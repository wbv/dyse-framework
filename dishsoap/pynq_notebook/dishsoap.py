from pynq import DefaultIP, Overlay

class CountStreamTest(DefaultIP):
    def __init__(self, description):
        super().__init__(description)
    bindto = ['wbv:user:count_stream_test:0.1']

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
    def __init__(self, bitfile_name, download):
        super().__init__(bitfile_name, download)

Overlay = TestDmaStreamOverlay
