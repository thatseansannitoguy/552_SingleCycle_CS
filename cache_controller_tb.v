//Simple cache tb to test writing and reading to same locations
module cache_tb ();
	
	// Inputs //
	reg clk, rst, Read_Enable, Write_Data_Array, Write_Tag_Array;
	reg [2:0] Word_Num;
	reg [15:0] Address, Data_In;
	
	// Outputs //
	wire [15:0] Data_Out;
	wire Miss;

	// Loop Var //
	integer i;
	
	// cache_controller DUT
	cache_controller DUT (.clk(clk), .rst(rst), .Address(Address), .Data_In(Data_In), .Data_Out(Data_Out), .Write_Data_Array(Write_Data_Array), 
				.Write_Tag_Array(Write_Tag_Array), .Read_Enable(Read_Enable), .Miss(Miss), .Word_Num(Word_Num));

	initial begin

	// Fresh reset of cache and data
	clk = 0;
	rst = 1;
	
	Read_Enable = 0;
	Write_Data_Array = 0;
	Write_Tag_Array = 0;
	Word_Num = 3'h0;
	
	Address = 16'h0000;
	Data_In = 16'h0000;
	
	i=0;
	
	#10;

	rst = 0;
	
	#10;

	// Cache Loop Write
	Address = 16'h0800;
	
	for(i=0; i<8; i=i+1) begin
		Data_In = Data_In + 1;
		Write_Tag_Array = (i > 0) ? 0 : 1;
		Write_Data_Array = 1;
		Word_Num = (i > 0) ? Word_Num + 1 : 3'h0;
		#10;
	end

	// Cache Loop Read
	Write_Data_Array = 0;
	Address = 16'h0800;
	
	for(i=0; i<8; i=i+1) begin
		Address = (i > 0) ? Address + 1 : Address;
		Read_Enable = 1;
		#10;
	end

	#10;

	$stop();

end

// Clock logic for TB
always
	#5 clk = ~clk;


endmodule