module datapath(clock, enable, resetn, c_in, point,	load_x,	load_y,	load_colour, x_out,	y_out, c_out);

	// singlebit inputs
	input clock;
	input enable;
	input resetn;

	// load enables
	input load_x;
	input load_y;
	input load_colour;

	// multibit inputs
	input [2:0] c_in;
	input [6:0] point;

	// outputs
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] c_out;

	reg speed;
	reg attack;
	reg [1:0] x_pos;
	reg [2:0] health;
	reg [3:0] counter;

	// registers for x, y and color update based on the value of load[x, y, colour].
	always @(posedge clock) begin
		if (!resetn) begin
			x <= 8'b0;
			y <= 7'b0;
			colour <= 3'b0;
		end
		else begin
			if (load_x)
				x <= {1'b0, point};
			if (load_y)
				y <= point;
			if (load_colour)
				colour <= c_in;
		end
	end

	// counter for x and y co-ordinates.
	always @(posedge clock) begin
		if (!resetn)
			counter <= 4'b0000;
		else if (enable) begin
			if (counter == 4'b1111)
				counter <= 4'b0000;
			else
				counter <= counter + 1'b1;
		end
	end

	assign x_out = x + counter[3:2];
	assign y_out = y + counter[1:0];
	assign c_out = colour;

endmodule



module RateDivider(enable, load_val_cycles, clock, reset_n, out);
	input enable;
	input clock, reset_n;
	input [24:0] load_val_cycles;
	output reg [24:0] out;
	
	always @(posedge clock, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			out <= load_val_cycles;
		else if (enable == 1'b0)
			begin
				if (out == 1'b0)
					out <= load_val_cycles;
				else
					out <= out - 1'b1;
			end
	end
		
endmodule