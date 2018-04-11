module FwardUnit(ID_EX_Rt, ID_EX_Rs, EX_MEM_Rd, MEM_WB_Rd, EX_MEM_RegWrite, MEM_WB_RegWrite, forward_src1, forward_src2);

//register addr for Rt, Rs, Rd in various pipline stages
input [3:0] ID_EX_Rt, ID_EX_Rs, EX_MEM_Rd, MEM_WB_Rd;

//control flag RegWrite values for EX/MEM and MEM/WB stages
input EX_MEM_RegWrite, MEM_WB_RegWrite;

//condition codes for forwarded values for src 1 and 2 for ALU 
output reg [1:0] forward_src1, forward_src2;

//hazard condition code params
localparam EX_HAZARD  = 2'b10;
localparam MEM_HAZARD = 2'b01;
localparam NO_HAZARD  = 2'b00;

always @(*) begin
	/*forward_src1 (Rs) logic */
	//if EX/MEM RegWrite control is asserted and it Rd is the same as ID/EX Rs -> execution hazard
	if ((EX_MEM_RegWrite) && (EX_MEM_Rd == ID_EX_Rs)) begin
		forward_src1 <= EX_HAZARD;
	//if MEM/WB RegWrite is asserted and its Rd is the same as ID/EX Rs -> memory hazard
	end else if ((MEM_WB_RegWrite) && (MEM_WB_Rd == ID_EX_Rs)) begin
		forward_src1 <= MEM_HAZARD;
	//condition code for no hazard in forward_src1
	end else begin
		forward_src1 <= NO_HAZARD;
	end

	/*forward_src2 (Rd) logic */
	//if EX/MEM RegWrite control is asserted and its Rd is the same as ID/EX Rt -> execution hazard
	if ((EX_MEM_RegWrite) && (EX_MEM_Rd == ID_EX_Rt)) begin
		forward_src2 <= EX_HAZARD;
	//if MEM/WB RegWrite is asserted and its Rd is the same as ID/EX Rt -> memory hazard
	end else if ((MEM_WB_RegWrite) && (MEM_WB_Rd == ID_EX_Rt)) begin
		forward_src2 <= MEM_HAZARD;
	//condition code for no hazard in forward_src2
	end else begin
		forward_src2 <= NO_HAZARD;
	end
end

endmodule
