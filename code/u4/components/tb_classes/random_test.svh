class random_test extends uvm_test;
   `uvm_component_utils(random_test);

   random_tester tester_h;
   coverage      coverage_h;
   scoreboard    scoreboard_h;

   // Los componentes se instancian en build_phase, nunca en el constructor.
   function void build_phase(uvm_phase phase);
      tester_h = new("tester_h", this);
      coverage_h = new("coverage_h", this);
      scoreboard_h = new("scoreboard_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // Sin run_phase: el trabajo del test termina cuando el arbol esta armado.

endclass
