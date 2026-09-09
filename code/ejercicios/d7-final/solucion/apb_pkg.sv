package apb_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // The register map, written once.
   localparam bit [7:0] CTRL_ADDR = 8'h00;
   localparam bit [7:0] SCRATCH_ADDR = 8'h04;
   localparam bit [7:0] ACC_ADDR = 8'h08;
   localparam bit [7:0] STATUS_ADDR = 8'h0C;
   localparam bit [7:0] MAPA_FIN = 8'h10;  // de aca para arriba, PSLVERR

   `include "apb_env_config.svh"
   `include "apb_agent_config.svh"

   `include "apb_transaction.svh"

   typedef uvm_sequencer #(apb_transaction) apb_sequencer;

   `include "smoke_sequence.svh"
   `include "random_sequence.svh"

   `include "apb_coverage.svh"
   `include "apb_scoreboard.svh"
   `include "apb_driver.svh"
   `include "apb_monitor.svh"

   `include "apb_agent.svh"
   `include "apb_env.svh"

   `include "base_test.svh"
   `include "monitor_test.svh"
   `include "smoke_test.svh"
   `include "random_test.svh"

endpackage : apb_pkg
