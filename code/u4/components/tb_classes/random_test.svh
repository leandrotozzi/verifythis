class random_test extends uvm_test;
   `uvm_component_utils(random_test);

   random_tester tester_h;
   coverage      coverage_h;
   scoreboard    scoreboard_h;

   // Components get instantiated in build_phase, never in the constructor.
   function void build_phase(uvm_phase phase);
      tester_h = new("tester_h", this);
      coverage_h = new("coverage_h", this);
      scoreboard_h = new("scoreboard_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // No run_phase: the test's job ends once the tree is built.

endclass
