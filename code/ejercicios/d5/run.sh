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
