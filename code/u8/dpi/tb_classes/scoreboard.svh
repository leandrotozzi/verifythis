class scoreboard extends uvm_subscriber #(result_transaction);
   `uvm_component_utils(scoreboard);

   uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      cmd_f = new("cmd_f", this);
   endfunction : build_phase

   // La UNICA diferencia con el scoreboard de las sequences, y es la seccion
   // entera: aca no hay un case con la aritmetica de la spec. La prediccion se
   // le pide al modelo de referencia en C, que es el que la firmo.
   //
   // Lo que no cambia: el monitor, el analysis port, la FIFO, el do_compare y
   // el uvm_error. El golden model reemplaza SEIS LINEAS -- las de predecir --
   // y ninguna otra pieza del testbench se entera.
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
