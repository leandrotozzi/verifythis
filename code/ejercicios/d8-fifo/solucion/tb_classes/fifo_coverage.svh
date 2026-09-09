// The coverage: the rows of the verification plan of spec.md, measured.
//
// What gets measured is not the data -- it is the STATES in which the FIFO
// served a request. Writing with the FIFO full and reading with the FIFO empty are
// the two rows nobody covers by accident.
class fifo_coverage extends uvm_subscriber #(fifo_transaction);
   `uvm_component_utils(fifo_coverage)

   protected fifo_transaction t;

   covergroup fifo_cov;
      option.per_instance = 1;

      // at_least = 2 on the edges: a single hit on "write with the FIFO
      // full" is an anecdote, not a verification. It is the knob from day 1.
      pedido: coverpoint {t.wr_en, t.rd_en} {
         bins nada        = {2'b00};
         bins escribe     = {2'b10};
         bins lee         = {2'b01};
         bins simultaneo  = {2'b11};
      }

      ocupacion: coverpoint t.count {
         bins vacia     = {0};
         bins pocos[]   = {[1:2]};
         bins medio     = {[3:5]};
         bins casi_full = {[6:7]};
         bins llena     = {8};
      }

      lleno:      coverpoint t.full;
      vacio:      coverpoint t.empty;
      casi_lleno: coverpoint t.almost_full;
      casi_vacio: coverpoint t.almost_empty;

      // The three crosses that count, and they are filtered on purpose: the full
      // product is 32 buckets and the plan asks for these.
      escribe_llena: cross pedido, lleno {
         option.at_least = 2;
         ignore_bins nada_ = binsof(pedido.nada);
         ignore_bins solo_lee = binsof(pedido.lee);
      }
      lee_vacia: cross pedido, vacio {
         option.at_least = 2;
         ignore_bins nada_ = binsof(pedido.nada);
         ignore_bins solo_escribe = binsof(pedido.escribe);
      }
      pedido_x_ocupacion: cross pedido, ocupacion {
         ignore_bins nada_ = binsof(pedido.nada);
      }
   endgroup : fifo_cov

   function new(string name, uvm_component parent);
      super.new(name, parent);
      fifo_cov = new();
   endfunction : new

   function void write(fifo_transaction t);
      this.t = t;
      fifo_cov.sample();
   endfunction : write

endclass : fifo_coverage
