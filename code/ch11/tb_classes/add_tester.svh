class add_tester extends random_tester;

   function new (virtual tinyalu_bfm b);
      super.new(b);
   endfunction : new

   function operation_t get_op();
      bit [2:0] op_choice;
      return add_op;
   endfunction : get_op

endclass : add_tester






