// The command_sequence of unit 22, split into three pieces that can now be
// combined at will. This sequence sends no item of its own: it only
// starts the other ones.
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

      // get_sequencer() returns the sequencer start() handed us: the children run
      // on the same one. The second argument declares them CHILDREN -- without it
      // they compete with us in the arbitration instead of inheriting our turn.
      reset_seq.start(get_sequencer(), this);
      random_seq.start(get_sequencer(), this);
      maxmult_seq.start(get_sequencer(), this);
   endtask : body

endclass : full_sequence
