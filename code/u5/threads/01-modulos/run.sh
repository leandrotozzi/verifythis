#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
# -Wno-IMPLICIT: put_it/get_it are implicit wires in top. It is valid Verilog,
# but Verilator reports it and by default stops. The source is not touched.
vlt top -Wno-IMPLICIT modules.sv
run_sim
