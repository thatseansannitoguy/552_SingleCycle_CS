module red_add(rs, rt, rd);
//rs = aaaa_bbbb_cccc_dddd
//rt = eeee_ffff_gggg_hhhh
//rd = (((aaaa+eeee) + (bbbb+ffff)) + ((cccc+gggg) + (dddd+hhhh)))

input[15:0] rs, rt;
output [15:0] rd;

wire[6:0] carry_out;

wire[3:0] L1_0, L1_1, L1_2, L1_3, L2_0, L2_1, L3_0; //R[3:0] temp sum wires

wire WT_S0, WT_S1, WT_C0, WT_C1, WT_S2, WT_C3;

wire[2:0] R_bit_6_4;

//layer one of R[3:0]
//module adder_4bit_red(Sum, A, B, C_in, C_out);
adder_4bit_red L1_0_add(.Sum(L1_0), .A(rs[3:0]), .B(rt[3:0]), .C_in(1'b0), .C_out(carry_out[0]));

adder_4bit_red L1_1_add(.Sum(L1_1), .A(rs[7:4]), .B(rt[7:4]), .C_in(1'b0), .C_out(carry_out[1]));

adder_4bit_red L1_2_add(.Sum(L1_2), .A(rs[11:8]), .B(rt[11:8]), .C_in(1'b0), .C_out(carry_out[2]));

adder_4bit_red L1_3_add(.Sum(L1_3), .A(rs[15:12]), .B(rt[15:12]), .C_in(1'b0), .C_out(carry_out[3]));

//layer two of R[3:0]
adder_4bit_red L2_0_add(.Sum(L2_0), .A(L1_0), .B(L1_1), .C_in(1'b0), .C_out(carry_out[4]));

adder_4bit_red L2_1_add(.Sum(L2_1), .A(L1_2), .B(L1_3), .C_in(1'b0), .C_out(carry_out[5]));

//layer three of R[3:0]
adder_4bit_red L3_0_add(.Sum(L3_0), .A(L2_0), .B(L2_1), .C_in(1'b0), .C_out(carry_out[6]));

//R[6:4] wallace tree dealing with carry bits from R[3:0]
//WT layer1
full_adder_1bit C_0_1_2(.A(carry_out[0]), .B(carry_out[1]), .Cin(carry_out[2]), .S(WT_S0), .Cout(WT_C0));

full_adder_1bit C_3_4_5(.A(carry_out[3]), .B(carry_out[4]), .Cin(carry_out[5]), .S(WT_S1), .Cout(WT_C1));

//WT layer2
full_adder_1bit C_0_1_2(.A(WT_S0), .B(WT_S1), .Cin(carry_out[6]), .S(R_bit_6_4[0]), .Cout(WT_C3));
full_adder_1bit C_0_1_2(.A(WT_C0), .B(WT_C1), .Cin(WT_C3), .S(R_bit_6_4[1]), .Cout(R_bit_6_4[2]));

//sign extended rd 
assign rd = {{9{R_bit_6_4[2]}}, R_bit_6_4, L3_0};