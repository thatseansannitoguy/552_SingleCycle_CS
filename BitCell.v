module BitCell(clk, rst, D, WriteEnable, ReadEnabel1, ReadEnable2, Bitline1, Bitline2);

input clk, rst, D, WriteEnable, ReadEnabel1, ReadEnable2;

inout Bitline1, Bitline2;

reg q_2_reg;

dff b_c(.q(q_2_reg), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

assign Bitline1 = (ReadEnabel1) ? q_2_reg : 1'bz;
assign Bitline2 = (ReadEnable2) ? q_2_reg : 1'bz;

endmodule