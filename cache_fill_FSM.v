//Nate Ciske - cache_fill_FSM.v - Also HW#9 - ECE552 UW-Madison
module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid);
	
	//Inputs
	input clk, rst_n;
	input miss_detected; // active high when tag match logic detects a miss
	input [15:0] miss_address; // address that missed the cache
	input [15:0] memory_data; // data returned by memory (after  delay)
	input memory_data_valid; // active high indicates valid data returning on memory bus
	
	//Outputs
	output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
	output write_data_array; // write enable to cache data array to signal when filling with memory_data
	output write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array
	output [15:0] memory_address; // address to read from memory
	
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
	wire [3:0] current_state, next_state; 
	
	wire [15:0] current_data1, next_data1;
	wire [15:0] current_data2, next_data2;
	wire [15:0] current_data3, next_data3;
	wire [15:0] current_data4, next_data4;
	wire [15:0] current_data5, next_data5;
	wire [15:0] current_data6, next_data6;
	wire [15:0] current_data7, next_data7;
	wire [15:0] current_data8, next_data8;
	wire [15:0] current_address, next_address;
	
	wire en1;
	wire en2;
	wire en3;
	wire en4;
	wire en5;
	wire en6;
	wire en7;
	wire en8;

	wire temp_ovfl;
	
	//Modules (Registers)
	CLA_add_16 address_adder(
		.Sum(next_address), 
		.Ovfl(temp_ovfl), 
		.A(current_address), 
		.B(16'h0002)
	);
	
	4_bit_state state_machine_reg(
		.next_data(next_state), 
		.clk(clk), 
		.rst(~rst_n), 
		.en(rst_n), 
		.current_data(current_state)
	);

	4_bit_state data_1_reg(
		.next_data(next_data1),
		.clk(clk),
		.rst(~rst_n),
		.en(en1),
		.current_data(current_data1)
	);
	
	4_bit_state data_2_reg(
		.next_data(next_data2),
		.clk(clk),
		.rst(~rst_n),
		.en(en2),
		.current_data(current_data2)
	);
	
	4_bit_state data_3_reg(
		.next_data(next_data3),
		.clk(clk),
		.rst(~rst_n),
		.en(en3),
		.current_data(current_data3)
	);
	
	4_bit_state data_4_reg(
		.next_data(next_data4),
		.clk(clk),
		.rst(~rst_n),
		.en(en4),
		.current_data(current_data4)
	);
	
	4_bit_state data_5_reg(
		.next_data(next_data5),
		.clk(clk),
		.rst(~rst_n),
		.en(en5),
		.current_data(current_data5)
	);
	
	4_bit_state data_6_reg(
		.next_data(next_data6),
		.clk(clk),
		.rst(~rst_n),
		.en(en6),
		.current_data(current_data6)
	);
	
	4_bit_state data_7_reg(
		.next_data(next_data7),
		.clk(clk),
		.rst(~rst_n),
		.en(en7),
		.current_data(current_data7)
	);
	
	4_bit_state data_8_reg(
		.next_data(next_data8),
		.clk(clk),
		.rst(~rst_n),
		.en(en8),
		.current_data(current_data8)
	);
	
	//FSM combinational logic
	always @(*) begin

		address_new = 16'h0000;
		fsm_busy = NONACTIVE;
		write_data_array = NONACTIVE;
		next_state = IDLE_0;
		
		en1 = NONACTIVE;
		en2 = NONACTIVE;
		en3 = NONACTIVE;
		en4 = NONACTIVE;
		en5 = NONACTIVE;
		en6 = NONACTIVE;
		en7 = NONACTIVE;
		en8 = NONACTIVE;
	
		case(current_state)
			IDLE_0: begin
				fsm_busy = miss_detected ? ACTIVE: NONACTIVE;
				memory_address[15:0] = (miss_detected) ? miss_address[15:0]: 16'h0000;
				address_current = miss_detected ? miss_address[15:0]: 16'h0000;
				write_data_array = miss_detected ? ACTIVE: NONACTIVE;
				next_state = miss_detected ? WAIT1: IDLE_0;
			end

			WAIT_1: begin
				en1 = ACTIVE;
				next_data1[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = next_address;
				current_address = next_address;
				next_state = WAIT_2;
			end
			
			WAIT_2: begin
				en1 = ACTIVE;
				next_data1[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = next_address;
				current_address = next_address;
				next_state = WAIT_2;
			end
			
			WAIT_3: begin
				en1 = ACTIVE;
				next_data1[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = next_address;
				current_address = next_address;
				next_state = WAIT_2;
			end
			
			WAIT_4: begin
				en1 = ACTIVE;
				next_data1[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = next_address;
				current_address = next_address;
				next_state = WAIT_2;
			end
			
			WAIT_5: begin
				en1 = ACTIVE;
				next_data1[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = next_address;
				current_address = next_address;
				next_state = WAIT_2;
			end
			
			WAIT_6: begin
				en1 = ACTIVE;
				next_data1[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = next_address;
				current_address = next_address;
				next_state = WAIT_2;
			end
			
			WAIT_7: begin
				en1 = ACTIVE;
				next_data1[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = next_address;
				current_address = next_address;
				next_state = WAIT_2;
			end
			
			WAIT_8: begin
				en8 = ACTIVE;
				next_data8[15:0] = 16{memory_data_valid} | memory_data[15:0];
				memory_address = 16'h0000;
				current_address = 16'h0000;
				next_state = IDLE_0;
			end

		endcase
			
	end
	
endmodule

module 4_bit_state (next_data, clk, rst, en, current_data)
	input [15:0] next_data;
	input clk, rst, en; 
	
	output [15:0] current_data; 
	
	dff dff0(.q(current_data[0]), .d(next_data[0]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[1]), .d(next_data[1]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[2]), .d(next_data[2]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[3]), .d(next_data[3]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[4]), .d(next_data[4]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[5]), .d(next_data[5]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[6]), .d(next_data[6]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[7]), .d(next_data[7]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[8]), .d(next_data[8]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[9]), .d(next_data[9]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[10]), .d(next_data[10]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[11]), .d(next_data[11]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[12]), .d(next_data[12]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[13]), .d(next_data[13]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[14]), .d(next_data[14]), .wen(en), .clk(clk), .rst(rst);
	dff dff0(.q(current_data[15]), .d(next_data[15]), .wen(en), .clk(clk), .rst(rst);	
	
endmodule