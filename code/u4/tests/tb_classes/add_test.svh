class add_test extends uvm_test;
   `uvm_component_utils(add_test);

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // Same build_phase as random_test: the virtual interface is read from the
   // config_db, with this and "" as the scope. See random_test.svh.
   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("ADD TEST", "Failed to get BFM")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      add_tester add_tester_h;
      coverage   coverage_h;
      scoreboard scoreboard_h;

      phase.raise_objection(this);

      add_tester_h = new(bfm);
      coverage_h = new(bfm);
      scoreboard_h = new(bfm);

      fork
         coverage_h.execute();
         scoreboard_h.execute();
      join_none

      add_tester_h.execute();
      phase.drop_objection(this);
   endtask : run_phase

endclass
