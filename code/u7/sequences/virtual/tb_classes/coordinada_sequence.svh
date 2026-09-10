// THE virtual sequence.
//
// Two things set it apart from every sequence in the Sequences section:
//
//   1. It has NO items of its own. It extends uvm_sequence without parameters
//      and never calls start_item(): all it does is start OTHER sequences.
//      Hence "virtual" -- it is tied to no item type and no sequencer.
//   2. It runs on more than one sequencer, and that is where the one thing no
//      single sequence can do comes from: coordinating two interfaces.

// cb: p-sequencer
// `uvm_declare_p_sequencer declares `p_sequencer` with the type above and casts
// it on its own inside m_set_p_sequencer. Without it, get_sequencer() returns a
// uvm_sequencer_base and every use would need a cast by hand.
class coordinada_sequence extends uvm_sequence;
   `uvm_object_utils(coordinada_sequence)
   `uvm_declare_p_sequencer(virtual_sequencer)
// cb: end

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

      // cb: the-fork
      // --- 1. Both ALUs get reset at the same time -----------------------------
      // fork/join over TWO sequencers. Each branch blocks on its own driver, and
      // the join waits for both: that cannot be written inside a normal
      // sequence, which only knows the sequencer that started it.
      fork
         reset_a.start(p_sequencer.clase_sequencer_h);
         reset_b.start(p_sequencer.modulo_sequencer_h);
      join

      // --- 2. Parallel traffic, different on each interface -------------------
      // A does the directed overflow case while B sends at random.
      fork
         maxmult.start(p_sequencer.clase_sequencer_h);
         random_b.start(p_sequencer.modulo_sequencer_h);
      join
      // cb: end

      // cb: the-ordered-pair
      // --- 3. What no single sequence can do ----------------------------------
      // The result of VTALU A is the operand of B. It is a dependency BETWEEN
      // interfaces: the second one cannot even start being built until the
      // first one answered.
      primera.A  = 8'h0F;
      primera.B  = 8'h07;
      primera.op = mul_op;
      primera.start(p_sequencer.clase_sequencer_h);

      `uvm_info("COORDINADA", $sformatf(
                "A returned %0d: it goes as an operand into B", primera.result), UVM_LOW)

      segunda.A  = primera.result[7:0];
      segunda.B  = 8'h01;
      segunda.op = add_op;
      segunda.start(p_sequencer.modulo_sequencer_h);
      // cb: end

      `uvm_info("COORDINADA", $sformatf(
                "B returned %0d", segunda.result), UVM_LOW)
   endtask : body

endclass : coordinada_sequence
