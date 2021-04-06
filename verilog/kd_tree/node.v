module node(clk, rst , data_from_top,data_from_right,data_from_left,command_from_top,command_from_right,command_from_left,data_to_top,data_to_right,data_to_left,command_to_top,command_to_right,command_to_left);

input clk, rst,alert_top,alert_left,alert_right;
input data_from_top,data_from_right,data_from_left;
input command_from_top,command_from_right,command_from_left,data_from_top;
output reg data_to_top,data_to_right,data_to_left;
output command_to_top,command_to_right,command_to_left;

/// Commands
localparam start_sort = 
			  nop = 
			  wait_sort_ack = 
			  send_sort_ack = 
			  switch_with_top = 
			  switch_with_down = 
/// States
localparam wait_down_command = 
			  wait_top_command  = 
			  configure_sort = 
			  configuration_done = 
			  sorting = 
			  sort_done = 
			  
reg self_state;
reg left_command,right_command,top_command;
reg left_data, right_data, top_data;

reg sorting_axis;
reg time_to_live;

reg wait_down_for, wait_up_for;
reg self_state_after_down_wait, self_state_after_up_wait;
reg left_command_after_down_wait,right_command_after_down_wait, top_command_after_down_wait;
reg left_command_after_up_wait,right_command_after_up_wait, top_command_after_up_wait;
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

wire sort_stable ;
assign ce_sorting = self_state == sorting;

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
					  
					  

  
always @(posedge clk) begin
if(rst) begin
/// rest every thing
end
else if(command_from_top != nop)
		case(command_from_top)
			center_fill: begin
				if(command_from_left != center_fill_done) begin
					data_to_left <= data_from_top;
					command_to_left <= cetner_fill;
					command_to_top <= nop;
					command_to_right <= nop;
				end
				else if (command_from_right != center_fill_done) begin
						data_to_right <= data_from_top;
						command_to_right <= cetner_fill;	
						command_to_top <= nop;
						command_to_left <= nop;		
				end
				
				else begin
					center <= data_from_top;
					command_to_top <= center_fill_done;
					command_to_right <= nop;
					command_to_left <= nop;
				end
			
			end
		///////////////////// END center fill //////////////////////////////
		configure_sort_axis: begin
			if(command_from_left == configure_sort_axis_done && command_from_right == configure_sort_axis_done) begin
				command_to_top <= configure_sort_axis_done;
				command_to_right <= nop;
				command_to_left <= nop;
			
			end
			else begin
				sorting_axis <= data_from_top;
				data_to_left <= data_from_top;
				data_to_right <= data_from_top;
				command_to_left <= configure_sort;
				command_to_right <= configure_sort;
				command_to_top <= nop;
			end
		
		
		end
		//////////////////////////////////////////// END CONFIGUREATION AXIS /////////////////////////////
		
		
		recieve_center: begin
						
						center <= data_from_top;
						data_to_top <= center;
						command_to_top <= recieve_center;

						right_command <= nop;
						left_command <= nop;
		
		end
		
		
		
		endcase
	else if(self_command != nop) begin 
		case(self_command)
			switch_with_left:
				if(command_from_left == receive_center && comman_to_left == receive_center) begin
					center <= data_from_left;
					command_to_left <= nop;
					
				
				end
				else if(command_from_left != busy) begin
					
				
				
				end
			
		  
		endcase
	end
	else if(left_command != nop) begin
		case(left_command)
		endcase
		
	end
	else begin 
		case(right_command)
		endcase
	end

endmodule 


