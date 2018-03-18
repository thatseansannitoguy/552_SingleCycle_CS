module full_control(Opcode, signals_out, alu_op);
input [3:0] Opcode;

output [6:0] signals_out;
output [2:0] alu_op;

//ALU Opcode specifications
// all with leading 0
// ADD: 000
// SUB: 001
// RED: 010 TODO
// XOR: 011
// SLL: 100
// SRA: 101
// ROR: 110
// PADDSB: 111

//signals out designation
//[6] Jump
//[5] Branch
//[4] MemRead
//[3] MemToReg
//[2] MemWrite
//[1] ALUsrc
//[0] RegWrite

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

assign signals_out[6] = (	(Opcode == BR) || 
							(Opcode == B)) ? 1'b1 : 1'b0; //Jump
//TODO not sure about BR and B
assign signals_out[5] = (	(Opcode == BR) || 
							(Opcode == B)) ? 1'b1 : 1'b0; //Branch
							
assign signals_out[4] = (   (Opcode == LW) ) ? 1'b1 : 1'b0; //MemRead

assign signals_out[3] = (   (Opcode == LW) ) ? 1'b1 : 1'b0; //MemToReg

assign signals_out[2] = (   (Opcode == SW) ) ? 1'b1 : 1'b0; //MemWrite

assign signals_out[1] = (   (Opcode == SLL) ||
							(Opcode == ROR)	||	
							(Opcode == SRA)	||
							(Opcode == LW ) ||
							(Opcode == SW ) ||
							(Opcode == LHB) ||
							(Opcode == LLB) ||
							(Opcode == BR )) ? 1'b1 : 1'b0; //ALUsrc
							
assign signals_out[0] = (   (Opcode == B  ) ||
							(Opcode == BR ) ||
							(Opcode == HLT)) ? 1'b0 : 1'b1; //RegWrite
							
assign alu_op = ((Opcode = ADD) ||
				 (Opcode = SW ) ||
				 (Opcode = LW)  ||) ? ADD[2:0] :
				alu_op[2:0];

				
endmodule