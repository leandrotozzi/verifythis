## Ejercicio · Día 6 · 2 de 4

#### *Una sequence que sólo multiplica*

`cd code/ejercicios/d6-sequences && bash run.sh`
<!-- .element: class="comando" -->

- Escribí `mult_sequence` y el `mult_test` que la arranca
- El driver, el agent y el `env` ya están: agregar estímulo **no toca la
  estructura**, que es justamente lo que la sección vino a demostrar
- Se corrige cruzado contra lo que el `chequeo` ve en el bus, no contra tu cuenta

Note:
Es el mismo ejercicio del día 2 y del día 3, por tercera vez y con la herramienta
final: "quiero que sólo multiplique". En el día 2 se resolvía agregando `virtual`,
en el día 3 con un override de la factory, y hoy escribiendo veinte líneas de
`body()` sin tocar una sola clase del testbench. Vale ponerlos a comparar los
tres: ésa es la historia entera del curso en un ejercicio.
La trampa que van a encontrar es la primera de la sección: si la sequence no
manda un `rst_op` como primer item, el VTALU arranca con `reset_n` en 0, `done`
nunca sube y el driver se queda en el primer `finish_item()`. El `run.sh` tiene
un `+UVM_TIMEOUT` puesto para que eso termine con un mensaje en vez de colgarse.
