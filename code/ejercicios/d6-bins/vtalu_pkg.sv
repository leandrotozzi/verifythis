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

   // Las sequences son uvm_object: van antes de los tests que las arrancan.
   `include "reset_sequence.svh"
   `include "random_sequence.svh"
   `include "maxmult_sequence.svh"
   `include "fibonacci_sequence.svh"
   `include "full_sequence.svh"
   `include "cierre_sequence.svh"  // el tuyo

   `include "coverage.svh"
   `include "scoreboard.svh"
   `include "driver.svh"
   `include "command_monitor.svh"
   `include "result_monitor.svh"

   `include "vtalu_agent.svh"
   `include "chequeo.svh"  // el corrector del ejercicio
   `include "env.svh"

   `include "base_test.svh"
   `include "full_test.svh"
   `include "fibonacci_test.svh"
   `include "add_test.svh"
   `include "default_seq_test.svh"
   `include "no_objection_test.svh"
   `include "cierre_test.svh"  // el enunciado, ya escrito

endpackage : vtalu_pkg
