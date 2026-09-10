#!/bin/bash
# Day 2 exercise. It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the "A testbench without a single module" section;
# from here come the package, your mult_tester and the testbench class, which come
# first thanks to the +incdir order.
#
# If the scoreboard finds a mismatch, Verilator's $error aborts the
# simulation: there is nothing to check here.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
# chequeo.svh is bound into the top and grades from outside: what it counts comes
# off the BFM and out of calling get_op() itself, and not out of the $display of
# the tester -- which is one of the files this exercise edits. See intocables.sha.
intocables
INC=${SOLUCION:+ +incdir+solucion}
vlt top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f
run_sim

falta() { echo "not yet: $1" >&2; exit 1; }

read -r draws dispatch muls others <<< "$(sed -nE 's/.*\[CHEQUEO\] base_draws=([0-9]+) dispatch=([0-9]+) muls=([0-9]+) others=([0-9]+).*/\1 \2 \3 \4/p' "$VLT_LOG" | tail -1)"
[ -n "$others" ] || falta "the [CHEQUEO] line did not come out: look at the log above"

# The base draw has to stay the base draw. Rewriting tester::get_op() so that it
# returns mul_op also fills the bus with multiplications, and it is the opposite
# of the section: the point is that the DERIVED class decides.
[ "$draws" -gt 1 ] || falta "tester::get_op() no longer draws: through a base tester
    it answers one single operation. That method is the one that must NOT change --
    the exercise is to override it in mult_tester, not to rewrite it."

# And this is the lesson in one number: get_op() called THROUGH A tester HANDLE
# on the object the testbench installed. It comes out mul_op every time only if
# get_op() is virtual and tester_h is holding a mult_tester.
[ "$dispatch" = "1" ] || falta "asked through a tester handle, tester_h still answers
    $dispatch different operations. Two things have to be true for it to answer only
    mul_op: get_op() has to be virtual --the word missing in tester.svh-- and
    tester_h has to be holding a mult_tester (testbench.svh)."

[ "$others" -eq 0 ] || falta "$others operations that are not multiplications went
    through the bus: look at the [CHEQUEO] line above, it says which was the first."
[ "$muls" -ge 1000 ] || falta "only $muls multiplications went through the bus, and
    the loop sends a thousand."

echo "EXERCISE OK: $muls multiplications on the bus and not one other operation,"
echo "              with a base tester that goes on drawing $draws"
