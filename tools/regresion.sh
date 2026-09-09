#!/bin/bash
# Una regresion de verdad: el MISMO test, N semillas, y el merge de la cobertura.
#
#   make regresion                              # u7/sequences, 10 semillas
#   make regresion EJEMPLO=u6/transactions N=20
#   sh tools/regresion.sh u7/sequences 10       # idem, sin make
#
# Es el ejercicio code/ejercicios/d7-semillas convertido en herramienta: ahi el
# alumno escribe este bucle a mano para entender que una regresion no son cinco
# tests distintos, sino el mismo test cinco veces con otra semilla.
#
# Deja en dist/regresion/:
#   seed.<N>.dat    la cobertura de cada semilla, por separado
#   regresion.dat   el merge -- un bin que llena cualquiera queda llenado
#   regresion.html  el reporte, con los bins que quedaron ABIERTOS
#
# Corre el run.sh del ejemplo tal cual, con SEED distinta cada vez: no duplica
# ni un flag de compilacion. La primera vuelta compila (minutos, si usa UVM); las
# demas reusan el obj_dir y son segundos.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

EJEMPLO=${1:-${EJEMPLO:-u7/sequences}}
N=${2:-${N:-10}}
DIR=code/$EJEMPLO
OUT=dist/regresion

[ -f "$DIR/run.sh" ] || { echo "no existe $DIR/run.sh — el ejemplo se nombra como en 'make u4/tests'" >&2; exit 1; }
grep -q -- --coverage-user "$DIR/run.sh" ||
  { echo "$DIR/run.sh no compila con --coverage-user: sin covergroups no hay nada que mergear" >&2; exit 1; }

rm -rf "$OUT"; mkdir -p "$OUT"
echo "regresion: $EJEMPLO, $N semillas -> $OUT/"

for s in $(seq 1 "$N"); do
  printf '  SEED=%-4s ' "$s"
  ( cd "$DIR" && SEED=$s bash run.sh ) > "$OUT/seed.$s.log" 2>&1 ||
    { echo "FALLA — el log quedo en $OUT/seed.$s.log"; exit 1; }

  # Un ejemplo puede correr varios tests, y cada run_sim deja su propio cov.N.dat.
  # La semilla es la corrida entera, asi que primero se mergean los de ESA vuelta.
  dats=$(ls "$DIR"/obj_dir/*/cov.*.dat 2>/dev/null) ||
    { echo "sin cobertura"; exit 1; }
  verilator_coverage --write "$OUT/seed.$s.dat" $dats > /dev/null
  echo "$(grep -m1 'covergroup *:' "$OUT/seed.$s.log" | sed 's/.*: *//' | tr -s ' ')"
done

verilator_coverage --write "$OUT/regresion.dat" "$OUT"/seed.*.dat > /dev/null
node tools/regresion.mjs "$OUT" "$EJEMPLO"
