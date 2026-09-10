// Memory Management: creating an object and passing it around the TB means
//                    allocating memory and sharing it between threads
//                    The simulator treats a class differently from a struct
//                    It allocates the memory of a struct as soon as it sees it,
//                    while for classes that has to be done with new()
// cb: rectangle-and-square
class rectangle;
   // Data members
   int length;
   int width;

   function new(int l, int w);
      length = l;
      width = w;
   endfunction

   function int area();
      return length * width;
   endfunction
endclass

// Extending classes!
class square extends rectangle;
   // Override Constructor
   function new(int side);
      // super: the call to the parent method
      super.new(.l(side), .w(side));
   endfunction

endclass
// cb: end

module top_class;
   //Handle: like a pointer, but arithmetic on it is not allowed
   rectangle rectangle_h;
   square    square_h;

   initial begin

      rectangle_h = new(.l(50), .w(20));
      $display("rectangle area: %0d", rectangle_h.area());

      square_h = new(.side(50));
      $display("square area: %0d", square_h.area());

      // Since a square is a particular case of a rectangle:
      // can rectangle_h point to a square? Yes, polymorphism

   end
endmodule
