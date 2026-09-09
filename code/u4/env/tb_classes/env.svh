// The structure of the TB, and nothing else: it instantiates the components and
// connects them. Which tester arrives is the test's call, with a factory override.
class env extends uvm_env;
   `uvm_component_utils(env);

   base_tester tester_h;
   coverage    coverage_h;
   scoreboard  scoreboard_h;

   function void build_phase(uvm_phase phase);
      // base_tester is abstract and this works anyway: create() does not build
      // it, it asks the factory what to hand out when somebody asks for a base_tester.
      tester_h = base_tester::type_id::create("tester_h", this);
      coverage_h = coverage::type_id::create("coverage_h", this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass
