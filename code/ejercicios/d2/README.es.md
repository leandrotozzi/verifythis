[English](README.md) · **Castellano**

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

Listo cuando `bash run.sh` imprime `EXERCISE OK`. El corrector es `chequeo.svh`,
que está *bindeado* al top y **no se toca**: cuenta lo que pasó por la BFM y
además llama al `get_op()` a mano dos veces —sobre un `tester` pelado, que tiene
que seguir sorteando las ocho, y sobre el objeto que quedó en `tester_h` a través
de un handle de tipo `tester`, que tiene que contestar `mul_op` siempre—. Ese
segundo número **es** la lección: sólo da 1 si `get_op()` es `virtual` y si
`tester_h` tiene adentro un `mult_tester`.

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
