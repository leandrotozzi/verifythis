class mult_tester extends random_tester;
   `uvm_component_utils(mult_tester)

   function operation_t get_op();
      return mul_op;
   endfunction : get_op

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : mult_tester
