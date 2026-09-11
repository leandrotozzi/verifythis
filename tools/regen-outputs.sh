#!/bin/bash
# Regenera las salidas de ejemplo que muestran las slides.
#
#   sh tools/regen-outputs.sh          # todas
#   sh tools/regen-outputs.sh u4/reporting     # solo las que matcheen
#
# Por que existe: esos .txt eran transcripts de Questa con UVM 1.1d. El curso
# hoy corre Verilator con UVM 2020.3.1, asi que la slide mostraba una salida que
# el alumno nunca iba a ver en su maquina. Ahora salen de correr el ejemplo.
#
# Ojo: cada build con UVM tarda varios minutos. La corrida completa es de media
# hora larga. No es parte de 'make': se corre a mano cuando cambia la version de
# UVM o del simulador.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
FILTER=${1:-}
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

quiere() { case "${1}" in *"$FILTER"*) return 0 ;; *) return 1 ;; esac; }

# Corre el run.sh de un ejemplo y deja la salida cruda en $TMP/$1.log.
# El log trae la compilacion adelante; los extractores de abajo se quedan solo
# con lo que imprime la simulacion.
corre() {
  local dir=$1 log=$TMP/$(echo "$1" | tr / _).log
  printf '  corriendo %-24s ' "$dir" >&2
  ( cd "$dir" && bash ./run.sh ) >"$log" 2>&1 || { echo "FALLO" >&2; tail -5 "$log" >&2; exit 1; }
  echo "ok" >&2
  echo "$log"
}

# La salida de la simulacion arranca en la primera linea de UVM y termina donde
# termina el resumen. Saca el ruido de Verilator y las lineas vacias del final.
#
# sed -E, no sed -n a secas: el sed de macOS no entiende '\|' como alternacion
# dentro de una direccion, asi que el patron no matcheaba nada y el archivo
# salia vacio. Con -E la alternacion es '|' y anda igual en BSD y en GNU.
#
# Y de paso se normaliza la ruta de UVM: en el log viene absoluta y tendria el
# home del que corrio el script metido en una slide del curso.
sim_out() {
  sed -nE '/UVM_INFO|UVM_WARNING|UVM_ERROR|UVM_FATAL/,$p' "$1"
}

# Todo lo que cambia entre maquinas y entre corridas, y ensuciaria el diff cada
# vez que se regenera:
#   - la ruta absoluta de UVM (traeria el home del que corrio el script a una
#     slide del curso)
#   - walltime / cpu / speed de Verilator
#   - el resumen de cobertura que imprime cov_report, que no es lo que estas
#     slides muestran
limpia() {
  sed -e "s|$ROOT/code/verilator/\.\./\.uvm|\$UVM_HOME|g" -e "s|$ROOT/|\$|g" \
      -e 's/; walltime .*//' -e '/^- Verilator: cpu /d' \
    | sed -e '/^Coverage Summary:/,$d' -e '/^%Warning: System has stack size/d' \
    | grep -v '^$'
}

# Un extractor que sale vacio es un error silencioso: la slide quedaria en
# blanco y el build no se entera.
escribe() {
  local out=$1
  limpia > "$out"
  [ -s "$out" ] || { echo "VACIO: $out — reviso el extractor" >&2; exit 1; }
  echo "  -> $out"
}

# --- u2/convencional: el mutante ------------------------------------------------
# La slide "Como sabes que el scoreboard chequea algo?" muestra la linea con la
# que el testbench convencional falla cuando el DUT corre con +VTALU_BUG. La
# corrida TIENE que fallar, asi que no pasa por corre(): un run.sh que termina
# en cero aca es el error. Se guarda solo el mensaje del scoreboard, sin el
# prefijo de Verilator, que trae el numero de linea del $error y envejece.
if quiere code/u2/convencional; then
  log=$TMP/u2_convencional_mutante.log
  printf '  corriendo %-24s ' "u2/convencional +VTALU_BUG" >&2
  if ( cd code/u2/convencional && VTALU_BUG=1 bash ./run.sh ) >"$log" 2>&1; then
    echo "NO FALLO — el scoreboard no atrapa el bug" >&2; exit 1
  fi
  echo "ok (fallo, que es lo que tenia que pasar)" >&2
  grep -m1 'FAILED:' "$log" | sed -E 's/.*Assertion failed in [^:]+: //' \
    | escribe code/u2/convencional/mutante.txt
fi

# --- u4/tests: la corrida de referencia ------------------------------------------
# Reemplaza a output.questa en la slide. El .questa se queda en el repo como
# testigo historico (ver code/README.md), pero no es lo que ve el alumno.
if quiere code/u4/tests; then
  log=$(corre code/u4/tests)
  sim_out "$log" | escribe code/u4/tests/output.txt
fi

# --- u8/assertions: SVA --------------------------------------------------------
# Los dos numeros que la seccion de assertions muestra en pantalla vivian
# escritos a mano en la slide, y por eso envejecieron sin que nada avisara: los
# UVM_ERROR del +BUG=1 y la cobertura de assertions. Ahora salen de correr.
#
# El run.sh hace DOS corridas -- el DUT sano y +BUG=1 -- asi que el resumen que
# la slide muestra es el ultimo del log.
if quiere code/u8/assertions; then
  log=$(corre code/u8/assertions)
  awk '/^--- UVM Report Summary ---$/ {buf=""} {buf = buf $0 "\n"} END {printf "%s", buf}' "$log" \
    | sed -n '/^\*\* Report counts by severity/,/^$/p' \
    | escribe code/u8/assertions/sva.txt
  # cov_report imprime una sola vez, al final de las dos corridas.
  sed -n '/^Coverage Summary:/,$p' "$log" | grep -E 'covergroup|user' \
    | escribe code/u8/assertions/cover.txt
fi

# --- u5/threads: blocking vs non-blocking ------------------------------------------
for v in 02-bloqueante 03-no-bloqueante; do
  quiere "code/u5/threads/$v" || continue
  log=$(corre "code/u5/threads/$v")
  out=code/u5/threads/$v/result.txt
  [ "$v" = 03-no-bloqueante ] && out=code/u5/threads/$v/results.txt
  sim_out "$log" | escribe "$out"
done

# --- u4/reporting: reporting ---------------------------------------------------------
# El scoreboard de u4/reporting tiene un bug a proposito (suma +1 en add_op) para que el
# seccion pueda mostrar como se ve un uvm_error y como se lo silencia.
#
#   scoreboard1.txt  el TB con el error a la vista
#   scoreboard2.txt  el mismo TB con set_report_severity_action_hier() puesto
#
# Para el segundo hace falta editar env.svh, asi que se toca, se corre y se
# deja como estaba.
if quiere code/u4/reporting; then
  log=$(corre code/u4/reporting)

  # Una linea de PASS y una de FAIL alcanzan para mostrar el formato; despues,
  # el resumen. La corrida entera son mil transacciones.
  {
    grep -m1 'RNTST'                  "$log" || true
    grep -m1 'SCOREBOARD] PASS'       "$log" || true
    grep -m1 'SCOREBOARD] FAIL'       "$log" || true
    echo '...'
    sed -n '/--- UVM Report Summary ---/,$p' "$log" | grep -v '^$'
  } | escribe code/u4/reporting/scoreboard1.txt

  grep -m1 'SCOREBOARD] FAIL' "$log" | escribe code/u4/reporting/tb_classes/scoreboard_error.txt

  ENV=code/u4/reporting/tb_classes/env.svh
  cp "$ENV" "$TMP/env.svh.bak"
  trap 'cp "$TMP/env.svh.bak" "$ENV" 2>/dev/null; rm -rf "$TMP"' EXIT
  # Se enciende la accion que apaga los errores y se apaga la verbosidad alta,
  # que es la leccion anterior: asi la salida queda en el resumen pelado.
  sed -e 's|//scoreboard_h.set_report_severity_action_hier|scoreboard_h.set_report_severity_action_hier|' \
      -e 's|^\( *\)scoreboard_h.set_report_verbosity_level_hier|\1//scoreboard_h.set_report_verbosity_level_hier|' \
      "$TMP/env.svh.bak" > "$ENV"
  grep -n 'scoreboard_h.set_report' "$ENV"

  log2=$(corre code/u4/reporting)
  {
    grep -m1 'RNTST' "$log2" || true
    sed -n '/--- UVM Report Summary ---/,$p' "$log2" | grep -v '^$'
  } | escribe code/u4/reporting/scoreboard2.txt

  cp "$TMP/env.svh.bak" "$ENV"
  trap 'rm -rf "$TMP"' EXIT
fi

# --- d4b: el bus con la FIFO sin tope -------------------------------------------
# El numero que hace el ejercicio --cuantas de las mil operaciones llegan al
# bus-- vivia escrito en la prosa, y la revision de septiembre 2026 lo encontro
# mal: decia "unas veinticinco" y son 13. Como es el estado ROTO el que ensena,
# esta captura corre el ejercicio SIN resolver, y por eso no puede usar corre():
# el run.sh termina en 1 a proposito, con el "not yet" que le explica al alumno
# lo que acaba de ver. Un exit 0 aca seria la senal de que el ejercicio se
# rompio y ya no ensena nada.
if quiere code/ejercicios/d4b; then
  printf '  corriendo %-24s ' code/ejercicios/d4b >&2
  log=$TMP/d4b.log
  ( cd code/ejercicios/d4b && bash ./run.sh ) >"$log" 2>&1 && {
    echo "PASO SIN RESOLVER" >&2
    echo "  code/ejercicios/d4b tendria que fallar sin la solucion y paso" >&2; exit 1; }
  echo "ok (fallo, que es lo que tenia que pasar)" >&2
  sed -n '/^\*\* Report counts by id/,/^$/p' "$log" | escribe code/ejercicios/d4b/roto.txt
fi

# --- u7/sequences: cuando termina el full_test ----------------------------------
# La slide de sequences dice en cuanto termina el full_test para contrastarlo
# con el test que no levanta objections. El run.sh corre cinco tests seguidos:
# el full_test es el PRIMERO, asi que se corta en su $finish y no en el ultimo,
# que es el del no_objection_test y termina en 0.
if quiere code/u7/sequences; then
  log=$(corre code/u7/sequences)
  sed -n '/--- UVM Report Summary ---/,/finish at/p' "$log" \
    | sed -n '1,/finish at/p' | escribe code/u7/sequences/full_test.txt
fi

echo
echo "Listo. Revisa el diff antes de commitear: git diff --stat code/"
