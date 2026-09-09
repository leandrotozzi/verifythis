#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top -f sv.f
run_sim

# Igual que 02-virtual: la pura obliga a la derivada a implementar servir(), y
# el despacho por el handle de la base tiene que seguir dando dos de cada uno.
expect_in_log 2 'Fernet: 70/30, and the coke last'
expect_in_log 2 'Mojito: mint, lime and crushed ice'
