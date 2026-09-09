class random_sequence extends uvm_sequence #(apb_transaction);
   `uvm_object_utils(random_sequence)

   int unsigned count = 400;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      apb_transaction t;
      for (int i = 0; i < count; i++) begin : loop
         t = apb_transaction::type_id::create("t");
         start_item(t);
         // The last one is never chained: with b2b = 1 the driver leaves PSEL
         // high waiting for an item that is not coming, and the DUT keeps seeing
         // the same transfer.
         if (!t.randomize()) `uvm_fatal("RANDOM SEQUENCE", "randomize() failed")
         if (i == count - 1) t.b2b = 1'b0;
         finish_item(t);
      end : loop
   endtask : body

endclass : random_sequence
