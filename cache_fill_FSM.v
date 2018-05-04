//Nate Ciske - cache_fill_FSM.v - Also HW#9 - ECE552 UW-Madison
module cache_fill_FSM(clk, rst_n, word_num, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid, word_num);
	
	//Inputs
	input clk, rst_n;
	input miss_detected; // active high when tag match logic detects a miss
	input [15:0] miss_address; // address that missed the cache
	input [15:0] memory_data; // data returned by memory (after  delay)
	input memory_data_valid; // active high indicates valid data returning on memory bus
	
	//Outputs
	output reg fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
	output reg write_data_array; // write enable to cache data array to signal when filling with memory_data
	output reg write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array
	output reg [15:0] memory_address; // address to read from memory
	output reg [2:0] word_num; //word written to in cache
	
	//Params
	localparam ACTIVE = 1'b1;
	localparam NONACTIVE = 1'b0;
	
	//States
	localparam IDLE_0	= 4'b0000;
	localparam WAIT_1  	= 4'b0001;
	localparam WAIT_2  	= 4'b0010;
	localparam WAIT_3  	= 4'b0011;
	localparam WAIT_4  	= 4'b0100;
	localparam WAIT_5  	= 4'b0101;
	localparam WAIT_6  	= 4'b0110;
	localparam WAIT_7  	= 4'b0111;
	localparam WAIT_8  	= 4'b1000;
	
	//Internal Wires
	reg [3:0] next_state;
	wire [3:0] current_state; 
	
	wire [15:0] current_address; 
	wire [15:0] next_address; 
	wire [15:0] temp_address; 
	
	reg [15:0] next_address_final;
	reg [15:0] address_adder; 
	
	reg address_0_en;
	reg address_1_en; 
	
	wire temp_ovfl;
	
	//Address Adder
	CLA_add_16 address_adder_module(
		.Sum(next_address), 
		.Ovfl(temp_ovfl), 
		.A(current_address), 
		.B(address_adder)
	);
	
	//State Machine Counter
	dff FSM_State[3:0](
		.clk(clk), 
		.rst(rst), 
		.d(next_state[3:0]), 
		.q(current_state[3:0]), 
		.wen(1'b1)
	);
	
	//Address Placeholder
	dff address_0[15:0](
		.clk(clk), 
		.rst(rst), 
		.d(next_address_final[15:0]), 
		.q(current_address[15:0]), 
		.wen(address_0_en | miss_detected)
	);
	
	dff address_1[15:0](
		.clk(clk), 
		.rst(rst), 
		.d(next_address[15:0]), 
		.q(temp_address[15:0]), 
		.wen(address_1_en)
	);
	 
	 
	//FSM combinational logic
	always @(*) begin

		fsm_busy = NONACTIVE;
		word_num = 3'h0;
		write_data_array = NONACTIVE;
		write_tag_array = NONACTIVE;
		next_state = 4'h0; 
		address_0_en = NONACTIVE;
		address_1_en = NONACTIVE; 
		address_adder = 16'h0000;
		
		case(current_state)
			IDLE_0: begin
				fsm_busy = miss_detected ? ACTIVE: NONACTIVE;
				memory_address = miss_detected ? miss_address : 16'hxxxx;
				next_address_final = miss_detected ? next_address : temp_address;
				address_adder = 16'h0002;
		
				next_state = miss_detected ? WAIT_1: IDLE_0;
				
			end

			WAIT_1: begin
				fsm_busy = ACTIVE; 
				word_num = 3'h0;
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				next_address_final = next_address;
				memory_address = current_address; 
				address_adder = 16'h0002;
				
				
				next_state = memory_data_valid ? WAIT_2 : WAIT_1;
				
			end
			
			WAIT_2: begin
				fsm_busy = ACTIVE; 
				word_num = 3'h1;
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				next_address_final = next_address;
				memory_address = current_address; 
				address_adder = 16'h0002;
				
				next_state = memory_data_valid ? WAIT_3 : WAIT_2;
				
			end
			
			WAIT_3: begin
				fsm_busy = ACTIVE; 
				word_num = 3'h2; 
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				next_address_final = next_address;
				memory_address = current_address;
				address_adder = 16'h0002;
				
				next_state = memory_data_valid ? WAIT_4 : WAIT_3;
				 
			end
			
			WAIT_4: begin
				fsm_busy = ACTIVE;
				word_num = 3'h3;
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				address_1_en = ACTIVE; 
				next_address_final = next_address;
				memory_address = current_address; 
			
				address_adder = 16'h0002;
				
				next_state = memory_data_valid ? WAIT_5 : WAIT_4;
				 
			end
			
			WAIT_5: begin
				fsm_busy = ACTIVE; 
				word_num = 3'h4;
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				next_address_final = next_address;
				memory_address = current_address;
			
				next_state = memory_data_valid ? WAIT_6 : WAIT_5;
				 
			end
			
			WAIT_6: begin
				fsm_busy = ACTIVE; 
				word_num = 3'h5; 
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				next_address_final = next_address;
				memory_address = current_address;
				
				next_state = memory_data_valid ? WAIT_7 : WAIT_6;
								
			end
			
			WAIT_7: begin
				fsm_busy = ACTIVE; 
				word_num = 3'h6; 
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				next_address_final = next_address;
				memory_address = current_address;
				
				next_state = memory_data_valid ? WAIT_8 : WAIT_7;
				
			end
			
			WAIT_8: begin
				fsm_busy = ACTIVE; 
				word_num = 3'h7; 
				write_data_array = memory_data_valid ? ACTIVE : NONACTIVE;
				write_tag_array = memory_data_valid ? ACTIVE : NONACTIVE;
				address_0_en = memory_data_valid ? ACTIVE : NONACTIVE;
				next_address_final = next_address;
				memory_address = current_address;
				
				next_state = memory_data_valid ? IDLE_0 : WAIT_8;
				
			end

		endcase
			
	end
	
endmodule

