module  mb #(parameter wel= 24, size = 10000)( input clk,we,input [0:wel - 1]din,input [0:$clog2(size) - 1]address,output  reg [0:wel - 1] dout);

   reg [0:wel - 1] mem [0:size - 1];
    always @(posedge clk) begin
        if (we)
            mem[address] <= din;
        dout <= mem[address];
   end
endmodule