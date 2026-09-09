// cb: handles
interface vtalu_bfm;
   import vtalu_pkg::*;

   // These handles get assigned in the build_phases of the classes
   command_monitor        command_monitor_h;
   result_monitor         result_monitor_h;

   byte unsigned          A;
   byte unsigned          B;
   bit                    clk;
   bit                    reset_n;
   bit                    start;
   wire                   done;
   wire            [15:0] result;
   wire                   ovf;
   operation_t            op_set;
// cb: end

   // cb: monitors
   // Here is the first monitor (commands)
   // A very simple FSM. If start is up, check whether this is a new command
   // If it is, send it to the TB with commands_monitor.write_to_monitor()
   always @(posedge clk) begin : cmd_monitor
      bit new_command;
      if (!start) new_command = 1;
      else if (new_command) begin
         command_monitor_h.write_to_monitor(A, B, op_set);
         new_command = (op_set == 3'b000);  // handle no_op
      end
   end : cmd_monitor

   always @(negedge reset_n) begin : rst_monitor
      if (command_monitor_h != null)  //guard against VCS time 0 negedge
         command_monitor_h.write_to_monitor(A, B, rst_op);
   end : rst_monitor

   always @(posedge clk) begin : rslt_monitor
      if (done) result_monitor_h.write_to_monitor(result);
   end : rslt_monitor
   // cb: end

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
