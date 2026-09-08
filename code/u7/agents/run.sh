#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
#
# Dos VTALU: una la maneja el agent activo, la otra vtalu_tester_module y la
# mira un agent pasivo. Un solo test.
#
# +TOPOLOGY imprime el arbol de componentes de UVM. Es la forma de VER que el
# agent pasivo no construyo ni sequencer ni driver:
#
#   bash run.sh +TOPOLOGY
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=dual_test "$@"
cov_report
