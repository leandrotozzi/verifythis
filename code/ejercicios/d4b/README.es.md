[English](README.md) · **Castellano**

# Día 4 — el `#500` es un parche

El testbench es el de *put y get*, con **una línea cambiada**: la FIFO del `env`
viene sin tope (`new("command_f", this, 0)`).

Con el tamaño 1 de siempre, `put()` bloqueaba al tester hasta que el driver
sacaba el comando anterior. Esa contrapresión era lo que mantenía al tester al
ritmo del bus — sin que nadie lo hubiera diseñado así. Sin tope no bloquea nadie:
el tester vacía sus mil comandos en `t = 0`, espera el `#500` de siempre, baja la
objection, y la simulación **termina en verde con el bus a medio llenar**.

## Qué se pide

**`driver.svh`** — que el driver sostenga una objection **mientras tiene un
comando en vuelo**. El par es `phase.raise_objection(this)` /
`phase.drop_objection(this)`, el mismo del test del día 3, y `phase` es el
argumento del `run_phase`.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

`env.svh` no se toca: la FIFO sin tope **es el DUT de este ejercicio**. Volver a
ponerle el tope esconde el problema en vez de arreglarlo, y el
`shasum -c intocables.sha` del corrector lo caza antes de compilar.

## Por qué el `#500` nunca fue la solución

La sección de *put y get* lo dice de pasada y acá se cobra: `#500` es un número
mágico que alguien midió una vez. Con la FIFO de tamaño 1 alcanzaba de casualidad
—el tester ya iba al ritmo del bus, así que le faltaba poco—; con la FIFO sin
tope no alcanza ni de lejos. Las dos veces el problema es el mismo: **el tester
no sabe cuándo terminó el bus**. Sabe cuándo terminó de *poner*.

El que sí sabe es el driver, porque es el que maneja. Por eso la objection va
ahí, y por eso este es el patrón que usa cualquier driver de UVM de verdad.

Y el detalle de dónde va el par, que es lo que decide si el ejercicio anda:
**después** del `get()`, no alrededor. Alrededor, el driver sostiene una
objection esperando trabajo que no va a llegar, y el test no termina nunca.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con el de solucion/, para comparar
```

## Cuánto tarda

Compila UVM entera, como el resto de los ejercicios del día 4:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~1 min 30 | ~4 min |
| las siguientes, con `ccache` | ~15 s | ~15 s |

## Lo que practica

Objections de verdad —quién las levanta y por qué ése y no otro—, `put()`
bloqueante y contrapresión, y la lección de fondo: **un `#N` en un testbench es
una pregunta sin contestar**. Y de paso, el modo de falla más caro de UVM: una
simulación que termina antes de tiempo **no falla**. Dice PASS.
