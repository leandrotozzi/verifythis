#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
#
# RAL sobre el APB del capstone. El testbench del dia 7 NO se toca: la interface,
# la transaction, el driver, el monitor y el agent salen de d7-final/solucion/
# por +incdir, igual que en los ejercicios. Esta unidad agrega tres archivos.
#
#   ral_test            write/read/mirror por el modelo, con prediccion explicita
#   builtin_test        uvm_reg_hw_reset_seq y uvm_reg_bit_bash_seq
#   builtin_test +MAL   el mismo, con CTRL.CLR modelado como "RW" en vez de "WOC"
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

CAP=../../ejercicios/d7-final

# -Wno-WIDTHEXPAND: uvm_reg_data_t son 64 bits, asi que un literal de 32 --el
# 'h1000_0000 de una write()-- se ensancha y Verilator lo avisa. Es ruido de la
# libreria, no del ejemplo.
vlt_uvm top -Wno-fatal -Wno-WIDTHEXPAND \
  +incdir+tb_classes +incdir+"$CAP/solucion/tb_classes" \
  "$CAP/rtl/apb_regs.sv" "$CAP/solucion/apb_pkg.sv" "$CAP/solucion/apb_if.sv" \
  ral_pkg.sv top.sv

run_sim +UVM_TESTNAME=ral_test

# Las dos sequences de la libreria hacen 380 transferencias, y el monitor del
# capstone reporta cada una. UVM_LOW deja los errores y saca el diario.
run_sim +UVM_TESTNAME=builtin_test +UVM_VERBOSITY=UVM_LOW

# El remate: una sola palabra mal en el modelo, y una sequence que nadie escribio
# la caza. Aca los UVM_ERROR son el resultado, no una falla, asi que run_sim no
# tiene que abortar.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=builtin_test +UVM_VERBOSITY=UVM_LOW +MAL
unset UVM_ERRORS_OK

# Del Report Summary, que es donde UVM cuenta de verdad. Las corridas buenas ya
# las chequeo run_sim: si hubieran dado un error, el script ya habria abortado.
errores=$(awk '$1 == "UVM_ERROR" && $2 == ":" { print $3 }' "$VLT_LOG")
if [ "${errores:-0}" -eq 0 ]; then
  echo "FALLA: con +MAL el modelo declara CTRL.CLR como RW y bit_bash tendria que" >&2
  echo "       cazarlo. Si no grita, la sequence no esta corriendo." >&2
  exit 1
fi

echo
echo "=== el modelo es la spec ==="
echo "    CTRL.CLR como \"WOC\"  0 UVM_ERROR"
echo "    CTRL.CLR como \"RW\"   $errores UVM_ERROR, de uvm_reg_bit_bash_seq"
grep -m1 'UVM_ERROR.*uvm_reg_bit_bash_seq' "$VLT_LOG" | sed 's/.*\] //; s/^/    > /'
echo
echo "    Nadie escribio un test para CTRL. La sequence lo genero del modelo, y el"
echo "    unico dato que uso fue la palabra que dice como se accede el campo."
