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

   // Los configs primero: el driver y los monitores los usan.
   `include "env_config.svh"
   `include "vtalu_agent_config.svh"

   `include "command_transaction.svh"
   `include "add_transaction.svh"
   `include "result_transaction.svh"

   // El sequencer no se extiende: se parametriza y se le pone nombre.
   // Va DESPUES de command_transaction y ANTES del driver y del agent.
   typedef uvm_sequencer #(command_transaction) sequencer;

   `include "command_sequence.svh"

   `include "coverage.svh"
   `include "scoreboard.svh"
   `include "driver.svh"
   `include "command_monitor.svh"
   `include "result_monitor.svh"

   `include "vtalu_agent.svh"
   `include "env.svh"

   `include "dual_test.svh"

endpackage : vtalu_pkg
