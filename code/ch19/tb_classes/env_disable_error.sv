   function void end_of_elaboration_phase(uvm_phase phase);
 
     scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);
 
   endfunction : end_of_elaboration_phase