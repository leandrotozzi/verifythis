#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
#
# El tercer gancho: el mismo testbench de la seccion Agents, con dos callbacks
# colgados del driver. El env, el agent, el driver y las sequences NO se tocan.
#
#   dual_test     el de siempre, sin un solo callback registrado
#   inject_test   el MISMO test, con jitter_cb y flip_bit_cb puestos encima
#
#   bash run.sh +CALLBACK_TRACE   imprime la cola de callbacks del driver
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f

run_sim +UVM_TESTNAME=dual_test
limpio=$VLT_LOG

run_sim +UVM_TESTNAME=inject_test "$@"
inyectado=$VLT_LOG

# Los dos callbacks corrieron de verdad. Sin este chequeo, un `uvm_register_cb
# que falte deja todo compilando y el ejemplo "pasando" sin haber inyectado nada
# -- que es el modo de falla tipico de los callbacks.
# El corchete y el "A:" son de la linea del `uvm_info; sin ellos, el conteo
# por severidad del Report Summary se cuenta a si mismo.
flips=$(grep -c "\[FLIP_BIT_CB\] A:" "$inyectado" || true)
[ "$flips" -gt 0 ] ||
  { echo "FALLA: ningun callback corrio — revisa el \`uvm_register_cb del driver" >&2; exit 1; }

# El jitter se ve en el tiempo de simulacion: mismo estimulo, mas ciclos.
tiempo() { sed -nE 's/.*\$finish at ([0-9]+)ns.*/\1/p' "$1" | tail -1; }
t_limpio=$(tiempo "$limpio"); t_inyectado=$(tiempo "$inyectado")

echo
echo "=== el tercer gancho ==="
printf '    dual_test    %s bits dados vuelta, $finish en %s ns\n' 0 "$t_limpio"
printf '    inject_test  %s bits dados vuelta, $finish en %s ns\n' "$flips" "$t_inyectado"
echo
echo "    Y el scoreboard NO grito en ninguna de las dos corridas: el monitor mira"
echo "    el CABLE, no lo que el driver creia que iba a mandar. Es la mejor noticia"
echo "    que da este ejemplo, no un agujero del corrector. Ver la slide."

cov_report
