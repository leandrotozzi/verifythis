// The virtual sequencer: it has no queue, it arbitrates no items, it talks to no
// driver. It is a component that exists for two things:
//
//   1. to hold the HANDLES to the real sequencers, somewhere the sequence can
//      reach without looking up by string;
//   2. to be a uvm_component, that is, to live in the tree and have a name.
//
// That is why it extends uvm_sequencer WITHOUT parameters: the default item is
// uvm_sequence_item, and none is ever sent.
// cb: the-handles
class virtual_sequencer extends uvm_sequencer;
   `uvm_component_utils(virtual_sequencer)

   sequencer clase_sequencer_h;
   sequencer modulo_sequencer_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : virtual_sequencer
// cb: end
