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
# Un tag de git se puede mover; el hash no. Esto es lo que separa "la UVM de
# Accellera" de "lo que hoy haya atras de ese tag".
#
# Si alguna vez falla sin que hayas tocado nada: GitHub genera este .tar.gz al
# vuelo y una vez en 2023 cambio la compresion de los archivos automaticos. Antes
# de re-blesear el hash, compara el contenido -- que el tag apunte al commit
# 78c06547a2a0a29b3dc9dcafae62b75b2ff61544 -- y recien ahi actualizalo aca y en
# el Dockerfile, que lleva el mismo.
SHA256=f55bdbc02cc500d4a2f41b31bad127653289eb2073f806ce156fb82662b362b8

[ -f "$DEST/src/uvm_pkg.sv" ] && { echo "UVM ya esta en $DEST"; exit 0; }

echo "bajando UVM $VERSION -> $DEST"
mkdir -p "$DEST"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -sSL --max-time 180 -o "$tmp/uvm.tgz" "$URL"

# sha256sum en Linux, shasum en macOS. Si no hay ninguno se avisa y se sigue:
# quedarse sin curso por no tener un binario de hash seria peor que el riesgo
# que esto cubre.
real=""
if command -v sha256sum >/dev/null 2>&1; then real=$(sha256sum "$tmp/uvm.tgz" | cut -d' ' -f1)
elif command -v shasum   >/dev/null 2>&1; then real=$(shasum -a 256 "$tmp/uvm.tgz" | cut -d' ' -f1)
else echo "aviso: sin sha256sum ni shasum, no puedo verificar el tarball" >&2; fi

if [ -n "$real" ] && [ "$real" != "$SHA256" ]; then
  echo "fallo: el tarball de UVM no es el esperado" >&2
  echo "  esperaba $SHA256" >&2
  echo "  vino     $real" >&2
  exit 1
fi

tar xzf "$tmp/uvm.tgz" -C "$DEST" --strip-components=1

[ -f "$DEST/src/uvm_pkg.sv" ] || { echo "fallo: no aparecio src/uvm_pkg.sv" >&2; exit 1; }
echo "ok"
