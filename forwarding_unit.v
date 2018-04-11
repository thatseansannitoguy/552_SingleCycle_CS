module FwardUnit(ID_EX_Rt, ID_EX_Rs, EX_MEM_Rd, MEM_WB_Rd, EX_MEM_RegWrite, MEM_WB_RegWrite, forward_src1, forwardb);

//register addr for Rt, Rs, Rd in various pipline stages
input [3:0] ID_EX_Rt, ID_EX_Rs, EX_MEM_Rd, MEM_WB_Rd;

//control flag RegWrite values for EX/MEM and MEM/WB stages
input EX_MEM_RegWrite, MEM_WB_RegWrite;

//condition codes for forwarded values for src 1 and 2 for ALU 
output reg [1:0] forward_src1, forward_src2;

localparam NO_HAZARD  = 2'b00;
localparam EX_HAZARD  = 2'b10;
localparam MEM_HAZARD = 2'b01;

always @(*) begin
	if ((EX_MEM_RegWrite & |EX_MEM_Rd) & (EX_MEM_Rd == ID_EX_Rs)) begin
		forward_src1 <= EX_HAZARD;
	end else if ((MEM_WB_RegWrite & |MEM_WB_Rd) & (MEM_WB_Rd == ID_EX_Rs)) begin
		forward_src1 <= MEM_HAZARD;
	end else begin
		forward_src1 <= NO_HAZARD;
	end

	if ((EX_MEM_RegWrite & |EX_MEM_Rd) & (EX_MEM_Rd == ID_EX_Rt)) begin
		forward_src2 <= EX_HAZARD;
	end else if ((MEM_WB_RegWrite & |MEM_WB_Rd) & (MEM_WB_Rd == ID_EX_Rt)) begin
		forward_src2 <= MEM_HAZARD;
	end else begin
		forward_src2 <= NO_HAZARD;
	end
end

endmodule
