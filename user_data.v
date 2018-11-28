module user_data(SW, clock, reset_n, y_out_r, y_out_l, x_out);

	input [3:0] SW;
	input clock;
	input reset_n;

	output x_out;

	reg r_y_out;
	reg l_y_out;

	always(@posedge clock)
		begin
			if (SW[0] == 1'b1)

				r_y_out <= 7'b1000;

			else if (SW[1] == 1'b1)

				l_y_out <= 7'b1000;

		end


	assign y_out_r = r_y_out;
	assign y_out_l = l_y_out;
	assign x_out = 8'b0;
	

endmodule