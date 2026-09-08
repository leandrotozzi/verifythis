// La estructura del TB, y nada mas: instancia los componentes y los conecta.
// Que tester llega lo decide el test con un override de la factory. Unidad 13.
class env extends uvm_env;
   `uvm_component_utils(env);

   base_tester tester_h;
   coverage    coverage_h;
   scoreboard  scoreboard_h;

   function void build_phase(uvm_phase phase);
      // base_tester es abstracta y esto igual anda: create() no la construye,
      // le pregunta a la factory que dar cuando alguien pide un base_tester.
      tester_h = base_tester::type_id::create("tester_h", this);
      coverage_h = coverage::type_id::create("coverage_h", this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass
