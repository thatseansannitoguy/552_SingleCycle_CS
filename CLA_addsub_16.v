module CLA_addsub_16(Sum, Ovfl, A, B, sub);
input signed[15:0] A, B;
input sub;

output signed[15:0] Sum, Sum_temp;
output Ovfl;
wire [15:0] carry;

assign Ovfl = carry[15] ^ carry[14];
//full_adder_1bit(A, B, Cin, S, Cout);

full_adder_1bit FA1(A[0],  B[0], sub, 	   Sum_temp[0], carry[0]);
full_adder_1bit FA2(A[1],  B[1], carry[0], Sum_temp[1], carry[1]);
full_adder_1bit FA3(A[2],  B[2], carry[1], Sum_temp[2], carry[2]);
full_adder_1bit FA4(A[3],  B[3], carry[2], Sum_temp[3], carry[3]);
full_adder_1bit FA4(A[4],  B[4], carry[3], Sum_temp[4], carry[4]);
full_adder_1bit FA4(A[5],  B[5], carry[4], Sum_temp[5], carry[5]);
full_adder_1bit FA4(A[6],  B[6], carry[5], Sum_temp[6], carry[6]);
full_adder_1bit FA4(A[7],  B[7], carry[6], Sum_temp[7], carry[7]);
full_adder_1bit FA4(A[8],  B[8], carry[7], Sum_temp[8], carry[8]);
full_adder_1bit FA4(A[9],  B[9], carry[8], Sum_temp[9], carry[9]);
full_adder_1bit FA4(A[10], B[10], carry[9], Sum_temp[10], carry[10]);
full_adder_1bit FA4(A[11], B[11], carry[10], Sum_temp[11], carry[11]);
full_adder_1bit FA4(A[12], B[12], carry[11], Sum_temp[12], carry[12]);
full_adder_1bit FA4(A[13], B[13], carry[12], Sum_temp[13], carry[13]);
full_adder_1bit FA4(A[14], B[14], carry[13], Sum_temp[14], carry[14]);
full_adder_1bit FA4(A[15], B[15], carry[14], Sum_temp[15], carry[15]);

//TODO Sat logic not correct, needs to be done correctly
//maybe, if Ovfl, and A bit 15 is 1, and B bit 15 is 1, then 16'h8000
// then if Ovfl, and A bit 15 is 0,, and B bit 15 is 0, then 16'h7FFF
// else, then normal Sum
assign Sum = ((A >= 16'h0000) && (B >= 16'h0000) && (Sum_temp < 16'h0000)) ? 16'h7FFF :
			 ((A <= 16'h0000) && (B <= 16'h0000) && (Sum_temp > 16'h0000)) ? 16'h8000 :
			 Sum_temp;

endmodule