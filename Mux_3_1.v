module Mux_3_1(Out, A, B, C, Sel);

input[1:0] Sel;
input A, B, C;
output Out;

// (00) A -|\
// (01) A -| |- Out
// (10) B -| |
// (11) C -|/
//          |
//         Sel[1:0]

assign Out = (~Sel[0] & ~Sel[1] & A) |
			(Sel[0] & ~Sel[1] & A) |
			 (~Sel[0]  & Sel[1] & B) |
			 (Sel[0]  & Sel[1] & C);

endmodule