// El top del capstone. Se da hecho, y no se toca.
//
// Hay DOS esclavos, cada uno con su interface -- es el mismo arreglo del
// seccion Agents: uno lo maneja tu testbench, el otro lo maneja un modulo de
// siempre, sin una linea de UVM. El segundo existe para que puedas escribir el
// MONITOR antes que el driver, que es el orden que recomienda el apendice del
// bus: si no podes ver el bus, no podes verificar nada.
module top;
   import uvm_pkg::*;
   import apb_pkg::*;
   `include "uvm_macros.svh"

   bit bug_en;

   // La que maneja tu testbench
   apb_if bfm ();
   apb_regs dut (
       .PCLK(bfm.PCLK), .PRESETn(bfm.PRESETn), .PSEL(bfm.PSEL), .PENABLE(bfm.PENABLE),
       .PWRITE(bfm.PWRITE), .PADDR(bfm.PADDR), .PWDATA(bfm.PWDATA), .bug_en(bug_en),
       .PRDATA(bfm.PRDATA), .PREADY(bfm.PREADY), .PSLVERR(bfm.PSLVERR)
   );

   // La que maneja el modulo de siempre. Su DUT nunca tiene el bug: lo unico
   // que se mira ahi es si tu monitor ve el bus.
   apb_if stim_bfm ();
   apb_regs stim_dut (
       .PCLK(stim_bfm.PCLK), .PRESETn(stim_bfm.PRESETn), .PSEL(stim_bfm.PSEL),
       .PENABLE(stim_bfm.PENABLE), .PWRITE(stim_bfm.PWRITE), .PADDR(stim_bfm.PADDR),
       .PWDATA(stim_bfm.PWDATA), .bug_en(1'b0),
       .PRDATA(stim_bfm.PRDATA), .PREADY(stim_bfm.PREADY), .PSLVERR(stim_bfm.PSLVERR)
   );

   apb_stim_module stim (stim_bfm);

   initial begin
      bug_en = $test$plusargs("BUG");
      // Como en la seccion Sequences: el top deja las dos interfaces con nombre y se
      // va. Quien las reparte es el test.
      uvm_config_db#(virtual apb_if)::set(null, "*", "bfm", bfm);
      uvm_config_db#(virtual apb_if)::set(null, "*", "stim_bfm", stim_bfm);
      run_test();
   end

endmodule : top
