module PC_control(C, I, F, PC_in, PC_out);

input [2:0] C, F; //control, flags = 3'b N, V, Z
input [8:0] I; //immediate 
input [15:0] PC_in;

output [15:0] PC_out;

wire ovfl_0, ovfl_1; 
wire [8:0] I_shift;
wire [15:0] branch_take, normal_pc, I_input;

assign I_shift = I << 1;

assign I_input = (I_shift[8]==1'b0) ? {7'b0000000, I_shift} :
				 (I_shift[8]==1'b1)	? {7'b1111111, I_shift} :
				 16'h0000;

// CLA_addsub_16(Sum, Ovfl, A, B, sub);
CLA_addsub_16 INC_PC(.Sum(normal_pc), .Ovfl(ovfl_0), .A(PC_in), .B(16'h0002), .sub(1'b0));
CLA_addsub_16  BRANCH_PC(.Sum(branch_take), .Ovfl(ovfl_1), .A(normal_pc), .B(I_input), .sub(1'b0));

assign PC_out = (C==3'b000 && F[0]==1'b0) ? branch_take : 
				(C==3'b001 && F[0]==1'b1) ? branch_take : 
				(C==3'b010 && F[0]==1'b0 && F[2]==1'b0) ? branch_take : 
				(C==3'b011 && F[2]==1'b1) ? branch_take :
				(C==3'b100 && (F[0]==1'b1 || (F[0]==1'b0 && F[2]==1'b0))) ? branch_take :
				(C==3'b101 && (F[0]==1'b1 || F[2]==1'b1)) ? branch_take : 
				(C==3'b110 && F[1]==1'b1) ? branch_take :
				(C==3'b111) ? branch_take :
				normal_pc;

endmodule