<!-- .slide: id="day5" -->

## Ayer quedó…

#### *Dónde dejamos el testbench*

- El monitor **publica** y no conoce a nadie: cuelgan de él el scoreboard y la
  cobertura, y agregar un tercero no toca al que publica
- Las FIFO de TLM resolvieron quién espera a quién, y `fork`/`join` quién corre
  con quién
- Pero el dato sigue siendo **tres campos sueltos**: `A`, `B` y `op` viajan
  separados, se copian a mano, y compararlos es escribir la comparación entera

Note:
La recap del día 5 tiene que instalar la incomodidad del dato suelto, porque es
lo que justifica una unidad entera sobre objetos que no hacen nada más que
llevar datos.
El tercer bullet es literal: en el testbench de ayer, copiar un comando es tres
asignaciones, y compararlo es tres `==`. Con dos campos más son cinco y cinco.
Hoy eso pasa a ser `copy()` y `compare()`, escritos una vez.

---

<!-- .slide: data-machete="res/machete-debug.svg|Machete de debug: las siete perillas del curso y qué mirar según el síntoma,res/uvm_class_diagram.svg|Jerarquía de clases base de UVM" -->

## Agenda

#### *Día 5 · ≈ 4 h 30 · unidad 6 · el dato*

- Copiar un objeto que contiene otro
- Transactions
- Constrained random

**Al final del día podés:**

- **Escribir** una constraint que llegue a un caso de borde, y **medir** si el
  `dist` hace lo que dice
- **Cerrar** un bin que quedó abierto, con un caso dirigido pedido por
  `randomize() with {}`
- **Explicar** la diferencia entre copiar el handle y copiar el objeto, y qué
  pasa cuando el objeto contiene otro

Note:
El segundo es la novedad del día y el que más rinde en el trabajo: medir es la
mitad, cerrar es la otra. Los dos últimos ejercicios de la tarde son dos tercios
de ese ciclo —medir el `dist`, cerrar el bin— y el día 7 lo cierra acumulando
semillas.
La 12 de la autoevaluación dice **medir**, no **escribir**, y es a propósito: un
`dist` con los pesos bien puestos puede dar un histograma que miente, y el que no
lo midió nunca no tiene forma de saberlo.
