module kmean#(parameter data_size = 100)(input clk, reset,input [0:3*8 - 1]sin,output strb);
localparam unit_size = 8;
localparam len_count = 10;
localparam max_data_size = data_size;
localparam len_acc   = unit_size;
localparam kmax = 16;
localparam max_unit_value = 255;
localparam threshold = 2;
localparam  fetch        = 4'b0000,
				distance     = 4'b0001,
				accumulate   = 4'b0010,
				pipeline     = 4'b0011,
				check        = 4'b0100,
				update 		 = 4'b0101,
				store_points = 4'b0110,
				done         = 4'b0111,
				configure    = 4'b1000,
				diff         = 4'b1001,
				sqaure_dist  = 4'b1010,
				div_x        = 4'b1011,
				div_y        = 4'b1100,
				div_z        = 4'b1101;
				
localparam acc_size = $clog2(max_unit_value) + $clog2(max_data_size);
localparam mem_elSize = 3*unit_size;
localparam mem_add_size = $clog2(max_data_size);
localparam config_size_size = $clog2(max_data_size);
localparam config_k_size = $clog2(kmax) + 1;
localparam point_size = 3*unit_size ;
localparam mean_size = 3*unit_size;
localparam mean_add_size = $clog2(kmax) + 1;
localparam counter_size = $clog2(max_data_size);
localparam cycle_counter_size = $clog2(100000000);
localparam d_size = unit_size;
localparam distance_size = $clog2(counter_size) + $clog2(point_size) + acc_size; // check this size !!!!!!!!!!!



integer j;
reg [0:cycle_counter_size-1] cycle_count;
reg [0:mem_add_size-1] mem_address;
reg [0:config_size_size-1] config_size;
reg [0:config_k_size-1] config_k;
reg [0:point_size - 1] point;
reg [0:mean_size-1] means [0:kmax-1];
reg [0:mean_size-1] new_means [0:kmax-1];

reg [0:mean_add_size-1] mean_address,min_mean;
reg [0:3*acc_size -1] accs [0:kmax-1];
reg [0:3*acc_size -1] accs_shadow [0:kmax-1];
reg [0:counter_size-1] counters [0:kmax-1];
reg [0:counter_size-1] counters_shadow [0:kmax-1];

reg [0:acc_size-1] d_x,d_y,d_z;
reg [0:distance_size-1] dx,dy,dz,dv,min_dist;
reg [0:$clog2(counter_size)+$clog2(distance_size)] right;
wire [0:distance_size-1] d,abs_delta_x,abs_delta_y,abs_delta_z;

reg [0:3] state;

wire [0:mem_elSize-1] mem_out;
reg  [0:32-1] num;
wire [0:32-1] q,r;
reg  [0:32-1] den;
/*
1) defin the missing variable 
2) add division
3) test bench
*/
 
assign abs_delta_x =  dx[0] ? -dx : dx;
assign abs_delta_y =  dy[0] ? -dy : dy;
assign abs_delta_z =  dz[0] ? -dz : dz;
assign d = abs_delta_x + abs_delta_y + abs_delta_z;
assign strb = state == done;
assign last_mean = mean_address == config_k;
assign last_mem  = mem_address  == config_size;
assign we = state == store_points;
mb #(.wel(mem_elSize), .size( max_data_size)) mem( clk,we,sin,mem_address,mem_out);


always @ (posedge clk) begin

	if(reset) begin
		mem_address <= {mem_add_size{1'b0}};
		config_size <= {config_size_size{1'b0}};
		config_k <= {config_k_size{1'b0}};
		point <= {point_size{1'b0}};
		
		for (j=0; j < kmax; j=j+1) begin
				accs[j][0+:acc_size] <= j*(255/kmax); //reset array
				accs[j][acc_size+:acc_size] <= j*(255/kmax);
				accs[j][2*acc_size+:acc_size] <= j*(255/kmax);
				counters[j] <= 1;
				accs_shadow[j]  <= {acc_size{1'b0}};
				counters_shadow[j] <= {counter_size{1'b0}};

		 end
		 
		min_mean <= {mean_add_size{1'b0}};
		
		dx <= {distance_size{1'b0}};
		dy <= {distance_size{1'b0}};
		dz <= {distance_size{1'b0}};

		min_dist <= {distance_size{1'b0}};
		state <= configure;
		point <= {point_size{1'b0}};
		cycle_count <= {cycle_counter_size{1'b0}};
		d_x <= {d_size{1'b0}};
		d_y <= {d_size{1'b0}};
		d_z <= {d_size{1'b0}};
		den <= {32{1'b0}};
		num <= {32{1'b0}};
		$display("reset #####################");
	end
	else begin
		case (state) 
			configure: begin
				config_size <= max_data_size;//sin[0:11];
				config_k    <= kmax; //sin[12:16];
				state <= store_points;				
			end
		/*Read Serial in and store it in memory*/
			store_points: begin
				$display("cycle: %d (%s) data_size %d k %d", cycle_count,"config",config_size,config_k); 
				
				
				if(last_mem) begin 
					state <= fetch;
					mem_address <= 0;
					mean_address <= 0;
					min_dist <= 255*255*3;
					
				end
				
				else begin
					$display("cycle: %d (%s) Putting %x in address %d", cycle_count,"store_points",sin,mem_address); 
					mem_address <= mem_address + 1;
				end
			end
			
			
		  /*Read point from memory and store it in point*/
	      fetch:
				state <= sqaure_dist;
			sqaure_dist: begin
					if(last_mean)
						state <= accumulate;
					else begin
					
						dx <= (mem_out[0+:unit_size]*counters[mean_address]            - accs[mean_address][0+:acc_size]);
					   dy <= (mem_out[unit_size+:unit_size]*counters[mean_address]    - accs[mean_address][acc_size+:acc_size]);
						dz <= (mem_out[2*unit_size+:unit_size]*counters[mean_address]  - accs[mean_address][2*acc_size+:acc_size]);

						state <= pipeline;
					end
			end
		
			pipeline: begin
				dv <= d;
				right <= min_dist*counters[mean_address];
				state <= distance;
				
			end
			/* Calculate the square distance and find the mean with minmum distance*/
			distance: begin
			
			
			 		if(dv*counters[min_mean]  < right) begin
							min_dist <= d;
							min_mean <= mean_address;
					end
						
					$display("cycle: %d (%s) comparing accs:[%d,%d,%d] counter %d with point [%d,%d,%d] distance %d [%d %d %d] %x %x %x %d %d %d   current min_dis %d min_mean %d mean_address %d config_k %d mem_address %d",cycle_count,"distance",accs[mean_address][0+:acc_size],accs[mean_address][acc_size+:acc_size],accs[mean_address][2*acc_size+:acc_size],counters[mean_address],mem_out[0+:unit_size],mem_out[unit_size+:unit_size],mem_out[2*unit_size+:unit_size],d,dx,dy,dz,dx,dy,dz,dx[0],dy[0],dz[0],min_dist,min_mean,mean_address,config_k,mem_address); 					
					mean_address <= mean_address+1'b1;
					state <= fetch;
					
			end 

			
			accumulate: begin
				if(last_mem) begin	
					state <= diff;
					mean_address <= 0;
				end
				else begin
					accs_shadow[min_mean][0+:acc_size]           <= accs_shadow[min_mean][0+:acc_size]            + mem_out[0+:unit_size];
					accs_shadow[min_mean][acc_size+:acc_size]    <= accs_shadow[min_mean][acc_size+:acc_size]     + mem_out[unit_size+:unit_size]; 
					accs_shadow[min_mean][2*acc_size+:acc_size]  <= accs_shadow[min_mean][2*acc_size+:acc_size]   + mem_out[2*unit_size+:unit_size];
					counters_shadow[min_mean] <=  counters_shadow[min_mean] + 1'b1;
					$display("cycle: %d (%s) adding [%d,%d,%d] to mean_address %d counter %d acc [%d %d %d]", cycle_count,"accumolate",mem_out[0+:unit_size],mem_out[unit_size+:unit_size],mem_out[2*unit_size+:unit_size],min_mean,counters_shadow[min_mean],accs_shadow[min_mean][0+:acc_size],accs_shadow[min_mean][acc_size+:acc_size],accs_shadow[min_mean][2*acc_size+:acc_size]); 
				
					mem_address <= mem_address + 1'b1;
					mean_address <= 0;
					min_dist <= 255*255*3;
					state <= fetch;
				end
			end
			
			 
			
			
			diff: begin
				d_x <= accs[mean_address][0+:acc_size] 					   - accs_shadow[mean_address][0+:acc_size];
				d_y <= accs[mean_address][acc_size+:acc_size]   - accs_shadow[mean_address][acc_size+:acc_size];
				d_z <= accs[mean_address][2*acc_size+:acc_size] - accs_shadow[mean_address][2*acc_size+:acc_size];
				state <= check;
			
			end
				
			
			check: begin
				
				
				/*Check for negative values*/
				if(counters_shadow[mean_address] != 0 && (d_x > threshold || d_z > threshold || d_y > threshold)) begin
					state <= update;
					mean_address <= 0;
				
				end	
				
				else if(last_mean) begin
					  state <= done;
					  mean_address <= 0;
				end
				else  begin
						$display("cycle: %d (%s) comparing accs :[%d,%d,%d] with accs [%d,%d,%d] diff [%d,%d,%d] mean_address %d",cycle_count,"check",accs[mean_address][0+:acc_size],accs[mean_address][acc_size+:acc_size],accs[mean_address][2*acc_size+:acc_size],accs_shadow[mean_address][0+:acc_size],accs_shadow[mean_address][acc_size+:acc_size],accs_shadow[mean_address][2*acc_size+:acc_size],d_x,d_y,d_z,mean_address); 
						mean_address <= mean_address+1'b1;
						state <= diff;
				end
			end
			
			
			
			update: begin
				if(last_mean) begin
					state <= fetch;
					mem_address <= 0;
					mean_address <= 0;
					for(j = 0; j < kmax ; j = j+1) begin
						accs_shadow[j]  <= {acc_size{1'b0}};
						counters_shadow[j] <= {counter_size{1'b0}};
					end 
				end
				else begin 
					$display("cycle: %d (%s) mean[%d %d %d] <== new_mean [%d %d %d] mean_address %d config_k %d counter %d counter %d" ,cycle_count,"update",accs[mean_address][0+:acc_size],accs[mean_address][acc_size+:acc_size],accs[mean_address][2*acc_size+:acc_size],accs_shadow[mean_address][0+:acc_size],accs_shadow[mean_address][acc_size+:acc_size],accs_shadow[mean_address][2*acc_size+:acc_size],mean_address,config_k,counters[mean_address],counters_shadow[mean_address] );
					mean_address <= mean_address + 1'b1;
					if( counters_shadow[mean_address] != 0) begin
						accs[mean_address] <= accs_shadow[mean_address];
						counters[mean_address] <= counters_shadow[mean_address];
					end
				end
			end
				
			done:
				$display("cycle: %d (%s) ############## END ##################### ",cycle_count,"done");
				
			
				
	   endcase 
		 cycle_count <= cycle_count + 1'b1;
		end

end


endmodule 





















