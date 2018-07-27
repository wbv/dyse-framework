//Testbench

reg [64:0] mem[`NUM_SEEDS:0];
bit [11:0] i;

module top();
   bit clk, rst, start, ld_inhibitor, steady_state;
   bit [9:0] round_number;
   bit [`RULES-1:0] network_state;
   bit [63:0] seed;
   bit [`LOG_RULES-1:0]  sel_inhibitor;
   
   datapath dp(.clk(clk), .rst(rst), .start(start), .ld_inhibitor(ld_inhibitor),
	       .steady_state(steady_state), .network_state(network_state),
	       .sel_inhibitor(sel_inhibitor), .seed(seed), .round_number(round_number));

   testbench tb(.clk(clk), .rst(rst), .start(start), .ld_inhibitor(ld_inhibitor),
		.steady_state(steady_state), .network_state(network_state),
		.sel_inhibitor(sel_inhibitor), .seed(seed), .round_number(round_number));
endmodule // top

module testbench(
    input [`RULES-1:0] network_state,
    input 	 steady_state,
    input bit [9:0]  round_number,
    output reg 	 clk, rst, start, ld_inhibitor,
    output reg [`LOG_RULES-1:0] sel_inhibitor,
    output reg [63:0] seed);

   always
     begin
	#5 clk = ~clk;
     end

   initial
     begin
	
	$readmemh("seeds.txt", mem);

	seed = mem[0];

	$monitor($time,, "start=%b, ss=%b, network_state=%b, round_number=%d, seed=%h, seed_num=%d", 
                 start, steady_state, network_state, round_number, seed, i);

	for (i=0; i < `NUM_SEEDS; i=i+1) begin
		clk = 0;
		rst = 0;
		start = 0;
		ld_inhibitor = 0;
		sel_inhibitor = ~(`LOG_RULES'b0);
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
	
		while (round_number < `ROUND_NUMBER) @(posedge clk);
	end
	
	$finish;
     end // initial begin
endmodule // testbench   
