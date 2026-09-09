interface vtalu_bfm;
   import vtalu_pkg::*;

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
      command_s  command;
      if (start) begin : start_high
         if (!in_command) begin : new_command
            command.A = A;
            command.B = B;
            command.op = op2enum();
            command_monitor_h.write_to_monitor(command);
            in_command = (command.op != no_op);
         end : new_command
      end : start_high
      else  // start low
         in_command = 0;
   end : op_monitor

   always @(negedge reset_n) begin : rst_monitor
      command_s command;
      command.op = rst_op;
      if (command_monitor_h != null)  //guard against VCS time 0 negedge
         command_monitor_h.write_to_monitor(command);
   end : rst_monitor

   result_monitor result_monitor_h;

   initial begin : result_monitor_thread
      forever begin : result_monitor
         @(posedge clk);
         if (done) result_monitor_h.write_to_monitor(result);
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
      start = 1'b0;
   endtask : reset_alu

   task send_op(input byte iA, input byte iB, input operation_t iop);
      if (iop == rst_op) begin
         @(posedge clk);
         reset_n = 1'b0;
         start = 1'b0;
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
            start = 1'b0;
         end
      end  // else: !if(iop == rst_op)

   endtask : send_op

endinterface : vtalu_bfm
