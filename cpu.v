module cpu(clk, rst_n, hlt, pc);
input clk, rst_n; //system clock and active LOW reset, causes execution to start at 0x0000

output hlt; //will be asserted when HLT instruction is encountered
output [15:0] pc; //pc value over program execution 

wire [15:0] instr, //instruction
			read_data1, //to alu
			read_data2, //to alu_mux and to d-mem write data
			alu_result,	//to D-mem and D-mem mux
			read_data,  //data read in D-mem to post D-mem mux
			write_data, //from D-mem mux
			alu_src_data, //from reg to alu mux
			alu_src_data_rs,
			imm_off, //SW, LW, LHB LLB
			pc_branch,
			pc_branch_temp,  
			pc_incr, //store calculated pc increment
			pc_descion;
			
wire [2:0] cond; 	//conditional operation

wire [2:0] flags;	//control flags = 3'b N, V, Z

wire [3:0] src_reg1_check; //for llb and lhb
//signals out designation
//[8] HLT
//[7] PCS
//[6] Jump Register
//[5] Branch
//[4] MemRead
//[3] MemToReg
//[2] MemWrite
//[1] ALUsrc
//[0] RegWrite	
wire [9:0] signals_out;

wire pc_write; //Used for pc halt

//control signals set by control unit			
wire b_l, hlt_sig, pcs, jump_register, branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;

//two instances of Memory for I-mem and D-mem
//Instruction memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
memory1c I_mem(				.data_out(instr),
							.data_in(16'h0000), 
							.addr(pc), 
							.enable(1'b1), 
							.wr(1'b0), 
							.clk(clk), 
							.rst(~rst_n));
							
//control block
//only needs opcode
full_control control(	.instr(instr), 
						.signals_out(signals_out),
						.imm_dec(imm_off));

//register file 
//RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
RegisterFile reg_file(	.clk(clk), 
						.rst(~rst_n), 
						.SrcReg1(src_reg1_check), //rs - src_reg1_check
						.SrcReg2(instr[3:0]), //rt
						.DstReg(instr[11:8]), //rd
						.WriteReg(reg_write), //if the write is enabled 
						.DstData(write_data), // comes from mux after d-mem 
						.SrcData1(read_data1), //rs
						.SrcData2(read_data2));//rt to alu_mux and to write data D-mem
						
//ALU
// module ALU(ALU_Out, Ovfl, ALU_In1, ALU_In2, Opcode, Flags_out);
ALU alu_op(	.ALU_Out(alu_result),  //to D-mem and D-mem mux
			.ALU_In1(alu_src_data_rs),  //rs
			.ALU_In2(alu_src_data),  //rt or sign extended imm
			.Opcode(instr[15:12]), //opcode
			.Flags_out(flags)); //to alu control unit and the and of the branch
			
//branch conditions logic? TODO? includes alu and shift op

//Data memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
memory1c D_mem(	.data_out(read_data), //to post d-mem mux
				.data_in(read_data2), //from reg
				.addr(alu_result), //from alu
				.enable(mem_write | mem_read), //one of the control signals enabled 
				.wr(mem_write), //from control
				.clk(clk), 
				.rst(~rst_n));

				
//PC Control 
//module PC_control(C, I, F, PC_in, PC_out);
PC_control PC_control(	.C(cond), 
				.I(imm_off[8:0]), 
				.F(flags), 
				.PC_in(pc), 
				.PC_out(pc_branch_temp));

//PC reg
//module PCReg(input clk,  input rst, input [15:0] D, input WriteReg, output [15:0] out);
PCReg pc_reg(.clk(clk), .rst(~rst_n), .D(pc_descion), .WriteReg(1'b1), .out(pc));
				
				
//control assignments //
assign pc_incr = pc + 2; //TODO 16 bit adder
assign pc_write = (hlt_sig) ? 1'b0: 1'b1;   
assign pc_branch = (jump_register) ? read_data1: pc_branch_temp;
assign cond = instr[11:9]; 

//D-mem mux
assign write_data = (mem_to_reg) ? read_data :	alu_result;				
//alu src mux
assign alu_src_data_rs = (pcs) ? pc: read_data1;
assign alu_src_data = (alu_src) ? imm_off : read_data2;	//decision between reg val and imm

//reg mux checking for llb lhb
assign src_reg1_check = (b_l) ? instr[11:8] : instr[7:4];

assign pc_descion = (branch) ? pc_branch : pc_incr;

assign b_l = signals_out[9];
assign hlt_sig = signals_out[8]; 
assign pcs = signals_out[7]; 		
assign jump_register = signals_out[6];
assign branch = signals_out[5];
assign mem_read = signals_out[4];
assign mem_to_reg = signals_out[3];
assign mem_write = signals_out[2];
assign alu_src = signals_out[1];
assign reg_write = signals_out[0];

// Program Counter
/*always @(posedge clk or negedge rst_n) begin 
	if (~rst_n) begin
		pc <= 16'h0000;
	end else begin
		if (pc_write) begin
			pc <= (branch ? pc_branch : pc_incr);
		end else begin
			pc <= pc;
			hlt <= 1; 
		end
	end
end*/
endmodule