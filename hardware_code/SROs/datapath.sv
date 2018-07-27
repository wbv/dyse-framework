//Datapath for Random Order Asynchronous with new RNG

module datapath(
    input clk, rst, start, ld_inhibitor,
    input [63:0] seed,
    input [`LOG_RULES-1:0] sel_inhibitor,
    output [`RULES-1:0] network_state,
    output steady_state, 
    output bit [9:0] round_number);

   reg [`LOG_RULES-1:0]	B_out;
   wire [`RULES-1:0] 	current_state, logic_output, next_state, inhibitor_mask, updated, last_state;
   
   wire [63:0] 	  	random_addr;
   wire 	  	ld_next_state, clr_updated, ld_updated, is_updated, round_done, is_steady_state,
		  	ld_last_state, en_rng;

   assign network_state = current_state & ~inhibitor_mask;
   assign next_state = logic_output & ~inhibitor_mask;
   
   select_reg #(`RULES, `LOG_RULES) state_reg(.clk(clk), .rst(rst), .load(ld_next_state), .sel(B_out),
		.data_in(next_state), .data_out(current_state), .init_state(`INITIAL_NETWORK_STATE));

   network_logic nl(.current_state(network_state), .next_state(logic_output));
   
   
   select_reg #(`RULES, `LOG_RULES) inhibitor_reg(.clk(clk), .rst(rst), .load(ld_inhibitor), .sel(sel_inhibitor),
		       .data_in(~(`RULES'h0)), .data_out(inhibitor_mask), .init_state(`RULES'h0));

   select_reg #(`RULES, `LOG_RULES) updated_reg(.clk(clk), .rst(clr_updated), .load(ld_updated), .sel(B_out),
			  .data_in(~(`RULES'h0)), .data_out(updated), .init_state(`RULES'h0));

   register #(`RULES) last_state_reg(.clk(clk), .rst(rst), .load(ld_last_state), .data_in(current_state),
			   .data_out(last_state));
   
   demux #(`NEAR_POW_2, `LOG_RULES) demux_updated(.data_in({~(`PADDING'b0), updated}), .sel(B_out), .data_out(is_updated));

   lfsr #(`RULES, `LOG_RULES_2, `LOG_RULES) rng(.clk(clk), .rst(rst), .en(en_rng), .data_out(random_addr), .seed(seed), .B_out(B_out));

   comparator #(`RULES) cmp_1(.in1(updated), .in2(~(`RULES'h0)), .eq(round_done));

   comparator #(`RULES) cmp_2(.in1(last_state), .in2(current_state), .eq(is_steady_state));
   
   controlpath fsm(.clk(clk), .rst(rst), .start(start), .en_rng(en_rng), 
		   .ld_next_state(ld_next_state), .clr_updated(clr_updated),
		   .ld_updated(ld_updated), .is_updated(is_updated), .round_done(round_done),
		   .ld_last_state(ld_last_state), .is_steady_state(is_steady_state), 
		   .steady_state(steady_state), .round_number(round_number));
endmodule // datapath
