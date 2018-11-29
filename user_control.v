module user_control(clock, reset_n, health, rgo, lgo, block, rpunch, lpunch, can_be_hit);

	//list of inputs
	input rgo;
	input lgo;
	input clock;
	input block;
	input reset_n;
	input [3:0] health;

	//list of outputs
	output reg can_be_hit;
	output reg rpunch, lpunch;

	reg [3:0] current_state, next_state; 

	//states listed out as local_params
	localparam   INITIAL 		= 3'd0,
		     left_punch		= 3'd1,
		     right_punch	= 3'd2,
		     blocked		= 3'd3,
		     dead 		= 3'd4;
					 
		//finite state machine transition

		// using key[x] as input, allow the health of the user to decrease based on the state.
		always @(*)
			begin 
				case (current_state)
					INITIAL: 
						begin
							if (rgo)
								next_state = right_punch;
							else if (lgo)
								next_state = left_punch;
							else if (block)
								next_state = blocked;
							else
								next_state = INITIAL;
						end
			
					right_punch: next_state = rgo ? right_punch : INITIAL;
					left_punch: next_state = lgo ? left_punch : INITIAL;
					blocked: next_state = block ? blocked : INITIAL;
					dead: next_state = dead;
						
				default:  next_state = INITIAL;
			  endcase
		 end

		always @(*)
			begin
        			can_be_hit = 1'b0;
        			lpunch = 1'b0;
				rpunch = 1'b0;
			  	// if the user is in the blocked state, punches will not affect the health of the player.
				case (current_state)
					INITIAL: 
						begin
							can_be_hit = 1'b1;
						end
					left_punch: 
						begin
							can_be_hit = 1'b1;
							lpunch = 1'b1;
						end
					right_punch: 
						begin
							can_be_hit = 1'b1;
							rpunch = 1'b1;
						end
					blocked: 
						begin
							can_be_hit = 1'b0;
						end
			  	endcase
		 	end

		 reg counter;
		
		 always @(posedge clock)
			begin
			  	if (!reset_n)
					current_state <= INITIAL;
				else if (health == 4'b0)
					current_state <= dead;
				else
					current_state <= next_state;
			end

endmodule
