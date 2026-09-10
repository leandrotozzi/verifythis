// Minimal repro of the bug that forced moving the protocol out of the interface
// and into the class. It is not part of the course: it is evidence for docs/verilator.md.
//
//   $ verilator --binary --timing --top-module top repro-vif-task.sv && ./obj_dir/Vtop
//
// Expected  : op_set=101 op=101 y=1
// With 5.048 : op_set=101 op=000 y=0    <- the interface assign is not re-evaluated
//            5.048 compiles this without a single warning.
//
// The only difference with the case that DOES work is who writes the signal:
// if the class does vif.op_set = v directly, it works; if it calls a task
// of the interface that does op_set = v, it does not.
interface tb_if;
   bit        clk;
   bit  [2:0] op_set;
   wire [2:0] op;
   bit        start;

   assign op = op_set;
   initial begin
      clk = 0;
      forever #5 clk = ~clk;
   end

   task drive(input bit [2:0] v);  // <- the task lives in the interface
      @(negedge clk);
      op_set = v;
      start = 1'b1;
   endtask
endinterface

module sink (
    input logic [2:0] op,
    input logic start,
    output logic y
);
   assign y = start & (op != 3'b000);
endmodule

class cls_driver;
   virtual tb_if vif;  // <- it gets called through a virtual interface
   function new(virtual tb_if v);
      vif = v;
   endfunction
   task go();
      vif.drive(3'b101);
   endtask
endclass

module top;
   tb_if intf ();
   logic y;
   sink s (
       .op(intf.op),
       .start(intf.start),
       .y(y)
   );
   cls_driver cd;

   initial begin
      cd = new(intf);
      cd.go();
      #1;
      $display("op_set=%b op=%b start=%b y=%b   (op and y should be 101 and 1)",
               intf.op_set, intf.op, intf.start, y);
      $finish;
   end
endmodule
