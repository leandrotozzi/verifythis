<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *1 de 10 · is_active*

**Un agent en `UVM_PASSIVE`, ¿qué construye su `build_phase`?**

- [ ] Nada: un agent pasivo es una cáscara vacía
- [ ] Todo igual que uno activo, pero sin conectar el driver al sequencer
- [x] Los monitores y los analysis ports; el driver y el sequencer, no
- [ ] Sólo el sequencer, para poder recibir sequences de otro agent del mismo env

> **Los monitores, siempre; el sequencer y el driver quedan en `null`** — mirar nunca es opcional: un agent pasivo sigue alimentando scoreboard y cobertura. Lo que se saltea es lo que *maneja* la interface, porque ahí ya hay otro manejándola.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *2 de 10 · El handshake del driver*

**El driver llama a `get_next_item()`, maneja las señales y se olvida del `item_done()`. ¿Qué pasa?**

- [ ] Error de compilación: UVM exige el par completo
- [ ] El sequencer entrega el siguiente item igual, con un warning
- [ ] El item se descarta y el scoreboard reporta un mismatch en la comparación siguiente
- [x] La sequence se queda esperando en `finish_item()` y no avanza más

> **Se cuelga en `finish_item()`, y sin decir nada** — es el error clásico de la primera semana, y el síntoma engaña: no hay error ni warning, el tiempo deja de avanzar y el objection nunca se baja. `get_next_item()` es un préstamo; `item_done()` es devolverlo.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *3 de 10 · Ámbito del config_db*

**El `env` instancia dos agents y hace los dos `set()` con el ámbito `"*"`. ¿Qué recibe cada uno?**

- [ ] Los dos fallan con `uvm_fatal`: el string `"config"` está duplicado
- [ ] Cada uno recibe el suyo, por orden de creación
- [x] Los dos reciben el mismo: el segundo `set()` pisa al primero
- [ ] El primero recibe su config y el segundo queda con `cfg == null`

> **Los dos reciben lo mismo** — el `uvm_config_db` no empareja por orden ni por tipo: empareja por **ruta**. Con `"*"` las dos entradas describen a los mismos componentes, así que la última gana. El ámbito es una ruta en el árbol, no una etiqueta.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *4 de 10 · El sequencer*

**`typedef uvm_sequencer #(command_transaction) sequencer;` compila sin tocar la transaction de las transactions. ¿Por qué?**

- [ ] Porque está registrada en la factory con `` `uvm_object_utils ``
- [ ] Porque `uvm_sequencer` acepta cualquier `uvm_object`
- [ ] Porque el driver hace el `$cast` por dentro
- [x] Porque `command_transaction` extiende `uvm_sequence_item`

> **Por la clase base que elegimos en transactions** — `uvm_sequencer #(T)` exige que `T` derive de `uvm_sequence_item`. Si aquel día la transaction hubiera extendido `uvm_transaction` a secas, este `typedef` hoy no compilaría. Una decisión de una sección habilitando la siguiente.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *5 de 10 · super.build_phase()*

**En vez del config object, ponés `is_active` directo en el `uvm_config_db`. En este curso el agent arranca activo igual. ¿Por qué?**

- [ ] Porque `is_active` es `protected` y el `config_db` no lo puede escribir
- [ ] Porque el `config_db` no acepta tipos enumerados, sólo `int` y `string`
- [ ] Porque `is_active` se fija en el constructor y `build_phase` llega tarde
- [x] Porque quien lo lee es `uvm_agent::build_phase`, y nadie llama a `super`

> **Ese mecanismo está apagado** — `uvm_agent::build_phase` busca `is_active` en el resource pool (está en `code/.uvm/src/comps/uvm_agent.svh`, se puede abrir). Sin `super.build_phase()` esa línea no corre nunca, y nadie avisa. Las dos formas son válidas; lo que no funciona es la mitad de cada una.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *6 de 10 · Object, no component*

**¿Cuál es la diferencia práctica de que una `uvm_sequence` sea un `uvm_object` y no un `uvm_component`?**

- [ ] Que no se puede registrar en la factory ni overridear
- [x] Que se crea, corre y se tira
- [ ] Que no puede tener campos `rand` ni constraints
- [ ] Que UVM la construye en `build_phase`, como a cualquier otra clase del árbol

> **Se crea, corre y se tira** — podés arrancar varias, una detrás de otra, sobre el mismo sequencer. Un componente se construye una vez en `build_phase` y vive hasta el final. Por eso el estímulo no puede ser un componente: cambia test a test, y a veces dentro del mismo test. De ahí sale también que se pueda configurar entre el `create()` y el `start()`, como hace `full_seq.count = 200`.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *7 de 10 · start_item()*

**`start_item(command)` acaba de volver. ¿Qué es lo que eso garantiza?**

- [ ] Que el driver ya recibió el item y está manejando las señales
- [x] Que el sequencer le dio el turno a esta sequence
- [ ] Que el `randomize()` ya se resolvió con las constraints de la clase
- [ ] Que el objection de la fase ya está levantado por el sequencer

> **Tenés el turno —nadie más te va a ganar el driver—, y todavía no entregaste nada** — y por eso el `randomize()` va *después*: es el último momento posible para elegir los valores, cuando ya sabés en qué estado está el DUT. Eso es la randomización tardía, y es donde se enganchan `pre_do()` y `mid_do()`.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *8 de 10 · El camino de vuelta*

**¿En qué momento `command.result` tiene un valor que se puede leer?**

- [ ] Apenas volvió `start_item()`
- [ ] Cuando el `result_monitor` lo publica por su analysis port
- [x] Cuando volvió `finish_item()`, porque el driver lo escribió antes de llamar a `item_done()`
- [ ] Nunca: para recibir una respuesta hay que usar el par REQ/RSP de `uvm_sequence #(REQ, RSP)`

> **Después de `finish_item()`** — no hay ningún canal de vuelta: hay un handle compartido y un acuerdo entre las dos partes. El par REQ/RSP existe y es el mecanismo formal, pero casi nadie lo usa: escribir el resultado en el request alcanza. Esto es lo que hace posible Fibonacci.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *9 de 10 · default_sequence*

**Configurás una `default_sequence` por `uvm_config_db` y te olvidás del `set_automatic_phase_objection(1)`. ¿Qué pasa?**

- [ ] `uvm_fatal` en `build_phase`: la sequence no encuentra el sequencer
- [ ] Corre igual: cuando hay `default_sequence`, el objection lo levanta el sequencer solo
- [x] La `main_phase` termina en t=0 y el test pasa con 0 errores
- [ ] La simulación se cuelga esperando un objection que nadie baja

> **Pasa en cero segundos sin mandar un solo estímulo, y miente** — una fase sin objection termina en cuanto arranca. Es el mismo tipo de bug que el `new()` que se come el override: no rompe, engaña. Y en una regresión de mil tests, el que pasa en cero segundos no lo mira nadie.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 6

#### *10 de 10 · Sub-sequences*

**`full_sequence` arranca a sus hijas con `reset_seq.start(get_sequencer(), this)`. ¿Para qué está el segundo argumento?**

- [ ] Para pasarle el sequencer, porque `get_sequencer()` sólo devuelve el tipo
- [x] Para declarar a la hija sub-sequence de la madre
- [ ] Para que la hija corra en un hilo aparte, en paralelo con la madre
- [ ] Para registrar a la hija en la factory con el nombre de la madre, y poder overridearla

> **Declara la relación madre-hija** — sin él, el sequencer trata a las dos como sequences independientes y compiten por el turno. Con él, la hija hereda el turno de la madre y su prioridad en la arbitración. Y para el paralelo no alcanza con eso: hace falta un `fork` / `join` alrededor de los `start()`.
