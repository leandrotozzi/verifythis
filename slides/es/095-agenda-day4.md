<!-- .slide: id="day4" -->

## Ayer quedó…

#### *Dónde dejamos el testbench*

- Entró UVM: `run_test()`, el test, las fases, el `env` y el scoreboard, y el
  `+UVM_TESTNAME` que elige la clase desde la línea de comandos
- El **objection** es lo que mantiene viva la simulación, y el reporting ya
  distingue verbosidad de *action*
- Y quedó un cuello: el scoreboard es **uno solo** y está cableado al monitor.
  El día que haya dos oyentes hay que editar al que publica

Note:
La recap del día 4 tiene que dejar servido el problema del observer, porque la
unidad entera es eso: un productor que no conoce a sus oyentes.
Vale hacer la pregunta y esperar: *"si mañana quieren medir cobertura además de
comparar, ¿dónde tocan?"*. La respuesta natural —"agrego una llamada en el
monitor"— es exactamente la que la unidad viene a desarmar.

---

<!-- .slide: data-machete="res/diagrams/analysis-ports_fig102.svg,res/diagrams/threads_fig124.svg" -->

## Agenda

#### *Día 4 · ≈ 4 h · unidad 5 · cómo hablan los componentes*

- Un productor, muchos oyentes
- Un solo lugar que mira el cable
- Cuando alguien tiene que esperar
- Quién espera a quién

**Al final del día podés:**

- **Colgar** un subscriber nuevo de un analysis port **sin tocar al que publica**
- **Elegir** entre un analysis port y una FIFO de TLM, y decir cuál de los dos
  bloquea
- **Sacar** el `#500` del final de un test y reemplazarlo por el objection que
  corresponde

Note:
El primero es la fila 11 de la autoevaluación del cierre y es el que define la
unidad: el observer existe para que agregar un oyente no toque al que publica.
El tercero es el segundo ejercicio del día y vale como objetivo por sí solo: el
`#500` es el parche que todo el mundo escribe la primera vez, y sacarlo obliga a
entender qué mantiene viva la simulación.
