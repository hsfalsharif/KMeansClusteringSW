module kmeans(input clk, reset,input [0:3*8 - 1]sin,output strb);
localparam unit_size = 8;
localparam len_count = 10;
localparam max_data_size = 1000;
localparam len_acc   = unit_size;
localparam kmax = 16;
localparam mean_size = 3*len_acc;
localparam distance_size = 18;
localparam threashold = 5;
localparam  fetch        = 4'b0000,
				distance     = 4'b0001,
				accoumolate  = 4'b0010,
				divide       = 4'b0011,
				check        = 4'b0100,
				update 		 = 4'b0101,
				store_points = 4'b0110,
				done         = 4'b0111,
				configure    = 4'b1000;
integer j;
reg [0:$clog2(100000000)-1] cycle_count;
reg [0:3*unit_size - 1] mem [0:max_data_size - 1];
reg [0:$clog2(max_data_size)-1] mem_address;
reg [0:$clog2(max_data_size)-1] config_size;
reg [0:$clog2(kmax)-1] config_k;
reg [0:3*unit_size - 1] point;
reg [0:mean_size-1] means [0:kmax-1];
reg [0:mean_size-1] new_means [0:kmax-1];

reg [0:$clog2(kmax)-1] mean_address,min_mean;
reg [0:mean_size -1] accs [0:kmax-1];
reg [0:$clog2(max_data_size)-1] counters [0:kmax-1];

reg [0:$bits(means[0])-1] d_x,d_y,d_z;
reg [0:distance_size-1] d,min_dist;
reg [0:3] state;

/*

1) defin the missing variable 
2) add division
3) test bench

*/
assign strb = state == done;

always @ (posedge clk) begin

	if(reset) begin
		mem_address <= {$size(mem_address){1'b0}};
		config_size <= {$size(config_size){1'b0}};
		config_k <= {$size(config_k){1'b0}};
		point <= {$size(point){1'b0}};
		
		for (j=0; j < kmax; j=j+1) begin
            means[j] <= j*(255/kmax); //reset array
				new_means[j] <= {$bits(new_means[j]){1'b0}};
				accs[j]  <= {$bits(accs[j]){1'b0}};
				counters[j] <= {$bits(counters[j]){1'b0}};
		 end
		 
		min_mean <= {$size(min_mean){1'b0}};
		
		d <= {$size(d){1'b0}};
		min_dist <= {$size(min_dist){1'b0}};
		state <= {$size(state){1'b0}};
		
		d_x <= {$size(d_x){1'b0}};
		d_y <= {$size(d_x){1'b0}};
		d_z <= {$size(d_x){1'b0}};
	end
	else begin
		case (state) 
			configure: begin
				config_size <= sin[0:11];
				config_k    <= sin[12:16];
				state <= store_points;
				
				$display("cycle: %d (%s) data_size %d k %d", cycle_count,"store_points",sin[0:5],sin[6:12]); 
				
				
			end
		/*Read Serial in and store it in memory*/
			store_points: begin
				if(mem_address <= config_size) begin
					mem[mem_address] <= sin;
					$display("cycle: %d (%s) Putting %x in address %d", cycle_count,"store_points",sin,mem_address); 
					mem_address <= mem_address + 1;
				end
				
				else begin
					state <= fetch;
					mem_address <= 0;
				end
			end
			
			
		  /*Read point from memory and store it in point*/
			fetch:
				if(mem_address <= config_size) begin
					point <= mem[mem_address];
					$display("cycle: %d (%s) fetch [%d,%d,%d] in as data no %d", cycle_count,"fetch",point[0+:unit_size-1],point[unit_size+:unit_size-1],point[2*unit_size+:unit_size-1],mem_address); 
					mem_address <= mem_address + 1;
					
					state <= distance;
					min_dist <= -1;
					mean_address <= 0;
				end
		
		
			/* Calculate the square distance and find the mean with minmum distance*/
			distance: begin
				   d <=     (point[0+:unit_size-1] - means[mean_address][0+:unit_size-1])
							*(point[0+:unit_size-1] - means[mean_address][0+:unit_size-1])
			
						+ (point[unit_size+:unit_size-1] - means[mean_address][unit_size+:unit_size-1])
							*(point[unit_size+:unit_size-1] - means[mean_address][unit_size+:unit_size-1]) 
			
						+ (point[2*unit_size+:unit_size-1] - means[mean_address][2*unit_size+:unit_size-1])
							*(point[2*unit_size+:unit_size-1] - means[mean_address][2*unit_size+:unit_size-1]);
			 
					if(d < min_dist)
							min_dist <= d;
							min_mean <= mean_address;
					
					$display("cycle: %d (%s) comparing mean:[%d,%d,%d] with point [%d,%d,%d] distance %d current min_dis %d min_mean %d mean_address %d",cycle_count,"distance",means[mean_address][0+:unit_size-1],means[mean_address][unit_size+:unit_size-1],means[mean_address][2*unit_size+:unit_size-1],point[0+:unit_size-1],point[unit_size+:unit_size-1],point[2*unit_size+:unit_size-1],d,min_dist,min_mean,mean_address); 
					
					if(mean_address >= config_k)
					  state <= accoumolate;
					else 
						mean_address <= mean_address+1;
			end 

			
			accoumolate: begin
				accs[min_mean][0+:unit_size-1]           <= accs[min_mean][0+:unit_size-1]                     + point[0+:unit_size-1];
				accs[min_mean][unit_size+:unit_size-1]   <= accs[min_mean][unit_size+:unit_size-1]     + point[unit_size+:unit_size-1]; 
				accs[min_mean][2*unit_size+:unit_size-1] <= accs[min_mean][2*unit_size+:unit_size-1] + point[2*unit_size+:unit_size-1];
				counters[min_mean] <=  counters[min_mean] + 1;
				$display("cycle: %d (%s) adding [%d,%d,%d] to mean_address %d", cycle_count,"accumolate",point[0+:unit_size-1],point[unit_size+:unit_size-1],point[2*unit_size+:unit_size-1],mean_address); 
				state <= divide;
			end
			
			divide: begin
				$display("cycle: %d (%s) should divide", cycle_count,"divide");
				state <= check;
			end
			
			
			
			check: begin
				d_x <= new_means[mean_address][0+:unit_size-1] - means[mean_address][0+:unit_size-1];
				d_y <= new_means[mean_address][unit_size+:unit_size-1] - means[mean_address][unit_size+:unit_size-1];
				d_z <= new_means[mean_address][2*unit_size+:unit_size-1] - means[mean_address][2*unit_size+:unit_size-1];
				$display("cycle: %d (%s) comparing mean:[%d,%d,%d] with new_mean [%d,%d,%d] diff [%d,%d,%d] mean_address %d",cycle_count,"distance",means[mean_address][0+:unit_size-1],means[mean_address][unit_size+:unit_size-1],means[mean_address][2*unit_size+:unit_size-1],new_means[mean_address][0+:unit_size-1]
				,new_means[mean_address][unit_size+:unit_size-1],
				new_means[mean_address][2*unit_size+:unit_size-1],d_x,d_y,d_z,mean_address); 
				/*Check for negative values*/
				if(d_x > threashold || d_z > threashold || d_y > threashold) begin
					state <= update;
					mean_address <= 0;
				
				end	
				
				else if(mean_address >= config_k)
					  state <= done;
				else  
						mean_address <= mean_address+1;
			end
			update: begin
				means[mean_address] <= new_means[mean_address];
				if(mean_address >= config_k) begin
					state <= fetch;
					mem_address <= 0;
				end
				else 
					mean_address <= mean_address + 1;
			end
				
			done:
				$display("cycle: %d (%s) ############## END ##################### ",cycle_count,"done");
				
			
				
	   endcase 
		 cycle_count <= cycle_count + 1;
		end

end


endmodule 















