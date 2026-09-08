#!/bin/bash
# Ejercicio del dia 6 (seccion Sequences). Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# El TB es el de la seccion Sequences entero; de aca salen el package, el env con el
# chequeo, y los dos archivos que tenes que escribir.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f

# +UVM_TIMEOUT es la red de seguridad del ejercicio. A una sequence a la que le
# falta el reset del principio o el finish_item() no le pasa nada malo: deja de
# avanzar, y sin esto el simulador giraria para siempre. 200000 es cien veces lo
# que tarda la solucion.
run_sim +UVM_TESTNAME=mult_test +UVM_TIMEOUT=200000,YES || true

falta() { echo "todavia no: $1" >&2; exit 1; }

if grep -q "\[INVTST\]" "$VLT_LOG"; then
  falta "todavia no existe la clase mult_test. Empeza por mult_test.svh."
fi
if grep -q "\[PH_TIMEOUT\]" "$VLT_LOG"; then
  falta "la simulacion dejo de avanzar. Dos causas, en orden de probabilidad:
    1) el primer item de tu sequence no es un rst_op, y sin reset el DUT nunca
       levanta done: el driver se queda esperando;
    2) te falto el finish_item() de alguno de los items."
fi

# Lo que dice tu sequence.
items=$(sed -nE 's/.*\[MULT SEQ\].*items=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)
tumax=$(sed -nE 's/.*\[MULT SEQ\].*max=([0-9]+).*/\1/p'   "$VLT_LOG" | tail -1)
# Lo que vio el bus. Esto no lo escribiste vos.
muls=$(sed -nE  's/.*\[CHEQUEO\].*muls=([0-9]+).*/\1/p'   "$VLT_LOG" | tail -1)
otras=$(sed -nE 's/.*\[CHEQUEO\].*otras=([0-9]+).*/\1/p'  "$VLT_LOG" | tail -1)
busmax=$(sed -nE 's/.*\[CHEQUEO\].*max=([0-9]+).*/\1/p'   "$VLT_LOG" | tail -1)

[ -n "$items" ] ||
  falta "tu sequence no imprimio la linea 'items=<n> max=<m>' con UVM_NONE"
[ "$otras" = "0" ] ||
  falta "pasaron $otras operaciones que no son multiplicaciones por el bus"
[ "$muls" -ge 20 ] ||
  falta "el bus vio $muls multiplicaciones y hacen falta 20"
[ "$items" = "$muls" ] ||
  falta "contaste $items items y por el bus pasaron $muls"
[ "$tumax" = "$busmax" ] ||
  falta "tu max es $tumax y el del bus es $busmax: fijate si estas leyendo
    command.result DESPUES de que volvio finish_item()"

uvm_summary_ok "$VLT_LOG" ||
  falta "el Report Summary cuenta errores: mira el log de arriba"

echo "EJERCICIO OK: $items multiplicaciones, max=$tumax, igual que lo que vio el bus"
