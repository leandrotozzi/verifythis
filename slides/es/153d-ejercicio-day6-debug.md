## Ejercicio · Día 6 · 5 de 5

#### *Tres bugs plantados, y ninguno se parece al otro*

`cd code/ejercicios/d6-debug && bash run.sh`
<!-- .element: class="comando" -->

| | Archivo | Cómo se manifiesta |
|:--:|---|---|
| **1** | `driver.svh` | **cuelga**: muere en `[PH_TIMEOUT]` |
| **2** | `default_seq_test.svh` | **termina en `t=0`** y dice PASS |
| **3** | `random_sequence.svh` | **miente en verde**: `add_test` pasa con el estímulo equivocado |

- El corrector dice **cuál** de los tres sigue roto. Cuál es la línea, es el
  ejercicio

Note:
Es el único ejercicio del curso donde no hay nada que escribir: hay algo que
encontrar. Y es el que más se parece al primer mes de trabajo, donde nadie te da
un archivo con un agujero — te dan un testbench que no anda.
La idea que ordena las tres filas, y que conviene decir antes de largarlos:
**los modos de falla de un testbench de UVM no se parecen entre sí**. El que
cuelga se nota enseguida y no cuesta nada. Los otros dos pasan **en verde**, y
ésos son los que cuestan semanas.
Los tres están en la tabla del apéndice de debug, y está permitido leerla: la
lista existe justamente para que la segunda vez tarden cinco minutos.
El tercero merece un comentario aparte porque rompe el reflejo que el curso viene
entrenando: `+TOPOLOGY` es la herramienta correcta para *"el árbol no es el que
dibujaste"*… y acá **no alcanza**, porque lo que se construyó mal es un
`uvm_object` y el árbol sólo muestra `uvm_component`. La única forma de verlo es
mirar qué salió al bus.
