# Día 6 · las sequences — el tester del día 3, ahora como sequence

El testbench es el de las sequences entero: agent, sequencer, driver, monitores,
cobertura y scoreboard. **No hay que tocar nada de eso**, y el `run.sh` lo
verifica con `intocables.sha` antes de compilar. Lo único que falta es el
estímulo.

## Qué se pide

1. **`mult_sequence.svh`** — una `uvm_sequence #(command_transaction)` que:
   - mande primero un `rst_op`;
   - después mande **20 multiplicaciones** con `A` y `B` al azar;
   - cuente cuántas mandó y se quede con el **resultado más grande** que vio;
   - imprima al final de `body()`, con verbosidad `UVM_NONE` y con el id
     `MULT SEQ`:

     ```
     items=<n> max=<m>
     ```

2. **`mult_test.svh`** — un test que extienda `base_test`, cree la sequence por
   la factory y la arranque sobre `sequencer_h`, con el objection alrededor.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

## Cuánto tarda

Este ejercicio compila UVM entera. Medido con Verilator 5.052:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~1 min 30 | ~4 min |
| las siguientes, con `ccache` | ~15 s | ~15 s |

El hit de `ccache` es copiar un archivo, así que la segunda compilación tarda lo
mismo en cualquier máquina. Instalalo antes de empezar —el `run.sh` lo detecta
solo— o usá Codespaces, que ya lo trae.

## Pistas, en orden de utilidad

- **El primer item tiene que ser un `rst_op`.** El VTALU arranca con `reset_n`
  en 0 y nunca levanta `done`; sin reset el driver se queda esperando y tu
  sequence se cuelga en el primer `finish_item()`. Mirá `reset_sequence.svh`.
- Para que salga sólo `mul_op` tenés dos caminos, los dos del día 5:
  `randomize() with {op == mul_op;}` —`op` no tiene `dist`, así que acá el `with`
  funciona— o `command.op = mul_op; command.op.rand_mode(0);` antes de
  `randomize()`.
- `command.result` lo escribe **el driver**, adentro del item, justo antes de
  `item_done()`. O sea que recién es válido **después** de que volvió
  `finish_item()`. Si lo leés antes, te va a dar 0 y el corrector te lo va a
  decir.
- La sequence es un `uvm_object`: `` `uvm_object_utils ``, constructor de un solo
  argumento, y `body()` es una **task**.

## Lo que practica

`body()` y el ciclo de vida de la sequence, `start_item()` / `finish_item()`,
randomización tardía y `rand_mode()` / `with {}`. Y la idea de fondo:
**el estímulo se cambia sin tocar una línea de estructura**. Los dos archivos que
escribís son los dos únicos que este ejercicio tiene.
