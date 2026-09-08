#!/bin/bash
# Ejercicio del dia 7 (unidad 9, RAL). Falla hasta que lo resuelvas, y te dice
# en que etapa.
#
#   bash run.sh              con tu archivo
#   SOLUCION=1 bash run.sh   con el de solucion/, para comparar
#
# El testbench es el de code/u9/ral/ entero: el adapter, el predictor y los tres
# tests salen de ahi. De aca sale un solo archivo -- el modelo de registros.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

U9=../../u9/ral
CAP=../d7-final

falta() { echo; echo "todavia no: $1" >&2; exit 1; }

# El +incdir de este directorio va PRIMERO: tu apb_reg_block.svh le gana al de
# la unidad. Con SOLUCION=1, gana el de solucion/.
vlt_uvm top -Wno-fatal -Wno-WIDTHEXPAND \
  ${SOLUCION:++incdir+solucion} +incdir+. \
  +incdir+"$U9/tb_classes" +incdir+"$CAP/solucion/tb_classes" \
  "$CAP/rtl/apb_regs.sv" "$CAP/solucion/apb_pkg.sv" "$CAP/solucion/apb_if.sv" \
  "$U9/ral_pkg.sv" "$U9/top.sv"

# --- Etapa 1: el mapa ---------------------------------------------------------
# Ni una transferencia todavia: el modelo se imprime y se compara con la tabla
# de spec.md. Un offset o un acceso mal se ven aca, antes de simular nada.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=mapa_test > /dev/null || true
unset UVM_ERRORS_OK

grep -o '\[MAPA\].*' "$VLT_LOG" | sed 's/^/    /' || true
falta_campo() {
  grep -Eq "\[MAPA\] +$1" "$VLT_LOG" ||
    falta "en el modelo no aparece $2.
    La tabla esta en $CAP/spec.md, seccion 'El mapa de registros'. El modelo se
    imprime solo: +UVM_TESTNAME=mapa_test y comparalo linea por linea."
}
falta_campo 'CTRL +@0x0 +\w+ +\[0\+:1\] +RW'      'CTRL.EN: bit 0, un bit, RW'
falta_campo 'CTRL +@0x0 +\w+ +\[1\+:1\] +WOC'     'CTRL.CLR: bit 1, un bit, y un acceso
    que diga "se escribe, y despues se lee en cero". No es RW ni WO: UVM tiene uno
    con ese nombre exacto'
falta_campo 'SCRATCH +@0x4 +\w+ +\[0\+:32\] +RW'  'SCRATCH: 32 bits en 0x04, RW'
falta_campo 'ACC +@0x8 +\w+ +\[0\+:32\] +RO'      'ACC: 32 bits en 0x08, RO'
falta_campo 'STATUS +@0xc +\w+ +\[0\+:1\] +RO'    'STATUS.EN: bit 0 en 0x0C, RO'
falta_campo 'STATUS +@0xc +\w+ +\[1\+:1\] +RO'    'STATUS.OVF: bit 1 en 0x0C, RO'
echo "ETAPA 1 OK: cuatro registros, seis campos, y el mapa dice lo que dice la spec"

# --- Etapa 2: los accesos -----------------------------------------------------
# uvm_reg_hw_reset_seq y uvm_reg_bit_bash_seq salen de uvm-core y no saben nada
# de este DUT: leen tu modelo y generan el estimulo y el chequeo. Son los tests
# que no escribiste.
run_sim +UVM_TESTNAME=builtin_test +UVM_VERBOSITY=UVM_LOW || falta "builtin_test cerro con
    UVM_ERROR. El DUT esta sano: el que se equivoca es tu modelo. Si el error
    habla de un bit de CTRL, el acceso de CLR es el sospechoso -- 'escribi un 1 y
    lei 0' es lo que dice la spec, no un bug."
echo "ETAPA 2 OK: hw_reset y bit_bash en verde -- dos tests que no escribiste"

# --- Etapa 3: lo que el modelo no puede predecir -------------------------------
run_sim +UVM_TESTNAME=ral_test || falta "ral_test cerro con UVM_ERROR.
    Si el mensaje es un mismatch de STATUS, el modelo no esta mintiendo por error
    de direccion: STATUS.EN es una copia de CTRL.EN y llego ahi por una
    transferencia a OTRA direccion. Un modelo de registros no puede predecir eso,
    y decirlo es parte de modelarlo. Ver el ultimo <<< ACA >>> del archivo."
echo "ETAPA 3 OK: el modelo sabe lo que puede predecir y lo que no"

echo
echo "EJERCICIO OK: el mapa de registros de spec.md, como modelo de UVM."
echo "              Escribiste 40 lineas y te llevaste dos tests de regalo."
