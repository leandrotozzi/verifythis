#!/bin/bash
# Virtual sequences, with BOTH agents driving.
#
# The testbench is the whole one from the Sequences section: the +incdir below bring it in by
# reference and this directory only puts in what changes. See docs/verilator.md.
#
#   virtual_test   reset of both ALUs in parallel, coordinated traffic, and the
#                  result of one as the operand of the other
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"

# The order of the incdir is what decides: the ones from here first, and that is why the
# env.svh of this directory beats the section's. And ".." does NOT go in the list:
# Verilator also looks in the incdir for the files on the command line, and
# would bring in the section's vtalu_pkg.sv instead of this one.
vlt_uvm top --coverage-user -Wno-fatal \
  +incdir+./tb_classes +incdir+../tb_classes \
  ../../../vtalu_dut/vtalu_1c.sv \
  ../../../vtalu_dut/vtalu_mult.sv \
  ../../../vtalu_dut/vtalu.sv \
  ./vtalu_pkg.sv ../vtalu_bfm.sv ./top.sv

run_sim +UVM_TESTNAME=virtual_test
cov_report
