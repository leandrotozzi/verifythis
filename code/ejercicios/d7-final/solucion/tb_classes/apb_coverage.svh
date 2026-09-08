// El covergroup es el plan de verificacion de spec.md, medido. Cada bin de aca
// es una fila de esa tabla: si el bin no se llena, la fila no se verifico --
// por mas que el scoreboard este en verde.
class apb_coverage extends uvm_subscriber #(apb_transaction);
   `uvm_component_utils(apb_coverage)

   bit [7:0] addr;
   bit       wr;
   bit       slverr;
   bit       ovf_leido;  // se leyo STATUS con OVF prendido
   bit       clr_pedido; // se escribio CTRL con CLR

   covergroup apb_cov;

      reg_addr: coverpoint addr {
         bins ctrl = {CTRL_ADDR};
         bins scratch = {SCRATCH_ADDR};
         bins acc = {ACC_ADDR};
         bins status = {STATUS_ADDR};
         bins unmapped = {[MAPA_FIN : 8'hFF]};
      }

      dir: coverpoint wr {
         bins wr = {1};
         bins rd = {0};
      }

      err: coverpoint slverr {
         bins ok = {0};
         bins error = {1};
      }

      // Los cuatro registros, escritos y leidos: la fila 1 del plan. El cross
      // implicito alcanza; los cross con binsof/intersect Verilator los ignora.
      acceso: cross reg_addr, dir;

      overflow: coverpoint ovf_leido {
         bins no = {0};
         bins visto = {1};
      }

      clear: coverpoint clr_pedido {
         bins no = {0};
         bins pedido = {1};
      }

   endgroup

   function new(string name, uvm_component parent);
      super.new(name, parent);
      apb_cov = new();
   endfunction : new

   function void write(apb_transaction t);
      addr = t.addr;
      wr = t.write;
      slverr = t.slverr;
      // Las dos ultimas filas del plan no son campos de la transaccion: son
      // condiciones. Se calculan aca y se muestrean como cualquier otra cosa.
      ovf_leido  = (!t.write && t.addr == STATUS_ADDR && t.rdata[1]);
      clr_pedido = (t.write && t.addr == CTRL_ADDR && t.wdata[1]);
      apb_cov.sample();
   endfunction : write

endclass : apb_coverage
