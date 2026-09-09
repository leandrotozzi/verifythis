# Día 8 — el modelo de referencia en C

El testbench es el entero de la sección de DPI y **no se toca ni una línea**. El
único archivo de este ejercicio es `vtalu_golden.c`: el modelo de referencia que
el scoreboard consulta en vez de predecir en SystemVerilog.

Vienen tres operaciones hechas —son el patrón— y faltan dos.

## Qué se pide

1. **`SUB_OP`** — la resta tiene **dos mitades**, y la segunda es la que se
   olvida todo el mundo: operandos de 8 bits en un resultado de 16, así que
   `a - b` da la vuelta, y el **borrow** (`a < b`) es la otra mitad de la
   respuesta que el scoreboard compara. Sale por `*ovf`.
2. **`MUL_OP`** — el producto completo, y la mutación que prueba que el camino
   está vivo: con `mutar` en 1 el modelo tiene que **mentir**. Truncar a 8 bits
   alcanza.

Listo cuando `bash run.sh` imprime las tres etapas y termina con `EXERCISE OK`.

## Las tres etapas del corrector

| | Qué corre | Qué prueba |
|:--:|---|---|
| **1** | DUT sano contra tu modelo | que tu modelo es correcto: 0 `UVM_ERROR` |
| **2** | DUT **mutado** (`VTALU_BUG=1`) contra tu modelo | que el scoreboard **de verdad** te está preguntando a vos |
| **3** | DUT sano contra tu modelo **mutado** (`+GOLDEN_BUG`) | que tu mutación existe: un scoreboard que nunca vio un error no está probado |

La etapa 2 es la que hace que el ejercicio valga. Un modelo que devuelva
cualquier cosa fija podría pasar la 1 por casualidad si el estímulo fuera pobre;
con el DUT mintiendo en el bit 0, no hay forma de pasarla sin haber calculado.

## La trampa que no se ve

`extern "C"` no es decoración. Verilator le pasa las fuentes del usuario al
compilador de **C++**, y sin la guarda el símbolo sale *mangled*: el link falla
con un *undefined reference* a una función que está ahí, escrita, dos líneas más
arriba. Es el modo de falla número uno de DPI con Verilator y por eso el
esqueleto ya la trae puesta.

La segunda: los opcodes están escritos **dos veces** —el `enum` de este archivo y
el `operation_t` de `vtalu_pkg.sv`— y nadie los compara. Ése es el impuesto del
DPI, y es lo primero que hay que mirar cuando fallan *todas* las comparaciones a
la vez.

## Cómo se corre

```sh
bash run.sh              # con tu archivo
SOLUCION=1 bash run.sh   # con el de solucion/, para comparar
```

## Cuánto tarda

Compila UVM entera, como el resto de los ejercicios del día 8:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~2 min | ~5 min |
| las siguientes, con `ccache` | ~15 s | ~15 s |

Tocar sólo el `.c` recompila **un** archivo: el resto del binario ya está. Ésa es
media ventaja de tener el modelo afuera, y la otra es que lo escribió el equipo
de algoritmos y no vos.

## Lo que practica

DPI-C de ida y de vuelta: el valor de retorno y el argumento `output` por
puntero, la guarda `extern "C"`, y la mutación como prueba de que el camino está
conectado. El punto de fondo es el de la sección: para un DUT con aritmética de
verdad —un DSP, un códec, un motor de cripto— **el modelo en C ya existe**, lo
escribió el equipo que firmó la spec, y reescribirlo en SystemVerilog es mantener
dos modelos y debuggear la diferencia entre ellos.
