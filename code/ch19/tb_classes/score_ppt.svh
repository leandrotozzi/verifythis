      data_str = $sformatf(" %2h %0s %2h = %4h (%4h predicted)",
                           cmd.A, cmd.op.name() ,cmd.B, t,  predicted_result);

      if (predicted_result != t) 
        `uvm_error ("SCOREBOARD", {"FAIL: ",data_str})
      else
        `uvm_info ( "SCOREBOARD", {"PASS: ",data_str}, UVM_HIGH)