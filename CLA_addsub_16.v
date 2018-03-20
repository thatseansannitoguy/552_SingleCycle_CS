module CLA_addsub_16(Sum, Ovfl, A, B, sub);
input [15:0] A, B;
input sub;

output[15:0] Sum;
output Ovfl;

wire [15:0] carry;
wire [15:0] Sum_temp;

//full_adder_1bit(A, B, Cin, S, Cout);

full_adder_1bit FA1(A[0],  sub^B[0], sub, 	   Sum_temp[0], carry[0]);
full_adder_1bit FA2(A[1],  sub^B[1], carry[0], Sum_temp[1], carry[1]);
full_adder_1bit FA3(A[2],  sub^B[2], carry[1], Sum_temp[2], carry[2]);
full_adder_1bit FA4(A[3],  sub^B[3], carry[2], Sum_temp[3], carry[3]);
full_adder_1bit FA5(A[4],  sub^B[4], carry[3], Sum_temp[4], carry[4]);
full_adder_1bit FA6(A[5],  sub^B[5], carry[4], Sum_temp[5], carry[5]);
full_adder_1bit FA7(A[6],  sub^B[6], carry[5], Sum_temp[6], carry[6]);
full_adder_1bit FA8(A[7],  sub^B[7], carry[6], Sum_temp[7], carry[7]);
full_adder_1bit FA9(A[8],  sub^B[8], carry[7], Sum_temp[8], carry[8]);
full_adder_1bit FA10(A[9],  sub^B[9], carry[8], Sum_temp[9], carry[9]);
full_adder_1bit FA11(A[10], sub^B[10], carry[9], Sum_temp[10], carry[10]);
full_adder_1bit FA12(A[11], sub^B[11], carry[10], Sum_temp[11], carry[11]);
full_adder_1bit FA13(A[12], sub^B[12], carry[11], Sum_temp[12], carry[12]);
full_adder_1bit FA14(A[13], sub^B[13], carry[12], Sum_temp[13], carry[13]);
full_adder_1bit FA15(A[14], sub^B[14], carry[13], Sum_temp[14], carry[14]);
full_adder_1bit FA16(A[15], sub^B[15], carry[14], Sum_temp[15], carry[15]);

assign Ovfl = carry[15] ^ carry[14];

//Sat logic
// if Ovfl, and A bit 15 is 1, and B bit 15 is 1, then 16'h8000
// then if Ovfl, and A bit 15 is 0, and B bit 15 is 0, then 16'h7FFF
// else, then normal Sum
assign Sum = ((Ovfl == 1'b1) && (A[15] == 1'b1) && (B[15] == 1'b1)) ? 16'h8000 :
			 ((Ovfl == 1'b1) && (A[15] == 1'b0) && (B[15] == 1'b0)) ? 16'h7FFF :
			 Sum_temp;

endmodule