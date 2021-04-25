module square_dist(clk,axis,point_x,point_y,point_z,counter,accX,accY,accZ,dist_out,signle_dist_out);

localparam  dim_size     = $clog2(255),
				dim_size2    = 2*dim_size,
				dim          = 3,
				max_n        = 100,
				center_size  = dim*dim_size,
				counter_size = $clog2(max_n),
				counter_size2 = 2*counter_size,
				acc_size     = $clog2(dim_size*max_n),
				acc_size2    = 2*acc_size,
				distance_1d  = 32,
				distance     = distance_1d + dim_size;
parameter to="unknown" ,name="unknown";
input clk;
input [1:0] axis;
input [dim_size -1:0] point_x,point_y,point_z;
input [counter_size -1:0]counter;
input [acc_size -1:0] accX,accY,accZ;
output [distance_1d -1:0] signle_dist_out;
output[distance -1:0] dist_out;


wire [counter_size2-1:0] n2;
wire [acc_size2-1:0] sx2,sy2,sz2;
wire [counter_size-1:0] n;
wire [acc_size - 1:0] sx,sy,sz;
wire [dim_size  -1:0] px,py,pz;
wire [dim_size2 -1:0] px2,py2,pz2;

wire [distance_1d-1:0] dx2,dy2,dz2;

 
assign n = counter;
assign n2 = n*n;
assign sx = accX;
assign sy = accY;
assign sz = accZ;
assign sx2 = sx*sx;
assign sy2 = sy*sy;
assign sz2 = sz*sz;

assign {px,py,pz}  = {point_x,point_y,point_z}; 
assign px2 = px*px;
assign py2 = py*py;
assign pz2 = pz*pz;
assign dx2 = px2* n2 -2*n*sx + sx2;
assign dy2 = py2* n2 -2*n*sy + sy2;
assign dz2 = pz2* n2 -2*n*sz + sz2;

assign dist_out   = dx2 + dy2 + dz2;
assign signle_dist_out = axis == 0 ? dx2 : axis == 1 ? dy2 : dz2;

always @(posedge clk) begin
$display("%s %s point [%x %x %x] center [%x %x %x  %d] d_single [%x %x %x] single: %x total: %x",name,to,point_z,point_y,point_x,sz,sy,sx,n,dz2,dy2,dx2,signle_dist_out,dist_out);
 
end


endmodule















