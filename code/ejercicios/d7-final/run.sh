#!/bin/bash
# El capstone del dia 7. Falla hasta que lo resolvas, y te dice en que etapa.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# A diferencia de los otros doce ejercicios, aca no hay un archivo con un
# agujero: hay un DUT, una spec y nada mas. El corrector va por etapas y cada
# una imprime su ETAPA N OK, asi que se puede terminar de a una.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

PFX=${SOLUCION:+solucion/}

falta() { echo; echo "todavia no: $1" >&2; exit 1; }

for f in apb_if.sv apb_pkg.sv; do
   [ -f "$PFX$f" ] && continue
   falta "no existe $PFX$f. Empeza por ahi: la interface con los pines de
    spec.md y el package que incluye tus clases. La lista de entregables, en
    orden, esta en el README."
done

vlt_uvm top --coverage-user -Wno-fatal \
   +incdir+"${PFX}tb_classes" \
   rtl/apb_regs.sv "${PFX}apb_pkg.sv" "${PFX}apb_if.sv" apb_stim_module.sv top.sv

# --- Etapa 1: el monitor ------------------------------------------------------
# El modulo de siempre hace OCHO transferencias y tu monitor tiene que verlas
# todas. Sin driver, sin scoreboard, sin cobertura: solo ver.
run_sim +UVM_TESTNAME=monitor_test +STIM || falta "monitor_test no llego al final"
vistas=$(grep -c 'UVM_INFO.*\[MONITOR\]' "$VLT_LOG" || true)
if [ "$vistas" -ne 8 ]; then
   falta "tu monitor reporto $vistas transferencias y el modulo de siempre hace 8.
    Si son 0, revisa que el agent del bus stim_bfm sea PASIVO y que el monitor
    se enganche solo (bfm.monitor_h = this en el build_phase). Si son mas de 8,
    estas reportando ciclos en vez de transferencias: una transferencia termina
    en el flanco en que PREADY esta alto, y una lectura dura dos."
fi
echo "ETAPA 1 OK: el monitor ve las 8 transferencias del modulo de siempre"

# --- Etapa 2: el driver -------------------------------------------------------
run_sim +UVM_TESTNAME=smoke_test || falta "smoke_test termino con UVM_ERROR"
for patron in 'WR @0x00' 'RD @0x00' 'WR @0x04' 'RD @0x04' 'RD @0x08' 'RD @0x0c'; do
   grep -qi "$patron" "$VLT_LOG" || falta "en smoke_test no aparece ninguna transferencia
    '$patron'. La sequence dirigida tiene que escribir y leer los cuatro
    registros: es la fila 1 del plan de verificacion."
done
echo "ETAPA 2 OK: el driver maneja el bus y la sequence dirigida pasa"

# --- Etapa 3: el scoreboard ---------------------------------------------------
run_sim +UVM_TESTNAME=random_test || falta "random_test termino con UVM_ERROR.
    El DUT esta sano: el que se equivoca es tu modelo. Las cuatro trampas estan
    juntas en la seccion 'La letra chica' de spec.md."
echo "    ...y ahora el mismo test contra el DUT con el bug"

# Un scoreboard que nunca vio un error no esta probado. +BUG=1 le saca al DUT el
# gate de CTRL.EN: el acumulador suma siempre.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=random_test +BUG=1
if ! grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG"; then
   falta "con +BUG=1 el DUT acumula aunque CTRL.EN este en 0, y tu scoreboard no
    dijo nada. O no modela EN, o no lee ACC nunca: fijate la fila 5 del plan de
    verificacion."
fi
unset UVM_ERRORS_OK
echo "ETAPA 3 OK: el scoreboard cierra en verde y caza el bug de +BUG=1"

# --- Etapa 4: la cobertura ----------------------------------------------------
cov=$(cov_report | tee /dev/stderr | awk '/covergroup/ {print}')
[ -n "$cov" ] || falta "no se genero cobertura de covergroup. Falta el componente
    de cobertura colgado del analysis port, o el covergroup no se muestrea."
puntos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\2/p')
llenos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\1/p')
if [ "${puntos:-0}" -lt 20 ]; then
   falta "tu covergroup tiene ${puntos:-0} puntos y el plan de verificacion de
    spec.md tiene siete filas: con el cross de direccion por sentido solo, ya
    son mas de veinte."
fi
if [ "$((llenos * 100 / puntos))" -lt 90 ]; then
   falta "cobertura $llenos/$puntos. Mira que bin quedo en cero y escribi el
    estimulo que lo llena -- es el ciclo de coverage closure del dia 6."
fi
echo "ETAPA 4 OK: cobertura $llenos/$puntos"

echo
echo "EJERCICIO OK: monitor, driver, scoreboard y cobertura. Eso es un testbench."
