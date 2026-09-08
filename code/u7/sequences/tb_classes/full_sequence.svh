// El command_sequence de la unidad 22, partido en tres piezas que ahora se
// combinan como uno quiera. Esta sequence no manda ningun item propio: solo
// arranca a las otras.
class full_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(full_sequence)

   int unsigned count = 1000;

   function new(string name = "full_sequence");
      super.new(name);
   endfunction : new

   task body();
      reset_sequence   reset_seq;
      random_sequence  random_seq;
      maxmult_sequence maxmult_seq;

      reset_seq   = reset_sequence::type_id::create("reset_seq");
      random_seq  = random_sequence::type_id::create("random_seq");
      maxmult_seq = maxmult_sequence::type_id::create("maxmult_seq");

      random_seq.count = count;

      // get_sequencer() devuelve el sequencer que nos paso start(): las hijas
      // corren sobre el mismo. El segundo argumento las declara HIJAS -- sin el
      // compiten con nosotros en la arbitracion en vez de heredar nuestro turno.
      reset_seq.start(get_sequencer(), this);
      random_seq.start(get_sequencer(), this);
      maxmult_seq.start(get_sequencer(), this);
   endtask : body

endclass : full_sequence
