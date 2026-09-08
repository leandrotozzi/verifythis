package vtalu_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // El modelo de referencia vive en vtalu_golden.c y se llama desde aca. Es
   // todo lo que hace falta del lado de SystemVerilog: una declaracion por
   // funcion, con los tipos del LRM que cruzan la frontera.
   //
   //   input int  -> int          output int -> int *
   //   function   -> devuelve     task       -> puede consumir tiempo (no aca)
   //
   // El nombre despues de "DPI-C" es el simbolo que el linker busca, asi que
   // tiene que coincidir con el del .c letra por letra.
   import "DPI-C" function int  vtalu_golden(input int op, input int a,
                                             input int b, output int ovf);
   import "DPI-C" function void vtalu_golden_bug(input int on);

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

   `include "coverage.svh"
   `include "scoreboard.svh"
   `include "driver.svh"
   `include "command_monitor.svh"
   `include "result_monitor.svh"

   `include "vtalu_agent.svh"
   `include "env.svh"

   `include "base_test.svh"
   `include "full_test.svh"
   `include "fibonacci_test.svh"
   `include "add_test.svh"
   `include "default_seq_test.svh"
   `include "no_objection_test.svh"

endpackage : vtalu_pkg
