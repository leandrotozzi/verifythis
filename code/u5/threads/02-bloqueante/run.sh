#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt_uvm top example_pkg.sv top.sv
run_sim
