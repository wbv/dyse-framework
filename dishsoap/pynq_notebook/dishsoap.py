from typing import Sequence
import collections

from pynq import DefaultIP, Overlay
from pynq import allocate
from pynq.buffer import PynqBuffer

import numpy as np


COUNTER_BITS = 16
COUNTER_MASK = (1 << COUNTER_BITS) - 1

class StreamController(DefaultIP):
    """
    Object for the count_stream_test IP core, which has a MMIO register
    interface that connects to a streaming DMA device.
    """

    def __init__(self, description):
        super().__init__(description)

    @property
    def low(self) -> int:
        return self.mmio.read(0x0)

    @low.setter
    def low(self, value: int):
        if not isinstance(value, int):
            raise TypeError
        elif value < 0 or value > COUNTER_MASK:
            raise ValueError(f"Counter must be between 0 and {COUNTER_MASK}"
                             f"(got: {value})")

        self.mmio.write(0x0, value)

    @property
    def high(self) -> int:
        return self.mmio.read(0x4)

    @high.setter
    def high(self, value: int):
        if not isinstance(value, int):
            raise TypeError
        elif value < 0 or value > COUNTER_MASK:
            raise ValueError(f"Counter must be between 0 and {COUNTER_MASK}"
                             f"(got: {value})")

        self.mmio.write(0x4, value)

    @property
    def status(self) -> int:
        return self.mmio.read(0xc, 1)

    def go(self):
        self.mmio.write(0x8, 1)

    bindto = ['wbv:user:count_stream_test:0.2']


class DishsoapIP(DefaultIP):
    """
    Object for the dishsoap IP core, which has a MMIO AXI register input and a
    streaming AXI-Stream output (intended to connect to a DMA device).
    """

    REG_SIZE = 4 # bytes per register

    def __init__(self, description):
        super().__init__(description)

    @property
    def status(self) -> int:
        return self.mmio.read(0x0, length=8)

    @property
    def ctrl(self) -> int:
        return self.mmio.read(0x8, length=8)

    @ctrl.setter
    def ctrl(self, value: int):
        if not isinstance(value, int):
            raise TypeError
        self.mmio.write(0x8, value)

    @property
    def init_state(self) -> int:
        lo = self.mmio.read(0x10, length=8)
        hi = self.mmio.read(0x18, length=8)
        return (hi << 32) | lo

    @init_state.setter
    def init_state(self, value: int):
        if not isinstance(value, int):
            raise TypeError
        lo = value         & 0xffffffff
        hi = (value >> 32) & 0xffffffff
        self.mmio.write(0x10, lo)
        self.mmio.write(0x18, hi)

    @property
    def num_steps(self) -> int:
        return self.mmio.read(0x20, length=8)

    @num_steps.setter
    def num_steps(self, value: int):
        if not isinstance(value, int):
            raise TypeError
        self.mmio.write(0x20, value)

    def start(self):
        self.mmio.write(0x8, 1)
        self.mmio.write(0xc, 1)


    bindto = ['wbv:user:dishsoap:0.1']



class TestDmaStreamOverlay(Overlay):
    def __init__(self, bitfile_name='test_dma_stream.bit'):
        super().__init__(bitfile_name)
        if self.is_loaded():
            self.dma = self.axi_dma_0
            self.counter_stream = self.count_stream_test_0

    @property
    def dma_status(self):
        self.dma.recvchannel
        r = self.dma.recvchannel.running
        i = self.dma.recvchannel.idle
        e = self.dma.recvchannel.error

        return f'Run:{r} Idle:{i} Err:{e}'

    @property
    def dma_regs(self):
        offset = 0x30 # read DMA offset
        info = ''
        cr = self.dma.mmio.read(offset + 0x0)
        sr = self.dma.mmio.read(offset + 0x4)
        lo = self.dma.mmio.read(offset + 0x18)
        hi = self.dma.mmio.read(offset + 0x1c)
        sz = self.dma.mmio.read(offset + 0x28)
        info += f'CR:   0x{cr:08x}\n'
        info += f'SR:   0x{sr:08x}\n'
        info += f'addr: 0x{hi:08x}{lo:08x}\n'
        info += f'len:  0x{sz:08x}\n'
        return info

    @property
    def stream_regs(self):
        info = ''
        lo    = self.counter_stream.read(0x0)
        hi    = self.counter_stream.read(0x4)
        info += f'StreamCfg: {lo} to {hi}\n'
        debug = self.counter_stream.read(0xc)
        info += f'TVALID: {(debug & (1 << 0)) >> 0} '
        info += f'TLAST: {(debug & (1 << 1)) >> 1} '
        info += f'TREADY: {(debug & (1 << 2)) >> 2}\n'
        info += f'counter_start: {(debug & (1 << 4)) >> 4}\n'
        info += f'read_pointer: {debug >> 16} '
        info += f'tx_en: {(debug & (1 << 8)) >> 8}\n'
        return info

    def debug_dma(self):
        if self.dma.recvchannel is not None:
            print('Recv Channel', self.dma_status)
            print(self.dma_regs)

    def debug_stream(self):
        print(self.stream_regs)

    def debug_both(self):
        self.debug_dma()
        self.debug_stream()

    def fill_buffer(self, start: int, array: PynqBuffer):
        if not isinstance(array, PynqBuffer):
            raise TypeError('fill_buffer requires array via pynq.allocate()')
        elif (array.nbytes % 8) != 0:
            raise TypeError('fill_buffer: array must be 8-byte aligned')

        length = int(array.nbytes // 8)

        self.dma.recvchannel.transfer(array)

        self.counter_stream.low  = start
        self.counter_stream.high = start + length - 1
        self.counter_stream.go()

        self.dma.recvchannel.wait()
        return

class DishsoapOverlay(Overlay):
    def __init__(self, bitfile_name='dishsoap_vivado.bit'):
        super().__init__(bitfile_name)
        if self.is_loaded():
            self.dma = self.axi_dma_0
            self.regs = self.dishsoap_0

    @property
    def dma_status(self):
        self.dma.recvchannel
        r = self.dma.recvchannel.running
        i = self.dma.recvchannel.idle
        e = self.dma.recvchannel.error

        return f'Run:{r} Idle:{i} Err:{e}'

    @property
    def dma_regs(self):
        offset = 0x30 # read DMA offset
        info = ''
        cr = self.dma.mmio.read(offset + 0x0)
        sr = self.dma.mmio.read(offset + 0x4)
        lo = self.dma.mmio.read(offset + 0x18)
        hi = self.dma.mmio.read(offset + 0x1c)
        sz = self.dma.mmio.read(offset + 0x28)
        info += f'CR:   0x{cr:08x}\n'
        info += f'SR:   0x{sr:08x}\n'
        info += f'addr: 0x{hi:08x}{lo:08x}\n'
        info += f'len:  0x{sz:08x}\n'
        return info

    @property
    def dishsoap_regs(self):
        info = ''
        for i in range(16):
            info += f'0x{i*8:02x}: {self.regs.mmio.read(i*8, length=8)}' + "\n"
        return info

    def debug_dma(self):
        if self.dma.recvchannel is not None:
            print('Recv Channel', self.dma_status)
            print(self.dma_regs)

    def debug_stream(self):
        print(self.dishsoap_regs)

    def debug_both(self):
        self.debug_dma()
        self.debug_stream()

    def debug_probes(self):
        dbg = self.regs.mmio.read(0x28, length=8)
        print(f"stream valid:    {(dbg & (1 << 0 )) >> 0 }")
        print(f"axis_tvalid:     {(dbg & (1 << 1 )) >> 1 }")
        print(f"axis_tlast:      {(dbg & (1 << 2 )) >> 2 }")
        print(f"network[0]:      {(dbg & (1 << 8 )) >> 8 }")
        print(f"network[1]:      {(dbg & (1 << 9 )) >> 9 }")
        print(f"network[2]:      {(dbg & (1 << 10)) >> 10}")
        print(f"sim_state_valid: {(dbg & (1 << 16)) >> 16}")
        print(f"sim_state_last:  {(dbg & (1 << 17)) >> 17}")
        print(f"sim_done:        {(dbg & (1 << 18)) >> 18}")

    def run_synch(self, results: PynqBuffer,
                  init_state: Sequence[int], num_iters: int):
        if not isinstance(results, PynqBuffer):
            raise TypeError('\'results\' must be from pynq.allocate()')

        elif not isinstance(init_state, collections.Sequence):
            raise TypeError('\'init_state\' must be a sequence of bits')

        elif (results.nbytes % 8) != 0:
            raise TypeError('\'results\' must be 8-byte aligned')

#        elif results.nbytes // 8 != num_iters:
#            raise RuntimeError(f"mismatched iterations ({available_states} !=" +
#                               f" {num_iters})")

        self.dma.recvchannel.transfer(results)

        state = [0,0,0,0] # 4 32-bit words smh
        for i in range(len(init_state)):
            if init_state[i]:
                state[(i//32)] |= (1 << i)

        self.regs.mmio.write(0x10, state[0])
        self.regs.mmio.write(0x14, state[1])
        self.regs.mmio.write(0x18, state[2])
        self.regs.mmio.write(0x1c, state[3])


        #self.regs.init_state_lo = state_lo
        #self.regs.init_state_hi = state_hi
        self.regs.num_steps = num_iters
        self.regs.start()

        self.dma.recvchannel.wait()
        return


Overlay = DishsoapOverlay
