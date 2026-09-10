# SystemVerilog para el que viene de VHDL (o de Verilog-2001)

Media hora antes del día 1, y una sola vez.

El curso declara que hace falta **Verilog o VHDL, y haber simulado algo**, y que
la programación orientada a objetos no hace falta porque el día 2 es exactamente
eso. Las dos cosas son ciertas. Lo que el curso **no** nivela es el
SystemVerilog que Verilog-2001 y VHDL no traen, y que el día 1 usa desde la
primera slide: `logic`, `enum`, `package`, `interface`, `covergroup`, `clocking`
y una `assert property`.

Son siete construcciones. Ninguna es difícil; todas juntas y sin aviso, en la
misma mañana en que además entra el vocabulario de verificación, son un escalón
de más. Esto es ese escalón, en una página.

> Si venís de **Verilog-2005 con algo de SystemVerilog**, ojeá la tabla del
> final y saltate el resto.

## Lo mínimo, en una tabla

| SystemVerilog | Lo que ya sabés | Qué cambia de verdad |
|---|---|---|
| `logic` | `reg` de Verilog / `std_logic` | Es `reg` renombrado y sin la trampa: se puede asignar desde un `always` **o** desde un `assign`. Regla práctica: `logic` para todo, `wire` sólo si hay más de un driver |
| `always_ff` / `always_comb` / `always_latch` | `always @(...)` / `process` | Declaran la **intención**. El sintetizador y el linter avisan si el código no la cumple: un `always_comb` al que le falta una rama es un error, no un latch silencioso |
| `enum` | `parameter`s sueltos / `type … is (…)` | Un tipo con nombres. `op.name()` devuelve el string, y eso es lo que hace que los logs del curso digan `mul_op` y no `3'b101` |
| `typedef` | `subtype` | Igual que en VHDL |
| `package` … `endpackage` + `import pkg::*` | `package` / `use work.pkg.all` | Igual que en VHDL. Todo el testbench del curso vive en un `package` |
| `struct packed` | `record` | Campos con nombre. `packed` quiere decir que además es un vector de bits, y se puede asignar entero |
| arrays dinámicos, `queue` (`[$]`), array asociativo (`[string]`) | — | No tienen equivalente en VHDL-93. El scoreboard del curso usa un array asociativo como tabla |
| `interface` … `endinterface` | un `record` de señales, o nada | **La construcción nueva más importante del día 1.** Ver abajo |
| `class` | — | El día 2, entero. No hace falta traerla sabida |
| `covergroup` / `coverpoint` / `bins` / `cross` | — | Ver abajo |
| `clocking` block | — | Ver abajo |
| `assert property (…)` | `assert` de VHDL, pero temporal | Ver abajo |
| `$urandom`, `$urandom_range` | `uniform` de `ieee.math_real` | Random del simulador, con semilla reproducible |
| `$display("%0d", x)` | `report` / `write` | `%0d` es "sin ancho fijo"; `%h` hexa, `%s` string, `%p` cualquier cosa |

## Las cuatro que sí o sí conviene leer antes

### `interface`: un manojo de cables con nombre

En VHDL una entidad tiene veinte puertos y el testbench los conecta uno por uno.
Un `interface` de SystemVerilog es un **bloque que agrupa esas señales** y que se
instancia como un módulo:

```systemverilog
interface vtalu_bfm;
   logic       clk, reset_n, start, done;
   logic [7:0] A, B;

   task send_op(...);   // y además puede tener el protocolo adentro
      ...
   endtask
endinterface
```

Dos cosas que sorprenden:

1. **Puede tener `task`s adentro.** El "cómo se habla con el DUT" —bajar el
   reset, poner los operandos, esperar el `done`— vive ahí y no en el testbench.
   Es la mitad de la unidad 2.
2. **`virtual vtalu_bfm bfm;` es una variable**, no una instancia. Es la única
   forma que tiene una clase de tocar señales, y por eso aparece en todos lados a
   partir del día 2. Un `virtual` acá **no** tiene nada que ver con el `virtual`
   de los métodos: la palabra está sobrecargada, y el curso lo dice.

### `covergroup`: la pregunta "¿qué probé de verdad?"

No existe en VHDL ni en Verilog. Es una construcción que **cuenta qué valores
pasaron** por una variable durante la simulación:

```systemverilog
covergroup op_cov;
   coverpoint op_set {                 // qué variable mirar
      bins single[] = {add_op, sub_op};  // qué casilleros quiero
      bins mult     = {mul_op};
   }
endgroup
```

Tres reglas que ahorran la mitad de las dudas del día 1:

- El covergroup **no mide solo**: alguien tiene que llamar a `sample()`. Un
  covergroup en 0 % casi siempre es un `sample()` que nadie llama.
- Un `bin` es un casillero. La cobertura es *cuántos casilleros se tocaron*, no
  cuántas veces.
- Un `cross` de dos coverpoints son todos los pares. Crece rápido, y por eso
  existen `ignore_bins` e `illegal_bins`.

### `clocking` block: el muestreo, dicho una vez

Declara **con qué flanco** se leen y se escriben las señales, para no tener que
acordarse en cada línea:

```systemverilog
clocking cb @(posedge clk);
   default input #1step output #0;
   input  done, result;
   output A, B, start;
endclocking
```

`#1step` quiere decir *el valor estable justo antes del flanco*, que es lo que
uno quiere leer. Es la respuesta de SystemVerilog a la race clásica entre el
testbench y el DUT — y el curso explica por qué **igual son opcionales**, con la
discusión larga en [`clocking-blocks.md`](clocking-blocks.md).

### `assert property`: un `assert` que dura varios ciclos

El `assert` de VHDL mira un instante. El de SystemVerilog puede decir *"cuando
pasa esto, dentro de uno a cinco ciclos tiene que pasar aquello"*:

```systemverilog
a_done: assert property (@(posedge clk) start |=> ##[1:5] done)
        else `uvm_error("BFM", "done no llegó");
```

`|->` es "en el mismo ciclo", `|=>` es "a partir del siguiente". El día 1 muestra
una de pasada y avisa que vuelve en el día 7, que es donde se enseña entera.

## Falsos amigos

- **`virtual`** son tres cosas distintas: método virtual (día 2), clase abstracta
  (día 2) y *virtual interface* (día 1). No están relacionadas.
- **`=` contra `<=`** es blocking / non-blocking, no "asignación de variable" y
  "de señal" como en VHDL, aunque el efecto práctico se parezca. En un testbench
  la regla es: **el driver maneja con `<=`**.
- **`static`** no es "estático" en el sentido de VHDL: es "una sola copia,
  compartida por todos los objetos de la clase". Día 2.
- **`logic` no es `std_logic`**: tiene cuatro valores (`0 1 x z`) pero no tiene
  fuerzas (`L`, `H`, `W`). No hace falta un `to_stdlogicvector` de nada.
- **No hay `others =>`.** El equivalente es `'0`, `'1` o `{N{1'b0}}`.
- **No hay resolución de tipos ni sobrecarga de operadores.** Todo es bits.

## Cómo se practica esto en media hora

El único ejercicio que hace falta antes del día 1 es leer el DUT y su testbench
convencional, que son cortos y usan casi todo lo de arriba:

```sh
cd code/u2/convencional && bash run.sh
```

Y después abrir tres archivos, en este orden:

1. `code/vtalu_dut/vtalu.sv` — `logic`, `always_ff`, un `case`. Es Verilog con
   otro nombre.
2. `code/u2/interfaces-bfm/vtalu_pkg.sv` — el `package` y el `enum`.
3. `code/u2/interfaces-bfm/vtalu_bfm.sv` — el `interface` con las tasks adentro.

Si los tres se leen sin tropezar, el día 1 no tiene ningún escalón escondido.
