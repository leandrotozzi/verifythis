// One FIFO cycle: what was asked for, and in what state it was.
//
// The same class works as stimulus and as observation, like in any agent:
// the first three are randomized by the sequence, the five below are filled by the
// monitor with what it saw.
class fifo_transaction extends uvm_sequence_item;
   `uvm_object_utils(fifo_transaction)

   rand bit       wr_en;
   rand bit [7:0] wr_data;
   rand bit       rd_en;

   // Observed by the monitor: the state BEFORE the edge.
   bit       full, almost_full, empty, almost_empty;
   bit [3:0] count;

   // Without this, half the cycles ask for nothing and the FIFO never fills
   // up. It is the same lesson as the dist of day 5: pure random does not visit
   // the edges.
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
