module RAM #(awidth, dwidth) (
			       input wire [awidth-1:0] address, 
			       inout wire [dwidth-1:0] data,
			       input we);

   initial $display("awidth: %0d  dwidth %0d",awidth, dwidth);
   // code to implement RAM
endmodule // RAM

   
   