[English](README.md) · **Castellano**

# Día 3 — un test nuevo sin tocar la estructura

El testbench ya trae el `env` separando estructura de estímulo.
Ya existen `random_test` y `add_test`. Falta el que multiplica.

## Qué se pide

1. **`mult_tester.svh`** — un tester que extienda `random_tester` y devuelva
   siempre `mul_op` en `get_op()`.
2. **`mult_test.svh`** — un `uvm_test` que le diga a la factory que cuando
   alguien pida un `base_tester` devuelva tu `mult_tester`, y que cree el `env`.
3. **No toques `env.svh`.** Esa es toda la gracia: la estructura del testbench
   no se entera de que cambió el estímulo. El `run.sh` lo verifica con
   `intocables.sha` antes de compilar: instanciar tu `mult_tester` ahí a mano
   también hace pasar el test, y ahí el ejercicio —el `set_type_override`— no se
   hizo nunca.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

`env.svh` instancia un componente `chequeo` que no es parte del curso: mira el
bus del DUT y reporta un `uvm_error` si pasa una operación que no sea una
multiplicación. Por eso el ejercicio se corrige solo.

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

UVM tests, components y phases, y sobre todo el factory override.
Compará con el día 2: ahí el tipo se elegía en el código del testbench, acá
lo elige la factory y el testbench ni se entera.

Mirá también la cobertura: con puras multiplicaciones baja a 26 %. Un test
enfocado cubre menos — por eso hacen falta varios, y por eso importa que
agregarlos sea barato.
