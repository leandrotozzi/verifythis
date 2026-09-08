// El primer test UVM del curso. Los cinco pasos que arma esta clase --registro,
// constructor, build_phase, run_phase y objections-- estan explicados uno por
// uno en las slides de la unidad 11.
class random_test extends uvm_test;
   `uvm_component_utils(random_test);

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // El get va en build_phase y no en el constructor: cuando corre el
   // constructor el arbol todavia no existe.
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
