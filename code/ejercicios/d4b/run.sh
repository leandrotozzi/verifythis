#!/bin/bash
# Day 4 exercise, second one (put and get section). It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#
# The TB is the whole one from the put and get section with ONE line changed: the
# FIFO of env.svh comes unbounded. Nobody blocks the tester any more, so it
# empties its thousand commands at t = 0, waits the #500 it always waited, drops
# the objection, and the simulation ends with the bus half empty -- in green.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
# The exercise is solved in driver.svh and only there. The unbounded FIFO is the
# DUT of this exercise: putting the ceiling back is not fixing it, it is hiding it.
intocables
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f

falta() { echo; echo "not yet: $1" >&2; exit 1; }

# The command_monitor reports at UVM_HIGH: without raising the ceiling its lines
# do not reach the log. It is the same flag as the previous exercise.
run_sim +UVM_TESTNAME=random_test +UVM_VERBOSITY=UVM_HIGH

# What is counted is what WENT OUT ON THE BUS, not what was put in the FIFO: the
# command_monitor watches the wires, and it is the file this exercise does not touch.
vistos=$(grep -c '^UVM_INFO.*\[COMMAND MONITOR\]' "$VLT_LOG" || true)
fin=$(awk '/\$finish at/ {for (i = 1; i < NF; i++) if ($i == "at") { sub(/[;,]$/, "", $(i + 1)); print $(i + 1) }}' "$VLT_LOG" | tail -1)

if [ "$vistos" -lt 1000 ]; then
   falta "the bus saw $vistos commands and the tester put a thousand in.
    The rest were left in the FIFO when the simulation ended, and UVM said PASS:
    that is the whole point of the exercise. The #500 of base_tester.svh is a
    patch --it was already one with the bounded FIFO-- and it is not the fix.
    Whoever knows when the bus is done is the driver, not the tester."
fi
echo "EXERCISE OK: the $vistos commands went out on the bus, and the phase ended when"
echo "              the last one did (at t=$fin, not at the tester's #500)"
