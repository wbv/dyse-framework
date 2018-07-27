default:
	@echo -e "AWDW"

help:
	vcs -help

run1:
	vcs -sverilog names_II1.sv logic_t.sv controlpath.sv dp_components.sv datapath.sv rng_new.sv testbench.sv 
	./simv > II1_toggle_ca.txt

run2:
	vcs -sverilog names_II2.sv logic_t.sv controlpath.sv dp_components.sv datapath.sv rng_new.sv testbench.sv 
	./simv > II2_toggle_ca.txt

run3:
	vcs -sverilog names_II3.sv logic_t.sv controlpath.sv dp_components.sv datapath.sv rng_new.sv testbench.sv 
	./simv > II3_toggle_ca.txt

