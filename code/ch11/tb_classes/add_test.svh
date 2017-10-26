class add_test extends uvm_test;
   `uvm_component_utils(add_test);

   virtual tinyalu_bfm bfm;
   
   function new (string name, uvm_component parent);
      super.new(name,parent);
      if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
        $fatal("Failed to get BFM");
   endfunction : new
   
   task run_phase(uvm_phase phase);
      add_tester add_tester_h;
      coverage   coverage_h;
      scoreboard scoreboard_h;

      phase.raise_objection(this);

      add_tester_h = new(bfm);
      coverage_h   = new(bfm);
      scoreboard_h = new(bfm);
      
      fork
         coverage_h.execute();
         scoreboard_h.execute();
      join_none

      add_tester_h.execute();
      phase.drop_objection(this);
   endtask : run_phase

endclass