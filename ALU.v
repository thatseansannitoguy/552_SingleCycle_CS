module ALU(ALU_Out, Error, ALU_In1, ALU_In2, Opcode);

input[3:0] ALU_In1, ALU_In2;
input[1:0] Opcode;

output[3:0] ALU_Out;
output Error; //just to show overflow

parameter ADD = 2'b00;
parameter SUB = 2'b01;
parameter NAND = 2'b10;
parameter XOR = 2'b11;

wire[3:0] temp_ALU;
addsub_4bit add_sub(.Sum(temp_ALU), .Ovfl(Error), .A(ALU_In1), .B(ALU_In2), .sub(Opcode[0]));


assign ALU_Out =
	(Opcode == ADD) ? temp_ALU :
	(Opcode == SUB) ? temp_ALU :
	(Opcode == NAND) ? (~ALU_In1 | ~ALU_In2) :
	(Opcode == XOR) ? ALU_In1 ^ ALU_In2:
		4'b0;

endmodule
