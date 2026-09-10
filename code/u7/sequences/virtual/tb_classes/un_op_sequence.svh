// One directed operation, with the three fields outside and the result coming
// back. It is the section's maxmult_sequence, parameterized: it is needed for the
// third step of the virtual sequence, where the operand of one VTALU comes from
// the result of the other.
class un_op_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(un_op_sequence)

   byte unsigned     A, B;
   operation_t       op;
   shortint unsigned result;  // the driver writes it inside the item

   function new(string name = "un_op_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.A  = A;
      command.B  = B;
      command.op = op;
      finish_item(command);
      // finish_item() returns after the driver's item_done(), so result is
      // already written. It is the way back the sequences added.
      result = command.result;
   endtask : body

endclass : un_op_sequence
