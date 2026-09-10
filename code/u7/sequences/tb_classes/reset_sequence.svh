// The smallest sequence there is: a single item.
//
// It is a uvm_object, not a uvm_component: it is not in the tree, it has no
// parent, it has no phases. It gets created, it runs, and it gets thrown away.
class reset_sequence extends uvm_sequence #(command_transaction);
   // `uvm_object_utils, NOT `uvm_component_utils: the constructor takes a single
   // argument and there is no parent to pass.
   `uvm_object_utils(reset_sequence)

   function new(string name = "reset_sequence");
      super.new(name);
   endfunction : new

   // body() is a TASK, not a function: it blocks inside. Nobody calls it by
   // hand; UVM calls it when somebody starts the sequence.
   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");
      start_item(command);    // blocks until the sequencer gives us our turn
      command.op = rst_op;    // only now do we decide what to send
      finish_item(command);   // blocks until the driver calls item_done()
   endtask : body

endclass : reset_sequence
