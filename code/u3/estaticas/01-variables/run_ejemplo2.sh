#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top_pepes ejemplo2.sv
run_sim

# The static counter: two pepes created, a single counter. If it stopped being
# shared it would say 1, and the example would pass just as green.
expect_in_log 1 'NUMBER OF PEPES = 2'
