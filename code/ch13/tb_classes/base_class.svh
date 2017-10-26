   function void build_phase(uvm_phase phase);
      // WTF??????
      //base_tester es abstracta.....
      tester_h     = base_tester::type_id::create("tester_h",this);
      coverage_h   = coverage::type_id::create ("coverage_h",this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
   endfunction : build_phase