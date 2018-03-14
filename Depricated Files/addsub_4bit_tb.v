module addsub_4bit_tb;

reg signed[7:0] A_B_input;
reg sub;

wire signed[3:0] A_input, B_input;

wire signed [3:0] Sum;
wire Ovfl;

addsub_4bit DUT(.Sum(Sum), .Ovfl(Ovfl), .A(A_input), .B(B_input), .sub(sub));

assign A_input = A_B_input[7:4];
assign B_input = A_B_input[3:0];

initial begin 
	A_B_input = 8'b0;
	sub = 1'b0;
	repeat(100) begin
	
		#20 A_B_input = $random;

		if((Sum != (A_input + B_input)) && Ovfl == 1'b0)
		begin
			$display("INCORRECT value for A: %d and B: %d, with a sum of: %d, overflow is: %b", A_input, B_input, Sum, Ovfl);
			$stop;
		end
	end
	//setup for subtraction
	A_B_input = 8'b0;
	sub = 1'b1;
	$display("sub now:%b", sub);
	#10;
	repeat(100) begin
		#20 A_B_input = $random;

		if((Sum != (A_input - B_input)) && Ovfl == 1'b0)
		begin
			$display("INCORRECT value for A: %d and B: %d, with a sum of: %d, overflow is: %b", A_input, B_input, Sum, Ovfl);
			$stop;
		end
	end
	$display("All operations complete without error");
end

endmodule

