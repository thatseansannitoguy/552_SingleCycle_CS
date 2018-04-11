module HDU(IF_ID_Opcode, IF_ID_Rs, IF_ID_Rt, ID_EX_Rt, ID_EX_MemRead, pc_write, IF_ID_WriteInstr, stall);

input [3:0] IF_ID_Opcode, IF_ID_Rs, IF_ID_Rt, ID_EX_Rt;
input ID_EX_MemRead;

output pc_write, IF_ID_WriteInstr, stall;

localparam ON 	= 1'b1;
localparam OFF = 1'b0;


always @(*) begin
	if (IF_ID_Opcode == 4'b1111) begin //IF current opcode is HLT, then stall
		pc_write = OFF;
		if_id_write = OFF;
		stall = ON;
	end else if (ID_EX_MemRead) begin //in the event ID/EX is reading from mem
		//IF the target currently in ID/EX is the same as the source of IF/ID
		//OR if the target of ID/ED is the same as the target of the IF/ID 
		//then stall and do not write
		if (ID_EX_Rt == IF_ID_Rs || ID_EX_Rt == IF_ID_Rt) begin
					pc_write = OFF;
					if_id_write = OFF;
					stall = ON;
		end else begin //hazard condition not met
					pc_write = ON;
					if_id_write = ON;
					stall = OFF;
		end
	end else begin //no hazard found
		pc_write = ON;
		if_id_write = ON;
		stall = OFF;
	end
end

endmodule
