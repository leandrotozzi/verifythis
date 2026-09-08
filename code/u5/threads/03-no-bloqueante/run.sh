#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
# --timescale: sin esto Verilator toma su default de 1ps y los #17 / #7 del
# ejemplo pasan a ser picosegundos, asi que la salida y el diagrama de la
# slide ("cada 17 ns") decian cosas distintas. Va como flag y no como
# `timescale en el fuente porque declararlo en un modulo obliga a declararlo
# en TODOS -- y uvm_pkg no lo declara: %Warning-TIMESCALEMOD, fatal. El flag,
# en cambio, es el default para los que no dicen nada, uvm_pkg incluido.
vlt_uvm top --timescale 1ns/1ns example_pkg.sv top.sv
run_sim
