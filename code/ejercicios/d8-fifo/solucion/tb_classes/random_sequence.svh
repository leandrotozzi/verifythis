// La sequence del random: N ciclos al azar, con el dist de la transaction
// sesgado a escribir mas de lo que lee. Sin ese sesgo la FIFO no se llena
// nunca y las dos filas caras del plan quedan en cero.
class random_sequence extends uvm_sequence #(fifo_transaction);
   `uvm_object_utils(random_sequence)

   rand int unsigned ciclos;
   constraint c_ciclos {ciclos inside {[400 : 600]};}

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      fifo_transaction t;
      repeat (ciclos) begin
         t = fifo_transaction::type_id::create("t");
         start_item(t);
         if (!t.randomize()) `uvm_fatal("SEQ", "randomize() fallo: falta z3?")
         finish_item(t);
      end
      // Y al final, vaciarla: asi el chequeo del check_phase tiene sentido y
      // se toca el borde de abajo aunque el azar no haya querido.
      repeat (12) begin
         t = fifo_transaction::type_id::create("t");
         start_item(t);
         t.wr_en = 1'b0;
         t.rd_en = 1'b1;
         finish_item(t);
      end
   endtask : body

endclass : random_sequence
