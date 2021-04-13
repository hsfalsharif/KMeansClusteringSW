module cluster_CE(clk, rst, en, sorting, left_en, right_en, left, parent, right,
point_in, axis, stable, left_switch, parent_switch, right_switch, go_left, new_left, new_parent, new_right);

parameter dim = 3, data_range = 255 ,name="unknown";

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
wire [dim_size - 1:0] left_1D, parent_1D, right_1D;
assign left_1D = (axis == 0) ? left[0+:dim_size] : ((axis == 1) ? left[dim_size+:dim_size] : left[2*dim_size+:dim_size]);
assign parent_1D = (axis == 0) ? parent[0+:dim_size] : ((axis == 1) ? parent[dim_size+:dim_size] : parent[2*dim_size+:dim_size]);
assign right_1D = (axis == 0) ? right[0+:dim_size] : ((axis == 1) ? right[dim_size+:dim_size] : right[2*dim_size+:dim_size]);

assign A = sorting && left_en && (left_1D > parent_1D);
assign B = sorting && right_en && (parent_1D > right_1D);
assign C = sorting && left_en && right_en && (left_1D > right_1D);

assign stable = (left_en && right_en) ? (!A && !B && !C) : ((left_en && !right_en) ? !A : (!left_en && right_en) ? !B : 1);

assign left_switch   = A || C || (A && C) || (B && C);
assign parent_switch = (A && B && C) ? 1'b0 : (A || B || (A && C) || (B && C));
assign right_switch  = B || C || (A && C) || (B && C);

wire [dist_size - 1:0] dst;
wire [dim_size - 1:0] axis_dst;

manhattan #(.dim(dim), .data_range(data_range)) m(clk, rst, axis, point, old_center, dst, axis_dst, dst_done);

always@* begin
if (en && sorting) begin
$display("(%s) ABC: %d%d%d, Left: %x, Parent: %x, Right: %x, New Left: %x, New Parent: %x, New Right: %x", name,A, B, C, left_1D, parent_1D, right_1D, new_left, new_parent, new_right);
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
	end
else
	begin new_left = left; new_parent = parent; new_right = right; end
end

endmodule
