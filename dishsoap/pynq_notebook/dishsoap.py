from typing import Sequence, List
import collections

import pynq
from pynq.buffer import PynqBuffer

import numpy as np


COUNTER_BITS = 16
COUNTER_MASK = (1 << COUNTER_BITS) - 1

class StreamController(pynq.DefaultIP):
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


class DishsoapIP(pynq.DefaultIP):
    """
    Object for the dishsoap IP core, which has a MMIO AXI register input and a
    streaming AXI-Stream output (intended to connect to a DMA device).
    """

    REG_SIZE = 8 # bytes per register

    def __init__(self, description):
        super().__init__(description)

    @property
    def status(self) -> int:
        return self.mmio.read(0x0, length=self.REG_SIZE)

    @property
    def ctrl(self) -> int:
        return self.mmio.read(0x8, length=self.REG_SIZE)

    @ctrl.setter
    def ctrl(self, value: int):
        if not isinstance(value, int):
            raise TypeError
        self.mmio.write(0x8, value)

    @property
    def init_state(self) -> List[int]:
        state = []
        for w in range(4):
            word = self.mmio.read(0x10 + (w*4), length=4)
            for i in range(32):
                state.append((word & (1<<i)) >> i)

        return state

    @init_state.setter
    def init_state(self, x):
        # set init state from a packed np.uint64
        if isinstance(x, np.uint64):
            x_bin = x.tobytes()
            lo, hi = x_bin[0:4], x_bin[4:8]
            self.mmio.write(0x10, lo)
            self.mmio.write(0x14, hi)

        # set init state from a list of states (easy)
        elif isinstance(x, collections.Sequence):
            if len(x) < 1:
                raise ValueError('init_state cannot be empty')
            elif len(x) > 64:
                raise IndexError(f'init_state too long (found {len(x)} elements)')

            states = [0]*2
            for bit, state in enumerate(x):
                # generously interpret things as booleans
                value = bool(int(state))
                # write the appropriate bit into the appropriate mmap'd word
                states[bit // 32] |= int(value) << (bit % 32)

            for i, state in enumerate(states):
                self.mmio.write(0x10 + (i*4), state)
        else:
            raise TypeError('init_state must be a sequence of states')


    @property
    def num_steps(self) -> int:
        return self.mmio.read(0x20, length=self.REG_SIZE)

    @num_steps.setter
    def num_steps(self, value: int):
        if not isinstance(value, int):
            raise TypeError
        self.mmio.write(0x20, value)

    def start(self):
        self.mmio.write(0x8, 1)

    bindto = ['wbv:user:dishsoap:0.1']



class TestDmaStreamOverlay(pynq.Overlay):
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


class DishsoapOverlay(pynq.Overlay):

    def __init__(self, bitfile_name='dishsoap_vivado.bit'):
        super().__init__(bitfile_name)
        if self.is_loaded():
            self.dma = self.axi_dma_0
            self.regs = self.dishsoap_0

    @property
    def network_size(self):
        return int(self.ip_dict['dishsoap_0']['parameters']['NETWORK_SIZE'])

    @property
    def elements(self):
        # cheat: hardcode this for demo until it's inserted as part of the
        # synthesis + config step
        return ['TF', 'Inh', 'Xgene', 'Xrna', 'Xprotein']

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
        info += f'0x00 status:        {self.regs.mmio.read(0x00, length=self.REG_SIZE):b}\n'
        info += f'0x08 control:       {self.regs.mmio.read(0x08, length=self.REG_SIZE):b}\n'
        info += f'0x10 init_state:    {self.regs.mmio.read(0x10, length=self.REG_SIZE):03b}\n'
        info += f'0x20 num_steps:     {self.regs.mmio.read(0x20, length=self.REG_SIZE):d}\n'
        info += f'0x28 dbg 0:         {self.regs.mmio.read(0x28, length=self.REG_SIZE):064b}\n'
        info += f'0x30 sim_state:     {self.regs.mmio.read(0x30, length=self.REG_SIZE):03b}\n'
        info += f'0x38 max_steps:     {self.regs.mmio.read(0x38, length=self.REG_SIZE):d}\n'
        info += f'0x40 step_counter:  {self.regs.mmio.read(0x40, length=self.REG_SIZE):d}\n'
        return info

    @staticmethod
    def print_dbg(dbg):
        print(f"axis_tready:  {(dbg & (1 << 0 )) >> 0 }")
        print(f"axis_tvalid:  {(dbg & (1 << 1 )) >> 1 }")
        print(f"axis_tlast:   {(dbg & (1 << 2 )) >> 2 }")
        print(f"stream_ready: {(dbg & (1 << 3 )) >> 3 }")
        print()
        print(f"sim_state_valid: {(dbg & (1 << 8 )) >>  8}")
        print(f"sim_state_last:  {(dbg & (1 << 9 )) >>  9}")
        print(f"sim_done:        {(dbg & (1 << 10)) >> 10}")
        print()
        print(f"state IDLE        {(dbg & (1 << 24)) >> 24}")
        print(f"state INIT_DELAY  {(dbg & (1 << 25)) >> 25}")
        print(f"state SEND_STREAM {(dbg & (1 << 26)) >> 26}")
        print()


    def debug_dma(self):
        if self.dma.recvchannel is not None:
            print('DMA Channel: s2mm')
            print(self.dma_status)
            print(self.dma_regs)

    def debug_all_dishsoap_regs(self):
        print(self.dishsoap_regs)

    def debug_probes(self):
        self.print_dbg(self.regs.mmio.read(0x28, length=self.REG_SIZE))

    def debug_both(self):
        self.debug_dma()
        self.debug_all_dishsoap_regs()
        self.debug_probes()

    def unpack(self, value) -> np.ndarray:
        if isinstance(value, np.uint64):
            return state_unpack(value, self.network_size)
        elif isinstance(value, np.ndarray):
            return np.array([state_unpack(v, self.network_size) for v in value])

    def run_synch_inplace(self, init_state, results: PynqBuffer):
        # figure out how many steps we take based on shape of results
        num_steps = results.shape[0] - 1

        # tell the DMA expect & transfer num_steps+1 states
        self.dma.recvchannel.transfer(results)

        # then configure & tell the sim to run
        self.regs.init_state = init_state
        self.regs.num_steps = num_steps
        self.regs.start()

        # and block until the sim to finishes and we have results to return
        self.dma.recvchannel.wait()

        return

    def run_synch(self, init_state: Sequence[int], num_steps: int):

        results = pynq.allocate(shape=(num_steps+1,), dtype=np.uint64)

        self.run_synch_inplace(init_state, results)

        list_by_time = [packed_to_list(r, self.network_size) for r in results]
        list_by_element = [[r[i] for r in list_by_time] for i in range(self.network_size)]
        return list_by_element

    def run_synch_np(self, init_state: np.uint64, num_steps: int):

        results = pynq.allocate(shape=(num_steps+1,), dtype=np.uint64)
        self.run_synch_inplace(init_state, results)
        return results



def packed_to_list(state: np.uint64, size: int = 64) -> List[int]:
    return [int(bool((int(state) & (1 << i)) >> i)) for i in range(size)]

def list_to_packed(state: Sequence[int]) -> np.uint64:
    if len(state) > 64:
        raise ValueError(f'cannot pack >64 elements (got {len(state)}')

    x = np.uint64(0)
    for i, s in enumerate(state):
        x |= np.uint64(int(bool(int(s))) << i)
    return x

def list_to_array(x: Sequence[int]) -> np.ndarray:
    return np.ndarray([int(bool(int(i))) for i in x])

def array_to_list(x: np.ndarray) -> Sequence[int]:
    return [int(v) for v in x.flat]

def state_unpack(x: np.uint64, bits: int):
    return np.unpackbits(x.flatten().view(np.uint8), count=bits, bitorder='little')


## TESTS ##




Dish = DishsoapOverlay
Overlay = DishsoapOverlay
