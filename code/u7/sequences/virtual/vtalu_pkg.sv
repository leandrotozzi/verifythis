// The package of the Sequences section, with four more files at the end. The `include
// that are not in this directory come from ../tb_classes through the +incdir; the
// env.svh is the only one overridden, and it is the one that turns on the second agent.
package vtalu_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   typedef enum bit [2:0] {
      no_op  = 3'b000,
      add_op = 3'b001,
      sub_op = 3'b010,
      and_op = 3'b011,
      xor_op = 3'b100,
      mul_op = 3'b101,
      rst_op = 3'b111
   } operation_t;

   `include "env_config.svh"
   `include "vtalu_agent_config.svh"

   `include "command_transaction.svh"
   `include "add_transaction.svh"
   `include "result_transaction.svh"

   typedef uvm_sequencer #(command_transaction) sequencer;

   `include "reset_sequence.svh"
   `include "random_sequence.svh"
   `include "maxmult_sequence.svh"
   `include "fibonacci_sequence.svh"
   `include "full_sequence.svh"
   `include "un_op_sequence.svh"

   `include "coverage.svh"
   `include "scoreboard.svh"
   `include "driver.svh"
   `include "command_monitor.svh"
   `include "result_monitor.svh"

   `include "vtalu_agent.svh"

   // The virtual sequencer goes BEFORE the env --the env instantiates it-- and
   // before the virtual sequence, which names it in `uvm_declare_p_sequencer.
   `include "virtual_sequencer.svh"
   `include "coordinada_sequence.svh"
   `include "env.svh"

   `include "base_test.svh"
   `include "virtual_test.svh"

endpackage : vtalu_pkg
