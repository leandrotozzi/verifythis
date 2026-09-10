class add_tester extends random_tester;

   function new(virtual vtalu_bfm b);
      super.new(b);
   endfunction : new

   function operation_t get_op();
      return add_op;
   endfunction : get_op

endclass : add_tester

