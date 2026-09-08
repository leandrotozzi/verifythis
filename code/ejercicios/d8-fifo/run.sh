#!/bin/bash
# El SEGUNDO capstone: una FIFO con backpressure. Falla hasta que lo resolvas,
# y te dice en que etapa.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# Es el hermano del d7-final y se hace despues. Lo que cambia no es el
# protocolo -- este es mas simple -- sino el SCOREBOARD: el del APB podia ser
# una tabla direccion/valor, y este no puede. Una FIFO tiene orden y ocupacion,
# y las dos hay que modelarlas.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

PFX=${SOLUCION:+solucion/}

falta() { echo; echo "todavia no: $1" >&2; exit 1; }

for f in fifo_if.sv fifo_pkg.sv; do
   [ -f "$PFX$f" ] && continue
   falta "no existe $PFX$f. Empeza por ahi: la interface con los pines de
    spec.md y el package que incluye tus clases. La lista de entregables, en
    orden, esta en el README."
done

vlt_uvm top --coverage-user -Wno-fatal \
   +incdir+"${PFX}tb_classes" \
   rtl/sync_fifo.sv "${PFX}fifo_pkg.sv" "${PFX}fifo_if.sv" fifo_stim_module.sv top.sv

# --- Etapa 1: el monitor ------------------------------------------------------
# El modulo de siempre hace DOCE ciclos con actividad y tu monitor tiene que
# verlos todos. Sin driver, sin scoreboard, sin cobertura: solo ver.
run_sim +UVM_TESTNAME=monitor_test +STIM || falta "monitor_test no llego al final"
vistos=$(grep -c 'UVM_INFO.*\[MONITOR\]' "$VLT_LOG" || true)
if [ "$vistos" -ne 12 ]; then
   falta "tu monitor reporto $vistos ciclos con actividad y el modulo de siempre
    hace 12. Si son 0, revisa que el agent del stim_bfm sea PASIVO y que el
    monitor se enganche solo (bfm.monitor_h = this en el build_phase). Si son
    muchos mas, estas publicando TODOS los flancos: un ciclo sin wr_en ni rd_en
    no es actividad."
fi
echo "ETAPA 1 OK: el monitor ve los 12 ciclos del modulo de siempre"

# --- Etapa 2: el driver -------------------------------------------------------
run_sim +UVM_TESTNAME=smoke_test || falta "smoke_test termino con UVM_ERROR"
if ! grep -qi 'full=1' "$VLT_LOG"; then
   falta "en smoke_test la FIFO nunca llego a full=1. La sequence dirigida tiene
    que llenarla hasta el tope y pasarse: es la fila 2 del plan de
    verificacion, y es donde vive media spec."
fi
if ! grep -qi 'empty=1' "$VLT_LOG"; then
   falta "en smoke_test la FIFO nunca llego a empty=1. Despues de llenarla hay
    que vaciarla, y leer una vez de mas."
fi
echo "ETAPA 2 OK: el driver maneja la FIFO y toca los dos bordes"

# --- Etapa 3: el scoreboard ---------------------------------------------------
run_sim +UVM_TESTNAME=random_test || falta "random_test termino con UVM_ERROR.
    El DUT esta sano: el que se equivoca es tu modelo. Las cuatro trampas estan
    juntas en la seccion 'La letra chica' de spec.md."
echo "    ...y ahora el mismo test contra el DUT con el bug"

# Un scoreboard que nunca vio un error no esta probado. +BUG=1 corre almost_full
# un lugar: el DUT sigue entregando los datos en orden, asi que un scoreboard
# que solo compara DATOS pasa en verde y no ve nada.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=random_test +BUG=1
if ! grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG"; then
   falta "con +BUG=1 almost_full se levanta un lugar tarde, y tu scoreboard no
    dijo nada. Los datos salen bien igual: si solo compares lo que sale por
    rd_data, este bug no se ve nunca. Un scoreboard de una FIFO tiene que
    predecir las BANDERAS, y para eso hace falta modelar la ocupacion."
fi
unset UVM_ERRORS_OK
echo "ETAPA 3 OK: el scoreboard cierra en verde y caza el bug de almost_full"

# --- Etapa 4: la cobertura ----------------------------------------------------
cov=$(cov_report | tee /dev/stderr | awk '/covergroup/ {print}')
[ -n "$cov" ] || falta "no se genero cobertura de covergroup. Falta el componente
    de cobertura colgado del analysis port, o el covergroup no se muestrea."
puntos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\2/p')
llenos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\1/p')
if [ "${puntos:-0}" -lt 20 ]; then
   falta "tu covergroup tiene ${puntos:-0} puntos y el plan de verificacion de
    spec.md tiene siete filas: con el cruce de pedido por ocupacion solo, ya
    son mas de veinte."
fi
if [ "$((llenos * 100 / puntos))" -lt 90 ]; then
   falta "cobertura $llenos/$puntos. Mira que bin quedo en cero: casi siempre es
    'escribir con la FIFO llena' o 'leer con la FIFO vacia', y los dos se
    llenan sesgando el dist de la transaction, no agregando ciclos."
fi
echo "ETAPA 4 OK: cobertura $llenos/$puntos"

echo
echo "EJERCICIO OK: monitor, driver, scoreboard con estado y cobertura."
echo "Ese scoreboard no podia ser una tabla. Eso es lo que separa este del otro."
