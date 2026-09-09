#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top -f sv.f
run_sim

# El punto de la seccion: con 'virtual', servir() por el handle de la clase base
# ejecuta el de la derivada. O sea que cada trago se sirve DOS veces, una por su
# propio handle y otra por el de trago. Sin despacho virtual saldria una sola.
expect_in_log 2 'Fernet: 70/30, and the coke last'
expect_in_log 2 'Mojito: mint, lime and crushed ice'
