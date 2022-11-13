from pynq import DefaultIP, Overlay
from pynq import allocate


class CountStreamTest(DefaultIP):
    def __init__(self, description):
        super().__init__(description)
        self._low  = 0
        self._high = 0

    @property
    def low(self):
        return self._low

    @low.setter
    def low(self, value: int):
        if not isinstance(value, int):
            raise TypeError

        self._low = value & 0xffff
        self.mmio.write(0x0, self._low)

    @property
    def high(self):
        return self._high

    @high.setter
    def high(self, value: int):
        if not isinstance(value, int):
            raise TypeError

        self._high = value & 0xffff
        self.mmio.write(0x4, self._high)

    bindto = ['wbv:user:count_stream_test:0.2']

class ExProjOverlay(Overlay):
    def __init__(self, bitfile_name, download):
        super().__init__(bitfile_name, download)

        # populate helper attributes for GPIO, etc
        if self.is_loaded():
            # LEDs and Buttons are both on axi_gpio_0
            self.leds = self.axi_gpio_0.channel1
            self.leds.setlength(4)
            self.leds.setdirection("out")
            self.btns = self.axi_gpio_0.channel2
            self.btns.setlength(4)
            self.btns.setdirection("in")

class TestDmaStreamOverlay(Overlay):
    def __init__(self, bitfile_name='test_dma_stream.bit'):
        super().__init__(bitfile_name)

        if self.is_loaded():
            self.dma = self.axi_dma_0
            self.counter_stream = self.count_stream_test_0

    @staticmethod
    def chan_status(chan):
        if chan is None:
            return ''

        r = chan.running
        i = chan.idle
        e = chan.error

        return f'Run:{r} Idle:{i} Err:{e}'

    @staticmethod
    def dump_regs(dma, offset):
        info = ''
        cr = dma.mmio.read(offset + 0x0)
        sr = dma.mmio.read(offset + 0x4)
        lo = dma.mmio.read(offset + 0x18)
        hi = dma.mmio.read(offset + 0x1c)
        sz = dma.mmio.read(offset + 0x28)
        info += f'CR:   0x{cr:08x}\n'
        info += f'SR:   0x{sr:08x}\n'
        info += f'addr: 0x{hi:08x}{lo:08x}\n'
        info += f'len:  0x{sz:08x}\n'
        return info

    @staticmethod
    def dump_stream_regs(count_stream):
        info = ''
        lo    = count_stream.read(0x0)
        hi    = count_stream.read(0x4)
        info += f'StreamCfg: {lo} to {hi}\n'
        debug = count_stream.read(0xc)
        info += f'TVALID: {(debug & (1 << 0)) >> 0} '
        info += f'TLAST: {(debug & (1 << 1)) >> 1} '
        info += f'TREADY: {(debug & (1 << 2)) >> 2}\n'
        info += f'counter_start: {(debug & (1 << 4)) >> 4}\n'
        info += f'read_pointer: {debug >> 16} '
        info += f'tx_en: {(debug & (1 << 8)) >> 8}\n'
        return info


    def debug_dma(self):
        if self.dma.recvchannel is not None:
            print('Recv Channel', self.chan_status(self.dma.recvchannel))
            print(self.dump_regs(self.dma, 0x30))

    def debug_stream(self):
        print(self.dump_stream_regs(self.counter_stream))

    def debug_both(self):
        self.debug_dma()
        self.debug_stream()


Overlay = TestDmaStreamOverlay
