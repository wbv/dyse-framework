//Control path for Random Order Asynchronous with new RNG

module controlpath(
    input clk, rst, start, is_updated, round_done, is_steady_state,
    output reg en_rng, ld_next_state, clr_updated, ld_updated, ld_last_state, steady_state, 
    output bit [9:0] round_number);

   parameter [2:0] reset_state = 0,
		simulation_state = 1,
		steady_simulation_state = 2;

   reg [2:0]   current_state, next_state;
   
   always @(posedge clk)
     begin
	if(~rst) begin
	  current_state <= reset_state;
	  round_number <= 0;
        end
	else
	  current_state <= next_state;
	if (round_done) round_number <= round_number + 1;
     end

   always @(*)
     begin
	case(current_state)
	  reset_state:
	    begin
	       en_rng = 0;
	       ld_next_state = 0;
	       clr_updated = start ? 1 : 0;
	       ld_updated = 0;
	       ld_last_state = 0;
	       steady_state = 0;
	       next_state = start ? simulation_state : reset_state;
	    end
	  simulation_state:
	    begin
	       en_rng = round_done ? 0 : 1;
	       ld_next_state = is_updated ? 0 : 1;
	       ld_updated = is_updated ? 0 : 1;
	       clr_updated = round_done ? 0 : 1;
	       ld_last_state = round_done ? 1 : 0;
	       steady_state = (round_done & is_steady_state) ? 1 : 0;
	       next_state = (round_done & is_steady_state) ? steady_simulation_state : simulation_state;
	    end
	  steady_simulation_state:
	    begin
	       en_rng = round_done ? 0 : 1;
	       ld_next_state = is_updated ? 0 : 1;
	       ld_updated = is_updated ? 0 : 1;
	       clr_updated = round_done ? 0 : 1;
	       ld_last_state = round_done ? 1 : 0;
	       steady_state = is_steady_state ? 1 : 0;
	       next_state = is_steady_state ? steady_simulation_state : simulation_state;
	    end
	  default:
	    begin
	       en_rng = 0;
	       ld_next_state = 0;
	       ld_updated = 0;
	       clr_updated = 0;
	       ld_last_state = 0;
	       steady_state = 0;
	       next_state = reset_state;
	    end
	endcase // case (current_state)
     end // always @ (*)

endmodule // controlpath
