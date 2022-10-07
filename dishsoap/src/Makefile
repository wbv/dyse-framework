# Makefile for automated GHDL testbench running

GHDLFLAGS := --std=93
GHDL ?= $(shell command -v ghdl)

ifeq ($(GHDL),)
$(error Can't find 'ghdl'. Make sure it's installed and in your PATH)
endif

.SUFFIXES:

# run all tests by default
all: test

# add entity names of all testbenches here
TESTBENCHES += nw_reg_tb
TESTBENCHES += network_toy_tb

# special file GHDL creates when building the library
WORKFILE := work-obj93.cf

# define waveform outputs as a means to force testbench running
WAVEFORMS := $(foreach tb,$(TESTBENCHES),$(tb).waveform.ghw)

# scans all vhdl files in the current directory into library
$(WORKFILE): $(wildcard *.vhdl) $(wildcard *.vhd)
	$(GHDL) -i $(GHDLFLAGS) $^

# get a waveform from the base file
%.waveform.ghw: %
	$(GHDL) -r $< --wave=$@
	
# testbenches can be auto-built if the workfile ("library") is populated
%_tb: $(WORKFILE)
	$(GHDL) -m $(GHDLFLAGS) $@
	
# test target just generates all waveforms (which necessarily runs all tests)
test: $(WAVEFORMS)


# protect intermediary files
.PRECIOUS: %_tb

clean: $(WORKFILE)
	$(GHDL) --remove

clean-waveforms:
	@rm -vf *.ghw
	@rm -vf *.gtkw

.PHONY: all test clean clean-waveforms
