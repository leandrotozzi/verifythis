// add_test extiende la clase random_test y realiza un override de tester_h
// Hereda el metodo build_phase de manera tal que solo debemos escribir la 
// conexion de las clases en un solo lugar

class add_test extends random_test;
   `uvm_component_utils(add_test);

   add_tester tester_h;

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      tester_h      = new("tester_h", this);
      coverage_h    = new("coverage_h",    this);
      scoreboard_h  = new("scoreboard_h",    this);
   endfunction

endclass