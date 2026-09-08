#!/bin/bash
# Ejercicio del dia 1 -- las ondas. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con el de solucion/, para comparar
#
# Es el unico ejercicio del curso que NO se resuelve leyendo el log. El log te
# da una linea; el resto esta en ondas.vcd.
#
# Va por etapas, como el capstone:
#   ETAPA 1  leiste las ondas: los dos tiempos de respuesta.txt
#   ETAPA 2  arreglaste la BFM: la corrida cierra sin un solo $error
#
# El TB es el del testbench convencional (u2/interfaces-bfm): de aca salen la
# BFM -- que es la que tiene el bug -- y el top, que trae el volcado de ondas.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
SRC=${SOLUCION:+solucion/}

falta() { echo "todavia no: $1" >&2; exit 1; }

# --trace siempre: las ondas son el ejercicio, no un opt-in.
VLT_TRACE=1
vlt top -Wno-fatal -f pkg.f "${SRC}vtalu_bfm.sv" -f tb.f top.sv -f dut.f

echo "=== corriendo, y volcando ondas.vcd ==="
# La corrida ABORTA en el primer $error mientras el bug este: es lo esperado.
run_sim || true
[ -f ondas.vcd ] || falta "no se genero ondas.vcd. Revisa que top.sv tenga el bloque \`ifdef VLT_TRACE."

# La verdad sale del propio .vcd, no de un numero escrito a mano aca: asi el
# ejercicio no se rompe si cambia el DUT o el estimulo. Los dos tiempos que se
# piden son los mismos con la BFM rota y con la sana -- pasan ANTES de que el
# bug desincronice nada -- asi que la respuesta no cambia al arreglarla.
#   done       top.DUT.done        start_mult  top.DUT.start_mult
# Los ids de una letra salen de la seccion $var del encabezado del .vcd.
ids() { awk -v s="$1" '/\$scope module DUT/ { d = 1 }
                       d && $0 ~ ("\\$var .* " s " \\$end") { print $(NF-2); exit }' ondas.vcd; }
ID_DONE=$(ids done); ID_MUL=$(ids start_mult)
[ -n "$ID_DONE" ] && [ -n "$ID_MUL" ] || falta "no encontre done/start_mult en ondas.vcd"

read -r T_PRIMERO T_MUL <<EOF
$(awk -v d="$ID_DONE" -v m="$ID_MUL" '
    /^#/ { t = substr($0,2)+0; next }
    $0 == "1" m { if (!sm) sm = t }
    $0 == "1" d { if (!p) p = t; if (sm && !dm) dm = t }
    END { print p, dm }' ondas.vcd)
EOF

echo ""
echo "=== ETAPA 1: leer las ondas ==="
[ -f "${SRC}respuesta.txt" ] || falta "falta respuesta.txt. Abri las ondas
    (gtkwave ondas.vcd, o surfer) y escribi los dos tiempos que pide el README,
    uno por linea, en picosegundos y sin unidad."

# Dos numeros, uno por linea; se ignoran comentarios y lineas en blanco.
R=(); while read -r n; do R+=("$n"); done < <(grep -oE "^[0-9]+" "${SRC}respuesta.txt")
[ "${#R[@]}" -ge 2 ] || falta "respuesta.txt tiene ${#R[@]} numero(s) y hacen falta 2:
    el primer flanco de subida de done, y el de la PRIMERA multiplicacion."

[ "${R[0]}" = "$T_PRIMERO" ] ||
  falta "el primer flanco de subida de done no es ${R[0]} ps.
    Poné el cursor sobre el PRIMER flanco de subida de done y leé el tiempo."
[ "${R[1]}" = "$T_MUL" ] ||
  falta "el done de la primera multiplicacion no es ${R[1]} ps.
    Buscá el primer tramo con op = mul_op (o start_mult en 1) y leé el tiempo
    del flanco de subida de done que lo cierra."
echo "ETAPA 1 OK: leiste las ondas -- primer done en $T_PRIMERO ps, el de la primera multiplicacion en $T_MUL ps"

echo ""
echo "=== ETAPA 2: arreglar la BFM ==="
grep -q 'while *( *done' "${SRC}vtalu_bfm.sv" ||
  falta "send_op sigue contando ciclos. El DUT dice cuando termino: esperá el
    handshake (done), no un numero de flancos. Es una linea."

run_sim || falta "la corrida sigue reportando errores: mira las lineas de arriba"
echo "ETAPA 2 OK: la BFM espera el handshake y no falla ninguna operacion"
echo ""
echo "EJERCICIO OK"
