module cluster_PE (clk, rst, en, init, start_iter, receive_point, inc, update, sorting,
parent_switch, child_switch, next_level, point_in, parent_in, child_in, depth_in,
stable, ce_en, parent_out, child_out, point_out, child_depth);

// also think about converting this to a state machine by combining the control signals into a state register

parameter dim = 3, data_range = 255, max_n = 1000, max_depth = 16, initial_center = 0, name="unknown";

localparam  dim_size     = $clog2(data_range),
				center_size  = dim*dim_size,
				counter_size = $clog2(max_n),
				acc_size     = $clog2(dim_size*max_n),
				depth_size   = $clog2(max_depth);

input clk, rst, en, init, start_iter, receive_point, inc, update, sorting, parent_switch, child_switch, next_level;
input [center_size - 1:0] point_in, parent_in, child_in;
input [depth_size - 1:0] depth_in;
output stable, ce_en; 								// ce_en enables node's cluster_ce, if time_to_live = 0 the node's
output [center_size - 1:0] point_out;						// comparator is disabled during sorting so no switching can occur here
output reg [center_size - 1:0] parent_out, child_out; // + if !distance_calc the node's comparator is disabled during point_propogation
output [depth_size - 1:0] child_depth;						// so it will stop calculating distances


// dim is number of dimensions, data_range is maximum allowable range for the data, max_n is the max number of data points,
// dim_size is the number of bits required to represent the data range, center_size is the number of bits to represent
// the centre combining by concatenating all of the dimensions, counter_size is the number of bits required to represent the
// maximum number of points, acc_size is the number of bits required to represent an accumulator, dist_size is the number of
// bits required to represent the maximum allowable distance, axis_size is the number of bits required to represent the
// number of axes, depth_size is the number of bits required to represent the depth.

reg [acc_size - 1:0] accX, accY, accZ;
reg [counter_size - 1:0] counter;
reg [center_size - 1:0] old_center, new_center, point;
reg [depth_size - 1:0] depth, time_to_live;
assign distance_calc = 1'b1; // distance_calc enables the ce to perform distance calculations during the point propogation stage

// assign center_out = old_center; // UPDATE: changed center_out to parent_out and child_out to control the dataflow direction
assign ce_en = (time_to_live != 0) || (distance_calc); // distance_calc 
assign child_depth = depth + 1;

always@(posedge clk) begin
	if(rst) begin
		accX <= {acc_size{1'b0}};
		accY <= {acc_size{1'b0}};
		accZ <= {acc_size{1'b0}};
		counter <= {counter_size{1'b0}};
		old_center <= initial_center;
		new_center <= {center_size{1'b0}};
		point <= {center_size{1'b0}};
		time_to_live <= {depth_size{1'b0}};
	end
	else if (en) begin
		if (init) begin
			old_center <= parent_in;
			// depth <= depth_in; we need to add depth_in using a signal other than init
		end
		if(start_iter) begin // the things that need to be done at the beginning of each iteration
			time_to_live <= depth;
			new_center <= 0;
		end
		if (receive_point) begin
			point <= point_in;
			$display("Receive Point => Point: [%d, %d, %d], Point_In: [%d, %d, %d]", point[0+:dim_size], point[dim_size+: dim_size], point[2*dim_size+: dim_size], point_in[0+:dim_size], point_in[dim_size+: dim_size], point_in[2*dim_size+: dim_size]);
		end
		if (inc) begin
			accX <= point[0+:dim_size];
			accY <= point[dim_size+: dim_size];
			accZ <= point[2*dim_size+: dim_size];
			counter <= counter + 1'b1;
			$display("Inc => Point: [%d, %d, %d], Acc: [%d, %d, %d], Counter: %d", point[0+:dim_size], point[dim_size+: dim_size], point[2*dim_size+: dim_size], accX, accY, accZ, counter);
		end
		if (update) begin
		// enable the divider
		// perform division to get new_center
		// check for local stability
		// check for global stability
		// assign old_center to new_center
		end
		if (next_level) begin
			time_to_live <= time_to_live - 1;
			$display("Next Level => Time To Live: %d", time_to_live);
		end
		if (sorting && parent_switch) begin
			parent_out <= old_center;
			old_center <= parent_in;
			$display("Parent Switch => Old Center: [%d, %d, %d], Parent Center: [%d, %d, %d], Child Center: [%d, %d, %d]", old_center[0+:dim_size], old_center[dim_size+: dim_size], old_center[2*dim_size+: dim_size], parent_in[0+:dim_size], parent_in[dim_size+: dim_size], parent_in[2*dim_size+: dim_size], parent_out[0+:dim_size], parent_out[dim_size+: dim_size], parent_out[2*dim_size+: dim_size], child_in[0+:dim_size], child_in[dim_size+: dim_size], child_in[2*dim_size+: dim_size], child_out[0+:dim_size], child_out[dim_size+: dim_size], child_out[2*dim_size+: dim_size]);
			end
		else if (sorting && child_switch) begin
			child_out <= old_center; 
			old_center <= child_in; // will this cause child_out to take the value of child_in? or can we guarantee that child_out has sent out the value of old_center before it has changed the value of old_center?
			$display("Parent Switch => Old Center: [%d, %d, %d], Parent Center: [%d, %d, %d], Child Center: [%d, %d, %d]", old_center[0+:dim_size], old_center[dim_size+: dim_size], old_center[2*dim_size+: dim_size], parent_in[0+:dim_size], parent_in[dim_size+: dim_size], parent_in[2*dim_size+: dim_size], parent_out[0+:dim_size], parent_out[dim_size+: dim_size], parent_out[2*dim_size+: dim_size], child_in[0+:dim_size], child_in[dim_size+: dim_size], child_in[2*dim_size+: dim_size], child_out[0+:dim_size], child_out[dim_size+: dim_size], child_out[2*dim_size+: dim_size]);
			end
	end
end

endmodule
