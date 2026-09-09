#!/bin/bash
# Day 8 exercise (DPI section). It fails until you solve it.
#
#   bash run.sh              with your file
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#
# The TB is the whole one from the DPI section and nothing in it gets touched. The only
# file of this exercise is vtalu_golden.c: the reference model the scoreboard
# asks instead of predicting in SystemVerilog.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
intocables
PFX=${SOLUCION:+solucion/}

falta() { echo; echo "not yet: $1" >&2; exit 1; }

# Your .c and the solution's share a basename, so the object Verilator generates
# is called the same for both and its makefile would reuse whichever was compiled
# last. It gets deleted before building: switching between the two has to
# recompile. It is one file, so it costs a second.
rm -f obj_dir/top/vtalu_golden.o

# The .c goes on the verilator line as one more source: there is no DPI flag.
vlt_uvm top -Wno-fatal -f dut.f -f tb.f "${PFX}vtalu_golden.c"

# --- 1: the healthy DUT against your model ------------------------------------
run_sim +UVM_TESTNAME=full_test || falta "full_test ended with UVM_ERROR against the
    HEALTHY DUT: the one lying is your model. If the failures are sub_op, check the
    borrow -- it goes out through *ovf, and the scoreboard compares it."
echo "STAGE 1 OK: your model matches the healthy DUT"

# --- 2: the mutated DUT -------------------------------------------------------
# The proof that the scoreboard really asks the C: with the DUT's bit 0 flipped,
# the comparison has to break. A model that answers anything at all would pass
# stage 1 by accident; this one it cannot pass.
export UVM_ERRORS_OK=1 VTALU_BUG=1
run_sim +UVM_TESTNAME=full_test
unset VTALU_BUG
if ! grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
   unset UVM_ERRORS_OK
   falta "with VTALU_BUG=1 the DUT flips bit 0 of the result and your model said
    nothing. Either it is returning a constant, or the operations that got mutated
    are the ones you left at zero."
fi
echo "STAGE 2 OK: the scoreboard catches the DUT mutation through the C model"

# --- 3: the mutation of the MODEL ---------------------------------------------
run_sim +UVM_TESTNAME=full_test +GOLDEN_BUG
unset UVM_ERRORS_OK
if ! grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
   falta "with +GOLDEN_BUG your model has to LIE and the scoreboard has to catch it,
    and nothing was reported. vtalu_golden_bug() leaves 'mutar' at 1 and nobody
    reads it: the multiplication has to look at it. Without that hook there is no
    way of telling a model that is being asked from one that is not."
fi
echo "STAGE 3 OK: with +GOLDEN_BUG the model lies and the scoreboard catches it"

echo
echo "EXERCISE OK: the reference model in C, and the two mutations that prove it"
echo "             is really the one answering"
