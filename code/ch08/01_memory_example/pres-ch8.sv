module RAM #(awidth, dwidth) (
			       input wire [awidth-1:0] address, 
			       inout wire [dwidth-1:0] data,
			       input we);

   initial $display("awidth: %0d  dwidth %0d",awidth, dwidth);
   // code to implement RAM

   //...

endmodule // RAM

module top;
   wire [ 7:0] address;
   wire [15:0] data;
   wire        write_enable;
   RAM #(.awidth(8), .dwidth(16)) my_ram(address, data, write_enable);
endmodule // top