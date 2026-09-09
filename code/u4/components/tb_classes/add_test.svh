// add_test extends random_test, redeclares tester_h with another type and
// REWRITES the whole build_phase. That duplication is the problem the env section solves
// with the factory override.

class add_test extends random_test;
   `uvm_component_utils(add_test);

   add_tester tester_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      tester_h = new("tester_h", this);
      coverage_h = new("coverage_h", this);
      scoreboard_h = new("scoreboard_h", this);
   endfunction

endclass
