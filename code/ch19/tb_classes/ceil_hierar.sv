// clase Env 
// seteamos la verbosidad del componente scoreboard y todo lo que contenga en su jerarquia
   function void end_of_elaboration_phase(uvm_phase phase);
     scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);
   endfunction : end_of_elaboration_phase