#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# Five tests over THE SAME testbench: the only thing that changes between one and the next is
# the sequence. That is the section.
#
#   full_test          reset + 1000 random ones + the directed multiplication
#   fibonacci_test     stimulus that depends on the previous result
#   default_seq_test   the same sequence, started by config_db
#   add_test           the factory override, without touching a sequence
#   no_objection_test  the TRAP: it passes at t=0 without sending anything. See the slide.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=full_test
run_sim +UVM_TESTNAME=fibonacci_test
run_sim +UVM_TESTNAME=default_seq_test
run_sim +UVM_TESTNAME=add_test
run_sim +UVM_TESTNAME=no_objection_test
cov_report
