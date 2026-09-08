function void build_phase(uvm_phase phase);
   // base_tester es abstracta: no se puede instanciar con new(). A la factory
   // se le pide igual, porque el que va a llegar es el tipo con el que el test
   // hizo el set_type_override -- add_tester o random_tester, nunca esta.
   tester_h = base_tester::type_id::create("tester_h", this);
   coverage_h = coverage::type_id::create("coverage_h", this);
   scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
endfunction : build_phase
