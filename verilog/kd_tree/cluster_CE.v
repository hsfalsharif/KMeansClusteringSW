module cluster_CE(clk, rst, en, sorting, left_en, right_en, left, parent, right,
point_in, axis, stable, left_switch, parent_switch, right_switch, go_left, new_left, new_parent, new_right);

parameter dim = 3, data_range = 255;

localparam dist_size   = $clog2(data_range*dim), 
			  dim_size    = $clog2(data_range),
			  center_size = dim*dim_size,
			  axis_size   = $clog2(dim);

input clk, rst, en, sorting, left_en, right_en;
input [center_size - 1:0] left, parent, right, point_in;
input [axis_size - 1:0] axis;
output stable, left_switch, parent_switch, right_switch, go_left;
output reg [center_size - 1:0] new_left, new_parent, new_right;

// we will probably need a reg for point, we will also need to make cluster_CE sequential

assign A = sorting && left_en && (left > parent);
assign B = sorting && right_en && (parent > right);
assign C = sorting && left_en && right_en && (left > right);

assign stable = (left_en && right_en) ? (!A && !B && !C) : ((left_en && !right_en) ? !A : (!left_en && right_en) ? !B : 1);

assign left_switch   = A || C || (A && C) || (B && C);
assign parent_switch = (A && B && C) ? 1'b0 : (A || B || (A && C) || (B && C));
assign right_switch  = B || C || (A && C) || (B && C);

wire [dist_size - 1:0] dst;
wire [dim_size - 1:0] axis_dst;

manhattan #(.dim(dim), .data_range(data_range)) m(clk, rst, axis, point, old_center, dst, axis_dst, dst_done);

always@* begin
$display("ABC: %d%d%d, Left: %d, Parent: %d, Right: %d, New Left: %d, New Parent: %d, New Right: %d", A, B, C, left, parent, right, new_left, new_parent, new_right);
if (en && sorting)
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
else
	begin new_left = left; new_parent = parent; new_right = right; end
end

endmodule
