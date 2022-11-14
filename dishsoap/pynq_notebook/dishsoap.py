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


Overlay = TestDmaStreamOverlay
