# Día 2 — un tester que sólo multiplica, sin tocar el que ya está

El testbench es el de *Un testbench sin un solo módulo*, en clases. Hoy `tester` manda
operaciones al azar; queremos uno que mande sólo multiplicaciones, **sin copiar
y pegar la clase entera**.

## Qué se pide

1. **`mult_tester.svh`** — escribí la clase: extiende `tester` y redefine
   `get_op()` para devolver siempre `mul_op`.
2. **`testbench.svh`** — hacé que `tester_h` sea un `mult_tester`.
3. Y va a seguir mandando operaciones al azar. **Ahí está el ejercicio**:
   mirá `tester.svh`, y acordate de polimorfismo.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

## Cuánto tarda

No usa UVM —el testbench es el orientado a objetos, sin la librería—: compila y
corre en **segundos**.

## Lo que practica

Herencia, polimorfismo y `virtual` sobre el testbench en objetos.
Es el mismo problema que el ejercicio del día 3 resuelve con la factory: hacerlo
primero a mano es lo que después explica para qué sirve la factory.
