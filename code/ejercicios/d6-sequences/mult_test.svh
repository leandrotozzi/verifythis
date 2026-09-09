// TODO(exercise 7): write the mult_test class here.
//
// It has to:
//   1. extend base_test, which already builds the env and leaves the sequencer of the
//      active agent in the sequencer_h field
//   2. register itself with `uvm_component_utils  --  this one IS a component
//   3. in task run_phase(): create the mult_sequence through the factory, raise the
//      objection, start it with start(sequencer_h), and drop it
//
// Look at full_test.svh and fibonacci_test.svh in code/u7/sequences/tb_classes/.
