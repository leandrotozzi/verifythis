// The random sequence: N random cycles, with the transaction dist
// biased to write more than it reads. Without that bias the FIFO never fills
// and the two expensive rows of the plan stay at zero.
class random_sequence extends uvm_sequence #(fifo_transaction);
   `uvm_object_utils(random_sequence)

   rand int unsigned ciclos;
   constraint c_ciclos {ciclos inside {[400 : 600]};}

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      fifo_transaction t;
      repeat (ciclos) begin
         t = fifo_transaction::type_id::create("t");
         start_item(t);
         if (!t.randomize()) `uvm_fatal("SEQ", "randomize() failed: is z3 missing?")
         finish_item(t);
      end
      // And at the end, drain it: that way the check_phase check makes sense and
      // the bottom edge gets touched even if chance did not want to.
      repeat (12) begin
         t = fifo_transaction::type_id::create("t");
         start_item(t);
         t.wr_en = 1'b0;
         t.rd_en = 1'b1;
         finish_item(t);
      end
   endtask : body

endclass : random_sequence
