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
   // That is the idea of unit 3, and it holds to the end of the course.

   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start   = 1'b0;
   endtask : reset_alu

   // NEW in unit 23: the fourth argument. The protocol did not change; the only
   // thing added is reading result on the edge where done is already up.
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
            do @(negedge clk); while (done == 0);
            oresult   = result;
            start = 1'b0;
         end
      end  // else: !if(iop == rst_op)
   endtask : send_op


   // ==========================================================================
   //  Unit 24 - the protocol, checked where it happens
   // ==========================================================================
   //
   // The properties live HERE, with the signals, and not in the testbench: they
   // plug themselves in, nobody connects them, and BOTH VTALUs of the top end up
   // checked by this same block -- the agent's and the legacy module's.
   // All they need in order to run is --assert, which run.sh already passes.
   //
   // MIND THE EDGE. An assertion samples in the preponed region of the edge
   // it is given: a signal written ON an edge is not seen on that edge, it is seen
   // on the next one. Before choosing the @() of your property, go and look at which
   // edge send_op() writes the operands -- it is forty lines further up.

   default disable iff (!reset_n);

   // --- The stimulus: THIS IS WHAT YOU HAVE TO WRITE ---
   //
   // The rule has been written in prose since slide 1 of day 1: while start
   // is up, the operands and the operation ARE NOT TOUCHED. Write it as a
   // property, and make it fire a `uvm_error with the id "SVA" -- if it ends the
   // simulation with $stop, the Report Summary does not get printed and the checker sees
   // nothing.
   //
   // The two properties below are done and work as a mould: copy their
   // shape, not their @(). Both look at the DUT's RESPONSE; yours looks at the
   // STIMULUS, and that changes one thing.
   //
   // property p_operandos_estables;
   //    ...
   // endproperty : p_operandos_estables
   //
   // a_operandos_estables :
   // assert property (p_operandos_estables)
   // else `uvm_error("SVA", $sformatf("%m: operand changed with start up"))

   // --- The DUT's answer ---

   // The variable latency of the "VTALU spec" section in one line: one cycle for the
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

   // And the cover that goes with it: without this, a regression where the random
   // never subtracted too much leaves the assertion green having checked nothing.
   c_ovf : cover property (@(posedge clk) done && ovf);
   c_sub_sin_borrow : cover property (@(posedge clk) done && (op_set == sub_op) && !ovf);

   c_mult_3ciclos : cover property (@(posedge clk) $rose(start) && (op_set == mul_op) ##3 done);
   c_mult_4ciclos : cover property (@(posedge clk) $rose(start) && (op_set == mul_op) ##4 done);
   c_un_ciclo : cover property (@(posedge clk) $rose(start) && (op_set inside {add_op, and_op, xor_op}) ##1 done);

endinterface : vtalu_bfm
