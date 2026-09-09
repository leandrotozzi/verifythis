# Día 4 — un observador más, sin tocar a los que ya miran

El testbench es el de los analysis ports: el `command_monitor` publica cada comando
por un `uvm_analysis_port`, y del otro lado escuchan el `coverage` y el
`scoreboard`. Queremos agregar uno que cuente.

## Qué se pide

1. **`op_counter.svh`** — un `uvm_subscriber #(command_s)` que cuente los
   comandos que le llegan (y aparte las `mul_op`), y que en `report_phase`
   imprima, con verbosidad `UVM_NONE` y con el id `OP_COUNTER`:

   ```
   commands=<n> multiplications=<m>
   ```

   El corrector busca esa línea tal cual: `commands=` es lo que grepea.

2. **`env.svh`** — instancialo y conectalo al analysis port del
   `command_monitor`, sin tocar las conexiones que ya están.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

La corrección es cruzada: tu `commands=` tiene que dar igual que la cantidad de
líneas `[COMMAND MONITOR]` que imprime el monitor, que no las escribiste vos. Si
te olvidás del `connect`, tu contador dice 0 y el monitor dice 1000.

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

## Lo que practica

Analysis ports y el observer pattern, `build_phase` y `connect_phase`.
El punto de fondo: **el que publica no se entera de quién escucha**, y por
eso agregar un observador no toca una línea de los que ya estaban.
