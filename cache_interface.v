// This module is used to interface with corresponding caches and fsm busy handler
module cache_interface(fsm_busy, write_data_array, write_tag_array, data_cache_write, D_miss, I_miss,
							D_addr, D_data, memory_data, I_addr, miss_detected, mem_en, mem_write, D_tag,
							D_enable, I_tag, I_enable, miss_address, mem_data_in, D_new_block,
							I_new_block, clk, rst, I_stall, D_stall);
	// INPUTS
	input clk, rst;				// system clock and reset
	input fsm_busy;				// busy signal from cache state machine
	input write_data_array;		// fsm_write_data
	input write_tag_array;		// fsm_write_tag
	input data_cache_write;		// MEM_MemWrite
	
	//D-mem
	input D_miss;				// Miss signal from D-cache
	input [15:0] D_addr;		// MEM_ALU_result
	input [15:0] D_data;		// MEM_data_write
	
	//I-mem
	input I_miss;				// Miss signal from I-cache
	input [15:0] memory_data;	// data read from memory
	input [15:0] I_addr;		// Current PC value to read instruction
	
	
	// OUTPUTS
	output miss_detected;		// Indicates a D-cache or I-cache miss
	output mem_en;				// High when writing to mem or a cache miss
	output mem_write;	
	output [15:0] miss_address;	// Address that missed
	output [15:0] mem_data_in;	// Data to write to memory
	
	//D-mem
	output D_enable;						// Write enable for D-cache
	output D_tag;							// Write tag for D-cache
	output D_stall;							// D fetch currently in stalling
	output [15:0] D_new_block;				// Data to write to D-cache
	
	//I-mem
	output I_enable;						// Write-enable for I-cache
	output I_tag;							// Write tag for I-cache
	output I_stall;							// I fetch curretnly in stalling
	output [15:0] I_new_block;				// Data to write to I-cache

	// Assign Statements
	//overall assignments
	assign miss_detected = D_miss || I_miss;				//miss detection based on I or D mem miss
	assign miss_address = I_miss ? I_addr : 
							D_addr;		//address of the miss, based on I or D miss assertion
	assign mem_en = fsm_busy;							//if busy, enable mem
	assign mem_data_in = (data_cache_write && D_miss) ? D_data : //D memory data input
							16'hxxxx;	
	assign mem_write = (data_cache_write && ~D_miss && ~I_miss); //D memory write input
	
	//D-mem based assignments
	assign D_tag =  (D_miss && write_tag_array && data_cache_write && ~I_miss); //Times to write D cache tag 
	assign D_enable = (data_cache_write && ~I_miss) ? 1'b1 : 
					(D_miss && write_data_array && ~I_miss); //data write for D cache
					
	assign D_new_block = (write_data_array) ? D_data : 
							(data_cache_write) ? memory_data : 
							D_data;	//if writing, then what block value???
							
	assign D_stall = D_miss; // If a miss, then stall
	
	//I-mem based assignments
	assign I_tag = I_miss && write_tag_array;	//write tag on miss
	assign I_enable = I_miss && write_data_array;	//enable write on a miss
	assign I_new_block = memory_data;	// pulled block
	assign I_stall = I_miss; // If a miss, then stall

endmodule