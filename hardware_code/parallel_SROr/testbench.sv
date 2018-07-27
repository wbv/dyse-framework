//Testbench
`include "names_I1.sv"
reg [128:0] mem[`NUM_SEEDS-1:0];
bit [9:0] i;

module top();
   bit clk, rst, start, ld_inhibitor, steady_state1, steady_state2;
   bit [`LOG_ITER-1:0] iteration_number;
   bit [`RULES-1:0] network_state1, network_state2;
   bit [127:0] seed;
   bit [`LOG_RULES-1:0]  sel_inhibitor;
   
   datapath dp(.clk(clk), .rst(rst), .start(start), .ld_inhibitor(ld_inhibitor),
	       .steady_state(steady_state1), .network_state(network_state1),
	       .sel_inhibitor(sel_inhibitor), .seed(seed[63:0]), .iteration_number(iteration_number));

   datapath dp2(.clk(clk), .rst(rst), .start(start), .ld_inhibitor(ld_inhibitor),
	       .steady_state(steady_state2), .network_state(network_state2),
	       .sel_inhibitor(sel_inhibitor), .seed(seed[127:64]), .iteration_number(iteration_number));

   testbench tb(.clk(clk), .rst(rst), .start(start), .ld_inhibitor(ld_inhibitor),
		.steady_state1(steady_state1), .steady_state2(steady_state2), 
		.network_state1(network_state1), .network_state2(network_state2),
		.sel_inhibitor(sel_inhibitor), .seed(seed), .iteration_number(iteration_number));
endmodule // top

module testbench(
    input [`RULES-1:0] network_state1, network_state2,
    input 	 steady_state1, steady_state2,
    input bit [`LOG_ITER-1:0]  iteration_number,
    output reg 	 clk, rst, start, ld_inhibitor,
    output reg [`LOG_RULES-1:0] sel_inhibitor,
    output reg [127:0] seed);

   always
     begin
	#5 clk = ~clk;
     end

   initial
     begin
	
	$readmemh("seeds.txt", mem);
	seed = mem[0];

	$monitor($time,, "start=%b, ss1=%b, network_state1=%b, ss2=%b, network_state2=%b, iteration_number=%d, seed=%h, seed_num=%d", 
                 start, steady_state1, network_state1, steady_state2, network_state2, iteration_number, seed, i);

	for (i=0; i < `NUM_SEEDS; i=i+1) begin
		clk = 0;
		rst = 0;
		start = 0;
		ld_inhibitor = 0;
		sel_inhibitor = ~(`INHIBITOR);
		seed = mem[i];

		@(posedge clk);
		@(posedge clk);

		#1 rst = 1;
		@(posedge clk);
	
		#1 ld_inhibitor = 1;
		@(posedge clk);

		#1 ld_inhibitor = 0;
		@(posedge clk);

		#1 start = 1;
		@(posedge clk);

		#1 start = 0;
		@(posedge clk);
	
		while (iteration_number < `ITERATION_NUMBER) @(posedge clk);
	end
	
	$finish;
     end // initial begin
endmodule // testbench   
