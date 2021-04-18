module container(clk,tb_command,tb_data,n0_data_left);
localparam  dim_size     = $clog2(255),
				dim          = 3,
				max_n        = 3800, 
				center_size  = dim*dim_size,
				counter_size = $clog2(max_n),
				acc_size     = $clog2(dim_size*max_n),
				depth_size   = $clog2(10);
localparam command_size = 6,
			  data_size    = center_size * 2,
			  data_half_size = center_size,
			  ttl_size     = 4,
			  axis_size    = 2;

input clk;			  
input [command_size - 1: 0 ] tb_command;
input [data_size - 1 : 0]    tb_data;
 
output [data_size - 1 : 0] n0_data_left;
localparam data_num     = 100;
			  
			  
wire[command_size - 1: 0 ] n0_command_up,n0_command_right,n0_command_left;
wire [data_size - 1 : 0]   n0_data_up,n0_data_right;



wire[command_size - 1: 0 ] n1_command_up,n2_command_up;
wire [data_size - 1 : 0]   n1_data_up,n2_data_up;

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

endmodule 