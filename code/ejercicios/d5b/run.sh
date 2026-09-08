#!/bin/bash
# Ejercicio del dia 5 (constrained random). Falla hasta que lo resuelvas.
#
#   bash run.sh              con tu archivo
#   SOLUCION=1 bash run.sh   con el de solucion/, para comparar
#   SEED=7 bash run.sh       con otra semilla: los numeros se mueven un poco
#
# Sin UVM y sin DUT: compila y corre en segundos. Es el ejercicio para el que
# tiene poco tiempo.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
SRC=${SOLUCION:+solucion/}
vlt top_histograma -Wno-fatal -Wno-WIDTHTRUNC "${SRC}histograma.sv"
run_sim

falta() { echo "todavia no: $1" >&2; exit 1; }

linea=$(grep -o 'HISTOGRAMA .*' "$VLT_LOG" | tail -1)
[ -n "$linea" ] || falta "no salio la linea HISTOGRAMA: no toques el \$display"

leer() { echo "$linea" | sed -nE "s/.*$1=([0-9.]+).*/\1/p"; }
ceros=$(leer 00); medio=$(leer medio); unos=$(leer FF)

# Tolerancia de +-2 puntos por casillero. bc no esta en todas las imagenes;
# awk si, y ademas es el que ya usa common.sh.
lejos() { awk -v v="$1" -v o="$2" 'BEGIN {exit !(v < o - 2 || v > o + 2)}'; }

if lejos "$ceros" 10 || lejos "$unos" 10; then
  falta "los bordes dan 00=$ceros% y FF=$unos%, y tienen que dar 10% cada uno.
    Los pesos ya son 10, 80 y 10: el problema no son los numeros, es el
    OPERADOR. Mira la slide 'dist: := no es lo mismo que :/' de la seccion Transactions."
fi
lejos "$medio" 80 &&
  falta "el medio da $medio% y tiene que dar 80%"

echo "EJERCICIO OK: 00=$ceros%  medio=$medio%  FF=$unos%  (objetivo 10/80/10, +-2)"
