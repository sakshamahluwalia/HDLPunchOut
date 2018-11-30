module enemy_meta_datapath(CLOCK_50, resetn, emd_enable, should_plot, ecEn, enemy_writeEn, x_out, y_out, start_plot);
	input clock;
	input reset_n;
	input emd_enable;
	input should_plot;
	input ecEn;
	
	output reg enemy_writeEn;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	output reg start_plot;

	//enemy_attributes
	
	wire movement;
	wire speed;
	wire attack;
	wire dead;
	wire [1:0] x_pos;
	wire [5:0] health = 6'b000111;
	wire initiate_attack;
	
	wire [7:0] en_x;
	wire [6:0] en_y;
	
	//lfsr enable governed by datapath output
	wire lfsrEnable;
	
//	lfsr lfsr0(
//			.clock(clock),
//			.reset_n(resetn),
//			.enable(lfsrEnable),
//			.counter_val(8'b10110101),
//			.random_pos(movement)
//	);
	
	always @(posedge clock)
		begin
			if (!reset_n)
				begin
					x_out <= 8'b0000_0000;
					y_out <= 7'b000_0000;
					enemy_writeEn <= 1'b0;
					start_plot <= 1'b0;
				end
			if (should_plot)
			begin
				x_out <= en_x;
				y_out <= en_y;
				enemy_writeEn <= 1'b1;
				start_plot <= 1'b1;
			end
		end
	
	enemy_control ec0(
			.clock(clock), 
			.reset_n(resetn),
			.enable(ecEn),
			.go(1'b0), 
			.health(health), 
			.x_pos(x_pos), 
			.speed(speed), 
			.attack(attack), 
			.dead(dead),
			.writeEn(writeEn)
	);
	
	enemy_datapath ed0(
			.clock(clock), 
			.resetn(resetn),
			.enable(ecEn),
			.speed(speed), 
			.attack(attack), 
			.x_pos(x_pos), 
			.x_out(en_x), 
			.y_out(en_Y), 
			.move(lfsrEnable), 
			.attack_out(initiate_attack)
	);
	
endmodule
