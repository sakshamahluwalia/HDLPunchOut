<<<<<<< HEAD
module enemycd(clock, reset_n, go, health);

	//list of inputs
	input clock;
	input reset_n;
	input go;
	input [3:0] health;
	
	//list of outputs
	wire [1:0] x_pos;
	wire speed;
	wire attack;
	wire dead;
	wire writeEn;
	wire enable = 1'b1;
	
	wire move, attack_out;
	wire [7:0] x_out;
	wire [6:0] y_out;
	
	enemy_control ec(clock, reset_n, go, enable, health, x_pos, speed, attack, dead, writeEn);
	
	enemy_datapath ed(clock, reset_n, speed, attack, x_pos, x_out, y_out, move, attack_out);
	
=======
module enemycd(clock, reset_n, go, health, x_pos, speed, attack, dead, writeEn);
speed, attack, x_pos, x_out, y_out, move, attack_out



>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a

endmodule


<<<<<<< HEAD
module enemy_control(clock, reset_n, go, enable, health, x_pos, speed, attack, dead, writeEn);
=======



module enemy_control(clock, reset_n, go, health, x_pos, speed, attack, dead, writeEn);
>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a

	//list of inputs
	input clock;
	input reset_n;
	input go;
	input [3:0] health;
	input enable;
	
	//list of outputs
	output reg [1:0] x_pos;
	output reg speed;
	output reg attack;
	output reg dead;
	output reg writeEn;

	
	reg [3:0] current_state, next_state; 

	//states listed out as local_params
<<<<<<< HEAD
   localparam   LEFT_CALM       			= 3'd0,
				MIDDLE_CALM   					= 3'd1,
				RIGHT_CALM       				= 3'd2,
				LEFT_AGGRESSIVE    			= 3'd3,
				MIDDLE_AGGRESSIVE          = 3'd4,
				RIGHT_AGGRESSIVE				= 3'd5,
				DEAD								= 3'd6;
=======
   localparam   LEFT_CALM       				= 3'd0,
				MIDDLE_CALM   					= 3'd1,
				RIGHT_CALM       				= 3'd2,
				LEFT_AGGRESSIVE    				= 3'd3,
				MIDDLE_AGGRESSIVE          		= 3'd4,
				RIGHT_AGGRESSIVE				= 3'd5,
				DEAD							= 3'd6;
>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a
					 
	//finite state machine transition

	// shoudnt we wait for the counter to finish counting before changing states??


		always @(*)
			begin 
				if (enable)
					begin
						case (current_state)
							 LEFT_CALM: next_state 				= go ? RIGHT_CALM : MIDDLE_CALM;
							 MIDDLE_CALM: next_state 			= go ? RIGHT_CALM : LEFT_CALM;
							 RIGHT_CALM: next_state 			= go ? MIDDLE_CALM : LEFT_CALM;
							 LEFT_AGGRESSIVE: next_state 		= go ? RIGHT_AGGRESSIVE : MIDDLE_AGGRESSIVE;
							 MIDDLE_AGGRESSIVE: next_state 	= go ? RIGHT_AGGRESSIVE: LEFT_AGGRESSIVE;
							 RIGHT_AGGRESSIVE: next_state 	= go ? MIDDLE_AGGRESSIVE: LEFT_AGGRESSIVE;
							 //TODO: FIX DEAD STATE
							 DEAD: next_state = DEAD;
						default:  next_state = LEFT_CALM;
					   endcase
					 end
		 end

		 //how to change between states
		 always @(*)
			begin
				if (enable)
				begin
				
				  //Speed = 0 -> RateDivider (__Hz)
				  //Speed = 1 -> RateDivider (2*__Hz)
				  speed = 1'b0;
				
				  //Attack = 0 -> Wait for 4 position changes
				  //Attack = 1 -> Wait for 2 position changes
				  attack = 1'b0;
				  
				  //X_pos = 2'b01 (1) -> Change VGA_X to 20
				  //X_pos = 2'b10 (2) -> Change VGA_X to 60
				  //X_pos = 2'b11 (3) -> Change VGA_X to 100
				  x_pos = 2'b00;
				  
				  //dead signal necessay
				  dead = 1'b0;
				  
				  writeEn = 1'b0;
				  
				  case (current_state)
						LEFT_CALM: 
							begin
								x_pos = 2'b01;
							end
						MIDDLE_CALM:
							begin
								x_pos = 2'b10;
							end
						RIGHT_CALM:
							begin
								x_pos = 2'b11;
							end
						LEFT_AGGRESSIVE:
							begin
								x_pos  = 2'b01;
								speed  = 1'b1;
								attack = 1'b1;
							end
						MIDDLE_AGGRESSIVE:
							begin
								x_pos  = 2'b10;
								speed  = 1'b1;
								attack = 1'b1;
							end
						RIGHT_AGGRESSIVE:
							begin
								x_pos  = 2'b11;
								speed  = 1'b1;
								attack = 1'b1;
							end
						//TODO DEAD CONTROL SIGNALS
						DEAD:
							begin
								dead = 1'b1;
							end
				  endcase
			 end
	    end
		
		 always @(posedge clock)
			begin

					  if (!reset_n)
							current_state <= LEFT_CALM;
					//if the opponent has less than half their health, 
					//they become more aggressive, move into different set of states
					  else if (enable)
							begin
						   if (health < 4'd6 && current_state < 4'd3)
								current_state <= next_state + 3;
						  else if (health == 4'b0)
								current_state <= DEAD;
						  else
								current_state <= next_state;
							end
			end


endmodule

 module enemy_datapath(clock, resetn, speed, attack, x_pos, x_out, y_out, move, attack_out);

	// singlebit inputs
	input clock;
	input resetn;

	input speed;
	input attack;
	input [1:0] x_pos; // two bit because it is used for states in our fsm.

	// outputs
	output [7:0] x_out; // 8 bits following the lab.
	output [6:0] y_out;
	output move;
	output attack_out;

	// used to set the x co - ordinate output at the end.
<<<<<<< HEAD
	reg [7:0] x;
=======
	wire [7:0] x;
>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a

	// set the x co - ordinate to either 20, 60, 100 based on x_pos.
	always @(posedge clock) begin

<<<<<<< HEAD
		if (x_pos == 2'b01)
			x <= 8'b00010100; //set x to 20
		else if (x_pos == 2'b10)
			x <= 8'b00111100; //set x to 60
		else if (x_pos == 2'b11)
			x <= 8'b01100100; //set x to 100
=======
		if (x_pos == 2'b00)
			x = 8'b00010100; //set x to 20
		else if (x_pos == 2'b01)
			x = 8'b00111100; //set x to 60
		else if (x_pos == 2'b10)
			x = 8'b01100100; //set x to 100
>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a

	end

	assign x_out = x;
	assign y_out = 7'b1000; // SET A CONSTANT FOR Y

	// fix the value for rate_dividers (Lab 5 part 2)
	
	wire [27:0] hz05, hz025;

	rate_divider r05hz(clk, reset_n, {1'b0, 27'd99999999}, hz05);
	rate_divider r025hz(clk, reset_n, {28'd499999999}, hz025); 

	// use this for attacking and moving
<<<<<<< HEAD
	reg go;
=======
	wire go;
>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a
	
	// when go is 0 then we have waited for hzT amount of time.
	always @(*)
		begin
			case(speed)
<<<<<<< HEAD
				1'b0: go <= (hz025 == 0) ? 1 : 0;
				1'b1: go <= (hz05 == 0) ? 1 : 0;
=======
				1'b0: go = (hz025 == 0) ? 1 : 0;
				1'b1: go = (hz05 == 0) ? 1 : 0;
>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a
			endcase
		end

	// count the number of moves we have made.
	reg [1:0] move_count;

	always @(posedge clk)
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


	wire should_attack;

	// logic to make the player attack.
	attack a1(clk, resetn, move_count, attack, should_attack);

	// relay information back to LFSR as enable.
	assign move = go;
	assign should_attack = attack_out;

endmodule

module attack(clk, reset_n, move_count, attack, q);
<<<<<<< HEAD
	input move_count, clk, reset_n, attack;
=======
	input move_count, clk, reset_n;
>>>>>>> 0e591803f642168b4ab8f0694fa1dddee68d880a
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
