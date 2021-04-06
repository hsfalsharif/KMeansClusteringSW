`timescale 1ns/1ns

module cluster_ce_tb();

localparam dim = 3, data_range = 255, dim_size = $clog2(data_range), center_size = dim*dim_size, axis_size = $clog2(dim);

reg clk, rst, en, sorting, left_en, right_en;
reg [center_size - 1:0] left, parent, right, point_in;
reg [axis_size - 1:0] axis;
wire stable, left_switch, right_switch;
wire [center_size - 1:0] new_left, new_parent, new_right;
wire [axis_size - 1:0] child_axis;

cluster_CE ce_test(clk, rst, en, sorting, left_en, right_en, left, parent, right,
point_in, axis, stable, left_switch, parent_switch, right_switch, new_left, new_parent, new_right, child_axis);

initial begin
	clk = 0; rst = 0;
	#5 rst = 1; clk = 1; en = 0; sorting = 0; left_en = 0; right_en = 0;
	#5 rst = 0; clk = 0; en = 1; sorting = 1; left_en = 1; right_en = 1;
	repeat(200) #5 clk = ~clk;
end

initial begin
	#20 left = 8'd101; parent = 8'd102; right = 8'd103; // l < p < r, normal case
	#20 left = 8'd150; parent = 8'd99; right = 8'd233;  // p < l < r
	#20 left = 8'd5; parent = 8'd1; right = 8'd3;       // p < r < l
	#20 left = 8'd32; parent = 8'd167; right = 8'd17;   // r < l < p
	#20 left = 8'd255; parent = 8'd254; right = 8'd253; // r < p < l
	#20 left = 8'd199; parent = 8'd201; right = 8'd42; 
	#20 left = 8'd50; parent = 8'd150; right = 8'd60;
	#20 $finish;
end

endmodule
