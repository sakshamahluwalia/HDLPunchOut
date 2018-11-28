module enemy_control(clock, reset_n, block, health, can_be_hit);

	//list of inputs
	input clock;
	input reset_n;
	input block;
	input r_punch;
	input l_punch;
	input [3:0] health;
	
	//list of outputs
	output can_be_hit;
	output right_up;
	output left_up;

	output plot;

	reg [3:0] current_state, next_state; 

	//states listed out as local_params
   localparam   INITIAL 	= 3'd0,
				BLOCKED		= 3'd1,
				RIGHT_PUNCH = 3'd2,
				LEFT_PUNCH  = 3'd3,
				DRAW		= 3'd4,
				DEAD 		= 3'd5;
					 
	//finite state machine transition

		// using key[x] as input, allow the health of the user to decrease based on the state.
		always @(*)
			begin 
				case (current_state)
					 INITIAL: 		next_state 			= block ? BLOCKED : INITIAL;
					 INITIAL: 		next_state 			= r_punch ? RIGHT_PUNCH : INITIAL;
					 INITIAL: 		next_state 			= l_punch ? LEFT_PUNCH : INITIAL;
					 BLOCKED: 		next_state 			= block ? INITIAL : BLOCKED;
					 RIGHT_PUNCH: 	next_state 			= r_punch ? RIGHT_PUNCH : DRAW;
					 LEFT_PUNCH: 	next_state 			= l_punch ? LEFT_PUNCH : DRAW;
					 DRAW:			next_state			= DRAW; //can I add a clock variable here.
					 DEAD: 			next_state 			= DEAD;
				default:  next_state = INITIAL;
			  endcase
		 end

		always @(*)
			begin

				plot = 1'b0;
			  	
			  	// if the user is in the blocked state, punches will not affect the health of the player.
				case (current_state)
					INITIAL: 
						begin
							can_be_hit = 1'b1;
						end
					BLOCKED:
						begin
							can_be_hit = 1'b0;
						end
					//TODO DEAD CONTROL SIGNALS
					RIGHT_PUNCH:
						begin
							can_be_hit	= 1'b1;
							right_up 	= 1'b1;
						end
					LEFT_PUNCH:
						begin
							can_be_hit	= 1'b1;
							left_up 	= 1'b1;
						end
					DRAW:
						begin
							plot	= 1'b1;
						end
					DEAD:
						begin
							dead = 1'b1;
						end
			  	endcase
		 	end
		
		 always @(posedge clock)
			begin
			  	if (!reset_n)
					current_state <= INITIAL;

				// if the health is 0 end game.
				else if (health == 4'b0)
					current_state <= DEAD;

				// after the plotting wait and then go back into the initial state.
				if (plot == 1'b1)
					current_state <= INITIAL;

				else
					current_state <= next_state;
			end


endmodule
