#!/bin/bash
# Day 6 exercise (Sequences section). It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the Sequences section; from here come the package, the env with the
# checker, and the two files you have to write.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f

# +UVM_TIMEOUT is the exercise's safety net. Nothing bad happens to a sequence
# missing the reset at the start or the finish_item(): it just stops
# advancing, and without this the simulator would spin forever. 200000 is a hundred times
# what the solution takes.
run_sim +UVM_TESTNAME=mult_test +UVM_TIMEOUT=200000,YES || true

falta() { echo "not yet: $1" >&2; exit 1; }

if grep -q "\[INVTST\]" "$VLT_LOG"; then
  falta "there is no mult_test class yet. Start with mult_test.svh."
fi
if grep -q "\[PH_TIMEOUT\]" "$VLT_LOG"; then
  falta "the simulation stopped advancing. Two causes, in order of likelihood:
    1) the first item of your sequence is not a rst_op, and without a reset the DUT never
       levanta done: el driver se queda esperando;
    2) you are missing the finish_item() of one of the items."
fi

# What your sequence says.
items=$(sed -nE 's/.*\[MULT SEQ\].*items=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)
tumax=$(sed -nE 's/.*\[MULT SEQ\].*max=([0-9]+).*/\1/p'   "$VLT_LOG" | tail -1)
# What the bus saw. You did not write this one.
muls=$(sed -nE  's/.*\[CHEQUEO\].*muls=([0-9]+).*/\1/p'   "$VLT_LOG" | tail -1)
otras=$(sed -nE 's/.*\[CHEQUEO\].*otras=([0-9]+).*/\1/p'  "$VLT_LOG" | tail -1)
busmax=$(sed -nE 's/.*\[CHEQUEO\].*max=([0-9]+).*/\1/p'   "$VLT_LOG" | tail -1)

[ -n "$items" ] ||
  falta "your sequence did not print the line 'items=<n> max=<m>' with UVM_NONE"
[ "$otras" = "0" ] ||
  falta "$otras operations that are not multiplications went through the bus"
[ "$muls" -ge 20 ] ||
  falta "the bus saw $muls multiplications and 20 are needed"
[ "$items" = "$muls" ] ||
  falta "you counted $items items and $muls went through the bus"
[ "$tumax" = "$busmax" ] ||
  falta "your max is $tumax and the bus one is $busmax: check whether you are reading
    command.result DESPUES de que volvio finish_item()"

uvm_summary_ok "$VLT_LOG" ||
  falta "the Report Summary counts errors: look at the log above"

echo "EXERCISE OK: $items multiplications, max=$tumax, the same the bus saw"
