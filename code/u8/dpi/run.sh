#!/bin/bash
# El modelo de referencia en C, por DPI. Ver docs/verilator.md.
#
# Es el testbench de las sequences con UNA diferencia: el scoreboard no predice en
# SystemVerilog, le pregunta a vtalu_golden.c. Verilator compila a C++, asi que
# el modelo se enlaza adentro de la simulacion -- no hay socket ni proceso
# aparte.
#
#   full_test               el DUT sano contra el modelo sano: 0 UVM_ERROR
#   full_test +GOLDEN_BUG   el mismo DUT contra un modelo MUTADO: tiene que
#                           gritar. Un scoreboard que nunca vio un error no
#                           esta probado, y por DPI la mutacion es una linea de C.
#
# El .c va en la linea de verilator como un fuente mas: no hay flag de DPI.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f vtalu_golden.c
run_sim +UVM_TESTNAME=full_test
run_sim +UVM_TESTNAME=fibonacci_test

# La mutacion: el modelo de C trunca la multiplicacion a 8 bits. El DUT sigue
# bien; el que miente ahora es el golden model, y el scoreboard tiene que
# verlo. Si NO grita, el testbench esta comparando contra si mismo.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=full_test +GOLDEN_BUG
if ! grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
   echo "ESPERABA que el scoreboard gritara con el modelo mutado" >&2; exit 1
fi
unset UVM_ERRORS_OK
echo "    el scoreboard caza la mutacion del modelo: el camino de DPI esta vivo"

cov_report
