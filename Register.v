module Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input clk, rst, WriteReg, ReadEnable1, ReadEnable2;
input [15:0] D;

inout [15:0] Bitline1, Bitline2;

BitCell B_C_16(.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));
BitCell B_C_15(.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]));
BitCell B_C_14(.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]));
BitCell B_C_13(.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]));
BitCell B_C_12(.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]));
BitCell B_C_11(.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]));
BitCell B_C_10(.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]));
BitCell B_C_9(.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]));
BitCell B_C_8(.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]));
BitCell B_C_7(.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]));
BitCell B_C_6(.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]));
BitCell B_C_5(.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]));
BitCell B_C_4(.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]));
BitCell B_C_3(.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
BitCell B_C_2(.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
BitCell B_C_1(.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnabel1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));

endmodule 