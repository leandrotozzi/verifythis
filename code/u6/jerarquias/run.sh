#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt top -f sv.f
run_sim

# La copia profunda tiene que bajar por los tres niveles de la jerarquia:
# 'medidas' es el campo del ultimo, el que se pierde si algun do_copy se olvida
# del super. Aparece dos veces: en el Fernet 1 y en el Fernet 2 ya copiado.
expect_in_log 2 'medidas: 2'
