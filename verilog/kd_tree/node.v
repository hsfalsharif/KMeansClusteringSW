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
localparam sorting = 
			  sort_done = 
			  
reg self_state;
reg left_command, right_command,top_command;
reg left_data, right_data, top_data;

always @(posedge clk) begin
if(rst) begin
/// rest every thing
end
else 
	case(self_state) 
	///////////////////////// SORTING ////////////////////////////////////////////
		sorting:
				case({alert_top,alert_left.alert_right})
					3'b100,3'b101,3'b110,3'b111: begin 
					case(top_command)
						configure_sort:
						time_to_live <= data_from_top;
						sorting_axis       <= data_from_top;
						start_sort:
							self_state <= sorting
							left_command <= start_sort;
							righ_command <= start_sort;
					endcase

					
					
	///////////////////////// Point ////////////////////////////////////////////				
					
					
					
	endcase



			end
			
endcase
endmodule 


