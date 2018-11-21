module lfsr(clock, reset_n, enable, counter_val, random_pos);

	input clock;
	input reset_n;
	// we need enable so we can set a random seed for the LFSR
	input enable;
	input [7:0] counter_val;
	
	// 1 bit position of XOR'd values
	// also serves as the go in the control
	output random_pos;
	
	// stores total value in LSFR
	reg [7:0] LFSR_val;
	
	// random values
	wire end_val = LFSR_val[6] ^ LFSR_val[2];
	
	// counter value helps find seed for LFSR
	
	// flag to determine whether the LFSR seed value has been set
	// necessary to allow it to be pseudo-random
	reg LFSR_set;
	
	
	always @(posedge clock)
		begin
			// on reset we can use any value, set flag to 0 (not set)
			if (!reset_n)
				begin
					LFSR_val <= 8'b11111110;
					LFSR_set <= 1'b0;
				end
			// while enable is off and flag = 0, we can update 
			// the LSFR value to be a random seed
			else if (!enable & !LFSR_set)
				begin
					LFSR_val <= (counter_val != 8'b0) ? 8'b01110111 : 8'b11111110;
					LFSR_set <= 1'b1;
				end
			// when we need the LSFR to work, we can generate our pseudorandom values
			else if (enable)
				LFSR_val <= {LFSR_val[6], LFSR_val[5], LFSR_val[4], LFSR_val[3],
								 LFSR_val[2], LFSR_val[1], LFSR_val[0], end_val};
		end
	
	//end val will be pseudorandom, so this is all we need
	assign random_pos = end_val;
		
	
endmodule


