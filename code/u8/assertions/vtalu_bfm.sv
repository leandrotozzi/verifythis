interface vtalu_bfm;
   import uvm_pkg::*;
   import vtalu_pkg::*;
   `include "uvm_macros.svh"

   byte unsigned          A;
   byte unsigned          B;
   bit                    clk;
   bit                    reset_n;
   bit                    start;
   wire                   done;
   wire            [15:0] result;
   wire                   ovf;
   operation_t            op_set;

   command_monitor        command_monitor_h;

   function operation_t op2enum();
      case (op_set)
         3'b000:  return no_op;
         3'b001:  return add_op;
         3'b010:  return sub_op;
         3'b011:  return and_op;
         3'b100:  return xor_op;
         3'b101:  return mul_op;
         default: $fatal(1, "Illegal operation on op bus");
      endcase  // case (op_set)
   endfunction : op2enum

   always @(posedge clk) begin : op_monitor
      static bit in_command = 0;
      // La guarda de null que ya tenia rst_monitor, ahora tambien aca. Con dos
      // BFM en el top, una puede quedar sin monitor mientras el testbench se
      // construye -- o para siempre, si alguien se olvida de instanciar el
      // agent pasivo. Sin la guarda eso es un crash del simulador en vez de un
      // testbench que no ve nada.
      if (command_monitor_h != null) begin : con_monitor
         if (start) begin : start_high
            if (!in_command) begin : new_command
               command_monitor_h.write_to_monitor(A, B, op2enum());
               in_command = (op2enum() != no_op);
            end : new_command
         end : start_high
         else  // start low
            in_command = 0;
      end : con_monitor
   end : op_monitor

   always @(negedge reset_n) begin : rst_monitor
      if (command_monitor_h != null)  //guard against VCS time 0 negedge
         command_monitor_h.write_to_monitor(A, B, rst_op);
   end : rst_monitor

   result_monitor result_monitor_h;

   initial begin : result_monitor_thread
      forever begin : result_monitor
         @(posedge clk);
         // Misma guarda que op_monitor y rst_monitor: con dos BFM en el top,
         // una puede quedar sin monitor. Sin esto, olvidarse del agent pasivo
         // es un "Null pointer dereferenced" del simulador en vez del mensaje
         // del corrector -- que es justo el estado inicial del ejercicio d6.
         if (done && result_monitor_h != null) result_monitor_h.write_to_monitor(result, ovf);
      end : result_monitor
   end : result_monitor_thread

   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end


   // --- el protocolo, en el BFM ---
   // Todo lo que sabe COMO se habla con el DUT vive aca, en un solo lugar: el
   // resto del testbench pide una operacion y no toca un cable. Es la idea de
   // la unidad 3, y se sostiene hasta el final del curso.

   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start   = 1'b0;
   endtask : reset_alu

   // NUEVO en la unidad 23: el cuarto argumento. El protocolo no cambio; lo
   // unico que se agrego es leer result en el flanco en que done ya subio.
   bit bug_operandos;
   initial bug_operandos = $test$plusargs("BUG");

   task send_op(input byte iA, input byte iB, input operation_t iop,
                output shortint unsigned oresult);
      oresult = 0;
      if (iop == rst_op) begin
         @(posedge clk);
         reset_n = 1'b0;
         start   = 1'b0;
         @(posedge clk);
         #1;
         reset_n = 1'b1;
      end else begin
         @(negedge clk);
         op_set = iop;
         A = iA;
         B = iB;
         start = 1'b1;
         if (iop == no_op) begin
            @(posedge clk);
            #1;
            start = 1'b0;
         end else begin
            // +BUG=1: cambia B a mitad de la multiplicacion. El multiplicador
            // ya latcheo A y B en el primer flanco, asi que el RESULTADO NO
            // CAMBIA: el scoreboard sigue en verde. Lo unico que lo ve es la
            // assertion. Eso es toda la seccion.
            if (bug_operandos && iop == mul_op) begin
               @(negedge clk);
               @(negedge clk);
               B = ~iB;
            end
            do @(negedge clk); while (done == 0);
            oresult   = result;
            start = 1'b0;
         end
      end  // else: !if(iop == rst_op)
   endtask : send_op


   // ==========================================================================
   //  Unidad 24 - el protocolo, chequeado donde ocurre
   // ==========================================================================
   //
   // Las properties viven ACA, con las senales, y no en el testbench: se
   // enchufan solas, nadie las conecta, y el agent pasivo de la seccion Agents se
   // las lleva de regalo. Lo unico que hace falta para que corran es --assert.
   //
   // DOS RELOJES, y no es un detalle de implementacion: la BFM maneja en
   // negedge y el DUT registra en posedge. Una assertion muestrea en la region
   // preponed del flanco que se le da, asi que una senal escrita EN el negedge
   // no se ve en ese negedge: se ve en el siguiente. Con todo en posedge, dos
   // no_op consecutivas -- start baja en t=111 y vuelve a subir en t=120, entre
   // dos posedge -- se leen como UNA transaccion con los operandos cambiando:
   // 185 falsos positivos cada 1000 operaciones. Con todo en negedge, los
   // falsos positivos se mudan a las properties de done.
   //
   //   estimulo  (start, A, B, op_set)  -> negedge, donde la BFM escribe
   //   respuesta (done, result)         -> posedge, donde el DUT registra

   default disable iff (!reset_n);

   // --- El estimulo ---

   // La regla de la slide 1 del dia 1, por fin ejecutable: mientras start este
   // arriba, los operandos y la operacion no se tocan.
   property p_operandos_estables;
      @(negedge clk) start |=> $stable(A) && $stable(B) && $stable(op_set);
   endproperty : p_operandos_estables

   a_operandos_estables :
   assert property (p_operandos_estables)
   else
      `uvm_error("SVA", $sformatf(
                 "%m: operando cambiado con start arriba: A=%0d B=%0d op=%s", A, B, op2enum().name()))

   // --- La respuesta del DUT ---

   // La latencia variable de la seccion La spec del VTALU en una linea: un ciclo las de un
   // ciclo, cuatro flancos la multiplicacion.
   property p_done_llega;
      @(posedge clk) start && (op_set != no_op) |-> ##[1:5] done;
   endproperty : p_done_llega

   a_done_llega :
   assert property (p_done_llega)
   else `uvm_error("SVA", $sformatf("%m: start con op=%s y done no llego en 5 ciclos", op2enum().name()))

   // La letra chica: no_op es la unica operacion que no responde.
   property p_no_op_sin_done;
      @(posedge clk) start && (op_set == no_op) |=> !done;
   endproperty : p_no_op_sin_done

   a_no_op_sin_done :
   assert property (p_no_op_sin_done)
   else `uvm_error("SVA", $sformatf("%m: done subio para una no_op"))

   // --- Toda assertion va con su cover property ---
   //
   // Una assertion cuyo antecedente no ocurre nunca PASA, y no chequea nada.
   // El cover es el antidoto. Y de paso desmiente modelos mentales: la
   // multiplicacion "de tres ciclos" tarda CUATRO flancos (done3 -> done2 ->
   // done1 -> done_mult), asi que c_mult_3ciclos se queda en 0 para siempre.
   // --- rev2 del VTALU: la salida que el scoreboard solo mira de reojo ---

   // El ovf es del sub y de nadie mas. Una assertion, porque es una regla de la
   // spec y no una cuenta: el scoreboard chequea QUE calcula, esto chequea que
   // no invente una bandera donde no corresponde.
   property p_ovf_solo_en_sub;
      @(posedge clk) done && (op_set != sub_op) |-> !ovf;
   endproperty : p_ovf_solo_en_sub

   a_ovf_solo_en_sub :
   assert property (p_ovf_solo_en_sub)
   else `uvm_error("SVA", $sformatf("%m: ovf arriba con op=%s, que no puede desbordar", op2enum().name()))

   // Y el cover que lo acompaña: sin esto, una regresion donde el random nunca
   // haya restado de menos deja la assertion en verde sin haber chequeado nada.
   c_ovf : cover property (@(posedge clk) done && ovf);
   c_sub_sin_borrow : cover property (@(posedge clk) done && (op_set == sub_op) && !ovf);

   c_mult_3ciclos : cover property (@(posedge clk) $rose(start) && (op_set == mul_op) ##3 done);
   c_mult_4ciclos : cover property (@(posedge clk) $rose(start) && (op_set == mul_op) ##4 done);
   c_un_ciclo : cover property (@(posedge clk) $rose(start) && (op_set inside {add_op, and_op, xor_op}) ##1 done);

endinterface : vtalu_bfm
