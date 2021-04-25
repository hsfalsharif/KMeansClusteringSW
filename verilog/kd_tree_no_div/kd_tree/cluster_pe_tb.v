`timescale 1ns/1ns

module cluster_pe_tb();

localparam dim 		  = 3,
			  data_range  = 255,
			  max_depth = 16,
			  dim_size 	  = $clog2(data_range),
			  center_size = dim*dim_size,
			  axis_size   = $clog2(dim),
			  depth_size  = $clog2(max_depth);

reg clk, rst, en, init, start_iter, receive_point, inc, update, sorting, parent_switch, child_switch, next_level;
reg [center_size - 1:0] point_in, parent_in, child_in;
reg [depth_size - 1:0] depth_in;
wire stable, go_left, switch_en;
wire [center_size - 1:0] point_out;
wire [center_size - 1:0] parent_out, child_out;
wire [depth_size - 1:0] child_depth;


cluster_PE pe_test (clk, rst, en, init, start_iter, receive_point, inc, update, sorting, parent_switch, child_switch, next_level,
point_in, parent_in, child_in, depth_in, stable, switch_en, parent_out, child_out, point_out, child_depth);


initial begin
	clk = 0; rst = 0;
	#5 rst = 1; clk = 1; en = 0; sorting = 0;
	#5 rst = 0; clk = 0; en = 1; sorting = 1; init = 0;
	repeat(200) #5 clk = ~clk;
end

// test everything that you have right now first then add the update scenario and test it

initial begin
	// initialization
	#20 init = 1; parent_in = 24'd101; depth_in = 3;
	// start iteration
	#20 init = 0; start_iter = 1;
	// receiving a point
	#20 start_iter = 0; receive_point = 1; point_in = 24'd16777215; next_level = 1; // problem here, point_in not being transferred to point
	// adding a point
	#20 receive_point = 0; inc = 1; next_level = 0;
	// parent_switch = 1, switching with parent
	#20 inc = 0; parent_switch = 1; child_switch = 0; point_in = {center_size{1'b0}}; parent_in = 24'd8388608; child_in = 24'd4194304;
	// child_switch = 1, switching with child
	#20 parent_switch = 0; child_switch = 1; parent_in = 24'd2097152; child_in = 24'd1048576;
	// parent_switch = 1 and child_switch = 1, switching with parent
	#20 parent_switch = 1; child_switch = 1; parent_in = 24'd524288; child_in = 24'd262143;
	#20 $finish;
end

endmodule
