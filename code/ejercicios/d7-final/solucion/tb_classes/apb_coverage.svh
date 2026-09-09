// The covergroup is the verification plan of spec.md, measured. Every bin here
// is a row of that table: if the bin does not fill, the row was not verified --
// no matter how green the scoreboard is.
class apb_coverage extends uvm_subscriber #(apb_transaction);
   `uvm_component_utils(apb_coverage)

   bit [7:0] addr;
   bit [7:0] registro;   // addr with the two ignored bits masked off
   bit [1:0] offset;     // ...and the two bits that got masked off
   bit       wr;
   bit       slverr;
   bit       encadenada;
   bit       ovf_leido;  // se leyo STATUS con OVF prendido
   bit       clr_pedido; // se escribio CTRL con CLR

   covergroup apb_cov;

      reg_addr: coverpoint registro {
         bins ctrl = {CTRL_ADDR};
         bins scratch = {SCRATCH_ADDR};
         bins acc = {ACC_ADDR};
         bins status = {STATUS_ADDR};
         bins unmapped = {[MAPA_FIN : 8'hFF]};
      }

      // Row 9 of the plan: PADDR[1:0] is ignored, and nobody had checked it.
      alineacion: coverpoint offset {
         bins aligned = {0};
         bins unaligned = {[1:3]};
      }

      // Row 8: PSEL can stay high between two transfers, and it is the driver
      // that decides. The monitor reads it off the bus.
      cadena: coverpoint encadenada {
         bins con_idle = {0};
         bins back_to_back = {1};
      }

      dir: coverpoint wr {
         bins wr = {1};
         bins rd = {0};
      }

      err: coverpoint slverr {
         bins ok = {0};
         bins error = {1};
      }

      // The four registers, written and read: row 1 of the plan. The implicit
      // cross is enough; crosses with binsof/intersect are ignored by Verilator.
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
      registro = {t.addr[7:2], 2'b00};
      offset = t.addr[1:0];
      encadenada = t.b2b;
      wr = t.write;
      slverr = t.slverr;
      // The last two rows of the plan are not fields of the transaction: they are
      // conditions. They get computed here and sampled like anything else.
      ovf_leido  = (!t.write && registro == STATUS_ADDR && t.rdata[1]);
      clr_pedido = (t.write && registro == CTRL_ADDR && t.wdata[1]);
      apb_cov.sample();
   endfunction : write

endclass : apb_coverage
