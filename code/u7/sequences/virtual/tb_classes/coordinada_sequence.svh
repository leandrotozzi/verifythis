// LA sequence virtual.
//
// Dos cosas la distinguen de todas las de la seccion Sequences:
//
//   1. NO tiene items propios. Extiende uvm_sequence sin parametrizar y nunca
//      llama a start_item(): lo unico que hace es arrancar OTRAS sequences.
//      Por eso "virtual" -- no esta atada a un tipo de item ni a un sequencer.
//   2. Corre sobre mas de un sequencer, y de ahi sale lo unico que ninguna
//      sequence sola puede hacer: coordinar dos interfaces.
//
// `uvm_declare_p_sequencer declara `p_sequencer` con el tipo de arriba y lo
// castea solo en el m_set_p_sequencer. Sin el, get_sequencer() devuelve un
// uvm_sequencer_base y habria que castear a mano en cada uso.
class coordinada_sequence extends uvm_sequence;
   `uvm_object_utils(coordinada_sequence)
   `uvm_declare_p_sequencer(virtual_sequencer)

   int unsigned count = 1000;

   function new(string name = "coordinada_sequence");
      super.new(name);
   endfunction : new

   task body();
      reset_sequence   reset_a, reset_b;
      maxmult_sequence maxmult;
      random_sequence  random_b;
      un_op_sequence   primera, segunda;

      reset_a  = reset_sequence::type_id::create("reset_a");
      reset_b  = reset_sequence::type_id::create("reset_b");
      maxmult  = maxmult_sequence::type_id::create("maxmult");
      random_b = random_sequence::type_id::create("random_b");
      primera  = un_op_sequence::type_id::create("primera");
      segunda  = un_op_sequence::type_id::create("segunda");

      random_b.count = count;

      // --- 1. Las dos ALU se resetean a la vez ---------------------------------
      // fork/join sobre DOS sequencers. Cada rama bloquea en su propio driver, y
      // el join espera a las dos: eso no se puede escribir adentro de una
      // sequence normal, que solo conoce el sequencer que la arranco.
      fork
         reset_a.start(p_sequencer.clase_sequencer_h);
         reset_b.start(p_sequencer.modulo_sequencer_h);
      join

      // --- 2. Trafico en paralelo, distinto en cada interface -----------------
      // La A hace el caso dirigido del desborde mientras la B manda al azar.
      fork
         maxmult.start(p_sequencer.clase_sequencer_h);
         random_b.start(p_sequencer.modulo_sequencer_h);
      join

      // --- 3. Lo que ninguna sequence sola puede ------------------------------
      // El resultado de la VTALU A es el operando de la B. Es una dependencia
      // ENTRE interfaces: la segunda no puede ni empezar a armarse hasta que la
      // primera contesto.
      primera.A  = 8'h0F;
      primera.B  = 8'h07;
      primera.op = mul_op;
      primera.start(p_sequencer.clase_sequencer_h);

      `uvm_info("COORDINADA", $sformatf(
                "la A devolvio %0d: va de operando a la B", primera.result), UVM_LOW)

      segunda.A  = primera.result[7:0];
      segunda.B  = 8'h01;
      segunda.op = add_op;
      segunda.start(p_sequencer.modulo_sequencer_h);

      `uvm_info("COORDINADA", $sformatf(
                "la B devolvio %0d", segunda.result), UVM_LOW)
   endtask : body

endclass : coordinada_sequence
