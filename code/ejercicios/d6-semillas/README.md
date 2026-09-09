# Día 6 ·las sequences — la misma sequence, otra semilla

La tabla *"así se cierra la cobertura"* de la seccion Constrained random termina con una fila que
el curso nunca hace: **repetir con otra semilla**. Este ejercicio la hace.

Es el único del curso donde no escribís SystemVerilog. El testbench y el test ya
están: reset y **25** operaciones al azar. Lo que escribís es la regresión.

```sh
bash run.sh
```

## Qué se pide

**`regresion.sh`** — que corra el mismo test con las semillas **1 a 5**, deje la
cobertura de cada una en `$VLT_OBJ/seed.<N>.dat`, y mergee las cinco en
`$VLT_OBJ/regresion.dat`.

El archivo tiene arriba todo lo que hay disponible (`run_sim`, `SEED`,
`$VLT_OBJ`) y el comando del merge. Son seis líneas de shell.

Listo cuando `bash run.sh` imprime `EXERCISE OK` — o sea, cuando el merge de las
cinco cubre **más** que la mejor de las cinco sola.

## Cómo se corre

```sh
bash run.sh              # con tu regresion.sh
SOLUCION=1 bash run.sh   # con el de solucion/, para comparar
```

## Por qué 25 operaciones y no 1000

Porque con 1000 **esto no funciona**, y esa es la mitad de la lección.

Está medido y está en la slide *"otra semilla, y de nuevo"*: `code/u2/convencional` y
`code/u7/sequences` dan 66 de 76 bins con la semilla por defecto, con la 7 y con la 8, y
el merge de las tres también da 66. Con 1000 operaciones el random ya llegó hasta
donde puede llegar, y los 10 bins que faltan no faltan por suerte — son los
slots de `rst_op` y `no_op` en el cross, que `ignore_bins` debería sacar y
Verilator no saca. Ninguna semilla los va a tocar nunca.

Con 25 el estímulo todavía no saturó, y ahí sí: cada semilla cubre un pedazo
distinto y el merge suma. Que es exactamente la situación de un chip de verdad,
donde el espacio es tan grande que nunca se satura.

**La regla que queda:** otra semilla sirve para **acumular** mientras el estímulo
no saturó, y para **reproducir** un fallo intermitente. No sirve para llenar un
bin que el estímulo no puede alcanzar — para eso está el caso dirigido del
ejercicio [`d6-bins`](../d6-bins/).

## Cuánto tarda

Compila UVM entera la primera vez: ~1 min 30 en una laptop de 12 cores, ~4 min en
un Codespaces gratis. Las siguientes, ~15 s en cualquiera de las dos con `ccache`
instalado. Las cinco simulaciones juntas son un segundo: son 25 operaciones cada
una.

Hace falta también **`z3`**, el solver de `randomize()`.

## Lo que practica

Que una **regresión** es un test corrido muchas veces con semillas distintas, no
muchos tests distintos. Que la cobertura **se acumula** y hay que mergearla —
`verilator_coverage --write` es acá lo que el merge de `ucdb` es en Questa. Y que
`SEED=N` es lo que hace reproducible un fallo que aparece una vez cada diez
corridas: sin eso no se debuggea, porque no se puede repetir.
