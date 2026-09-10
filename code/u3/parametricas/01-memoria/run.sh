#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top ram.sv top.sv
run_sim

# pres-ch8.sv is the version that is on screen in 055-clases-parametricas: the same
# RAM and the same top in one file, so the slide shows the parameter and its
# instantiation together. It has its own `module top`, so it does not go into the
# build -- but it does have to COMPILE, the same way wrong.sv does in u6/jerarquias.
verilator --lint-only --quiet-stats -Wno-fatal --top-module top pres-ch8.sv
