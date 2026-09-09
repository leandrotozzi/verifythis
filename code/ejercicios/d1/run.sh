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

# Step 3 of the README is the one that fails in silence, and the percentage does
# NOT catch it: a covergroup that never declared the bin does not count it as
# missing either, so a testbench that leaves shr_op out of every bin still
# reports a tidy 100 % -- 76/76 instead of 77/77. What drops is the number of
# COVERED bins, and that is what is checked here. It is a floor and not an
# equality on purpose: any way of putting shr_op in the measure reaches 77 (a
# bin of its own, or the range stretched to shr_op, which gives 78), and adding
# bins later must never turn the exercise red.
bins=$(sed -nE 's/.*covergroup *: *[0-9.]+% *\( *([0-9]+)\/.*/\1/p' "$VLT_OBJ/cov.report")
[ "${bins:-0}" -ge 77 ] || {
  echo "not yet: the report closes with $bins covered bins and this testbench has to" >&2
  echo "    reach 77. The shift runs and the scoreboard signs it off, but it is not" >&2
  echo "    landing inside any bin: an opcode nobody measures is step 3 of the README." >&2
  exit 1; }
