#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
# -Wno-IMPLICIT: put_it/get_it son wires implicitos en top. Es Verilog valido,
# pero Verilator lo reporta y por defecto corta. El fuente no se toca.
vlt top -Wno-IMPLICIT modules.sv
run_sim
