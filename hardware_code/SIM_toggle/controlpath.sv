//Controlpath

module controlpath(
    input clk, rst, start, is_steady_state,
    output reg en_rng, ld_next_state, ld_last_state, steady_state, 
    output bit [9:0] iteration_number);

   parameter [2:0] reset_state = 0,
		simulation_state = 1,
		steady_simulation_state = 2;

   reg [2:0]   current_state, next_state;
   
   always @(posedge clk)
     begin
	if(~rst) begin
	  current_state <= reset_state;
	  iteration_number <= 0;
        end
	else
	  current_state <= next_state;
	/* It counts as an iteration each time you are loading the next rule from either the simulation state
           or the steady state. */
	if (current_state == simulation_state) iteration_number <= iteration_number + 1; //Always increment iteration_number for synchronous
     end

   always @(*)
     begin
	case(current_state)
	  reset_state:
	    begin
	       en_rng = 0;
	       ld_next_state = 0;
	       ld_last_state = 0;
	       steady_state = 0;
	       next_state = start ? simulation_state : reset_state;
	    end
	  simulation_state:
	    begin
	       en_rng = 1;
	       ld_next_state = 1; //Always update next state for random asynchronous
	       ld_last_state = 1;
	       steady_state = is_steady_state; 
	       next_state = simulation_state;
	    end
	  default:
	    begin
	       en_rng = 0;
	       ld_next_state = 0;
	       ld_last_state = 0;
	       steady_state = 0;
	       next_state = reset_state;
	    end
	endcase // case (current_state)
     end // always @ (*)

endmodule // controlpath
