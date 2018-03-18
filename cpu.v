module cpu(clk, rst_n, hlt, pc);
input clk, rst_n; //system clock and active LOW reset, causes execution to start at 0x0000

output reg hlt; //will be asserted when HLT instruction is encountered
output reg [15:0] pc; //pc value over program execution 

wire [15:0] instr, //instruction
			read_data1, //to alu
			read_data2, //to alu_mux and to d-mem write data
			alu_result,	//to D-mem and D-mem mux
			read_data,  //data read in D-mem to post D-mem mux
			write_data; //from D-mem mux
			
wire reg [2:0] flags;		

//control signals set by control unit			
wire mem_write, mem_read, mem_to_reg;

//two instances of Memory for I-mem and D-mem
//Instruction memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
memory1c I_mem(				.data_out(instr),
							.data_in(16'h0000), 
							.addr(pc), 
							.enable(1'b1), 
							.wr(1'b0), 
							.clk(clk), 
							.rst(rst_n));
							
//control block
//TODO make an actual entire control block


//register file 
//RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
RegisterFile reg_file(	.clk(clk), 
						.rst(rst_n), 
						.SrcReg1(instr[7:4]), //rs
						.SrcReg2(instr[3:0]), //rt
						.DstReg(instr[11:8]), //rd
						.WriteReg(),// mux select between instr[7:4] or imm TODO 
						.DstData(), // comes from mux after d-mem TODO
						.SrcData1(read_data1), //rs
						.SrcData2(read_data2));//rt to alu_mux and to write data D-mem
						
//ALU
// module ALU(ALU_Out, Ovfl, ALU_In1, ALU_In2, Opcode, Flags_out);
ALU alu_op(	.ALU_Out(alu_result),  //to D-mem and D-mem mux
			.ALU_In1(read_data1),  //rs
			.ALU_In2(),  //rt or sign extended imm TODO
			.Opcode(instr[14:12]), //opcode
			.Flags_out(flags)); //to alu control unit and the and of the branch
			
//branch conditions logic? TODO?

//Data memory
//memory1c (data_out, data_in, addr, enable, wr, clk, rst);
memory1c D_mem(	.data_out(read_data), //to post d-mem mux
				.data_in(read_data2), //from reg
				.addr(alu_result), //from alu
				.enable(mem_write | mem_read), //one of the control signals enabled 
				.wr(mem_write), //from control
				.clk(clk), 
				.rst(rst_n));
				
//control assignments 
assign next_pc = pc + 1;

//D-mem mux
assign write_data = (mem_to_reg) ? read_data :
					alu_result;




always @(posedge clk or negedge rst_n) begin 
	if (~rst_n) begin
		pc <= 16'h0000;
	end else begin
		if (pc_write) begin
			pc <= (branch ? pc_branch : pc_incr);
		end else begin
			pc <= pc;
		end
	end
end

endmodule