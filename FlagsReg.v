module FlagsReg(input clk,  input rst, input [2:0] D, input WriteReg, output [2:0] out);

dff ff0(.q(out[0]),		.d(D[0]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff1(.q(out[1]),		.d(D[1]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff2(.q(out[2]),		.d(D[2]),	.wen(WriteReg), .clk(clk), .rst(rst));

endmodule