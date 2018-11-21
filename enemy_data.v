module datapath(clock, resetn, speed, attack, x_pos, x_out);

	// singlebit inputs
	input clock;
	input resetn;

	input speed;
	input attack;
	input [1:0] x_pos;

	// outputs
	output [7:0] x_out;

	// used to set the x co - ordinate output at the end.
	wire [7:0] x;

	// set the x co - ordinate to either 20, 60, 100.
	always @(posedge clock) begin

		if (x_pos == 2'b00)
			x = {3'b0, 5'b10100}; //set x to 20
		else if (x_pos == 2'b01)
			x = {2'b0, 6'b111100}; //set x to 60
		else if (x_pos == 2'b10)
			x = {1'b0, 7'b1100100}; //set x to 100

	end

	assign x_out = x;

	// fix the value for rate_dividers (Lab 5 part 2)

	rate_divider r05hz(clk, reset_n, {1'b0, 27'd99999999}, hz05);
	rate_divider r025hz(clk, reset_n, {28'd499999999}, hz025); 

	// use this for attacking and moving
	wire go;
	
	// when enable(go) is 0 then we have waited for hzT amount of time.
	always @(*)
		begin
			case(speed)
				1'b0: go = (hz1 == 0) ? 1 : 0;
				1'b1: go = (hz05 == 0) ? 1 : 0;
			endcase
		end


	attack a1(clk, resetn, go, output);


endmodule



module rate_divider(clk, reset_n, enable, d, q);
	input enable, clk, reset_n;
	input [27:0] d;
	output reg [27:0] q;
	
	always @(posedge clk)
	begin
		if (reset_n == 1'b0)
			q <= d;
		else if (enable == 1'b1)
			begin
				if (q == 0)
					q <= d;
				else
					q <= q - 1'b1;
			end
	end
	
endmodule

module attack(clk, reset_n, enable, q);
	input enable, clk, reset_n;
	output reg [3:0] q;
	
	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			q <= 4'b0000;
		else if (enable == 1'b1)
			begin
				if (q == 4'b1111)
					q <= 4'b0000;
				else
					q <= q + 1'b1;
			end
	end
endmodule