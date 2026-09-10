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
# chequeo.sv is bound into the top and counts the shifts off the DUT's pins.
# Everything this exercise asks for lives in the two files you edit, the verdict
# included, so the verdict moved out to a file you cannot edit. See intocables.sha.
intocables
SRC=${SOLUCION:+solucion/}
vlt top --coverage-user -Wno-fatal \
    "${SRC}vtalu_1c.sv" "${SRC}vtalu_tb.sv" chequeo.sv \
    ../../vtalu_dut/vtalu.sv ../../vtalu_dut/vtalu_mult.sv
run_sim
cov_report

falta() { echo "not yet: $1" >&2; exit 1; }

# --- what the bus saw, out of chequeo.sv ------------------------------------
read -r ops shifts mal <<< "$(sed -nE 's/.*\[CHEQUEO\] ops=([0-9]+) shifts=([0-9]+) wrong=([0-9]+).*/\1 \2 \3/p' "$VLT_LOG" | tail -1)"
[ -n "$ops" ] || falta "the [CHEQUEO] line did not come out: look at the log above"

[ "$shifts" -gt 0 ] || falta "not one operation with op = 3'b110 went through the bus.
    Steps 1 and 2 of the README: the opcode has to exist in the enum AND get_op has
    to generate it. Until then there is nothing to verify."
[ "$mal" -eq 0 ] || falta "$mal of the $shifts shifts came out wrong. The line above
    says which one and what the hardware owes: mind the width, the shift is by
    B[2:0] and not by the whole B."

# --- and what this testbench says it did ------------------------------------
# The cross-check: the scoreboard has to have looked at every operation the bus
# answered. If it checked fewer, there are operations going by that nobody
# predicts -- which is exactly what happens when a case has no branch for the
# new opcode.
checked=$(sed -nE 's/.*TB COUNTERS:.*checked=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)
[ -n "$checked" ] || falta "the TB COUNTERS line did not come out: look at the log above"
[ "$checked" = "$ops" ] || falta "your scoreboard checked $checked operations and the
    bus answered $ops. Every operation that gets an answer has to go through the
    scoreboard."

# --- step 3: the one that passes in silence ---------------------------------
# The percentage does NOT catch it: a covergroup that never declared the bin does
# not count it as missing either, so leaving shr_op out of every bin still reports
# a tidy 100 % -- of 76 instead of 77. And a TOTAL does not catch it either: any
# coverpoint added anywhere moves the total up without measuring the new opcode.
# So the two things asked for are the ones that only step 3 produces: no bin left
# at zero, and single_cycle with one member more than the operations it used to
# have. The names come out of the coverage database, not out of your code.
read -r llenos puntos <<< "$(sed -nE 's/.*covergroup *: *[0-9.]+% *\( *([0-9]+)\/ *([0-9]+)\).*/\1 \2/p' "$VLT_OBJ/cov.report")"
[ -n "$puntos" ] || falta "the coverage report did not come out: look at the log above"
[ "$llenos" = "$puntos" ] || falta "coverage $llenos/$puntos: some bin stayed at zero.
    Look at which one in $VLT_OBJ/cov.report -- a bin nobody sampled is a case
    nobody verified."

sc=$(grep -c "op_cov\.op_set\.single_cycle\[" "$VLT_OBJ/coverage.dat" || true)
[ "$sc" -ge 7 ] || falta "single_cycle has $sc bins and the one-cycle operations are
    seven: add, sub, and, xor, shr, rst and no_op. The range [add_op : xor_op] stops
    at 3'b100, so shr_op is left OUT of every bin: it runs, it passes the scoreboard,
    and it does not show up in the report. That is step 3 of the README, and it is
    the one the percentage cannot see."

echo "EXERCISE OK: $shifts shifts checked on the bus, 0 wrong, coverage $llenos/$puntos"
