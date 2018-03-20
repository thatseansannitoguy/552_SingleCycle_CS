module ALU(ALU_Out, ALU_In1, ALU_In2, Opcode, Flags_out);

//Opcode specifications
//all with leading 0
// ADD: 000
// SUB: 001
// RED: 010 TODO
// XOR: 011
// SLL: 100
// SRA: 101
// ROR: 110
// PADDSB: 111

// Inputs and Outputs //
input[15:0] ALU_In1, ALU_In2;
input[3:0] Opcode;


output[15:0] ALU_Out;

output[2:0] Flags_out;


// Internal Wires //
wire[15:0] ADD_out, SUB_out, Shift_out, RED_out, PADDSB_out, LLB_out, LHB_out, LW_SW_out;
wire Ovfl_add, Ovfl_sub; //just to show overflow/saturation

// Param Definitions //
localparam ADD	= 4'b0000;
localparam SUB	= 4'b0001;
localparam RED	= 4'b0010;
localparam XOR 	= 4'b0011;
localparam SLL 	= 4'b0100;
localparam SRA 	= 4'b0101;
localparam ROR 	= 4'b0110;
localparam PADDSB = 4'b0111;
localparam LW 	= 4'b1000;
localparam SW 	= 4'b1001;
localparam LHB 	= 4'b1010;
localparam LLB 	= 4'b1011;
localparam B 	= 4'b1100;
localparam BR 	= 4'b1101;
localparam PCS	= 4'b1110;
localparam HLT 	= 4'b1111;

// Assignments // 
wire dont_care, dont_care2; //overflow outputs we dont care about

CLA_add_16 adder(.Sum(ADD_out), .Ovfl(Ovfl_add), .A(ALU_In1), .B(ALU_In2));
CLA_sub_16 subber(.Sum(SUB_out), .Ovfl(Ovfl_sub), .A(ALU_In1), .B(ALU_In2), .sub(1'b1));

//modifies opcode to fit our shifter within shifter
Shifter shift_ops(.Shift_Out(Shift_out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode_In(Opcode[1:0]));
  
PSA_16bit paddsub_ops(.Sum(PADDSB_out), .Error(dont_care2), .A(ALU_In1), .B(ALU_In2));

assign LLB_out = (ALU_In1 & 16'hFF00) | {8'h00, {ALU_In2[7:0]}};
assign LHB_out = (ALU_In1 & 16'h00FF) | (ALU_In2[7:0] << 8);

CLA_add_16 sw_lw_add(.Sum(LW_SW_out), .Ovfl(dont_care), .A(ALU_In1 & 16'hFFFE), .B(ALU_In2 << 1));

assign ALU_Out =
	((Opcode == ADD) || (Opcode == PCS)) ? ADD_out : 
	(Opcode == SUB) ? SUB_out : 
	(Opcode == RED) ? RED_out : //TODO create RED module
	(Opcode == XOR) ? ALU_In1 ^ ALU_In2:
	(Opcode == SLL) ? Shift_out :
	(Opcode == SRA) ? Shift_out :
	(Opcode == ROR) ? Shift_out :
	(Opcode == PADDSB) ? PADDSB_out : 
	(Opcode == LLB) ? LLB_out :								
	(Opcode == LHB) ? LHB_out :										
	((Opcode == LW) || (Opcode == SW)) ? LW_SW_out :
		16'h0000;

//setting condition flags N(sign bit), V(overflow), Z(zero)
assign Flags_out[2] = (((Opcode != PADDSB) || (Opcode != RED)) && ALU_Out[15] == 1'b1) ? 1'b1 :
					  1'b0;

assign Flags_out[1] = (Opcode == ADD && Ovfl_add) ? 1'b1 :
					  (Opcode == SUB && Ovfl_sub) ? 1'b1 :
					  1'b0;

assign Flags_out[0] = (Opcode == ADD && ALU_Out == 16'h0000) ? 1'b1 :
					  (Opcode == SUB && ALU_Out == 16'h0000) ? 1'b1 :
					  1'b0;
					  		
endmodule
