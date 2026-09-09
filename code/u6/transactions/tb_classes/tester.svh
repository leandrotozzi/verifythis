class tester extends uvm_component;
   `uvm_component_utils(tester)

   uvm_put_port #(command_transaction) command_port;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   // cb: the-loop
   task run_phase(uvm_phase phase);
      command_transaction command;

      phase.raise_objection(this);

      // ALL transactions come out of the factory, the directed ones too.
      // A new() here would compile and work just the same, but it would skip
      // add_test's set_type_override: the factory never hears about what you
      // build by hand. See the slide "the new() that eats the override".
      command = command_transaction::type_id::create("command");
      command.op = rst_op;
      command_port.put(command);

      repeat (1000) begin : random_loop
         command = command_transaction::type_id::create("command");
         // randomize() returns 0 if the constraints have no solution, and aborts
         // nothing. A bare assert() lets an unrandomized transaction through in
         // silence: the TB carries on, sending garbage.
         if (!command.randomize()) `uvm_fatal("TESTER", "randomize() failed")
         command_port.put(command);
      end : random_loop
   // cb: end

      // Directed: the multiplier overflow case, which 1000 random operations
      // might never touch. It comes out of the factory like the others, but
      // since it is not randomized, add_transaction's constraint does not run:
      // the factory picks the TYPE, constraints only act inside randomize().
      command = command_transaction::type_id::create("command");
      command.op = mul_op;
      command.A = 8'hFF;
      command.B = 8'hFF;
      command_port.put(command);

      #500;
      phase.drop_objection(this);
   endtask : run_phase
endclass : tester
