[English](README.md) · **Castellano**

# Día 3 — el `uvm_error` que no dice nada

El ejercicio de las ondas del día 1 terminaba con esta línea:

```
FAILED: A: e5  B: 0  op: mul_op result: fe01 ovf: 0
```

y con la observación de que un log dice **que** algo falló y casi nunca **por
qué**. Éste es el ejercicio donde eso se arregla, del lado del que escribe el
log.

El testbench es el entero de la sección *El env*. El `scoreboard.svh` que hay
acá está **bien**: atrapa todos los errores. Y es inútil: cuando falla, dice
`FAILED` y nada más.

```sh
bash run.sh
```

## Qué se pide

**`scoreboard.svh`**, dos cambios y ninguno cambia lo que el scoreboard
*chequea*:

1. **Que el `uvm_error` diga cuál falló.** El contrato de log es éste, y el
   corrector lo verifica contra la operación que de verdad falló:

   | Qué | Cómo |
   |---|---|
   | `A` y `B` | **dos** dígitos hexa — `%02h` |
   | la operación | su nombre, `add_op`, `mul_op`… — `%s` sobre `.name()` |
   | el resultado del DUT y el que predijiste | **cuatro** dígitos hexa cada uno — `%04h` |

   El orden y el texto alrededor son tuyos. Lo que se chequea es que los cinco
   valores estén **en la misma línea**.

2. **Que la comparación que pasa también se imprima**, con la palabra `PASS` y
   con verbosidad **`UVM_HIGH`**. Va en el `else` del mismo `if`.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tu archivo
SOLUCION=1 bash run.sh   # con el de solucion/, para comparar
```

`run.sh` corre el mismo testbench **tres veces**, y cada una corrige una cosa:

1. con `+VTALU_BUG` —el DUT sale roto a propósito— para que tu `uvm_error`
   dispare y se pueda leer qué dice;
2. sin el bug y con la verbosidad de siempre: el `PASS` **no** tiene que
   aparecer;
3. sin el bug y con `+UVM_VERBOSITY=UVM_HIGH`: ahora sí, **una vez por
   comparación**.

`chequeo.svh`, `env.svh`, `vtalu_pkg.sv` y los dos `.f` no se tocan: el
`shasum -c intocables.sha` lo caza antes de compilar. `chequeo.svh` es el que
mira el mismo bus que vos y sabe cuál fue la primera operación que falló.

## Cuánto tarda

Compila UVM entera: ~1 min 30 la primera vez en una laptop de 12 cores, ~15 s
las siguientes con `ccache`. Escribirlo son diez minutos.

## Por qué la verbosidad, y no borrar el `PASS`

Un scoreboard que sólo habla cuando falla parece más limpio, y es el que hace
perder la mañana: cuando la operación 700 falla, lo que necesitás saber es qué
pasó en la 699. Por eso el `PASS` se escribe **y** se esconde: `UVM_HIGH` lo saca
del log de todos los días y lo deja a un `+UVM_VERBOSITY=UVM_HIGH` de distancia
el día que hace falta.

Ésa es la diferencia entre **verbosidad** y **severidad**, que es la mitad de la
sección de *Reporting*: la severidad dice qué tan grave es, la verbosidad dice
cuántas ganas tenés de leerlo hoy.

## Lo que practica

`uvm_error` y `uvm_info` con `$sformatf`, los niveles de verbosidad,
`+UVM_VERBOSITY` desde la línea de comandos, y la fila 10 de la autoevaluación
del cierre: *hacer que un scoreboard que falla diga algo más que "falló"*.
