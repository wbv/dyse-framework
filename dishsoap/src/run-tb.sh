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

if [ $# -lt 1 ]; then
	echo "E: Call with names of VHDL files to test (e.g. my_reg.vhdl)" >&2
	exit 1;
fi


# run testbench for each unit-under-test (UUT) specified
while [ $# -gt 0 ]; do
	UUT_FILE="$1"
	
	# check the arg each time through
	if [ ! -f "$UUT_FILE" ]; then
		echo "W: Can't find '$UUT_FILE'. Skipping." >&2
		shift
		continue
	elif [ "${UUT_FILE%.vhdl}" = "$UUT_FILE" ] \
	  && [ "${UUT_FILE%.vhd}"  = "$UUT_FILE" ]; then
		echo "W: '$UUT_FILE' Doesn't look like VHDL. Skipping." >&2
		shift
		continue
	fi

	# show steps for compilation
	set -x

	UUT="${UUT_FILE%.vhdl}"
	TB_FILE="${UUT}_tb.vhdl"
	TB="${TB_FILE%.vhdl}"

	FLAGS='--std=93'

	ghdl -a $FLAGS $UUT_FILE
	ghdl -a $FLAGS $TB_FILE
	ghdl -e $FLAGS $TB
	ghdl -r $FLAGS $TB --wave="${TB}.waveform.ghw" 

	set +x
	# end: show steps for compilation (this loop)
	shift
done
