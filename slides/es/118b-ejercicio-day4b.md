## Ejercicio · Día 4 · 2 de 2

#### *El `#500` es un parche*

`cd code/ejercicios/d4b && bash run.sh`
<!-- .element: class="comando" -->

- El testbench de *put y get* con **una línea cambiada**: la FIFO del `env` viene
  sin tope
- El tester vacía sus mil comandos en `t = 0`, espera el `#500` de siempre, baja
  la objection — y la simulación termina **en verde con 13 comandos en el bus**
- Se arregla en el driver: una objection **mientras hay un comando en vuelo**
- `env.svh` no se toca: la FIFO sin tope es el DUT de este ejercicio

Note:
Es el ejercicio que le da manos a las dos cosas que la sección afirma y no
demuestra: que `put()` bloquea, y que el `#500` del tester es un parche.
El número está medido y conviene decirlo: con la FIFO de tamaño 1 el testbench
manda las mil operaciones; con la FIFO sin tope, **13**. Nadie tocó el DUT, nadie
tocó el estímulo, y la diferencia es el argumento por defecto de un constructor.
Lo que la contrapresión estaba haciendo sin que nadie lo hubiera diseñado así:
mantener al tester al ritmo del bus. Sacala y el tester queda hablando solo.
El arreglo hay que discutirlo, porque la respuesta obvia —subir el `#500`— es la
que hay que rechazar. La pregunta que ordena: **¿quién sabe cuándo terminó el
bus?** No es el tester, que sabe cuándo terminó de *poner*. Es el driver, que es
el que maneja. Por eso la objection va ahí, y por eso es el patrón de cualquier
driver de UVM de verdad.
Y el detalle que decide si el ejercicio anda, que también es de campo: el par
`raise`/`drop` va **después** del `get()`, no alrededor. Alrededor, el driver
sostiene una objection esperando trabajo que no va a llegar, y el test no termina
nunca — que es el otro modo de falla de la tabla del apéndice de debug.
