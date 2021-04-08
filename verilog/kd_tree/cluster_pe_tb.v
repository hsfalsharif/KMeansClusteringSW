`timescale 1ns/1ns

module cluster_pe_tb();

localparam dim 		  = 3,
			  data_range  = 255,
			  dim_size 	  = $clog2(data_range),
			  center_size = dim*dim_size,
			  axis_size   = $clog2(dim),
			  depth_size  = $clog2(max_depth);

reg clk, rst, en, inc, parent_switch, child_switch, receive_point, sorting, next_level;
reg [center_size - 1:0] point_in, parent_in, child_in;
reg [depth_size - 1:0] depth;
wire stable, go_left;
wire [center_size - 1:0] point_out;
wire [center_size - 1:0] parent_out, child_out;
wire [depth_size - 1:0] child_depth;


cluster_PE pe_test (clk, rst, en, inc, parent_switch, child_switch, receive_point, sorting, next_level, point_in, parent_in, child_in,
depth, stable, go_left, parent_out, child_out, point_out, child_depth);


initial begin
	clk = 0; rst = 0;
	#5 rst = 1; clk = 1; en = 0; sorting = 0;
	#5 rst = 0; clk = 0; en = 1; sorting = 1;
	repeat(200) #5 clk = ~clk;
end

endmodule
