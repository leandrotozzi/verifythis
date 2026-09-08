# Día 1 — las ondas: el log no alcanza

El apéndice de debug dice que las ondas son la herramienta con la que se hace el
**47 % del trabajo**. Éste es el ejercicio donde eso se practica: es el único
del curso que **no se resuelve leyendo el log**.

Corré:

```sh
bash run.sh
```

La simulación aborta con **una sola línea**:

```
FAILED: A: e5  B: 0  op: mul_op result: fe01 ovf: 0
```

Y ahí se termina lo que el log te da. `e5 * 00` es `0`, no `fe01`. El scoreboard
tiene razón, el DUT está sano, y el número que salió no es de esta operación.

## Qué se pide

### 1 · Leer las ondas

El `run.sh` compila siempre con `--trace`, así que la corrida deja **`ondas.vcd`**
al lado. Abrilo:

```sh
gtkwave ondas.vcd     # o surfer, o el visor que uses
```

Poné en el visor `clk`, `start`, `op`, `A`, `B`, `done` y `result`, y contestá
dos preguntas escribiendo los tiempos en **`respuesta.txt`**, uno por línea, en
picosegundos y sin unidad:

1. ¿En qué instante sube `done` por **primera vez**?
2. ¿En qué instante sube `done` de la **primera multiplicación**? (buscá el
   primer tramo con `op = mul_op`, o `start_mult` en 1)

```
# respuesta.txt
1234
5678
```

Los dos números salen del visor y de ningún otro lado: no están en el log.

> Mientras estés ahí, mirá `A` y `B` en el instante de la segunda respuesta y
> compará con los que imprimió el `FAILED`. Ésa es la respuesta a *por qué*.

### 2 · Arreglar la BFM

Con las ondas a la vista se ve solo: `done` de una multiplicación llega **tres
ciclos** después del `start`, y el de las demás operaciones llega en uno. El
`send_op` de `vtalu_bfm.sv` **cuenta flancos** en vez de esperar el handshake,
así que vuelve antes de tiempo y el estímulo siguiente pisa `A` y `B` mientras
el multiplicador todavía está calculando.

Se arregla con **una línea**. El TODO está en el archivo.

Listo cuando `bash run.sh` imprime `EJERCICIO OK`.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

El corrector va por etapas y cada una imprime su `ETAPA N OK`, como el capstone.
Los dos tiempos que pide son los mismos antes y después de arreglar el bug
—ocurren antes de que nada se desincronice—, así que la respuesta no se te
vence cuando toques la BFM.

## Cuánto tarda

No usa UVM: compila y corre en **segundos**, sin `ccache` y sin `z3`.

## Lo que practica

- **Abrir un `.vcd` y leer un tiempo.** Suena trivial hasta que hace falta.
- Que un log dice *que* algo falló y casi nunca *por qué*. El `FAILED` de este
  ejercicio es correcto, completo, y no alcanza.
- La regla de oro del apéndice de debug: **el sospechoso número uno nunca es el
  DUT**, es el testbench que lo mira.
- Y la lección de protocolo que vuelve en el capstone del día 7, con el wait
  state del APB: **no cuentes ciclos, esperá el handshake.** El día que el DUT
  tarde un ciclo más, un testbench que cuenta no se entera.
