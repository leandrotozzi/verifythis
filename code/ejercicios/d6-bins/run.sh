#!/bin/bash
# Day 6 exercise (Sequences section) -- close a bin. It fails until you solve it.
#
#   bash run.sh              with your file
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#
# It runs the same test TWICE:
#   1. with +SIN_CIERRE  -> only reset + 60 random ones. That is the baseline coverage.
#   2. without it        -> the same, plus your directed case.
#
# The seed is pinned on purpose: with 7, the 60 random operations do NOT
# touch the FF x FF bin in mul_op, so the exercise is always the same. Without
# pinning it, some runs would fill it on their own and there would be nothing to close.
# (If the DUT or the stimulus changes, it has to be picked again: try seeds until
# the run with +SIN_CIERRE leaves the bin open.)
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f

export SEED=7
falta() { echo "not yet: $1" >&2; exit 1; }

# The exercise asks for the directed case to be ASKED FOR, not assigned. Assigning
# the three fields by hand also closes the bin -- u7/sequences' maxmult_sequence does that --
# but then neither the with{} nor the dist hole get practised, and those are the
# topic. It is the only thing this checker looks at in your file.
#
# The comment lines are dropped first: the header of cierre_sequence.svh explains
# the exercise and says "randomize()" three times, so a plain grep matched the
# statement of the problem and the check passed on the untouched file.
grep -v '^[[:space:]]*//' "${SOLUCION:+solucion/}cierre_sequence.svh" | grep -q 'randomize()' ||
  falta "your cierre_sequence does not call randomize(): the exercise asks for the
    directed case with randomize() with {}, not by assigning A, B and op by hand."

cg() { verilator_coverage "$1" 2>/dev/null | sed -nE 's/.*covergroup *: *([0-9.]+)% *\( *([0-9]+)\/.*/\2 \1/p'; }

echo "=== 1) without your directed case: 60 random operations ==="
run_sim +UVM_TESTNAME=cierre_test +UVM_TIMEOUT=500000,YES +SIN_CIERRE > /dev/null
ANTES=$VLT_OBJ/cov.$VLT_RUN.dat
read -r bins_antes pct_antes <<< "$(cg "$ANTES")"
echo "    coverage: $pct_antes%  ($bins_antes bins)"

echo "=== 2) with your cierre_sequence ==="
run_sim +UVM_TESTNAME=cierre_test +UVM_TIMEOUT=500000,YES || true
DESPUES=$VLT_OBJ/cov.$VLT_RUN.dat
read -r bins_despues pct_despues <<< "$(cg "$DESPUES")"
echo "    coverage: $pct_despues%  ($bins_despues bins)"

grep -q "\[PH_TIMEOUT\]" "$VLT_LOG" &&
  falta "the simulation stopped advancing: you are missing the finish_item()"

maxmul=$(sed -nE 's/.*\[CHEQUEO\].*maxmul=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)
[ -n "$maxmul" ] || falta "the checker never got to report: look at the log above"

if [ "$maxmul" -lt 1 ]; then
  falta "not a single FF x FF in mul_op went through the bus.
    If randomize() returned 0, it is the dist hole: with the data-spread constraint
    enabled, Verilator picks the value BEFORE looking at your with. Turn it off for
    this object -- one line, and it is in the Constrained random section."
fi
[ "$bins_despues" -gt "$bins_antes" ] ||
  falta "coverage did not go up: $bins_antes bins before, $bins_despues after"

uvm_summary_ok "$VLT_LOG" || falta "the Report Summary counts errors"

echo "EXERCISE OK: the bin closed -- $pct_antes% ($bins_antes bins) -> $pct_despues% ($bins_despues bins), with one transaction"
