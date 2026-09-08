#!/bin/sh
# Baja UVM 2020.3.1 (Accellera uvm-core, Apache-2.0) a code/.uvm/. No se
# commitea: son varios MB de libreria de terceros. Idempotente — si ya esta, no
# hace nada.
#
# Por que 2020.3.1 y no la 1.2: es la implementacion de referencia de
# IEEE 1800.2-2020, que es lo que el curso dice ensenar, y Verilator la soporta
# oficialmente desde 5.052. Ademas se baja de GitHub sin formulario. La 1.2
# tambien anda (probado), pero es la version pre-IEEE.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST=$ROOT/code/.uvm
VERSION=2020.3.1
URL=https://github.com/accellera-official/uvm-core/archive/refs/tags/$VERSION.tar.gz

[ -f "$DEST/src/uvm_pkg.sv" ] && { echo "UVM ya esta en $DEST"; exit 0; }

echo "bajando UVM $VERSION -> $DEST"
mkdir -p "$DEST"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -sSL --max-time 180 -o "$tmp/uvm.tgz" "$URL"
tar xzf "$tmp/uvm.tgz" -C "$DEST" --strip-components=1

[ -f "$DEST/src/uvm_pkg.sv" ] || { echo "fallo: no aparecio src/uvm_pkg.sv" >&2; exit 1; }
echo "ok"
