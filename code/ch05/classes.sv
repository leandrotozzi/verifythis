// Memory Management: Crear un objeto y pasarlos por el TB, es reservar memoria
//                    y compartirla entre threads
//                    El Simulador trata distinto una clase respecto de una struct
//                    El simulador reserva la memoria de la struct apenas la ve
//                    mientras que en las clases, se debe hacer mediante new()
class rectangle;
    // Data members 
    int length;
    int width;
    
    function new(int l, int w);
      length = l;
      width  = w;
    endfunction
    
    function int area();
      return length * width;
    endfunction
endclass

// Extendiendo Clases!  
class square extends rectangle;
    // Override Constructor
    function new(int side);
      //super: llamado a metodo de padre
      super.new(.l(side), .w(side));
    endfunction
  
endclass
  
module top_class ;
    //Handler: similar a un puntero, pero no permite operaciones arimeticas 
    rectangle rectangle_h;
    square    square_h;
    
    initial begin
    
      rectangle_h = new(.l(50),.w(20));
      $display("rectangle area: %0d", rectangle_h.area());
      
      square_h = new(.side(50));
      $display("square area: %0d", square_h.area());

      // Ya que un cuadrado es un caso particular de un rectangulo:
      // rectangle_h puede apuntar a un square? Si, polimorfismo
      
    end
endmodule