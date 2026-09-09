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

#### *Reuso vertical: el env del bloque adentro del env del sistema*

```systemverilog
class soc_env extends uvm_env;
   apb_env apb_env_h;     // el env del bloque, sin tocarle una línea
   axi_env axi_env_h;
   soc_scoreboard sb_h;   // el de sistema mira las dos puntas, no las transferencias

   function void build_phase(uvm_phase phase);
      // Lo que cambia no es el código del env: es su CONFIGURACIÓN
      apb_cfg.is_active = UVM_PASSIVE;   // acá el APB lo maneja el CPU del SoC
      uvm_config_db #(apb_env_config)::set(this, "apb_env_h*", "cfg", apb_cfg);
      apb_env_h = apb_env::type_id::create("apb_env_h", this);
   endfunction
endclass
```

- El reuso de la sección de agents es **horizontal**: dos instancias del mismo
  agent en el mismo env. Éste es **vertical**, y es el que se cobra en un SoC
- El env del bloque no se edita. Lo que cambia es su config: el agent pasa a
  **pasivo** porque a nivel de sistema el bus lo maneja el DUT, no el testbench
- Por eso `is_active` y el objeto de config no son ceremonia: son la bisagra que
  hace que el mismo código sirva en los dos niveles
- Lo que **no** sube es el scoreboard de bloque: el de sistema compara entrada
  contra salida del SoC, y el de bloque sigue midiendo su bus

Note:
Ésta es la respuesta a *"¿y para qué tanta clase, si mi DUT tiene un bus?"*, y la
respuesta es que el testbench del bloque no se escribe para el bloque: se escribe
para que dentro de seis meses entre entero adentro del testbench del chip.
La regla concreta que decide si un env es reusable, y conviene bajarla como
checklist de tres puntos: **no crea su propia interface** —la recibe por
`config_db`—, **no lee del `config_db` con rutas absolutas** —nada de
`uvm_test_top.env_h.*`, porque a nivel de sistema esa ruta no existe—, y **no
levanta objections propias** salvo que sea el que manda. Un env que rompe
cualquiera de las tres compila igual y no se puede instanciar dos veces.
El cambio de activo a pasivo es el caso típico y vale explicarlo despacio: a
nivel de bloque el testbench maneja el APB porque no hay nadie más. A nivel de
SoC ese bus lo maneja el procesador de verdad, así que el mismo agent tiene que
mirar sin manejar — y eso ya está resuelto, es el `is_active` de la sección de
agents. Ninguna línea nueva.
Y el dato que cierra el capstone: el env que escribieron en `d7-final` **ya** es
reusable, porque su config viene de afuera y su interface también. No fue
casualidad; fue el `apb_env_config`.


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
Si alguien pregunta por dónde sigue el camino de aprendizaje **después de este
curso**, la lista corta y en orden: **TLM2** —`uvm_tlm_generic_payload` y los
sockets, que es como se conectan los VIP de bus entre sí—, el **backdoor de RAL**
—`docs/verilator.md` explica por qué acá no está—, la **`uvm_sequence_library`**
para el test de estrés que no se escribe, y leer el `dv/` de un proyecto abierto
de verdad: los agents de **OpenTitan** y el VIP de AXI de **pulp-platform/axi**
son código de producción y se leen gratis. Y una que no es de UVM y vale la
carrera: **formal** con SymbiYosys, que prueba las mismas properties que
escribieron hoy sin ningún estímulo.
Lo que **no** va en esa lista es lo que ya vieron: RAL es el día 8, la regresión
con semillas es el calentamiento del día 7 y `make regresion`, y el `clocking
block` es media sección de la unidad 2.
Y una última, que no es técnica: en un proyecto real el testbench casi siempre ya
existe. Lo que se pide el primer día no es armar uno, es **agregarle un test** —
que es exactamente lo que practicaron en los ejercicios de los días 3 y 6.
