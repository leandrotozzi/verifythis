// The basic UVM analysis port mechanism lets a uvm_subscriber watch 1 port
// To analyze 2 ports, the simplest way is to instantiate another subscriber
// inside our class that listens to that port
// For that, UVM provides a class called uvm_tlm_analysis_fifo
//	that class gives us an analysis_export and the try_get() method

class scoreboard extends uvm_subscriber #(shortint);
   `uvm_component_utils(scoreboard);

   uvm_tlm_analysis_fifo #(command_s) cmd_f;

   function void build_phase(uvm_phase phase);
      cmd_f = new("cmd_f", this);
   endfunction : build_phase

   // Every time the DUT hands a result to the analysis port, this method
   // gets triggered
   function void write(shortint t);
      shortint  predicted_result;
      command_s cmd;
      cmd.op = no_op;

      // Here is where the prediction happens: look in our FIFO for the command
      // that was sent, skipping the resets and the no_ops with the
      // do....while
      // since whenever there is a result there must be an operation,
      // a result with no operation behind it is an error
      do
      if (!cmd_f.try_get(cmd)) `uvm_fatal("SCOREBOARD", "No command in self checker")
      while ((cmd.op == no_op) || (cmd.op == rst_op));

      case (cmd.op)
         add_op: predicted_result = cmd.A + cmd.B;
         sub_op: predicted_result = cmd.A - cmd.B;
         and_op: predicted_result = cmd.A & cmd.B;
         xor_op: predicted_result = cmd.A ^ cmd.B;
         mul_op: predicted_result = cmd.A * cmd.B;
      endcase  // case (op_set)

      if (predicted_result != t)
         `uvm_error("SCOREBOARD", $sformatf(
                    "FAILED: A: %2h  B: %2h  op: %s actual result: %4h   expected: %4h",
                    cmd.A,
                    cmd.B,
                    cmd.op.name(),
                    t,
                    predicted_result
                    ))
   endfunction : write

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : scoreboard
