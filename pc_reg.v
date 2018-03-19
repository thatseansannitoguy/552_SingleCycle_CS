module PCReg(input clk,  input rst, input [15:0] D, input WriteReg, output [15:0] out);

dff ff0(.q(out[0]),		.d(D[0]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff1(.q(out[1]),		.d(D[1]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff2(.q(out[2]),		.d(D[2]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff3(.q(out[3]),		.d(D[3]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff4(.q(out[4]),		.d(D[4]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff5(.q(out[5]),		.d(D[5]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff6(.q(out[6]),		.d(D[6]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff7(.q(out[7]),		.d(D[7]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff8(.q(out[8]),		.d(D[8]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff9(.q(out[9]),		.d(D[9]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff10(.q(out[10]),	.d(D[10]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff11(.q(out[11]),	.d(D[11]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff12(.q(out[12]),	.d(D[12]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff13(.q(out[13]),	.d(D[13]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff14(.q(out[14]),	.d(D[14]),	.wen(WriteReg), .clk(clk), .rst(rst));
dff ff15(.q(out[15]),	.d(D[15]),	.wen(WriteReg), .clk(clk), .rst(rst));

endmodule
