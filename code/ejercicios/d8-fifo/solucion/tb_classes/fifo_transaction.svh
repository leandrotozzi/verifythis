// Un ciclo de la FIFO: lo que se pidio, y en que estado estaba.
//
// La misma clase sirve de estimulo y de observacion, como en cualquier agent:
// las tres primeras las randomiza la sequence, las cinco de abajo las llena el
// monitor con lo que vio.
class fifo_transaction extends uvm_sequence_item;
   `uvm_object_utils(fifo_transaction)

   rand bit       wr_en;
   rand bit [7:0] wr_data;
   rand bit       rd_en;

   // Observado por el monitor: el estado ANTES del flanco.
   bit       full, almost_full, empty, almost_empty;
   bit [3:0] count;

   // Sin esto, la mitad de los ciclos no piden nada y la FIFO no se llena
   // nunca. Es la misma leccion del dist del dia 5: el random puro no visita
   // los bordes.
   constraint c_actividad {
      wr_en dist {1 := 7, 0 := 3};
      rd_en dist {1 := 5, 0 := 5};
   }

   function new(string name = "");
      super.new(name);
   endfunction : new

   function string convert2string();
      return $sformatf("wr=%0b data=%2h rd=%0b | count=%0d full=%0b af=%0b empty=%0b ae=%0b",
                       wr_en, wr_data, rd_en, count, full, almost_full, empty, almost_empty);
   endfunction : convert2string

endclass : fifo_transaction
