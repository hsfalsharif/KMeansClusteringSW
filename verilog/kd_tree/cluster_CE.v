module cluster_CE(clk, rst, en, sorting, point_prop, left_en, right_en, left, parent, right,
axis, stable, send_left, send_right, left_switch, parent_switch, right_switch, new_left, new_parent, new_right);

// For the point_prop situation, old_center will come from left, point will from parent, best_center will come from right
// best_center will come out from new_parent
parameter dim = 3, data_range = 255 ,name="unknown";

localparam dist_size   = $clog2(data_range*dim), 
			  dim_size    = $clog2(data_range),
			  center_size = dim*dim_size,
			  axis_size   = $clog2(dim);

input clk, rst, en, sorting, point_prop, left_en, right_en;
input [center_size - 1:0] left, parent, right;
input [axis_size - 1:0] axis;
output stable, send_left, send_right, left_switch, parent_switch, right_switch;
output reg [center_size - 1:0] new_left, new_parent, new_right;

// we will probably need a reg for point, we will also need to make cluster_CE sequential
wire [dim_size - 1:0] left_1D, parent_1D, right_1D;
wire [dist_size - 1:0] dst, best_dist;
wire [dim_size - 1:0] axis_dist;
wire [dim_size - 1:0] dx,dy,dz;
wire [dim_size - 1:0] abs_delta_x,abs_delta_y,abs_delta_z;

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

assign dx = right[0+:dim_size] - parent[0+:dim_size];
assign dy = right[dim_size+: dim_size] - parent[dim_size+: dim_size];
assign dz = right[2*dim_size+: dim_size] - parent[2*dim_size+: dim_size];

assign abs_delta_x =  dx[dim_size-1] ? -dx : dx;
assign abs_delta_y =  dy[dim_size-1] ? -dy : dy;
assign abs_delta_z =  dz[dim_size-1] ? -dz : dz;
assign best_dist = abs_delta_x + abs_delta_y + abs_delta_z;

manhattan #(.dim(dim), .data_range(data_range)) m_current(
																			.clk(clk),
																			.rst(rst),
																			.en(point_prop),
																			.axis(axis),
																			.a(left),
																			.b(parent),
																			.c(right),
																			.dist_out(dst),
																			.single_dist_out(axis_dist),
																			.done(dst_done)
																			);
																			
assign go_left = parent_1D < right_1D; // MIGHT NEED TO CHECK THIS CONDITION LATER
assign other_branch = best_dist > axis_dist; // WE MIGHT NEED TO MAKE BEST_DIST ABSOLUTE VALUE LATER
assign send_left = point_prop && (go_left || (!go_left && other_branch));
assign send_right = point_prop && (!go_left || (go_left && other_branch));

assign change_best = best_dist > dst; // this is not an output, this controls the best value


always@* begin

//$display("ABC: %d%d%d, Left: %x, Parent: %x, Right: %x, New Left: %x, New Parent: %x, New Right: %x", A, B, C, left, parent, right, new_left, new_parent, new_right);
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
else if (en && point_prop) begin
$display("dx: %d dy: %d dz: %d abs_dx: %d abs_dy: %d abs_dz: %d best_dist: %d axis_dist: %d", dx, dy, dz, abs_delta_x, abs_delta_y, abs_delta_z, best_dist, axis_dist);
	if (change_best)
		new_parent = left;
	else
		new_parent = right;
	new_right = {center_size{1'b0}};
	new_left = {center_size{1'b0}};
end

else
	begin new_left = left; new_parent = parent; new_right = right; end
end

endmodule
