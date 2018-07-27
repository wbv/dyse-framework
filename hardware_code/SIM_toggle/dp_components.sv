//DP_Library

`ifndef TOGGLE_RULE 
	`define TOGGLE_RULE 5
`endif

module register #(parameter WIDTH = 64)
   (input clk, rst, load,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out);

   always @(posedge clk)
     begin
	if(~rst)
	  data_out <= 'b0;
	else if(load)
	  data_out <= data_in;
     end
endmodule // register

module comparator #(parameter WIDTH = 64)
   (input [WIDTH-1:0] in1, in2,
    output eq);

   assign eq = (in1 == in2) ? 1 : 0;
endmodule // comparator

module demux #(parameter WIDTH = 64, W_LOG_2 = 6)
  (input [WIDTH-1:0] data_in,
   input [W_LOG_2-1:0] sel,
    output     data_out);

   assign data_out = data_in[sel];
endmodule // demux

/**
 * Register that loads a single bit from the input at a time, addressed by sel.
 * Reset state specified by init_state.
 */
module select_reg #(parameter WIDTH = 64, W_LOG_2 = 6)
   (input clk, rst, load,
    input [WIDTH-1:0] data_in, init_state,
    input [W_LOG_2-1:0] sel,
    output reg [WIDTH-1:0] data_out);

   always @(posedge clk)
     begin
	if(~rst)
	  data_out <= init_state;
	else if(load)
	  data_out[sel] <= data_in[sel];
     end
endmodule // state_reg

/**
 * Register that loads a single bit from the input at a time, addressed by sel.
 * Reset state specified by init_state. Also contains a toggle which flips a state
   bit at the appropriate round number. Used for ca simulation.
 */
module toggle_ca_reg #(parameter WIDTH = 64, W_LOG_2 = 6)
   (input clk, rst, load,
    input [9:0] toggle,
    input [WIDTH-1:0] data_in, init_state,
    input [W_LOG_2-1:0] sel, input [9:0] round_number,
    output reg [WIDTH-1:0] data_out);

   bit toggled; //Keeps track of whether or not the toggle has occurred already

   always @(posedge clk)
     begin
	if(~rst) begin
	  toggled <= 0;
	  data_out <= init_state;
	end
	else if(load) begin
	  data_out[sel] <= data_in[sel];
	  if (toggle == round_number & toggled == 0) begin
	    toggled <= 1;
	    data_out[`TOGGLE_RULE] <= ~data_out[`TOGGLE_RULE];
	  end
	end
     end
endmodule // state_reg

/**
 * Register that loads a single bit from the input at a time, addressed by sel.
 * Reset state specified by init_state. Also contains a toggle which flips a state
   bit at the appropriate iteration number. Used for ra simulation.
 */
module toggle_ra_reg #(parameter WIDTH = 64, W_LOG_2 = 6)
   (input clk, rst, load,
    input [9:0] toggle,
    input [WIDTH-1:0] data_in, init_state,
    input [W_LOG_2-1:0] sel, input [9:0] iteration_number,
    output reg [WIDTH-1:0] data_out);

   bit toggled; //Keeps track of whether or not the toggle has occurred already

   always @(posedge clk)
     begin
	if(~rst) begin
	  toggled <= 0;
	  data_out <= init_state;
	end
	else if(load) begin
	  data_out[sel] <= data_in[sel];
	  if (toggle == iteration_number & toggled == 0) begin
	    toggled <= 1;
	    data_out[`TOGGLE_RULE] <= ~data_out[`TOGGLE_RULE];
	  end
	end
     end
endmodule // state_reg

/**
 * Register that loads all bits from the input at a time, addressed by sel.
 * Reset state specified by init_state. Also contains a toggle which flips a state
   bit at the appropriate iteration number. Used for ra simulation.
 */
module toggle_ra_reg_prime #(parameter WIDTH = 64, W_LOG_2 = 6)
   (input clk, rst, load,
    input [9:0] toggle,
    input [WIDTH-1:0] data_in, init_state,
    input [9:0] iteration_number,
    output reg [WIDTH-1:0] data_out);

   bit toggled; //Keeps track of whether or not the toggle has occurred already

   always @(posedge clk)
     begin
	if(~rst) begin
	  toggled <= 0;
	  data_out <= init_state;
	end
	else if(load) begin
	  data_out <= data_in;
	  if (toggle == iteration_number & toggled == 0) begin
	    toggled <= 1;
	    data_out[`TOGGLE_RULE] <= ~data_out[`TOGGLE_RULE];
	  end
	end
     end
endmodule // state_reg

module valid_rule #(parameter RULES = 68, R_LOG_2 = 7)
	(input  bit [R_LOG_2-1:0] random_addr,
	 output bit validRule);

	assign validRule = (random_addr < RULES) ? 1 : 0;

endmodule

/* Maps groups of RNG numbers to one particular rule number. Used to minimize misses. */
module rule_map #(parameter LARGE = 10, MAP = 7, RULES = 68, GROUP = 15)
	(input  bit [LARGE-1:0] random_addr,
         output bit [MAP-1:0] rule,
	 output bit validRule);
	
	assign rule = random_addr / GROUP;
	assign validRule = (rule < RULES) ? 1 : 0;

endmodule

/* Use for Grouped Asynchronous. Can load multiple changed rules into the new current state for the
   next cycle. */
module select_reg_prime #(parameter WIDTH = 64)
   (input clk, rst, load,
    input [WIDTH-1:0] data_in, init_state,
    output reg [WIDTH-1:0] data_out);

   always @(posedge clk)
     begin
	if(~rst)
	  data_out <= init_state;
	else if(load)
	  data_out <= data_in;
     end
endmodule // state_reg
