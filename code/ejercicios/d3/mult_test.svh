// TODO(exercise 3): write the mult_test class here.
//
// It has to:
//   1. extend uvm_test and register itself in the factory
//   2. in build_phase, tell the factory that when somebody asks for a
//      base_tester it should hand back a mult_tester: that is the factory override
//   3. create the env
//
// What it must NOT do: touch env.svh. That is the whole point — the structure
// of the TB never finds out that the stimulus changed.
