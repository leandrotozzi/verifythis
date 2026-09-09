#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top -f sv.f
run_sim

# Los tres fernets se pushearon desde TRES objetos distintos y salen de una sola
# lista, la estatica de la clase. Si dejara de ser compartida la bandeja tendria
# un solo vaso, y sin este chequeo el ejemplo pasaria igual.
expect_in_log 3 'the one at'
