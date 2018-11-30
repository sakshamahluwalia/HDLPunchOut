module overall_vga(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	
	input	  CLOCK_50;			
	input   [9:0]   SW;
	input   [3:0]   KEY;

	wire resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	reg [2:0] colour;
	reg [7:0] x;
	reg [6:0] y;
	reg writeEn;
	

	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	wire [2:0] init_colour;
	wire [7:0] init_x;
	wire [6:0] init_y;
	wire init_writeEn;
	wire [2:0] enemy_colour;
	wire [7:0] enemy_x;
	wire [6:0] enemy_y;
	wire enemy_writeEn;
	
	always @(*)
		begin
			if (!resetn)
				begin
					colour <= 3'b000;
					x <= 8'b0000_0000;
					y <= 7'b000_0000;
					writeEn <= 1'b0
				end
			else if (should_plot)
				begin
					colour <= enemy_colour;
					x <= enemy_x;
					y <= enemy_y
					writeEn <= enemy_writeEn;
				end
			else if (en_enable)
				begin
					colour <= init_colour;
					x <= init_x;
					y <= init_y;
					writeEn <= init_writeEn;
				end
		end

	wire start_project;
	wire const_one = 1'b1;
	wire en_enable = ~(const_one & start_project); //enables initialization function
	wire ecEn; //enables enemy_controller in enemy_meta_controller 
	          //(between meta control and meta datapath;
	wire should_plot;
	wire enemy_x_shift;
	wire enemy_y_shift;
	
	initialization        io(   CLOCK_50, init_writeEn, resetn, en_enable, start_project, init_x, init_y, init_colour);
   enemy_meta_controller emc0( CLOCK_50, resetn, start_project, should_plot, ecEn);
	enemy_data_path       emd0( CLOCK_50, resetn, start_project, should_plot, ecEn, enemy_writeEn, enemy_x_shift, enemy_y_shift);
	write_scene_to_buffer wstb0(CLOCK_50, writeEn, resetn, enemy_x_shift, should_plot, plot_finished, enemy_x, enemy_y, enemy_colour);                    



endmodule

module write_scene_to_buffer(clock, writeEn, reset_n, enemy_x_shift, enable, plot_finished, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	input enemy_x_shift;
	
	output reg plot_finished;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	output reg [2:0] c_out;
	output reg writeEn; 

	reg en_enable;
	
	wire start_left;
	wire start_right;
	//wire start_player;
	wire real_start;
	wire [7:0] enemy_x;
	wire [6:0] enemy_y;
	wire [2:0] enemy_col;
	wire [7:0] player_x;
	wire [6:0] player_y;
	wire [2:0] player_col;
	wire [7:0] left_x;
	wire [6:0] left_y;
	wire [2:0] left_col;
	wire [7:0] right_x;
	wire [6:0] right_y;
	wire [2:0] right_col;
	
	
	always @(*)
		begin
			if (!reset_n)
				begin
					plot_finished <= 1'b1;
					writeEn <= 1'b0;
				end
			else if (real_start)
				begin
					writeEn <= 1'b1;
					plot_finished <= 1'b1;
				end
			else if (start_right)
				begin
					en_enable <= 1'b0;
					x_out <= right_x;
					y_out <= right_y;
					c_out <= right_col;
				end
//			else if (start_player)
//				begin
//					en_enable <= 1'b0;
//					x_out <= player_x;
//					y_out <= player_y;
//					c_out <= player_col;
//				end
			else if (start_left)
				begin
					en_enable <= 1'b0;
					x_out <= left_x;
					y_out <= left_y;
					c_out <= left_col;
				end	
			else if (enable)
				begin
					en_enable <= enable;
					x_out <= enemy_x;
					y_out <= enemy_y;
					c_out <= enemy_col;
					writeEn <= 1'b0;
					plot_finished <= 1'b0;
				end
		end
		
	enemy_pos_tracker(clock, reset_n, en_enable, enemy_x_shift, start_left, enemy_x, enemy_y, enemy_col);
	left_hand_pos_tracker(clock, reset_n, start_left, 8'b0000_0000, start_right, left_x, left_y, left_col);
	//player_pos_tracker(clock, reset_n, start_player, start_right, player_x, player_y, player_col);
	right_hand_pos_tracker(clock, reset_n, start_right, 8'b0000_0000, real_start, right_x, right_y, right_col);

	
endmodule


module enemy_pos_tracker(clock, reset_n, enable, x_pos_change,
								 start_next, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	input x_pos_change;
	
	output reg start_next;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [11:0] counter;
	reg [10:0] address_counter;
	
	reg [7:0] base_x;
	reg [6:0] base_y;
	
	back	back_inst (
			.address(address_counter),
			.clock(clock),
			.data(3'b111),
			.wren(1'b0),
			.q(c_out)
	);
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b0;

					end
				else if (counter == 12'b100111100111)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b1;
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[11:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end
	
	always @(posedge clock)
		begin
			if (enable)
				begin
					if (!reset_n)
						base_x <= 8'b00010100;
					// TODO FIND NUMBERS
					else
						base_x <= x_pos_change;
				end
		end
		
	always @(posedge clock)
		begin
			if (enable)
				begin
					if (!reset_n)
						base_y <= 7'b000_0110;
					else
						base_y <= 7'b000_0110;
				end
		end
	assign x_out = base_x + counter[5:0];
	assign y_out = base_y + counter[11:6];
	
endmodule

module left_hand_pos_tracker(clock, reset_n, enable, y_pos_change,
								 start_next, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	input y_pos_change;
	
	output reg start_next;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [11:0] counter;
	reg [10:0] address_counter;
	
	reg [7:0] base_x;
	reg [6:0] base_y;
	
	back	back_inst (
			.address(address_counter),
			.clock(clock),
			.data(3'b111),
			.wren(1'b0),
			.q(c_out)
	);
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b0;

					end
				else if (counter == 12'b100111100111)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b1;
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[11:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end
	
	always @(posedge clock)
		begin
			if (enable)
				begin
					if (!reset_n)
						base_x <= 8'b00010100;
					// TODO FIND NUMBERS
					else
						base_x <= 8'b00010100;
				end
		end
		
	always @(posedge clock)
		begin
			if (enable)
				begin
					if (!reset_n)
						base_y <= 7'b100_0110;
					else
						base_y <= 7'b100_0110;
				end
		end
	assign x_out = base_x + counter[5:0];
	assign y_out = base_y + counter[11:6];
	
endmodule

module right_hand_pos_tracker(clock, reset_n, enable, y_pos_change,
								 start_next, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	input y_pos_change;
	
	output reg start_next;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [11:0] counter;
	reg [10:0] address_counter;
	
	reg [7:0] base_x;
	reg [6:0] base_y;
	
	back	back_inst (
			.address(address_counter),
			.clock(clock),
			.data(3'b111),
			.wren(1'b0),
			.q(c_out)
	);
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b0;

					end
				else if (counter == 12'b100111100111)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b1;
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[11:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end
	
	always @(posedge clock)
		begin
			if (enable)
				begin
					if (!reset_n)
						base_x <= 8'b01100100;
					// TODO FIND NUMBERS
					else
						base_x <= 8'b01100100;
				end
		end
		
	always @(posedge clock)
		begin
			if (enable)
				begin
					if (!reset_n)
						base_y <= 7'b100_0110;
					else
						base_y <= 7'b100_0110;
				end
		end
	assign x_out = base_x + counter[5:0];
	assign y_out = base_y + counter[11:6];
	
endmodule

//module player_pos_tracker(clock, reset_n, y_pos_change, main_player_curr_x);
//		input clock;
//	input reset_n;
//	input enable;
//	input y_pos_change;
//	
//	output reg start_next;
//	output [7:0] x_out;
//	output [6:0] y_out;
//	output [2:0] c_out;
//	
//	reg [11:0] counter;
//	reg [10:0] address_counter;
//	
//	reg [7:0] base_x;
//	reg [6:0] base_y;
//	
//	back	back_inst (
//			.address(address_counter),
//			.clock(clock),
//			.data(3'b111),
//			.wren(1'b0),
//			.q(c_out)
//	);
//	
//	always @(posedge clock)
//		begin
//			if (enable)
//				begin
//				if (!reset_n)
//					begin
//						counter <= 12'b0000_0000_0000;
//						address_counter <= 11'b000_0000_0000;
//						start_next <= 1'b0;
//
//					end
//				else if (counter == 12'b100111100111)
//					begin
//						counter <= 12'b0000_0000_0000;
//						address_counter <= 11'b000_0000_0000;
//						start_next <= 1'b1;
//			
//					end
//				else if (counter[5:0] == 6'b100111)
//					begin
//						counter <= {counter[11:6] + 1'b1, 6'b000000};
//						address_counter <= address_counter + 1'b1;
//					end	
//				else
//					begin
//						counter <= counter + 1'b1;
//						address_counter <= address_counter + 1'b1; 
//					end
//				end
//		end
//	
//	always @(posedge clock)
//		begin
//			if (enable)
//				begin
//					if (!reset_n)
//						base_x <= 8'b00111100;
//					// TODO FIND NUMBERS
//					else
//						base_x <= 8'b00111100;
//				end
//		end
//		
//	always @(posedge clock)
//		begin
//			if (enable)
//				begin
//					if (!reset_n)
//						base_y <= 7'b100_0110;
//					else
//						base_y <= 7'b100_0110;
//				end
//		end
//	assign x_out = base_x + counter[5:0];
//	assign y_out = base_y + counter[11:6];
//	
//endmodule

module initialization(clock, writeEn, reset_n, enable, start_project, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	
	output reg start_project;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	output reg [2:0] c_out;
	output reg writeEn;
	
	reg en_enable;
	
	wire start_left;
	wire start_right;
	wire start_player;
	wire real_start;
	wire [7:0] enemy_x;
	wire [6:0] enemy_y;
	wire [2:0] enemy_col;
	wire [7:0] player_x;
	wire [6:0] player_y;
	wire [2:0] player_col;
	wire [7:0] left_x;
	wire [6:0] left_y;
	wire [2:0] left_col;
	wire [7:0] right_x;
	wire [6:0] right_y;
	wire [2:0] right_col;
	
	
	always @(*)
		begin
			if (!reset_n)
				begin
					start_project <= 1'b0;
					writeEn <= 1'b0;
				end
			else if (real_start)
				begin
					start_project <= 1'b1;
					writeEn <= 1'b1;
				end
			else if (start_right)
				begin
					en_enable <= 1'b0;
					x_out <= right_x;
					y_out <= right_y;
					c_out <= right_col;
				end
			else if (start_player)
				begin
					en_enable <= 1'b0;
					x_out <= player_x;
					y_out <= player_y;
					c_out <= player_col;
				end
			else if (start_left)
				begin
					en_enable <= 1'b0;
					x_out <= left_x;
					y_out <= left_y;
					c_out <= left_col;
				end	
			else if (enable)
				begin
					en_enable <= enable;
					x_out <= enemy_x;
					y_out <= enemy_y;
					c_out <= enemy_col;
				end
			
		end
	initialize_enemy(clock, reset_n, en_enable, start_left, enemy_x, enemy_y, enemy_col);
	initialize_left(clock, reset_n, start_left, start_player, left_x, left_y, left_col);
	initialize_player(clock, reset_n, start_player, start_right, player_x, player_y, player_col);
	initialize_right(clock, reset_n, start_right, real_start, right_x, right_y, right_col);

	
endmodule

module initialize_enemy(clock, reset_n, enable, start_next, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output reg start_next;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [11:0] counter;
	reg [10:0] address_counter;
	
	back	back_inst (
			.address(address_counter),
			.clock(clock),
			.data(3'b111),
			.wren(1'b0),
			.q(c_out)
	);
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b0;

					end
				else if (counter == 12'b100111100111)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b1;
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[11:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end

	assign x_out = 8'b0000_1100 + counter[5:0];
	assign y_out = 7'b000_0110 + counter[11:6];
	
	
endmodule


module initialize_player(clock, reset_n, enable, start_next, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output reg start_next;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [11:0] counter;
	reg [10:0] address_counter;
	
	back	back_inst (
			.address(address_counter),
			.clock(clock),
			.data(3'b111),
			.wren(1'b0),
			.q(c_out)
	);
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b0;

					end
				else if (counter == 12'b100111100111)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b1;
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[11:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end

	assign x_out = 8'b0010_1000 + counter[5:0];
	assign y_out = 7'b100_0110 + counter[11:6];
	
	
endmodule

module initialize_left(clock, reset_n, enable, start_next, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output reg start_next;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [11:0] counter;
	reg [10:0] address_counter;
	
	back	back_inst (
			.address(address_counter),
			.clock(clock),
			.data(3'b111),
			.wren(1'b0),
			.q(c_out)
	);
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b0;

					end
				else if (counter == 12'b100111100111)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b1;
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[11:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end

	assign x_out = 8'b0000_0000 + counter[5:0];
	assign y_out = 7'b100_0110 + counter[11:6];
	
	
endmodule

module initialize_right(clock, reset_n, enable, start_next, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output reg start_next;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [11:0] counter;
	reg [10:0] address_counter;
	
	back	back_inst (
			.address(address_counter),
			.clock(clock),
			.data(3'b111),
			.wren(1'b0),
			.q(c_out)
	);
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b0;

					end
				else if (counter == 12'b100111100111)
					begin
						counter <= 12'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						start_next <= 1'b1;
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[11:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end

	assign x_out = 8'b0101_0000 + counter[5:0];
	assign y_out = 7'b100_0110 + counter[11:6];
	
	
endmodule



	

module counter(clock, reset_n, out);

	input clock;
	input reset_n;
	output reg [7:0] out;
	
	always @(posedge clock)
	begin
		if (!reset_n)
			begin
				out <= 8'b0;
			end
		else
			out <= out + 1'b1;
	end
			
endmodule