`timescale 1 ns / 1 ps

module top(
	input clk, rst, start, ld_inhibitor,
	input [`LOG_RULES-1:0] sel_inhibitor,
	input bit [`STATE-1:0] initial_state,
	output [`STATE-1:0] network_state,
	output steady_state,
	output bit [9:0] iteration_number
);

	datapath dp(
		.clk(clk),
		.rst(rst),
		.start(start),
		.ld_inhibitor(ld_inhibitor),
		.steady_state(steady_state),
		.network_state(network_state),
		.sel_inhibitor(sel_inhibitor),
		.iteration_number(iteration_number),
		.initial_state(initial_state)
	);

endmodule
