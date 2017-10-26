class command_transaction extends uvm_transaction;
   `uvm_object_utils(command_transaction)
   rand byte unsigned        A;
   rand byte unsigned        B;
   rand operation_t         op;

   constraint data { A dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
                     B dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};} 
   
   

   function void do_copy(uvm_object rhs);
      command_transaction copied_transaction_h;

      if(rhs == null) 
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

      if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")
      
      super.do_copy(rhs); // copy all parent class data

      A = copied_transaction_h.A;
      B = copied_transaction_h.B;
      op = copied_transaction_h.op;

   endfunction : do_copy

   function command_transaction clone_me();
      command_transaction clone;
      uvm_object tmp;

      tmp = this.clone();
      $cast(clone, tmp);
      return clone;
   endfunction : clone_me
   

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      command_transaction compared_transaction_h;
      bit   same;
      
      if (rhs==null) `uvm_fatal("RANDOM TRANSACTION", 
                                "Tried to do comparison to a null pointer");
      
      if (!$cast(compared_transaction_h,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (compared_transaction_h.A == A) &&
               (compared_transaction_h.B == B) &&
               (compared_transaction_h.op == op);
               
      return same;
   endfunction : do_compare


   function string convert2string();
      string s;
      s = $sformatf("A: %2h  B: %2h op: %s",
                        A, B, op.name());
      return s;
   endfunction : convert2string

   function new (string name = "");
      super.new(name);
   endfunction : new

endclass : command_transaction