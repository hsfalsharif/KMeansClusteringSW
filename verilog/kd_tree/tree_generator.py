import math



n = 15
for i in range(n):
    print(f"wire[command_size - 1: 0 ] n{i}_command_up,n{i}_command_right,n{i}_command_left;")
    print(f"wire [data_size - 1 : 0]   n{i}_data_up,n{i}_data_right,n{i}_data_left;")





for i in range(n):
    if i == 0:
        print(f"""
            node #("n{i}") n{i}(  
            ///////// input //////////////
			 .clk(clk),
			 .data_from_top(tb_data),
			 .data_from_right(n{2*i+2}_data_up),
			 .data_from_left (n{2*i+1}_data_up),
			 .command_from_top(tb_command),
			 .command_from_right(n{2*i+2}_command_up),
			 .command_from_left (n{2*i+1}_command_up),
			     
			 ///////// output //////////////
			 .data_to_top     (n{i}_data_up),
			 .data_to_right   (n{i}_data_right),
			 .data_to_left    (n{i}_data_left),
			 .command_to_top  (n{i}_command_up),
			 .command_to_right(n{i}_command_right),
			 .command_to_left (n{i}_command_left)
			 );     
        """)
    else :

            parent = math.ceil((i-2)/2)
            if parent != (i-2)/2:
                d = "left"
            else:
                d = "right"
            if 2*i+1 >= n :
                command_from_right = "dne"
                command_from_left  = "dne"
                data_from_right = "{ data_size{1'b0} }"
                data_from_left  = "{ data_size{1'b0} }"
            else :
                command_from_right = f"n{2*i+2}_command_up"
                command_from_left  = f"n{2*i+1}_command_up"
                data_from_right = f"n{2*i+2}_data_up"
                data_from_left  = f"n{2*i+1}_data_up"
            print(f"""
                node #("n{i}") n{i}(  
                ///////// input //////////////
                 .clk(clk),
                 .data_from_top(n{parent}_data_{d}),
                 .data_from_right({data_from_right}),
                 .data_from_left ({data_from_left}),
                 .command_from_top(n{parent}_command_{d}),
                 .command_from_right({command_from_right}),
                 .command_from_left ({command_from_left}),

                 ///////// output //////////////
                 .data_to_top     (n{i}_data_up),
                 .data_to_right   (n{i}_data_right),
                 .data_to_left    (n{i}_data_left),
                 .command_to_top  (n{i}_command_up),
                 .command_to_right(n{i}_command_right),
                 .command_to_left (n{i}_command_left)
                 );     
                """)


nop= 5'h00,
rst = 5'h1f,
rst_done = 5'h1e,
center_fill = 5'h01,
configure_sort_axis= 5'h02,
receive_center = 5'h03,
switch_with_left= 5'h04,
center_fill_done= 5'h05,
configure_sort_axis_done = 5'h07,
busy= 5'h08, 
dne = 5'h10,
start_sorting = 5'h09,
ready_to_sort = 5'h0a,
switch        = 5'h0b,
sort_left_validate   = 5'h0c,
sort_right_validate= 5'h0d,
valid_sort   = 5'h0f,
expose_center= 5'h12,
valid_done   = 5'h11,
next_sort_level  = 5'h13,
start_sorting_as_root= 5'h14,
sort_done = 5'h15,
point_in_as_root= 5'h16,
point_in_with_best= 5'h17,
return_best = 5'h18,
hold= 5'h19,
get_most_left = 5'h1a,
get_most_right= 5'h1b,
set_most_left = 5'h1c,
set_most_right= 5'h1d;
