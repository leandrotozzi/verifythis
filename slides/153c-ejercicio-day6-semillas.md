## Ejercicio · Día 6 · 4 de 4

#### *La misma sequence, otra semilla*

`cd code/ejercicios/d6-semillas && bash run.sh`
<!-- .element: class="comando" -->

- El único ejercicio del curso sin SystemVerilog: lo que se escribe es la
  **regresión**, seis líneas de shell
- Correr el mismo test con las semillas 1 a 5 y **mergear** las cinco coberturas
  con `verilator_coverage --write`
- Se corrige comprobando que el merge cubre más que la mejor de las cinco sola

Note:
Es la última fila de la tabla de *coverage closure*, hecha. Y cierra el arco con
el ejercicio anterior: uno es el caso dirigido, el otro es la regresión, y son
las dos herramientas que no se reemplazan entre sí.
El detalle que hay que subrayar es por qué el test manda **25** operaciones y no
mil: con mil esto no funciona. Está medido y está en la slide *"otra semilla, y
de nuevo"* — `u2/convencional` y `u7/sequences` dan 66 de 76 con cualquier semilla, y el merge
también. Con 25 el estímulo todavía no saturó y ahí sí cada semilla cubre un
pedazo distinto: 41 a 47 bins cada una, 62 las cinco mergeadas.
La regla que se llevan, en una línea: otra semilla **acumula** mientras el
estímulo no saturó, y **reproduce** un fallo intermitente. No llena un bin que el
estímulo no puede alcanzar.
Y el comando del merge conviene nombrarlo por lo que es en la industria:
`verilator_coverage --write` es acá lo que el merge de `ucdb` es en Questa. Una
regresión de verdad son cien semillas de noche y un solo número a la mañana.
