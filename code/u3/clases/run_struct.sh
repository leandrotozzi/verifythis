#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt top_struct structs.sv
run_sim
