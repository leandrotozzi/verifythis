#!/bin/bash
# Day 5 exercise. It fails until you solve it.
#
#   bash run.sh                        with your files
#   SOLUCION=1 bash run.sh             with the ones in solucion/, to compare
#   bash run.sh +UVM_VERBOSITY=UVM_HIGH   with the debug messages in plain sight
#
# The TB is the whole one from the Transactions section: the only thing coming out of this directory is
# command_monitor.svh, which comes first thanks to the +incdir order.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f
run_sim +UVM_TESTNAME=random_test "$@"

# run_sim already reads the Report Summary, so getting here means UVM_ERROR : 0.
# There is no second cross-check to make: the scoreboard is the one that grades,
# it comes from u6/transactions --nobody edits it-- and if the monitor stops
# writing to its analysis port it does not go quiet, it `uvm_fatal`s on the
# missing command. Deleting the bug is not a way of passing.
echo "EXERCISE OK: the scoreboard is quiet, and the DUT was never the culprit"
