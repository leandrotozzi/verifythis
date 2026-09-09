#!/bin/bash
# Day 7 exercise (Assertions section). It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the Assertions section. Two files come from here: the legacy
# module that violates the protocol --which must NOT be touched-- and the BFM, which is
# where the property goes.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
# The legacy module is the DUT of this exercise: silencing it is not solving
# it. Until now only the scoreboard noticed, and it noticed sideways.
intocables

# --assert is what turns the concurrent properties on. Without the flag they compile,
# they do not run, and everything "passes".
vlt_uvm top --assert --coverage-user -Wno-fatal \
  -f dut.f -f tb.f "${SOLUCION:+solucion/}vtalu_bfm.sv"

# The uvm_error being looked for are precisely the result of the exercise.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=full_test

falta() { echo "not yet: $1" >&2; exit 1; }

# The two numbers come from the %m of the message: each BFM says who it is.
modulo=$(grep -c 'UVM_ERROR.*\[SVA\].*modulo_bfm' "$VLT_LOG" || true)
clase=$(grep -c  'UVM_ERROR.*\[SVA\].*clase_bfm'  "$VLT_LOG" || true)

if [ "$modulo" -eq 0 ]; then
  falta "no assertion fired on modulo_bfm, which is the one driven by the
    legacy module. Either you have not written the property yet, or its antecedent
    never happens: add a cover property to it and see whether it gets covered."
fi
if [ "$clase" -gt 0 ]; then
  falta "your property fired $clase times on clase_bfm, which is the one driven by
    the agent driver and respects the protocol. Those are false positives, and the
    culprit is the EDGE you sample on: the BFM writes on negedge."
fi
# And the scoreboard has to have stayed green: if the bug also corrupts
# the result, it stops being a blind bug and the exercise loses its point.
if grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
  falta "the scoreboard is reporting errors. It should not: check that you did not
    touch vtalu_tester_module.sv."
fi

echo "EXERCISE OK: the assertion catches $modulo violations of the legacy module,"
echo "              0 false positives on the agent, and the scoreboard stays green"
