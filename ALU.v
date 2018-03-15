module ALU(ALU_Out, Error, ALU_In1, ALU_In2, Opcode);

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
output Error; //just to show overflow

wire[15:0] CLA_out, Shift_out, RED_out, PADDSB_out;

parameter ADD = 3'b000;
parameter SUB = 3'b001;
parameter RED = 3'b010;
parameter XOR = 3'b011;
parameter SLL = 3'b100;
parameter SRA = 3'b101;
parameter ROR = 3'b110;
parameter PADDSB = 3'b111;


CLA_addsub_16 add_sub(.Sum(CLA_out), .Ovfl(Error), .A(ALU_In1), .B(ALU_In2), .sub(Opcode[0]));

//modifies opcode to fit our shifter within shifter
Shifter shift_ops(.Shift_Out(Shift_out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2), .Mode(Opcode[1:0]));
  
PSA_16bit paddsub_ops(.Sum(PADDSB_out), .Error(Error), .A(ALU_In1), .B(ALU_In2));
  
assign ALU_Out =
	(Opcode == ADD) ? CLA_out : //TODO saturation implemented correctly in 16bit add_sub
	(Opcode == SUB) ? CLA_out : //TODO saturation implemented correctly in 16bit add_sub
	(Opcode == RED) ? RED_out : //TODO create RED module
	(Opcode == XOR) ? ALU_In1 ^ ALU_In2:
	(Opcode == SLL) ? Shift_out :
	(Opcode == SRA) ? Shift_out :
	(Opcode == ROR) ? Shift_out :
	(Opcode == PADDSB) ? PADDSB_out : //TODO 4 bit saturation for addsub 4 bit 
		16'h0000;

//TODO setting condition flags N(sign bit), V(overflow), Z(zero)
		
endmodule
