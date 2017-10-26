class rectangle;
    int length;
    int width;
    
    function new(int l, int w);
      length = l;
      width  = w;
    endfunction
    
    function int area;
      return length * width;
    endfunction
  endclass : rectangle

  
  module top_rectangle ;

    rectangle rectangle_h;

    initial begin

      rectangle_h = new(.l(50),.w(20));

      $display("rectangle area: %0d", rectangle_h.area());

    end
endmodule : top_rectangle

