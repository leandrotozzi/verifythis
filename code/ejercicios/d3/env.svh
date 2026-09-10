// This class defines the structure of the TB
// It instantiates the objects in the TB
class env extends uvm_env;
   `uvm_component_utils(env);

   base_tester tester_h;
   coverage    coverage_h;
   scoreboard  scoreboard_h;
   chequeo     chequeo_h;  // the exercise adds it; you do not need to touch this one

   function void build_phase(uvm_phase phase);
      // tester_h creates an object of the base_tester class
      // We know base_tester is a virtual class, so
      // a base_tester object cannot be created: what has to be created is a
      // class derived from base_tester. So why does this code work?
      // The env class is using the base_tester variable as a placeholder
      tester_h = base_tester::type_id::create("tester_h", this);
      coverage_h = coverage::type_id::create("coverage_h", this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
      chequeo_h = chequeo::type_id::create("chequeo_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass
