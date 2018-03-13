module ALU_tb;

reg signed[7:0] ALU_input;
reg [1:0] Opcode;

wire signed[3:0] A_input, B_input;

wire signed [3:0] ALU_Out;
wire Error;

ALU DUT(.ALU_Out(ALU_Out), .Error(Error), .ALU_In1(A_input), .ALU_In2(B_input), .Opcode(Opcode));

assign A_input = ALU_input[7:4];
assign B_input = ALU_input[3:0];

initial begin 
	//all add test cases
	$display("BEGIN ADD now");
	Opcode = 2'b00;
	for(ALU_input = 8'b0; ALU_input < 8'b1111111; ALU_input = ALU_input + 1) 
	begin
		#10;
		if((ALU_Out != (A_input + B_input)) && Error == 1'b0)
		begin
			$display("INCORRECT value for A: %d and B: %d, with a sum of: %d, overflow is: %b", A_input, B_input, ALU_Out, Error);
			$stop;
		end
	end
	//setup for subtraction
	$display("BEGIN SUB now");
	#10;
	Opcode = 2'b01;
	for(ALU_input = 8'b00000000; ALU_input < 8'b1111111; ALU_input = ALU_input + 1) 
	begin
			
		#10;
		if((ALU_Out != (A_input - B_input)) && Error == 1'b0)
		begin
			$display("INCORRECT value for A: %d and B: %d, with a sum of: %d, overflow is: %b", A_input, B_input, ALU_Out, Error);
			$stop;
		end
	end
	//setup for NAND
	$display("BEGIN NAND now");
	#10;
	Opcode = 2'b10;
	for(ALU_input = 8'b00000000; ALU_input < 8'b1111111; ALU_input = ALU_input + 1) 
	begin

		#10;
		if(ALU_Out != (~A_input | ~B_input))
		begin
			$display("INCORRECT value for A: %b and B: %b, with a NAND of: %b", A_input, B_input, ALU_Out);
			$stop;
		end
	end
	//setup for XOR
	$display("BEGIN XOR now");
	#10;
	Opcode = 2'b11;
	for(ALU_input = 8'b00000000; ALU_input < 8'b1111111; ALU_input = ALU_input + 1) 
	begin

		#10;
		if(ALU_Out != (A_input ^ B_input))
		begin
			$display("INCORRECT value for A: %b and B: %b, with a XOR of: %b", A_input, B_input, ALU_Out);
			$stop;
		end
	end

	$display("All operations complete without error");
end

endmodule
