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
					  
					  

always * begin
	case({})
	
	
	
	
	

end
		  
					  
always @(posedge clk) begin
if(rst) begin
/// rest every thing
end
else 
	case(self_state) 
	///////////////////////// SORTING ////////////////////////////////////////////
	/* commands 
		1) configuer time_to_live and axis
		2) start_sorting : turn on CE and consider it's output
	
	
	
	
	
	
	
	*/
	
	
	//////////////// configurte///////////////////////////////////////////////////////////
	
	feeding:
		if(top_alert) 
			case(top_command) 
				set_center:
					data_to_left <= data_from_top;
					left
			
			
			endcase
	
	
	
	
	
	
	
	
	
	//////////////////////////////// Sorting /////////////////////////////////////////////
	
	

		configure_sort:
				if(top_alert)
					case(command_from_top)
						depth_time_to_live:
							time_to_live <= data_from_top;
							sorting_axis <= data_from_top;							
							if(self_lower_exists)
								// setup child nodes for sorting
								left_command <= depth_time_to_live;
								righ_command <= depth_time_to_live;
								data_to_left <= time_to_live + 1 , axit same just forward.
								data_to_right <= time_to_live + 1 , axit same just forward.
								// wait for child ack to propagate configure status
								self_state <= wait_down_command;
								wait_down_for <= send_sort_ack;
								self_state_after_down_wait    <= wait_top_command;
								
								left_command_after_down_wait  <=  nop;
								right_command_after_down_wait <=  nop;
								top_command_after_down_wait   <=  send_sort_ack;
								/// change this belwo 
								
								wait_up_for <= start_sorting;
								self_state_after_up_wait    <=  sorting;
								left_command_after_up_wait  <=  nop;
								right_command_after_up_wait <=  nop;
								top_command_after_up_wait   <=  nop;
								
								
							else 
								top_command <= send_sort_ack;
								self_state <= unconditional_wait;
								
					endcase
				
					
		sorting:
			if(top_alert)
				case(command_from_top)
					switch_top:
					/// first copy the top's center
					/// and send switch_done signal
					/// 
						center <= data_from_top;
						top_command <= switch_done;
						right_command <= busy;
						left_command <= busy;
			
						
						wait_up_for <= switch_ack;
						self_state_after_up_wait    <=  sorting;
						left_command_after_up_wait  <=  nop;
						right_command_after_up_wait <=  nop;
						top_command_after_up_wait   <=  nop;
				endcase
				
				
			else if(self_alert)
				case(command_from_self)
					switch_with_left:
						if(command_from_left != busy) 
							center <= data_from_left;
							left_command <= switch_done;
							right_command <= busy;
							top_command <= busy;
						
						
							wait_up_for <= switch_ack;
							self_state_after_up_wait    <=  sorting;
							left_command_after_up_wait  <=  nop;
							right_command_after_up_wait <=  nop;
							top_command_after_up_wait   <=  nop;
					
					switch_with_right:
						if(command_from_right != busy)
							center <= data_from_right;
							right_command <= switch_done;
							top_command <= busy;
							left_command <= busy;
						
						
							wait_up_for <= switch_ack;
							self_state_after_up_wait    <=  sorting;
							left_command_after_up_wait  <=  nop;
							right_command_after_up_wait <=  nop;
							top_command_after_up_wait   <=  nop;
					
					swtich_left_right:
						if(command_from_right != busy && command_from_left != busy)
							data_to_left <= data_from_right;
							data_to_right <= data_from_left;
							top_command <= busy;
							right_command <= switch_top;
							left_command <= switch_top;
						
							wait_down_for <= switch_ack;
							self_state_after_up_wait    <=  sorting;
							left_command_after_up_wait  <=  nop;
							right_command_after_up_wait <=  nop;
							top_command_after_up_wait   <=  nop;
							
					rotate_right:
						
					
					rotate_left:
				endcase
			
	
	///////////////////////// waiting //////////////////////////////////////////
	
		wait_down_command:
					if(command_from_left == wait_down_for && command_from_right == wait_down_for) begin
						self_state <= self_state_after_down_wait;
						left_command <= left_command_after_down_wait;
						right_command <= right_command_after_down_wait;
						top_command <=  top_command_after_down_wait;
				
				end

			
	
	
	
	wait_top_command:
			if(command_from_top == wait_up_for) begin
						self_state <= self_state_after_up_wait;
						left_command <= left_command_after_up_wait;
						right_command <= right_command_after_up_wait;
						top_command <=  top_command_after_up_wait;
				

			end

	
	///////////////////////// Point ////////////////////////////////////////////				
					
					
					
	endcase



			end
			
endcase
endmodule 


