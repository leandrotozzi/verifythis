#!/bin/bash
# Ejercicio del dia 6 (seccion Sequences) -- otra semilla. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tu regresion.sh
#   SOLUCION=1 bash run.sh   con el de solucion/, para comparar
#
# El test es reset + 25 operaciones al azar. 25 y no 1000 a proposito: con 1000
# el random ya llega hasta donde puede y todas las semillas dan el mismo numero
# -- medilo, esta en la slide "otra semilla, y de nuevo" de la seccion Constrained random.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f

falta() { echo "todavia no: $1" >&2; exit 1; }
bins() { verilator_coverage "$1" 2>/dev/null | sed -nE 's/.*covergroup *: *[0-9.]+% *\( *([0-9]+)\/.*/\1/p'; }

rm -f "$VLT_OBJ"/seed.*.dat "$VLT_OBJ/regresion.dat"
. "${SOLUCION:+solucion/}regresion.sh"

dats=$(ls "$VLT_OBJ"/seed.*.dat 2>/dev/null | sort)
n=$(printf '%s\n' $dats | grep -c . || true)
[ "$n" -ge 5 ] ||
  falta "encontre $n archivo(s) seed.<N>.dat y hacen falta 5, uno por semilla"

echo "=== cobertura de cada semilla ==="
mejor=0
for d in $dats; do
  b=$(bins "$d")
  printf '    %-14s %s bins\n' "$(basename "$d")" "$b"
  [ "$b" -gt "$mejor" ] && mejor=$b
done

[ -f "$VLT_OBJ/regresion.dat" ] ||
  falta "falta el merge: verilator_coverage --write \$VLT_OBJ/regresion.dat \$VLT_OBJ/seed.*.dat"
merge=$(bins "$VLT_OBJ/regresion.dat")
echo "=== las cinco, mergeadas ==="
printf '    regresion.dat  %s bins\n' "$merge"

[ "$merge" -gt "$mejor" ] ||
  falta "el merge da $merge bins y la mejor semilla sola ya daba $mejor.
    Si son iguales, lo mas probable es que hayas mergeado un solo .dat, o que
    los cinco sean copias de la misma corrida: fijate que run_sim reciba una
    SEED distinta en cada vuelta -- la imprime al arrancar."

echo "EJERCICIO OK: la mejor semilla sola llega a $mejor bins; las cinco mergeadas, a $merge"
