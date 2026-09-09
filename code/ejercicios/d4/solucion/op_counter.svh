// One more subscriber hanging off the same analysis port. The command_monitor
// never finds out it exists: that is the observer pattern.
class op_counter extends uvm_subscriber #(command_s);
   `uvm_component_utils(op_counter)

   int total = 0;
   int muls  = 0;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void write(command_s t);
      total++;
      if (t.op == mul_op) muls++;
   endfunction : write

   function void report_phase(uvm_phase phase);
      `uvm_info("OP_COUNTER", $sformatf("commands=%0d multiplications=%0d", total, muls),
                UVM_NONE)
   endfunction : report_phase

endclass : op_counter
