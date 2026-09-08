# Día 5 — el scoreboard grita y el DUT está sano

El testbench ya usa transactions. Corré:

```sh
bash run.sh
```

El scoreboard reporta `FAIL` en casi todas las operaciones. **El DUT está bien**
— es el mismo que viene pasando desde la spec. El bug está en el
testbench, en este directorio.

## Qué se pide

1. Encontralo. Los mensajes del monitor son `UVM_HIGH`, así que por defecto no
   se ven:

   ```sh
   bash run.sh +UVM_VERBOSITY=UVM_HIGH
   ```

   Compará lo que el monitor dice que vio con lo que el scoreboard compara.
2. Arreglalo.

Listo cuando `bash run.sh` termina con `UVM_ERROR : 0`. No hace falta que
chequees nada a mano: desde que `run_sim` lee el *Report Summary*, un ejemplo
con UVM que reporte errores no pasa.

## Cómo se corre

```sh
bash run.sh                          # con tus archivos
bash run.sh +UVM_VERBOSITY=UVM_HIGH  # con los mensajes de debug a la vista
SOLUCION=1 bash run.sh               # con los de solucion/, para comparar
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

## Si te trabás

Los dos apéndices del final del deck están escritos para este ejercicio:

- **La caja de herramientas de debug** — la tabla *"cuál usar según el síntoma"*
  tiene la fila `el scoreboard grita en todas`, y dice con qué se mira.
- **Las diecinueve trampas mudas** — el catálogo de todo lo que compila, corre y
  miente. La causa de este bug es una de las diecinueve.

Se puede hacer el ejercicio sin haber visto reporting: alcanza con tener la
slide de síntomas abierta al lado.

## Lo que practica

Verbosidad y reporting (19), monitores y analysis ports (16), transactions (21).
Y la lección de fondo, que es de oficio y no de sintaxis: **cuando el scoreboard
grita, el sospechoso número uno no es el DUT.** Un monitor que muestrea mal
inventa fallas que no existen, y hace perder días.
