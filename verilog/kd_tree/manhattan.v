module manhattan (clk, rst, en, axis, a, b, c, dist_out, single_dist_out, done);

// a has current, b has parent, and c has best

parameter dim = 3, data_range = 255;

localparam dim_size 	  = $clog2(data_range),
			  dist_size   = $clog2(data_range*dim),
			  center_size = dim*dim_size,
			  axis_size   = $clog2(dim);

input clk, rst, en; 
input [axis_size - 1:0] axis;
input [center_size - 1:0] a, b, c;
output [dist_size - 1:0] dist_out;
output reg [dim_size - 1:0] single_dist_out;
output done;

wire [dim_size:0] dx, dy, dz, dx_d, dy_d, dz_d;
wire [dim_size:0] abs_delta_x,abs_delta_y,abs_delta_z, abs_delta_x_d, abs_delta_y_d, abs_delta_z_d;

assign done = 1'b1;
assign dx = (en) ? a[0+:dim_size] - b[0+:dim_size] : {dim_size{1'b0}};
assign dy = (en) ? a[dim_size+: dim_size] - b[dim_size+: dim_size] : {dim_size{1'b0}};
assign dz = (en) ? a[2*dim_size+: dim_size] - b[2*dim_size+: dim_size] : {dim_size{1'b0}};

assign abs_delta_x = (en) ? (dx[dim_size] ? -dx : dx) : {dim_size{1'b0}};
assign abs_delta_y = (en) ? (dy[dim_size] ? -dy : dy) : {dim_size{1'b0}};
assign abs_delta_z = (en) ? (dz[dim_size] ? -dz : dz) : {dim_size{1'b0}};

assign dx_d = (en) ? c[0+:dim_size] - b[0+:dim_size] : {dim_size{1'b0}};
assign dy_d = (en) ? c[dim_size+: dim_size] - b[dim_size+: dim_size] : {dim_size{1'b0}};
assign dz_d = (en) ? c[2*dim_size+: dim_size] - b[2*dim_size+: dim_size] : {dim_size{1'b0}};

assign dist_out = (en) ? (abs_delta_x + abs_delta_y + abs_delta_z) : {dist_size{1'b0}};

assign abs_delta_x_d = (en) ? (dx_d[dim_size] ? -dx_d : dx_d) : {dim_size{1'b0}};
assign abs_delta_y_d = (en) ? (dy_d[dim_size] ? -dy_d : dy_d) : {dim_size{1'b0}};
assign abs_delta_z_d = (en) ? (dz_d[dim_size] ? -dz_d : dz_d) : {dim_size{1'b0}};
 

always@* begin
if (en) 
	case(axis) 
		2'b00: single_dist_out = abs_delta_z;//abs_delta_x_d;
		2'b01: single_dist_out = abs_delta_y;
		2'b10: single_dist_out = abs_delta_x;//abs_delta_z_d;
		2'b11: single_dist_out = {dim_size{1'b0}};
	endcase
else
	single_dist_out = {dim_size{1'b0}};
end

endmodule

// pipeline this later
// output done will be implemented with pipelining