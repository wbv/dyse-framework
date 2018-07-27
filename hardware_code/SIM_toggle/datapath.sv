//Datapath for Synchronous. Does not need rng, updated reg.

module datapath(
    input clk, rst, start, ld_inhibitor,
    input [`LOG_RULES-1:0] sel_inhibitor, input bit [`STATE-1:0] initial_state,
    output [`STATE-1:0] network_state,
    output steady_state, 
    output bit [9:0] iteration_number);

   reg [`STATE-1:0]    	current_state, logic_output, next_state, inhibitor_mask, last_state, last_last_state;
   wire 	  	ld_next_state, is_steady_state, ld_last_state, en_rng, last_steady, last_last_steady;

   assign network_state = current_state & ~inhibitor_mask;
   assign next_state = logic_output & ~inhibitor_mask;
   assign is_steady_state = last_steady & last_last_steady;

   toggle_ra_reg_prime #(`STATE, `LOG_RULES) state_reg_prime(.clk(clk), .rst(rst), .load(ld_next_state), .iteration_number(iteration_number),
		.data_in(next_state), .data_out(current_state), .init_state(initial_state), .toggle(`TOGGLE));

   network_logic nl(.current_state(network_state), .next_state(logic_output), .clk(clk), .iteration_number(iteration_number));

   select_reg #(`STATE, `LOG_RULES) inhibitor_reg(.clk(clk), .rst(rst), .load(ld_inhibitor), .sel(sel_inhibitor),
		       .data_in(~(`STATE'h0)), .data_out(inhibitor_mask), .init_state(`STATE'h0));

   register #(`STATE) last_state_reg(.clk(clk), .rst(rst), .load(ld_last_state), .data_in(current_state),
			   .data_out(last_state));

   register #(`STATE) last_last_state_reg(.clk(clk), .rst(rst), .load(ld_last_state), .data_in(last_state),
			   .data_out(last_last_state));

   /* Due to timing of non-blocking statements, to determine steady state for synchronous
      check if the state two states before equals the current state, and if the last state
      equals the current state.*/

   comparator #(`STATE) cmp_1(.in1(last_state), .in2(current_state), .eq(last_steady));

   comparator #(`STATE) cmp_2(.in1(last_last_state), .in2(current_state), .eq(last_last_steady));
   
   controlpath fsm(.clk(clk), .rst(rst), .start(start), .en_rng(en_rng), 
		   .ld_next_state(ld_next_state),
		   .ld_last_state(ld_last_state), .is_steady_state(is_steady_state), 
		   .steady_state(steady_state), .iteration_number(iteration_number));
endmodule // datapath
