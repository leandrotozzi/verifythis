// Repro minimo del bug que obligo a mover el protocolo de la interface a la
// clase. No es parte del curso: es evidencia para docs/verilator.md.
//
//   $ verilator --binary --timing --top-module top repro-vif-task.sv && ./obj_dir/Vtop
//
// Esperado : op_set=101 op=101 y=1
// Con 5.048 : op_set=101 op=000 y=0    <- el assign de la interface no se re-evalua
//            5.048 compila esto sin un solo warning.
//
// La unica diferencia con el caso que SI anda es quien escribe la senal:
// si la clase hace vif.op_set = v directamente, funciona; si llama a una task
// de la interface que hace op_set = v, no.
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

   task drive(input bit [2:0] v);  // <- la task vive en la interface
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
   virtual tb_if vif;  // <- se la llama por virtual interface
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
      $display("op_set=%b op=%b start=%b y=%b   (op e y deberian ser 101 y 1)",
               intf.op_set, intf.op, intf.start, y);
      $finish;
   end
endmodule
