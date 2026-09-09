#!/bin/bash
# Day 6 exercise -- three planted bugs. It fails until you find them.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the sequences section and it works. Three of its
# files were copied here with one bug each, and the three fail in a DIFFERENT way:
#
#   1. it hangs                 driver.svh
#   2. it ends at t=0 in green   default_seq_test.svh
#   3. it lies in green          random_sequence.svh
#
# The checker says which of the three is still broken, and nothing else: which
# line it is, is the exercise.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
intocables
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f

falta() { echo; echo "not yet: $1" >&2; exit 1; }

# --- 1: the one that hangs ----------------------------------------------------
# +UVM_TIMEOUT so the exercise does not have to be killed with Ctrl-C: without
# a ceiling, a testbench that hangs hangs the CI too.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=full_test +UVM_TIMEOUT=2000000,YES
unset UVM_ERRORS_OK
if grep -q '\[PH_TIMEOUT\]' "$VLT_LOG"; then
   falta "BUG 1: full_test does not end. The phase died on the timeout with the
    sequence still blocked. Nobody is unblocking the finish_item(), and the one
    who has to is the driver: the sequences handshake has TWO calls."
fi
uvm_summary_ok "$VLT_LOG" || falta "BUG 1: full_test ends, but with UVM_ERROR.
    Look at what the scoreboard reports before going after the other two."
echo "STAGE 1 OK: full_test ends on its own, and in green"

# --- 2: the one that ends at t=0 ----------------------------------------------
# What is counted is what WENT OUT ON THE BUS the testbench drives, which is what
# a test that ends at t=0 does not have: it reports no errors because it did not
# send anything.
run_sim +UVM_TESTNAME=default_seq_test +UVM_VERBOSITY=UVM_HIGH
mandados=$(grep -c 'clase_agent_h.command_monitor_h .*\[COMMAND MONITOR\]' "$VLT_LOG" || true)
if [ "$mandados" -lt 100 ]; then
   falta "BUG 2: default_seq_test sent $mandados commands and its sequence has 200.
    It ends in green because it has nothing to complain about: a sequence started by
    config_db does not run inside any run_phase, so nobody raises the objection for
    it and the phase ends at t=0. There is one line for that."
fi
echo "STAGE 2 OK: default_seq_test sent its $mandados commands"

# --- 3: the one that lies in green --------------------------------------------
# add_test asks the factory for an add_transaction, so EVERY command has to be an
# add. This is the only check that reads what went out on the bus instead of
# whether the run ended.
# Only the agent the testbench drives: the other bus belongs to the legacy module,
# which sends its own random operations and has nothing to do with this.
# The mul_op is expected -- it is the directed maxmult_sequence, which does not
# randomize and therefore does not go through the constraint either.
run_sim +UVM_TESTNAME=add_test +UVM_VERBOSITY=UVM_HIGH
mias=$(grep 'clase_agent_h.command_monitor_h .*\[COMMAND MONITOR\]' "$VLT_LOG" || true)
sumas=$(echo "$mias" | grep -c 'op: add_op' || true)
otras=$(echo "$mias" | grep -vc 'op: add_op\|op: mul_op' || true)
if [ "$otras" -gt 0 ]; then
   falta "BUG 3: add_test let $otras operations through that are not adds ($sumas are).
    It closes green and the coverage even goes up, but the override never applied.
    The factory only hands back another type to whoever ASKS IT for the object."
fi
[ "$sumas" -gt 900 ] || falta "BUG 3: add_test sent $sumas adds and there are a
    thousand of them. Check that stage 1 and stage 2 are still passing."
echo "STAGE 3 OK: with add_test the $sumas random commands are adds, and not one is not"

echo
echo "EXERCISE OK: one that hangs, one that ends at t=0 and one that lies in green."
echo "             The three fail differently, and none of them fails by itself."
