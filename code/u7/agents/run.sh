#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# Two VTALUs: one is driven by the active agent, the other by vtalu_tester_module and
# watched by a passive agent. A single test.
#
# +TOPOLOGY prints the UVM component tree. It is how to SEE that the
# passive agent built neither a sequencer nor a driver:
#
#   bash run.sh +TOPOLOGY
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=dual_test "$@"
cov_report
