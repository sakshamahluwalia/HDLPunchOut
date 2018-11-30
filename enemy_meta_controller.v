module enemy_meta_controller(clock, reset_n, emc_enable, should_plot, ecEn);

	input clock;
	input reset_n;
	input emc_enable;
	
	output reg should_plot; //enables plot of where enemy is
	output reg ecEn;    //enables enemy controller to decide next move
	output reg plotEn;
	
	reg [3:0] current_state, next_state; 

	//states listed out as local_params
   localparam     DECIDE_MOVE      				= 3'd0,
						PLOT       				      = 3'd1;
	
	always @(*)
		begin 
			if (emc_enable)
				begin
					case (current_state)
						 DECIDE_MOVE: next_state = plot_finished ? DECIDE_MOVE : PLOT;
						 PLOT: next_state = plot_finished ? DECIDE_MOVE : PLOT;
					default:  next_state = LEFT_CALM;
				   endcase
				end
		end

		 //how to change between states
	 always @(*)
		begin
			if (emc_enable)
				begin
				  ecEn    = 1'b0;
				  should_plot = 1'b0;
				  case (current_state)
						DECIDE_MOVE:
							begin
								ecEN = 1'b1;
							end
						PLOT:
							begin
								should_plot = 1'b1;
							end
				  endcase
				end
		end
		
	 always @(posedge clock)
		begin
				  if (!reset_n)
						current_state <= DECIDE_MOVE;
				  else if (emc_enable)
						current_state <= next_state;
				end
		end
endmodule
