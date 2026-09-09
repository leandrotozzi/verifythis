# Correr el curso en Docker

Sirve para no compilar Verilator a mano. La imagen trae **Verilator 5.052** y
**UVM 2020.3.1** ya adentro; el repo se monta desde afuera, así que editás los
ejemplos con tu editor de siempre y los corrés adentro.

```sh
docker build -t verifythis .                      # una vez, ~7 min
docker run --rm -it -v "$PWD":/work verifythis make u4/tests   # ~5 min
docker run --rm -it -v "$PWD":/work verifythis    # shell interactiva
```

O abrí el repo en VS Code / GitHub Codespaces: `.devcontainer/devcontainer.json`
usa el mismo `Dockerfile` y te deja adentro del contenedor. Con una diferencia a
propósito: el devcontainer le suma **Node 22** por encima, así que ahí sí andan
`npm run check` y `npm run build`. La imagen pelada no los trae.

## Dónde vive UVM

En `/opt/uvm`, **fuera** del repo: si estuviera en `code/.uvm/` el bind-mount
del working tree la taparía y habría que bajarla en cada `docker run`. La imagen
exporta `UVM_HOME=/opt/uvm`, que es lo que leen `code/verilator/common.sh` y el
`Makefile`. Fuera del contenedor nada cambia: sin `UVM_HOME`, sigue siendo
`code/.uvm/` y `make uvm` la baja como siempre.

## RAM: el único parámetro que hay que mirar

Verilator parte los ~2300 archivos C++ que genera UVM en un *bucket* por core y
cada `g++` de esos pesa casi un giga. Con los 12 cores de una laptop y los ~4 GB
que Docker Desktop se asigna por defecto, el kernel mata el compilador:

```
g++: fatal error: Killed signal terminated program cc1plus
```

Por eso la imagen exporta `VLT_BUILD_JOBS=2`: los buckets se siguen generando de
a muchos, pero se compilan de a dos. Es más lento y entra en cualquier lado. Si
le diste 8 GB o más a Docker, `VLT_BUILD_JOBS=6` (o vacío, que son todos los
cores) acorta bastante:

```sh
docker run --rm -it -e VLT_BUILD_JOBS=6 -v "$PWD":/work verifythis make u4/tests
```

Fuera de Docker no cambia nada: sin `VLT_BUILD_JOBS`, `common.sh` sigue usando
todos los cores como siempre.

## Notas

- Los `obj_dir/` los escribe el contenedor dentro del repo montado, con el UID
  del contenedor (root). Si te molesta: `docker run --user "$(id -u)"`.
- No mezcles `obj_dir/` de macOS con los del contenedor: son objetos de otra
  plataforma y el link falla. `make clean` antes de cambiar de flujo.
- `make deck` y `npm run build` **no** andan con la imagen pelada: no trae Node,
  es para los ejemplos SystemVerilog nada más. En el devcontainer sí, que le
  agrega Node 22 encima.
- La imagen se construye para la arquitectura del host (Verilator se compila de
  fuente, no hay binarios prearmados). En Apple Silicon sale arm64 y anda igual,
  pero tarda más.
