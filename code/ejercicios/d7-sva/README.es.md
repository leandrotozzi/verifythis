[English](README.md) · **Castellano**

# Día 7 — el módulo heredado viola el protocolo y nadie lo sabía

El testbench es el de las assertions entero, con sus dos VTALU: una la maneja el
driver del agent, la otra la maneja `vtalu_tester_module` — el "tester del jefe",
un módulo de siempre, sin una línea de UVM, que está en producción hace años.

Ese módulo **viola el protocolo**: para la multiplicación no llama a
`bfm.send_op()` sino que mueve los cables a mano, y aprovecha los ciclos que el
DUT tarda en contestar para ir dejando listo el operando de la próxima.

El scoreboard **no lo ve**, y no es que esté roto: el multiplicador latchea `A` y
`B` en el primer flanco, así que el resultado sale bien igual. Mil comparaciones,
cero diferencias.

## Qué se pide

**`vtalu_bfm.sv`** — escribí la property que sí lo ve. La regla está en prosa
desde la slide 1 del día 1: *mientras `start` está arriba, los operandos y la
operación no se tocan.*

Las dos properties de `done` ya están hechas y sirven de molde. La acción de
falla tiene que ser un `` `uvm_error `` con el id `"SVA"`: si dejás que la
assertion termine en `$stop`, la simulación se corta, el *Report Summary* no se
imprime y el corrector no ve nada.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

El corrector pide **tres** cosas, y la del medio es la que hace el ejercicio:

1. que la property dispare sobre `modulo_bfm`, que es la que viola el protocolo;
2. que **no** dispare ni una vez sobre `clase_bfm`, que es la que maneja el
   driver y lo respeta;
3. que el scoreboard siga en verde, para que quede claro quién cazó qué.

## Cuánto tarda

Este ejercicio compila UVM entera. Medido con Verilator 5.052:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~1 min 30 | ~4 min |
| las siguientes, con `ccache` | ~15 s | ~15 s |

## Pistas, en orden de utilidad

- Si tu property no dispara nunca, agregale un `cover property` con el mismo
  antecedente y mirá el `user:` del reporte de cobertura. Un cover en 0 quiere
  decir que el antecedente no ocurre — no que el DUT esté sano.
- Si dispara **sobre las dos** interfaces, el problema es el **flanco**. Mirá con
  qué flanco escribe `bfm.send_op()` los operandos, y acordate de que SVA
  muestrea en la región *preponed*: una señal escrita **en** un flanco no se ve
  en ese flanco, se ve en el siguiente. Las dos properties de `done` que ya están
  usan `@(posedge clk)`; ésta no puede.
- `$stable(x)` compara contra el muestreo anterior, que es exactamente lo que
  hace falta. Y son tres señales, no una: `A`, `B` y `op_set`.
- La implicación va `|=>` y no `|->`: el consecuente es *"en el flanco
  siguiente"*, porque un operando que cambia en el mismo flanco en que `start`
  sube no es una violación, es el arranque de la transacción.
- Si el `run.sh` compila y no dispara nada de nada, revisá que el `else` de tu
  assertion tenga el `` `uvm_error `` con el id `"SVA"` — el corrector lo busca
  por ese id.

## Lo que practica

La property de las assertions (`$stable`, `|=>`, `disable iff`), la elección del
**flanco de muestreo** —que es la lección de la sección— y la idea de fondo: una
assertion vive en la interface y por lo tanto chequea **a todos los que la usen**,
incluido el código que nadie escribió pensando en UVM.
