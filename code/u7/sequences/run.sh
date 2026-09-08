#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
#
# Cinco tests sobre EL MISMO testbench: lo unico que cambia entre uno y otro es
# la sequence. Esa es la seccion.
#
#   full_test          reset + 1000 al azar + la multiplicacion dirigida
#   fibonacci_test     estimulo que depende del resultado anterior
#   default_seq_test   la misma sequence, arrancada por config_db
#   add_test           el override de la factory, sin tocar una sequence
#   no_objection_test  la TRAMPA: pasa en t=0 sin mandar nada. Ver la slide.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=full_test
run_sim +UVM_TESTNAME=fibonacci_test
run_sim +UVM_TESTNAME=default_seq_test
run_sim +UVM_TESTNAME=add_test
run_sim +UVM_TESTNAME=no_objection_test
cov_report
