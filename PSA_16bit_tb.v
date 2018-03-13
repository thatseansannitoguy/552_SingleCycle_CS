module PSA_16bit_tb;

reg [15:0] A, B;
reg sub;

wire signed[15:0] Sum;

wire Error;

//helper wires
wire signed[3:0] a_e, b_f, c_g, d_h;

PSA_16bit DUT(.Sum(Sum), .Error(Error), .A(A), .B(B));

//assign
assign d_h = A[3:0] + B[3:0];
assign c_g = A[7:4] + B[7:4];
assign b_f = A[11:8] + B[11:8];
assign a_e = A[15:12] + B[15:12];

initial begin
	A = 16'b0;
	B = 16'b0;

	repeat(100) begin
			
		A = $random;
		B = $random;

		#20

		if(Error != 1'b0 &&
		d_h != Sum[3:0] &&
		c_g != Sum[7:4] &&
		b_f != Sum[11:8] &&
		a_e != Sum[15:12])
		begin
			$display("INCORRECT value for A: %b and B: %b, with a sum of: %b, overflow is: %b", A, B, Sum, Error);
			$display("a_e = %b", a_e);
			$display("b_f = %b", b_f);
			$display("c_g = %b", c_g);
			$display("d_h = %b", d_h);

			$stop;	
		end
		
		$display("A: %b and B: %b", A, B);
		$display("Sum: %b and Error: %b", Sum, Error);


	end

	$display("all results correct");
end
endmodule