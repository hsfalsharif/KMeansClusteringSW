module node(clk, rst , data_from_top,data_from_right,data_from_left,command_from_top,command_from_right,command_from_left,data_to_top,data_to_right,data_to_left,command_to_top,command_to_right,command_to_left);

input clk, rst,alert_top,alert_left,alert_right;
input data_from_top,data_from_right,data_from_left;
input command_from_top,command_from_right,command_from_left,data_from_top;
output data_to_top,data_to_right,data_to_left;
output command_to_top,command_to_right,command_to_left;

/// Commands
localparam start_sort = 
			  configure_sort = 
			  wait_sort_ack = 
			  send_sort_ack = 
			  switch_with_top = 
			  switch_with_down = 
/// States
localparam wait_down_command = 
			  wait_top_command  = 
			  sorting = 
			  sort_done = 
			  
reg self_state;
reg left_command, right_command,top_command;
reg left_data, right_data, top_data;

reg sorting_axis;
reg time_to_live;

reg wait_down_for;
reg self_state_after_ack;
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

cluster_CE c_ce (.clk(clk), 
					  .rst(rst),
					  .en(en),
					  .sorting(1'b1),
					  .left(left_in), 
					  .parent(center_self_P2C), 
					  .right(right_in),
					  .axis(axis_in), 
					  .stable(sefl_stable), 
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
else 
	case(self_state) 
	///////////////////////// SORTING ////////////////////////////////////////////
	/* commands 
		1) configuer time_to_live and axis
		2) start_sorting : turn on CE and consider it's output
	
	
	
	
	
	
	
	*/
	
	/////////////////////////////////////////////////////////////////////////////
		sorting:
				case({alert_top,alert_left.alert_right})
					3'b100,3'b101,3'b110,3'b111: begin 
					case(top_command)
						configure_sort:
							time_to_live <= data_from_top;
							sorting_axis <= data_from_top;
							self_state <= sorting
							left_command <= start_sort;
							righ_command <= start_sort;
							data_to_left <= time_to_live + 1 , axit same just forward.
							if(self_lower_exists)
								self_state <= wait_down_command;
							else 
							wait_down_for <= sort_configure_ack
							self_state_after_wait <= sorting;
					endcase

					
	///////////////////////// waiting //////////////////////////////////////////
	
		wait_child_ack:
			case({alert_top,alert_left.alert_right})
				3'b100,3'b101,3'b110,3'b111: begin 
					case(top_command)
					endcase
				3'b010,3'b011,3'b001: begin
					if(left_command == wait_down_for && right_command == wait_down_for)
						state <= self_state_after_wait
				
				end

			endcase
	
	
	
	
	///////////////////////// Point ////////////////////////////////////////////				
					
					
					
	endcase



			end
			
endcase
endmodule 


