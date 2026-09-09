class mult_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(mult_sequence)

   int unsigned      count = 20;   // cuantas multiplicaciones mandar
   int unsigned      items = 0;    // cuantas mando de verdad
   shortint unsigned max = 0;      // el resultado mas grande que vio

   function new(string name = "mult_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;

      // The reset first. Without it the DUT never raises done, the driver stays in
      // its while and this sequence hangs on the first finish_item().
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = rst_op;
      finish_item(command);

      repeat (count) begin : mult_loop
         command = command_transaction::type_id::create("command");
         start_item(command);
         // Late randomization. op has no dist, so the with {} works; if you
         // restricted A or B you would first have to turn the data constraint off
         // with command.data.constraint_mode(0).
         if (!command.randomize() with {op == mul_op;})
            `uvm_fatal("MULT SEQ", "randomize() failed")
         finish_item(command);

         // finish_item() returned: the driver already wrote the result inside.
         items++;
         if (command.result > max) max = command.result;
      end : mult_loop

      `uvm_info("MULT SEQ", $sformatf("items=%0d max=%0d", items, max), UVM_NONE)
   endtask : body

endclass : mult_sequence
