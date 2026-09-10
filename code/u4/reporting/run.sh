#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# --coverage-user: measures the covergroups and leaves out line/toggle/branch,
# which are not the topic. The number comes out at the end, with cov_report.
#
# -Wno-fatal: the examples have sloppy widths on purpose (WIDTHEXPAND/WIDTHTRUNC)
# and by default any warning stops the build. They still get printed.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

# The scoreboard of this section adds wrong ON PURPOSE: it is the example
# reporting is taught with. Without this opt-out, run_sim would fail on the uvm_error
# the section wants to show.
export UVM_ERRORS_OK=1
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=random_test

# The same testbench with one line of difference: add_test overrides the tester
# through the factory, so every operation is an add. It is the second half of the
# factory lesson and until now nobody ran it -- a test that does not get run is a
# test that does not compile.
run_sim +UVM_TESTNAME=add_test
unset UVM_ERRORS_OK

# ...but "we tolerate the uvm_errors" cannot mean "we look at nothing". Without
# this, a disconnected scoreboard --the analysis port never connected, the write()
# that never gets called-- leaves the example just as green as it is now, and what
# the section came to show does not appear anywhere.
if ! grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG"; then
   echo "EXPECTED the deliberately broken scoreboard to report [SCOREBOARD]" >&2
   exit 1
fi
cov_report
