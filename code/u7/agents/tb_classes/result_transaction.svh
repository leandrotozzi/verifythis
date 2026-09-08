class result_transaction extends uvm_sequence_item;
   // Registrada en la factory, igual que command_transaction: sin esto
   // no hay type_id::create() ni override posible.
   `uvm_object_utils(result_transaction)

   shortint result;

   // rev2 del VTALU: el borrow de la resta. Es la mitad del resultado que el
   // scoreboard del libro no tenia que chequear.
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

      // Un $cast que falla NO es un fatal: comparar contra otro tipo es una
      // respuesta legitima -- "no son iguales". El fatal es para el null, que
      // si es un error del testbench.
      if (!$cast(compared_transaction_h, rhs)) same = 0;
      else same = super.do_compare(rhs, comparer) && (compared_transaction_h.result == result)
          && (compared_transaction_h.ovf == ovf);

      return same;
   endfunction : do_compare

endclass : result_transaction
