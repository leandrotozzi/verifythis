class result_transaction extends uvm_sequence_item;
   // Registered in the factory, same as command_transaction: without this
   // there is no type_id::create() and no override is possible.
   `uvm_object_utils(result_transaction)

   shortint result;

   // VTALU rev2: the borrow of the subtraction. It is the half of the result the
   // scoreboard in the book never had to check.
   bit      ovf;

   function new(string name = "");
      super.new(name);
   endfunction : new

   function void do_copy(uvm_object rhs);
      result_transaction copied_transaction_h;

      if (rhs == null)
         `uvm_fatal("RESULT TRANSACTION", "Tried to copy from a null pointer")

      if (!$cast(copied_transaction_h, rhs))
         `uvm_fatal("RESULT TRANSACTION", "Tried to copy wrong type.")

      super.do_copy(rhs);  // copy all parent class data

      result = copied_transaction_h.result;
      ovf    = copied_transaction_h.ovf;
   endfunction : do_copy

   function string convert2string();
      string s;
      s = $sformatf("result: %4h ovf: %0b", result, ovf);
      return s;
   endfunction : convert2string

   function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      result_transaction compared_transaction_h;
      bit same;

      if (rhs == null)
         `uvm_fatal("RESULT TRANSACTION", "Tried to do comparison to a null pointer")

      // A $cast that fails is NOT a fatal: comparing against another type is a
      // legitimate answer -- "they are not equal". The fatal is for the null,
      // which IS a testbench bug.
      if (!$cast(compared_transaction_h, rhs)) same = 0;
      else same = super.do_compare(rhs, comparer) && (compared_transaction_h.result == result)
          && (compared_transaction_h.ovf == ovf);

      return same;
   endfunction : do_compare

endclass : result_transaction
