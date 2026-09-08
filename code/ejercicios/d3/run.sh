#!/bin/bash
# Ejercicio del dia 3. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# El TB es el de la seccion El env entero; de aca salen el package, el env con el
# chequeo, y los dos archivos que tenes que escribir.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f
run_sim +UVM_TESTNAME=mult_test
cov_report
grep -q "EJERCICIO OK" "$VLT_LOG" ||
  { echo "todavia no: mira los UVM_ERROR de arriba y el README" >&2; exit 1; }
