module manhattan #(parameter dim = 3, data_range = 255)(input clk, rst, input [$clog2(dim) - 1:0] axis, input [dim*$clog2(data_range) - 1:0] a, b, 
output [$clog2(data_range*dim) - 1:0] dist_out,
output reg [$clog2(data_range) - 1:0] single_dist_out,
output done);

localparam dim_size = $clog2(data_range);

wire [dim_size-1:0] dx,dy,dz;
wire [dim_size-1:0] abs_delta_x,abs_delta_y,abs_delta_z;

assign done = 1'b1;
assign dx = a[0+:dim_size] - b[0+:dim_size];
assign dy = a[dim_size+: dim_size] - b[dim_size+: dim_size];
assign dz = a[2*dim_size+: dim_size] - b[2*dim_size+: dim_size];

assign abs_delta_x =  dx[dim_size-1] ? -dx : dx;
assign abs_delta_y =  dy[dim_size-1] ? -dy : dy;
assign abs_delta_z =  dz[dim_size-1] ? -dz : dz;
assign dist_out = abs_delta_x + abs_delta_y + abs_delta_z;

always@* begin
	case(axis)
		2'b00: single_dist_out = dx;
		2'b01: single_dist_out = dy;
		2'b10: single_dist_out = dz;
		2'b11: single_dist_out = {dim_size{1'b0}};
	endcase
end

endmodule

// pipeline this later
// output done will be implemented with pipelining