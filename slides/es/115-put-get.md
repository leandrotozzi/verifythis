## Quién espera a quién

#### *Qué mandar y cómo mandarlo*

- Los analysis ports partieron el análisis: el monitor mira, los subscribers interpretan.
  Falta hacer lo mismo del lado del estímulo
- Hoy el `base_tester` hace **dos** cosas: elige la operación *y* la aplica sobre
  la BFM ciclo por ciclo. Son dos trabajos que cambian por motivos distintos
- El **qué** cambia con cada test. El **cómo** cambia sólo si cambia el
  protocolo del DUT — o sea, casi nunca
- Separarlos deja el protocolo escrito en un solo lugar: el **driver**. Cada test
  nuevo escribe qué mandar y no vuelve a mirar un `@(negedge clk)`
- Y como los dos corren en threads distintos, la unión es la de la comunicación entre threads:
  `uvm_put_port`, `uvm_get_port` y una `uvm_tlm_fifo` en el medio

Note:
Es la tercera vez que el curso hace la misma operación, y conviene decirlo así de
explícito porque es lo que hay que llevarse: en interfaces y BFM sacamos el protocolo del
test y lo pusimos en el BFM; en los analysis ports sacamos la observación de los
analizadores y la pusimos en el monitor; acá sacamos la aplicación del estímulo del generador
y la ponemos en el driver.
La pregunta que ordena todo: ¿esto cambia cuando cambia el test, o cuando cambia
el diseño? Si cambia con el test, es estímulo. Si cambia con el diseño, es
estructura. No van en la misma clase.
Y el aviso de hacia dónde va: en los agents este par put/get se llama sequencer
y viene puesto, y el tester se llama sequence. Lo que estamos armando a mano acá
es exactamente lo que UVM da hecho — por eso primero se arma a mano.

---

## Quién espera a quién

#### *El tester hace dos trabajos, y uno no es suyo*

- Así quedó el `base_tester` de los analysis ports, y hace **dos** trabajos:
  - elige qué operación mandar
  - y la aplica sobre la BFM, ciclo por ciclo
- El segundo es el que no debería estar ahí: es protocolo, y el protocolo no
  cambia cuando cambia el test
- La clase que se lleva ese trabajo se llama **driver**: toma un dato del
  testbench y lo convierte en señales

{{code:code/u5/analysis-ports/tb_classes/base_tester.svh#run_phase}}

Note:
Conviene leer el código señalando con el dedo dónde termina un trabajo y empieza
el otro: `get_op()` y `get_data()` son el **qué**; todo lo que sigue —el
`bfm.send_op()`, la espera, el ciclo— es el **cómo**. Están pegados en la misma
task y por eso no se pueden cambiar por separado.
La prueba de que están mal juntos es una pregunta: si mañana el DUT agrega una
señal al protocolo, ¿cuántas clases hay que tocar? Todas las que heredan de
`base_tester`, aunque ninguna sepa nada de protocolo. Eso es acoplamiento, y el
síntoma clásico es exactamente éste — una clase que cambia por dos motivos
distintos.
El nombre **driver** conviene decirlo ya, aunque la clase todavía no exista, para
que la palabra no aparezca por primera vez en el día 6. Un driver es lo que
convierte un dato en señales. Nada más que eso, y por eso es la única clase del
testbench que tiene derecho a escribir un `@(negedge clk)`.

---

## Quién espera a quién

#### *Cómo queda partido*

- El resultado: una clase decide **qué** mandar y otra sabe **cómo** mandarlo, y
  entre las dos hay una FIFO en vez de una llamada a método

![El tester y el driver del VTALU separados por una uvm_tlm_fifo](res/diagrams/put-get_fig125.svg)
<!-- .element: class="grande" -->

Note:
La caja del medio es la que hay que señalar, porque es la que sorprende: entre el
tester y el driver **no hay una flecha**. Hay una FIFO. El tester no llama al
driver, y ni siquiera tiene un handle suyo.
Vale hacer la comparación con el diagrama de los analysis ports, que está dos
secciones atrás: allá el monitor tampoco conocía a sus oyentes. Es la misma idea
aplicada del otro lado del testbench, y es la razón de que el día 6 se puedan
cambiar todas las sequences sin tocar el driver.
Y la diferencia que sí importa entre los dos diagramas, porque es la pregunta 3
del repaso: aquello era **intra**-thread —`write()` es una función y no espera a
nadie—, esto es **inter**-thread. Acá el que pone puede quedarse esperando, y ésa
es justamente la sincronización que antes había que escribir a mano.

---

## Quién espera a quién

#### *El `env`: siete objetos y cinco `connect()`*

- Mantra: "Ports connect to exports"

{{code:code/u5/put-get/tb_classes/env.svh#build-and-connect}}

Note:
Contá los objetos de este `build_phase`: son **siete**, más cinco `connect()`. Ese
número es el que hay que recordar, porque en los agents el mismo testbench va a
tener un agent y dos subscribers. Vale anotarlo en el pizarrón para poder volver.
Las dos líneas nuevas del `connect_phase` son un par y se leen juntas: el tester
pone en el `put_export` de la FIFO, el driver saca del `get_export`. Nadie
conecta el tester con el driver — **no se conocen**, y ése es el punto.
El mantra tiene una razón que conviene dar y no repetir como loro: el *port* es
el que pide el servicio, el *export* es el que lo ofrece. La FIFO ofrece las dos
puntas, así que tiene dos exports. Si lo escribís al revés no compila, y el
mensaje del compilador es de los peores de UVM.
Y el detalle que se olvida: `command_f = new(...)`, no `create()`. No es que la
FIFO falte en la factory —está registrada, `tlm1/uvm_tlm_fifos.svh:62`—: es que el
`size` va por constructor y `create()` no lo sabe pasar. Los que de verdad no están
en la factory son los ports y los exports.

---

## Quién espera a quién

#### *El `base_tester`, sin una sola señal*

- Cambia una sola cosa: donde había un handle a la BFM ahora hay un
  `uvm_put_port #(command_s)` llamado `command_port`
- `random_tester` y `add_tester` **no se tocan**. Sólo definen `get_op()` y
  `get_data()`, y ninguna de las dos sabía cómo se aplicaba el estímulo
- Ése es el retorno de haber separado bien en el env: el cambio se detuvo en
  la clase base

{{code:code/u5/put-get/tb_classes/base_tester.svh#class-and-run}}

Note:
Lo importante de esta clase es lo que **desapareció**: no hay un solo `@(negedge
clk)`, ni un `bfm.start`, ni la espera del `done`. El tester quedó reducido a
elegir qué mandar y ponerlo en el puerto.
Y sin embargo `random_tester` y `add_tester` **no se tocaron**: sólo definen
`get_op()` y `get_data()`, y ninguna de las dos sabía cómo se aplicaba el
estímulo. Eso es lo que se compra separando bien — el cambio se detuvo en la
clase base.
El `put()` es una `task` y bloquea: si el driver todavía está manejando la
operación anterior, el tester espera ahí. La FIFO de un elemento de la comunicación entre threads
es lo que sincroniza los dos threads, sin un solo semáforo.
Y hay un `#500` al final, antes del `drop_objection`, que conviene señalar como
lo que es: un parche. Está para que el objection no se caiga mientras la última
operación todavía viaja. En las sequences desaparece, porque `finish_item()` vuelve
recién cuando la operación terminó de verdad. Un `#500` a ojo en un testbench es
siempre una pregunta sin responder.

---

## Quién espera a quién

#### *El driver: el único que toca el cable*

- Un `forever` con dos líneas: `get()` un comando —que bloquea hasta que haya— y
  aplicarlo con `send_op()`. Todo el protocolo vive acá

{{code:code/u5/put-get/tb_classes/driver.svh#class-and-run}}

Note:
Esta división es la que UVM formaliza en los agents: el tester decide QUÉ
mandar, el driver sabe CÓMO mandarlo.
En un agent de verdad el tester se va a llamar sequence y este put/get se va a
llamar get_next_item / item_done. Anticiparlo acá hace que el día 6 arranque
cuesta abajo.

---

## Quién espera a quién

#### *Resumen de la unidad*

- El testbench quedó partido en tres capas que cambian por motivos distintos: el
  **estímulo** (tester), el **protocolo** (driver y monitores) y el **análisis**
  (scoreboard y cobertura)
- Ninguna conoce el interior de las otras: entre ellas sólo viajan comandos y
  resultados
- Falta que el testbench sepa **contar lo que pasa**, que es la unidad que sigue

Note:
Vale cerrar el día con las tres capas escritas en el pizarrón, porque es el mapa
que ordena todo lo que viene: estímulo, protocolo, análisis. Las cuatro secciones
de hoy fueron construir esa separación, y las de mañana no agregan capas — le
ponen nombres de UVM a las que ya están.
La pregunta de control, que además es la que se contesta sola si el día cerró:
¿en cuál de las tres capas vive un `@(negedge clk)`? En una sola, el protocolo. Si
aparece en otra, algo quedó mal separado.
Y el aviso de lo que falta, que conviene dar ahora: entre el tester y el driver
viajan `command_s`, que son structs. Andan, pero no se randomizan solas, no se
comparan solas y no se imprimen solas — y eso es exactamente lo que el día 5 va a
arreglar convirtiéndolas en transactions.
