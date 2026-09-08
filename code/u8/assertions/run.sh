#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
#
# El testbench es el de la seccion Sequences sin tocar una clase: lo unico que cambia es
# que la BFM ahora trae un bloque de assertions. Dos corridas:
#
#   full_test           el DUT sano: 0 UVM_ERROR, las tres assertions callan
#   full_test +BUG=1    la BFM cambia B a mitad de la multiplicacion. El
#                       RESULTADO no cambia --el multiplicador ya latcheo los
#                       operandos-- asi que el scoreboard sigue en verde y el
#                       unico que ve el bug es a_operandos_estables.
#
# --assert es lo que prende las concurrentes. Sin ese flag compilan, no corren,
# y todo "pasa": es la trampa muda de la seccion.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --assert --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=full_test

# La corrida con el bug: los uvm_error son los que la seccion quiere mostrar.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=full_test +BUG=1

if ! grep -q 'UVM_ERROR.*\[SVA\]' "$VLT_LOG"; then
   echo "ESPERABA que a_operandos_estables disparara con +BUG=1" >&2; exit 1
fi
# Y el scoreboard tiene que haber seguido en verde: esa es la seccion entera.
if grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
   echo "el scoreboard tambien fallo: el bug dejo de ser ciego" >&2; exit 1
fi
echo "    el scoreboard no vio nada: al bug lo caza la assertion, y nadie mas"

cov_report
