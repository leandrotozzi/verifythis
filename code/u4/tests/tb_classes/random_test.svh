// The first UVM test of the course. The five steps this class puts together
// --registration, constructor, build_phase, run_phase and objections-- are
// explained one by one in the slides of unit 11.
class random_test extends uvm_test;
   `uvm_component_utils(random_test);

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // The get goes in build_phase and not in the constructor: when the
   // constructor runs, the tree does not exist yet.
   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("RANDOM TEST", "Failed to get BFM")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      random_tester random_tester_h;
      coverage      coverage_h;
      scoreboard    scoreboard_h;

      phase.raise_objection(this);

      random_tester_h = new(bfm);
      coverage_h = new(bfm);
      scoreboard_h = new(bfm);

      fork
         coverage_h.execute();
         scoreboard_h.execute();
      join_none

      random_tester_h.execute();

      phase.drop_objection(this);
   endtask : run_phase

endclass
