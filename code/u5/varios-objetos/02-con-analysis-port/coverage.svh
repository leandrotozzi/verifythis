// uvm_subscriber:
//    extends the uvm_component class and lets you hook onto an analysis port
//    It is a parameterizable class!
//    The class gives you something and asks for something in return
//       * It gives you an object called analysis_export
//       * It asks you to write a write() method that handles the data

class coverage extends uvm_subscriber #(int);
   `uvm_component_utils(coverage);
   int the_roll;

   covergroup dice_cg;
      coverpoint the_roll {bins twod6[] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};}
   endgroup

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      dice_cg = new();
   endfunction : new

   function void write(int t);
      the_roll = t;
      dice_cg.sample();
   endfunction : write

   function void report_phase(uvm_phase phase);
      `uvm_info("COVERAGE", $sformatf("COVERAGE: %2.0f%%", dice_cg.get_inst_coverage()),
                UVM_NONE)
   endfunction : report_phase

endclass : coverage
