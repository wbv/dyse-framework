/**
 *  64-bit linear feedback shift register.  The seed is the reset state of the register. Let width be 2 * log2(Number of Rules)
 *  A receives lfsr inputs and prioritizes them. After it is full it loads into B, which sends info out to datapath. As
 *  B is sending out info, A is being reloaded. First half of a register is the priority, the second is the lfsr input
 */
module lfsr #(parameter RULES = 61, WIDTH = 12, HALF = 6)
    (input clk, rst, en,
    input [63:0] seed,
    output reg [63:0] data_out,
    output reg [HALF-1:0] B_out);

   reg [RULES-1:0][WIDTH-1:0] A, B;
   logic A_full, A_empty, B_empty;
   reg [9:0] A_elements, B_elements; 
   logic [HALF-1:0] d_out, A_priority;

   always @(posedge clk)
     begin
	if(~rst) begin
	  data_out <= seed;
	  A_elements <= 0; B_elements <= 0;
        end
	else if(en) begin
	  data_out <= {data_out[0] ^ data_out[1] ^ data_out[3] ^ data_out[4], data_out[63:1]};
	  if (~B_empty) begin
	    B_elements <= B_elements - 1;
	    B_out <= B[B_elements-1][WIDTH-1:HALF];
          end
	  if (A_empty) begin
	    A[0][WIDTH-1:HALF] <= 0; //Default priority of first element is 0
	    A[0][HALF-1:0] <= d_out;
	    A_elements <= 1;
    	  end
	  else if (~A_empty & ~A_full) begin
	    A_elements <= A_elements + 1;
	    for (int i=0; i <A_elements; i++) begin
	      /* Increase priority if new elements is smaller than old elements. */
	      if (d_out < A[i][HALF-1:0]) A[i][WIDTH-1:HALF] <= A[i][WIDTH-1:HALF] + 1;
	    end
	    A[A_elements][WIDTH-1:HALF] <= A_priority;
	    A[A_elements][HALF-1:0] <= d_out;
	  end
	  else if (A_full) begin
	    A_elements <= 1;
	    A[0][WIDTH-1:HALF] <= 0; //Default priority of first element is 0
	    A[0][HALF-1:0] <= d_out;
	    B <= A;
	    B_elements <= RULES;
	  end
	end
     end

   always_comb begin
     d_out = data_out[HALF:1];
     A_empty = (A_elements == 0);
     B_empty = (B_elements == 0);
     A_full = (A_elements == RULES);
     A_priority = 0;
     for (int j=0; j<A_elements; j++) begin
       if (d_out >= A[j][HALF-1:0]) A_priority = A_priority + 1;
     end
   end
endmodule // lfsr
