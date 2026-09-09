#!/bin/bash
# The reference model in C, through DPI. See docs/verilator.md.
#
# It is the sequences testbench with ONE difference: the scoreboard does not predict in
# SystemVerilog, it asks vtalu_golden.c. Verilator compiles to C++, so
# the model gets linked inside the simulation -- there is no socket and no separate
# process.
#
#   full_test               the healthy DUT against the healthy model: 0 UVM_ERROR
#   full_test +GOLDEN_BUG   the same DUT against a MUTATED model: it has to
#                           scream. A scoreboard that never saw an error is not
#                           tested, and through DPI the mutation is one line of C.
#
# The .c goes on the verilator line as one more source: there is no DPI flag.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f vtalu_golden.c
run_sim +UVM_TESTNAME=full_test
run_sim +UVM_TESTNAME=fibonacci_test

# The mutation: the C model truncates the multiplication to 8 bits. The DUT is still
# fine; the one lying now is the golden model, and the scoreboard has to
# see it. If it does NOT scream, the testbench is comparing against itself.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=full_test +GOLDEN_BUG
if ! grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
   echo "EXPECTED the scoreboard to scream with the mutated model" >&2; exit 1
fi
unset UVM_ERRORS_OK
echo "    the scoreboard catches the model mutation: the DPI path is alive"

cov_report
