   function void do_copy(uvm_object rhs);
      command_transaction copied_transaction_h;

      // Chequeos que facilitan el DEBUG
      if(rhs == null) 
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

      if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")
      
      super.do_copy(rhs); // copy all parent class data

      A = copied_transaction_h.A;
      B = copied_transaction_h.B;
      op = copied_transaction_h.op;

   endfunction : do_copy