`timescale 1ns/1ns

module main_tb;

reg reset, clk;
 
reg [23:0] Sin;
localparam data_size = 10000;
reg [23:0] in_im [data_size-1:0] ;
reg [2:0] tb_state;
localparam configuration = 3'b000, loading_image = 3'b001, compute = 3'b010, done = 3'b011, idle = 3'b100;

kmean #(data_size) c_m(clk, reset, Sin,strb);
reg [$clog2(data_size)-1 : 0] count;

reg [$clog2(data_size)-1 : 0] image_size;
reg [3:0] K;
integer f;
initial begin
        $display("Loading image.\n");
        $readmemh("C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequential_manhattan/test.hex", in_im);
		  //f = $fopen("output.rgb", "wb");
    end
  
initial begin	//the reset sequence and clock
	clk = 0;reset = 0 ; count=0; tb_state = idle; image_size = data_size; K = 16;
	#5 reset = 1 ;clk=1; #5 reset = 0; clk=0;
	repeat(429496720) #5 clk = ~clk ;
	  end

always @ (negedge clk)	begin 	// Read input pixels from in_im
	if(reset) 
		tb_state <= idle;
	else
	case (tb_state)
	   idle: tb_state<= configuration;
		configuration: begin
			Sin <= {{8{1'b0}},K,image_size};
			tb_state <= loading_image;
		end
		loading_image: begin
			if (count == image_size)
				tb_state <= compute;
			else begin
				Sin <= in_im [count];
				count <= count + 1;
			end
		end
		compute:
			if (strb) begin
				tb_state <= done;
				count <= 0;
				end
		done: begin
			$display("Simulation ENDS HERE ################################");
			$finish;
			end
		
		endcase
end

endmodule