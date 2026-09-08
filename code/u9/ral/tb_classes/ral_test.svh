// What the register layer buys, in ten lines of stimulus: not one PADDR, not one
// PWDATA, not one wait state. The same driver as the capstone is doing all of
// that underneath.
class ral_test extends ral_base_test;
   `uvm_component_utils(ral_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      uvm_status_e   status;
      uvm_reg_data_t data;

      phase.raise_objection(this);
      reset_model();

      // --- the frontdoor -----------------------------------------------------
      // write() puts the value on the wire through the sequencer. There is no
      // second argument for the address: the address is in the map.
      model.CTRL.write(status, 'h1);              // EN = 1
      model.CTRL.read(status, data);
      `uvm_info("RAL", $sformatf("CTRL read back 0x%08h (status %s)", data, status.name()),
                UVM_MEDIUM)

      // --- prediction --------------------------------------------------------
      // Nothing above updated the mirror by hand. The monitor saw the two
      // transfers, the predictor turned them into predictions, and the model
      // knows -- with set_auto_predict(0), which is the honest setting: what the
      // model believes comes from the BUS, not from what the test meant to send.
      if (model.CTRL.EN.get_mirrored_value() != 1)
         `uvm_error("RAL", "the predictor did not update CTRL.EN")
      `uvm_info("RAL", $sformatf("mirrored CTRL.EN = %0d, and nobody assigned it",
                model.CTRL.EN.get_mirrored_value()), UVM_MEDIUM)

      // --- mirror(UVM_CHECK): the read that checks itself --------------------
      model.SCRATCH.write(status, 'h1000_0000);
      model.SCRATCH.mirror(status, UVM_CHECK);

      // --- and the part RAL does not do --------------------------------------
      // ACC changed because of the write to SCRATCH, at another address. The
      // model never predicted that and never will: mirror(UVM_CHECK) is off on
      // ACC (see the reg block). The read still updates the mirror, so after
      // this line the model agrees with the DUT again.
      model.ACC.read(status, data);
      `uvm_info("RAL", $sformatf("ACC = 0x%08h -- predicted by the SCOREBOARD, not by the model",
                data), UVM_MEDIUM)
      if (data != 'h1000_0000)
         `uvm_error("RAL", $sformatf("ACC read 0x%08h, expected 0x10000000", data))

      // CLR is "WOC": the write clears the accumulator and the bit reads 0. A
      // mirror(UVM_CHECK) right after would pass -- which is the point of
      // getting the access policy right.
      model.CTRL.write(status, 'h3);             // EN = 1, CLR = 1
      model.CTRL.mirror(status, UVM_CHECK);
      model.ACC.read(status, data);
      if (data != 0) `uvm_error("RAL", $sformatf("after CLR, ACC = 0x%08h", data))

      // STATUS.EN is a copy of CTRL.EN, and it got there through a transfer to a
      // DIFFERENT address. Without the set_compare(UVM_NO_CHECK) of the reg
      // block this line fails -- and the failure would be the model's fault, not
      // the DUT's. Knowing which of the two is lying is the whole skill.
      //
      // The two UVM_WARNING it prints (UVM/FLD/GET_MIRRORED_VAL/VOL) are the
      // library saying the same thing on its own: a volatile field's mirror is
      // not evidence. They are the expected output of this line, not noise.
      `uvm_info("RAL", "the two VOL warnings below are the point, not a problem",
                UVM_MEDIUM)
      model.STATUS.mirror(status, UVM_CHECK);

      // --- the status that only a bus can give -------------------------------
      // Every call returns a status, and it is not decoration: PSLVERR comes back
      // through bus2reg as UVM_NOT_OK. A pure software model could not tell you
      // that the slave refused the access -- it is the one thing in this file
      // that could only come from the wire.
      if (status != UVM_IS_OK)
         `uvm_error("RAL", $sformatf("the mapped accesses came back %s", status.name()))

      phase.drop_objection(this);
   endtask : run_phase

endclass : ral_test
