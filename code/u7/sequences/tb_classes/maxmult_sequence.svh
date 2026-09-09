class maxmult_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(maxmult_sequence)

   function new(string name = "maxmult_sequence");
      super.new(name);
   endfunction : new

   // Directed: the multiplier overflow, which 1000 random operations might never
   // touch. It is not randomized, so no constraint runs -- not even
   // add_transaction's when add_test does the override.
   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = mul_op;
      command.A  = 8'hFF;
      command.B  = 8'hFF;
      finish_item(command);
      // The result is already inside the item: the driver wrote it before
      // item_done(), and finish_item() returned after that.
      `uvm_info("MAXMULT", $sformatf("FF x FF = %4h", command.result), UVM_MEDIUM)
   endtask : body

endclass : maxmult_sequence
