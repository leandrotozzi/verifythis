// Un subscriber mas colgado del mismo analysis port. El command_monitor no se
// entera de que existe: eso es el observer pattern.
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
      `uvm_info("OP_COUNTER", $sformatf("comandos=%0d multiplicaciones=%0d", total, muls),
                UVM_NONE)
   endfunction : report_phase

endclass : op_counter
