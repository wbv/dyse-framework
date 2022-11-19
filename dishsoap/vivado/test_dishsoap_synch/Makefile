#==============================#
# DiSHSOAP Vivado Build Script #
#==============================#

# Configuration
# -------------
# set these variables for your system, or override with environment variables

VIVADO ?= /opt/Xilinx/Vivado/2022.1/bin/vivado
VIVADO_OPTS ?= -m64 -notrace

# name of the bitstream/top-level module being built
DESIGN = dishsoap_vivado

.SUFFIXES:  # disable default suffix-based rules



all: all.tcl generate.tcl build.tcl
	$(VIVADO) $(VIVADO_OPTS) -mode batch -source $<


generate: $(DESIGN)/$(DESIGN).xpr

$(DESIGN)/$(DESIGN).xpr: generate.tcl
	$(VIVADO) $(VIVADO_OPTS) -mode batch -source $<


update: update.tcl
	$(VIVADO) $(VIVADO_OPTS) -mode batch -source $<


build: $(DESIGN).bit $(DESIGN).hwh

$(DESIGN).bit $(DESIGN).hwh: build.tcl
	$(VIVADO) $(VIVADO_OPTS) -mode batch -source $<



clean:
	@rm -vrf $(DESIGN)

.PHONY: all generate build clean
