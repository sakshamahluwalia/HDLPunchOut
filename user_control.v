module enemy_control(clock, reset_n, block, health, can_be_hit);

	//list of inputs
	input clock;
	input reset_n;
	input block;
	input [3:0] health;

	//list of outputs
	output can_be_hit;

	output plot;

	reg [3:0] current_state, next_state; 

	//states listed out as local_params
   localparam   INITIAL 	= 2'd0,
				BLOCKED		= 2'd1,
				DRAW		= 2'd2,
				DEAD 		= 2'd4;
					 
	//finite state machine transition

		// using key[x] as input, allow the health of the user to decrease based on the state.
		always @(*)
			begin 
				case (current_state)
					 INITIAL: 		next_state 			= block ? BLOCKED : INITIAL;
					 BLOCKED: 		next_state 			= block ? INITIAL : BLOCKED;
					 DRAW:			next_state			= DRAW;
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
					
					begin
						if (counter == 1'b1)
							current_state <= INITIAL;
							counter <= 1'b0;
							plot = 1'b0;
						else
							counter <= counter + 1'b1;
					end

				else
					current_state <= next_state;
			end

endmodule