//TOP LEVEL CPU MODULE ECE552
module cpu(clk, rst_n, hlt, pc);

//**Module I/O**//

//Inputs
input clk, rst_n; //system clock and active LOW reset, causes execution to start at 0x0000

//Outputs
output reg hlt; //will be asserted when HLT instruction is encountered
output reg [15:0] pc; //pc value over program execution 

//**Global Variables**//

//Flag Indexes
localparam N = 0;	//Negative 
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
localparam SRC_ID_EX  = 2'b00;
localparam SRC_EX_MEM = 2'b10;
localparam SRC_MEM_WB = 2'b01;

//**Registers**//

//Data Pipeline Registers
reg [15:0] DATA_IF_ID [1:0]; 	// [0] = PC, [1] = Instruction
reg [15:0] DATA_ID_EX [2:0]; 	// [0] = Op1, [1] = Op2, [2] = PC
reg [15:0] DATA_EX_MEM [1:0]; 	// [0] = ALU_Result, [1] = Op2_Src 
reg [15:0] DATA_MEM_WB [1:0]; 	// [0] = Mem_Data_Read, [1] = ALU_Result

//Control Pipeline Registers//
reg [5:0] CTRL_ID_EX; 	// [0] = Halt, [1] = RegWrite, [2] = MemToReg, [3] = MemWrite , [4] = MemRead, [5] = PCS
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
			br_branch,  //holds br address 
			read_data1, //to alu
			read_data2, //to alu_mux and to d-mem write data
			alu_result,	//to D-mem and D-mem mux
			mem_read_data,  //data read in D-mem to post D-mem mux
			write_data, //from D-mem mux
			imm_off, //SW, LW, LHB LLB
			pc_branch,  
			pc_incr, //store calculated pc increment
			IF_ID_Imm,
			src1,
			src2,
			DATA_ID_EX_OP2;

wire [11:0] signals_out; 	//Signal control wires	
wire [2:0]  flags_out;		//control flags = 3'b N, V, Z

wire [3:0] IF_ID_Rd, 		//To hold initial decode values
	   IF_ID_Rs,
	   IF_ID_Rt,
	   IF_ID_Opcode;					
wire [2:0] IF_ID_Cond; 		//conditional operation

wire IF_ID_WriteInstr;			//Hazard Unit Driven, tells when to pull instruction enable
wire stall; 				//Hazard Unit Driven, tells when to stall with NOPs
wire pc_write; 				//Hazard Unit Driven, tells when to write/ not write to pc
wire branch; 				//Branch unit driven, tells when a branch is taken or not

//condition code set by Forwarding Unit for decision made on alu src values
wire [1:0] forward_src1, forward_src2;

//** MODULES ** //

//Cache memory
cache_contoller D_cache_controller(.clk(clk), .rst(rst), .Address(MEM_ALU_result), .Data_In(D_new_block), 
				.Data_Out(data_out), .Write_Data_Array(D_write_data), .Write_Tag_Array(D_write_tag),
				.Miss(D_miss), .Read_Enable(MEM_MemRead | MEM_MemWrite), .Word_Num(word_num[2:0]));

cache_contoller I_cache_controller(.clk(clk), .rst(rst), .Address(PC_in), .Data_In(I_new_block), 
				.Data_Out(instruction), .Write_Data_Array(I_write_data), .Write_Tag_Array(I_write_tag), 
				.Miss(I_miss), .Read_Enable(1'b1), .Word_Num(word_num[2:0]));





//Instruction memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
//memory1c I_mem(				
//							.data_out(instr),
//							.data_in(16'h0000), 
//							.addr(pc), 
//							.enable(IF_ID_WriteInstr), 
//							.wr(1'b0), 
//							.clk(clk), 
//							.rst(~rst_n));
					
//Data memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
//memory1c D_mem(	
//				.data_out(mem_read_data), //to post d-mem mux
//				.data_in(DATA_EX_MEM[EX_MEM_OP2]), //from reg read_data2
//				.addr(DATA_EX_MEM[EX_MEM_RESULT]), //from alu
//				.enable(CTRL_EX_MEM[CONTROL_MEM_WRITE] | CTRL_EX_MEM[CONTROL_MEM_READ]), //one of the control signals enabled 
//				.wr(CTRL_EX_MEM[CONTROL_MEM_WRITE]), //from control
//				.clk(clk), 
//				.rst(~rst_n));

				
				
				
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
			.ALU_In1(src1),  //rs 	
			.ALU_In2(src2),  //rt
			.imm(IMM_ID_EX), //signed imm			
			.Opcode(OPCODE_ID_EX), //opcode
			.Flags_out(flags_out)); //to alu control unit and the and of the branch	

//Forwarding Unit
//forward_unit(ID_EX_Rt, ID_EX_Rs, EX_MEM_Rd, MEM_WB_Rd, EX_MEM_RegWrite, MEM_WB_RegWrite, forward_src1, forward_src2);
FwardUnit forward_unit(
	.ID_EX_Rt(REG_ID_EX[ID_EX_Rt]), 
	.ID_EX_Rs(REG_ID_EX[ID_EX_Rs]), 
	.EX_MEM_Rd(REG_EX_MEM_Rd), 
	.MEM_WB_Rd(REG_MEM_WB_Rd), 
	.EX_MEM_RegWrite(CTRL_EX_MEM[CONTROL_REG_WRITE]), 
	.MEM_WB_RegWrite(CTRL_MEM_WB[CONTROL_REG_WRITE]), 

	.forward_src1(forward_src1), 
	.forward_src2(forward_src2)
);
			
//Hazard Detection Unit
//HDU(IF_ID_Opcode, IF_ID_Rs, IF_ID_Rt, ID_EX_Rt, ID_EX_MemRead, pc_write, IF_ID_WriteInstr, stall);
HDU hdu(
	.IF_ID_Opcode(IF_ID_Opcode),
	.IF_ID_Rs(IF_ID_Rs), 
	.IF_ID_Rt(IF_ID_Rt), 
	.ID_EX_Rt(REG_ID_EX[ID_EX_Rd]), 
	
	.ID_EX_MemRead(CTRL_ID_EX[CONTROL_MEM_READ]),

	.pc_write(pc_write), 
	.IF_ID_WriteInstr(IF_ID_WriteInstr), 
	.stall(stall)
);			
						
//Branch Control 
//br_control(cond, flags, br_control, clk, branch);
br_control br_controller(
				.cond(IF_ID_Cond), 
				.flags(flags_out), 
				.br_control(signals_out[Branch]), 
				.clk(clk), 
				.branch(branch));						
						
//**Continuous Assignment**//						

assign pc_incr = pc + 2;	// PC Increment
assign pc_branch = signals_out[BranchRegister] ?  br_branch : DATA_IF_ID[IF_ID_PC] + IF_ID_Imm; 
assign br_branch = read_data1;  //TODO maybe implement forwarding on where register value comes from
assign write_data = CTRL_MEM_WB[CONTROL_MEM_TO_REG] ? DATA_MEM_WB[MEM_WB_DATA] : DATA_MEM_WB[MEM_WB_RESULT];  //Assign the data to be written back (Memory or AluResult)	
assign DATA_ID_EX_OP2 = CTRL_ID_EX[CONTROL_PCS] ? DATA_ID_EX[ID_EX_PC] : DATA_ID_EX[ID_EX_OP2]; //TODO may need a +2 on Data PC retrieved

//Forwarding ALU src1
assign src1 = (forward_src1 == SRC_ID_EX)  ? DATA_ID_EX[ID_EX_OP1] :
	      (forward_src1 == SRC_EX_MEM) ? DATA_EX_MEM[EX_MEM_RESULT] :
	      (forward_src1 == SRC_MEM_WB) ? write_data : DATA_ID_EX[ID_EX_OP1];

//Forwarding ALU scr2
assign src2 = (forward_src2 == SRC_ID_EX)  ? DATA_ID_EX_OP2 : 
	      (forward_src2 == SRC_EX_MEM) ? DATA_EX_MEM[EX_MEM_RESULT] :
	      (forward_src2 == SRC_MEM_WB) ? write_data : DATA_ID_EX_OP2;
		
//**Program Counter**//
always @(posedge clk or negedge rst_n) begin 
	if (~rst_n) begin
		pc <= 16'h0000;
	end else if (pc_write) begin
		pc <= (branch ? pc_branch : pc_incr);
	end else begin
		pc <= pc;
	end
end		  
		  		  
//**Control Pipeline**// 
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		CTRL_ID_EX  <= 6'b000000;
		CTRL_EX_MEM <= 5'b00000;
		CTRL_MEM_WB <= 3'b000;

		hlt	    <= 1'b0;
	end else begin
		// [0] = Halt, [1] = RegWrite, [2] = MemToReg, [3] = MemWrite , [4] = MemRead, [5] = PCS
		CTRL_ID_EX  <= (stall & ~signals_out[Halt]) ? 6'b000000 : {signals_out[PCS], signals_out[MemRead], signals_out[MemWrite], 
				signals_out[MemToReg], signals_out[RegWrite], signals_out[Halt]};
		CTRL_EX_MEM <= CTRL_ID_EX[4:0];
		CTRL_MEM_WB <= CTRL_EX_MEM[2:0];

		hlt 	    <= CTRL_EX_MEM[0];
	end
end

//**Data Pipeline**//
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		DATA_IF_ID[IF_ID_PC] <= 16'h0000;
		DATA_IF_ID[IF_ID_INST] <= 16'h0000;
		
		DATA_ID_EX[ID_EX_OP1] <= 16'h0000;
		DATA_ID_EX[ID_EX_OP2] <= 16'h0000;
		DATA_ID_EX[ID_EX_PC] <= 16'h0000;

		REG_ID_EX[ID_EX_Rd]  <= 4'h0;
		REG_ID_EX[ID_EX_Rs]  <= 4'h0;
		REG_ID_EX[ID_EX_Rt]  <= 4'h0;
		OPCODE_ID_EX  <= 4'h0;
		IMM_ID_EX     <= 16'h0000;

		DATA_EX_MEM[EX_MEM_RESULT] <= 16'h0000;
		DATA_EX_MEM[EX_MEM_RESULT] <= 16'h0000;
		REG_EX_MEM_Rd  <= 4'h0;
		FLAGS          <= 3'b000;

		DATA_MEM_WB[MEM_WB_DATA] <= 16'h0000;
		DATA_MEM_WB[MEM_WB_RESULT] <= 16'h0000;
		REG_MEM_WB_Rd  <= 4'h0;
	end else begin
		if (branch) begin
			DATA_IF_ID[IF_ID_PC]   <= pc_incr;
			DATA_IF_ID[IF_ID_INST] <= 16'h0000;
		end else if (IF_ID_WriteInstr) begin
			DATA_IF_ID[IF_ID_PC]   <= pc_incr;
			DATA_IF_ID[IF_ID_INST] <= instr;
		end else begin
			DATA_IF_ID[IF_ID_PC]   <= DATA_IF_ID[IF_ID_PC];
			DATA_IF_ID[IF_ID_INST] <= DATA_IF_ID[IF_ID_INST];
		end

		DATA_ID_EX[ID_EX_OP1]    <= read_data1;
		DATA_ID_EX[ID_EX_OP2]    <= read_data2;
		DATA_ID_EX[ID_EX_PC]     <= DATA_IF_ID[IF_ID_PC];
		REG_ID_EX[ID_EX_Rd]	 <= IF_ID_Rd;
		REG_ID_EX[ID_EX_Rs]	 <= IF_ID_Rs;
		REG_ID_EX[ID_EX_Rt]	 <= IF_ID_Rt;
		OPCODE_ID_EX		 <= IF_ID_Opcode;
		IMM_ID_EX		 <= IF_ID_Imm;

		DATA_EX_MEM[EX_MEM_RESULT] <= alu_result;
		DATA_EX_MEM[EX_MEM_OP2]  <= src2;
		REG_EX_MEM_Rd		 <= REG_ID_EX[ID_EX_Rd];
		FLAGS                    <= flags_out;

		DATA_MEM_WB[MEM_WB_DATA]   <= mem_read_data;
		DATA_MEM_WB[MEM_WB_RESULT] <= DATA_EX_MEM[EX_MEM_RESULT];
		REG_MEM_WB_Rd		 <= REG_EX_MEM_Rd;
	
	end
end

endmodule