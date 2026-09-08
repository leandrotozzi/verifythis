#!/bin/bash
# Sequences virtuales -- la unidad 23, con los DOS agents manejando.
#
# El testbench es el de la seccion Sequences entero: los +incdir de abajo lo traen por
# referencia y este directorio solo pone lo que cambia. Ver docs/verilator.md.
#
#   virtual_test   reset de las dos ALU en paralelo, trafico coordinado, y el
#                  resultado de una como operando de la otra
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"

# El orden de los incdir es el que decide: primero los de aca, y por eso el
# env.svh de este directorio le gana al de la seccion. Y ".." NO va en la lista:
# Verilator busca en los incdir tambien los archivos de la linea de comandos, y
# se traeria el vtalu_pkg.sv de la seccion en vez de este.
vlt_uvm top --coverage-user -Wno-fatal \
  +incdir+./tb_classes +incdir+../tb_classes \
  ../../../vtalu_dut/vtalu_1c.sv \
  ../../../vtalu_dut/vtalu_mult.sv \
  ../../../vtalu_dut/vtalu.sv \
  ./vtalu_pkg.sv ../vtalu_bfm.sv ./top.sv

run_sim +UVM_TESTNAME=virtual_test
cov_report
