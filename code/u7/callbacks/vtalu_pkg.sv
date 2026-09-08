// The Agents testbench, plus the callback hook. Everything that is not about
// callbacks is included straight from ../agents/tb_classes: tb.f puts this
// example's tb_classes FIRST on the include path, so the only file that shadows
// the other example's is driver.svh -- the one that grows the hook.
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

   `include "command_sequence.svh"

   `include "coverage.svh"
   `include "scoreboard.svh"

   // Before the driver: `uvm_register_cb needs the callback type to exist.
   `include "driver_callback.svh"
   `include "driver.svh"

   `include "command_monitor.svh"
   `include "result_monitor.svh"

   `include "vtalu_agent.svh"
   `include "env.svh"

   `include "dual_test.svh"
   `include "inject_test.svh"

endpackage : vtalu_pkg
