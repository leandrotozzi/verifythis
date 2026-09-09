#!/bin/bash
# Day 4 exercise. It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the Analysis ports section; from here come the package, the env you have
# to connect and your op_counter.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f
# The command_monitor reports with `uvm_info at UVM_HIGH, so the verbosity
# ceiling has to be raised for its lines to show up in the log. That is the
# Reporting section's topic; here it is enough to know that without the flag they are invisible.
run_sim +UVM_TESTNAME=random_test +UVM_VERBOSITY=UVM_HIGH || true

# The grading is cross-checked: what you counted has to match the lines the
# command_monitor printed, which you did not write.
# The ^UVM_INFO is not decorative: without it, the grep also counts the line
# "[COMMAND MONITOR]  1000" of the Report Summary and gives one too many.
vistos=$(grep -c '^UVM_INFO.*\[COMMAND MONITOR\]' "$VLT_LOG" || true)
contados=$(sed -nE 's/.*OP_COUNTER.*commands=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)

if [ -z "$contados" ]; then
  echo "not yet: op_counter printed nothing in report_phase" >&2; exit 1
fi
if [ "$contados" != "$vistos" ]; then
  echo "not yet: you counted $contados commands and the monitor saw $vistos" >&2; exit 1
fi
echo "EXERCISE OK: $contados commands, the same the command_monitor saw"
