#!/bin/bash
# Ejercicio del dia 6 (seccion Sequences) -- cerrar un bin. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tu archivo
#   SOLUCION=1 bash run.sh   con el de solucion/, para comparar
#
# Corre DOS veces el mismo test:
#   1. con +SIN_CIERRE  -> solo reset + 60 al azar. Es la cobertura de partida.
#   2. sin el           -> lo mismo, mas tu caso dirigido.
#
# La semilla esta fijada a proposito: con la 7, las 60 operaciones al azar NO
# tocan el bin FF x FF en mul_op, asi que el ejercicio es el mismo siempre. Sin
# fijarla, algunas corridas te lo llenarian solas y no habria nada que cerrar.
# (Si cambia el DUT o el estimulo, hay que volver a elegirla: probar seeds hasta
# que la corrida con +SIN_CIERRE deje el bin abierto.)
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f

export SEED=7
falta() { echo "todavia no: $1" >&2; exit 1; }

# El enunciado pide el caso dirigido PEDIDO, no asignado. Asignando los tres
# campos a mano tambien se cierra el bin -- lo hace maxmult_sequence del u7/sequences --
# pero entonces no se practica ni el with{} ni el agujero del dist, que son el
# tema. Es lo unico que este corrector mira en tu archivo.
grep -q 'randomize()' "${SOLUCION:+solucion/}cierre_sequence.svh" ||
  falta "tu cierre_sequence no llama a randomize(): el enunciado pide el caso
    dirigido con randomize() with {}, no asignando A, B y op a mano."

cg() { verilator_coverage "$1" 2>/dev/null | sed -nE 's/.*covergroup *: *([0-9.]+)% *\( *([0-9]+)\/.*/\2 \1/p'; }

echo "=== 1) sin tu caso dirigido: 60 operaciones al azar ==="
run_sim +UVM_TESTNAME=cierre_test +UVM_TIMEOUT=500000,YES +SIN_CIERRE > /dev/null
ANTES=$VLT_OBJ/cov.$VLT_RUN.dat
read -r bins_antes pct_antes <<< "$(cg "$ANTES")"
echo "    cobertura: $pct_antes%  ($bins_antes bins)"

echo "=== 2) con tu cierre_sequence ==="
run_sim +UVM_TESTNAME=cierre_test +UVM_TIMEOUT=500000,YES || true
DESPUES=$VLT_OBJ/cov.$VLT_RUN.dat
read -r bins_despues pct_despues <<< "$(cg "$DESPUES")"
echo "    cobertura: $pct_despues%  ($bins_despues bins)"

grep -q "\[PH_TIMEOUT\]" "$VLT_LOG" &&
  falta "la simulacion dejo de avanzar: te falto el finish_item()"

maxmul=$(sed -nE 's/.*\[CHEQUEO\].*maxmul=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)
[ -n "$maxmul" ] || falta "el corrector no llego a reportar: mira el log de arriba"

if [ "$maxmul" -lt 1 ]; then
  falta "por el bus no paso ni una FF x FF en mul_op.
    Si randomize() te devolvio 0, es el agujero del dist: con la constraint de
    reparto activa, Verilator elige el valor ANTES de mirar tu with. Apagala
    para este objeto -- una linea, y esta en la seccion Constrained random."
fi
[ "$bins_despues" -gt "$bins_antes" ] ||
  falta "la cobertura no subio: $bins_antes bins antes, $bins_despues despues"

uvm_summary_ok "$VLT_LOG" || falta "el Report Summary cuenta errores"

echo "EJERCICIO OK: el bin se cerro -- $pct_antes% ($bins_antes bins) -> $pct_despues% ($bins_despues bins), con una transaction"
