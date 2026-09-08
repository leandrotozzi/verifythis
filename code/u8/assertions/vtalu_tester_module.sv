// El "tester del jefe": un modulo de siempre, sin una linea de UVM, que maneja
// su propia VTALU. Lo unico que el testbench hace con el es MIRARLO, con un
// agent pasivo.
//
// Llama a la MISMA bfm.send_op() que el driver del agent: recibe la interface
// por su puerto en vez de por una virtual interface, pero el protocolo que
// ejecuta es el mismo codigo. Por eso la comparacion entre los dos estimulos es
// justa -- lo unico que cambia es QUE manda cada uno.
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

   initial begin
      byte unsigned    iA, iB;
      operation_t      op_set;
      shortint unsigned descartado;  // el modulo no chequea: de eso se ocupa el scoreboard
      bfm.reset_alu();
      repeat (200) begin : random_loop
         op_set = get_op();
         iA = get_data();
         iB = get_data();
         bfm.send_op(iA, iB, op_set, descartado);
      end : random_loop
   end

endmodule : vtalu_tester_module
