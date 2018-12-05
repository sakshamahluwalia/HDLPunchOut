module overall_vga_5(
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
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	

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
		
		wire init_erase, init_enemy, init_left, init_player, init_right;
		
		enemy_move_controller emc(CLOCK_50, resetn, init_erase,
									init_enemy, init_left, 
									init_player, init_right, writeEn);
		enemy_move_datapath edc(CLOCK_50, resetn, init_erase, init_enemy,
									init_left, init_player, init_right,
									x, y, colour);
endmodule

module enemy_move_controller(clock, reset_n, init_erase, init_enemy, init_left, 
									  init_player, init_right, writeEn);

	input clock;
	input reset_n;
	//input emc_enable;
	
//	output reg writeEn; //enables plot of where enemy is
//	output reg ecEn;    //enables enemy controller to decide next move
//	output reg plotEn;
	output reg init_erase;
	output reg init_enemy;
	output reg init_left;
	output reg init_player;
	output reg init_right;
	output reg writeEn;
	
	//TODO
	
	reg erase_counter_enable;
	reg enemy_counter_enable;
	reg left_counter_enable;
	reg player_counter_enable;
	reg right_counter_enable;
	reg plot_counter_enable;
	reg wait_counter_enable;
	reg pass;
	
	wire erase_done;
	wire enemy_done;
	wire left_done;
	wire player_done;
	wire right_done;
	wire plot_done;
	wire wait_done;
	
	reg [3:0] current_state, next_state; 

	//states listed out as local_params
   localparam     INITIAL      					= 4'd0,
						//ADD ERASE_ENEMY STATE
						DRAW_ENEMY 		    			  = 4'd1,
						DRAW_LEFT       				      = 4'd2,
						DRAW_PLAYER 		     			 = 4'd3,
						DRAW_RIGHT       				      = 4'd4,
						PLOT 		     				 			= 4'd5,
						WAIT       				     			 = 4'd6,
						ERASE_ENEMY                       = 4'd7;
	
	always @(*)
		begin 
//			if (emc_enable)
//				begin
					case (current_state)
					//automatic state change here
						 INITIAL: next_state = ERASE_ENEMY;
						 ERASE_ENEMY: next_state = DRAW_ENEMY;
						 DRAW_ENEMY: next_state = DRAW_LEFT;
						 DRAW_LEFT: next_state = DRAW_PLAYER;
						 DRAW_PLAYER: next_state = DRAW_RIGHT;
						 DRAW_RIGHT: next_state = PLOT;
						 PLOT: next_state = WAIT;
						 WAIT: next_state = INITIAL;
					default:  next_state = INITIAL;
				   endcase
//				end
		end

		 //how to change between states
	 always @(*)
		begin
//			if (emc_enable)
//				begin
				  init_enemy = 1'b0;
				  init_left = 1'b0;
				  init_player = 1'b0;
				  init_right = 1'b0;
				  init_erase = 1'b0;
				  erase_counter_enable = 1'b0;
				  enemy_counter_enable = 1'b0;
					left_counter_enable = 1'b0;
					player_counter_enable = 1'b0;
					right_counter_enable = 1'b0;
					plot_counter_enable = 1'b0;
					wait_counter_enable = 1'b0;
					pass = 1'b0;
					writeEn = 1'b1;
				  case (current_state)
						INITIAL:
						begin
						pass = 1'b1;
						end
						ERASE_ENEMY:
						begin
						init_erase = 1'b1;
						erase_counter_enable = 1'b1;
						end
						DRAW_ENEMY:
						begin
						init_enemy = 1'b1;
						enemy_counter_enable = 1'b1;
						end
						DRAW_LEFT:
						begin
						init_left = 1'b1;
						left_counter_enable = 1'b1;
						end
						DRAW_PLAYER:
						begin
						init_player = 1'b1;
						player_counter_enable = 1'b1;
						end
						DRAW_RIGHT:
						begin
						init_right = 1'b1;
						right_counter_enable = 1'b1;
						end
						PLOT:
						begin
						//writeEn = 1'b1;
						plot_counter_enable = 1'b1;
						end
						WAIT:
						begin
						pass = 1'b1;
						wait_counter_enable = 1'b1;
						end
				  endcase
//				end
		end
	
	//TODO MAKE COUNTER
	 counter_1200 enemy(enemy_counter_enable, clock, reset_n, enemy_done);
	 counter_300 left(left_counter_enable, clock, reset_n, left_done);
	 counter_1200 player(player_counter_enable, clock, reset_n, player_done);
	 counter_300 right(right_counter_enable, clock, reset_n, right_done);
	 counter_3000 plot(plot_counter_enable, clock, reset_n, plot_done);
	 counter_9600 erase(erase_counter_enable, clock, reset_n, erase_done);
	 counter_4_seconds waiter(wait_counter_enable, clock, reset_n, wait_done);
	 
	 always @(posedge clock)
		begin
				  if (!reset_n)
				  //here, implement 1200 or 300 counter for each image
				  // put counter enables that are registers based on the current state
				  // after which you can switch to the next state
					current_state <= INITIAL;
				  //else if (emc_enable)
				   else if (current_state == INITIAL)
						current_state <= next_state;
					else if (current_state == ERASE_ENEMY & erase_done)
						current_state <= next_state;
					else if (current_state == DRAW_ENEMY & enemy_done)
						current_state <= next_state;
					else if (current_state == DRAW_LEFT & left_done)
						current_state <= next_state;
					else if (current_state == DRAW_PLAYER & player_done)
						current_state <= next_state;
					else if (current_state == DRAW_RIGHT & right_done)
						current_state <= next_state;
					else if (current_state == PLOT & plot_done)
						current_state <= next_state;
					else if (current_state == WAIT & wait_done)
						current_state <= next_state;
						
		end
endmodule

module counter_1200(enable, clock, reset_n, out_enable);
	input enable, clock, reset_n;

	output reg out_enable;
	
	reg [10:0] out_wire;
	
	
	always @(posedge clock)
	begin
		if (!reset_n)
			begin
				out_enable <= 1'b0;
				out_wire <= 11'b1001_0110_000;
			end
		else if (enable == 1'b1)
			begin
				if (out_wire == 0)
					begin
						out_wire <= 11'b10010110000;
						out_enable <= 1'b1;
					end
				else
					begin
						out_wire <= out_wire - 1;
						out_enable <= 1'b0;
					end
			end
		else if (enable == 1'b0)
			out_enable <= 1'b0;
	end
			
endmodule



module counter_300(enable, clock, reset_n, out_enable);

	input enable, clock, reset_n;
	
	output reg out_enable;
	
	reg [8:0] out_wire;
	
	always @(posedge clock)
	begin
		if (!reset_n)
			begin
				out_enable <= 1'b0;
				out_wire <= 9'b100101100;
			end
		else if (enable == 1'b1)
			begin
				if (out_wire == 0)
					begin
						out_wire <= 9'b100101100;
						out_enable <= 1'b1;
					end
				else
					begin
						out_wire <= out_wire - 1;
						out_enable <= 1'b0;
					end
			end
		else if (enable == 1'b0)
			out_enable <= 1'b0;
	end
			
endmodule



module counter_3000(enable, clock, reset_n, out_enable);
	input enable, clock, reset_n;
	output reg out_enable;
	
   reg [11:0] out_wire;
	
	
	always @(posedge clock)
	begin
		if (!reset_n)
			begin
				out_enable <= 1'b0;
				out_wire <= 12'b101110111000;
			end
		else if (enable == 1'b1)
			begin
				if (out_wire == 0)
					begin
						out_wire <= 12'b101110111000;
						out_enable <= 1'b1;
					end
				else
					begin
						out_wire <= out_wire - 1;
						out_enable <= 1'b0;
					end
			end
		else if (enable == 1'b0)
			out_enable <= 1'b0;
	end
			
endmodule

module counter_4_seconds(enable, clock, reset_n, out_enable);
	input enable, clock, reset_n;

	output reg out_enable;
	
	reg [27:0] out_wire;
	
	
	always @(posedge clock)
	begin
		if (!reset_n)
			begin
				out_enable <= 1'b0;
				out_wire <= 28'b1011111010111100001000000000;
			end
		else if (enable == 1'b1)
			begin
				if (out_wire == 0)
					begin
						out_wire <= 28'b1011111010111100001000000000;
						out_enable <= 1'b1;
					end
				else
					begin
						out_wire <= out_wire - 1;
						out_enable <= 1'b0;
					end
			end
		else if (enable == 1'b0)
			out_enable <= 1'b0;
	end
			
endmodule

module counter_9600(enable, clock, reset_n, out_enable);
	input enable, clock, reset_n;
	output reg out_enable;
	
   reg [13:0] out_wire;
	
	
	always @(posedge clock)
	begin
		if (!reset_n)
			begin
				out_enable <= 1'b0;
				out_wire <= 14'b10_0101_1000_0000;
			end
		else if (enable == 1'b1)
			begin
				if (out_wire == 0)
					begin
						out_wire <= 14'b10_0101_1000_0000;
						out_enable <= 1'b1;
					end
				else
					begin
						out_wire <= out_wire - 1;
						out_enable <= 1'b0;
					end
			end
		else if (enable == 1'b0)
			out_enable <= 1'b0;
	end
			
endmodule





module enemy_move_datapath(clock, reset_n, init_erase, init_enemy,
									init_left, init_player, init_right,
									x, y, colour);

	input clock;
	input reset_n;
	input init_erase;
	input init_enemy;
	input init_left;
	input init_player;
	input init_right;
//	input writeEn;
	
	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour;
	
	reg erase_enable;
	reg enemy_enable;
	reg left_enable;
	reg player_enable;
	reg right_enable;
	
	wire [7:0] erase_x;
	wire [6:0] erase_y;
	wire [2:0] erase_col; 
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
					enemy_enable <= 1'b0;
					left_enable <= 1'b0;
					player_enable <= 1'b0;
					right_enable <= 1'b0;
					erase_enable <= 1'b0;
					x <= 8'b0000_0000;
					y <= 7'b000_0000;
					colour <= 3'b000;
				end
			else if (init_enemy)
				begin
					enemy_enable <= 1'b1;
					left_enable <= 1'b0;
					player_enable <= 1'b0;
					right_enable <= 1'b0;
					erase_enable <= 1'b0;
					x <= enemy_x;
					y <= enemy_y;
					colour <= enemy_col;
				end
			else if (init_left)
				begin
					enemy_enable <= 1'b0;
					left_enable <= 1'b1;
					player_enable <= 1'b0;
					right_enable <= 1'b0;
					erase_enable <= 1'b0;
					x <= left_x;
					y <= left_y;
					colour <= left_col;
				end
			else if (init_player)
				begin
					enemy_enable <= 1'b0;
					left_enable <= 1'b0;
					player_enable <= 1'b1;
					right_enable <= 1'b0;
					erase_enable <= 1'b0;
					x <= player_x;
					y <= player_y;
					colour <= player_col;
				end
			else if (init_right)
				begin
					enemy_enable <= 1'b0;
					left_enable <= 1'b0;
					player_enable <= 1'b0;
					right_enable <= 1'b1;
					erase_enable <= 1'b0;
					x <= right_x;
					y <= right_y;
					colour <= right_col;
				end
			else if (init_erase)
				begin
					enemy_enable <= 1'b0;
					left_enable <= 1'b0;
					player_enable <= 1'b0;
					right_enable <= 1'b0;
					erase_enable <= 1'b1;
					x <= erase_x;
					y <= erase_y;
					colour <= erase_col;
				end
		end
			
		
	initialize_enemy ie(clock, reset_n, enemy_enable, enemy_x, enemy_y, enemy_col);
	initialize_left il(clock, reset_n, left_enable, left_x, left_y, left_col);
	initialize_player ip(clock, reset_n, player_enable, player_x, player_y, player_col);
	initialize_right ir(clock, reset_n, right_enable, right_x, right_y, right_col);
	initialize_erase ier(clock, reset_n, erase_enable, erase_x, erase_y, erase_col);
	
endmodule


module initialize_enemy(clock, reset_n, enable, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [10:0] counter;
	reg [10:0] address_counter;
	
	reg [7:0] base_x;
	
	wire [1:0] x_shift;
	
	lfsr l0(clock, reset_n, enable, 8'b10110110, x_shift);
	
	boxer	boxer_inst (
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
						counter <= 11'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;

					end
				else if (counter == 11'b11110100111)
					begin
						counter <= 11'b0000_0000_0000;
						address_counter <= 11'b000_0000_0000;

			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[10:6] + 1'b1, 6'b000000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end
	
	reg flag;
	always @(*)
		begin
			if (!reset_n)
				begin
					base_x <= 8'b0000_0000;
					flag <= 1'b0;
				end
			if (enable & !flag)
				begin
					if (x_shift % 3 == 0)
						begin
						base_x <= 8'b0000_0000;
						flag <= 1'b1;
						end
					else if (x_shift % 3 == 1)
						begin
						base_x <= 8'b0010_1000;
						flag <= 1'b1;
						end
					else if (x_shift % 3 == 2)
						begin
						base_x <= 8'b0101_0000;
						flag <= 1'b1;
						end
				end
			else if (!enable)
				begin
					flag <= 1'b0;
				end
		end
		
	assign x_out = base_x + counter[5:0];
	assign y_out = 7'b000_0110 + counter[10:6];
	
	
endmodule


module initialize_player(clock, reset_n, enable, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [10:0] counter;
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
						counter <= 11'b000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						

					end
				else if (counter == 11'b11110100111)
					begin
						counter <= 11'b000_0000_0000;
						address_counter <= 11'b000_0000_0000;
						
			
					end
				else if (counter[5:0] == 6'b100111)
					begin
						counter <= {counter[10:6] + 1'b1, 6'b000000};
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
	assign y_out = 7'b100_0110 + counter[10:6];
	
	
endmodule

module initialize_left(clock, reset_n, enable, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [8:0] counter;
	reg [8:0] address_counter;
	
	glove	glove_inst (
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
						counter <= 9'b0_0000_0000;
						address_counter <= 9'b0_0000_0000;
						

					end
				else if (counter == 9'b111110100)
					begin
						counter <= 9'b0_0000_0000;
						address_counter <= 9'b0_0000_0000;
						
			
					end
				else if (counter[4:0] == 5'b10100)
					begin
						counter <= {counter[8:5] + 1'b1, 5'b00000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end

	assign x_out = 8'b0000_0000 + counter[4:0];
	assign y_out = 7'b100_0110 + counter[8:5];
	
	
endmodule

module initialize_right(clock, reset_n, enable, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [8:0] counter;
	reg [8:0] address_counter;
	
	right_glove	right_glove_inst (
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
						counter <= 9'b0_0000_0000;
						address_counter <= 9'b0_0000_0000;

					end
				else if (counter == 9'b111110100)
					begin
						counter <= 9'b0_0000_0000;
						address_counter <= 9'b0_0000_0000;
			
					end
				else if (counter[4:0] == 5'b10100)
					begin
						counter <= {counter[8:5] + 1'b1, 5'b00000};
						address_counter <= address_counter + 1'b1;
					end	
				else
					begin
						counter <= counter + 1'b1;
						address_counter <= address_counter + 1'b1; 
					end
				end
		end

	assign x_out = 8'b0101_0000 + counter[4:0];
	assign y_out = 7'b100_0110 + counter[8:5];
	
	
endmodule

module initialize_erase(clock, reset_n, enable, x_out, y_out, c_out);
	input clock;
	input reset_n;
	input enable;
	
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;
	
	reg [13:0] counter;
	
	
	
	always @(posedge clock)
		begin
			if (enable)
				begin
				if (!reset_n)
					begin
						counter <= 14'b00_0000_0000_0000;

					end
				else if (counter == 14'b11_1100_1010_0000)
					begin
						counter <= 14'b00_0000_0000_0000;
			
					end
				else if (counter[7:0] == 8'b10100000)
					begin
						counter <= {counter[13:8] + 1'b1, 8'b0000_0000};
					end	
				else
					begin
						counter <= counter + 1'b1;
					end
				end
		end

	assign x_out = 8'b0000_0000 + counter[7:0];
	assign y_out = 7'b000_0000 + counter[13:8];
	assign c_out = 3'b000;
	
	
endmodule

module lfsr(clock, reset_n, enable, counter_val, random_pos);

	//TODO: make more random
	input clock;
	input reset_n;
	// we need enable so we can set a random seed for the LFSR
	input enable;
	input [7:0] counter_val;
	
	// 1 bit position of XOR'd values
	// also serves as the go in the control
	output reg [1:0] random_pos;
	
	always @(posedge clock)
		begin
			if (!reset_n)
				random_pos <= 2'b00;
			if (random_pos == 2'b00)
				random_pos <= 2'b01;
			else if (random_pos == 2'b01)
				random_pos <= 2'b10;
			else if (random_pos == 2'b10)
				random_pos <= 2'b00;
		end
	
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
	
		
	
endmodule



