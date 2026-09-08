// La clase entera son ocho lineas: eso es lo que compra la herencia. El resto
// del tester —el protocolo, el loop, los displays— no se toca.
class mult_tester extends tester;

   function new(virtual vtalu_bfm b);
      super.new(b);
   endfunction : new

   protected function operation_t get_op();
      return mul_op;
   endfunction : get_op

endclass : mult_tester
