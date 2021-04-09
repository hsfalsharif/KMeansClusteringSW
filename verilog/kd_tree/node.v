module node(clk, data_from_top,data_from_right,data_from_left,command_from_top,command_from_right,command_from_left,data_to_top,data_to_right,data_to_left,command_to_top,command_to_right,command_to_left);

localparam command_size = 5,
			  data_size    = 24,
			  ttl_size     = 4,
			  axis_size    = 2,
			  center_size  = 24;
			  
parameter name="unknown";

input clk;
input      [data_size - 1 : 0]    data_from_top,data_from_right,data_from_left;
input      [command_size - 1 : 0] command_from_top,command_from_right,command_from_left;
output reg [data_size - 1 : 0]    data_to_top,data_to_right,data_to_left;
output reg [command_size - 1 : 0] command_to_top,command_to_right,command_to_left;

/// Commands
localparam nop =  5'b00000,
			  rst = 5'b11111,
			  rst_done = 5'b11110,
			  center_fill =  5'b00001,
			  configure_sort_axis = 5'b00010,
			  recieve_center =  5'b00011,
			  switch_with_left =  5'b00100,
			  center_fill_done =  5'b00101,
			  cetner_fill      =  5'b00110,
			  configure_sort_axis_done = 5'b00111,
			  busy             = 5'b01000,
			  dne              = 5'b10000;


reg [axis_size - 1 : 0] sorting_axis;
reg [ttl_size - 1 : 0] time_to_live;
reg [center_size-1:0] parent_in, center;
reg [command_size - 1 : 0] command_pipe;
reg [data_size - 1 : 0]     data_pipe;

wire [command_size - 1 : 0] self_command;
wire [center_size - 1:0] center_self_C2P, center_self_P2C, ce_left_out, ce_right_out;
reg rst_t, init, start_iter, receive_point, inc, update, sorting, parent_switch_in, self_child_switch, next_level;
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

cluster_CE c_ce (
						.clk(clk),
						.rst(rst_t),
						.en(ce_en), // pe enables ce
						.sorting(sorting),
						.left_en(left_en),
						.right_en(right_en),
						.left(data_from_left),
						.parent(center_self_P2C),
						.right(data_from_right),
						.point_in(data_from_top), // do we need to pass point through pe before passing it to ce or can we pass it directly from data_from_top?
						.axis(sorting_axis),
						.stable(sort_stable),
						.left_switch(left_switch),
						.parent_switch(self_switch),
						.right_switch(right_switch),
						.go_left(), // will be added later with point propogation stage
						.new_left(ce_left_out),
						.new_parent(center_self_C2P),
						.new_right(ce_right_out)
						);

wire [2:0] ce_command;
assign ce_command = {left_switch, self_switch, right_switch};

/*always @* begin
    case (ce_command)
        switch_left:
            self_command <= switch_with_left;
        swith_right:
            self_command <= switch_with_right;
        rotate_right:
            self_command <= rotate_r;
        rotate_left:
            self_command <= rotate_l;
        point_left:
            self_command <= pl;
        point_right:
            self_command <= pr;
        point_consume:
            self_command <= pc;
        best_changed:
            self_command <= best_changed;

        endcase
*/


always @* begin
	case(command_from_top)
		rst:
			rst_t = 1;
		center_fill:
			if(!(command_from_left != center_fill_done && !left_dne) && !(command_from_right != center_fill_done && ! right_dne) && !(command_to_top != center_fill_done ))
				if(both_dne) begin
					parent_in <= data_from_top;
					init <= 1;
				end
				else begin
					parent_in <= data_to_right;
					init <= 1;
				end
			else begin
				parent_in <= 0;
				init <= 0;
			end
		default: begin
			rst_t <= 0;
			init <= 0;
			start_iter <= 0;
			receive_point <= 0;
			inc <= 0;
			update <= 0;
		end
		endcase
end

always @(posedge clk) begin
$display("node: %s center %x command_from [%x %x %x] data_from [%x %x %x] command_to [%x %x %x] data_to [%x %x %x]  Child_status [%x %x]",name,center,command_from_left,command_from_top,command_from_right,data_from_left,data_from_top,data_from_right,command_to_left,command_to_top,command_to_right,data_to_left,data_to_top,data_to_right,left_dne,right_dne);

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
				if(command_from_left != center_fill_done && !left_dne) begin
					data_to_left <= data_from_top;
					data_pipe <= data_from_top;
 
					command_to_left <= center_fill;
					command_to_top <= nop;
					command_to_right <= nop;
				end
				else if (command_from_right != center_fill_done && ! right_dne) begin
						data_to_right <= data_pipe;
						data_pipe <= data_from_top;
						command_to_right <= center_fill;	
						command_to_top <= nop;
						command_to_left <= center_fill;		
				end
			
				else if(command_to_top != center_fill_done )
				begin
					if(both_dne) 
						center <= data_from_top;
					else 
						center <= data_to_right;
					
					command_to_top <= center_fill_done;
					command_to_right <= nop;
					command_to_left <= nop;
				
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
		//////////////////////////////////////////// END CONFIGUREATION AXIS /////////////////////////////
		
		
		recieve_center: begin
						if(command_to_top == recieve_center && command_from_top == recieve_center) begin
							command_to_top <= nop;
						end
						else if(command_from_top == recieve_center && command_to_top != recieve_center) begin
							command_to_top <= recieve_center;
							command_to_left <= busy;
							command_to_right <= busy;
							center <= data_from_top;
							data_to_top <= center;
						end
						
		end
		
		
		
		endcase
	else if(self_command != nop) begin 
		case(self_command)
			switch_with_left:
				if(command_to_left == recieve_center && command_from_left == recieve_center) begin
							command_to_left <= nop;
							center <= data_from_left;
							command_to_left <= nop;
						end
						else begin
							command_to_left <= recieve_center;
							data_to_left <= center;

							command_to_top <= busy;
							command_to_right <= busy;
						end			
		  
		endcase
	end
	else begin
		command_to_top   <= nop;
		command_to_left  <= nop;
		command_to_right <= nop;
		
	end
	/*else if(left_command != nop) begin
		case(left_command)
		endcase
		
	end
	else begin 
		case(right_command)
		endcase
	end
*/


end
endmodule 


