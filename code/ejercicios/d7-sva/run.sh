#!/bin/bash
# Ejercicio del dia 7 (seccion Assertions). Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# El TB es el de la seccion Assertions entero. De aca salen dos archivos: el modulo
# heredado que viola el protocolo --que NO hay que tocar-- y la BFM, que es
# donde va la property.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

# --assert es lo que prende las properties concurrentes. Sin el flag compilan,
# no corren, y todo "pasa".
vlt_uvm top --assert --coverage-user -Wno-fatal \
  -f dut.f -f tb.f "${SOLUCION:+solucion/}vtalu_bfm.sv"

# Los uvm_error que se buscan son justamente el resultado del ejercicio.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=full_test

falta() { echo "todavia no: $1" >&2; exit 1; }

# Los dos numeros salen del %m del mensaje: cada BFM dice quien es.
modulo=$(grep -c 'UVM_ERROR.*\[SVA\].*modulo_bfm' "$VLT_LOG" || true)
clase=$(grep -c  'UVM_ERROR.*\[SVA\].*clase_bfm'  "$VLT_LOG" || true)

if [ "$modulo" -eq 0 ]; then
  falta "ninguna assertion disparo sobre modulo_bfm, que es la que maneja el
    modulo heredado. O todavia no escribiste la property, o su antecedente no
    ocurre nunca: agregale un cover property y fijate si se cubre."
fi
if [ "$clase" -gt 0 ]; then
  falta "tu property disparo $clase veces sobre clase_bfm, que es la que maneja
    el driver del agent y respeta el protocolo. Son falsos positivos, y el
    culpable es el FLANCO con el que muestreas: la BFM escribe en negedge."
fi
# Y el scoreboard tiene que haber seguido en verde: si el bug tambien corrompe
# el resultado, deja de ser un bug ciego y el ejercicio pierde el sentido.
if grep -q 'UVM_ERROR.*\[SELF CHECKER\]' "$VLT_LOG"; then
  falta "el scoreboard esta reportando errores. No deberia: revisa que no hayas
    tocado vtalu_tester_module.sv."
fi

echo "EJERCICIO OK: la assertion caza $modulo violaciones del modulo heredado,"
echo "              0 falsos positivos sobre el agent, y el scoreboard sigue en verde"
