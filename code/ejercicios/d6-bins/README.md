# Día 6 · las sequences — cerrar un bin

El curso dice dos veces que el trabajo diario del verificador es **correr, mirar
qué bin falta, escribir el caso dirigido, volver a correr**. Este es ese
ejercicio.

El testbench es el de las sequences entero, con un test ya escrito
(`cierre_test.svh`) que manda un reset, 60 operaciones al azar, y después tu
sequence. **De todo eso, lo único que escribís es la última.**

```sh
bash run.sh
```

`run.sh` corre el test dos veces: la primera con `+SIN_CIERRE`, que saltea tu
sequence, y así ves la cobertura de partida. La segunda ya te incluye.

## Qué se pide

**`cierre_sequence.svh`** — una sequence de un solo item, que mande
`A = 8'hFF`, `B = 8'hFF` y `op = mul_op`. Es el bin *"las dos patas en `FF`,
multiplicando"* del plan de cobertura del testbench convencional, y 60
operaciones al azar no lo llenan.

Concretamente es la **fila 3** del plan de verificación
([`docs/plan-de-verificacion.md`](../../../docs/plan-de-verificacion.md)): el
**producto máximo** del multiplicador, la única fila de las doce cuya columna de
estímulo dice **caso dirigido**. Y eso no lo decidió nadie a mano: `FF` × `FF` es
una combinación entre 65 536, así que el random no la visita.
Que quede claro por las dudas: `FF` × `FF` **no desborda**. Da `FE01`, que entra
exacto en los 16 bits de `result`, y el DUT deja `ovf` en 0 en toda
multiplicación. Es el máximo del espacio de entrada — por eso el bin se llama
`mul_max`. El plan es lo que hace
evidente qué test hay que escribir — este.

Pero no lo pidas asignando los campos: **pedilo con `randomize() with {}`**. El
caso dirigido se pide en el punto de uso, y esa es la herramienta de las
transactions. `run.sh` chequea que tu archivo llame a `randomize()`.

Listo cuando `bash run.sh` imprime `EXERCISE OK` — o sea, cuando la cobertura
de la segunda corrida es **mayor** que la de la primera.

## Cómo se corre

```sh
bash run.sh              # con tu archivo
SOLUCION=1 bash run.sh   # con el de solucion/, para comparar
```

La semilla está fijada dentro del `run.sh` a propósito. Sin fijarla, algunas
corridas llenarían el bin solas con las 60 al azar y no habría nada que cerrar —
que es exactamente el tema del otro ejercicio, [`d6-semillas`](../d6-semillas/).

## Cuánto tarda

Este ejercicio compila UVM entera. Medido con Verilator 5.052:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~1 min 30 | ~4 min |
| las siguientes, con `ccache` | ~15 s | ~15 s |

El hit de `ccache` es copiar un archivo, así que la segunda compilación tarda lo
mismo en cualquier máquina. Instalalo antes de empezar —el `run.sh` lo detecta
solo— o usá Codespaces, que ya lo trae.

Hace falta también **`z3`**: Verilator resuelve `randomize()` con constraints
llamando a un solver SMT externo, y sin él `randomize()` devuelve 0 sin decir
nada.

## Pistas, en orden de utilidad

- **Si `randomize()` te devuelve 0, no es tu `with`.** `command_transaction`
  tiene un `dist` sobre `A` y sobre `B`, y Verilator resuelve el `dist`
  eligiendo un valor **antes** de mirar el resto de las constraints: si el que
  sorteó no cumple tu `with`, devuelve 0 en vez de buscar otro. Con
  `A dist {00 :/ 1, [01:FE] :/ 2, FF :/ 1}`, `with {A == 8'hFF}` resuelve una de
  cada cuatro veces. El rodeo es una línea y está en la sección Constrained random.
- Ese rodeo, además, es lo correcto acá aunque el simulador fuera perfecto: un
  caso **dirigido** no quiere un reparto de probabilidades, quiere un valor.
- `randomize()` se chequea con `if`, nunca con `assert()`. Un simulador con las
  asserts deshabilitadas no ejecuta el argumento, y tu transaction sale con lo
  que tenía.
- El `result` lo escribe el driver adentro del item, justo antes de
  `item_done()`: es válido recién **después** de que volvió `finish_item()`.

## Lo que practica

`randomize() with {}` y `constraint_mode()`, `body()` y
`start_item`/`finish_item`, y leer un reporte de cobertura para decidir qué
escribir. Que es lo que hace que *coverage closure* sea un verbo y no un
sustantivo: no se escribe un test por bin, se mira el reporte y se escriben
tres líneas.
