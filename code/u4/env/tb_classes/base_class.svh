function void build_phase(uvm_phase phase);
   // base_tester is abstract: it cannot be instantiated with new(). The factory
   // is asked for it anyway, because what will arrive is the type the test set
   // with set_type_override -- add_tester or random_tester, never this one.
   tester_h = base_tester::type_id::create("tester_h", this);
   coverage_h = coverage::type_id::create("coverage_h", this);
   scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
endfunction : build_phase
