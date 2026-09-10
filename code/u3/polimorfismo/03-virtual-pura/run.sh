#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top -f sv.f
run_sim

# Same as 02-virtual: the pure one forces the derived class to implement
# servir(), and dispatch through the base handle still has to give two of each.
expect_in_log 2 'Fernet: 70/30, and the coke last'
expect_in_log 2 'Mojito: mint, lime and crushed ice'
