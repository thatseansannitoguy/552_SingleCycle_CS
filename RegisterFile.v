module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);

input clk, rst, WriteReg;
input [3:0] SrcReg1, SrcReg2, DstReg;
input [15:0] DstData;

inout [15:0] SrcData1, SrcData2;

wire [15:0] dec_src_reg1, dec_src_reg2, dec_dst_reg, temp1, temp2;

ReadDecoder_4_16 Dec_SrcReg1(.RegId(SrcReg1), .Wordline(dec_src_reg1));
ReadDecoder_4_16 Dec_SrcReg2(.RegId(SrcReg2), .Wordline(dec_src_reg2));

WriteDecoder_4_16 Dec_DstReg(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(dec_dst_reg));

Register R16(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[15]), .ReadEnable1(dec_src_reg1[15]), .ReadEnable2(dec_src_reg2[15]), .Bitline1(temp1), .Bitline2(temp2));
Register R15(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[14]), .ReadEnable1(dec_src_reg1[14]), .ReadEnable2(dec_src_reg2[14]), .Bitline1(temp1), .Bitline2(temp2));
Register R14(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[13]), .ReadEnable1(dec_src_reg1[13]), .ReadEnable2(dec_src_reg2[13]), .Bitline1(temp1), .Bitline2(temp2));
Register R13(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[12]), .ReadEnable1(dec_src_reg1[12]), .ReadEnable2(dec_src_reg2[12]), .Bitline1(temp1), .Bitline2(temp2));
Register R12(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[11]), .ReadEnable1(dec_src_reg1[11]), .ReadEnable2(dec_src_reg2[11]), .Bitline1(temp1), .Bitline2(temp2));
Register R11(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[10]), .ReadEnable1(dec_src_reg1[10]), .ReadEnable2(dec_src_reg2[10]), .Bitline1(temp1), .Bitline2(temp2));
Register R10(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[9]), .ReadEnable1(dec_src_reg1[9]), .ReadEnable2(dec_src_reg2[9]), .Bitline1(temp1), .Bitline2(temp2));
Register R9(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[8]), .ReadEnable1(dec_src_reg1[8]), .ReadEnable2(dec_src_reg2[8]), .Bitline1(temp1), .Bitline2(temp2));
Register R8(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[7]), .ReadEnable1(dec_src_reg1[7]), .ReadEnable2(dec_src_reg2[7]), .Bitline1(temp1), .Bitline2(temp2));
Register R7(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[6]), .ReadEnable1(dec_src_reg1[6]), .ReadEnable2(dec_src_reg2[6]), .Bitline1(temp1), .Bitline2(temp2));
Register R6(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[5]), .ReadEnable1(dec_src_reg1[5]), .ReadEnable2(dec_src_reg2[5]), .Bitline1(temp1), .Bitline2(temp2));
Register R5(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[4]), .ReadEnable1(dec_src_reg1[4]), .ReadEnable2(dec_src_reg2[4]), .Bitline1(temp1), .Bitline2(temp2));
Register R4(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[3]), .ReadEnable1(dec_src_reg1[3]), .ReadEnable2(dec_src_reg2[3]), .Bitline1(temp1), .Bitline2(temp2));
Register R3(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[2]), .ReadEnable1(dec_src_reg1[2]), .ReadEnable2(dec_src_reg2[2]), .Bitline1(temp1), .Bitline2(temp2));
Register R2(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[1]), .ReadEnable1(dec_src_reg1[1]), .ReadEnable2(dec_src_reg2[1]), .Bitline1(temp1), .Bitline2(temp2));
Register R1(.clk(clk), .rst(rst), .D(DstData), .WriteReg(dec_dst_reg[0]), .ReadEnable1(dec_src_reg1[0]), .ReadEnable2(dec_src_reg2[0]), .Bitline1(temp1), .Bitline2(temp2));

assign SrcData1 = temp1; //(SrcReg1 == DstReg) ? DstData : 
assign SrcData2 = temp2; //(SrcReg2 == DstReg) ? DstData : 


endmodule