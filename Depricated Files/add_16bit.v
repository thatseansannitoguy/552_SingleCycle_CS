module add_16bit(Sum, A, B);
input [16] A;
input [16] B; 

output [16] Sum;
wire [16] carry;
//full_adder_1bit(A, B, Cin, S, Cout);

full_adder_1bit FA1(A[0],  B[0], 1'b0, 	   Sum[0], carry[0]);
full_adder_1bit FA2(A[1],  B[1], carry[0], Sum[1], carry[1]);
full_adder_1bit FA3(A[2],  B[2], carry[1], Sum[2], carry[2]);
full_adder_1bit FA4(A[3],  B[3], carry[2], Sum[3], carry[3]);
full_adder_1bit FA4(A[4],  B[4], carry[3], Sum[4], carry[4]);
full_adder_1bit FA4(A[5],  B[5], carry[4], Sum[5], carry[5]);
full_adder_1bit FA4(A[6],  B[6], carry[5], Sum[6], carry[6]);
full_adder_1bit FA4(A[7],  B[7], carry[6], Sum[7], carry[7]);
full_adder_1bit FA4(A[8],  B[8], carry[7], Sum[8], carry[8]);
full_adder_1bit FA4(A[9],  B[9], carry[8], Sum[9], carry[9]);
full_adder_1bit FA4(A[10], B[10], carry[9], Sum[10], carry[10]);
full_adder_1bit FA4(A[11], B[11], carry[10], Sum[11], carry[11]);
full_adder_1bit FA4(A[12], B[12], carry[11], Sum[12], carry[12]);
full_adder_1bit FA4(A[13], B[13], carry[12], Sum[13], carry[13]);
full_adder_1bit FA4(A[14], B[14], carry[13], Sum[14], carry[14]);
full_adder_1bit FA4(A[15], B[15], carry[14], Sum[15], carry[15]);

endmodule