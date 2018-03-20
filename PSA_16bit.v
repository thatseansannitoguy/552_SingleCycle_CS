module PSA_16bit(Sum, Error, A, B);

input[15:0] A, B; //Input values

output[15:0] Sum; //sum output
output Error; //To indicate any instance of overflow

wire[3:0] Ovfl_check;
//aaaa_bbbb_cccc_dddd   A
//eeee_ffff_gggg_hhhh + B
assign Error = Ovfl_check[0] | Ovfl_check[1] | Ovfl_check[2] | Ovfl_check[3];

//TODO addsub_4bit needs saturation implemented without <,> operators
addsub_4bit a_e(.Sum(Sum[15:12]), .Ovfl(Ovfl_check[3]), .A(A[15:12]), .B(B[15:12]), .sub(1'b0));
addsub_4bit b_f(.Sum(Sum[11:8]), .Ovfl(Ovfl_check[2]), .A(A[11:8]), .B(B[11:8]), .sub(1'b0));
addsub_4bit c_g(.Sum(Sum[7:4]), .Ovfl(Ovfl_check[1]), .A(A[7:4]), .B(B[7:4]), .sub(1'b0));
addsub_4bit d_h(.Sum(Sum[3:0]), .Ovfl(Ovfl_check[0]), .A(A[3:0]), .B(B[3:0]), .sub(1'b0));

endmodule