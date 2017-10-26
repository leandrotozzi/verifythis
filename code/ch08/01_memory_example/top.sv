module top;
   wire [ 7:0] address;
   wire [15:0] data;
   wire        write_enable;
   RAM #(.awidth(8), .dwidth(16)) my_ram(address, data, write_enable);
endmodule // top
