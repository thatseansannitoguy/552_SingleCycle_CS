module addsub_4bit(Sum, Ovfl, A, B, sub);

input [3:0] A, B; //input values
input sub; //add-sub indicator add(0), sub(1)

output [3:0] Sum; //Sum output
output Ovfl; //overflow indicator

wire [4:1] carry;

assign Ovfl = carry[4] ^ carry[3];

full_adder_1bit FA1(A[0], sub^B[0], sub, Sum[0], carry[1]);
full_adder_1bit FA2(A[1], sub^B[1], carry[1], Sum[1], carry[2]);
full_adder_1bit FA3(A[2], sub^B[2], carry[2], Sum[2], carry[3]);
full_adder_1bit FA4(A[3], sub^B[3], carry[3], Sum[3], carry[4]);

//TODO implement saturation

endmodule