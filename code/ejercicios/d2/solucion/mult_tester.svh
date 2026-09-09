// The whole class is eight lines: that is what inheritance buys. The rest of
// the tester —the protocol, the loop, the displays— is untouched.
class mult_tester extends tester;

   function new(virtual vtalu_bfm b);
      super.new(b);
   endfunction : new

   protected function operation_t get_op();
      return mul_op;
   endfunction : get_op

endclass : mult_tester
