## Ejercicio · Día 1 · 2 de 2

#### *Las ondas: cuando el log no alcanza*

`cd code/ejercicios/d1b && bash run.sh`
<!-- .element: class="comando" -->

- La corrida aborta con **una sola línea**: `FAILED: A: e5  B: 0  op: mul_op
  result: fe01 ovf: 0`. `e5 * 00` es `0`, no `fe01`. El scoreboard tiene razón,
  y el DUT también: el que se equivocó es el **handshake** de la BFM
- Ahí se termina lo que el log te da. El `run.sh` deja **`ondas.vcd`** al lado:
  `gtkwave ondas.vcd`
- **Etapa 1:** dos tiempos que sólo están en el visor, en `respuesta.txt`.
  **Etapa 2:** la línea de la BFM que los explica
- Es el único ejercicio del curso que **no se resuelve leyendo el log**

Note:
Media hora, y es el ejercicio que justifica el apéndice de debug: ahí se dice que
las ondas son la herramienta con la que se hace el 47 % del trabajo, y hasta acá
el curso no las había hecho usar ni una vez.
El bug es de protocolo y es el mismo que vuelve en el capstone: `send_op`
**cuenta flancos** en vez de esperar el handshake. Para las operaciones de un
ciclo da igual; la multiplicación tarda cuatro, así que `send_op` vuelve antes de
tiempo, el estímulo siguiente pisa `A` y `B`, y cuando `done` finalmente sube el
scoreboard compara los operandos nuevos contra el resultado viejo.
Por eso los dos tiempos que pide la etapa 1 no son burocracia: el segundo es el
`done` de la primera multiplicación, y el que lo busca en el visor **ve** que
`A` y `B` ya cambiaron. Esa es la respuesta al *por qué*, y no hay forma de
leerla en el log.
La pregunta para tirar al grupo cuando lo terminen: si el multiplicador pasara
de cuatro flancos a cinco, ¿cuál de las dos versiones de `send_op` se entera?
Ninguna cuenta bien; sólo la que espera `done` sigue andando. Es literalmente la
pista del wait state del APB del día 7.
Y éste es el 47 % de la slide de tendencias, visto de cerca: el log dice
*falló* y para el *por qué* hay que ir a otro lado. Hoy ese otro lado son las
ondas; el día 3, en reporting, es el log el que aprende a decirlo.
