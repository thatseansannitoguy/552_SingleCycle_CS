//TOP LEVEL CPU MODULE ECE552
module cpu(clk, rst_n, hlt, pc);

//**Module I/O**//

//Inputs
input clk, rst_n; //system clock and active LOW reset, causes execution to start at 0x0000

//Outputs
output hlt; //will be asserted when HLT instruction is encountered
output [15:0] pc; //pc value over program execution 

//**Global Variables**//

//Flag Indexes
localparam Z = 0;	//Zero 
localparam V = 1; 	//Overflow 
localparam Z = 2;	//Zero 

//Control Signal Names
localparam Halt 			= 8;
localparam PCS 				= 7;
localparam BranchRegister 	= 6;
localparam Branch 			= 5;
localparam MemRead 			= 4;
localparam MemToReg 		= 3;
localparam MemWrite  		= 2;
localparam ALUSrc 			= 1;
localparam RegWrite 		= 0;

//Data Pipeline Indexes
localparam IF_ID_PC = 0;			//PC  
localparam IF_ID_INST = 1;			//Instruction 

localparam ID_EX_OP1 = 0;			//OP #1 
localparam ID_EX_OP2 = 1;			//OP #2  
localparam ID_EX_PC = 2;			//PC

localparam EX_MEM_RESULT = 0;		//Alu Result
localparam EX_MEM_OP2 = 1; 			//OP #2

localparam MEM_WB_DATA = 0; 		//Retrieved Data from Mem
localparam MEM_WB_RESULT = 1;		//Write Back Result

//Control Pipeline Indexes
// [0] = Halt, [1] = RegWrite, [2] = MemToReg, [3] = MemWrite , [4] = MemRead, [5] = PCS
localparam CONTROL_HALT = 0; 
localparam CONTROL_REG_WRITE = 1; 
localparam CONTROL_MEM_TO_REG = 2; 
localparam CONTROL_MEM_WRITE = 3; 
localparam CONTROL_MEM_READ = 4; 
localparam CONTROL_PCS = 5; 

//Other Globals
localparam ID_EX_Rd    = 0;			//Rd Index
localparam ID_EX_Rs    = 1;			//Rs Index
localparam ID_EX_Rt    = 2;			//Rt Index

//TODO
//localparam SRC_ID_EX  = 2'b00;
//localparam SRC_EX_MEM = 2'b10;
//localparam SRC_MEM_WB = 2'b01;

//**Registers**//

//Data Pipeline Registers
reg [15:0] DATA_IF_ID [1:0]; 	// [0] = PC, [1] = Instruction
reg [15:0] DATA_ID_EX [2:0]; 	// [0] = Op1, [1] = Op2, [2] = PC
reg [15:0] DATA_EX_MEM [1:0]; 	// [0] = ALU_Result, [1] = Op2_Src 
reg [15:0] DATA_MEM_WB [1:0]; 	// [0] = Mem_Data_Read, [1] = ALU_Result

//Control Pipeline Registers//
reg [5:0] CTRL_ID_EX; 	// [0] = Halt, [1] = RegWrite, [2] = MemToReg, [3] = MemWrite , [4] = MemRead, [5] = JumpRegister //TODO
reg [4:0] CTRL_EX_MEM; 	// [0] = Halt, [1] = RegWrite, [2] = MemToReg, [3] = MemWrite , [4] = MemRead
reg [2:0] CTRL_MEM_WB; 	// [0] = Halt, [1] = RegWrite, [2] = MemToReg

//Extra Pipeline Registers
reg [15:0] IMM_ID_EX;		//Stores Immediate
reg [3:0]  REG_ID_EX [2:0];	//Stores Rd[0], Rs[1], Rt[2] 
reg [3:0]  REG_EX_MEM_Rd, 	//Stores Dst Reg
	REG_MEM_WB_Rd, 			//Stores Dst Reg
	OPCODE_ID_EX;			//Stores Opcode
reg [2:0]  FLAGS;			//Stores Flags Set in ALU

//**Wires**//

//Internal Wires
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
			pc_descion,
			IF_ID_Imm;

wire [11:0] signals_out; 	//Signal control wires	
wire [2:0]  flags_out;		//control flags = 3'b N, V, Z

wire [3:0] IF_ID_Rd, 		//To hold initial decode values
	   IF_ID_Rs,
	   IF_ID_Rt,
	   IF_ID_Opcode;					
wire [2:0] IF_ID_Cond; 		//conditional operation

wire if_id_write;			//Hazard Unit Driven, tells when to pull instruction enable
wire stall; 				//Hazard Unit Driven, tells when to stall with NOPs
wire pc_write; 				//Hazard Unit Driven, tells when to write/ not write to pc
wire branch; 				//Branch unit driven, tells when a branch is taken or not

//TODO
//wire [1:0] read_signals, forwardA, forwardB;
//wire pc_write, if_id_write, stall, mem_ready, branch, jal, jr_forward;

//** MODULES ** //

//Instruction memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
memory1c I_mem(				
							.data_out(instr),
							.data_in(16'h0000), 
							.addr(pc), 
							.enable(if_id_write), 
							.wr(1'b0), 
							.clk(clk), 
							.rst(~rst_n));
					
//Data memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
memory1c D_mem(	
				.data_out(DATA_MEM_WB[MEM_WB_DATA]), //to post d-mem mux
				.data_in(DATA_EX_MEM[EX_MEM_OP2]), //from reg read_data2
				.addr(DATA_EX_MEM[EX_MEM_RESULT]), //from alu
				.enable(CTRL_EX_MEM[CONTROL_MEM_WRITE] | CTRL_EX_MEM[CONTROL_MEM_READ]), //one of the control signals enabled 
				.wr(CTRL_EX_MEM[CONTROL_MEM_WRITE]), //from control
				.clk(clk), 
				.rst(~rst_n));

//Register file 
//RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
RegisterFile reg_file(	
						.clk(clk), 
						.rst(~rst_n), 
						.SrcReg1(IF_ID_Rs), //rs 
						.SrcReg2(IF_ID_Rt), //rt 
						.DstReg(REG_MEM_WB_Rd), //rd from Mem Wb Pipeline Register
						.WriteReg(CTRL_MEM_WB[CONTROL_REG_WRITE]), //if the write is enabled 
						.DstData(write_data), // comes from mux after d-mem 
						.SrcData1(read_data1),  //rs
						.SrcData2(read_data2)); //rt to alu_mux and to write data D-mem

//Control Block
//full_control(instr, signals_out, imm_dec, rd, rs, rt, cond, opcode);
full_control control(	
						.instr(DATA_IF_ID[IF_ID_INST]), 
						.signals_out(signals_out),
						.imm_dec(IF_ID_Imm),
						.rd(IF_ID_Rd),
						.rs(IF_ID_Rs),
						.rt(IF_ID_Rt), 
						.cond(IF_ID_Cond),
						.opcode(IF_ID_Opcode));
						
//ALU
//ALU(ALU_Out, ALU_In1, ALU_In2, Opcode, Flags_out);
ALU alu_op(	
			.ALU_Out(alu_result),  //to D-mem and D-mem mux
			.ALU_In1(op_1),  //rs 	
			.ALU_In2(op_2),  //rt
			.imm(IMM_ID_EX), //signed imm			
			.Opcode(OPCODE_ID_EX), //opcode
			.Flags_out(flags_out)); //to alu control unit and the and of the branch	

//Forwarding Unit
//forward_unit(id_ex_rt, id_ex_rs, ex_mem_rd, mem_wb_rd, ex_mem_rw, mem_wb_rw, forwarda, forwardb);
FwardUnit forward_unit(
	.id_ex_rt(REG_ID_EX[ID_EX_Rt]), 
	.id_ex_rs(REG_ID_EX[ID_EX_Rs]), 
	.ex_mem_rd(REG_EX_MEM_Rd), 
	.mem_wb_rd(REG_MEM_WB_Rd), 
	.ex_mem_rw(CTRL_EX_MEM[CONTROL_REG_WRITE]), 
	.mem_wb_rw(CTRL_MEM_WB[CONTROL_REG_WRITE]), 

	.forwarda(forwardA), 
	.forwardb(forwardB)
);
			
//Hazard Detection Unit
//HDU(opcode, if_id_rs, if_id_rt, id_ex_rt, id_ex_mr, pc_write, if_id_write, stall);
HDU hdu(
	.opcode(IF_ID_Opcode),
	.if_id_rs(IF_ID_Rs), 
	.if_id_rt(IF_ID_Rt), 
	.id_ex_rt(REG_ID_EX[ID_EX_Rd]), 
	
	.id_ex_mr(CTRL_ID_EX[CONTROL_MEM_READ]),

	.pc_write(pc_write), 
	.if_id_write(if_id_write), 
	.stall(stall)
);			
						
//Branch Control 
//br_control(cond, flags, br_control, clk, branch);
br_control br_controller(
				.cond(IF_ID_Cond), 
				.flags(flag_out), 
				.br_control(signals_out[Branch]), 
				.clk(clk), 
				.branch(branch));						
						
//**Continuous Assignment**//						

assign pc_incr = pc + 2;	// PC Increment
assign pc_branch = signals_out[BranchRegister] ?  br_branch : DATA_IF_ID[IF_ID_PC] + IF_ID_Imm; 
assign br_branch = read1;  //TODO

//Assign the data to be written back (Memory or AluResult)
assign write_data = CTRL_MEM_WB[CONTROL_MEM_TO_REG] ? DATA_MEM_WB[MEM_WB_RD] :	DATA_MEM_WB[MEM_WB_RESULT];	

//Forwarding ALU Op1
assign op_1 = (forwardA == SRC_ID_EX)  ? DATA_ID_EX[ID_EX_OP1] :
	      (forwardA == SRC_EX_MEM) ? DATA_EX_MEM[EX_MEM_RSLT] :
	      (forwardA == SRC_MEM_WB) ? write_data : DATA_ID_EX[ID_EX_OP1];

//Forwarding ALU Op2
assign op_2 = (forwardB == SRC_ID_EX)  ? DATA_ID_EX_OP2 : 
	      (forwardB == SRC_EX_MEM) ? DATA_EX_MEM[EX_MEM_RSLT] :
	      (forwardB == SRC_MEM_WB) ? write_data : DATA_ID_EX_OP2;

assign alu_src_data_rs = pcs ? DATA_ID_EX[ID_EX_PC] : read_data1;
		
//**Program Counter**//
always @(posedge clk or negedge rst_n) begin 
	if (~rst_n) begin
		pc <= 16'h0000;
	end else if (pc_write & mem_ready) begin
		pc <= (branch ? pc_branch : pc_incr);
	end else begin
		pc <= pc;
	end
end		  
		  		  
//**Control Pipeline**// 
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

//**Data Pipeline**//
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