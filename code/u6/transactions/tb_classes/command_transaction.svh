// cb: fields-and-constraints
class command_transaction extends uvm_sequence_item;
   `uvm_object_utils(command_transaction)
   rand byte unsigned A;
   rand byte unsigned B;
   rand operation_t   op;

   // :/ and NOT :=  ---  this is the line that reproduces the bias towards the
   // corner cases that get_data() of the Functional coverage section did by hand (1/4 at 00, 1/4 at FF,
   // 1/2 in the middle). With ":=" the weight applies to EVERY value of the range, so the
   // middle takes 254 out of 256 and 00 comes up once every 256: the distribution
   // ends up almost uniform and the corner bins never fill.
   // The Constrained Random unit has the experiment with the numbers.
   constraint data {
      A dist {
         8'h00 :/ 1,
         [8'h01 : 8'hFE] :/ 2,
         8'hFF :/ 1
      };
      B dist {
         8'h00 :/ 1,
         [8'h01 : 8'hFE] :/ 2,
         8'hFF :/ 1
      };
   }
// cb: end

   function void do_copy(uvm_object rhs);
      command_transaction copied_transaction_h;

      // Checks that make DEBUG easier
      if (rhs == null)
         `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

      if (!$cast(copied_transaction_h, rhs))
         `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

      super.do_copy(rhs);  // copy all parent class data

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
      bit same;

      if (rhs == null)
         `uvm_fatal("RANDOM TRANSACTION", "Tried to do comparison to a null pointer");

      // First check whether we are comparing the same type
      if (!$cast(compared_transaction_h, rhs)) same = 0;
      else
         // Deep comparison: what the parent compares, plus the three fields of
         // this class
         same = super.do_compare(
             rhs, comparer
         ) && (compared_transaction_h.A == A) && (compared_transaction_h.B == B) &&
             (compared_transaction_h.op == op);

      return same;
   endfunction : do_compare

   function string convert2string();
      string s;
      // op.name() can be add_op, no_op ...
      s = $sformatf("A: %2h  B: %2h op: %s", A, B, op.name());
      return s;
   endfunction : convert2string

   // Constructor of a uvm_object: dead simple, it only takes a name. A
   // transaction has no parent because it does not live in the component tree.
   function new(string name = "");
      super.new(name);
   endfunction : new

endclass : command_transaction
