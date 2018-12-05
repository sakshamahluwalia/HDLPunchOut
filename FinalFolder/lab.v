//
//module part2
//	(
//	CLOCK_50,						//	On Board 50 MHz
//	// Your inputs and outputs here
//        KEY,
//        SW,
//	// The ports below are for the VGA output.  Do not change.
//	VGA_CLK,   						//	VGA clk
//	VGA_HS,							//	VGA H_SYNC
//	VGA_VS,							//	VGA V_SYNC
//	VGA_BLANK_N,						//	VGA BLANK
//	VGA_SYNC_N,						//	VGA SYNC
//	VGA_R,   						//	VGA Red[9:0]
//	VGA_G,	 						//	VGA Green[9:0]
//	VGA_B   						//	VGA Blue[9:0]
//	);
//
//	input	CLOCK_50;				//	50 MHz
//	input   [9:0]   SW;
//	input   [3:0]   KEY;
//
//	// Declare your inputs and outputs here
//	// Do not change the following outputs
//	output	VGA_CLK;   				//	VGA clk
//	output	VGA_HS;					//	VGA H_SYNC
//	output	VGA_VS;					//	VGA V_SYNC
//	output	VGA_BLANK_N;				//	VGA BLANK
//	output	VGA_SYNC_N;				//	VGA SYNC
//	output	[9:0]	VGA_R;   			//	VGA Red[9:0]
//	output	[9:0]	VGA_G;	 			//	VGA Green[9:0]
//	output	[9:0]	VGA_B;   			//	VGA Blue[9:0]
//
//	wire resetn;
//	assign resetn = KEY[0];
//
//	// Create the colour, x, y and writeEn wires that are inputs to the controller.
//	wire [2:0] colour;
//	wire [7:0] x;
//	wire [6:0] y;
//	wire writeEn;
//
//	wire ld_x, ld_y, ld_colour, enable;
//
//	// Create an Instance of a VGA controller - there can be only one!
//	// Define the number of colours as well as the initial background
//	// image file (.MIF) for the controller.
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
//	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
//	// for the VGA controller, in addition to any other functionality your design may require.
//
//	// output ld_x;
//	// output ld_y;
//	// output ld_colour;
//	// output writeEn;
//	// output enable;
//
//
//	// Instantiate datapath
//	// datapath d0(...);
//	datapath d0(
//		.clock(CLOCK_50),
//		.enable(enable),
//		.resetn(resetn),
//		.c_in(SW[9:7]),
//		.point(SW[6:0]),
//		.load_x(ld_x),
//		.load_y(ld_y),
//		.load_colour(ld_colour),
//		.x_out(x),
//		.y_out(y),
//		.c_out(colour)
//		);
//
//	// Instantiate FSM control
//	// control c0(...);
//	control c0(
//		.clock(CLOCK_50),
//		.resetn(resetn),
//		.load(KEY[3]),
//		.drw(~KEY[1]),
//		.writeEnable(writeEn),
//		.enable(enable),
//		.ld_x(ld_x),
//		.ld_y(ld_y),
//		.ld_colour(ld_colour)
//		);
//
//endmodule
//
//module datapath(clock, enable, resetn, c_in, point,	load_x,	load_y,	load_colour, x_out,	y_out, c_out);
//
//	// singlebit inputs
//	input clock;
//	input enable;
//	input resetn;
//
//	// load enables
//	input load_x;
//	input load_y;
//	input load_colour;
//
//	// multibit inputs
//	input [2:0] c_in;
//	input [6:0] point;
//
//	// outputs
//	output [7:0] x_out;
//	output [6:0] y_out;
//	output [2:0] c_out;
//
//	reg [7:0] x;
//	reg [6:0] y;
//	reg [2:0] colour;
//	reg [3:0] counter;
//
//	// registers for x, y and color update based on the value of load[x, y, colour].
//	always @(posedge clock) begin
//		if (!resetn) begin
//			x <= 8'b0;
//			y <= 7'b0;
//			colour <= 3'b0;
//		end
//		else begin
//			if (load_x)
//				x <= {1'b0, point};
//			if (load_y)
//				y <= point;
//			if (load_colour)
//				colour <= c_in;
//		end
//	end
//
//	// counter for x and y co-ordinates.
//	always @(posedge clock) begin
//		if (!resetn)
//			counter <= 4'b0000;
//		else if (enable) begin
//			if (counter == 4'b1111)
//				counter <= 4'b0000;
//			else
//				counter <= counter + 1'b1;
//		end
//	end
//
//	assign x_out = x + counter[3:2];
//	assign y_out = y + counter[1:0];
//	assign c_out = colour;
//
//endmodule
//
//module control(clock, resetn, load, drw, writeEnable, enable, ld_x, ld_y, ld_colour);
//
//	input clock;
//	input resetn;
//	input load;
//	input drw;
//
//	output reg ld_x;
//	output reg ld_y;
//	output reg ld_colour;
//	output reg writeEnable;
//	output reg enable;
//
//	reg [3:0] curr_state, next_state;
//
//	// States
//	localparam 	load_x 					= 3'd0,
//				load_x_wait 			= 3'd1,
//				load_colour_and_y 		= 3'd2,
//				load_colour_and_y_wait 	= 3'd3,
//				transition				= 3'd4,
//				draw 					= 3'd5;
//
//	// State Table
//	always @(*) begin
//		case (curr_state)
//
//			load_x: next_state = load ? load_x_wait : load_x;
//			load_x_wait: next_state = load ? load_x_wait : load_colour_and_y;
//
//			load_colour_and_y: next_state = load ? load_colour_and_y_wait : load_colour_and_y;
//			load_colour_and_y_wait: next_state = load ? load_colour_and_y_wait : transition;
//
//			transition: next_state = drw ? draw : transition; //introduced this state to use KEY[0]
//
//			draw: next_state = drw ? draw : load_x;
//		endcase
//	end
//
//	// Output Logic
//	always @(*) begin
//		ld_x = 1'b0;
//		ld_y = 1'b0;
//		ld_colour = 1'b0;
//		writeEnable = 1'b0;
//
//		case (curr_state)
//			load_x: begin
//				ld_x = 1;
//				enable = 0;
//			end
//			load_x_wait: begin
//				ld_x = 1;
//				enable = 0;
//			end
//			load_colour_and_y: begin
//				ld_y = 1;
//				ld_colour = 1;
//				enable = 0;
//			end
//			load_colour_and_y_wait: begin
//				ld_y = 1;
//				ld_colour = 1;
//				enable = 0;
//			end
//			transition: begin
//				enable = 0;
//			end
//			draw: begin
//				writeEnable = 1;
//				enable = 1;
//			end
//		endcase
//	end
//
//	// Current State Register
//	always @(posedge clock) begin
//		if (!resetn)
//			curr_state <= load_x;
//		else
//			curr_state <= next_state;
//	end
//
//endmodule

