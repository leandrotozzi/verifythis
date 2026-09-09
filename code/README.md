# Ejemplos de código

Un directorio por unidad —`u2/` a `u9/`—, y adentro un directorio por ejemplo,
con el nombre de la sección que lo usa. Cada ejemplo es **autocontenido a
propósito**: podés copiar `code/u4/env/` a otro lado y correrlo tal cual. Por eso
`vtalu_bfm.sv`, `vtalu_pkg.sv` y compañía aparecen repetidos entre unidades — no
es duplicación a limpiar, es que cada ejemplo muestra su propia versión de esos
archivos a medida que el testbench evoluciona.

| | Unidad | Ejemplos |
|:--|:--|:--|
| `u2/` | El testbench sin UVM | `convencional`, `interfaces-bfm` |
| `u3/` | La OOP que UVM da por sabida | `clases`, `polimorfismo`, `estaticas`, `parametricas`, `factory`, `tb-en-objetos` |
| `u4/` | Entra UVM | `tests`, `components`, `env`, `reporting` |
| `u5/` | Cómo hablan los componentes | `varios-objetos`, `analysis-ports`, `threads`, `put-get` |
| `u6/` | El dato | `jerarquias`, `transactions` (+ `constraints`) |
| `u7/` | El testbench reutilizable | `agents`, `callbacks`, `sequences` (+ `virtual`) |
| `u8/` | La otra mitad | `assertions` |
| `u9/` | RAL — la unidad opcional | `ral` |

No hay `u1/`: el código de la unidad 1 es el DUT, que vive en `code/vtalu_dut/`
porque lo usan todos.

`u9/ral` es la excepción a lo de *autocontenido*, y a propósito: no trae DUT ni
testbench, los toma del capstone (`ejercicios/d7-final/`) por `+incdir`. Es la
forma de decir en el código lo que la unidad dice en las slides — RAL es una capa
sobre un testbench que ya funciona, no un testbench distinto.

## El idioma de `code/`

**Todo lo que hay acá adentro está en inglés**, y es a propósito: comentarios,
`TODO(exercise N)`, los mensajes que imprimen los correctores, los `$display` que
narran un ejemplo, y las cabeceras de los `run.sh`.

La razón es una sola y vale la pena decirla entera. El curso se dicta en dos
idiomas, y las slides no pegan el código: lo **incluyen** con `{{code:}}`. Si los
comentarios estuvieran en el idioma del curso habría que mantener dos copias de
`code/` —dos veces los ejemplos, dos veces los ejercicios, dos veces las
soluciones— y el día que una se arregla la otra queda rota sin que nada avise.
Escribirlo una sola vez, en inglés, es lo que hace que las dos versiones del
curso muestren y corran exactamente el mismo código. Y de paso es el idioma en el
que el alumno va a escribir comentarios en el trabajo.

**La única excepción son los `README.md`**, que son el enunciado del ejercicio y
no documentación del código: ahí sí hay dos, `README.md` en castellano y
`README.en.md` al lado. `npm run check` verifica que el par no se haya
desincronizado — ver `tools/lint-i18n.mjs`.

Los identificadores son otra cosa y no se traducen: la nomenclatura de UVM ya es
inglesa (`driver`, `scoreboard`, `env`), y las pocas excepciones en castellano
—la bandeja de fernet de `u6/jerarquias`, el `chequeo` de los correctores,
`clase_`/`modulo_` de `u7/agents`, que además no pueden llamarse `class_`/`module_`
porque son keywords— son metáforas del curso y se explican en la slide.

## Requisitos

**Verilator ≥ 5.050** — libre, sin licencia. Los covergroups entraron en esa
versión: antes la cobertura funcional no se medía. Qué anda y qué no, con el
número de cobertura de cada ejemplo, en
[`../docs/verilator.md`](../docs/verilator.md).

UVM 2020.3.1 (Accellera `uvm-core`, IEEE 1800.2-2020) se baja aparte, una sola
vez: `make uvm` (o lo hace `make` solo). Verilator la soporta oficialmente desde
5.052.

## Correr un ejemplo

```sh
make u3/tb-en-objetos             # desde la raíz del repo
cd code/u3/tb-en-objetos && ./run.sh
```

Cada directorio de ejemplo trae:

| Archivo     | Qué es |
|-------------|--------|
| `run.sh`    | compila con Verilator y simula |
| `dut.f`     | fuentes del DUT |
| `tb.f`      | lista de fuentes del testbench |

`code/verilator/` tiene lo compartido por los `run.sh`: los flags, el shim de
DPI que hace compilar UVM, y cuatro repros mínimos de limitaciones de
Verilator —los bins de transición y `binsof`/`intersect`, las opciones del
covergroup (`at_least`, `weight`, `merge_instances`), `solve ... before` y
`randomize() with` sobre un campo con `dist`— explicados en
`docs/verilator.md`. El quinto, `repro-vif-task.sv`, documenta un bug que **ya
se arregló** en Verilator 5.052 y queda como evidencia fechada.
Se corren a mano; `make matrix` sólo corre los `run.sh` de `code/u*/`.

Los ejemplos con varias variantes (`u3/polimorfismo`, `u3/estaticas`,
`u3/parametricas`, `u5/varios-objetos`, `u5/threads`) tienen un subdirectorio por
variante, cada uno con su `run.sh`.

`u8/assertions` es el único ejemplo cuyo `run.sh` compila con `--assert`, y el
único que corre dos veces: una limpia y otra con `+BUG=1`, que es lo que hace
gritar a la property.

`u6/transactions/constraints/` es la excepción a la regla de autocontención: son los cuatro experimentos
de la unidad de Constrained Random, sin UVM y sin DUT, con un solo `run.sh` que
compila los cuatro tops. Compilan en segundos y se pueden correr sueltos.

`u7/sequences/virtual/` es la otra: la **sequence virtual**, que necesita las dos VTALU
con los dos agents **activos** y por lo tanto un `top.sv` y un `env.svh`
distintos. En vez de copiar el ejemplo entero, ese directorio tiene sólo los
cinco archivos que cambian y trae el resto por `+incdir`. Lo que enseña es
exactamente el tamaño del diff.

`u7/callbacks/` es la tercera, y por la misma razón: el diff contra `u7/agents`
son **dos líneas** del driver —`` `uvm_register_cb `` y `` `uvm_do_callbacks ``—
más el callback y el test que lo cuelga. Copiar los 900 líneas del ejemplo de al
lado para mostrar dos escondería justo lo que se quiere mostrar, así que su
`tb.f` pone `+incdir+tb_classes` **antes** de `+incdir+../agents/tb_classes` y
sólo `driver.svh` le gana al de la otra sección. Es el mismo mecanismo que usan
los ejercicios.

## Archivos de salida esperada

Los `.txt` que muestran las slides (`u4/tests/output.txt`, los de `u5/threads`, los de
`u4/reporting`) **no son basura de simulación**: son la salida real de correr el
ejemplo, capturada a propósito para que la slide muestre lo mismo que va a ver
el alumno en su terminal. Se regeneran con:

```sh
sh tools/regen-outputs.sh          # todas
sh tools/regen-outputs.sh u4/reporting     # solo las que matcheen
```

No es parte de `make`: se corre a mano cuando cambia la versión de UVM o del
simulador. Cada build con UVM tarda varios minutos.

`u4/tests/output.questa` es distinto: es la corrida de referencia con Questa y UVM
1.1d, de antes de sacar el flujo Questa del repo. Ya no se muestra en ninguna
slide — queda como **testigo** de que la cadena de comparación cierra (Questa
1.1d → Verilator + UVM 1.2 → Verilator + UVM 2020.3.1). No lo borres, pero
tampoco lo actualices.

> Los `.txt` de u4/reporting salen de un scoreboard con un bug puesto a propósito
> (`add_op` suma de más), que es lo que le permite a la sección mostrar cómo se
> ve un `uvm_error` y cómo se lo silencia. `scoreboard2.txt` es la misma
> corrida con `set_report_severity_action_hier()` puesto; el script lo hace
> tocando `env.svh` y dejándolo como estaba.
