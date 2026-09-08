#!/bin/bash
# Ejercicio del dia 6. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# El TB es el de la seccion Agents entero; de aca salen el agent y el env, que son
# los dos archivos que hay que tocar.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f

# +UVM_CONFIG_DB_TRACE hace que UVM imprima cada get() con la RUTA COMPLETA del
# componente que lo pidio. Como el driver y los monitores piden su config en
# build_phase, esas lineas son un censo del arbol -- escrito por la libreria, no
# por el alumno.
run_sim +UVM_TESTNAME=dual_test +UVM_VERBOSITY=UVM_HIGH +UVM_CONFIG_DB_TRACE

falta() { echo "todavia no: $1" >&2; exit 1; }
# El espacio final es el que separa la ruta del " = " que imprime UVM: sin el,
# "modulo_agent_h" tambien matchearia "modulo_agent_h.driver_h".
existe() { grep -q "accessor=uvm_test_top\.env_h\.$1 " "$VLT_LOG"; }

if ! existe modulo_agent_h; then
  falta "no hay ningun modulo_agent_h en el arbol"
fi
if existe modulo_agent_h.driver_h; then
  falta "modulo_agent_h construyo un driver: is_active no esta haciendo nada"
fi
if ! existe clase_agent_h.driver_h; then
  falta "clase_agent_h se quedo sin driver, y ese tiene que seguir siendo activo"
fi

# Correccion cruzada: el agent pasivo tiene que estar MIRANDO de verdad. Las dos
# cuentas salen del command_monitor y del scoreboard de la seccion Agents.
vistos=$(grep -c 'modulo_agent_h\.command_monitor_h.*MONITOR:' "$VLT_LOG" || true)
clase=$(grep -c 'clase_agent_h\.command_monitor_h.*MONITOR:' "$VLT_LOG" || true)
chequeados=$(grep -c 'modulo_scoreboard_h.*PASS' "$VLT_LOG" || true)

if [ "$vistos" -eq 0 ]; then
  falta "el agent pasivo no vio un solo comando: mira el ambito del set()"
fi
# El modulo manda 200 operaciones y la sequence mas de mil. Si las dos cuentas dan
# parecido, los dos agents estan mirando la MISMA interface: el ambito del
# set() esta mal. Ninguno de los dos numeros lo elegis vos.
if [ "$vistos" -ge "$clase" ]; then
  falta "los dos agents miran la misma interface ($vistos contra $clase): revisa el ambito del set()"
fi
if [ "$chequeados" -eq 0 ]; then
  falta "el scoreboard del modulo no chequeo nada: te falta conectar los analysis ports"
fi

echo "EJERCICIO OK: el agent pasivo vio $vistos comandos y su scoreboard chequeo $chequeados"
