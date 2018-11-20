module enemy_control(clock, reset_n, go, health, x_pos, speed, attack, dead);

	//list of inputs
	input clock;
	input reset_n;
	input go;
	input [3:0] health;
	
	//list of outputs
	output reg [1:0] x_pos;
	output reg speed;
	output reg attack;
	output reg dead;

	
	reg [3:0] current_state, next_state; 

	//states listed out as local_params
   localparam   LEFT_CALM       					= 3'd0,
					 MIDDLE_CALM   					= 3'd1,
					 RIGHT_CALM       				= 3'd2,
					 LEFT_AGGRESSIVE    				= 3'd3,
					 MIDDLE_AGGRESSIVE          	= 3'd4,
					 RIGHT_AGGRESSIVE					= 3'd5,
					 DEAD									= 3'd6;
					 
	//finite state machine transition			 
	always @(*)
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

	 //how to change between states
	 always @(*)
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
   
    always @(posedge clock)
		begin
        if (!reset_n)
            current_state <= LEFT_CALM;
		//if the opponent has less than half their health, 
		//they become more aggressive, move into different set of states
		  else if (health < 4'd6 && current_state < 4'd3)
				current_state <= next_state + 3;
		  else if (health == 4'b0)
				current_state <= DEAD;
        else
            current_state <= next_state;
		end



endmodule