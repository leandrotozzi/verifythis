#!/bin/bash
# Clocking block: el flanco y el delta, declarados una sola vez.
#
# Corre los dos tops, uno detras del otro, porque la seccion es la comparacion:
#   1. sin_clocking  tres formas de muestrear el mismo dato -> tres numeros
#   2. con_clocking  el mismo dato, leido tres veces -> el mismo numero
#   3. mezcla        el precio del clocking block: dos nombres para el mismo
#                    cable, y no valen lo mismo
#
# El segundo termina en $fatal si el clocking block no da 11: es la red que
# avisa si una version de Verilator cambia la semantica del muestreo.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

echo "=== 1) sin clocking block: el flanco y el delta, a mano y en cada task ==="
vlt top_sin -Wno-fatal -f sv_sin.f
run_sim

echo ""
echo "=== 2) con clocking block: declarado una vez, en la interface ==="
vlt top_con -Wno-fatal -f sv_con.f
run_sim

echo ""
echo "=== 3) la trampa: mezclar el cable crudo con el del clocking block ==="
vlt top_mezcla -Wno-fatal -f sv_mezcla.f
run_sim
