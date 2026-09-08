#!/bin/bash
# Ejercicio del dia 2. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# El TB es el de la seccion Un testbench sin un solo modulo entero; de aca salen el package, tu mult_tester y
# la clase testbench, que se cuelan primero por el orden de los +incdir.
#
# Si el scoreboard encuentra una diferencia, el $error de Verilator aborta la
# simulacion: no hace falta chequearlo aca.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f
run_sim

if [ "$(grep -c ' mul_op ' "$VLT_LOG")" -lt 1000 ]; then
  echo "todavia no: el loop tiene que mandar 1000 multiplicaciones" >&2; exit 1
fi
if grep -qE ' (no_op|add_op|and_op|xor_op) ' "$VLT_LOG"; then
  echo "todavia no: siguen saliendo operaciones que no son mul_op" >&2; exit 1
fi
echo "EJERCICIO OK: 1000 multiplicaciones y ni una diferencia"
