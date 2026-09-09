// The env of the "The whole env" section, with one component added: the exercise
// checker. Do not touch it.
class env extends uvm_env;
   `uvm_component_utils(env);

   base_tester tester_h;
   coverage    coverage_h;
   scoreboard  scoreboard_h;

   // The exercise checker. Do not touch it.
   chequeo     chequeo_h;

   function void build_phase(uvm_phase phase);
      tester_h = base_tester::type_id::create("tester_h", this);
      coverage_h = coverage::type_id::create("coverage_h", this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
      chequeo_h = chequeo::type_id::create("chequeo_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass
