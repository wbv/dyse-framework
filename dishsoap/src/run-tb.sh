#!/bin/sh

# exit on failures
set -e

fix_perms() {
	chown -R --reference=. .
}
catch_exit() {
	echo Exiting...
}
trap catch_exit INT QUIT ABRT KILL TERM HUP 
trap fix_perms EXIT


TB_FILE='nw_reg_tb.vhdl'
TB="${TB_FILE%.vhdl}"

FLAGS='--std=93'

# show steps
set -x
ghdl -a $FLAGS $TB_FILE
ghdl -e $FLAGS $TB
ghdl -r $FLAGS $TB --wave="${TB}.waveform.ghw" 
