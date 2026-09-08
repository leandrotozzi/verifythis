#!/bin/bash
# Ejercicio del dia 5. Falla hasta que lo resuelvas.
#
#   bash run.sh                        con tus archivos
#   SOLUCION=1 bash run.sh             con los de solucion/, para comparar
#   bash run.sh +UVM_VERBOSITY=UVM_HIGH   con los mensajes de debug a la vista
#
# El TB es el de la seccion Transactions entero: lo unico que sale de este directorio es
# command_monitor.svh, que se cuela primero por el orden de los +incdir.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f
run_sim +UVM_TESTNAME=random_test "$@"
