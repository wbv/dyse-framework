//Datapath for General Asynchronous with new RNG

module datapath(
    input clk, rst, start, ld_inhibitor,
    input [63:0] seed,
    input [`LOG_RULES-1:0] sel_inhibitor,
    output [`RULES-1:0] network_state,
    output steady_state, 
    output bit [`LOG_ITER-1:0] iteration_number);

   wire [`RULES-1:0] 	current_state, logic_output, next_state, inhibitor_mask, updated, last_state;
   
   wire [63:0] 	  	random_addr;
   wire 	  	ld_next_state, clr_updated, ld_updated, steady, is_steady_state,
		  	ld_last_state, en_rng;
   bit		  	validRule;
   bit [`LOG_RULES-1:0] rule;

   assign network_state = current_state & ~inhibitor_mask;
   assign next_state = logic_output & ~inhibitor_mask;

   rule_map #(`GROUP_BITS, `LOG_RULES, `RULES, `GROUP_RULES) map(.random_addr(random_addr[`GROUP_BITS-1:0]), .rule(rule), .validRule(validRule));
   
   select_reg #(`RULES, `LOG_RULES) state_reg(.clk(clk), .rst(rst), .load(ld_next_state), .sel(rule),
		.data_in(next_state), .data_out(current_state), .init_state(`INITIAL_NETWORK_STATE));

   network_logic nl(.current_state(network_state), .next_state(logic_output));
   
   
   select_reg #(`RULES, `LOG_RULES) inhibitor_reg(.clk(clk), .rst(rst), .load(ld_inhibitor), .sel(sel_inhibitor),
		       .data_in(~(`RULES'h0)), .data_out(inhibitor_mask), .init_state(`RULES'h0));

   select_reg #(`RULES, `LOG_RULES) updated_reg(.clk(clk), .rst(clr_updated), .load(ld_updated), .sel(rule),
			  .data_in(~(`RULES'h0)), .data_out(updated), .init_state(`RULES'h0));

   register #(`RULES) last_state_reg(.clk(clk), .rst(rst), .load(ld_last_state), .data_in(current_state),
			   .data_out(last_state));

   lfsr rng(.clk(clk), .rst(rst), .en(en_rng), .data_out(random_addr), .seed(seed));

   /* To determine steady state for RA ensure that all the rules are run at least once, and ensure that no change occurs to network state. Use the updated reg 
      for this purpose (keeps track of what rules have been run). Each time network state changes reset updated reg (as you need to rerun each rule to ensure
      no change occurs in state due to a rule). If all rules are tried and network state doesn't change you have achieved steady state.*/

   comparator #(`RULES) cmp_1(.in1(updated), .in2(~(`RULES'h0)), .eq(steady));

   comparator #(`RULES) cmp_2(.in1(last_state), .in2(current_state), .eq(is_steady_state));
   
   controlpath fsm(.clk(clk), .rst(rst), .start(start), .en_rng(en_rng), 
		   .ld_next_state(ld_next_state), .clr_updated(clr_updated),
		   .ld_updated(ld_updated), .steady(steady),
		   .ld_last_state(ld_last_state), .is_steady_state(is_steady_state), 
		   .steady_state(steady_state), .iteration_number(iteration_number), .validRule(validRule));
endmodule // datapath
