class random_sequence extends uvm_sequence #(apb_transaction);
   `uvm_object_utils(random_sequence)

   int unsigned count = 400;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      apb_transaction t;
      repeat (count) begin : loop
         t = apb_transaction::type_id::create("t");
         start_item(t);
         if (!t.randomize()) `uvm_fatal("RANDOM SEQUENCE", "randomize() failed")
         finish_item(t);
      end : loop
   endtask : body

endclass : random_sequence
