function void end_of_elaboration_phase(uvm_phase phase);

   scoreboard_h.set_report_severity_action_hier(UVM_ERROR, UVM_NO_ACTION);

endfunction : end_of_elaboration_phase
