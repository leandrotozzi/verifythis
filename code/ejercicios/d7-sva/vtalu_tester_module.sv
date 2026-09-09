// The "boss's tester" from the Agents section, with one difference: somebody
// "optimized" it.
//
// For every operation it still calls bfm.send_op(), as always. For
// the multiplication it does not: it drives it by hand, "because that way you do not have to wait
// for the BFM to do things properly". And it uses the cycles the DUT takes to
// answer to get the next operand ready -- after all, done
// has not gone up yet, so the DUT read nothing.
//
// That reasoning is false, it violates the protocol, and the scoreboard DOES NOT SEE IT:
// the multiplier latches A and B on the first edge and the result comes out right
// anyway. This module has been in production for three years.
//
// You do not have to touch this file. You have to write the property that
// catches it, in vtalu_bfm.sv. run.sh checks that with intocables.sha before
// compiling: shutting the legacy module up is not a way of solving the exercise.
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

   // The "optimization". It is the same handshake as send_op, plus the extra line.
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
