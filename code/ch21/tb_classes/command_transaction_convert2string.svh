   function string convert2string();
      string s;
      // op.name() puede ser add_op, no_op ...
      s = $sformatf("A: %2h  B: %2h op: %s",
                        A, B, op.name());
      return s;
   endfunction : convert2string