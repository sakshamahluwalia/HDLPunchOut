//module overall_vga(
//		CLOCK_50,						//	On Board 50 MHz
//		// Your inputs and outputs here
//        KEY,
//        SW,
//		// The ports below are for the VGA output.  Do not change.
//		VGA_CLK,   						//	VGA Clock
//		VGA_HS,							//	VGA H_SYNC
//		VGA_VS,							//	VGA V_SYNC
//		VGA_BLANK_N,						//	VGA BLANK
//		VGA_SYNC_N,						//	VGA SYNC
//		VGA_R,   						//	VGA Red[9:0]
//		VGA_G,	 						//	VGA Green[9:0]
//		VGA_B   						//	VGA Blue[9:0]
//	);
//	
//	input	  CLOCK_50;			
//	input   [9:0]   SW;
//	input   [3:0]   KEY;
//
//	wire resetn = KEY[0];
//
//	// Create the colour, x, y and writeEn wires that are inputs to the controller.
//	reg [2:0] colour;
//	reg [7:0] x;
//	reg [6:0] y;
//	reg writeEn;
//	
//
//	// Do not change the following outputs
//	output			VGA_CLK;   				//	VGA Clock
//	output			VGA_HS;					//	VGA H_SYNC
//	output			VGA_VS;					//	VGA V_SYNC
//	output			VGA_BLANK_N;				//	VGA BLANK
//	output			VGA_SYNC_N;				//	VGA SYNC
//	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
//	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
//	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
//	
//	vga_adapter VGA(
//			.resetn(resetn),
//			.clock(CLOCK_50),
//			.colour(colour),
//			.x(x),
//			.y(y),
//			.plot(writeEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "black.mif";
//		
//	wire [2:0] init_colour;
//	wire [7:0] init_x;
//	wire [6:0] init_y;
//	wire init_writeEn;
//	wire [2:0] enemy_colour;
//	wire [7:0] enemy_x;
//	wire [6:0] enemy_y;
//	wire enemy_writeEn;
//	
//	always @(*)
//		begin
//			if (!resetn)
//				begin
//					colour <= 3'b000;
//					x <= 8'b0000_0000;
//					y <= 7'b000_0000;
//					writeEn <= 1'b0;
//				end
////			else if (should_plot)
////				begin
////					colour <= enemy_colour;
////					x <= enemy_x;
////					y <= enemy_y;
////					writeEn <= enemy_writeEn;
////				end
//			else if (en_enable)
//				begin
//					colour <= init_colour;
//					x <= init_x;
//					y <= init_y;
//					writeEn <= init_writeEn;
//				end
//		end
//
//	wire start_project;
//	wire const_one = 1'b1;
//	wire en_enable; //enables initialization function
//	wire ecEn; //enables enemy_controller in enemy_meta_controller 
//	          //(between meta control and meta datapath;
//	wire should_plot;
//	wire enemy_x_shift;
//	wire enemy_y_shift;
//	wire plot_finished;
//	wire start_plot;
//	
//	wire [1:0] x_shift;
//	FrameRateDivider frd0(1'b1, CLOCK_50, resetn, en_enable);
//	lfsr lfsr0(
//			.clock(CLOCK_50),
//			.reset_n(resetn),
//			.enable(1'b1),
//			.counter_val(8'b10110101),
//			.random_pos(x_shift)
//	);
//	
//	initialization        io(  x_shift, CLOCK_50, init_writeEn, resetn, en_enable, start_project, init_x, init_y, init_colour);
//// enemy_meta_controller emc0( CLOCK_50, resetn, start_project, plot_finished, should_plot, ecEn);
////	enemy_meta_datapath   emd0( CLOCK_50, resetn, start_project, should_plot, ecEn, enemy_writeEn, enemy_x_shift, enemy_y_shift, start_plot);
//   
//	
//	//write_scene_to_buffer wstb0(CLOCK_50, start_plot, resetn, 8'b01010100, 1'b1, plot_finished, enemy_x, enemy_y, enemy_colour);                    
//
//
//
//endmodule
//
//module FrameRateDivider(enable, clock, reset_n, out_enable);
//	input enable;
//	input clock, reset_n;
//	output reg out_enable;
//	
//	reg [27:0] out;
//	
//	wire frame_rate = 28'b1011111010111100001000000000;
//	
//	always @(posedge clock)
//	begin
//		if (!reset_n)
//			begin
//				out <= frame_rate;
//				out_enable <= 1'b0;
//			end
//		else if (enable == 1'b1)
//			begin
//				if (out == 1'b0)
//					begin
//						out <= frame_rate;
//						out_enable <= 1'b1;
//					end
//				else
//					begin
//						out <= out - 1'b1;
//						out_enable <= 1'b0;
//					end
//			end
//	end
//		
//endmodule
//
////
//
//module initialization(x_shift, clock, writeEn, reset_n, enable, start_project, x_out, y_out, c_out);
//	input clock;
//	input reset_n;
//	input enable;
//	input [1:0] x_shift;
//	
//	
//	output reg start_project;
//	output reg [7:0] x_out;
//	output reg [6:0] y_out;
//	output reg [2:0] c_out;
//	output reg writeEn;
//	
//	reg en_enable;
//	reg left_enable;
//	reg right_enable;
//	reg player_enable;
//	
//	wire start_left;
//	wire start_right;
//	wire start_player;
//	wire real_start;
//	wire [7:0] enemy_x;
//	wire [6:0] enemy_y;
//	wire [2:0] enemy_col;
//	wire [7:0] player_x;
//	wire [6:0] player_y;
//	wire [2:0] player_col;
//	wire [7:0] left_x;
//	wire [6:0] left_y;
//	wire [2:0] left_col;
//	wire [7:0] right_x;
//	wire [6:0] right_y;
//	wire [2:0] right_col;
//	
//	
//	always @(*)
//		begin
//			if (!reset_n)
//				begin
//					start_project <= 1'b0;
//					writeEn <= 1'b0;
//				end
//			else if (real_start)
//				begin
//					start_project <= 1'b1;
//					right_enable <= 1'b0;
//					writeEn <= 1'b1;
//				end
//			else if (start_right)
//				begin
//					en_enable <= 1'b0;
//					player_enable <= 1'b0;
//					right_enable <= 1'b1;
//					x_out <= right_x;
//					y_out <= right_y;
//					c_out <= right_col;
//					writeEn <= 1'b0;
//				end
//			else if (start_player)
//				begin
//					en_enable <= 1'b0;
//					left_enable <= 1'b0;
//					player_enable <= 1'b1;
//					x_out <= player_x;
//					y_out <= player_y;
//					c_out <= player_col;
//					writeEn <= 1'b0;
//				end
//			else if (start_left)
//				begin
//					en_enable <= 1'b0;
//					left_enable <= 1'b1;
//					x_out <= left_x;
//					y_out <= left_y;
//					c_out <= left_col;
//					writeEn <= 1'b0;
//				end	
//			else if (enable)
//				begin
//					en_enable <= enable;
//					x_out <= enemy_x;
//					y_out <= enemy_y;
//					c_out <= enemy_col;
//					writeEn <= 1'b0;
//				end
//			
//		end
//	initialize_enemy ie(clock, reset_n, en_enable, start_left, enemy_x, enemy_y, enemy_col);
//	initialize_left il(clock, reset_n, left_enable, start_player, left_x, left_y, left_col);
//	initialize_player ip(clock, reset_n, player_enable, start_right, player_x, player_y, player_col);
//	initialize_right ir(clock, reset_n, right_enable, real_start, right_x, right_y, right_col);
////always @(*)
////		begin
////			if (!reset_n)
////				begin
////					start_project <= 1'b0;
////					writeEn <= 1'b0;
////				end
////			else if (real_start)
////				begin
////					start_project <= 1'b1;
////					writeEn <= 1'b1;
////				end
////			else if (start_right)
////				begin
////					en_enable <= 1'b0;
////					x_out <= right_x;
////					y_out <= right_y;
////					c_out <= right_col;
////				end
////			else if (start_player)
////				begin
////					en_enable <= 1'b0;
////					x_out <= player_x;
////					y_out <= player_y;
////					c_out <= player_col;
////				end
////			else if (start_left)
////				begin
////					en_enable <= 1'b0;
////					x_out <= left_x;
////					y_out <= left_y;
////					c_out <= left_col;
////				end	
////			else if (enable)
////				begin
////					en_enable <= enable;
////					x_out <= enemy_x;
////					y_out <= enemy_y;
////					c_out <= enemy_col;
////				end
////			
////		end
////	initialize_enemy ie(x_shift, clock, reset_n, en_enable, start_left, enemy_x, enemy_y, enemy_col);
////	initialize_left il(clock, reset_n, start_left, start_player, left_x, left_y, left_col);
////	initialize_player ip(clock, reset_n, start_player, start_right, player_x, player_y, player_col);
////	initialize_right ir(clock, reset_n, start_right, real_start, right_x, right_y, right_col);
//
//	
//endmodule
//
//module initialize_enemy(x_shift, clock, reset_n, enable, start_next, x_out, y_out, c_out);
//	input clock;
//	input reset_n;
//	input enable;
//	input [1:0] x_shift;
//	
//	output reg start_next;
//	output [7:0] x_out;
//	output [6:0] y_out;
//	output [2:0] c_out;
//	
//	reg [10:0] counter;
//	reg [10:0] address_counter;
//	
//	reg [7:0] base_x;
//	
//	boxer	boxer_inst (
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
//						counter <= 11'b0000_0000_0000;
//						address_counter <= 11'b000_0000_0000;
//						start_next <= 1'b0;
//
//					end
//				else if (counter == 11'b11110100111)
//					begin
//						counter <= 11'b0000_0000_0000;
//						address_counter <= 11'b000_0000_0000;
//						start_next <= 1'b1;
//			
//					end
//				else if (counter[5:0] == 6'b100111)
//					begin
//						counter <= {counter[10:6] + 1'b1, 6'b000000};
//						address_counter <= address_counter + 1'b1;
//					end	
//				else
//					begin
//						counter <= counter + 1'b1;
//						address_counter <= address_counter + 1'b1; 
//					end
//				end
//			else
//				start_next <= 1'b0;
//		end
//
//	always @(*)
//		begin
//			if (!reset_n)
//				begin
//					base_x <= 8'b0000_0000;
//				end
//			if (enable)
//				begin
//					if (x_shift % 3 == 0)
//						base_x <= 8'b0000_0000;
//					else if (x_shift % 3 == 1)
//						base_x <= 8'b0000_1100;
//					else if (x_shift % 3 == 2)
//						base_x <= 8'b0101_0000;
//				end
//		end
//	assign x_out = base_x + counter[5:0];
//	assign y_out = 7'b000_0110 + counter[10:6];
//	
//	
//endmodule
//
//
//module initialize_player(clock, reset_n, enable, start_next, x_out, y_out, c_out);
//	input clock;
//	input reset_n;
//	input enable;
//	
//	output reg start_next;
//	output [7:0] x_out;
//	output [6:0] y_out;
//	output [2:0] c_out;
//	
//	reg [10:0] counter;
//	reg [10:0] address_counter;
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
//						counter <= 11'b000_0000_0000;
//						address_counter <= 11'b000_0000_0000;
//						start_next <= 1'b0;
//
//					end
//				else if (counter == 11'b11110100111)
//					begin
//						counter <= 11'b000_0000_0000;
//						address_counter <= 11'b000_0000_0000;
//						start_next <= 1'b1;
//			
//					end
//				else if (counter[5:0] == 6'b100111)
//					begin
//						counter <= {counter[10:6] + 1'b1, 6'b000000};
//						address_counter <= address_counter + 1'b1;
//					end	
//				else
//					begin
//						counter <= counter + 1'b1;
//						address_counter <= address_counter + 1'b1; 
//					end
//				end
//			else
//				start_next <= 1'b0;
//		end
//
//	assign x_out = 8'b0010_1000 + counter[5:0];
//	assign y_out = 7'b100_0110 + counter[10:6];
//	
//	
//endmodule
//
//module initialize_left(clock, reset_n, enable, start_next, x_out, y_out, c_out);
//	input clock;
//	input reset_n;
//	input enable;
//	
//	output reg start_next;
//	output [7:0] x_out;
//	output [6:0] y_out;
//	output [2:0] c_out;
//	
//	reg [8:0] counter;
//	reg [8:0] address_counter;
//	
//	glove	glove_inst (
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
//						counter <= 9'b0_0000_0000;
//						address_counter <= 9'b0_0000_0000;
//						start_next <= 1'b0;
//
//					end
//				else if (counter == 9'b111110100)
//					begin
//						counter <= 9'b0_0000_0000;
//						address_counter <= 9'b0_0000_0000;
//						start_next <= 1'b1;
//			
//					end
//				else if (counter[4:0] == 5'b10100)
//					begin
//						counter <= {counter[8:5] + 1'b1, 5'b00000};
//						address_counter <= address_counter + 1'b1;
//					end	
//				else
//					begin
//						counter <= counter + 1'b1;
//						address_counter <= address_counter + 1'b1; 
//					end
//				end
//			else
//				start_next <= 1'b0;
//		end
//
//	assign x_out = 8'b0000_0000 + counter[4:0];
//	assign y_out = 7'b100_0110 + counter[8:5];
//	
//	
//endmodule
//
//module initialize_right(clock, reset_n, enable, start_next, x_out, y_out, c_out);
//	input clock;
//	input reset_n;
//	input enable;
//	
//	output reg start_next;
//	output [7:0] x_out;
//	output [6:0] y_out;
//	output [2:0] c_out;
//	
//	reg [8:0] counter;
//	reg [8:0] address_counter;
//	
//	right_glove	right_glove_inst (
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
//						counter <= 9'b0_0000_0000;
//						address_counter <= 9'b0_0000_0000;
//						start_next <= 1'b0;
//
//					end
//				else if (counter == 9'b111110100)
//					begin
//						counter <= 9'b0_0000_0000;
//						address_counter <= 9'b0_0000_0000;
//						start_next <= 1'b1;
//			
//					end
//				else if (counter[4:0] == 5'b10100)
//					begin
//						counter <= {counter[8:5] + 1'b1, 5'b00000};
//						address_counter <= address_counter + 1'b1;
//					end	
//				else
//					begin
//						counter <= counter + 1'b1;
//						address_counter <= address_counter + 1'b1; 
//					end
//				end
//			else
//				start_next <= 1'b0;
//		end
//
//	assign x_out = 8'b0101_0000 + counter[4:0];
//	assign y_out = 7'b100_0110 + counter[8:5];
//	
//	
//endmodule
//
//
//
//	
//
////module counter(clock, reset_n, out);
////
////	input clock;
////	input reset_n;
////	output reg [7:0] out;
////	
////	always @(posedge clock)
////	begin
////		if (!reset_n)
////			begin
////				out <= 8'b0;
////			end
////		else
////			out <= out + 1'b1;
////	end
////			
////endmodule
////
////module enemy_meta_controller(clock, reset_n, emc_enable, plot_finished, should_plot, ecEn);
////
////	input clock;
////	input reset_n;
////	input emc_enable;
////	input plot_finished;
////	
////	output reg should_plot; //enables plot of where enemy is
////	output reg ecEn;    //enables enemy controller to decide next move
////	
////	reg [3:0] current_state, next_state; 
////
////	//states listed out as local_params
////   localparam     DECIDE_MOVE      				= 3'd0,
////						PLOT       				      = 3'd1;
////	
////	always @(*)
////		begin 
////			if (emc_enable)
////				begin
////					case (current_state)
////						 DECIDE_MOVE: next_state = plot_finished ? DECIDE_MOVE : PLOT;
////						 PLOT: next_state = plot_finished ? DECIDE_MOVE : PLOT;
////					default:  next_state = DECIDE_MOVE;
////				   endcase
////				end
////		end
////
////		 //how to change between states
////	 always @(*)
////		begin
////			if (emc_enable)
////				begin
////				  ecEn    = 1'b0;
////				  should_plot = 1'b0;
////				  case (current_state)
////						DECIDE_MOVE:
////							begin
////								ecEn = 1'b1;
////							end
////						PLOT:
////							begin
////								should_plot = 1'b1;
////							end
////				  endcase
////				end
////		end
////		
////	 always @(posedge clock)
////		begin
////				  if (!reset_n)
////						current_state <= DECIDE_MOVE;
////				  else if (emc_enable)
////						current_state <= next_state;
////				
////		end
////endmodule
////
////module enemy_meta_datapath(clock, reset_n, emd_enable, should_plot, ecEn, enemy_writeEn, x_out, y_out, start_plot);
////	input clock;
////	input reset_n;
////	input emd_enable;
////	input should_plot;
////	input ecEn;
////	
////	output reg enemy_writeEn;
////	output reg [7:0] x_out;
////	output reg [6:0] y_out;
////	output reg start_plot;
////
////	//enemy_attributes
////	
////	wire movement;
////	wire speed;
////	wire attack;
////	wire dead;
////	wire [1:0] x_pos;
////	wire [5:0] health = 6'b000111;
////	wire initiate_attack;
////	
////	wire [7:0] en_x;
////	wire [6:0] en_y;
////	
////	//lfsr enable governed by datapath output
////	wire lfsrEnable;
////	
//////	lfsr lfsr0(
//////			.clock(clock),
//////			.reset_n(resetn),
//////			.enable(lfsrEnable),
//////			.counter_val(8'b10110101),
//////			.random_pos(movement)
//////	);
////	
////	always @(posedge clock)
////		begin
////			if (!reset_n)
////				begin
////					x_out <= 8'b0000_0000;
////					y_out <= 7'b000_0000;
////					enemy_writeEn <= 1'b0;
////					start_plot <= 1'b0;
////				end
////			if (should_plot)
////			begin
////				x_out <= en_x;
////				y_out <= en_y;
////				enemy_writeEn <= 1'b1;
////				start_plot <= 1'b1;
////			end
////		end
////	
////	enemy_control ec0(
////			.clock(clock), 
////			.reset_n(resetn),
////			.enable(ecEn),
////			.go(1'b0), 
////			.health(health), 
////			.x_pos(x_pos), 
////			.speed(speed), 
////			.attack(attack), 
////			.dead(dead),
////			.writeEn(writeEn)
////	);
////	
////	enemy_datapath ed0(
////			.clock(clock), 
////			.resetn(resetn),
////			.enable(ecEn),
////			.speed(speed), 
////			.attack(attack), 
////			.x_pos(x_pos), 
////			.x_out(en_x), 
////			.y_out(en_Y), 
////			.move(lfsrEnable), 
////			.attack_out(initiate_attack)
////	);
////	
////endmodule
////
////module enemy_control(clock, reset_n, go, enable, health, x_pos, speed, attack, dead, writeEn);
////
////	//list of inputs
////	input clock;
////	input reset_n;
////	input go;
////	input [3:0] health;
////	input enable;
////	
////	//list of outputs
////	output reg [1:0] x_pos;
////	output reg speed;
////	output reg attack;
////	output reg dead;
////	output reg writeEn;
////
////	
////	reg [3:0] current_state, next_state; 
////
////	//states listed out as local_params
////   localparam   LEFT_CALM       			= 3'd0,
////				MIDDLE_CALM   					= 3'd1,
////				RIGHT_CALM       				= 3'd2,
////				LEFT_AGGRESSIVE    			= 3'd3,
////				MIDDLE_AGGRESSIVE          = 3'd4,
////				RIGHT_AGGRESSIVE				= 3'd5,
////				DEAD								= 3'd6;
////					 
////	//finite state machine transition
////
////	// shoudnt we wait for the counter to finish counting before changing states??
////
////
////		always @(*)
////			begin 
////				if (enable)
////					begin
////						case (current_state)
////							 LEFT_CALM: next_state 				= go ? RIGHT_CALM : MIDDLE_CALM;
////							 MIDDLE_CALM: next_state 			= go ? RIGHT_CALM : LEFT_CALM;
////							 RIGHT_CALM: next_state 			= go ? MIDDLE_CALM : LEFT_CALM;
////							 LEFT_AGGRESSIVE: next_state 		= go ? RIGHT_AGGRESSIVE : MIDDLE_AGGRESSIVE;
////							 MIDDLE_AGGRESSIVE: next_state 	= go ? RIGHT_AGGRESSIVE: LEFT_AGGRESSIVE;
////							 RIGHT_AGGRESSIVE: next_state 	= go ? MIDDLE_AGGRESSIVE: LEFT_AGGRESSIVE;
////							 //TODO: FIX DEAD STATE
////							 DEAD: next_state = DEAD;
////						default:  next_state = LEFT_CALM;
////					   endcase
////					 end
////		 end
////
////		 //how to change between states
////		 always @(*)
////			begin
////				if (enable)
////				begin
////				
////				  //Speed = 0 -> RateDivider (__Hz)
////				  //Speed = 1 -> RateDivider (2*__Hz)
////				  speed = 1'b0;
////				
////				  //Attack = 0 -> Wait for 4 position changes
////				  //Attack = 1 -> Wait for 2 position changes
////				  attack = 1'b0;
////				  
////				  //X_pos = 2'b01 (1) -> Change VGA_X to 20
////				  //X_pos = 2'b10 (2) -> Change VGA_X to 60
////				  //X_pos = 2'b11 (3) -> Change VGA_X to 100
////				  x_pos = 2'b00;
////				  
////				  //dead signal necessay
////				  dead = 1'b0;
////				  
////				  writeEn = 1'b0;
////				  
////				  case (current_state)
////						LEFT_CALM: 
////							begin
////								x_pos = 2'b01;
////							end
////						MIDDLE_CALM:
////							begin
////								x_pos = 2'b10;
////							end
////						RIGHT_CALM:
////							begin
////								x_pos = 2'b11;
////							end
////						LEFT_AGGRESSIVE:
////							begin
////								x_pos  = 2'b01;
////								speed  = 1'b1;
////								attack = 1'b1;
////							end
////						MIDDLE_AGGRESSIVE:
////							begin
////								x_pos  = 2'b10;
////								speed  = 1'b1;
////								attack = 1'b1;
////							end
////						RIGHT_AGGRESSIVE:
////							begin
////								x_pos  = 2'b11;
////								speed  = 1'b1;
////								attack = 1'b1;
////							end
////						//TODO DEAD CONTROL SIGNALS
////						DEAD:
////							begin
////								dead = 1'b1;
////							end
////				  endcase
////			 end
////	    end
////		
////		 always @(posedge clock)
////			begin
////
////					  if (!reset_n)
////							current_state <= LEFT_CALM;
////					//if the opponent has less than half their health, 
////					//they become more aggressive, move into different set of states
////					  else if (enable)
////							begin
////						   if (health < 4'd6 && current_state < 4'd3)
////								current_state <= next_state + 3;
////						  else if (health == 4'b0)
////								current_state <= DEAD;
////						  else
////								current_state <= next_state;
////							end
////			end
////endmodule
////
////module enemy_datapath(clock, resetn, enable, speed, attack, x_pos, x_out, y_out, move, attack_out);
////
////	// singlebit inputs
////	input clock;
////	input resetn;
////	input enable;
////
////	input speed;
////	input attack;
////	input [1:0] x_pos; // two bit because it is used for states in our fsm.
////
////	// outputs
////	output [7:0] x_out; // 8 bits following the lab.
////	output [6:0] y_out;
////	output move;
////	output attack_out;
////
////	// used to set the x co - ordinate output at the end.
////	reg [7:0] x;
////
////	// set the x co - ordinate to either 20, 60, 100 based on x_pos.
////	always @(posedge clock) begin
////		if (enable)
////			begin
////				if (x_pos == 2'b01)
////					x <= 8'b00010100; //set x to 20
////				else if (x_pos == 2'b10)
////					x <= 8'b00111100; //set x to 60
////				else if (x_pos == 2'b11)
////					x <= 8'b01100100; //set x to 100
////			end
////	end
////
////	assign x_out = x;
////	assign y_out = 7'b1000; // SET A CONSTANT FOR Y
////
////	// fix the value for rate_dividers (Lab 5 part 2)
////	
////	wire [27:0] hz05, hz025;
////
////	rate_divider r05hz(clk, reset_n, {1'b0, 27'd99999999}, hz05);
////	rate_divider r025hz(clk, reset_n, {28'd499999999}, hz025); 
////
////	// use this for attacking and moving
////	reg go;
////	
////	// when go is 0 then we have waited for hzT amount of time.
////	always @(*)
////		begin
////			if (enable)
////				begin
////					case(speed)
////						1'b0: go <= (hz025 == 0) ? 1 : 0;
////						1'b1: go <= (hz05 == 0) ? 1 : 0;
////					endcase
////				end
////		end
////
////	// count the number of moves we have made.
////	reg [1:0] move_count;
////
////	always @(posedge clk)
////		begin
////			if (enable)
////				begin
////					if (go == 1'b1) // after waiting hzT time units
////
////						//depending on the speed, move player.
////
////						if (speed == 1'b0) 
////							begin
////								if (move_count == 2'b11) // CHECK THIS LOGIC IS IT HIGH OR LOW UPDATE ATTACK
////									move_count <= 2'b00;
////								else
////									move_count <= move_count + 1'b1;
////							end
////						else if (speed == 1'b1)
////							begin
////								if (move_count == 1'b1) // CHECK THIS LOGIC IS IT HIGH OR LOW UPDATE ATTACK
////									move_count <= 1'b0;
////								else
////									move_count <= move_count + 1'b1;
////							end
////				end
////		end
////
////
////	wire should_attack;
////
////	// logic to make the player attack.
////	attack a1(clk, resetn, move_count, attack, should_attack);
////
////	// relay information back to LFSR as enable.
////	assign move = go;
////	assign should_attack = attack_out;
////
////endmodule
////
////module attack(clk, reset_n, move_count, attack, q);
////	input move_count, clk, reset_n, attack;
////	output reg [3:0] q;
////	
////	always @(posedge clk)
////	begin
////		if (reset_n == 1'b0)
////			q <= 4'b0000;
////
////		// this should trigger after x amount of moves.
////		else if (move_count == 1'b0) // if move_count is low refer to caps lock comment. TODO
////		begin 
////
////			// if attack is low fight slower.
////			if (attack == 1'b0)
////				begin
////					if (q == 2'b11)
////						q <= 2'b00;
////					else
////						q <= q + 1'b1;
////				end
////			// if attack is high fight faster.
////			else if (attack == 1'b1)
////				begin
////					if (q == 4'b1111)
////						q <= 4'b0000;
////					else
////						q <= q + 1'b1;
////				end
////
////		end
////	end
////	// use output for this to set of a signal to make the opponent punch us.
////endmodule
//
//
////module rate_divider(clk, reset_n, enable, d, q);
////	input enable, clk, reset_n;
////	input [27:0] d;
////	output reg [27:0] q;
////	
////	always @(posedge clk)
////	begin
////		if (reset_n == 1'b0)
////			q <= d;
////		else if (enable == 1'b1)
////			begin
////				if (q == 0)
////					q <= d;
////				else
////					q <= q - 1'b1;
////			end
////	end
////endmodule
//
//// module write_scene_to_buffer(clock, writeEn, reset_n, enemy_x_shift, enable, plot_finished, x_out, y_out, c_out);
////	input clock;
////	input reset_n;
////	input enable;
////	input enemy_x_shift;
////	
////	output reg plot_finished;
////	output reg [7:0] x_out;
////	output reg [6:0] y_out;
////	output reg [2:0] c_out;
////	output reg writeEn; 
////
////	reg en_enable;
////	
////	wire start_left;
////	wire start_right;
////	//wire start_player;
////	wire real_start;
////	wire [7:0] enemy_x;
////	wire [6:0] enemy_y;
////	wire [2:0] enemy_col;
////	wire [7:0] player_x;
////	wire [6:0] player_y;
////	wire [2:0] player_col;
////	wire [7:0] left_x;
////	wire [6:0] left_y;
////	wire [2:0] left_col;
////	wire [7:0] right_x;
////	wire [6:0] right_y;
////	wire [2:0] right_col;
////	
////	
////	always @(*)
////		begin
////			if (!reset_n)
////				begin
////					plot_finished <= 1'b1;
////					writeEn <= 1'b0;
////				end
////			else if (real_start)
////				begin
////					writeEn <= 1'b1;
////					plot_finished <= 1'b1;
////				end
////			else if (start_right)
////				begin
////					en_enable <= 1'b0;
////					x_out <= right_x;
////					y_out <= right_y;
////					c_out <= right_col;
////				end
//////			else if (start_player)
//////				begin
//////					en_enable <= 1'b0;
//////					x_out <= player_x;
//////					y_out <= player_y;
//////					c_out <= player_col;
//////				end
////			else if (start_left)
////				begin
////					en_enable <= 1'b0;
////					x_out <= left_x;
////					y_out <= left_y;
////					c_out <= left_col;
////				end	
////			else if (enable)
////				begin
////					en_enable <= enable;
////					x_out <= enemy_x;
////					y_out <= enemy_y;
////					c_out <= enemy_col;
////					writeEn <= 1'b0;
////					plot_finished <= 1'b0;
////				end
////		end
////		
////	enemy_pos_tracker(clock, reset_n, en_enable, enemy_x_shift, start_left, enemy_x, enemy_y, enemy_col);
////	left_hand_pos_tracker(clock, reset_n, start_left, 8'b0000_0000, start_right, left_x, left_y, left_col);
////	//player_pos_tracker(clock, reset_n, start_player, start_right, player_x, player_y, player_col);
////	right_hand_pos_tracker(clock, reset_n, start_right, 8'b0000_0000, real_start, right_x, right_y, right_col);
////
////	
////endmodule
////
////
////module enemy_pos_tracker(clock, reset_n, enable, x_pos_change,
////								 start_next, x_out, y_out, c_out);
////	input clock;
////	input reset_n;
////	input enable;
////	input x_pos_change;
////	
////	output reg start_next;
////	output [7:0] x_out;
////	output [6:0] y_out;
////	output [2:0] c_out;
////	
////	reg [11:0] counter;
////	reg [10:0] address_counter;
////	
////	reg [7:0] base_x;
////	reg [6:0] base_y;
////	
////	back	back_inst (
////			.address(address_counter),
////			.clock(clock),
////			.data(3'b111),
////			.wren(1'b0),
////			.q(c_out)
////	);
////	
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////				if (!reset_n)
////					begin
////						counter <= 12'b0000_0000_0000;
////						address_counter <= 11'b000_0000_0000;
////						start_next <= 1'b0;
////
////					end
////				else if (counter == 12'b100111100111)
////					begin
////						counter <= 12'b0000_0000_0000;
////						address_counter <= 11'b000_0000_0000;
////						start_next <= 1'b1;
////			
////					end
////				else if (counter[5:0] == 6'b100111)
////					begin
////						counter <= {counter[11:6] + 1'b1, 6'b000000};
////						address_counter <= address_counter + 1'b1;
////					end	
////				else
////					begin
////						counter <= counter + 1'b1;
////						address_counter <= address_counter + 1'b1; 
////					end
////				end
////		end
////	
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////					if (!reset_n)
////						base_x <= 8'b00010100;
////					// TODO FIND NUMBERS
////					else
////						base_x <= x_pos_change;
////				end
////		end
////		
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////					if (!reset_n)
////						base_y <= 7'b000_0110;
////					else
////						base_y <= 7'b000_0110;
////				end
////		end
////	assign x_out = base_x + counter[5:0];
////	assign y_out = base_y + counter[11:6];
////	
////endmodule
////
////module left_hand_pos_tracker(clock, reset_n, enable, y_pos_change,
////								 start_next, x_out, y_out, c_out);
////	input clock;
////	input reset_n;
////	input enable;
////	input y_pos_change;
////	
////	output reg start_next;
////	output [7:0] x_out;
////	output [6:0] y_out;
////	output [2:0] c_out;
////	
////	reg [11:0] counter;
////	reg [10:0] address_counter;
////	
////	reg [7:0] base_x;
////	reg [6:0] base_y;
////	
////	back	back_inst (
////			.address(address_counter),
////			.clock(clock),
////			.data(3'b111),
////			.wren(1'b0),
////			.q(c_out)
////	);
////	
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////				if (!reset_n)
////					begin
////						counter <= 12'b0000_0000_0000;
////						address_counter <= 11'b000_0000_0000;
////						start_next <= 1'b0;
////
////					end
////				else if (counter == 12'b100111100111)
////					begin
////						counter <= 12'b0000_0000_0000;
////						address_counter <= 11'b000_0000_0000;
////						start_next <= 1'b1;
////			
////					end
////				else if (counter[5:0] == 6'b100111)
////					begin
////						counter <= {counter[11:6] + 1'b1, 6'b000000};
////						address_counter <= address_counter + 1'b1;
////					end	
////				else
////					begin
////						counter <= counter + 1'b1;
////						address_counter <= address_counter + 1'b1; 
////					end
////				end
////		end
////	
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////					if (!reset_n)
////						base_x <= 8'b00010100;
////					// TODO FIND NUMBERS
////					else
////						base_x <= 8'b00010100;
////				end
////		end
////		
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////					if (!reset_n)
////						base_y <= 7'b100_0110;
////					else
////						base_y <= 7'b100_0110;
////				end
////		end
////	assign x_out = base_x + counter[5:0];
////	assign y_out = base_y + counter[11:6];
////	
////endmodule
////
////module right_hand_pos_tracker(clock, reset_n, enable, y_pos_change,
////								 start_next, x_out, y_out, c_out);
////	input clock;
////	input reset_n;
////	input enable;
////	input y_pos_change;
////	
////	output reg start_next;
////	output [7:0] x_out;
////	output [6:0] y_out;
////	output [2:0] c_out;
////	
////	reg [11:0] counter;
////	reg [10:0] address_counter;
////	
////	reg [7:0] base_x;
////	reg [6:0] base_y;
////	
////	back	back_inst (
////			.address(address_counter),
////			.clock(clock),
////			.data(3'b111),
////			.wren(1'b0),
////			.q(c_out)
////	);
////	
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////				if (!reset_n)
////					begin
////						counter <= 12'b0000_0000_0000;
////						address_counter <= 11'b000_0000_0000;
////						start_next <= 1'b0;
////
////					end
////				else if (counter == 12'b100111100111)
////					begin
////						counter <= 12'b0000_0000_0000;
////						address_counter <= 11'b000_0000_0000;
////						start_next <= 1'b1;
////			
////					end
////				else if (counter[5:0] == 6'b100111)
////					begin
////						counter <= {counter[11:6] + 1'b1, 6'b000000};
////						address_counter <= address_counter + 1'b1;
////					end	
////				else
////					begin
////						counter <= counter + 1'b1;
////						address_counter <= address_counter + 1'b1; 
////					end
////				end
////		end
////	
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////					if (!reset_n)
////						base_x <= 8'b01100100;
////					// TODO FIND NUMBERS
////					else
////						base_x <= 8'b01100100;
////				end
////		end
////		
////	always @(posedge clock)
////		begin
////			if (enable)
////				begin
////					if (!reset_n)
////						base_y <= 7'b100_0110;
////					else
////						base_y <= 7'b100_0110;
////				end
////		end
////	assign x_out = base_x + counter[5:0];
////	assign y_out = base_y + counter[11:6];
////	
////endmodule
////
//////module player_pos_tracker(clock, reset_n, y_pos_change, main_player_curr_x);
//////		input clock;
//////	input reset_n;
//////	input enable;
//////	input y_pos_change;
//////	
//////	output reg start_next;
//////	output [7:0] x_out;
//////	output [6:0] y_out;
//////	output [2:0] c_out;
//////	
//////	reg [11:0] counter;
//////	reg [10:0] address_counter;
//////	
//////	reg [7:0] base_x;
//////	reg [6:0] base_y;
//////	
//////	back	back_inst (
//////			.address(address_counter),
//////			.clock(clock),
//////			.data(3'b111),
//////			.wren(1'b0),
//////			.q(c_out)
//////	);
//////	
//////	always @(posedge clock)
//////		begin
//////			if (enable)
//////				begin
//////				if (!reset_n)
//////					begin
//////						counter <= 12'b0000_0000_0000;
//////						address_counter <= 11'b000_0000_0000;
//////						start_next <= 1'b0;
//////
//////					end
//////				else if (counter == 12'b100111100111)
//////					begin
//////						counter <= 12'b0000_0000_0000;
//////						address_counter <= 11'b000_0000_0000;
//////						start_next <= 1'b1;
//////			
//////					end
//////				else if (counter[5:0] == 6'b100111)
//////					begin
//////						counter <= {counter[11:6] + 1'b1, 6'b000000};
//////						address_counter <= address_counter + 1'b1;
//////					end	
//////				else
//////					begin
//////						counter <= counter + 1'b1;
//////						address_counter <= address_counter + 1'b1; 
//////					end
//////				end
//////		end
//////	
//////	always @(posedge clock)
//////		begin
//////			if (enable)
//////				begin
//////					if (!reset_n)
//////						base_x <= 8'b00111100;
//////					// TODO FIND NUMBERS
//////					else
//////						base_x <= 8'b00111100;
//////				end
//////		end
//////		
//////	always @(posedge clock)
//////		begin
//////			if (enable)
//////				begin
//////					if (!reset_n)
//////						base_y <= 7'b100_0110;
//////					else
//////						base_y <= 7'b100_0110;
//////				end
//////		end
//////	assign x_out = base_x + counter[5:0];
//////	assign y_out = base_y + counter[11:6];
//////	
//////endmodule
//
//module lfsr(clock, reset_n, enable, counter_val, random_pos);
//
//	//TODO: make more random
//	input clock;
//	input reset_n;
//	// we need enable so we can set a random seed for the LFSR
//	input enable;
//	input [7:0] counter_val;
//	
//	// 1 bit position of XOR'd values
//	// also serves as the go in the control
//	output [1:0] random_pos;
//	
//	// stores total value in LSFR
//	reg [7:0] LFSR_val;
//	
//	// random values
//	wire end_val = LFSR_val[1] ^ LFSR_val[0] ^ ~LFSR_val[2];
//	wire mid_val = LFSR_val[7] ^ LFSR_val[6];
//	
//	// counter value helps find seed for LFSR
//	
//	// flag to determine whether the LFSR seed value has been set
//	// necessary to allow it to be pseudo-random
//	reg LFSR_set;
//	
//	
//	always @(posedge clock)
//		begin
//			// on reset we can use any value, set flag to 0 (not set)
//			if (!reset_n)
//				begin
//					LFSR_val <= 8'b11111110;
//					LFSR_set <= 1'b0;
//				end
//			// while enable is off and flag = 0, we can update 
//			// the LSFR value to be a random seed
//			else if (!enable & !LFSR_set)
//				begin
//					LFSR_val <= (counter_val != 8'b0) ? counter_val : 8'b11111110;
//					LFSR_set <= 1'b1;
//				end
//			// when we need the LFSR to work, we can generate our pseudorandom values
//			else if (enable)
//				LFSR_val <= {LFSR_val[6], mid_val, LFSR_val[4], LFSR_val[3],
//								 LFSR_val[2], LFSR_val[1], LFSR_val[0], end_val};
//		end
//	
//	//end val will be pseudorandom, so this is all we need
//	assign random_pos = {LFSR_val[1], LFSR_val[0]};
//		
//	
//endmodule