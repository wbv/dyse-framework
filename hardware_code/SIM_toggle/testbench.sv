//Testbench

reg [64:0] mem[199:0];
bit [9:0] i;

module top();
   bit clk, rst, start, ld_inhibitor, steady_state;
   bit [9:0] iteration_number;
   bit [`STATE-1:0] network_state, initial_state;
   bit [`LOG_RULES-1:0]  sel_inhibitor;
   
   datapath dp(.clk(clk), .rst(rst), .start(start), .ld_inhibitor(ld_inhibitor),
	       .steady_state(steady_state), .network_state(network_state),
	       .sel_inhibitor(sel_inhibitor), .iteration_number(iteration_number), .initial_state(initial_state));

   testbench tb(.clk(clk), .rst(rst), .start(start), .ld_inhibitor(ld_inhibitor),
		.steady_state(steady_state), .network_state(network_state),
		.sel_inhibitor(sel_inhibitor), .iteration_number(iteration_number), .initial_state(initial_state));
endmodule // top

module testbench(
    input [`STATE-1:0] network_state,
    input 	 steady_state,
    input bit [9:0]  iteration_number,
    output reg 	 clk, rst, start, ld_inhibitor,
    output reg [`LOG_RULES-1:0] sel_inhibitor,
    output bit [`STATE-1:0] initial_state);

   always
     begin
	#5 clk = ~clk;
     end

   initial
     begin
	
	$readmemh(`SYNC_FILE, mem);

	initial_state = mem[0];

	$monitor($time,, "start=%b, ss=%b, network_state=%b, iteration_number=%d, initial_state = %h, seed_num=%d", 
                 start, steady_state, network_state, iteration_number, initial_state, i);

	for (i=0; i < `NUM_SEEDS; i=i+1) begin
		clk = 0;
		rst = 0;
		start = 0;
		ld_inhibitor = 0;
		sel_inhibitor = ~(`INHIBITOR);
		initial_state = mem[i];

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
