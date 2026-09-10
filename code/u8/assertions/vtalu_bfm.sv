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
      // The null guard rst_monitor already had, now here too. With two BFMs in
      // the top, one can be left without a monitor while the testbench is being
      // built -- or forever, if someone forgets to instantiate the passive
      // agent. Without the guard that is a simulator crash instead of a
      // testbench that sees nothing.
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
         // Same guard as op_monitor and rst_monitor: with two BFMs in the top,
         // one can be left without a monitor. Without this, forgetting the
         // passive agent is a simulator "Null pointer dereferenced" instead of
         // the checker's message -- which is exactly where exercise d6 starts.
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


   // --- the protocol, in the BFM ---
   // Everything that knows HOW the DUT is talked to lives here, in one place:
   // the rest of the testbench asks for an operation and never touches a wire.
   // That is the idea of the interfaces-and-BFM section, and it holds to the end of the course.

   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start   = 1'b0;
   endtask : reset_alu

   // NEW with the sequences: the fourth argument. The protocol did not change; the only
   // thing added is reading result on the edge where done is already up.
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
         // cb: the-planted-bug
            // +BUG=1: changes B halfway through the multiplication. The
            // multiplier already latched A and B on the first edge, so the
            // RESULT DOES NOT CHANGE: the scoreboard stays green. The only
            // thing that sees it is the assertion. That is the whole section.
            if (bug_operandos && iop == mul_op) begin
               @(negedge clk);
               @(negedge clk);
               B = ~iB;
            end
            do @(negedge clk); while (done == 0);
            oresult   = result;
            start = 1'b0;
         // cb: end
         end
      end  // else: !if(iop == rst_op)
   endtask : send_op


   // ==========================================================================
   //  The protocol, checked where it happens
   // ==========================================================================
   //
   // The properties live HERE, with the signals, and not in the testbench: they
   // plug themselves in, nobody connects them, and the passive agent of the Agents
   // section gets them for free. All they need in order to run is --assert.

   // cb: two-clocks
   // TWO CLOCKS, and it is not an implementation detail: the BFM drives on
   // negedge and the DUT registers on posedge. An assertion samples in the
   // preponed region of the edge it is given, so a signal written ON the negedge
   // is not seen on that negedge: it is seen on the next one. With everything on
   // posedge, two consecutive no_op -- start goes down at t=111 and back up at
   // t=120, between two posedges -- read as ONE transaction with the operands
   // changing: 145 false positives every 1000 operations. With everything on
   // negedge, the false positives move to the done properties.
   //
   //   stimulus (start, A, B, op_set)  -> negedge, where the BFM writes
   //   response (done, result)         -> posedge, where the DUT registers

   default disable iff (!reset_n);
   // cb: end

   // cb: stable-operands
   // --- The stimulus ---

   // The rule from slide 1 of day 1, executable at last: while start is up, the
   // operands and the operation are not touched.
   property p_operandos_estables;
      @(negedge clk) start |=> $stable(A) && $stable(B) && $stable(op_set);
   endproperty : p_operandos_estables

   a_operandos_estables :
   assert property (p_operandos_estables)
   else
      `uvm_error("SVA", $sformatf(
                 "%m: operand changed with start up: A=%0d B=%0d op=%s", A, B, op2enum().name()))
   // cb: end

   // --- The DUT's answer ---

   // cb: done-arrives
   // The variable latency from the VTALU spec section, in one line: one cycle for the
   // one-cycle ops, four edges for the multiplication.
   property p_done_llega;
      @(posedge clk) start && (op_set != no_op) |-> ##[1:5] done;
   endproperty : p_done_llega

   a_done_llega :
   assert property (p_done_llega)
   else `uvm_error("SVA", $sformatf("%m: start con op=%s y done no llego en 5 ciclos", op2enum().name()))

   // The fine print: no_op is the only operation that does not answer.
   property p_no_op_sin_done;
      @(posedge clk) start && (op_set == no_op) |=> !done;
   endproperty : p_no_op_sin_done

   a_no_op_sin_done :
   assert property (p_no_op_sin_done)
   else `uvm_error("SVA", $sformatf("%m: done subio para una no_op"))
   // cb: end

   // --- Every assertion comes with its cover property ---
   //
   // An assertion whose antecedent never happens PASSES, and checks nothing.
   // The cover is the antidote. And it also debunks mental models: the
   // "three-cycle" multiplication takes FOUR edges (done3 -> done2 ->
   // done1 -> done_mult), so c_mult_3ciclos stays at 0 forever.
   // --- VTALU rev2: the output the scoreboard only glances at ---

   // ovf belongs to sub and to nobody else. An assertion, because it is a rule of
   // the spec and not arithmetic: the scoreboard checks WHAT it computes, this
   // checks that it does not invent a flag where none belongs.
   property p_ovf_solo_en_sub;
      @(posedge clk) done && (op_set != sub_op) |-> !ovf;
   endproperty : p_ovf_solo_en_sub

   a_ovf_solo_en_sub :
   assert property (p_ovf_solo_en_sub)
   else `uvm_error("SVA", $sformatf("%m: ovf arriba con op=%s, que no puede desbordar", op2enum().name()))

   // cb: the-covers
   // And the cover that goes with it: without this, a regression where the random
   // never subtracted too much leaves the assertion green having checked nothing.
   c_ovf : cover property (@(posedge clk) done && ovf);
   c_sub_sin_borrow : cover property (@(posedge clk) done && (op_set == sub_op) && !ovf);

   c_mult_3ciclos : cover property (@(posedge clk) $rose(start) && (op_set == mul_op) ##3 done);
   c_mult_4ciclos : cover property (@(posedge clk) $rose(start) && (op_set == mul_op) ##4 done);
   c_un_ciclo : cover property (@(posedge clk) $rose(start) && (op_set inside {add_op, sub_op, and_op, xor_op}) ##1 done);
   // cb: end

endinterface : vtalu_bfm
