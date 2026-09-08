// El package de la seccion Sequences, con cuatro archivos mas al final. Los `include
// que no estan en este directorio salen de ../tb_classes por el +incdir; el
// env.svh es el unico que se pisa, y es el que prende el segundo agent.
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

   // El sequencer virtual va ANTES del env --el env lo instancia-- y antes de
   // la sequence virtual, que lo nombra en el `uvm_declare_p_sequencer.
   `include "virtual_sequencer.svh"
   `include "coordinada_sequence.svh"
   `include "env.svh"

   `include "base_test.svh"
   `include "virtual_test.svh"

endpackage : vtalu_pkg
