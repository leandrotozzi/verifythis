# Todo lo que hace falta para correr los ejemplos del curso: Verilator 5.052
# compilado de fuente (el de las distros esta atrasado y los covergroups
# entraron en 5.050) y UVM 2020.3.1 horneada en /opt/uvm.
#
#   docker build -t verifythis .
#   docker run --rm -it -v "$PWD":/work verifythis make u4/tests
# z3 no es opcional: Verilator resuelve randomize() con constraints llamando a un
# solver SMT externo, y sin el `randomize()` devuelve 0 en vez de fallar al
# compilar. Lo necesitan code/u5/varios-objetos, u6/transactions, u7/agents,
# u7/sequences, u8/assertions y u8/dpi, mas los ejercicios de constrained
# random y de cobertura. Ver docs/verilator.md.
FROM debian:bookworm-slim

ARG VERILATOR_VERSION=v5.052
ARG UVM_VERSION=2020.3.1

# g++, make y perl no son solo del build de Verilator: cada simulacion se
# compila a un binario nativo, asi que se quedan en la imagen.
# -j4 y no $(nproc): con mas paralelismo el build de Verilator se queda sin RAM
# en una VM de Docker chica.
RUN apt-get update && apt-get install -y --no-install-recommends \
      autoconf bison ca-certificates ccache curl flex g++ git help2man \
      libfl-dev make perl python3 z3 zlib1g-dev \
 && git clone --depth 1 --branch "$VERILATOR_VERSION" \
      https://github.com/verilator/verilator.git /tmp/verilator \
 && cd /tmp/verilator && autoconf && ./configure && make -j4 && make install \
 && rm -rf /tmp/verilator \
 && mkdir -p /opt/uvm \
 && curl -sSL "https://github.com/accellera-official/uvm-core/archive/refs/tags/$UVM_VERSION.tar.gz" \
      | tar xz -C /opt/uvm --strip-components=1 \
 && rm -rf /var/lib/apt/lists/*

# common.sh y el Makefile leen UVM_HOME: apuntando afuera del repo, el
# bind-mount del working tree no tapa la UVM que ya viene en la imagen.
# VLT_BUILD_JOBS: compilar los buckets de UVM de a dos. Sin esto Docker Desktop
# con su RAM por defecto (~4 GB) mata el g++ por OOM. Ver docs/docker.md.
# CCACHE_DIR sí va DENTRO del bind-mount, al reves que UVM_HOME y por la razon
# opuesta: con --rm el contenedor se borra entero, y una cache que no sobrevive
# al `docker run` no cachea nada. En /work vive en el repo del host y el segundo
# capitulo compila en segundos. Esta en .gitignore.
ENV UVM_HOME=/opt/uvm \
    VLT_BUILD_JOBS=2 \
    CCACHE_DIR=/work/.ccache
WORKDIR /work
