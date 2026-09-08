#!/bin/sh
# Doctor del entorno: dice si esta maquina puede correr el curso, y si no, que
# falta y como se instala.
#
# Existe porque la instalacion es donde el curso pierde gente antes de empezar,
# y porque los dos modos de falla mas caros son MUDOS -- sin z3, randomize()
# devuelve 0 sin decir nada; con un Verilator viejo, la cobertura funcional
# reporta 0 % sin una advertencia.
#
#   sh tools/doctor.sh      (o: make doctor)
#
# Sale con 0 si el curso corre entero, 1 si falta algo obligatorio.

VERILATOR_MIN=5.050          # los covergroups entraron aca
ok=0

# ---------------------------------------------------------------- utilidades
verde()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
rojo()   { printf '  \033[31m✗\033[0m %s\n' "$1"; ok=1; }
aviso()  { printf '  \033[33m!\033[0m %s\n' "$1"; }
comose() { printf '      %s\n' "$1"; }

# Compara dos versiones x.y.z. Devuelve 0 si $1 >= $2. sort -V no esta en todos
# lados (macOS viejo), asi que se comparan los campos a mano. Los campos se
# comparan como NUMEROS, que es lo correcto para el esquema de Verilator -- el
# minor va con tres digitos: 5.050, 5.052, 5.100.
ge() {
  IFS=. read -r a1 a2 a3 <<EOF
$1
EOF
  IFS=. read -r b1 b2 b3 <<EOF
$2
EOF
  [ "${a1:-0}" -gt "${b1:-0}" ] && return 0
  [ "${a1:-0}" -lt "${b1:-0}" ] && return 1
  [ "${a2:-0}" -gt "${b2:-0}" ] && return 0
  [ "${a2:-0}" -lt "${b2:-0}" ] && return 1
  [ "${a3:-0}" -ge "${b3:-0}" ]
}

# Que gestor de paquetes hay, para dar el comando exacto y no una lista.
if command -v brew >/dev/null 2>&1;    then INSTALA="brew install"
elif command -v apt >/dev/null 2>&1;   then INSTALA="sudo apt install"
elif command -v dnf >/dev/null 2>&1;   then INSTALA="sudo dnf install"
elif command -v pacman >/dev/null 2>&1; then INSTALA="sudo pacman -S"
else INSTALA="instala con tu gestor de paquetes:"
fi

echo
echo "Verify This! — doctor del entorno"
echo

# ------------------------------------------------------- 1. Verilator (obligatorio)
if command -v verilator >/dev/null 2>&1; then
  v=$(verilator --version 2>/dev/null | awk '{print $2}')
  if ge "$v" "$VERILATOR_MIN"; then
    verde "verilator $v"
  else
    rojo "verilator $v — el curso necesita >= $VERILATOR_MIN"
    comose "Los covergroups entraron en $VERILATOR_MIN: con uno anterior la"
    comose "cobertura funcional reporta 0 % y no avisa. Receta de compilacion"
    comose "en el README, seccion 'A mano'."
  fi
else
  rojo "verilator — no esta instalado"
  comose "$INSTALA verilator     (y verifica que sea >= $VERILATOR_MIN)"
  comose "El paquete de la distro suele estar atrasado. El camino corto es"
  comose "GitHub Codespaces, que ya lo trae: ver el README."
fi

# ------------------------------------------------------------- 2. z3 (obligatorio)
if command -v z3 >/dev/null 2>&1; then
  verde "z3 $(z3 --version 2>/dev/null | awk '{print $3}')"
else
  rojo "z3 — no esta instalado, y hace falta desde el dia 5"
  comose "$INSTALA z3"
  comose "Verilator resuelve randomize() con constraints llamando a z3. Sin el,"
  comose "los ejemplos compilan, corren, y randomize() devuelve 0 EN SILENCIO."
fi

# -------------------------------------------------------------- 3. make + g++
for h in make g++ perl; do
  if command -v "$h" >/dev/null 2>&1
    then verde "$h"
    else rojo "$h — no esta instalado"; comose "$INSTALA $h"
  fi
done

# ---------------------------------------------------------- 4. ccache (opcional)
if command -v ccache >/dev/null 2>&1; then
  verde "ccache — la segunda compilacion con UVM va a tardar ~15 s"
else
  aviso "ccache — no esta, y sin el CADA compilacion con UVM tarda minutos"
  comose "$INSTALA ccache"
  comose "No es obligatorio, pero es la diferencia entre 15 segundos y 90 en"
  comose "cada ejemplo con UVM. common.sh lo detecta solo."
fi

# ------------------------------------------------- 5. node (solo para editar)
if command -v node >/dev/null 2>&1; then
  verde "node $(node --version 2>/dev/null) — para regenerar el deck"
else
  aviso "node — no esta. Solo hace falta para EDITAR el curso"
  comose "index.html y libro/ vienen commiteados: para hacer el curso alcanza"
  comose "con abrir index.html con doble clic."
fi

# ---------------------------------------------- 6. UVM bajada (se baja sola)
if [ -f "${UVM_HOME:-code/.uvm}/src/uvm_pkg.sv" ]; then
  verde "UVM 2020.3.1 en ${UVM_HOME:-code/.uvm}/"
else
  aviso "UVM todavia no esta bajada — se baja sola la primera vez"
  comose "make uvm      (o lo hace 'make' solo)"
fi

# ------------------------------------------------------------------ veredicto
echo
if [ "$ok" -eq 0 ]; then
  echo "Todo listo. Probalo con:   make u2/convencional     (segundos)"
  echo "y despues con:             make u4/tests            (compila UVM)"
else
  echo "Falta algo de lo marcado con ✗. Mientras tanto, el curso corre entero"
  echo "en GitHub Codespaces sin instalar nada: ver el README."
fi
echo
exit "$ok"
