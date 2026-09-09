# Ejercicios

**Dieciocho**, repartidos por día. Cada uno se corrige solo: el `run.sh` falla hasta
que lo resolvés.

La columna **Necesita** dice qué hace falta tener instalado además de Verilator:
`UVM` es "compila la librería entera la primera vez" y `z3` es el solver de
`randomize()`, que sin él devuelve 0 en silencio.

| | Día | Qué | Sale de | Necesita |
|---|:--:|---|---|---|
| [`d1`](d1/) | 1 | Una operación nueva, de punta a punta: RTL, TB y cobertura | unidades 1 y 2 | — |
| [`d1b`](d1b/) | 1 | **Las ondas**: el log da una línea y el resto está en el `.vcd` | La spec del VTALU · Interfaces y BFM | — |
| [`d2`](d2/) | 2 | Un tester que sólo multiplica, sin copiar la clase entera | unidad 3 | — |
| [`d3`](d3/) | 3 | El mismo tester, ahora con factory override y sin tocar el `env` | unidad 4 | UVM |
| [`d4`](d4/) | 4 | Un subscriber más colgado del analysis port | unidad 5 | UVM |
| [`d4b`](d4b/) | 4 | El `#500` es un parche: la FIFO sin tope y la objection que falta | unidad 5 | UVM |
| [`d5`](d5/) | 5 | El scoreboard grita y el DUT está sano: encontrá el bug | unidades 5 y 6 | UVM |
| [`d5b`](d5b/) | 5 | Medí tu `dist`: los pesos están bien y el histograma miente | Constrained random | z3 |
| [`d6-agents`](d6-agents/) | 6 | El agent que sólo mira: `is_active` y el ámbito del `config_db` | Agents | UVM |
| [`d6-sequences`](d6-sequences/) | 6 | Una sequence que sólo multiplica, sin tocar la estructura | Sequences | UVM |
| [`d6-bins`](d6-bins/) | 6 | Cerrar un bin con `randomize() with {}` | Constrained random y Sequences | UVM · z3 |
| [`d6-semillas`](d6-semillas/) | 6 | Cinco semillas y un merge: qué es una regresión | Constrained random y Sequences | UVM · z3 |
| [`d6-debug`](d6-debug/) | 6 | **Tres bugs plantados**: uno cuelga, uno termina en `t=0`, uno miente en verde | Tests, Agents y Sequences | UVM · z3 |
| [`d7-sva`](d7-sva/) | 7 | El módulo heredado viola el protocolo: escribí la property que lo ve | Assertions | UVM |
| [`d7-final`](d7-final/) | 7 | **Capstone**: un esclavo APB, su spec, y el testbench entero desde cero | todo | UVM · z3 |
| [`d8-ral`](d8-ral/) | 8 | El mapa de registros de la spec, como modelo de UVM | RAL (unidad 9) | UVM |
| [`d8-dpi`](d8-dpi/) | 8 | El modelo de referencia en C, y las dos mutaciones que lo prueban | DPI (unidad 9) | UVM · z3 |
| [`d8-fifo`](d8-fifo/) | 8 | **Capstone 2**: una FIFO con backpressure, donde el scoreboard no puede ser una tabla | todo | UVM · z3 |

Tres de la tabla —`d5b`, `d6-bins` y `d6-semillas`— son el ciclo de
*coverage closure* hecho con las manos: medir una distribución, escribir el caso
dirigido que llena el bin que falta, y acumular cobertura con una regresión de
varias semillas. El curso lo cuenta dos veces; acá se hace.

[`d7-final`](d7-final/) es distinto de los otros y a propósito:
**no hay archivo con un agujero**. Hay un DUT que no es la VTALU —un esclavo APB
de cuatro registros de 32 bits—, su especificación, y una hoja en blanco. El
corrector va por etapas —monitor, driver, scoreboard, cobertura y las properties
del protocolo— y cada una imprime su `STAGE N OK`, así que se puede terminar de a
una. Y dos filas del plan de verificación vienen **vacías**: las escribe el alumno.

[`d8-ral`](d8-ral/) es el de la unidad opcional y va **después** del capstone:
reusa el mismo DUT y el mismo testbench, y agrega encima el modelo de registros.
También va por etapas, y la segunda la corrigen dos sequences de `uvm-core` que
nadie escribió.

Y el último, [`d8-fifo`](d8-fifo/), es el **segundo capstone**, para el que ya
entregó el primero. El protocolo es más simple —no hay direcciones ni wait
states— y aun así es más difícil: el scoreboard del APB podía ser una tabla de
cuatro filas, y el de una FIFO no, porque una FIFO tiene orden y ocupación. El
bug de `+BUG=1` está en una **bandera**, no en los datos: un scoreboard que sólo
compara lo que sale por `rd_data` pasa en verde con el DUT roto.

```sh
cd code/ejercicios/d1
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

## Cómo están armados

Cada directorio tiene **sólo los archivos que vas a tocar**. El resto del
testbench sale de la sección correspondiente, por referencia: los `+incdir` del
`run.sh` ponen este directorio primero, así que tu versión de un archivo le gana
a la de la sección. Nada de lo que hagas acá rompe los ejemplos del curso.

Siete —`d3`, `d4`, `d4b`, `d6-debug`, `d6-sequences`, `d7-sva` y `d8-dpi`— traen
además un `intocables.sha`: la lista de los archivos que el enunciado dice **no**
tocar, con su hash, y el `run.sh` la chequea antes de compilar. No es
desconfianza: en esos siete el ejercicio *está* en no tocarlos. En `d4b`, volver
a ponerle el tope a la FIFO hace pasar el corrector sin haber entendido nada. Instanciar el `mult_tester` a
mano en el `env.svh` de `d3` hace pasar el corrector sin escribir un solo
`set_type_override`, que es justo el tema.

`SOLUCION=1` corre la solución sin pisar tu archivo: en los que usan UVM agrega
un `+incdir+solucion` adelante de todo, y en los otros cuatro le pone el prefijo
`solucion/` a los fuentes que compila.

La excepción es `d7-final`: ahí no hay sección de la que salga el resto, porque el
resto **es** el ejercicio. Lo único que viene hecho es el DUT, el `top.sv` y el
módulo de estímulo que se usa para probar el monitor. Y `d8-ral` es el caso
inverso: lo que le falta sale de dos lados a la vez —el testbench, de
`d7-final/solucion/`; el adapter y los tests, de `code/u9/ral/`—, así que se
resuelve con el capstone ya hecho.

Catorce usan UVM: la primera compilación tarda ~1 min 30 en una laptop de 12 cores
y ~4 min en un Codespaces gratis; los dos capstones tardan ~2 min.
**Las siguientes son 15 segundos en cualquiera de las dos**, si tenés `ccache`
instalado — el `run.sh` lo detecta solo. El tiempo de cada uno está en su README.

Los cuatro que no usan UVM —`d1`, `d1b`, `d2` y `d5b`— corren sin esperar nada.
`d1b` es además el único que compila con `--trace`: deja `ondas.vcd` al lado,
porque las ondas *son* el ejercicio. Los siete que randomizan con constraints
—`d5b`, `d6-bins`, `d6-debug`, `d6-semillas`, `d7-final`, `d8-dpi` y `d8-fifo`—
necesitan además
**`z3`**: sin él `randomize()` devuelve 0 en silencio. Ver
[`docs/verilator.md`](../../docs/verilator.md).

## Para el que dicta

`make ejercicios` corre las dieciocho **soluciones**. No comprueba que un alumno
lo haya resuelto: comprueba que los dieciocho sigan siendo resolubles cuando
cambia el código del curso.

Los cinco del día 6, los dos del día 7 y los tres del día 8 compilan un testbench
entero con UVM: son los más lentos.

Dos de ellos tienen la semilla **fijada**, y es a propósito: `d6-bins` la clava
en el `run.sh` (`export SEED=7`) porque necesita que las 60 operaciones al azar
*no* llenen el bin que hay que cerrar, y `d6-semillas` la recorre de 1 a 5 en el
`regresion.sh` porque necesita que las cinco den resultados distintos. Sin
fijarlas, los dos serían intermitentes — que es justo el defecto que enseñan a
evitar.
