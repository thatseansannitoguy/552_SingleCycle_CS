//3 to 8 bit decoder module
module decoder_3_8(input_3, output_8);
input [2:0] input_3;
output reg [7:0] output_8;

always @ (*)
	case (input_3)
		3'b000 : assign output_8 = 8'h01;
		3'b001 : assign output_8 = 8'h02;
		3'b010 : assign output_8 = 8'h04;
		3'b011 : assign output_8 = 8'h08;
		3'b100 : assign output_8 = 8'h10;
		3'b101 : assign output_8 = 8'h20;
		3'b110 : assign output_8 = 8'h40;
		3'b111 : assign output_8 = 8'h80
	endcase

endmodule