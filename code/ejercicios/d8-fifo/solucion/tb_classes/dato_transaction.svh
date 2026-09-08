// Lo que sale por rd_data, un ciclo despues de la lectura que lo pidio.
class dato_transaction extends uvm_sequence_item;
   `uvm_object_utils(dato_transaction)

   bit [7:0] dato;

   function new(string name = "");
      super.new(name);
   endfunction : new

   function string convert2string();
      return $sformatf("sale %2h", dato);
   endfunction : convert2string

endclass : dato_transaction
