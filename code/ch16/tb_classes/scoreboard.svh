// El mecanismo basico de UVM analysis port permite que un uvm_subscriber vea 1 puerto
// Si necesitamos analizar 2 puertos, la manera mas sencilla es instanciar otro subscriber
// en nuestra clase que escuche ese puerto
// Para tal fin, UVM provee una clase llamada uvm_tlm_analysis_fifo
//	esta clase nos provee un analysis_export y el metodo try_get()

class scoreboard extends uvm_subscriber #(shortint);
   `uvm_component_utils(scoreboard);

   uvm_tlm_analysis_fifo #(command_s) cmd_f;

   function void build_phase(uvm_phase phase);
      cmd_f = new ("cmd_f", this);
   endfunction : build_phase

   // Cada vez que la DUT entregue un resultado al analysis port se va a
   // activar este metodo
   function void write(shortint t);
      shortint predicted_result;
      command_s cmd; 
      cmd.op = no_op;


      // Aca realizamos la prediccion, buscamos en nuestra FIFO que comando
      // se mando, para eso obviamos los resets y los no_ops mediante el 
      // do....while
      // ya que siempre que tengamos un resultado, debemos tener una operacion
      // por eso si no existe la operacion y tenemos un resultado... es error
      do
       if (!cmd_f.try_get(cmd)) $fatal(1, "No command in self checker");
      while ((cmd.op == no_op) || (cmd.op == rst_op));
      
      case (cmd.op)
        add_op: predicted_result = cmd.A + cmd.B;
        and_op: predicted_result = cmd.A & cmd.B;
        xor_op: predicted_result = cmd.A ^ cmd.B;
        mul_op: predicted_result = cmd.A * cmd.B;
      endcase // case (op_set)

      if (predicted_result != t)
       $error ("FAILED: A: %2h  B: %2h  op: %s actual result: %4h   expected: %4h",
                cmd.A, cmd.B, cmd.op.name(), t,  predicted_result);
   endfunction : write         


   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : scoreboard