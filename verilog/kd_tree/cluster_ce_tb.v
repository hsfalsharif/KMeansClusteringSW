`timescale 1ns/1ns

module cluster_ce_tb();

localparam dim 		  = 3,
			  data_range  = 255,
			  dim_size    = $clog2(data_range),
			  center_size = dim*dim_size,
			  axis_size   = $clog2(dim);

reg clk, rst, en, sorting, point_prop, left_en, right_en;
reg [center_size - 1:0] left, parent, right;
reg [axis_size - 1:0] axis;
wire stable, left_switch, right_switch;
wire [center_size - 1:0] new_left, new_parent, new_right;

cluster_CE ce_test(clk, rst, en, sorting, point_prop, left_en, right_en, left, parent, right,
axis, stable, send_left, send_right, left_switch, parent_switch, right_switch, new_left, new_parent, new_right);

initial begin
	clk = 0; rst = 0;
	#5 rst = 1; clk = 1; en = 0; sorting = 0; left_en = 0; right_en = 0;
	#5 rst = 0; clk = 0; en = 1; sorting = 1; left_en = 1; right_en = 1;
	repeat(200) #5 clk = ~clk;
end

// left, parent, right, and point_in are actually 24 bits but here we are testing 8 bit values
initial begin
	#20 left = 8'd101; parent = 8'd102; right = 8'd103; axis = 2'd0; // l < p < r, normal case
	#20 left = 8'd150; parent = 8'd99; right = 8'd233; axis = 2'd1;  // p < l < r
	#20 left = 8'd5; parent = 8'd1; right = 8'd3; axis = 2'd2;       // p < r < l
	#20 left = 8'd32; parent = 8'd167; right = 8'd17; axis = 2'd0;   // r < l < p
	#20 left = 8'd255; parent = 8'd254; right = 8'd253; axis = 2'd0; // r < p < l
	#20 left = 8'd199; parent = 8'd201; right = 8'd42; 
	#20 left = 8'd50; parent = 8'd150; right = 8'd60;
	// testing when sorting is 0
	#20 left = 8'd0; parent = 8'd0; right = 8'd0; sorting= 1'd0;
	#20 left = 8'd101; parent = 8'd102; right = 8'd103; axis = 2'd0; // l < p < r, normal case
	#20 left = 8'd150; parent = 8'd99; right = 8'd233; axis = 2'd1;  // p < l < r
	#20 left = 8'd5; parent = 8'd1; right = 8'd3; axis = 2'd2;       // p < r < l
	#20 left = 8'd32; parent = 8'd167; right = 8'd17; axis = 2'd0;   // r < l < p
	#20 left = 8'd255; parent = 8'd254; right = 8'd253; axis = 2'd0; // r < p < l
	#20 left = 8'd199; parent = 8'd201; right = 8'd42; 
	#20 left = 8'd50; parent = 8'd150; right = 8'd60;
	// testing when left_en is 0
	#20 left = 8'd0; parent = 8'd0; right = 8'd0; sorting= 1'b1; left_en = 1'b0;
	#20 left = 8'd101; parent = 8'd102; right = 8'd103; axis = 2'd0; // l < p < r, normal case
	#20 left = 8'd150; parent = 8'd99; right = 8'd233; axis = 2'd1;  // p < l < r
	#20 left = 8'd5; parent = 8'd1; right = 8'd3; axis = 2'd2;       // p < r < l
	#20 left = 8'd32; parent = 8'd167; right = 8'd17; axis = 2'd0;   // r < l < p
	#20 left = 8'd255; parent = 8'd254; right = 8'd253; axis = 2'd0; // r < p < l
	#20 left = 8'd199; parent = 8'd201; right = 8'd42; 
	#20 left = 8'd50; parent = 8'd150; right = 8'd60;
	// testing when right_en is 0
	#20 left = 8'd0; parent = 8'd0; right = 8'd0; sorting= 1'b1; left_en = 1'b1; right_en = 1'b0;
	#20 left = 8'd101; parent = 8'd102; right = 8'd103; axis = 2'd0; // l < p < r, normal case
	#20 left = 8'd150; parent = 8'd99; right = 8'd233; axis = 2'd1;  // p < l < r
	#20 left = 8'd5; parent = 8'd1; right = 8'd3; axis = 2'd2;       // p < r < l
	#20 left = 8'd32; parent = 8'd167; right = 8'd17; axis = 2'd0;   // r < l < p
	#20 left = 8'd255; parent = 8'd254; right = 8'd253; axis = 2'd0; // r < p < l
	#20 left = 8'd199; parent = 8'd201; right = 8'd42; 
	#20 left = 8'd50; parent = 8'd150; right = 8'd60;
	// testing when left_en is 0 and right_en is 0
	#20 left = 8'd0; parent = 8'd0; right = 8'd0; sorting= 1'b1; left_en = 1'b0; right_en = 1'b0;
	#20 left = 8'd101; parent = 8'd102; right = 8'd103; axis = 2'd0; // l < p < r, normal case
	#20 left = 8'd150; parent = 8'd99; right = 8'd233; axis = 2'd1;  // p < l < r
	#20 left = 8'd5; parent = 8'd1; right = 8'd3; axis = 2'd2;       // p < r < l
	#20 left = 8'd32; parent = 8'd167; right = 8'd17; axis = 2'd0;   // r < l < p
	#20 left = 8'd255; parent = 8'd254; right = 8'd253; axis = 2'd0; // r < p < l
	#20 left = 8'd199; parent = 8'd201; right = 8'd42; 
	#20 left = 8'd50; parent = 8'd150; right = 8'd60;
	
	// testing point propogation => left is old_center, parent is point, right is best_center
	// old_center = 01 02 03 , point = 05 03 06, best_center = 27 90 31, axis is x
	#20 sorting = 1'b0; point_prop = 1'b1; left = {8'd01, 8'd02, 8'd03}; parent = {8'd05, 8'd03, 8'd06}; right = {8'd27, 8'd90, 8'd31}; axis = 2'd0; // new parent = left
	// old_center = 01 02 03 , point = 05 03 06, best_center = 27 90 31, axis is y
	#20 left = {8'd01, 8'd02, 8'd03}; parent = {8'd05, 8'd03, 8'd06}; right = {8'd27, 8'd90, 8'd31}; axis = 2'd1; // new parent = left
	// old_center = 01 02 03 , point = 05 03 06, best_center = 27 90 31, axis is z
	#20 left = {8'd01, 8'd02, 8'd03}; parent = {8'd05, 8'd03, 8'd31}; right = {8'd27, 8'd90, 8'd06}; axis = 2'd2; // new parent = left
	// old_center = 27 90 31 , point = 05 03 06, best_center = 01 02 03, axis is x
	#20 left = {8'd27, 8'd90, 8'd31}; parent = {8'd05, 8'd03, 8'd06}; right = {8'd01, 8'd02, 8'd03}; axis = 2'd0; // new parent = right
	// old_center = 27 90 31 , point = 05 03 06, best_center = 01 02 03, axis is y
	#20 left = {8'd27, 8'd90, 8'd31}; parent = {8'd05, 8'd03, 8'd06}; right = {8'd01, 8'd02, 8'd03}; axis = 2'd1; // new parent = right
	// old_center = 27 90 31 , point = 05 03 06, best_center = 01 02 03, axis is z
	#20 left = {8'd27, 8'd90, 8'd31}; parent = {8'd05, 8'd03, 8'd06}; right = {8'd01, 8'd02, 8'd03}; axis = 2'd2; // new parent = right
	
	
	// old_center = 27 90 31 , point = 30 75 21, best_center =  01 02 03
	// => continue here
	#20 $finish;
end

endmodule
