class add_tester extends random_tester;
   `uvm_component_utils(add_tester)

   function operation_t get_op();
      bit [2:0] op_choice;
      return add_op;
   endfunction : get_op
         
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : add_tester






