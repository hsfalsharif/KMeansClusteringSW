
`timescale 1ns/1ns
module kd_tree;
	
localparam nop 					 		= 5'h00,
			  rst 					 		= 5'h1f,
			  rst_done 				 		= 5'h1e,
			  center_fill 			 		= 5'h01,
			  configure_sort_axis 		= 5'h02,
			  receive_center 		 		= 5'h03,
			  switch_with_left 	 		= 5'h04,
			  center_fill_done 	 		= 5'h05,
			  configure_sort_axis_done = 5'h07,
			  busy             	 		= 5'h08, 
			  dne              	 		= 5'h10,
			  start_sorting    	 		= 5'h09,
			  ready_to_sort    	 		= 5'h0a,
			  switch           	 		= 5'h0b,
			  sort_left_validate       = 5'h0c,
			  sort_right_validate      = 5'h0d,
			  valid_sort               = 5'h0f,
			  expose_center            = 5'h12,
			  valid_done               = 5'h11;
			  
localparam cycle_counter_size = $clog2(100000000);


localparam fill_center_tb = 5'b00001, 
			  idel =        5'b00010,
			  start_sorting_tb = 5'b00011,
			  stall            = 5'b00101,
			  done				= 5'b000100,
			  wait_sort       = 5'b000110;
reg [5:0]tb_state;



localparam command_size = 5,
			  data_size    = 24,
			  data_num     = 20;
			  




wire [command_size - 1 : 0] left_command_up,left_command_right,left_command_left;
wire [command_size - 1 : 0] right_command_up,right_command_right,right_command_left;
wire [command_size - 1 : 0] root_command_up,root_command_right,root_command_left;

wire[command_size - 1: 0 ] n1_command_up,n1_command_right,n1_command_left;
wire[command_size - 1: 0 ] n2_command_up,n2_command_right,n2_command_left;
wire[command_size - 1: 0 ] n3_command_up,n3_command_right,n3_command_left;
wire[command_size - 1: 0 ] n4_command_up,n4_command_right,n4_command_left;


wire [data_size - 1 : 0]   n1_data_up,n1_data_right,n1_data_left;
wire [data_size - 1 : 0]   n2_data_up,n2_data_right,n2_data_left;
wire [data_size - 1 : 0]   n3_data_up,n3_data_right,n3_data_left;
wire [data_size - 1 : 0]   n4_data_up,n4_data_right,n4_data_left;

reg [command_size - 1 : 0] tb_command;


wire [data_size - 1 : 0] left_data_up,left_data_right,left_data_left;
wire [data_size - 1 : 0] right_data_up,right_data_right,right_data_left;
wire [data_size - 1 : 0] root_data_up,root_data_right,root_data_left;
reg [data_size - 1 : 0] tb_data;
reg [23:0] in_im [data_num-1:0] ;

reg [3:0] stall_counter;
reg [cycle_counter_size-1 : 0] cycle_count, serial_count;
reg clk , reset;

node #("root ") root(  ///////// input //////////////
			 .clk(clk),
			 .data_from_top(tb_data),
			 .data_from_right(right_data_up),
			 .data_from_left (left_data_up),
			 .command_from_top(tb_command),
			 .command_from_right(right_command_up),
			 .command_from_left(left_command_up),
			     
			 ///////// output //////////////
			 .data_to_top(root_data_up),
			 .data_to_right(root_data_right),
			 .data_to_left(root_data_left),
			 .command_to_top(root_command_up),
			 .command_to_right(root_command_right),
			 .command_to_left(root_command_left)
			 ); 
node #("root-left ") left(
		///////// input //////////////
 		.clk(clk),
 		.data_from_top(root_data_left),
 		.data_from_right(n2_data_up),
 		.data_from_left (n1_data_up),
 		.command_from_top(root_command_left),
 		.command_from_right(n2_command_up),
 		.command_from_left(n1_command_up),

 		///////// output //////////////
 		.data_to_top(left_data_up),
 		.data_to_right(left_data_right),
 		.data_to_left(left_data_left),
 		.command_to_top(left_command_up),
 		.command_to_right(left_command_right),
 		.command_to_left(left_command_left)
);
node  #("root-right") right( 
		///////// input //////////////
		.clk(clk),
		.data_from_top(root_data_right),
		.data_from_right(n4_data_up),
		.data_from_left (n3_data_up),
		.command_from_top(root_command_right),
		.command_from_right(n4_command_up),
		.command_from_left(n3_command_up),
		///////// output //////////////
		.data_to_top(right_data_up),
		.data_to_right(right_data_right),
		.data_to_left(right_data_left),
		.command_to_top(right_command_up),
		.command_to_right(right_command_right),
		.command_to_left(right_command_left)
);

node  #("n1(ll)") n1(
		///////// input //////////////
		.clk(clk),
		.data_from_top(left_data_left),
		.data_from_right(0),
		.data_from_left (0),
		.command_from_top(left_command_left),
		.command_from_right(dne),
		.command_from_left(dne),
		///////// output //////////////
		.data_to_top(n1_data_up),
		.data_to_right(n1_data_right),
		.data_to_left(n1_data_left),
		.command_to_top(n1_command_up),
		.command_to_right(n1_command_right),
		.command_to_left(n1_command_left)
);

node  #("n2(lr)") n2(
		///////// input //////////////
		.clk(clk),
		.data_from_top(left_data_right),
		.data_from_right(0),
		.data_from_left (0),
		.command_from_top(left_command_right),
		.command_from_right(dne),
		.command_from_left(dne),
		///////// output //////////////
		.data_to_top(n2_data_up),
		.data_to_right(n2_data_right),
		.data_to_left(n2_data_left),
		.command_to_top(n2_command_up),
		.command_to_right(n2_command_right),
		.command_to_left(n2_command_left)
);




node  #("n3(rl)") n3(
		///////// input //////////////
		.clk(clk),
		.data_from_top(right_data_left),
		.data_from_right(0),
		.data_from_left (0),
		.command_from_top(right_command_left),
		.command_from_right(dne),
		.command_from_left(dne),
		///////// output //////////////
		.data_to_top(n3_data_up),
		.data_to_right(n3_data_right),
		.data_to_left(n3_data_left),
		.command_to_top(n3_command_up),
		.command_to_right(n3_command_right),
		.command_to_left(n3_command_left)
);

node  #("n4(rr)") n4(
		///////// input //////////////
		.clk(clk),
		.data_from_top(right_data_right),
		.data_from_right(0),
		.data_from_left (0),
		.command_from_top(right_command_right),
		.command_from_right(dne),
		.command_from_left(dne),
		///////// output //////////////
		.data_to_top(n4_data_up),
		.data_to_right(n4_data_right),
		.data_to_left(n4_data_left),
		.command_to_top(n4_command_up),
		.command_to_right(n4_command_right),
		.command_to_left(n4_command_left)
);
 
initial begin
        $display("Loading image.\n");

        // $readmemh("C:/Users/atom/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/test.hex", in_im);
		  $readmemh("C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/sequantial/test.hex", in_im);

        //$readmemh("C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/test.hex", in_im);
		  //$readmemh("C:/Users/atom/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/test.hex", in_im);
		  //$readmemh("C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/sequantial/test.hex", in_im);
		  //f = $fopen("output.rgb", "wb");
    end
 
initial begin	//the reset sequence and clock
	clk = 0;reset = 0 ; cycle_count = 0 ;serial_count=0; tb_state = idel;
	#5 reset = 1 ;clk=1; #5 reset = 0; clk=0;
	repeat(500) #5 clk = ~clk ;
	  end

always @ (negedge clk)	begin 	// Read input pixels from in_im
	cycle_count <= cycle_count + 1;
	$display("#################### new cycle: %d ##########################",cycle_count); 
	if(reset) begin
		tb_state <= idel;
		stall_counter <= 0;
		cycle_count <= 0;
		
	end
	else
	case (tb_state)
	   idel: begin
		if(root_command_up == rst_done) begin
					$display("[%d] %s DONE",cycle_count,"rst");
					tb_state <= fill_center_tb;
	 	end
		else 
			begin
			$display("[%d] %s",cycle_count,"idle");
			tb_command <= rst;
			end
		end
		fill_center_tb: begin
				if(root_command_up == center_fill_done) begin
					$display("[%d] %s DONE",cycle_count,"fill_center_tb");
					tb_state <= start_sorting_tb;
				end
				else begin
					tb_data <= in_im [serial_count];
					tb_command <= center_fill;
					serial_count <= serial_count + 1;
					$display("[%d] %s tb_data: %x tb_command: %b serial_Count: %d root_command_up: %b",cycle_count,"fill_center_tb",tb_data,tb_command,serial_count,root_command_up);

				end
		end
		start_sorting_tb: begin
			tb_state <= wait_sort; 
			if(root_command_up == valid_sort )
				tb_state <= done;
		   tb_command <= start_sorting;
			tb_data <= 0;
 
		end
		wait_sort : begin 
			if(root_command_up == valid_sort )
				tb_state <= done;
			tb_command <= nop;  

		end
		stall : begin
					 tb_command <= nop;  
					if(stall_counter == 0)
						tb_state <= done;
				   else  stall_counter <= stall_counter - 1;
				 end 
		
		done:
			$finish;
		endcase
end



endmodule 