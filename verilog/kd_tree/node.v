module node(clk, data_from_top,data_from_right,data_from_left,command_from_top,command_from_right,command_from_left,data_to_top,data_to_right,data_to_left,command_to_top,command_to_right,command_to_left);


			  //center_size  = 24;
localparam  dim_size     = $clog2(255),
				dim          = 3,
				max_n        = 10000,
				center_size  = dim*dim_size,
				counter_size = $clog2(max_n),
				acc_size     = $clog2(dim_size*max_n),
				depth_size   = $clog2(10);
localparam command_size = 6,
			  data_size    = center_size * 2,
			  data_half_size = center_size,
			  ttl_size     = 4,
			  axis_size    = 2,
			  threashold   = 4;
parameter name="unknown"; 

input clk;
input      [data_size - 1 : 0]    data_from_top,data_from_right,data_from_left;
input      [command_size - 1 : 0] command_from_top,command_from_right,command_from_left;
output reg [data_size - 1 : 0]    data_to_top,data_to_right,data_to_left;
output reg [command_size - 1 : 0] command_to_top,command_to_right,command_to_left;

/// Commands
localparam nop 					 		= 6'h00,
			  rst 					 		= 6'h1f,
			  rst_done 				 		= 6'h1e,
			  center_fill 			 		= 6'h01,
			  configure_sort_axis 		= 6'h02,
			  receive_center 		 		= 6'h03,
			  switch_with_left 	 		= 6'h04,
			  center_fill_done 	 		= 6'h05,
			  configure_sort_axis_done = 6'h07,
			  busy             	 		= 6'h08, 
			  dne              	 		= 6'h10,
			  start_sorting    	 		= 6'h09,
			  ready_to_sort    	 		= 6'h0a,
			  switch           	 		= 6'h0b,
			  sort_left_validate       = 6'h0c,
			  sort_right_validate      = 6'h0d,
			  valid_sort               = 6'h0f,
			  expose_center            = 6'h12,
			  valid_done               = 6'h11,
			  next_sort_level          = 6'h13,
			  start_sorting_as_root    = 6'h14,
			  sort_done                = 6'h15,
			  point_in_as_root         = 6'h16,
			  point_in_with_best       = 6'h17,
			  return_best              = 6'h18,
			  hold                     = 6'h19,
			  get_most_left            = 6'h1a,
			  get_most_right           = 6'h1b,
			  set_most_left            = 6'h1c,
			  set_most_right           = 6'h1d,
			  nopme                    = 6'h06,
			  valid_semi_done          = 6'h20,
			  axis_set_inc             = 6'h21,
			  accomulate               = 6'h22,
			  divide                   = 6'h23,
			  new_iteration            = 6'h24,
			  stable                   = 6'h25,
			  unstable                 = 6'h26;
  
reg [axis_size - 1 : 0] sorting_axis;
reg [ttl_size - 1 : 0] time_to_live;
reg [center_size-1:0] parent_in, center;
reg [command_size - 1 : 0] command_pipe;
reg [data_size - 1 : 0]     data_pipe;




reg [acc_size - 1:0] accX, accY, accZ;
reg [counter_size - 1:0] counter;
reg [center_size - 1:0] old_center, new_center, point;
reg [depth_size - 1:0] depth;
assign distance_calc = 1'b1; // distance_calc enables the ce to perform distance calculations during the point propogation stage


reg [command_size - 1 : 0] self_command;
wire [center_size - 1:0] center_self_C2P, center_self_P2C, ce_left_out, ce_self_out, ce_right_out;
reg rst_t, virtual_root, sorting;
wire point_prop,first_direction,div_en,div_valid,div_clr;
wire [dim_size-1:0] div_outX,div_outY,div_outZ;
reg [9:0] div_pipe;
assign div_en = command_from_top == divide;
assign div_clr= !div_en; 
assign div_valid = div_pipe[9];
assign center_stableX = old_center[0			+:dim_size]  > div_outX - threashold && old_center[0			+:dim_size] < div_outX + threashold;
assign center_stableY = old_center[dim_size  +:dim_size]  > div_outY - threashold && old_center[dim_size  +:dim_size] < div_outY + threashold;
assign center_stableZ = old_center[2*dim_size+:dim_size]  > div_outZ - threashold && old_center[2*dim_size+:dim_size] < div_outZ + threashold;
assign center_stable = counter == 0 || (center_stableX && center_stableY && center_stableZ);
divider divx (.aclr(div_clr),.clock(clk),.denom(counter),.numer(accX),.quotient(div_outX),.remain(remaider));
divider divy (.aclr(div_clr),.clock(clk),.denom(counter),.numer(accY),.quotient(div_outY),.remain(remaider));
divider divz (.aclr(div_clr),.clock(clk),.denom(counter),.numer(accZ),.quotient(div_outZ),.remain(remaider));
  
always @(posedge clk) begin
	if(div_clr)
		div_pipe <= 0;
	else
		div_pipe <= {div_pipe[8:0],div_en};
end
// how many commands need to come from top at a single instance during processing?

// two major outer global stages: init, sorting, and point propogation

// inner stage-based signals which are:-
// During init ---> maybe we can have multiple stages to propogate centers then depths, or we can propogate these two at the same time
// During sorting ---> next_level
// During point propogation ---> start_iter, update

// stage-based/global-state-based signals = signals that signify a stage in the algorithm or a global state that is happening
// at all nodes at an instance during processing
 
// local signals are signals that are relevant locally and within the context of the current node and they are:
// During init ---> can add this later as necessary
// During sorting ---> parent_switch_in, self_child_switch
// During point propogation --->  receive_point, inc


/*
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
*/
// TODO: Find out how we will generate control signals inc, receive_point, next_level, stable, and go_left
// Also implement the point propogation after verifying that the sort works 
/*
cluster_CE c_ce (.clk(clk), 
					  .rst(rst),
					  .en(en),
					  .sorting(1'b1),
					  .left(data_from_left), 
					  .parent(self_center), 
					  .right(data_from_right),
					  .axis(sorting_axis), 
					  /////
					  .stable(sort_stable), 
					  .left_switch(left_switch_out), 
					  .parent_switch(self_child_switch), 
					  .right_switch(right_switch_out),
					  .new_left(left_out), 
					  .new_parent(center_self_C2P), 
					  .new_right(right_out), 
					  .child_axis(axis_out)
					  )
					  
					  

 */

assign left_dne = command_from_left == dne;
assign right_dne = command_from_right == dne; 
assign both_dne = left_dne && right_dne;
assign left_en = !left_dne;
assign right_en = !right_dne;
assign ce_en = 1;
assign pe_en = 1;
/*
cluster_PE c_pe (
						.clk(clk),
						.rst(rst_t),
						.en(pe_en),
						.init(init),
						.start_iter(start_iter),
						.receive_point(receive_point),
						.inc(inc),
						.update(update),
						.sorting(sorting),
						.parent_switch(parent_switch_in),
						.child_switch(self_switch),
						.next_level(next_level), 
						.point_in(data_from_top),
						.parent_in(parent_in),
						.child_in(center_self_C2P),
						.depth_in(),
						.stable(center_stable), // out
						.ce_en(ce_en),
						.parent_out(parent_out),
						.child_out(center_self_P2C),
						.point_out(),
						.child_depth()
						);
*/
wire [center_size - 1 : 0] ce_parent,ce_left,point_in;
reg  [center_size - 1 : 0] ce_right;
assign point_in  = data_from_top[0 +: data_half_size];

assign ce_parent = (command_from_top == point_in_as_root || command_from_top == point_in_with_best) ? point_in: old_center;
							
							
assign ce_left   = (command_from_top == point_in_as_root || command_from_top == point_in_with_best) ? old_center : data_from_left;
assign returned  = (command_from_right == return_best || command_from_left == return_best);
assign point_prop = (command_from_top == point_in_as_root || command_from_top == point_in_with_best);

always @* begin

	if(command_from_top == point_in_with_best || command_from_top == point_in_as_root ) begin
		if(command_from_right == return_best && command_from_left != return_best)
			ce_right = data_from_right[data_half_size +: data_half_size];
		else if (command_from_left == return_best && command_from_right != return_best)
			ce_right = data_from_left[data_half_size +: data_half_size];
		else if(command_from_left == return_best && command_from_right == return_best)
			if(first_direction)
				ce_right = data_from_right[data_half_size +: data_half_size];
			else 
				ce_right = data_from_left[data_half_size +: data_half_size];
		else if(command_from_top == point_in_with_best)
			ce_right = data_from_top[data_half_size +: data_half_size];
		else 
			ce_right = old_center; 
	end
		
	else 
		ce_right = data_from_right;
end






// For the point_prop situation, old_center will come from left, point will from parent, best_center will come from right
// best_center will come out from new_parent
cluster_CE #(.name(name)) c_ce (
						.clk(clk),
						.rst(rst_t),
						.en(ce_en), // pe enables ce
						.sorting(sorting),
						.point_prop(point_prop),
						.left_en(left_en), 
						.right_en(right_en),
						.returned(returned), // will need to add signal here to tell us we have returned from the first direction
						.left(ce_left), //data_from_left),
						.parent(ce_parent),//old_center),
						.right(ce_right), //data_from_right),
						.axis(sorting_axis),
						.stable(sort_stable),
						.left_switch(left_switch),
						.parent_switch(self_switch),
						.right_switch(right_switch),
						.first_direction(first_direction),
						.other_branch(other_branch),
						.new_left(ce_left_out),
						.new_parent(ce_self_out),
						.new_right(ce_right_out) 
						); 
 
wire [2:0] ce_command;
assign ce_command = {left_switch, self_switch, right_switch};

always @* begin
	case (ce_command)
        4'b0000:
					//if(command_to_top == valid_sort || command_to_top == sort_done || command_to_top == valid_done || command_to_top == get_most_right || command_to_top == get_most_left)
					//	if(virtual_root)
					//		self_command <= next_sort_level;
					//	else
					//		self_command <= expose_center;
					//else
						self_command = nop;
		 	//4'b0001:  begin  
 			//	if(left_en && right_en) 
			//		self_command = sort_done1;
			//	else self_command = nop; 
			//end
		  
		  default: self_command = switch;
	endcase
end



always @(posedge clk) begin 
$display("node: %s center %x axis: %x command_from [%x %x %x,self:%x,ce:%x,{s:%d,pp:%d,fd:%d,ob:%d,rt:%d}] data_from [%x %x %x] command_to [%x %x %x] data_to [%x %x %x]  Child_status [%x %x] [%x %x %x]",name,old_center, sorting_axis, command_from_left,command_from_top,command_from_right,self_command,ce_command,sorting,point_prop,first_direction,other_branch,returned,data_from_left,data_from_top,data_from_right,command_to_left,command_to_top,command_to_right,data_to_left,data_to_top,data_to_right,left_dne,right_dne,ce_left,ce_parent,ce_right);	

if(command_from_top != nop)
		case(command_from_top)
		   rst: begin 
				if( (command_from_left == rst_done || left_dne) && (command_from_right == rst_done || left_dne) ) begin
					command_to_top <= rst_done;
					command_to_left <= nop;
					command_to_right <= nop;
					command_pipe    <= nop;
					data_to_left  <= {data_size{1'b0}};
					data_to_right <= {data_size{1'b0}}; 
					data_to_top   <= {data_size{1'b0}};
					data_pipe     <= {data_size{1'b0}};
//					center        <= {center_size{1'b0}};
					sorting_axis  <= {center_size{1'b0}};
//					time_to_live  <= {center_size{1'b0}};
					rst_t = 1;
					accX <= {acc_size{1'b0}};
					accY <= {acc_size{1'b0}};
					accZ <= {acc_size{1'b0}};
					counter <= {counter_size{1'b0}};
					old_center <= {center_size{1'b0}};
					new_center <= {center_size{1'b0}};
					point <= {center_size{1'b0}};
					time_to_live <= {depth_size{1'b0}};
					sorting <= 0;
					virtual_root <= 0;
				
				end 
				else begin
					command_to_left <= rst;
					command_to_right <= rst;
	
					data_to_left  <= {data_size{1'b0}};
					data_to_right <= {data_size{1'b0}};
					data_to_top   <= {data_size{1'b0}};
	 
					center        <= {center_size{1'b0}};
					sorting_axis  <= {center_size{1'b0}};
					time_to_live  <= {center_size{1'b0}};
				end
			
			
	 		end
			    
			center_fill: begin
				if(command_to_top != center_fill_done) begin 
				if(command_from_left != center_fill_done && !left_dne) begin
					data_to_left <= data_from_top;
					//data_pipe <= data_from_top;
 
					command_to_left <= center_fill;
					command_to_top <= nop;
					command_to_right <= nop;
				end
				else if (command_from_right != center_fill_done && ! right_dne) begin
						data_to_right <= data_to_left;//data_pipe;
						data_to_left <= data_from_top;
						command_to_right <= center_fill;	
						command_to_left <= center_fill;
				end
					else begin  
						if(both_dne) begin
							old_center <= data_from_top;
						end
						else begin
							old_center <= data_to_right;
						end
						command_to_top <= center_fill_done;
						command_to_right <= nop; 
						command_to_left <= nop;
					end
					
				
				end 
			
			end           
		///////////////////// END center fill //////////////////////////////
		configure_sort_axis: begin
			if((command_from_left == configure_sort_axis_done || left_dne) && ( command_from_right == configure_sort_axis_done || right_dne) )  begin
				command_to_top <= configure_sort_axis_done;
				command_to_right <= nop;
				command_to_left <= nop;
			
			end
			else begin
				sorting_axis <= data_from_top;
				data_to_left <= data_from_top;
				data_to_right <= data_from_top;
				command_to_left <= configure_sort_axis;
				command_to_right <= configure_sort_axis;
				command_to_top <= nop;
			end
		end 
		 
		axis_set_inc: begin
			sorting_axis <= data_from_top;
			command_to_left <= axis_set_inc;
			command_to_right <= axis_set_inc;
			if(data_from_top == 2) begin
				data_to_right <= 0;
				data_to_left  <= 0;
			end
			else begin
				data_to_right <= data_from_top + 1;
				data_to_left  <= data_from_top + 1;
			end
		end
		//////////////////////////////////////////// END CONFIGURATION  /////////////////////////////
		
		/*
		 
		receive_center: begin
						if(command_to_top == receive_center && command_from_top == receive_center) begin
							command_to_top <= ready_to_sort;
							command_to_left <= nop;
							command_to_right <= nop;
							data_to_top <= old_center;
							data_to_left <= old_center;
							data_to_right <= old_center;
						end
						else if(command_from_top == receive_center && command_to_top != receive_center) begin
							command_to_top <= receive_center;
							command_to_left <= busy;
							command_to_right <= busy;
							old_center <= data_from_top;
						end
						
		end
		 
		*/
		receive_center: begin
							if(command_to_top == receive_center) begin
								data_to_top <= old_center;
								command_to_top <= ready_to_sort ;
								command_to_left <= nop;
								command_to_right <= nop;
	
							end  
							else begin
								old_center <= data_from_top;
								command_to_top <= receive_center;
								//if(command_from_left == valid_done) begin
								//	command_to_left <= hold;
								//	command_to_right <= hold;
								//end
								//else begin
									command_to_left <= nop;
									command_to_right <= nop;
								
								//end
								
							end
			end 
		
		
		//////////////////////////////END receive_point //////////////////////
		start_sorting: begin
			if(!left_dne) begin
				command_to_left <= start_sorting;
				data_to_left <= data_from_top;
			end
			
			if(!right_dne) begin
				command_to_right <= start_sorting;
				data_to_right <= data_from_top;
 
			end 
			if(command_to_right == start_sorting) 
				command_to_right <= nop;
			if(command_to_left == start_sorting)
				command_to_left <= nop;
		
			sorting_axis <= data_from_top; // experimental 
			data_to_top <= old_center;
			command_to_top <= ready_to_sort;
			sorting <= 1; 
		end
		
		start_sorting_as_root:begin
			
			if(!left_dne) begin
				command_to_left <= start_sorting;
				data_to_left <= data_from_top;
			end
			
			if(!right_dne) begin
				command_to_right <= start_sorting;
				data_to_right <= data_from_top;
 
			end
			sorting_axis <= data_from_top; // experimental 
			data_to_top <= old_center;
			command_to_top <= ready_to_sort;
			sorting <= 1;
			virtual_root <= 1;
		end
		
 
		  
		
		///////////////////////////////////// Start sorting END ///////////////////////////
		/* 
		sort_left_validate: 
		if(!left_dne ) begin
				if(command_to_top == valid_done)
					command_to_left <= nop; 
				else if(command_to_left != get_most_left && (command_from_left == valid_sort || command_from_left == valid_done)) begin
					command_to_left <= get_most_left;				
	 			end 
				else if (command_from_left == get_most_left ) begin
					if((sorting_axis == 0 && data_from_top[0+:dim_size] < data_from_left[0+:dim_size]) || (sorting_axis == 1 && data_from_top[dim_size+:dim_size] < data_from_left[dim_size+:dim_size]) || (sorting_axis == 2 && data_from_top[2*dim_size+:dim_size] < data_from_left[2*dim_size+:dim_size])) begin
						data_to_top <= data_from_top;
						command_to_top <= valid_done;
					end
					else begin 
					data_to_top <= data_from_left;
					command_to_left <= set_most_left;
					data_to_left <= data_from_top;
					command_to_top <= valid_done;
					end
				end 
			end
			 
			
		else if (left_dne) begin
			data_to_top <= data_from_top;
			command_to_top <= valid_done;
		end
		*/
		/*
		sort_right_validate: 
		if(!right_dne) begin
			if(command_to_top == valid_done)
					command_to_right <= nop;
				else if (command_to_right != get_most_right  && (command_from_right == valid_sort || command_from_right == valid_done)  ) begin
					command_to_right <= get_most_right;				
				end
    			else if (command_from_right == get_most_right) begin
					if((sorting_axis == 0 && data_from_top[0+:dim_size] > data_from_right[0+:dim_size]) || (sorting_axis == 1 && data_from_top[dim_size+:dim_size] > data_from_right[dim_size+:dim_size]) || (sorting_axis == 2 && data_from_top[2*dim_size+:dim_size] > data_from_right[2*dim_size+:dim_size])) begin
						data_to_top <= data_from_top;
						command_to_top <= valid_done;
					end
					else begin 
						data_to_top <= data_from_right;
						command_to_right <= set_most_right;
						data_to_right <= data_from_top;
						command_to_top <= valid_done;
					end 
				end 
			end
		else if(right_dne) begin
			data_to_top <= data_from_top;
			command_to_top <= valid_done;
		end
		*/
		 
		nopme: begin
			command_to_top <= nop;
			//data_to_top <= {data_size{1'b0}};
			
			command_to_left <= nopme;
			data_to_right <= {data_size{1'b0}};
			command_to_right <= nopme;
			data_to_left <= {data_size{1'b0}};
		end
		
		sort_right_validate: begin
			if(right_dne) begin
				data_to_top <= data_from_top;
				command_to_top <= valid_done;
			end
			else if(command_to_top != valid_done) begin
				if(command_to_right != get_most_right) begin
					command_to_right <= get_most_right;
				end
				else if(command_from_right == get_most_right) begin
					if((sorting_axis == 0 && data_from_top[0+:dim_size] > data_from_right[0+:dim_size]) || (sorting_axis == 1 && data_from_top[dim_size+:dim_size] > data_from_right[dim_size+:dim_size]) || (sorting_axis == 2 && data_from_top[2*dim_size+:dim_size] > data_from_right[2*dim_size+:dim_size])) begin
						data_to_top <= data_from_top;
						command_to_top <= valid_done;
						command_to_right <= nop;
					end
					else begin 
						data_to_top <= data_from_right;
						command_to_right <= set_most_right;
						data_to_right <= data_from_top;
						command_to_top <= valid_done;
					end 
				end
			end
		end
		
		
		sort_left_validate: begin
			if(left_dne) begin
				data_to_top <= data_from_top;
				command_to_top <= valid_done;
			end
			else if(command_to_top != valid_done) begin
				if(command_to_left != get_most_left) begin
					command_to_left <= get_most_left;
				end
				else if(command_from_left == get_most_left) begin
					if((sorting_axis == 0 && data_from_top[0+:dim_size] < data_from_left[0+:dim_size]) || (sorting_axis == 1 && data_from_top[dim_size+:dim_size] < data_from_left[dim_size+:dim_size]) || (sorting_axis == 2 && data_from_top[2*dim_size+:dim_size] < data_from_left[2*dim_size+:dim_size])) begin
						data_to_top <= data_from_top;
						command_to_top <= valid_done;
						command_to_left <= nop;
					end
					else begin 
						data_to_top <= data_from_left;
						command_to_left <= set_most_left;
						data_to_left <= data_from_top;
						command_to_top <= valid_done;
					end 
				end
			end
		end
		get_most_right:
			if(right_dne) begin
				command_to_top <= get_most_right;
				data_to_top <= old_center;
			end
			else if(command_from_right == get_most_right) begin
				command_to_top <= get_most_right;
				data_to_top <= data_from_right;
				command_to_right <= nop;
			end
			else if( command_from_right == valid_sort || command_from_right == valid_done )
				command_to_right <= get_most_right;
			 
		get_most_left:  
			if(left_dne) begin
				command_to_top <= get_most_left;
				data_to_top <= old_center;
			end
			else if(command_from_left == get_most_left) begin
				command_to_top <= get_most_left;
				data_to_top <= data_from_left;
				command_to_left <= nop;
			end
			 
			else if(command_to_top == get_most_right)begin
				command_to_left <= nop;
				command_to_top <= nop;
			end
			else if( command_from_left == valid_sort || command_from_left == valid_done) 
				command_to_left <= get_most_left;
			
			  
		set_most_left: begin
			if(left_dne) begin
				old_center <= data_from_top;
				//command_to_top <= valid_done;
				data_to_top  <= data_from_top; 
			end
			
			else if(command_to_left == set_most_left)
				command_to_left <= nop;
	
			else  begin
				command_to_left <= set_most_left;
				data_to_left <= data_from_top;
			end
			
			command_to_top <= nop;			
		end
		
		
		set_most_right: begin 
			if(right_dne) begin
				old_center <= data_from_top;
				command_to_top <= valid_done;
				data_to_top  <= data_from_top;
			end
			
			else if(command_to_right == set_most_right)
				command_to_right <= nop;
			else begin
				command_to_right <= set_most_right;
				data_to_right <= data_from_top;
			end
			
		
			command_to_top <= nop;
		end
		
		////////////////////////////// POint COmmands ///////////////////////////
		 
		point_in_as_root : begin
				sorting = 0;
			if(both_dne) begin
				command_to_top <= return_best;
				data_to_top    <= {ce_self_out,point_in};
			end
			else if(first_direction) begin  /// if we started with left
				if(command_from_left == return_best) begin // if left finishes
					if(other_branch) begin        // if we need to go right
						if(command_from_right == return_best) begin // if we went right and right finishes
							command_to_top <= return_best;    
						   data_to_top    <= data_from_right;
							if(old_center == data_from_right[data_half_size +: data_half_size]) begin
								accX <= accX + data_from_right[0          +: dim_size];
								accY <= accY + data_from_right[dim_size   +: dim_size];
								accZ <= accZ + data_from_right[2*dim_size +: dim_size];
								counter <= counter + 1'b1;
								$display("%s acc this %x center %x",name,data_from_right,old_center);
							end
							else begin
								command_to_left <= accomulate;
								data_to_left <= data_from_right;
								command_to_right <= accomulate;
								data_to_right <= data_from_right;
							end
							
						end 
						else begin // if we need to go right and write did not finish,
							command_to_right <= point_in_with_best;
							data_to_right     <= data_from_left;
						end
					end 
					else begin  // if we went left and no need to go right
						command_to_top <= return_best;
						data_to_top    <= data_from_left;
						if(old_center == data_from_left[data_half_size +: data_half_size]) begin
								accX <= accX + data_from_left[0          +: dim_size];
								accY <= accY + data_from_left[dim_size   +: dim_size];
								accZ <= accZ + data_from_left[2*dim_size +: dim_size];
								counter <= counter + 1'b1;
								$display("%s acc this %x center %x",name,data_from_left,old_center);

							end
							else begin
								command_to_left <= accomulate;
								data_to_left <= data_from_left;
								command_to_right <= accomulate;
								data_to_right <= data_from_left;
							end
							//command_to_left <= accomulate;
							//data_to_left <= data_from_left;
							//command_to_right <= accomulate;
							//data_to_right <= data_from_left;
					end
				end
				else begin 
					command_to_left  <= point_in_with_best;
					data_to_left     <=  {ce_self_out,point_in};
					command_to_right <= nop;
					data_to_right    <= 0;
				end
			end 
			else begin
				if(command_from_right == return_best) begin
					if(other_branch) begin
			 			if(command_from_left == return_best) begin
							command_to_top <= return_best;
							data_to_top    <= data_from_left;
							if(old_center == data_from_left[data_half_size +: data_half_size]) begin
								accX <= accX + data_from_left[0          +: dim_size];
								accY <= accY + data_from_left[dim_size   +: dim_size];
								accZ <= accZ + data_from_left[2*dim_size +: dim_size];
								counter <= counter + 1'b1;
								$display("%s acc this %x center %x",name,data_from_left,old_center);
							end
							else begin
								command_to_left <= accomulate;
								data_to_left <= data_from_left;
								command_to_right <= accomulate;
								data_to_right <= data_from_left;
							end
							////command_to_left <= accomulate;
							//data_to_left <= data_from_left;
							//command_to_right <= accomulate;
							//data_to_right <= data_from_left;
					
						end
						else begin 
							command_to_left <= point_in_with_best;
							data_to_left     <= data_from_right;
						end
					end 
					else begin
						command_to_top <= return_best;
						data_to_top    <= data_from_right;
						if(old_center == data_from_right[data_half_size +: data_half_size]) begin
								accX <= accX + data_from_right[0          +: dim_size];
								accY <= accY + data_from_right[dim_size   +: dim_size];
								accZ <= accZ + data_from_right[2*dim_size +: dim_size];
								counter <= counter + 1'b1;
								$display("%s acc this %x center %x",name,data_from_right,old_center);

							end
							else begin
								command_to_left <= accomulate;
								data_to_left <= data_from_right;
								command_to_right <= accomulate;
								data_to_right <= data_from_right;
							end//command_to_left <= accomulate;
						//data_to_left <= data_from_right;
						//command_to_right <= accomulate;
						//data_to_right <= data_from_right;
					
					end
				end
				else begin
					command_to_right  <= point_in_with_best;
					data_to_right     <= {ce_self_out,point_in};
					command_to_left   <= nop;
					data_to_left      <= 0;
				end
			end
		end 
		 
		accomulate: begin
			command_to_top <= nop;
			if(old_center == data_from_top[data_half_size +: data_half_size]) begin
						accX <= accX + data_from_top[0          +: dim_size];
						accY <= accY + data_from_top[dim_size   +: dim_size];
						accZ <= accZ + data_from_top[2*dim_size +: dim_size];
						counter <= counter + 1'b1;
						$display("%s acc this %x center %x",name,data_from_top,old_center);
			end
			else begin
				command_to_left <= accomulate;
				data_to_left <= data_from_top; 
				command_to_right <= accomulate;
				data_to_right <= data_from_top;
					
			end
		 
		end 
		new_iteration: begin
			if(command_to_left != new_iteration || command_to_right != new_iteration) begin
				old_center <= new_center;
			
				accX <= {acc_size{1'b0}};
				accY <= {acc_size{1'b0}};
				accZ <= {acc_size{1'b0}};
				counter <= {counter_size{1'b0}};
			 
				new_center <= {center_size{1'b0}};
				command_to_top <= nop;
				command_to_right <= new_iteration;
				command_to_left  <= new_iteration;
			end
		end 
		 
		divide: begin 
			command_to_left <= divide;
			command_to_right <= divide;
			$display("%s acc:[%x %x %x] counter: %d new_center: %x old_center: %x  div_out: [%x,%x,%x] center_stable: %x valid:%x  div_en:%x div_pipe:%x",name,accZ,accY,accX,counter,new_center,old_center,div_outZ,div_outY,div_outX,center_stable,div_valid,div_en,div_pipe);
			if(div_valid) begin
				if( counter != 0)
					new_center <= {div_outZ,div_outY,div_outX};
				else 
					new_center <= old_center;
					
				if((command_from_right == stable && command_from_left == stable) || both_dne) begin 
					if(center_stable)
						command_to_top <= stable;
					else
						command_to_top <= unstable;
					end
				else if(command_from_right == unstable || command_from_left == unstable) 
					command_to_top <= unstable;
				end
			end
		
		point_in_with_best :
		begin
				sorting = 0;

			if(both_dne) begin
				command_to_top <= return_best;
				data_to_top    <= {ce_self_out,point_in};
			end
			else if(first_direction) begin
				if(command_from_left == return_best) begin
					if(other_branch) begin
						if(command_from_right == return_best) begin
							command_to_top <= return_best;
						   data_to_top    <= data_from_right;
						
						end
						command_to_right <= point_in_with_best;
						data_to_right     <= data_from_left;
						
					end 
					else begin
				 		command_to_top <= return_best;
						data_to_top    <= data_from_left;
					end
				end 
				else begin
					command_to_left  <= point_in_with_best;
					data_to_left     <=  {ce_self_out,point_in};
					command_to_right <= nop;
					data_to_right    <= 0;
				end
			end
			else begin
				if(command_from_right == return_best) begin
					if(other_branch) begin
						if(command_from_left == return_best) begin
							command_to_top <= return_best;
							data_to_top    <= data_from_left;
						end
						command_to_left <= point_in_with_best;
						data_to_left     <= data_from_right;
					end 
					else begin
						command_to_top <= return_best;
						data_to_top    <= data_from_right;
					end
				end
				else begin
					command_to_right  <= point_in_with_best;
					data_to_right     <= {ce_self_out,point_in};
					command_to_left   <= nop;
					data_to_left      <= 0;
				end
		 	end
		end  ///////////////// if hold abonden every thing and make suitable enviroment
		//hold: command_to_top <= valid_sort;
		endcase 
	  
	else if(self_command != nop) begin 
		case(self_command)
			switch: 
			if(command_to_left == receive_center && command_to_right == receive_center && command_from_left == receive_center && command_from_right == receive_center) begin
							command_to_left  <= nop;
							command_to_right <= nop;
							command_to_top   <= ready_to_sort;
							data_to_top      <= ce_self_out; 
							old_center       <= ce_self_out;
			end
			else if ((command_to_left != receive_center && command_to_right != receive_center) && (command_from_left == ready_to_sort || command_from_left == valid_sort ) && (command_from_right == ready_to_sort || command_from_right == valid_sort) ) begin
					 if (command_to_left != hold && command_to_right != hold) begin
							command_to_right <= hold;
							command_to_left  <= hold;
							command_to_top   <= busy;
							data_to_top <= old_center;
							//data_to_top <= old_center;
						end  
						else begin
							data_to_left     <= ce_left_out;
							data_to_right    <= ce_right_out;
							command_to_left  <= receive_center;
							command_to_right <= receive_center;
							command_to_top   <= busy; 

						end		 
					end 
				 
			expose_center: begin  
				//if(command_from_right == sort_done && command_from_left == sort_done)
				//if(command_to_top == valid_done || command_to_top == get_most_right || command_to_top == get_most_left)
				//	command_to_top <= valid_done;
				//else
				//if(command_to_top == valid_sort)
				//	command_to_top <= valid_sort;
				//else
				if(both_dne)
					command_to_top <= valid_sort; 
				else
					command_to_top <= ready_to_sort;
				data_to_top <= old_center;
			end 
			next_sort_level: begin  
			if(both_dne) begin
				command_to_top <= sort_done; 
			end
			else begin
				 if(command_to_left != start_sorting_as_root && command_to_right != start_sorting_as_root) begin
					command_to_left <= start_sorting_as_root;
					data_to_left    <= sorting_axis + 1;
					command_to_right <= start_sorting_as_root;
					data_to_right    <= sorting_axis + 1;
					virtual_root     <= 1;
				end 
				else begin
					command_to_right <= nop;
					command_to_left <= nop;
					sorting = 0;
					virtual_root <= 0;
				
				end
			end
		
		
		end
		
		
		
		endcase
	end
	else if(command_from_left != nop) begin 
		case(command_from_left)
			receive_center: begin 
					command_to_right <= nop;
					command_to_left <= nop;
					command_to_top <= ready_to_sort;
					data_to_top <= old_center; 
					
				end
	 	/*      
			valid_sort: begin
					if(command_from_right == valid_sort && command_to_left != sort_right_validate) begin
						if( command_to_left == hold) begin
							command_to_left <= sort_right_validate;
							data_to_left   <= old_center;
							command_to_top <= busy;
							sorting = 0;
						end  
						else begin  
							command_to_left <= hold;
							command_to_right <= hold;
							command_to_top <= busy;
							data_to_top <= old_center; 
						end
					end 
			end  
		*/


			valid_sort: begin
				if(command_from_right == valid_sort) begin
					if(command_to_left != sort_right_validate) begin
						if(command_to_left == hold) begin
							command_to_left <= sort_right_validate;
							data_to_left   <= old_center;
							sorting = 0;
						end 
						else begin  
							command_to_left <= hold;
							command_to_right <= hold;
							command_to_top <= busy;
							data_to_top <= old_center; 
						end
					end
				end
				else if (command_from_right == valid_done) begin
					if(command_to_left != sort_right_validate) begin
						if(command_to_left == hold) begin
							command_to_left <= sort_right_validate;
							data_to_left   <= old_center;
							sorting = 0;
						end 
						else begin  
							command_to_left <= hold;
							command_to_right <= hold;
							command_to_top <= busy;
							data_to_top <= old_center; 
						end
					end
				end 
			end
			valid_semi_done :begin
				if(command_from_right == valid_sort) begin
					if(command_to_right != sort_left_validate) begin
						command_to_right <= sort_left_validate;
						data_to_right    <= data_from_left;
					end
				end
				else if (command_from_right == valid_done) begin
					if(command_to_right == sort_left_validate) begin
						command_to_right <= nop;
						command_to_left <= nop;
						old_center <= data_from_right;
						command_to_top <= valid_sort; 
						data_to_top <= data_from_right;
						sorting = 1;
					
					end
					else begin
						command_to_right <= nop;
						command_to_left <= nop;
						old_center <= data_from_left;
						command_to_top <= valid_sort; 
						data_to_top <= data_from_left;
						sorting = 1;
					end
				end
			end
			
			
			
			valid_done: begin
				if(command_from_right == valid_sort) begin
					if(command_to_right != sort_left_validate) begin
						command_to_right <= sort_left_validate;
						data_to_right    <= data_from_left;
					end
				end
				else if (command_from_right == valid_done) begin
					if(command_to_right == sort_left_validate) begin
						command_to_right <= nop;
						command_to_left <= nop;
						old_center <= data_from_right; 
						command_to_top <= valid_sort; 
						data_to_top <= data_from_right;
						sorting = 1;
					
					end 
					else if (command_to_left == sort_right_validate) begin
						command_to_right <= nop;
						command_to_left <= nop;
						old_center <= data_from_left;
						command_to_top <= valid_sort; 
						data_to_top <= data_from_left;
						sorting = 1;
					end
				end
			end
			
			
			

/*			valid_done: 
					if(command_to_right != sort_left_validate && command_to_left == sort_right_validate)  begin
						command_to_right <= sort_left_validate;
						data_to_right    <= data_from_left;
						sorting = 0;
					end 
					else if(command_from_right == valid_done && command_to_left == sort_right_validate) begin
						command_to_right <= nop;
						command_to_left <= nop;
						old_center <= data_from_right;
						command_to_top <= valid_sort; 
						data_to_top <= data_from_right;
						sorting = 1;
					end 
					else if(command_from_right == valid_done)
							command_to_top <= valid_sort; 
*/
					
				
				
			sort_done: if(command_from_right == sort_done) command_to_top <= sort_done;
			dne: if(sorting) begin
				if( command_to_top == valid_done) 
					command_to_top <= valid_done;
				else 
					command_to_top <= valid_sort;
				data_to_top <= old_center;
			end
			ready_to_sort: if(command_from_right == ready_to_sort) begin
				command_to_right <= nop;
				command_to_left  <= nop; 
			
			end
		endcase 
	end
	else if(command_from_right != nop) begin
		case(command_from_right)
	 		dne: if(sorting) begin
				if( command_to_top == valid_done) 
					command_to_top <= valid_done;
				else 
					command_to_top <= valid_sort;
				data_to_top <= old_center;
			end
			
			receive_center: begin 
				if(command_to_right == receive_center) begin
					command_to_right <= nop;
					command_to_left <= nop;
					command_to_top <= ready_to_sort;
					data_to_top <= old_center; 
					
				end
			end
		endcase
		
	end



end
endmodule 


