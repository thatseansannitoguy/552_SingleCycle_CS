module adder_4bit_red(Sum, A, B, C_in, C_out);

input [3:0] A, B; //input values
input C_in; //carry input

output [3:0] Sum; //sum
output C_out; //carry output

wire [2:0] carry; //carry throught the FAdders

full_adder_1bit bit1(.A(A[0]), .B(B[0]), .Cin(C_in), .S(Sum[0]), .Cout(carry[0]));
full_adder_1bit bit2(.A(A[1]), .B(B[1]), .Cin(carry[0]), .S(Sum[1]), .Cout(carry[1]));
full_adder_1bit bit3(.A(A[2]), .B(B[2]), .Cin(carry[1]), .S(Sum[2]), .Cout(carry[2]));
full_adder_1bit bit4(.A(A[3]), .B(B[3]), .Cin(carry[2]), .S(Sum[3]), .Cout(C_out));

endmodule