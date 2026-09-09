// The "boss's tester": an ordinary module, without a single line of UVM, driving
// its own VTALU. The only thing the testbench does with it is WATCH it, with a
// passive agent.
//
// It calls the SAME bfm.send_op() the agent's driver calls: it gets the interface
// through its module port instead of through a virtual interface, but the
// protocol it runs is the same code. That is what makes the comparison between
// the two stimuli fair -- the only thing that changes is WHAT each one sends.
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
      byte unsigned iA, iB;
      operation_t   op_set;
      bfm.reset_alu();
      repeat (200) begin : random_loop
         op_set = get_op();
         iA = get_data();
         iB = get_data();
         bfm.send_op(iA, iB, op_set);
      end : random_loop
   end

endmodule : vtalu_tester_module
