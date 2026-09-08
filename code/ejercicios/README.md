# Ejercicios

**Catorce**, repartidos por día. Cada uno se corrige solo: el `run.sh` falla hasta
que lo resolvés.

| | Qué | Sale de |
|---|---|---|
| [`d1`](d1/) | Una operación nueva, de punta a punta: RTL, TB y cobertura | unidades 1 y 2 |
| [`d1b`](d1b/) | **Las ondas**: el log da una línea y el resto está en el `.vcd` | La spec del VTALU · Interfaces y BFM |
| [`d2`](d2/) | Un tester que sólo multiplica, sin copiar la clase entera | unidad 3 |
| [`d3`](d3/) | El mismo tester, ahora con factory override y sin tocar el `env` | unidad 4 |
| [`d4`](d4/) | Un subscriber más colgado del analysis port | unidad 5 |
| [`d5`](d5/) | El scoreboard grita y el DUT está sano: encontrá el bug | unidades 5 y 6 |
| [`d5b`](d5b/) | Medí tu `dist`: los pesos están bien y el histograma miente | Constrained random |
| [`d6-agents`](d6-agents/) | El agent que sólo mira: `is_active` y el ámbito del `config_db` | Agents |
| [`d6-sequences`](d6-sequences/) | Una sequence que sólo multiplica, sin tocar la estructura | Sequences |
| [`d6-bins`](d6-bins/) | Cerrar un bin con `randomize() with {}` | Constrained random y Sequences |
| [`d6-semillas`](d6-semillas/) | Cinco semillas y un merge: qué es una regresión | Constrained random y Sequences |
| [`d7-sva`](d7-sva/) | El módulo heredado viola el protocolo: escribí la property que lo ve | Assertions |
| [`d7-final`](d7-final/) | **Capstone**: un esclavo APB, su spec, y el testbench entero desde cero | todo |
| [`d8-ral`](d8-ral/) | El mapa de registros de la spec, como modelo de UVM | RAL (unidad 9) |
| [`d8-fifo`](d8-fifo/) | **Capstone 2**: una FIFO con backpressure, donde el scoreboard no puede ser una tabla | todo |

Tres de la tabla —`d5b`, `d6-bins` y `d6-semillas`— son el ciclo de
*coverage closure* hecho con las manos: medir una distribución, escribir el caso
dirigido que llena el bin que falta, y acumular cobertura con una regresión de
varias semillas. El curso lo cuenta dos veces; acá se hace.

El decimotercero, [`d7-final`](d7-final/), es distinto de los otros y a propósito:
**no hay archivo con un agujero**. Hay un DUT que no es la VTALU —un esclavo APB
de cuatro registros—, su especificación, y una hoja en blanco. El corrector va
por etapas —monitor, driver, scoreboard, cobertura— y cada una imprime su
`ETAPA N OK`, así que se puede terminar de a una.

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

`SOLUCION=1` agrega `+incdir+solucion` adelante de todo, así que corre la
solución sin pisar tu archivo.

La excepción es `d7-final`: ahí no hay sección de la que salga el resto, porque el
resto **es** el ejercicio. Lo único que viene hecho es el DUT, el `top.sv` y el
módulo de estímulo que se usa para probar el monitor. Y `d8-ral` es el caso
inverso: lo que le falta sale de dos lados a la vez —el testbench, de
`d7-final/solucion/`; el adapter y los tests, de `code/u9/ral/`—, así que se
resuelve con el capstone ya hecho.

Diez usan UVM: la primera compilación tarda ~1 min 30 en una laptop de 12 cores
y ~4 min en un Codespaces gratis. **Las siguientes son 15 segundos en cualquiera
de las dos**, si tenés `ccache` instalado — el `run.sh` lo detecta solo. El
tiempo de cada uno está en su README.

Los tres que no usan UVM —`d1`, `d1b` y `d5b`— corren sin esperar nada. `d1b`
es además el único que compila con `--trace`: deja `ondas.vcd` al lado, porque
las ondas *son* el ejercicio. `d5b`,
`d6-bins`, `d7-final` y todo lo que randomice con constraints necesita además
**`z3`**: sin él `randomize()` devuelve 0 en silencio. Ver [`docs/verilator.md`](../../docs/verilator.md).

## Para el que dicta

`make ejercicios` corre las quince **soluciones**. No comprueba que un alumno lo
haya resuelto: comprueba que los quince sigan siendo resolubles cuando cambia el
código del curso.

Los cuatro del día 6 y los tres del día 7 compilan un testbench entero con UVM:
son los más lentos.

Dos de ellos tienen la semilla **fijada adentro del `run.sh`**, y es a propósito:
`d6-bins` necesita que las 60 operaciones al azar *no* llenen el bin que hay que
cerrar, y `d6-semillas` necesita que las cinco semillas den resultados
distintos. Sin fijarlas, los dos serían intermitentes — que es justo el defecto
que enseñan a evitar.
