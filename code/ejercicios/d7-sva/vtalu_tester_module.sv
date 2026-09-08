// El "tester del jefe" de la seccion Agents, con una diferencia: alguien lo
// "optimizo".
//
// Para todas las operaciones sigue llamando a bfm.send_op(), como siempre. Para
// la multiplicacion no: la maneja a mano, "porque asi no hay que esperar a que
// la BFM haga las cosas bien". Y aprovecha los ciclos que el DUT tarda en
// contestar para ir dejando listo el operando de la proxima -- total, done
// todavia no subio, asi que el DUT no leyo nada.
//
// Ese razonamiento es falso, viola el protocolo, y el scoreboard NO LO VE:
// el multiplicador latchea A y B en el primer flanco y el resultado sale bien
// igual. Este modulo esta en produccion hace tres anos.
//
// Vos no tenes que tocar este archivo. Tenes que escribir la property que lo
// caza, en vtalu_bfm.sv.
module vtalu_tester_module (vtalu_bfm bfm);
   import vtalu_pkg::*;

   function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
         3'b000:  return no_op;
         3'b001:  return add_op;
         3'b010:  return sub_op;
         3'b011:  return and_op;
         3'b100:  return xor_op;
         3'b101:  return mul_op;
         3'b110:  return rst_op;
         3'b111:  return rst_op;
      endcase
   endfunction : get_op

   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00) return 8'h00;
      else if (zero_ones == 2'b11) return 8'hFF;
      else return $random;
   endfunction : get_data

   // La "optimizacion". Es el mismo handshake que send_op, mas la linea de mas.
   task mult_a_mano(input byte iA, input byte iB);
      @(negedge bfm.clk);
      bfm.op_set = mul_op;
      bfm.A      = iA;
      bfm.B      = iB;
      bfm.start  = 1'b1;
      @(negedge bfm.clk);
      @(negedge bfm.clk);
      bfm.B = ~iB;  // <-- adelantando trabajo, mientras el DUT "no mira"
      do @(negedge bfm.clk); while (bfm.done == 0);
      bfm.start = 1'b0;
   endtask : mult_a_mano

   initial begin
      byte unsigned     iA, iB;
      operation_t       op_set;
      shortint unsigned descartado;  // el modulo no chequea: de eso se ocupa el scoreboard
      bfm.reset_alu();
      repeat (200) begin : random_loop
         op_set = get_op();
         iA = get_data();
         iB = get_data();
         if (op_set == mul_op) mult_a_mano(iA, iB);
         else bfm.send_op(iA, iB, op_set, descartado);
      end : random_loop
   end

endmodule : vtalu_tester_module
