module cluster_node(clk, rst, en, sorting, parent_switch_in, left_sort_done, self_sort_done, right_sort_done, // what are these sort_done signals??
point_in, left_in, parent_in, right_in, axis_in, depth_in, left_switch_out, right_switch_out,
point_out, left_out, parent_out, right_out, axis_out, depth_out);

parameter dim = 3, data_range = 255, max_n = 1000;

localparam  dim_size = $clog2(data_range), center_size = dim*dim_size, counter_size = $clog2(max_n), acc_size = $clog2(dim_size*max_n), 
dist_size = $clog2(data_range*dim), axis_size = $clog2(dim), depth_size = $clog2(max_depth);

input clk, rst, en, sorting, parent_switch_in, left_sort_done, self_sort_done, right_sort_done;
input [center_size - 1:0] point_in, left_in, parent_in, right_in;
input [axis_size - 1:0] axis_in;
input [depth_size - 1:0] depth_in;
output left_switch_out, right_switch_out;
output [center_size - 1:0] point_out, left_out, parent_out, right_out;
output [axis_size - 1:0] axis_out;
output [depth_size - 1:0] depth_out;




/* TODO: 
	1- move time_to_live here.
	2- add left_en , right_en inside CE.
	4- add left_sort_stable and right_sort_stable as input.
	3- start sorting 
*/
// dim is number of dimensions, data_range is maximum allowable range for the data, max_n is the max number of data points,
// dim_size is the number of bits required to represent the data range, center_size is the number of bits to represent
// the centre combining by concatenating all of the dimensions, counter_size is the number of bits required to represent the
// maximum number of points, acc_size is the number of bits required to represent an accumulator, dist_size is the number of
// bits required to represent the maximum allowable distance, axis_size is the number of bits required to represent the
// number of axes.

// For the switching, there is no such thing as a left_switch_in and a right_switch in. There is also no such thing as a parent_switch_out

wire [center_size - 1:0] center_self_P2C, center_self_C2P;
wire self_child_switch;
reg left_en,right_en;
assign sort_stable_out = self_sort_stable & left_sort_stable & right_sort_stable;
cluster_PE c_pe (
					.clk(clk), 
					.rst(rst), 
					.en(en), 
					inc(1'b0), 
					.parent_switch(parent_switch_in), 
					.child_switch(self_child_switch), 
					.receive_point(1'b0),
					.sorting(1'b1), 
					.next_level(1'b0), 
					.point_in(point_in), 
					.parent_in(parent_in), 
					.child_in(center_self_C2P),
					.depth(depth_in), 
					.stable(x1), .
					.go_left(x2), 
					.parent_out(parent_out), 
					.child_out(center_self_P2C), 
					.point_out(x3), 
					.child_depth(depth_out)
					);

// TODO: Find out how we will generate control signals inc, receive_point, next_level, stable, and go_left
// Also implement the point propogation after verifying that the sort works 

cluster_CE c_ce (.clk(clk), 
					  .rst(rst),
					  .en(en),
					  .sorting(1'b1),
					  .left(left_in), 
					  .parent(center_self_P2C), 
					  .right(right_in),
					  .axis(axis_in), 
					  .stable(sefl_stable), 
					  .left_switch(left_switch_out), 
					  .parent_switch(self_child_switch), 
					  .right_switch(right_switch_out),
					  .new_left(left_out), 
					  .new_parent(center_self_C2P), 
					  .new_right(right_out), 
					  .child_axis(axis_out)
					  );

endmodule
