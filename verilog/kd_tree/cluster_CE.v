module cluster_CE(clk, rst, en, sorting, left, parent, right,
point_in, axis, stable, left_switch, parent_switch, right_switch, new_left, new_parent, new_right, child_axis);

parameter dim = 3, data_range = 255;
localparam dist_size = $clog2(data_range*dim), dim_size = $clog2(data_range), center_size = dim*dim_size;

input clk, rst, en, sorting, left_switch, parent_switch, right_switch;
input [center_size - 1:0] left, parent, right;
input [dim_size - 1:0] axis;
output stable, left_switch, parent_switch, right_switch;
output reg [center_size - 1:0] new_left, new_parent, new_right;
output [dim_size - 1:0] child_axis;



assign A = left > parent;
assign B = parent > right;
assign C = left > right;

assign stable = !A && !B && !C;
assign child_axis = (axis + 1 != 4) ? axis + 1 : 0;

assign left_switch   = A || C || (A && C) || (B && C);
assign parent_switch = A || B || (A && C) || (B && C);
assign right_switch  = B || C || (A && C) || (B && C);

wire [dist_size - 1:0] dist;
wire [dim_size - 1:0] axis_dist;


manhattan #(.dim(dim), .data_range(data_range)) m(clk, rst, axis, point, old_center, dist, axis_dist, dist_done);

always@* begin
	if (time_to_live && en && sorting)
		case({A, B, C})
			3'b000: begin new_left = left; new_parent = parent; new_right = right; end
			3'b001: begin new_left = right; new_parent = parent; new_right = left; end
			3'b010: begin new_left = left; new_parent = right; new_right = parent; end
			3'b011: begin new_left = right; new_parent = left; new_right = parent; end
			3'b100: begin new_left = parent; new_parent = left; new_right = right; end
			3'b101: begin new_left = parent; new_parent = right; new_right = left; end
			3'b110: begin new_left = left; new_parent = parent; new_right = right; end
			3'b111: begin new_left = right; new_parent = parent; new_right = left; end
		endcase
	else begin
		new_left = left; new_parent = parent; new_right = right;
	end
end

endmodule
