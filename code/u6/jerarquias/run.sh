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

# wrong.sv is the "how not to" version and it is on screen in 130-jerarquias. It has
# its own `module top`, so it does not go into sv.f -- but it does have to COMPILE:
# it lived for months with a `sformat` (which does not exist in SystemVerilog) on a
# slide that presented it as working code, precisely because nobody ever built it.
verilator --lint-only --timing --quiet-stats -Wno-fatal --top-module top wrong.sv
