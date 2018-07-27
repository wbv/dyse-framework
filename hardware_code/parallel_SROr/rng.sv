/**
 *  64-bit linear feedback shift register.  The seed is the reset state of the register.
 */
module lfsr(
    input clk, rst, en,
    input [63:0] seed,
    output reg [63:0] data_out);

   always @(posedge clk)
     begin
	if(~rst)
	  data_out <= seed;
	else if(en)
	  data_out <= {data_out[0] ^ data_out[1] ^ data_out[3] ^ data_out[4], data_out[63:1]};
	//$display("%d", data_out[9:0]);
     end
endmodule // lfsr
