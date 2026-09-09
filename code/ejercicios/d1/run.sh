#!/bin/bash
# Day 1 exercise. It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The VTALU top and the multiplier come from the course DUT, untouched: the two
# files in this directory are the only ones to edit.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
SRC=${SOLUCION:+solucion/}
vlt top --coverage-user -Wno-fatal \
    "${SRC}vtalu_1c.sv" "${SRC}vtalu_tb.sv" \
    ../../vtalu_dut/vtalu.sv ../../vtalu_dut/vtalu_mult.sv
run_sim
cov_report
grep -q "EXERCISE OK" "$VLT_LOG" ||
  { echo "not yet: look at the lines above and at the README" >&2; exit 1; }
