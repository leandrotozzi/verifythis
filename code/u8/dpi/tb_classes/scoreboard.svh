class scoreboard extends uvm_subscriber #(result_transaction);
   `uvm_component_utils(scoreboard);

   uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      cmd_f = new("cmd_f", this);
   endfunction : build_phase

   // The ONLY difference with the sequences scoreboard, and it is the whole
   // section: there is no case with the arithmetic of the spec here. The
   // prediction is asked of the C reference model, the one that signed it.
   //
   // What does not change: the monitor, the analysis port, the FIFO, the
   // do_compare and the uvm_error. The golden model replaces SIX LINES -- the
   // ones that predict -- and no other piece of the testbench finds out.
   function result_transaction predict_result(command_transaction cmd);
      result_transaction predicted;
      int                ovf;

      predicted = result_transaction::type_id::create("predicted");

      predicted.result = vtalu_golden(int'(cmd.op), int'(cmd.A), int'(cmd.B), ovf);
      predicted.ovf    = (ovf != 0);

      return predicted;

   endfunction : predict_result

   function void write(result_transaction t);
      string data_str;
      command_transaction cmd;
      result_transaction predicted;

      do
      if (!cmd_f.try_get(cmd))
         `uvm_fatal("SELF CHECKER", "Missing command in self checker")
      while ((cmd.op == no_op) || (cmd.op == rst_op));

      predicted = predict_result(cmd);

      data_str = {
         cmd.convert2string(),
         " ==>  Actual ",
         t.convert2string(),
         "/Predicted ",
         predicted.convert2string()
      };

      if (!predicted.compare(t)) `uvm_error("SELF CHECKER", {"FAIL: ", data_str})
      else `uvm_info("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

   endfunction : write
endclass : scoreboard
