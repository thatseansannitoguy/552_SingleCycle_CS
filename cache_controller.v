//Direct-mapped cache used for both I and D caches
module cache_controller(clk, rst, Address, Data_In, Data_Out, Write_Data_Array, Write_Tag_Array, Read_Enable, Miss, Word_Num);

	// Inputs //
	input clk, rst;
	input Write_Data_Array, Write_Tag_Array;
	input Read_Enable;
	input [2:0] Word_Num;
	input [15:0] Address, Data_In;

	// Outputs //
	output Miss;
	output [15:0] Data_Out;

	// Internal Signals //
	wire [6:0] block_index;
	wire [127:0] block_enable;

	wire [2:0] word_index;
	wire [7:0] word_enable; 
	
	wire [15:0] word_write;
	wire[7:0] word_read; 

	wire [15:0] cache_data;

	wire [7:0] tag_check, tag; 

	// Modules //
	decoder_3_8 word_decoder(.input_3(word_index), .output_8(word_read));
	decoder_7_128 block_decoder(.input_7(block_index), .output_128(block_enable));
	Shifter multi_byte_shifter(.Shift_Out(word_write), .Shift_In(16'h0001), .Shift_Val({1'b0, Word_Num}), .Mode_In(2'b00));	//Mode = SLL, for multi byte writes

	//Meta data array (Valid + tag bits)
	MetaDataArray MetaDataArrayCache (.clk(clk), .rst(rst), .DataIn(tag), .Write(Write_Tag_Array), .BlockEnable(block_enable), .DataOut(tag_check));

	//Data array (cache lines)
	DataArray DataArrayCache (.clk(clk), .rst(rst), .DataIn(Data_In), .Write(Write_Data_Array), .BlockEnable(block_enable), .WordEnable(word_enable), .DataOut(cache_data));	

	// Assignments //
	assign block_index = {Address[8:4],1'b0};	//Byte addressable Block # = (block address) % 128/8, 8 bits of address as block #
	assign word_index = Address[3:1];			//Word select bits are 3 least significant bits of the index
	assign tag = {1'b1, Address[14:8]};			//tag with first bit valid now, tag = address[15:8]

	assign word_enable = Write_Data_Array ? word_write[7:0] : word_read;	//differentiate on word write and reads
	
	assign Miss = Read_Enable ? !(tag == tag_check) : 1'b0;	//logic for a miss, must be reading
	assign Data_Out = Read_Enable ? cache_data : 16'hxxxx;	//logic for output data, must be reading

endmodule