module cluster_CE(clk, rst, en, sorting, point_prop, left_en, right_en, returned, left, parent, right,
axis, stable, left_switch, parent_switch, right_switch, first_direction, other_branch, new_left, new_parent, new_right);

// For the point_prop situation, old_center will come from left, point will from parent, best_center will come from right
// best_center will come out from new_parent
parameter dim = 3, data_range = 255 ,name="unknown";

localparam  dist_size   = $clog2(data_range*dim), 
			   dim_size    = $clog2(data_range),
			   center_size = dim*dim_size,
			   axis_size   = $clog2(dim),
            max_n        = 100,
				counter_size = $clog2(max_n),
				acc_size     = $clog2(dim_size*max_n),
			   data_size    = center_size + counter_size + 3*acc_size,
			   data_acc_start = center_size,
			   data_counter_end = counter_size + acc_size,
				counter_size2 = 2*counter_size,
				acc_size2    = 2*acc_size,
				distance_1d  = 32,
				distance     = distance_1d + dim_size;
				
 
input clk, rst, en, sorting, point_prop, left_en, right_en, returned;
input [data_size - 1:0] left, parent, right;
input [axis_size - 1:0] axis;
output stable, left_switch, parent_switch, right_switch, first_direction, other_branch;
output reg [data_size - 1:0] new_left, new_parent, new_right;

// we will probably need a reg for point, we will also need to make cluster_CE sequential
wire [acc_size -1 :0 ] left_accX,left_accY,left_accZ;
wire [acc_size -1 :0 ] right_accX,right_accY,right_accZ;
wire [acc_size -1 :0 ] parent_accX,parent_accY,parent_accZ;
wire [dim_size -1 :0 ] point_x,point_y,point_z;
wire [counter_size -1:0] left_counter,right_counter,parent_counter;



assign {left_counter,left_accZ,left_accY,left_accX} = left;
assign {right_counter,right_accZ,right_accY,right_accX} = right;
assign {parent_counter,parent_accZ,parent_accY,parent_accX} = parent;
assign {point_z,point_y,point_x} = parent;

wire [distance - 1:0] dist_self, best_dist;
wire [distance_1d - 1:0] dx,dy,dz;
wire [distance_1d-1:0] dx2;


assign dx = left_accX < point_x * left_counter;
assign dy = left_accY < point_y * left_counter;
assign dz = left_accZ < point_z * left_counter;

square_dist #(.to("self"),.name(name)) self(.clk(clk)
					  ,.axis(axis)
					  ,.point_x(point_x)
					  ,.point_y(point_y)
					  ,.point_z(point_z)
					  ,.counter(left_counter)
					  ,.accX(left_accX)
					  ,.accY(left_accY)
					  ,.accZ(left_accZ)
					  ,.dist_out(dist_self)
					  ,.signle_dist_out(dx2));
					  
square_dist #(.to("best"),.name(name)) best(.clk(clk)
					  ,.axis(axis) 
					  ,.point_x(point_x)
					  ,.point_y(point_y)
					  ,.point_z(point_z)
					  ,.counter(right_counter)
					  ,.accX(right_accX)
					  ,.accY(right_accY)
					  ,.accZ(right_accZ)
					  ,.dist_out(best_dist)
					  ,.signle_dist_out(dontCare));
																		
assign first_direction = point_prop && (axis==0&&dx||axis==1&&dy||axis==2&&dz); //if first_direction is 1 => we go left, if it is 0 => we go right
assign other_branch = point_prop && returned ? best_dist > dx2 : 1'b0; // WE MIGHT NEED TO MAKE BEST_DIST ABSOLUTE VALUE LATER

assign change_best = point_prop && best_dist > dist_self; // this is not an output, this controls the best value


always@* begin
//$display("%s ce : dx: %x dy: %x dz: %x best_dist> dx2 %x , best_dist > dist_self",name,dx,dy,dz,best_dist>dx2,best_dist>dist_self);

if (en && point_prop) begin

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
