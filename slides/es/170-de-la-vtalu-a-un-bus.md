<!-- .slide: id="apendice-bus" data-machete="res/diagrams/sequences_tb_completo.svg,res/diagrams/agents_agent.svg" -->

## Apéndice · De la VTALU a un bus real

#### *Lo que no cambia*

- El DUT del curso tiene un handshake de tres señales. El lunes te vas a
  encontrar con **AXI, APB o AHB**, y la pregunta honesta es cuánto de esto sirve
- El árbol, entero: `test` → `env` → `agent` → sequencer, driver y monitores, con
  el análisis colgado de los analysis ports. **Es el mismo diagrama**
- El agent sigue siendo **uno por interface**. Un DUT con un APB de configuración
  y un AXI de datos son dos agents, no un agent más grande
- La configuración sigue bajando por **un objeto por nivel**, y el ámbito del
  `config_db` sigue siendo una ruta
- La sequence sigue siendo un objeto que se crea, corre y se tira

Note:
Este apéndice existe porque la pregunta la hace todo el mundo al terminar, y la
respuesta corta es buena noticia: la **arquitectura** no cambia nada. Lo que
cambia es una sola clase, el driver, y una sola clase más, el monitor.
Vale decirlo con números para que no suene a consuelo: de las nueve clases del
`code/u7/sequences`, en un agent de APB se reescriben dos —driver y monitor—, la
transaction gana campos, y el resto —test, env, agent, config, scoreboard,
cobertura, sequences— se copia y se adapta.
Y la razón de fondo es la que el curso viene diciendo desde el `env`: lo que
sabe del protocolo está encerrado en un lugar. Cambiar de protocolo toca ese
lugar y nada más. Si al alumno le tocara reescribir el env, sería señal de que el
agent estaba mal armado.

---

## Apéndice · De la VTALU a un bus real

#### *Lo que sí cambia*

- **El driver deja de ser una task lineal.** Una operación de la VTALU es subir
  `start` y esperar `done`. Un bus tiene fases —dirección, dato, respuesta— y en
  AXI los cinco canales corren **independientes**: el driver pasa de un `send_op()`
  a varios threads con `fork`
- **El monitor tiene que reconstruir.** Ya no alcanza con mirar un flanco: hay que
  aparear la dirección de un canal con el dato de otro, por ID. Es la clase más
  difícil del agent, y la que más se subestima
- **La transaction crece**: dirección, tipo de burst, largo, strobes, respuesta. Y
  las constraints dejan de ser decorativas — en AXI un burst no puede cruzar un
  límite de 4 KB, y eso es una `constraint`, no un comentario
- **Las sequences virtuales dejan de ser un lujo**: configurá por APB, después
  mandá tráfico por AXI con lo que la configuración devolvió. La forma es la de
  las sequences —`virtual_sequencer`, `p_sequencer`, un `fork` por interfaz—; lo
  único que cambia es que los dos sequencers son de tipos distintos
- **Aparece RAL.** Si el DUT tiene registros —y los tiene—, `uvm_reg` te da el
  modelo y los tests de registro hechos

Note:
El primer bullet es el que hay que subrayar, porque es donde se rompe la
intuición que el curso construyó. En la VTALU, "una operación" y "un intercambio
en el bus" son la misma cosa. En AXI no: una transacción de escritura son tres
canales que pueden ir en cualquier orden, y `item_done()` se llama cuando llegó la
respuesta, no cuando se puso la dirección.
Consecuencia práctica que conviene anticipar: en el momento en que el driver tiene
varias transacciones en vuelo, el par `get_next_item` / `item_done` deja de
alcanzar y aparece `uvm_tlm_fifo` adentro del driver, o el modo *pipelined*. No es
un tema nuevo: son las mismas piezas de threads y de put y get.
Y sobre el segundo bullet, para bajar la ansiedad: el monitor de un protocolo
conocido casi nunca se escribe. Se compra o se baja.

---

## Apéndice · De la VTALU a un bus real

#### *Por dónde empezar*

- **Buscá un VIP antes de escribir un agent.** Casi nadie escribe un agent de AXI
  desde cero: los vendors los venden y hay libres. Escribir el tuyo es un proyecto
  de meses y no es el que te pidieron
- **El protocolo antes que la metodología.** El 90 % de los bugs de un agent nuevo
  son de protocolo mal leído, no de UVM. La spec del bus primero
- **Lo primero que se escribe es el monitor**, no el driver. Si no podés *ver* el
  bus no podés verificar nada — ni siquiera el estímulo de otro
- Y ahí el **agent pasivo** es tu primer entregable de verdad:
  mirar antes de manejar
- **SVA en paralelo.** Un bus tiene reglas que se chequean donde ocurren, no en el
  scoreboard, y en un bus con transacciones solapadas ésa es la diferencia entre
  media hora y dos días. La herramienta ya la tenés: **las assertions**, con la ventaja
  de que las properties viajan adentro de la interface del VIP

Note:
El orden de esta slide es un consejo de campo y conviene defenderlo: el que
arranca por el driver escribe estímulo que nadie está mirando, y descubre a la
semana que su monitor no reconstruye. El que arranca por el monitor puede
enchufarlo pasivo sobre el estímulo de otro —o sobre un test del diseñador— y ya
está aportando el primer día.
Si alguien pregunta por dónde sigue el camino de aprendizaje después de acá, el
orden que rinde: RAL, después regresión con semillas, después el `clocking block`
y las properties de bus prefabricadas. SVA ya no está en esa lista —es una unidad entera de este curso— y conviene decirlo, porque es la primera pregunta de toda entrevista.
Y una última, que no es técnica: en un proyecto real el testbench casi siempre ya
existe. Lo que se pide el primer día no es armar uno, es **agregarle un test** —
que es exactamente lo que practicaron en los ejercicios de los días 3 y 6.
