#!/bin/bash
# Day 3 exercise. It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the "The whole env" section; from here come the
# package, the env with the checker, and the two files you have to write.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
# "Do not touch env.svh" is the whole exercise: instantiating mult_tester
# there works, and gets there without one set_type_override. See intocables.sha.
intocables
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f
run_sim +UVM_TESTNAME=mult_test
cov_report
grep -q "EXERCISE OK" "$VLT_LOG" ||
  { echo "not yet: look at the UVM_ERROR above and at the README" >&2; exit 1; }
