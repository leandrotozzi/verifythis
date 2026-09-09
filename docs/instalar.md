# Instalar y correr los ejemplos

Los cuatro caminos para tener el curso corriendo en una máquina, en orden de
menos a más trabajo, y lo que hay que saber después: semillas, ondas, ccache y
qué corre el CI. Es lo que estaba en el README hasta que se lo acortó; acá está
entero.

El atajo: `make doctor` no compila nada y te dice qué falta y con qué comando se
instala en tu gestor de paquetes.

---

## Los comandos

El simulador del curso es **Verilator** — libre, sin licencia, y desde la
versión **5.050** mide **cobertura funcional** (covergroups), que es tema del
curso. No hay flujo Questa: los `run.do` y el DUT en VHDL se sacaron del repo.

```sh
make doctor          # ¿esta máquina puede correr el curso? qué falta y cómo se instala
make u3/tb-en-objetos            # una sección
make                 # los 38 ejemplos (UVM incluido)
make matrix          # idem, y regenera docs/verilator.md
make ejercicios      # las 19 soluciones: verifica que sigan siendo resolubles
```

**Empezá por `make doctor`.** No compila nada: mira que haya Verilator ≥ 5.050,
`z3`, `ccache` y el resto, y para lo que falte imprime el comando exacto de tu
gestor de paquetes. Existe porque los dos modos de falla más caros del curso son
**mudos** —sin `z3`, `randomize()` devuelve 0 sin decir nada; con un Verilator
anterior a 5.050, la cobertura funcional reporta 0 % sin una advertencia—, así
que un alumno puede perder una tarde antes de sospechar de la instalación.

> [!IMPORTANT]
> **`z3` hace falta desde el día 5.** Verilator resuelve `randomize()` con
> constraints llamando a un solver SMT externo. Sin él, `u5/varios-objetos`, `u6/transactions`, `u7/agents` y
> `u7/sequences` compilan, corren, y `randomize()` devuelve 0 sin decir nada.
> `apt install z3` / `brew install z3`. La imagen de Docker y el devcontainer ya
> lo traen.

**Instalá `ccache` antes de empezar.** Cada simulación se compila a un binario
nativo, y para las secciones con UVM eso son ~2300 archivos C++. Con `ccache` en
el `PATH`, `common.sh` exporta `OBJCACHE` solo y la segunda compilación no vuelve
a hacer el trabajo. Medido sobre `make u4/tests` con Verilator 5.052:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|--:|--:|
| la primera vez | ~1 min 30 | ~4 min |
| con el `obj_dir` borrado y `ccache` tibio | ~15 s | ~15 s |

Un hit de `ccache` es copiar un archivo, así que la segunda compilación tarda lo
mismo en cualquier máquina: lo caro se paga una vez. Lo que la cache **no** hace
es acelerar la sección de al lado — Verilator renombra los símbolos por diseño y
apenas el 22 % de los archivos coinciden entre dos secciones.

Y para repetir una corrida al azar, `SEED=N`:

```sh
SEED=7 make u7/sequences     # pasa +verilator+seed+7; run_sim imprime la semilla que usó
```

Para mirar ondas con **GTKWave** —Verilator las genera gratis— hay un opt-in:

```sh
cd code/u2/convencional && VLT_TRACE=1 bash run.sh && gtkwave vtalu.vcd
```

`VLT_TRACE=1` agrega el `--trace` de Verilator y prende el `$dumpfile`/`$dumpvars`
del top, que está detrás de un `` `ifdef `` porque sin el flag no compilaría.

`make` baja **UVM 2020.3.1** (Accellera `uvm-core`, la implementación de
referencia de IEEE 1800.2-2020) a `code/.uvm/` la primera vez. Cada ejemplo
tiene su `run.sh`; los flags comunes están en `code/verilator/common.sh`.

Un ejemplo **pasa** si compila, corre, sale con código 0 y su *Report Summary*
de UVM cierra en 0 `UVM_ERROR`. El único opt-out es `u4/reporting`, que rompe el
scoreboard a propósito para poder enseñar reporting.

### Ejercicios

**Diecinueve**, en [`code/ejercicios/`](../code/ejercicios/): el `run.sh` **falla hasta
que lo resolvés**, y la solución está al lado (`SOLUCION=1 bash run.sh`). Cada
directorio tiene sólo los archivos que se tocan; el resto del testbench sale de la
sección, por referencia.

Tres de ellos —`d5b`, `d5c` y `d7-semillas`— son el ciclo de *coverage
closure* hecho con las manos: medir una distribución, escribir el caso dirigido
que llena el bin que falta, y acumular cobertura con una regresión de cinco
semillas.

El decimotercero, `d7-final`, es el **capstone**: un esclavo APB de cuatro registros,
su especificación, y **nada más**. El testbench se escribe entero, desde una
hoja en blanco, y el corrector va por etapas — monitor, driver, scoreboard y
cobertura, un `STAGE N OK` cada uno. Se entrega con su **plan de verificación**
lleno: las cinco columnas, la plantilla y el plan del VTALU como ejemplo están en
**[`docs/plan-de-verificacion.md`](plan-de-verificacion.md)**.

Los dos últimos son los de la unidad opcional y van **después** del capstone.
`d8-ral` reusa el mismo DUT y el mismo testbench, con el mapa de registros de la
spec escrito como modelo de UVM —su segunda etapa la corrigen dos sequences de
`uvm-core` que nadie escribió—; `d8-fifo` es el **segundo capstone**: una FIFO
con backpressure, donde el scoreboard no puede ser una tabla de cuatro filas.

Los ejemplos **los corre el CI**, no sólo yo: cada push que toque `code/` corre
los que no usan UVM (segundos) más `u4/tests`, y todas las noches corren los 38 más
las 19 soluciones de los ejercicios. El badge `ejemplos` del README dice si están en verde
ahora, no en la fecha en que alguien los corrió a mano.

Lo que anda y lo que no —con versión, fecha y el número de cobertura de cada
ejemplo— está en **[`docs/verilator.md`](verilator.md)**. Los dos agujeros
que quedan: los *bins de transición* (`=>`) todavía no compilan, y `binsof` /
`intersect` en un cross se ignoran.

### Sin instalar nada: Codespaces

[![Abrir en Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/leandrotozzi/verifythis)

**Es el camino por defecto.** `.devcontainer/` trae Verilator, UVM y ccache ya
adentro, así que el botón —o **Code ▸ Codespaces ▸ Create codespace**— deja el
curso corriendo en el navegador, desde cualquier máquina. Las cuentas gratuitas
traen 60 horas-core por mes, de sobra para los siete días.

Va primero porque en macOS y en Windows instalar Verilator ≥ 5.050 es media
tarde de trabajo que no enseña nada de UVM. Si tenés Linux con un Verilator
reciente, saltá a la tercera.

### Con Docker, en tu máquina

La misma imagen del devcontainer, con el repo montado desde afuera: editás con
tu editor de siempre y corrés adentro.

```sh
docker build -t verifythis .                              # una vez, ~7 min
docker run --rm -it -v "$PWD":/work verifythis make u4/tests
```

La cache de `ccache` vive en `.ccache/` del repo montado —por eso sobrevive al
`--rm`—. Detalles, ajuste de RAM y limitaciones en [`docs/docker.md`](docker.md).

### A mano: Verilator ≥ 5.050

En Linux, el paquete de la distro suele estar atrasado: mirá `verilator --version`
antes de nada. En macOS Intel, Homebrew ya no compila fórmulas nuevas, así que va
de fuente. La receta que funciona (las tres trampas están en los `PATH`):

```sh
brew install m4 bison ccache z3   # el bison de macOS es 2.3, Verilator pide 3.x
git clone --depth 1 --branch v5.052 https://github.com/verilator/verilator
cd verilator
# m4 y bison de brew; flex NO: el de brew genera contra otro FlexLexer.h y no linkea
export PATH="/usr/local/opt/m4/bin:/usr/local/opt/bison/bin:$PATH"
autoconf && ./configure --prefix="$HOME/opt/verilator-5.052"
make -j"$(sysctl -n hw.ncpu)" && make install
```

Después, `$HOME/opt/verilator-5.052/bin` adelante en el `PATH`.

Los otros dos paquetes de esa línea no son adorno:

- **`z3`** es **obligatorio** desde el día 5. Verilator resuelve `randomize()`
  con constraints llamando a un solver SMT externo; sin él la compilación pasa,
  la simulación corre, y `randomize()` devuelve 0 — otra que no rompe, miente.
  Lo necesitan `u5/varios-objetos`, `u6/transactions`, `u7/agents` y `u7/sequences`.
- **`ccache`** lo detecta solo `common.sh`, y es lo que hace que la segunda
  sección con UVM compile en segundos.

<details>
<summary>En Windows: WSL 2</summary>

Una vez instalado Ubuntu, todo lo demás es idéntico a Linux.

```powershell
wsl --install -d Ubuntu     # PowerShell como administrador, y reiniciar
```

Adentro de Ubuntu, `sudo apt install git make g++ perl ccache z3` y después
Verilator de fuente, con la receta de arriba.

> [!IMPORTANT]
> Cloná el repo **dentro del sistema de archivos de WSL** (`~/verifythis`), no en
> `/mnt/c/...`. El puente a NTFS hace que la compilación de UVM tarde varias
> veces más.

Para las ondas: en Windows 11, WSLg abre GTKWave directo. En Windows 10, instalá
GTKWave nativo y abrí el `.vcd` desde `\\wsl$\Ubuntu\home\...`.

Docker Desktop también funciona, con el mismo `Dockerfile`.

</details>

### Si no podés ni eso

[EDA Playground](https://edaplayground.com) sirve para pegar una clase suelta y
experimentar con un concepto —polimorfismo, una `constraint`, un `covergroup`—.
No corre el curso entero, porque los testbenches son de muchos archivos, pero es
la red de seguridad del que hoy no puede instalar nada. Y sus simuladores
comerciales soportan los *bins de transición* que Verilator todavía no.

Cada ejemplo es **autocontenido a propósito**: podés copiar `code/u4/env/` a otro
lado y correrlo tal cual. Ver [`code/README.md`](../code/README.md).
