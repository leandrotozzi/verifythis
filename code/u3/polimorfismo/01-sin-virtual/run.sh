#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
# Este ejemplo TERMINA en $fatal: llamar make_sound() sobre un animal generico
# es el error que la seccion quiere mostrar. Sale con codigo != 0 a proposito,
# asi que el PASS es que aparezca ese mensaje, no que el exit code sea 0.
vlt top -f sv.f
expect_output "Un trago generico no se sirve"
