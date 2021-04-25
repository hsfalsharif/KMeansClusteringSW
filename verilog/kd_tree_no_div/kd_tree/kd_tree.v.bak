
`timescale 1ns/1ns
module kd_tree;
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
			  
localparam cycle_counter_size = $clog2(100000000);


localparam fill_center_tb = 5'b00001, 
			  idel =        5'b00010,
			  start_sorting_tb = 5'b00011,
			  stall            = 5'b00101,
			  done				= 5'b000100,
			  wait_sort       = 5'b000110,
			  point_tb        = 5'b000111,
			  set_axis        = 5'b001000,
			  new_point       = 5'b001001,
			  stability       = 5'b001010;
reg [5:0]tb_state;
  
   
  
localparam data_num     = 100;
			  
localparam  dim_size     = $clog2(255),
				dim          = 3,
				max_n        = 3800 , 
				center_size  = dim*dim_size,
				counter_size = $clog2(max_n),
				acc_size     = $clog2(dim_size*max_n),
				depth_size   = $clog2(10);
localparam command_size = 6,
			  data_size    = center_size * 2,
			  data_half_size = center_size,
			  ttl_size     = 4,
			  axis_size    = 2;
 

reg [data_size - 1 : 0] tb_data;
reg [23:0] in_im [data_num-1:0] ;
reg [23:0] in_point [max_n-1:0] ;

reg [command_size - 1 : 0] tb_command;

reg [3:0] stall_counter;
reg [cycle_counter_size-1 : 0] cycle_count, serial_count,point_counter,point_t,it;
reg clk , reset;

///////////////////// PASTE HERE ///////////////////////////////
wire[command_size - 1: 0 ] n0_command_up,n0_command_right,n0_command_left;
wire [data_size - 1 : 0]   n0_data_up,n0_data_right,n0_data_left;
wire[command_size - 1: 0 ] n1_command_up,n1_command_right,n1_command_left;
wire [data_size - 1 : 0]   n1_data_up,n1_data_right,n1_data_left;
wire[command_size - 1: 0 ] n2_command_up,n2_command_right,n2_command_left;
wire [data_size - 1 : 0]   n2_data_up,n2_data_right,n2_data_left;
wire[command_size - 1: 0 ] n3_command_up,n3_command_right,n3_command_left;
wire [data_size - 1 : 0]   n3_data_up,n3_data_right,n3_data_left;
wire[command_size - 1: 0 ] n4_command_up,n4_command_right,n4_command_left;
wire [data_size - 1 : 0]   n4_data_up,n4_data_right,n4_data_left;
wire[command_size - 1: 0 ] n5_command_up,n5_command_right,n5_command_left;
wire [data_size - 1 : 0]   n5_data_up,n5_data_right,n5_data_left;
wire[command_size - 1: 0 ] n6_command_up,n6_command_right,n6_command_left;
wire [data_size - 1 : 0]   n6_data_up,n6_data_right,n6_data_left;
wire[command_size - 1: 0 ] n7_command_up,n7_command_right,n7_command_left;
wire [data_size - 1 : 0]   n7_data_up,n7_data_right,n7_data_left;
wire[command_size - 1: 0 ] n8_command_up,n8_command_right,n8_command_left;
wire [data_size - 1 : 0]   n8_data_up,n8_data_right,n8_data_left;
wire[command_size - 1: 0 ] n9_command_up,n9_command_right,n9_command_left;
wire [data_size - 1 : 0]   n9_data_up,n9_data_right,n9_data_left;
wire[command_size - 1: 0 ] n10_command_up,n10_command_right,n10_command_left;
wire [data_size - 1 : 0]   n10_data_up,n10_data_right,n10_data_left;
wire[command_size - 1: 0 ] n11_command_up,n11_command_right,n11_command_left;
wire [data_size - 1 : 0]   n11_data_up,n11_data_right,n11_data_left;
wire[command_size - 1: 0 ] n12_command_up,n12_command_right,n12_command_left;
wire [data_size - 1 : 0]   n12_data_up,n12_data_right,n12_data_left;
wire[command_size - 1: 0 ] n13_command_up,n13_command_right,n13_command_left;
wire [data_size - 1 : 0]   n13_data_up,n13_data_right,n13_data_left;
wire[command_size - 1: 0 ] n14_command_up,n14_command_right,n14_command_left;
wire [data_size - 1 : 0]   n14_data_up,n14_data_right,n14_data_left;

            node #("n0") n0(
            ///////// input //////////////
                         .clk(clk),
                         .data_from_top(tb_data),
                         .data_from_right(n2_data_up),
                         .data_from_left (n1_data_up),
                         .command_from_top(tb_command),
                         .command_from_right(n2_command_up),
                         .command_from_left (n1_command_up),

                         ///////// output //////////////
                         .data_to_top     (n0_data_up),
                         .data_to_right   (n0_data_right),
                         .data_to_left    (n0_data_left),
                         .command_to_top  (n0_command_up),
                         .command_to_right(n0_command_right),
                         .command_to_left (n0_command_left)
                         );


                node #("n1") n1(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n0_data_left),
                 .data_from_right(n4_data_up),
                 .data_from_left (n3_data_up),
                 .command_from_top(n0_command_left),
                 .command_from_right(n4_command_up),
                 .command_from_left (n3_command_up),

                 ///////// output //////////////
                 .data_to_top     (n1_data_up),
                 .data_to_right   (n1_data_right),
                 .data_to_left    (n1_data_left),
                 .command_to_top  (n1_command_up),
                 .command_to_right(n1_command_right),
                 .command_to_left (n1_command_left)
                 );


                node #("n2") n2(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n0_data_right),
                 .data_from_right(n6_data_up),
                  .data_from_left (n5_data_up),
                 .command_from_top(n0_command_right),
                 .command_from_right(n6_command_up),
                 .command_from_left (n5_command_up),

                 ///////// output //////////////
                 .data_to_top     (n2_data_up),
                 .data_to_right   (n2_data_right),
                 .data_to_left    (n2_data_left),
                 .command_to_top  (n2_command_up),
                 .command_to_right(n2_command_right),
                 .command_to_left (n2_command_left)
                 );


                node #("n3") n3(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n1_data_left),
                 .data_from_right(n8_data_up),
                 .data_from_left (n7_data_up),
                 .command_from_top(n1_command_left),
                 .command_from_right(n8_command_up),
                 .command_from_left (n7_command_up),

                 ///////// output //////////////
                 .data_to_top     (n3_data_up),
                 .data_to_right   (n3_data_right),
                 .data_to_left    (n3_data_left),
                 .command_to_top  (n3_command_up),
                 .command_to_right(n3_command_right),
                 .command_to_left (n3_command_left)
                 );


                node #("n4") n4(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n1_data_right),
                 .data_from_right(n10_data_up),
                 .data_from_left (n9_data_up),
                 .command_from_top(n1_command_right),
                 .command_from_right(n10_command_up),
                 .command_from_left (n9_command_up),

                 ///////// output //////////////
                 .data_to_top     (n4_data_up),
                 .data_to_right   (n4_data_right),
                 .data_to_left    (n4_data_left),
                 .command_to_top  (n4_command_up),
                 .command_to_right(n4_command_right),
                 .command_to_left (n4_command_left)
                 );


                node #("n5") n5(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n2_data_left),
                 .data_from_right(n12_data_up),
                 .data_from_left (n11_data_up),
                 .command_from_top(n2_command_left),
                 .command_from_right(n12_command_up),
                 .command_from_left (n11_command_up),

                 ///////// output //////////////
                 .data_to_top     (n5_data_up),
                 .data_to_right   (n5_data_right),
                 .data_to_left    (n5_data_left),
                 .command_to_top  (n5_command_up),
                 .command_to_right(n5_command_right),
                 .command_to_left (n5_command_left)
                 );


                node #("n6") n6(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n2_data_right),
                 .data_from_right(n14_data_up),
                 .data_from_left (n13_data_up),
                 .command_from_top(n2_command_right),
                 .command_from_right(n14_command_up),
                 .command_from_left (n13_command_up),

                 ///////// output //////////////
                 .data_to_top     (n6_data_up),
                 .data_to_right   (n6_data_right),
                 .data_to_left    (n6_data_left),
                 .command_to_top  (n6_command_up),
                 .command_to_right(n6_command_right),
                 .command_to_left (n6_command_left)
                 );


                node #("n7") n7(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n3_data_left),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n3_command_left),
                 .command_from_right(dne),
                 .command_from_left (dne),

                 ///////// output //////////////
                 .data_to_top     (n7_data_up),
                 .data_to_right   (n7_data_right),
                 .data_to_left    (n7_data_left),
                 .command_to_top  (n7_command_up),
                 .command_to_right(n7_command_right),
                 .command_to_left (n7_command_left)
                 );


                node #("n8") n8(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n3_data_right),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n3_command_right),
                 .command_from_right(dne),
                 .command_from_left (dne),

                 ///////// output //////////////
                 .data_to_top     (n8_data_up),
                 .data_to_right   (n8_data_right),
                 .data_to_left    (n8_data_left),
                 .command_to_top  (n8_command_up),
                 .command_to_right(n8_command_right),
                 .command_to_left (n8_command_left)
                 );


                node #("n9") n9(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n4_data_left),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n4_command_left),
                 .command_from_right(dne),
                 .command_from_left (dne),

                 ///////// output //////////////
                 .data_to_top     (n9_data_up),
                 .data_to_right   (n9_data_right),
                 .data_to_left    (n9_data_left),
                 .command_to_top  (n9_command_up),
                 .command_to_right(n9_command_right),
                 .command_to_left (n9_command_left)
                 );


                node #("n10") n10(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n4_data_right),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n4_command_right),
                 .command_from_right(dne),
                 .command_from_left (dne),

                 ///////// output //////////////
                 .data_to_top     (n10_data_up),
                 .data_to_right   (n10_data_right),
                 .data_to_left    (n10_data_left),
                 .command_to_top  (n10_command_up),
                 .command_to_right(n10_command_right),
                 .command_to_left (n10_command_left)
                 );


                node #("n11") n11(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n5_data_left),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n5_command_left),
                 .command_from_right(dne),
                 .command_from_left (dne),

                 ///////// output //////////////
                 .data_to_top     (n11_data_up),
                 .data_to_right   (n11_data_right),
                 .data_to_left    (n11_data_left),
                 .command_to_top  (n11_command_up),
                 .command_to_right(n11_command_right),
                 .command_to_left (n11_command_left)
                 );


                node #("n12") n12(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n5_data_right),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n5_command_right),
                 .command_from_right(dne),
                 .command_from_left (dne),

                 ///////// output //////////////
                 .data_to_top     (n12_data_up),
                 .data_to_right   (n12_data_right),
                 .data_to_left    (n12_data_left),
                 .command_to_top  (n12_command_up),
                 .command_to_right(n12_command_right),
                 .command_to_left (n12_command_left)
                 );


                node #("n13") n13(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n6_data_left),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n6_command_left),
                 .command_from_right(dne),
                 .command_from_left (dne),

                 ///////// output //////////////
                 .data_to_top     (n13_data_up),
                 .data_to_right   (n13_data_right),
                 .data_to_left    (n13_data_left),
                 .command_to_top  (n13_command_up),
                 .command_to_right(n13_command_right),
                 .command_to_left (n13_command_left)
                 );


                node #("n14") n14(
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n6_data_right),
                 .data_from_right({ data_size{1'b0} }),
                 .data_from_left ({ data_size{1'b0} }),
                 .command_from_top(n6_command_right),
                 .command_from_right(dne),
                 .command_from_left (dne), 

                 ///////// output //////////////
                 .data_to_top     (n14_data_up),
                 .data_to_right   (n14_data_right),
                 .data_to_left    (n14_data_left),
                 .command_to_top  (n14_command_up),
                 .command_to_right(n14_command_right),
                 .command_to_left (n14_command_left)
                 );

 

///////////////////////////////////////////////////////////////

initial begin
        $display("Loading image.\n");
        $readmemh("C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/kd_tree/means.hex", in_im);
		  $readmemh("C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/sample.hex", in_point);

		  //$readmemh("C:/Users/atom/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/test.hex", in_im);
		  //$readmemh("C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/sequantial/test.hex", in_im);
		  //f = $fopen("output.rgb", "wb");
    end
 
initial begin	//the reset sequence and clock
	clk = 0;reset = 0 ; cycle_count = 0 ;serial_count=0; tb_state = idel;point_counter = 0;point_t = 0;it= 0;
	#5 reset = 1 ;clk=1; #5 reset = 0; clk=0;
	repeat(42949672) #5 clk = ~clk ;
	  end
 
always @ (negedge clk)	begin 	// Read input pixels from in_im
	cycle_count <= cycle_count + 1;
	//$display("#################### new cycle: %d ##########################",cycle_count); 
	if(reset) begin
		tb_state <= idel;
		stall_counter <= 0;
		cycle_count <= 0;
		point_counter <= 0;
		point_t <= 0;
		
	end
	else
	case (tb_state)
	   idel: begin  
		if(n0_command_up == rst_done) begin
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
				if(n0_command_up == center_fill_done) begin
					$display("[%d] %s DONE",cycle_count,"fill_center_tb");
					tb_state <= set_axis;
				end
				else begin 
					tb_data <= in_im [serial_count];
					tb_command <= center_fill;
					serial_count <= serial_count + 1;
					$display("[%d] %s tb_data: %x tb_command: %b serial_Count: %d n0_command_up: %b",cycle_count,"fill_center_tb",tb_data,tb_command,serial_count,n0_command_up);

				end
		end 
		start_sorting_tb: begin
			tb_state <= wait_sort; 
			if(n0_command_up == sort_done )
				tb_state <= done;
		   tb_command <= start_sorting_as_root;
			tb_data <= 0; 
  
		end
		wait_sort : begin 
			if(n0_command_up == sort_done ) begin
				tb_state <= point_tb;
				$display("###################### Sort END ######################");
			end
			tb_command <= nop; 
		end
		set_axis: begin
				tb_command <= axis_set_inc;
				tb_data    <= 0;
				tb_state   <= point_tb;
		end  
		point_tb: begin 
			if(n0_command_up == return_best) begin
				tb_command <= nopme;
				point_counter <= point_counter + 1; 
				tb_data    <= {data_size{1'b0}};
				tb_state <= new_point;
			end
			else begin
				tb_command <= point_in_as_root;
				tb_data    <= {{24{1'b0}},in_point[point_counter]};
				point_t <= point_t + 1;
			end
			
		end
		new_point: begin 
				$display("%x ==> %x %d",n0_data_up[0 +: data_half_size] , n0_data_up[data_half_size +: data_half_size],point_t);
				point_t <= 0;
				if(point_counter >= max_n) begin	
					tb_state <= stability;
					$display("######################### Iteration : %d #########################" , it);
					it <= it + 1;
					point_counter <= 0;
				end
				else 
					tb_state <= point_tb;
				
				
		end
		stability: begin
			tb_command <= divide;
			tb_data    <= {data_size{1'b1}};
			
			if(n0_command_up == unstable)begin
				tb_state <= point_tb;
				tb_command <= new_iteration;
			end
			else if(n0_command_up == stable)
				tb_state <= done;
			
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