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


input[15:0] ALU_In1, ALU_In2;
input[2:0] Opcode;

output[15:0] ALU_Out;

output[2:0] Flags_out;

wire[15:0] CLA_out, Shift_out, RED_out, PADDSB_out;
wire Ovfl; //just to show overflow/saturation

parameter ADD = 3'b000;
parameter SUB = 3'b001;
parameter RED = 3'b010;
parameter XOR = 3'b011;
parameter SLL = 3'b100;
parameter SRA = 3'b101;
parameter ROR = 3'b110;
parameter PADDSB = 3'b111;


CLA_addsub_16 add_sub(.Sum(CLA_out), .Ovfl(Ovfl), .A(ALU_In1), .B(ALU_In2), .sub(Opcode[0]));

//modifies opcode to fit our shifter within shifter
Shifter shift_ops(.Shift_Out(Shift_out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2), .Mode(Opcode[1:0]));
  
PSA_16bit paddsub_ops(.Sum(PADDSB_out), .Error(Ovfl), .A(ALU_In1), .B(ALU_In2));
  
assign ALU_Out =
	(Opcode == ADD) ? CLA_out : 
	(Opcode == SUB) ? CLA_out : 
	(Opcode == RED) ? RED_out : //TODO create RED module
	(Opcode == XOR) ? ALU_In1 ^ ALU_In2:
	(Opcode == SLL) ? Shift_out :
	(Opcode == SRA) ? Shift_out :
	(Opcode == ROR) ? Shift_out :
	(Opcode == PADDSB) ? PADDSB_out : 
		16'h0000;

//setting condition flags N(sign bit), V(overflow), Z(zero)
assign Flags_out[2] = (((Opcode != PADDSB) || (Opcode != RED)) && ALU_Out[15] == 1'b1) ? 1'b1 :
					  1'b0;

assign Flags_out[1] = (Opcode == ADD && Sum) ? 1'b1 :
					  (Opcode == SUB && Ovfl) ? 1'b1 :
					  1'b0;

assign Flags_out[0] = (Opcode == ADD && ALU_Out == 16'h0000) ? 1'b1 :
					  (Opcode == SUB && ALU_Out == 16'h0000) ? 1'b1 :
					  1'b0;
					  		
endmodule
