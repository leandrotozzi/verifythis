// Day 5 exercise -- close a bin.
//
// The missing bin is the one in the coverage plan of the Functional coverage section:
// "both legs at FF, multiplying". It is called mul_max in coverage.svh, and with
// 60 random operations it does not fill: the report run.sh prints shows you that.
//
// What is asked: send ONE transaction with A = 8'hFF, B = 8'hFF and op = mul_op,
// asked for with randomize() with {} -- not by assigning the three fields by hand.
// The directed case is asked for at the point of use; that is the tool from the
// Constrained random section.
//
// Two warnings that are in the slides and that you are going to need:
//
//   1. command_transaction has a `dist` on A and on B. Verilator solves
//      the dist by PICKING A VALUE first and then checking the rest: if the
//      draw does not satisfy your with, randomize() returns 0 instead of retrying.
//      The workaround is in the Constrained random section and it is one line.
//   2. randomize() gets checked with if, never with assert().
class tester extends uvm_component;
   `uvm_component_utils(tester)

   uvm_put_port #(command_transaction) command_port;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_transaction command;
      int                 count = 60;

      void'($value$plusargs("COUNT=%d", count));

      phase.raise_objection(this);

      // The DUT starts with reset_n at 0: the first item of every test is a reset.
      command = command_transaction::type_id::create("command");
      command.op = rst_op;
      command_port.put(command);

      // The cheap bulk: count random operations. This part is written.
      repeat (count) begin : random_loop
         command = command_transaction::type_id::create("command");
         if (!command.randomize()) `uvm_fatal("TESTER", "randomize() failed")
         command_port.put(command);
      end : random_loop

      // +SIN_CIERRE skips the directed case. It is how run.sh measures the
      // coverage BEFORE yours, so it can compare it with the one after.
      if (!$test$plusargs("SIN_CIERRE")) begin : el_cierre
         command = command_transaction::type_id::create("command");

         // <<< HERE >>>  randomize() with { ... }, and whatever is needed before it.

         command_port.put(command);
         `uvm_info("CIERRE", $sformatf("A=%2h B=%2h op=%s",
                   command.A, command.B, command.op.name()), UVM_NONE)
      end : el_cierre

      #500;
      phase.drop_objection(this);
   endtask : run_phase
endclass : tester
