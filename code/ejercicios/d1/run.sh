#!/bin/bash
# Ejercicio del dia 1. Falla hasta que lo resuelvas.
#
#   bash run.sh              con tus archivos
#   SOLUCION=1 bash run.sh   con los de solucion/, para comparar
#
# El top del VTALU y el multiplicador salen del DUT del curso, sin tocar: los
# dos archivos de este directorio son los unicos que hay que editar.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
SRC=${SOLUCION:+solucion/}
vlt top --coverage-user -Wno-fatal \
    "${SRC}vtalu_1c.sv" "${SRC}vtalu_tb.sv" \
    ../../vtalu_dut/vtalu.sv ../../vtalu_dut/vtalu_mult.sv
run_sim
cov_report
grep -q "EJERCICIO OK" "$VLT_LOG" ||
  { echo "todavia no: mira las lineas de arriba y el README" >&2; exit 1; }
