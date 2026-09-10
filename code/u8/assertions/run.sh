#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# The testbench is the Sequences section's without touching a class: the only thing that changes is
# that the BFM now carries an assertions block. Two runs:
#
#   full_test           the healthy DUT: 0 UVM_ERROR, the four assertions stay quiet
#   full_test +BUG=1    the BFM changes B halfway through the multiplication. The
#                       RESULT does not change --the multiplier already latched the
#                       operands-- so the scoreboard stays green and the
#                       only one that sees the bug is a_operandos_estables.
#
# --assert is what turns the concurrent ones on. Without that flag they compile, they do not run,
# and everything "passes": it is the silent trap of the section.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --assert --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=full_test

# The run with the bug: the uvm_error are the ones the section wants to show.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=full_test +BUG=1

if ! grep -q 'UVM_ERROR.*\[SVA\]' "$VLT_LOG"; then
   echo "EXPECTED a_operandos_estables to fire with +BUG=1" >&2; exit 1
fi
# And the scoreboard has to have stayed green: that is the whole section.
if grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
   echo "the scoreboard failed too: the bug stopped being blind" >&2; exit 1
fi
echo "    the scoreboard saw nothing: the bug is caught by the assertion, nobody else"

cov_report
