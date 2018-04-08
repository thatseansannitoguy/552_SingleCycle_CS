module HDU(opcode, if_id_rs, if_id_rt, id_ex_rt, id_ex_mr, pc_write, if_id_write, stall);

input [3:0] opcode, if_id_rs, if_id_rt, id_ex_rt;
input id_ex_mr;
output pc_write, if_id_write, stall;

localparam DETECTED 	= 1'b1;
localparam NOT_DETECTED = 1'b0;
localparam HLT 		= 4'b1111;

reg detected;

assign pc_write = ~detected;
assign if_id_write = ~detected;
assign stall = detected;

always @(*) begin
	if (opcode == HLT) begin
		detected = DETECTED;
	end else if (id_ex_mr) begin
		if (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt) begin
			detected = DETECTED;
		end else begin
			detected = NOT_DETECTED;
		end
	end else begin
		detected = NOT_DETECTED;
	end
end

endmodule
