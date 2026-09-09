#!/bin/bash
# Day 2 exercise. It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the A testbench without a single module section; from here come the package, your mult_tester and
# the testbench class, which come first thanks to the +incdir order.
#
# If the scoreboard finds a mismatch, Verilator's $error aborts the
# simulation: there is nothing to check here.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f
run_sim

if [ "$(grep -c ' mul_op ' "$VLT_LOG")" -lt 1000 ]; then
  echo "not yet: the loop has to send 1000 multiplications" >&2; exit 1
fi
if grep -qE ' (no_op|add_op|and_op|xor_op) ' "$VLT_LOG"; then
  echo "not yet: operations other than mul_op still come out" >&2; exit 1
fi
echo "EXERCISE OK: 1000 multiplications and not one mismatch"
