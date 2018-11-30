module enemy_datapath(clock, resetn, enable, speed, attack, x_pos, x_out, y_out, move, attack_out);

	// singlebit inputs
	input clock;
	input resetn;
	input enable;

	input speed;
	input attack;
	input [1:0] x_pos; // two bit because it is used for states in our fsm.

	// outputs
	output [7:0] x_out; // 8 bits following the lab.
	output [6:0] y_out;
	output move;
	output attack_out;

	// used to set the x co - ordinate output at the end.
	reg [7:0] x;

	// set the x co - ordinate to either 20, 60, 100 based on x_pos.
	always @(posedge clock) begin
		if (enable)
			begin
				if (x_pos == 2'b01)
					x <= 8'b00010100; //set x to 20
				else if (x_pos == 2'b10)
					x <= 8'b00111100; //set x to 60
				else if (x_pos == 2'b11)
					x <= 8'b01100100; //set x to 100
			end
	end

	assign x_out = x;
	assign y_out = 7'b1000; // SET A CONSTANT FOR Y

	// fix the value for rate_dividers (Lab 5 part 2)
	
	wire [27:0] hz05, hz025;

	rate_divider r05hz(clk, reset_n, {1'b0, 27'd99999999}, hz05);
	rate_divider r025hz(clk, reset_n, {28'd499999999}, hz025); 

	// use this for attacking and moving
	reg go;
	
	// when go is 0 then we have waited for hzT amount of time.
	always @(*)
		begin
			if (enable)
				begin
					case(speed)
						1'b0: go <= (hz025 == 0) ? 1 : 0;
						1'b1: go <= (hz05 == 0) ? 1 : 0;
					endcase
				end
		end

	// count the number of moves we have made.
	reg [1:0] move_count;

	always @(posedge clk)
		begin
			if (enable)
				begin
					if (go == 1'b1) // after waiting hzT time units

						//depending on the speed, move player.

						if (speed == 1'b0) 
							begin
								if (move_count == 2'b11) // CHECK THIS LOGIC IS IT HIGH OR LOW UPDATE ATTACK
									move_count <= 2'b00;
								else
									move_count <= move_count + 1'b1;
							end
						else if (speed == 1'b1)
							begin
								if (move_count == 1'b1) // CHECK THIS LOGIC IS IT HIGH OR LOW UPDATE ATTACK
									move_count <= 1'b0;
								else
									move_count <= move_count + 1'b1;
							end
				end
		end


	wire should_attack;

	// logic to make the player attack.
	attack a1(clk, resetn, move_count, attack, should_attack);

	// relay information back to LFSR as enable.
	assign move = go;
	assign should_attack = attack_out;

endmodule

module attack(clk, reset_n, move_count, attack, q);
	input move_count, clk, reset_n, attack;
	output reg [3:0] q;
	
	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			q <= 4'b0000;

		// this should trigger after x amount of moves.
		if (move_count == 1'b0) // if move_count is low refer to caps lock comment. TODO
		begin 

			// if attack is low fight slower.
			if (attack == 1'b0)
				begin
					if (q == 2'b11)
						q <= 2'b00;
					else
						q <= q + 1'b1;
				end
			// if attack is high fight faster.
			else if (attack == 1'b1)
				begin
					if (q == 4'b1111)
						q <= 4'b0000;
					else
						q <= q + 1'b1;
				end

		end
	end
	// use output for this to set of a signal to make the opponent punch us.
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


//module enemy_datapath(clock, resetn, speed, attack, x_pos, x_out, y_out, move, attack_out);
//
//	// singlebit inputs
//	input clock;
//	input resetn;
//
//	input speed;
//	input attack;
//	input [1:0] x_pos; // two bit because it is used for states in our fsm.
//
//	// outputs
//	output [7:0] x_out; // 8 bits following the lab.
//	output [6:0] y_out;
//	output move;
//	output attack_out;
//
//	// used to set the x co - ordinate output at the end.
//	wire [7:0] x;
//
//	// set the x co - ordinate to either 20, 60, 100 based on x_pos.
//	always @(posedge clock) begin
//
//		if (x_pos == 2'b00)
//			x = 8'b00010100; //set x to 20
//		else if (x_pos == 2'b01)
//			x = 8'b00111100; //set x to 60
//		else if (x_pos == 2'b10)
//			x = 8'b01100100; //set x to 100
//
//	end
//
//	assign x_out = x;
//	assign y_out = 7'b1000; // SET A CONSTANT FOR Y
//
//	// fix the value for rate_dividers (Lab 5 part 2)
//	
//	wire [27:0] hz05, hz025;
//
//	rate_divider r05hz(clk, reset_n, {1'b0, 27'd99999999}, hz05);
//	rate_divider r025hz(clk, reset_n, {28'd499999999}, hz025); 
//
//	// use this for attacking and moving
//	wire go;
//	
//	// when go is 0 then we have waited for hzT amount of time.
//	always @(*)
//		begin
//			case(speed)
//				1'b0: go = (hz025 == 0) ? 1 : 0;
//				1'b1: go = (hz05 == 0) ? 1 : 0;
//			endcase
//		end
//
//	// count the number of moves we have made.
//	reg [1:0] move_count;
//
//	always @(posedge clk)
//		begin
//			if (go == 1'b1) // after waiting hzT time units
//
//				//depending on the speed, move player.
//
//				if (speed == 1'b0) 
//					begin
//						if (move_count == 2'b11) // CHECK THIS LOGIC IS IT HIGH OR LOW UPDATE ATTACK
//							move_count <= 2'b00;
//						else
//							move_count <= move_count + 1'b1;
//					end
//				else if (speed == 1'b1)
//					begin
//						if (move_count == 1'b1) // CHECK THIS LOGIC IS IT HIGH OR LOW UPDATE ATTACK
//							move_count <= 1'b0;
//						else
//							move_count <= move_count + 1'b1;
//					end
//		end
//
//
//	wire should_attack;
//
//	// logic to make the player attack.
//	attack a1(clk, resetn, move_count, attack, should_attack);
//
//	// relay information back to LFSR as enable.
//	assign move = go;
//	assign should_attack = attack_out;
//
//endmodule
//
//module attack(clk, reset_n, move_count, attack, q);
//	input move_count, clk, reset_n;
//	output reg [3:0] q;
//	
//	always @(posedge clk, negedge reset_n)
//	begin
//		if (reset_n == 1'b0)
//			q <= 4'b0000;
//
//		// this should trigger after x amount of moves.
//		if (move_count == 1'b0) // if move_count is low refer to caps lock comment. TODO
//		begin 
//
//			// if attack is low fight slower.
//			if (attack == 1'b0)
//				begin
//					if (q == 2'b11)
//						q <= 2'b00;
//					else
//						q <= q + 1'b1;
//				end
//			// if attack is high fight faster.
//			else if (attack == 1'b1)
//				begin
//					if (q == 4'b1111)
//						q <= 4'b0000;
//					else
//						q <= q + 1'b1;
//				end
//
//		end
//	end
//	// use output for this to set of a signal to make the opponent punch us.
//endmodule
//
//
//module rate_divider(clk, reset_n, enable, d, q);
//	input enable, clk, reset_n;
//	input [27:0] d;
//	output reg [27:0] q;
//	
//	always @(posedge clk)
//	begin
//		if (reset_n == 1'b0)
//			q <= d;
//		else if (enable == 1'b1)
//			begin
//				if (q == 0)
//					q <= d;
//				else
//					q <= q - 1'b1;
//			end
//	end
//endmodule
