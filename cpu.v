module cpu(clk, rst_n, hlt, pc);
input clk, rst_n; //system clock and active LOW reset, causes execution to start at 0x0000

output hlt; //will be asserted when HLT instruction is encountered
output [15:0] pc; //pc value over program execution 

endmodule