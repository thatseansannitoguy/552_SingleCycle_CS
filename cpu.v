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
wire[2:0] flags_out, flags_reg_input; 

//wire [2:0] flags;	//control flags = 3'b N, V, Z

wire [3:0] src_reg1_check, src_sw; //for llb and lhb
//signals out designation
//[10] SW mux
//[9] Byte Loads
//[8] HLT
//[7] PCS
//[6] Jump Register
//[5] Branch
//[4] MemRead
//[3] MemToReg
//[2] MemWrite
//[1] ALUsrc
//[0] RegWrite	
wire [11:0] signals_out;

wire pc_write; //Used for pc halt

//control signals set by control unit			
wire flags_update, sw_mux, b_l, hlt_sig, pcs, jump_register, branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;


//**Registers**//

//Control Pipeline Registers// TODO
reg [5:0] Ctrl_Id_Ex;
reg [4:0] Ctrl_Ex_Mem;
reg [2:0] Ctrl_Mem_Wb;

// Accessory Pipeline Registers TODO
reg [15:0] Imm_Id_Ex;
reg [3:0]  Reg_Id_Ex [2:0];
reg [3:0]  Reg_Ex_Mem_Rd, 
	   Reg_Mem_Wb_Rd,
	   OPCODE_Id_Ex;
//TODO
reg [2:0] flags; //control flags = 3'b N, V, Z


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
						.SrcReg1(src_reg1_check), //rs - src_reg1_check instr[7:4]
						.SrcReg2(src_sw), //rt 
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
			.Flags_out(flags_out)); //to alu control unit and the and of the branch
			

//Data memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
memory1c D_mem(	.data_out(read_data), //to post d-mem mux
				.data_in(read_data2), //from reg read_data2
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

//PC reg
//module PCReg(input clk,  input rst, input [15:0] D, input WriteReg, output [15:0] out);
FlagsReg flags_reg(.clk(clk), .rst(~rst_n), .D(flags_reg_input), .WriteReg(1'b1), .out(flags));
				
				
//control assignments //
assign pc_incr = pc + 2; 
assign pc_write = (hlt_sig) ? 1'b0: 1'b1;   
assign pc_branch = (jump_register) ? read_data1: pc_branch_temp;
assign cond = instr[11:9]; 

//D-mem mux
assign write_data = (mem_to_reg) ? read_data :	alu_result;				
//alu src mux
assign alu_src_data_rs = (pcs) ? pc : read_data1;
assign alu_src_data = (alu_src) ? imm_off : read_data2;	//decision between reg val and imm

//reg mux checking for llb lhb
assign src_reg1_check = ((b_l) ? {instr[11:8]} : {instr[7:4]});

assign flags_reg_input = (flags_update) ? flags_out : flags;

assign pc_descion = (branch) ? pc_branch : pc_incr;

assign src_sw = (sw_mux) ? instr[11:8] : instr[3:0];

assign hlt = (pc_write) ? 1'b0 : 1'b1;

assign flags_update = signals_out[11]; 
assign sw_mux = signals_out[10];
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

// HAZARD DETECTION UNIT //TODO
HDU hdu(
	.opcode(IF_ID_Opcode),
	.if_id_rs(IF_ID_Rs), 
	.if_id_rt(IF_ID_Rt), 
	.id_ex_rt(REG_ID_EX[ID_EX_Rd]), 
	.id_ex_mr(CTRL_ID_EX[MemRead]),

	.pc_write(pc_write), 
	.if_id_write(if_id_write), 
	.stall(stall)
);

// FORWARDING UNIT //TODO
FU forward_unit(
	.id_ex_rt(REG_ID_EX[ID_EX_Rt]), 
	.id_ex_rs(REG_ID_EX[ID_EX_Rs]), 
	.ex_mem_rd(REG_EX_MEM_Rd), 
	.mem_wb_rd(REG_MEM_WB_Rd), 
	.ex_mem_rw(CTRL_EX_MEM[RegWrite]), 
	.mem_wb_rw(CTRL_MEM_WB[RegWrite]), 

	.forwarda(forwardA), 
	.forwardb(forwardB)
);

// FORWARDING FOR ALU OP 1 //TODO
assign op_1 = (forwardA == SRC_ID_EX)  ? DATA_ID_EX[ID_EX_OP1] :
	      (forwardA == SRC_EX_MEM) ? DATA_EX_MEM[EX_MEM_RSLT] :
	      (forwardA == SRC_MEM_WB) ? write_data : DATA_ID_EX[ID_EX_OP1];

// FORWARDING FOR ALU OP 2 //TODO
assign op_2 = (forwardB == SRC_ID_EX)  ? DATA_ID_EX_OP2 : 
	      (forwardB == SRC_EX_MEM) ? DATA_EX_MEM[EX_MEM_RSLT] :
	      (forwardB == SRC_MEM_WB) ? write_data : DATA_ID_EX_OP2;


//** CONTROL PIPELINE **// //TODO
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		Ctrl_Id_Ex  <= 6'b000000;
		Ctrl_Ex_Mem <= 5'b00000;
		Ctrl_Mem_Wb <= 3'b000;

		hlt	    <= 1'b0;
	end else if (mem_ready) begin
		CTRL_ID_EX  <= (stall & ~ctrl_signals[Halt]) ? 6'b00000 : ctrl_signals[Jal:Halt];
		CTRL_EX_MEM <= CTRL_ID_EX[MemRead:Halt];
		CTRL_MEM_WB <= CTRL_EX_MEM[MemToReg:Halt];

		hlt 	    <= CTRL_EX_MEM[Halt];
	end else begin
		CTRL_ID_EX  <= CTRL_ID_EX;
		CTRL_EX_MEM <= CTRL_EX_MEM;
		CTRL_MEM_WB <= CTRL_MEM_WB;

		hlt 	    <= hlt;
	end
end

//** DATA PIPELINE **// //TODO
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		DATA_IF_ID[0] <= 16'h0000;
		DATA_IF_ID[1] <= 16'h0000;

		DATA_ID_EX[0] <= 16'h0000;
		DATA_ID_EX[1] <= 16'h0000;
		DATA_ID_EX[2] <= 16'b0000;
		REG_ID_EX[0]  <= 4'h0;
		REG_ID_EX[1]  <= 4'h0;
		REG_ID_EX[2]  <= 4'h0;
		OPCODE_ID_EX  <= 4'h0;
		IMM_ID_EX     <= 16'h0000;

		DATA_EX_MEM[0] <= 16'h0000;
		DATA_EX_MEM[1] <= 16'h0000;
		REG_EX_MEM_Rd  <= 4'h0;
		FLAG           <= 3'b000;

		DATA_MEM_WB[0] <= 16'h0000;
		DATA_MEM_WB[1] <= 16'h0000;
		REG_MEM_WB_Rd  <= 4'h0;
	end else if (mem_ready) begin
		if (branch) begin
			DATA_IF_ID[IF_ID_PC]   <= pc_incr;
			DATA_IF_ID[IF_ID_INST] <= 16'h0000;
		end else if (if_id_write) begin
			DATA_IF_ID[IF_ID_PC]   <= pc_incr;
			DATA_IF_ID[IF_ID_INST] <= instr;
		end else begin
			DATA_IF_ID[IF_ID_PC]   <= DATA_IF_ID[IF_ID_PC];
			DATA_IF_ID[IF_ID_INST] <= DATA_IF_ID[IF_ID_INST];
		end

		DATA_ID_EX[ID_EX_OP1]    <= read_1;
		DATA_ID_EX[ID_EX_OP2]    <= read_2;
		DATA_ID_EX[ID_EX_PC]     <= DATA_IF_ID[IF_ID_PC];
		REG_ID_EX[ID_EX_Rd]	 <= IF_ID_Rd;
		REG_ID_EX[ID_EX_Rs]	 <= IF_ID_Rs;
		REG_ID_EX[ID_EX_Rt]	 <= IF_ID_Rt;
		OPCODE_ID_EX		 <= IF_ID_Opcode;
		IMM_ID_EX		 <= IF_ID_Imm;

		DATA_EX_MEM[EX_MEM_RSLT] <= result;
		DATA_EX_MEM[EX_MEM_OP2]  <= op_2;
		REG_EX_MEM_Rd		 <= REG_ID_EX[ID_EX_Rd];
		FLAG                     <= flags;

		DATA_MEM_WB[MEM_WB_RD]   <= dm_read;
		DATA_MEM_WB[MEM_WB_RSLT] <= DATA_EX_MEM[EX_MEM_RSLT];
		REG_MEM_WB_Rd		 <= REG_EX_MEM_Rd;
	end else begin
		DATA_IF_ID[IF_ID_PC]   <= DATA_IF_ID[IF_ID_PC];
		DATA_IF_ID[IF_ID_INST] <= DATA_IF_ID[IF_ID_INST];

		DATA_ID_EX[ID_EX_OP1]    <= DATA_ID_EX[ID_EX_OP1];
		DATA_ID_EX[ID_EX_OP2]    <= DATA_ID_EX[ID_EX_OP2];
		DATA_ID_EX[ID_EX_PC]     <= DATA_ID_EX[ID_EX_PC];
		REG_ID_EX[ID_EX_Rs]	 <= REG_ID_EX[ID_EX_Rs];
		REG_ID_EX[ID_EX_Rt]	 <= REG_ID_EX[ID_EX_Rt];
		OPCODE_ID_EX		 <= OPCODE_ID_EX;
		IMM_ID_EX		 <= IMM_ID_EX;

		DATA_EX_MEM[EX_MEM_RSLT] <= DATA_EX_MEM[EX_MEM_RSLT];
		DATA_EX_MEM[EX_MEM_OP2]  <= DATA_EX_MEM[EX_MEM_OP2];
		REG_EX_MEM_Rd		 <= REG_EX_MEM_Rd;
		FLAG                     <= FLAG;

		DATA_MEM_WB[MEM_WB_RD]   <= DATA_MEM_WB[MEM_WB_RD];
		DATA_MEM_WB[MEM_WB_RSLT] <= DATA_MEM_WB[MEM_WB_RSLT];
		REG_MEM_WB_Rd		 <= REG_MEM_WB_Rd;
	end
end


endmodule