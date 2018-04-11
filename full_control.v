module full_control(instr, signals_out, imm_dec, rd, rs, rt, opcode, cond);

input [15:0] instr;

//all control signals and conditions and read signals
output reg [11:0] signals_out;

//register addr, cond, and opcode present based off instruction
output reg [3:0] rd, rs, rt, opcode;
output reg [2:0] cond; 

//immediate conditionally assinged based on instruction
output reg [15:0] imm_dec;

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
//[8] HLT
//[7] PCS
//[6] BranchRegister
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

localparam ON = 1'b1;
localparam OFF = 1'b0;

localparam NO_SET_SIGNALS = 9'b000000000;
localparam NO_SET_IMM = 16'h0000;
localparam NO_SET_REG = 4'h0;

wire [8:0] I, I_shift; 


//begining of case assignment based on opcode
always@(*) begin
		opcode = instr(15:12]; //opcode assignment
		cond = instr[11:9]; //condition assignment
		case (opcode)
				ADD: begin
						if(instr != 16'h0000) begin	
								signals_out[0] = ON;  //RegWrite		
								signals_out[1] = OFF; //ALUsrc
								signals_out[2] = OFF; //MemWrite
								signals_out[3] = OFF; //MemToReg
								signals_out[4] = OFF; //MemRead
								signals_out[5] = OFF; //Branch 
								signals_out[6] = OFF; //BranchRegister
								signals_out[7] = OFF; //PCS cond
								signals_out[8] = OFF; //Halt
								
						end else begin
								signals_out = NO_SET_SIGNALS;
						end
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = instr[3:0];
							
							imm_dec = NO_SET_IMM;
					end
				SUB: begin	
							signals_out[0] = ON;  //RegWrite		
							signals_out[1] = OFF; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = instr[3:0];
							
							imm_dec = NO_SET_IMM;
					end
				RED: begin
						//TODO
						signals_out = NO_SET_SIGNALS;
				
					end
				XOR: begin 
							signals_out[0] = ON;  //RegWrite		
							signals_out[1] = OFF; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = instr[3:0];
							
							imm_dec = NO_SET_IMM;
					end
				SLL: begin	
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = NO_SET_REG;
							
							imm_dec = {12'h000, instr[3:0]};
					end
				SRA: begin 
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = NO_SET_REG;
							
							imm_dec = {12'h000, instr[3:0]};
					end
				ROR: begin
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = NO_SET_REG;
							
							imm_dec = {12'h000, instr[3:0]};
					end
				PADDSB: begin 
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = OFF; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = instr[3:0];
							
							imm_dec = NO_SET_IMM;
					end
				LW: begin
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = ON; //MemToReg
							signals_out[4] = ON; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[7:4];
							rt = NO_SET_REG;
							
							imm_dec = {{12{instr[3]}}, instr[3:0]}; //signed offset
					end
				SW: begin
							signals_out[0] = OFF; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = ON; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = NO_SET_REG;
							rs = instr[7:4];
							rt = instr[11:8];
							
							imm_dec = {{12{instr[3]}}, instr[3:0]}; //signed offset
					end
				LHB: begin
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = instr[11:8];
							rt = NO_SET_REG;
							
							imm_dec = {8'h00, instr[7:0]};
					end
				LLB: begin
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = NO_SET_REG;
							rt = NO_SET_REG;
							
							imm_dec = {8'h00, instr[7:0]};
							
					end
				B: begin
							signals_out[0] = OFF; //RegWrite		
							signals_out[1] = OFF; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = ON; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = NO_SET_REG;
							rs = NO_SET_REG;
							rt = NO_SET_REG;
							
							I = instr[8:0]; 
							I_shift = I << 1;
							
							imm_dec = {{7{I_shift[8]}}, I_shift[8:0]}; //signed offset
				
					end
					BR: begin 
							signals_out[0] = OFF; //RegWrite		
							signals_out[1] = OFF; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = ON; //Branch 
							signals_out[6] = ON; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = NO_SET_REG;
							rs = instr[7:4];
							rt = NO_SET_REG;
							
							imm_dec = NO_SET_IMM; //signed offset
				
					end
					PCS: begin
							signals_out[0] = ON; //RegWrite		
							signals_out[1] = ON; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = ON; //PCS cond
							signals_out[8] = OFF; //Halt
							
							rd = instr[11:8];
							rs = NO_SET_REG;
							rt = NO_SET_REG;
							
							imm_dec = NO_SET_IMM;
					
					end
					HALT: begin
							signals_out[0] = OFF; //RegWrite		
							signals_out[1] = OFF; //ALUsrc
							signals_out[2] = OFF; //MemWrite
							signals_out[3] = OFF; //MemToReg
							signals_out[4] = OFF; //MemRead
							signals_out[5] = OFF; //Branch 
							signals_out[6] = OFF; //BranchRegister
							signals_out[7] = OFF; //PCS cond
							signals_out[8] = ON; //Halt
							
							rd = NO_SET_REG;
							rs = NO_SET_REG;
							rt = NO_SET_REG;
							
							imm_dec = NO_SET_IMM;
					end
					default: begin
							signals_out = NO_SET_SIGNALS;
							
							rd = NO_SET_REG;
							rs = NO_SET_REG;
							rt = NO_SET_REG;
							
							imm_dec = NO_SET_IMM;
							
					end
			endcase
	end
			
/*	OLD IMPLEMENTATION		
assign signals_out[11] = ((Opcode == ADD) ||
				(Opcode == SUB) ||
				(Opcode == XOR)	||	
				(Opcode == SLL)	||
				(Opcode == SRA) ||
				(Opcode == ROR)) ? 1'b1 : 1'b0;

assign signals_out[10] =    ((Opcode == SW)) ? 1'b1 : 1'b0; 

assign signals_out[9] = 	((Opcode == LHB) || (Opcode == LLB)) ? 1'b1 : 1'b0; //unique case for rd = rs

assign signals_out[8] = 	(Opcode == HLT) ? 1'b1 : 1'b0; //HLT

assign signals_out[7] = 	(Opcode == PCS) ? 1'b1 : 1'b0; //PCS

assign signals_out[6] = (	(Opcode == BR) ) ? 1'b1 : 1'b0; //Jump Register

assign signals_out[5] = (	(Opcode == BR) || 
				(Opcode == B)) ? 1'b1 : 1'b0; //Branch						

assign signals_out[4] = (   	(Opcode == LW) ) ? 1'b1 : 1'b0; //MemRead

assign signals_out[3] = (   	(Opcode == LW) ) ? 1'b1 : 1'b0; //MemToReg

assign signals_out[2] = (   	(Opcode == SW) ) ? 1'b1 : 1'b0; //MemWrite

assign signals_out[1] = (   	(Opcode == PCS) ||
				(Opcode == SLL) ||
				(Opcode == ROR)	||	
				(Opcode == SRA)	||
				(Opcode == LW ) ||
				(Opcode == SW ) ||
				(Opcode == LHB) ||
				(Opcode == LLB)) ? 1'b1 : 1'b0; //ALUsrc
							
assign signals_out[0] = (   	(Opcode == B  ) ||
				(Opcode == BR ) ||
				(Opcode == HLT) ||
				(Opcode == SW)) ? 1'b0 : 1'b1; //RegWrite
							
assign imm_dec = ( 		(Opcode == LLB)	|| (Opcode == LHB) ) ? 
					{{8{instr[7]}}, instr[7:0]} :
				(Opcode == PCS) ? 16'h0002 :
				 	{{12{instr[3]}}, instr[3:0]}; //ROR, SLL, SRA, LW, SW
*/
			
endmodule