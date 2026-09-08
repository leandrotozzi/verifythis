// The model printed and nothing else: no bus, no stimulus. It is the first thing
// to run against a register model you just wrote, and the exercise grades stage
// one with it -- a wrong offset or a wrong access string shows up here, before
// any simulation semantics get involved.
//
//   bash run.sh    ->  ral_test / builtin_test
//   +UVM_TESTNAME=mapa_test   ->  the table, and back to the prompt
class mapa_test extends ral_base_test;
   `uvm_component_utils(mapa_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      print_map();
   endtask : run_phase

endclass : mapa_test
