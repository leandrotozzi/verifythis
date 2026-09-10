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
# env.svh is NOT on the list: this exercise is edited there. What is on it is
# the scaffolding that makes the cross-check mean something -- the command_monitor
# the grading counts comes from u5 through tb.f. See intocables.sha.
intocables
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f
# The command_monitor reports with `uvm_info at UVM_HIGH, so the verbosity
# ceiling has to be raised for its lines to show up in the log. That is the
# Reporting section's topic; here it is enough to know that without the flag they are invisible.
run_sim +UVM_TESTNAME=random_test +UVM_VERBOSITY=UVM_HIGH || true

falta() { echo "not yet: $1" >&2; exit 1; }

# The grading is cross-checked TWICE, and neither number comes out of a file this
# exercise edits.
#
#   commands=       against the lines the command_monitor printed. It comes from
#                   u5 and you do not write it.
#   multiplications= against what chequeo.sv counted off the bus. That one is the
#                   important one: commands are always a thousand, so a
#                   report_phase printing the literal "commands=1000" passed
#                   without counting anything. The multiplications move with the
#                   seed, and there is no way to know how many there were other
#                   than counting them.
#
# The ^UVM_INFO is not decorative: without it, the grep also counts the line
# "[COMMAND MONITOR]  1000" of the Report Summary and gives one too many.
vistos=$(grep -c '^UVM_INFO.*\[COMMAND MONITOR\]' "$VLT_LOG" || true)
contados=$(sed -nE 's/.*OP_COUNTER.*commands=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)
muls_tb=$(sed -nE 's/.*OP_COUNTER.*multiplications=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)
muls_bus=$(sed -nE 's/.*\[CHEQUEO\] muls=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)

[ -n "$muls_bus" ] || falta "the [CHEQUEO] line did not come out: look at the log above"
[ -n "$contados" ] || falta "op_counter printed nothing in report_phase"
[ "$contados" = "$vistos" ] ||
  falta "you counted $contados commands and the monitor saw $vistos"
[ -n "$muls_tb" ] ||
  falta "op_counter reports the commands and not the multiplications. The line the
    README asks for has the two numbers: commands= and multiplications=."
[ "$muls_tb" = "$muls_bus" ] ||
  falta "you counted $muls_tb multiplications and $muls_bus went through the bus."

echo "EXERCISE OK: $contados commands --the same the command_monitor saw-- and"
echo "              $muls_tb multiplications, the same that went through the bus"
