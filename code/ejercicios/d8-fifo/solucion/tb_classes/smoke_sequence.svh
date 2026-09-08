// La sequence dirigida de la etapa 2: llenar hasta el tope y vaciar.
//
// Diez escrituras sobre una FIFO de ocho: las dos ultimas se descartan, y ahi
// esta media spec. Despues diez lecturas: las dos ultimas leen vacio.
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
      // 1. Llenar de mas: 0xC0 .. 0xC9. Entran los ocho primeros.
      for (int i = 0; i < 10; i++) un_ciclo(1, 8'hC0 + 8'(i), 0);
      // 2. Un ciclo simultaneo con la FIFO llena: la escritura ENTRA, porque
      //    la lectura libero el lugar en el mismo flanco.
      un_ciclo(1, 8'hEE, 1);
      // 3. Vaciar de mas.
      for (int i = 0; i < 10; i++) un_ciclo(0, 8'h00, 1);
      // 4. Y una escritura y una lectura sobre la FIFO vacia, para tocar el
      //    borde de abajo con las dos manos.
      un_ciclo(0, 8'h00, 1);
      un_ciclo(1, 8'h5A, 1);
      un_ciclo(0, 8'h00, 1);
   endtask : body

endclass : smoke_sequence
