module Shifter(Shift_Out, Shift_In, Shift_Val, Mode);

input[15:0] Shift_In; //This is the number to perform the shift operation on
input[3:0] Shift_Val; //Shift amount (used to shift the 'Shift_ln')
input [1:0] Mode; //To indicate SLL=00 or SRA=01 or ROR=11

output[15:0] Shift_Out; //Shifter value

wire L1_1, L1_2, L1_3, L1_4, L1_5, L1_6, L1_7, L1_8, L1_9, L1_10, L1_11, L1_12, L1_13, L1_14, L1_15, L1_16;
wire L2_1, L2_2, L2_3, L2_4, L2_5, L2_6, L2_7, L2_8, L2_9, L2_10, L2_11, L2_12, L2_13, L2_14, L2_15, L2_16;
wire L3_1, L3_2, L3_3, L3_4, L3_5, L3_6, L3_7, L3_8, L3_9, L3_10, L3_11, L3_12, L3_13, L3_14, L3_15, L3_16;

wire[1:0] Sel_1, Sel_2, Sel_3, Sel_4;
//00=A, 01=B, 10=C

assign Mode = (Mode == 2'b10) ? 2'b11 : //ROR assignment fix
			  Mode;


//sel[1],sel[0]
//shiftval, mode
assign Sel_1 = {Shift_Val[0], Mode[0]}; 
assign Sel_2 = {Shift_Val[1], Mode[0]};
assign Sel_3 = {Shift_Val[2], Mode[0]};
assign Sel_4 = {Shift_Val[3], Mode[0]};

//ROR vs SRA based on Mode[1]
wire M1_rot;
wire M2_rot_16, M2_rot_15; 
wire M3_rot_16, M3_rot_15, M3_rot_14, M3_rot_13;
wire M4_rot_16, M4_rot_15, M4_rot_14, M4_rot_13, M4_rot_12, M4_rot_11, M4_rot_10, M4_rot_9;
//1 mux from 1st slice
assign M1_rot = (Mode[1] == 1'b1) ? Shift_In[0] :
									Shift_In[15];
//2 mux's from 2nd slice								
assign M2_rot_16 = (Mode[1] == 1'b1) ? L1_2 :
									   L1_16;	
assign M2_rot_15 = (Mode[1] == 1'b1) ? L1_1 :
									   L1_16;
//4 mux's from 3nd slice								
assign M3_rot_16 = (Mode[1] == 1'b1) ? L2_4 :
									   L2_16;	
assign M3_rot_15 = (Mode[1] == 1'b1) ? L2_3 :
									   L2_16;
assign M3_rot_14 = (Mode[1] == 1'b1) ? L2_2 :
									   L2_16;	
assign M3_rot_13 = (Mode[1] == 1'b1) ? L2_1 :
									   L2_16;

//8 mux's from 4nd slice								
assign M4_rot_16 = (Mode[1] == 1'b1) ? L3_8 :
									   L3_16;	
assign M4_rot_15 = (Mode[1] == 1'b1) ? L3_7 :
									   L3_16;
assign M4_rot_14 = (Mode[1] == 1'b1) ? L3_6 :
									   L3_16;	
assign M4_rot_13 = (Mode[1] == 1'b1) ? L3_5 :
									   L3_16;
assign M4_rot_12 = (Mode[1] == 1'b1) ? L3_4 :
									   L3_16;	
assign M4_rot_11 = (Mode[1] == 1'b1) ? L3_3 :
									   L3_16;
assign M4_rot_10 = (Mode[1] == 1'b1) ? L3_2 :
									   L3_16;	
assign M4_rot_9 = (Mode[1] == 1'b1) ? L3_1 :
									   L3_16;
									   
//First layer of MUXes TODO C for SRA
Mux_3_1 M1_16(.Out(L1_16), .A(Shift_In[15]), .B(Shift_In[14]), .C(M1_rot), .Sel(Sel_1));
Mux_3_1 M1_15(.Out(L1_15), .A(Shift_In[14]), .B(Shift_In[13]), .C(Shift_In[15]), .Sel(Sel_1));
Mux_3_1 M1_14(.Out(L1_14), .A(Shift_In[13]), .B(Shift_In[12]), .C(Shift_In[14]), .Sel(Sel_1));
Mux_3_1 M1_13(.Out(L1_13), .A(Shift_In[12]), .B(Shift_In[11]), .C(Shift_In[13]), .Sel(Sel_1));
Mux_3_1 M1_12(.Out(L1_12), .A(Shift_In[11]), .B(Shift_In[10]), .C(Shift_In[12]), .Sel(Sel_1));
Mux_3_1 M1_11(.Out(L1_11), .A(Shift_In[10]), .B(Shift_In[9]), .C(Shift_In[11]), .Sel(Sel_1));
Mux_3_1 M1_10(.Out(L1_10), .A(Shift_In[9]), .B(Shift_In[8]), .C(Shift_In[10]), .Sel(Sel_1));
Mux_3_1 M1_9(.Out(L1_9), .A(Shift_In[8]), .B(Shift_In[7]), .C(Shift_In[9]), .Sel(Sel_1));
Mux_3_1 M1_8(.Out(L1_8), .A(Shift_In[7]), .B(Shift_In[6]), .C(Shift_In[8]), .Sel(Sel_1));
Mux_3_1 M1_7(.Out(L1_7), .A(Shift_In[6]), .B(Shift_In[5]), .C(Shift_In[7]), .Sel(Sel_1));
Mux_3_1 M1_6(.Out(L1_6), .A(Shift_In[5]), .B(Shift_In[4]), .C(Shift_In[6]), .Sel(Sel_1));
Mux_3_1 M1_5(.Out(L1_5), .A(Shift_In[4]), .B(Shift_In[3]), .C(Shift_In[5]), .Sel(Sel_1));
Mux_3_1 M1_4(.Out(L1_4), .A(Shift_In[3]), .B(Shift_In[2]), .C(Shift_In[4]), .Sel(Sel_1));
Mux_3_1 M1_3(.Out(L1_3), .A(Shift_In[2]), .B(Shift_In[1]), .C(Shift_In[3]), .Sel(Sel_1));
Mux_3_1 M1_2(.Out(L1_2), .A(Shift_In[1]), .B(Shift_In[0]), .C(Shift_In[2]), .Sel(Sel_1));
Mux_3_1 M1_1(.Out(L1_1), .A(Shift_In[0]), .B(1'b0), .C(Shift_In[1]), .Sel(Sel_1));

//Second layer of MUXes TODO C for SRA
Mux_3_1 M2_16(.Out(L2_16), .A(L1_16), .B(L1_14), .C(M2_rot_16), .Sel(Sel_2));
Mux_3_1 M2_15(.Out(L2_15), .A(L1_15), .B(L1_13), .C(M2_rot_15), .Sel(Sel_2));
Mux_3_1 M2_14(.Out(L2_14), .A(L1_14), .B(L1_12), .C(L1_16), .Sel(Sel_2));
Mux_3_1 M2_13(.Out(L2_13), .A(L1_13), .B(L1_11), .C(L1_15), .Sel(Sel_2));
Mux_3_1 M2_12(.Out(L2_12), .A(L1_12), .B(L1_10), .C(L1_14), .Sel(Sel_2));
Mux_3_1 M2_11(.Out(L2_11), .A(L1_11), .B(L1_9), .C(L1_13), .Sel(Sel_2));
Mux_3_1 M2_10(.Out(L2_10), .A(L1_10), .B(L1_8), .C(L1_12), .Sel(Sel_2));
Mux_3_1 M2_9(.Out(L2_9), .A(L1_9), .B(L1_7), .C(L1_11), .Sel(Sel_2));
Mux_3_1 M2_8(.Out(L2_8), .A(L1_8), .B(L1_6), .C(L1_10), .Sel(Sel_2));
Mux_3_1 M2_7(.Out(L2_7), .A(L1_7), .B(L1_5), .C(L1_9), .Sel(Sel_2));
Mux_3_1 M2_6(.Out(L2_6), .A(L1_6), .B(L1_4), .C(L1_8), .Sel(Sel_2));
Mux_3_1 M2_5(.Out(L2_5), .A(L1_5), .B(L1_3), .C(L1_7), .Sel(Sel_2));
Mux_3_1 M2_4(.Out(L2_4), .A(L1_4), .B(L1_2), .C(L1_6), .Sel(Sel_2));
Mux_3_1 M2_3(.Out(L2_3), .A(L1_3), .B(L1_1), .C(L1_5), .Sel(Sel_2));
Mux_3_1 M2_2(.Out(L2_2), .A(L1_2), .B(1'b0), .C(L1_4), .Sel(Sel_2));
Mux_3_1 M2_1(.Out(L2_1), .A(L1_1), .B(1'b0), .C(L1_3), .Sel(Sel_2));

//Third layer of MUXes TODO C for SRA
Mux_3_1 M3_16(.Out(L3_16), .A(L2_16), .B(L2_12), .C(M3_rot_16), .Sel(Sel_3));
Mux_3_1 M3_15(.Out(L3_15), .A(L2_15), .B(L2_11), .C(M3_rot_15), .Sel(Sel_3));
Mux_3_1 M3_14(.Out(L3_14), .A(L2_14), .B(L2_10), .C(M3_rot_14), .Sel(Sel_3));
Mux_3_1 M3_13(.Out(L3_13), .A(L2_13), .B(L2_9), .C(M3_rot_13), .Sel(Sel_3));
Mux_3_1 M3_12(.Out(L3_12), .A(L2_12), .B(L2_8), .C(L2_16), .Sel(Sel_3));
Mux_3_1 M3_11(.Out(L3_11), .A(L2_11), .B(L2_7), .C(L2_15), .Sel(Sel_3));
Mux_3_1 M3_10(.Out(L3_10), .A(L2_10), .B(L2_6), .C(L2_14), .Sel(Sel_3));
Mux_3_1 M3_9(.Out(L3_9), .A(L2_9), .B(L2_5), .C(L2_13), .Sel(Sel_3));
Mux_3_1 M3_8(.Out(L3_8), .A(L2_8), .B(L2_4), .C(L2_12), .Sel(Sel_3));
Mux_3_1 M3_7(.Out(L3_7), .A(L2_7), .B(L2_3), .C(L2_11), .Sel(Sel_3));
Mux_3_1 M3_6(.Out(L3_6), .A(L2_6), .B(L2_2), .C(L2_10), .Sel(Sel_3));
Mux_3_1 M3_5(.Out(L3_5), .A(L2_5), .B(L2_1), .C(L2_9), .Sel(Sel_3));
Mux_3_1 M3_4(.Out(L3_4), .A(L2_4), .B(1'b0), .C(L2_8), .Sel(Sel_3));
Mux_3_1 M3_3(.Out(L3_3), .A(L2_3), .B(1'b0), .C(L2_7), .Sel(Sel_3));
Mux_3_1 M3_2(.Out(L3_2), .A(L2_2), .B(1'b0), .C(L2_6), .Sel(Sel_3));
Mux_3_1 M3_1(.Out(L3_1), .A(L2_1), .B(1'b0), .C(L2_5), .Sel(Sel_3));

//Second layer of MUXes TODO C for SRA
Mux_3_1 M4_16(.Out(Shift_Out[15]), .A(L3_16), .B(L3_8), .C(M4_rot_16), .Sel(Sel_4));
Mux_3_1 M4_15(.Out(Shift_Out[14]), .A(L3_15), .B(L3_7), .C(M4_rot_15), .Sel(Sel_4));
Mux_3_1 M4_14(.Out(Shift_Out[13]), .A(L3_14), .B(L3_6), .C(M4_rot_14), .Sel(Sel_4));
Mux_3_1 M4_13(.Out(Shift_Out[12]), .A(L3_13), .B(L3_5), .C(M4_rot_13), .Sel(Sel_4));
Mux_3_1 M4_12(.Out(Shift_Out[11]), .A(L3_12), .B(L3_4), .C(M4_rot_12), .Sel(Sel_4));
Mux_3_1 M4_11(.Out(Shift_Out[10]), .A(L3_11), .B(L3_3), .C(M4_rot_11), .Sel(Sel_4));
Mux_3_1 M4_10(.Out(Shift_Out[9]), .A(L3_10), .B(L3_2), .C(M4_rot_10), .Sel(Sel_4));
Mux_3_1 M4_9(.Out(Shift_Out[8]), .A(L3_9), .B(L3_1), .C(M4_rot_9), .Sel(Sel_4));
Mux_3_1 M4_8(.Out(Shift_Out[7]), .A(L3_8), .B(1'b0), .C(L3_16), .Sel(Sel_4));
Mux_3_1 M4_7(.Out(Shift_Out[6]), .A(L3_7), .B(1'b0), .C(L3_15), .Sel(Sel_4));
Mux_3_1 M4_6(.Out(Shift_Out[5]), .A(L3_6), .B(1'b0), .C(L3_14), .Sel(Sel_4));
Mux_3_1 M4_5(.Out(Shift_Out[4]), .A(L3_5), .B(1'b0), .C(L3_13), .Sel(Sel_4));
Mux_3_1 M4_4(.Out(Shift_Out[3]), .A(L3_4), .B(1'b0), .C(L3_12), .Sel(Sel_4));
Mux_3_1 M4_3(.Out(Shift_Out[2]), .A(L3_3), .B(1'b0), .C(L3_11), .Sel(Sel_4));
Mux_3_1 M4_2(.Out(Shift_Out[1]), .A(L3_2), .B(1'b0), .C(L3_10), .Sel(Sel_4));
Mux_3_1 M4_1(.Out(Shift_Out[0]), .A(L3_1), .B(1'b0), .C(L3_9), .Sel(Sel_4));

endmodule