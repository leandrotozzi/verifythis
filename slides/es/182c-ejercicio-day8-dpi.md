## Ejercicio · Día 8 · 2 de 2

#### *El modelo de referencia en C, y las dos mutaciones que lo prueban*

`cd code/ejercicios/d8-dpi && bash run.sh`
<!-- .element: class="comando" -->

- El único archivo del ejercicio es `vtalu_golden.c`. Del testbench no se toca
  una línea
- Faltan dos operaciones: la **resta con su borrow** —que sale por un puntero— y
  el producto con el gancho de mutación
- El corrector corre tres veces: DUT sano contra tu modelo, **DUT mutado**
  (`VTALU_BUG=1`), y tu modelo mutado (`+GOLDEN_BUG`)

Note:
La etapa 2 es la que hace que el ejercicio valga, y conviene explicarla antes:
con el DUT sano, un modelo que devuelva cualquier cosa fija podría pasar de
casualidad si el estímulo fuera pobre. Con el DUT mintiendo en el bit 0, no hay
forma de pasar sin haber calculado — es el mismo test de mutación del capstone,
apuntado al modelo en vez de al scoreboard.
La resta es la que se cae, y no por la aritmética: `a - b` es una línea. Lo que
se olvida es la **segunda mitad de la respuesta**, el borrow, y se olvida porque
cruza la frontera de otra forma —por puntero, que es como viaja un `output int`
de SystemVerilog—. El scoreboard lo compara, así que sin él fallan todas las
restas y ninguna otra operación: ese patrón de fallas es el que hay que aprender
a leer.
Y la trampa que no se ve, que está resuelta en el esqueleto a propósito para que
no pierdan la hora ahí: sin `extern "C"`, Verilator le pasa el archivo al
compilador de **C++**, el símbolo sale *mangled*, y el link falla con un
*undefined reference* a una función que está escrita dos líneas más arriba. Es el
modo de falla número uno de DPI con Verilator.
