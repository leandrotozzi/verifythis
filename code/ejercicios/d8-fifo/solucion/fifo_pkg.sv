package fifo_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // Los tres numeros de la spec, escritos una sola vez. El scoreboard y la
   // cobertura los leen de aca: un modelo que hardcodea el 8 se rompe callado
   // el dia que la FIFO cambia de tamano.
   localparam int DEPTH = 8;
   localparam int AF    = 6;  // almost_full con 6 o mas
   localparam int AE    = 2;  // almost_empty con 2 o menos

   `include "fifo_env_config.svh"
   `include "fifo_agent_config.svh"

   `include "fifo_transaction.svh"
   `include "dato_transaction.svh"

   typedef uvm_sequencer #(fifo_transaction) fifo_sequencer;

   `include "smoke_sequence.svh"
   `include "random_sequence.svh"

   `include "fifo_coverage.svh"
   `include "fifo_scoreboard.svh"
   `include "fifo_driver.svh"
   `include "fifo_monitor.svh"

   `include "fifo_agent.svh"
   `include "fifo_env.svh"

   `include "base_test.svh"
   `include "monitor_test.svh"
   `include "smoke_test.svh"
   `include "random_test.svh"

endpackage : fifo_pkg
