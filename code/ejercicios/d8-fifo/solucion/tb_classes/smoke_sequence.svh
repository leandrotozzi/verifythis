// The directed sequence of stage 2: fill to the brim and drain.
//
// Ten writes onto a FIFO of eight: the last two get discarded, and there
// is half the spec. Then ten reads: the last two read empty.
class smoke_sequence extends uvm_sequence #(fifo_transaction);
   `uvm_object_utils(smoke_sequence)

   function new(string name = "smoke_sequence");
      super.new(name);
   endfunction : new

   protected task un_ciclo(bit wr, bit [7:0] dato, bit rd);
      fifo_transaction t;
      t = fifo_transaction::type_id::create("t");
      start_item(t);
      t.wr_en = wr;
      t.wr_data = dato;
      t.rd_en = rd;
      finish_item(t);
   endtask : un_ciclo

   task body();
      // 1. Overfill: 0xC0 .. 0xC9. The first eight go in.
      for (int i = 0; i < 10; i++) un_ciclo(1, 8'hC0 + 8'(i), 0);
      // 2. A simultaneous cycle with the FIFO full: the write GOES IN, because
      //    the read freed the place on the same edge.
      un_ciclo(1, 8'hEE, 1);
      // 3. Overdrain.
      for (int i = 0; i < 10; i++) un_ciclo(0, 8'h00, 1);
      // 4. And a write and a read on the empty FIFO, to touch the
      //    bottom edge with both hands.
      un_ciclo(0, 8'h00, 1);
      un_ciclo(1, 8'h5A, 1);
      un_ciclo(0, 8'h00, 1);
   endtask : body

endclass : smoke_sequence
