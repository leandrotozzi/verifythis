#!/bin/bash
# Ejercicio del dia 4. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# El TB es el de la seccion Analysis ports entero; de aca salen el package, el env que tenes
# que conectar y tu op_counter.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f
# El command_monitor reporta con `uvm_info a UVM_HIGH, asi que hay que subir
# el techo de verbosidad para que sus lineas salgan en el log. Eso es tema
# de la seccion Reporting; aca alcanza con saber que sin el flag no se ven.
run_sim +UVM_TESTNAME=random_test +UVM_VERBOSITY=UVM_HIGH || true

# La correccion es cruzada: lo que contaste tiene que dar igual que las lineas
# que imprimio el command_monitor, que no las escribiste vos.
# El ^UVM_INFO no es decorativo: sin el, el grep tambien cuenta la linea
# "[COMMAND MONITOR]  1000" del Report Summary y da uno de mas.
vistos=$(grep -c '^UVM_INFO.*\[COMMAND MONITOR\]' "$VLT_LOG" || true)
contados=$(sed -nE 's/.*OP_COUNTER.*comandos=([0-9]+).*/\1/p' "$VLT_LOG" | tail -1)

if [ -z "$contados" ]; then
  echo "todavia no: op_counter no imprimio nada en report_phase" >&2; exit 1
fi
if [ "$contados" != "$vistos" ]; then
  echo "todavia no: contaste $contados comandos y el monitor vio $vistos" >&2; exit 1
fi
echo "EJERCICIO OK: $contados comandos, los mismos que vio el command_monitor"
