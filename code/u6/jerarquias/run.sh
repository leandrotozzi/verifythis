#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt top -f sv.f
run_sim

# The deep copy has to go down the three levels of the hierarchy: 'medidas' is
# the field of the last one, the one that gets lost if some do_copy forgets its
# super. It shows up twice: in Fernet 1 and in the already copied Fernet 2.
expect_in_log 2 'medidas: 2'

# wrong.sv is the "how not to" version and it is on screen in 130-jerarquias. It has
# its own `module top`, so it does not go into sv.f -- but it does have to COMPILE:
# it lived for months with a `sformat` (which does not exist in SystemVerilog) on a
# slide that presented it as working code, precisely because nobody ever built it.
verilator --lint-only --timing --quiet-stats -Wno-fatal --top-module top wrong.sv
