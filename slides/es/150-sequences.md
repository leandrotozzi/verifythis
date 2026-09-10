## Sequences

#### *Lo único que quedó cableado*

- Los agents dejaron el testbench encapsulado: un `agent` por interface, el
  análisis en el `env`, y nadie nombrando componentes ajenos
- Menos una línea, la del `run_phase` del test:

```systemverilog
seq.start(env_h.clase_agent_h.sequencer_h);
```

- El test **atraviesa la jerarquía** para llegar al sequencer, y de paso conoce
  el interior del `env` que acabamos de cerrar
- Y hay algo más grande atrás: ese `command_sequence` es **una** clase que hace
  **tres** cosas — resetear, mandar mil operaciones al azar y una dirigida
- Esta sección es sobre lo que pasa adentro de `body()`, y sobre cómo se
  arranca una sequence sin cablearla

Note:
La frase que ordena la sección entera: **el estímulo no es estructura**.
Un componente se construye una vez, antes de que arranque la simulación, y se
queda ahí hasta el final. El estímulo cambia test a test, y a veces cambia
dentro del mismo test. Transactions, agents y sequences son la misma operación repetida
sobre tres cosas distintas: separar los **datos** (transaction), separar la
**estructura** (agent), separar el **estímulo** (sequence).
La pregunta para tirar al grupo antes de seguir: con el `command_sequence` de los
agents, ¿cuántas clases hacen falta para probar tres estímulos y sus combinaciones?
Seis, y crece factorial. En el *UVM Primer* eso se llama *explosion of tester
classes*.

---

## Sequences

#### *Un objeto, no un componente*

![La sequence vive afuera del arbol de componentes; el sequencer, adentro](res/diagrams/sequences_donde_vive.svg)
<!-- .element: class="grande" -->

- El `uvm_sequencer` es un `uvm_component`: **está en el árbol**, tiene padre,
  tiene fases, lo construye el `build_phase` del agent
- La `uvm_sequence` es un `uvm_object`: **no está en el árbol**, no tiene padre,
  no tiene fases, y se crea con un solo argumento — igual que las transactions
- Consecuencia práctica: se crea, corre, termina y se tira. Podés correr otra a
  continuación, o dos a la vez, sin tocar la estructura

Note:
Acá hay un detalle que confunde y conviene adelantarlo, porque van a verlo en el
log: aunque la sequence no esté en el árbol, UVM la reporta **colgada del
sequencer**, con un `@@` en el medio:
`uvm_test_top.env_h.clase_agent_h.sequencer_h@@full_seq.random_seq`
Eso NO significa que sea hija del sequencer. El `@@` es justamente la marca de
que lo que sigue es una sequence y no un componente: a la izquierda, la ruta del
sequencer sobre el que corre; a la derecha, el camino de sequences anidadas. Si
alguien busca `sequencer_h.full_seq` con `uvm_root::get().find()` no lo va a
encontrar nunca.
La otra consecuencia, la que se usa todos los días: como no es un componente, una
sequence puede tener campos configurables que se cambian **entre** el `create()`
y el `start()`. Eso es lo que hace `full_seq.count = 200` al final de la
unidad, y con un componente no se podría: para cuando querés cambiarlo, el
`build_phase` ya pasó.

---

## Sequences

#### *La sequence más chica que existe*

{{code:code/u7/sequences/tb_classes/reset_sequence.svh}}

- Extiende `uvm_sequence #(T)`, parametrizada con el item que va a mandar
- Se registra con `` `uvm_object_utils `` — **no** con `` `uvm_component_utils ``
- Constructor de un solo argumento: `name`, sin `parent`
- Todo el trabajo vive en `body()`, que es una **task**: puede bloquear
- Nadie llama a `body()` a mano: lo llama UVM cuando alguien arranca la sequence

Note:
Los dos errores de tipeo que comete todo el mundo la primera vez, y que dan
mensajes que no ayudan:
1. `` `uvm_component_utils `` en vez de `` `uvm_object_utils ``. El error habla de
   un constructor con dos argumentos y nadie lo relaciona con el macro.
2. `function body()` en vez de `task body()`. La declaración compila, y después
   el `start_item()` de adentro no, porque una función no puede bloquear.
Y una de diseño que vale la pena marcar: el `command` se declara **adentro** de
`body()`, no como campo de la clase. En el *UVM Primer* está como campo. Si es campo,
dos corridas de la misma sequence comparten el handle, y el día que alguien
arranca la misma sequence dos veces en paralelo tenés dos hilos escribiendo el
mismo objeto.
Y una de protocolo, que es la que hace que esta sequence exista: **el primer item
de todo test es un reset**. El VTALU arranca con `reset_n` en 0 y nunca levanta
`done`; el driver se queda en su `while (bfm.done == 0)` y la sequence, en el
primer `finish_item()`. No hay error: la simulación deja de avanzar. Es el mismo
síntoma del `item_done()` olvidado, con otra causa, y conviene mostrarlo una vez
en clase borrando el `reset_sequence` de `full_sequence`.

---

## Sequences

#### *El handshake, ahora desde el lado de la sequence*

![Linea de tiempo de start_item, get_next_item, item_done y finish_item](res/diagrams/sequences_handshake.svg)
<!-- .element: class="grande" -->

- Las mismas cuatro llamadas de los agents, mirando el otro carril:
  `start_item()` bloquea a la **sequence** hasta que el sequencer le da el turno,
  y `finish_item()` la bloquea hasta el `item_done()` del driver
- El tiempo de simulación avanza **sólo** en la barra ámbar: llenar el item no
  cuesta un flanco de reloj
- Dos hilos, cuatro llamadas y ningún `#delay` en el medio

Note:
La confusión número uno de la sección: creer que `finish_item()` vuelve cuando el
item **se entregó**. No: vuelve cuando el driver llamó a `item_done()`, o sea
cuando la operación **terminó en el DUT**. Es la diferencia entre "lo mandé" y
"ya está hecho", y es lo que hace posible la sequence de Fibonacci.
De ahí sale también por qué desapareció el `#500` que el `tester` de las transactions
tenía al final: no era estímulo, era un parche para que el objection no se cayera
antes de tiempo. Con `finish_item()` el estímulo ya no se corta a la mitad. Ojo,
honestidad: el **último** resultado puede quedar sin comparar igual, porque el
objection se baja apenas vuelve `start()` y el `result_monitor` publica un flanco
después. Se ve en el log del `add_test` corrido con `+UVM_VERBOSITY=UVM_HIGH`: 1001
comandos, 1000 comparaciones.
Si alguien pregunta por el primo no bloqueante: existe `try_next_item()`, que
vuelve enseguida con `null` si el sequencer no tiene nada. Es la misma pareja
`get()` / `try_get()` de la comunicación entre threads y sirve cuando el protocolo obliga a manejar
el bus aunque no haya estímulo — ciclos idle, refresh de una DRAM. El VTALU no lo
necesita: entre operación y operación las señales se pueden quedar quietas.

---

## Sequences

#### *Lo que pasa entre `start_item()` y `finish_item()`*

{{code:code/u7/sequences/tb_classes/random_sequence.svh#body}}

- Cuando `start_item()` vuelve, la sequence **ya tiene el turno** del sequencer:
  nadie más le va a ganar el driver
- Recién ahí se llenan los campos, o se randomiza. Eso es la **randomización
  tardía**: los valores se eligen en el último momento posible
- Sirve porque a esa altura ya se sabe en qué estado está el DUT, y una
  constraint puede depender de eso
- `randomize()` sigue yendo con su `else`: devuelve 0 y no aborta nada — es lo
  mismo que vieron en la unidad de Constrained Random

Note:
La pregunta honesta: "¿y si randomizo antes de `start_item()`?". Funciona. En un
testbench chico no se nota la diferencia.
Se nota cuando la sequence tiene mil items encolados y una constraint depende de
algo que cambia durante la corrida —una dirección que ya se escribió, un buffer
que se llenó, el resultado anterior—. Si randomizaste todo al principio,
decidiste con información vieja.
El otro motivo, más práctico: entre `start_item()` y `finish_item()` es donde UVM
llama a `pre_do()` y `mid_do()`, que son los ganchos que usa la gente para
inyectar errores sin tocar la sequence original. Si llenás el item antes, esos
ganchos no tienen nada que hacer.
Y el enganche con el día 5: acá es donde va el `randomize() with {}` del cierre de
cobertura. Se pide el caso dirigido en el punto de uso, sin escribir una clase
nueva. La slide que sigue es exactamente eso, con la trampa de Verilator incluida.

---

## Sequences

#### *Randomización tardía dirigida, y el agujero de Verilator*

```systemverilog
start_item(command);
command.data.constraint_mode(0);                       // 1. apago el dist
if (!command.randomize() with {A inside {[1:10]};})    // 2. pido lo dirigido
   `uvm_fatal("SEQ", "randomize() fallo")
finish_item(command);
```

- Medido con Verilator 5.052, sobre una clase con las constraints de
  `command_transaction`, 100 randomizaciones de cada forma:

```sh
with {op == mul_op}                       100 de 100   op no tiene dist
with {A inside {[1:10]}}                    1 de 100   A si lo tiene
constraint_mode(0) + with {A inside ...}  100 de 100   el rodeo
```

- La regla, en una línea: **si el `with {}` toca un campo que tiene `dist`,
  apagá antes esa constraint**
- No es del lenguaje, es de la herramienta: `repro-dist-with.sv` en
  `code/verilator/`

Note:
Es la misma limitación que ya vieron en la unidad de Constrained Random, pero acá
aparece en el lugar donde de verdad la van a usar, así que conviene medirla de
nuevo contra la transaction real.
Lo que la medición agrega sobre lo que dice `docs/verilator.md`: el disparador no
es "hay un `dist` en la clase". Es **el `with {}` restringiendo un campo que tiene
`dist`**. Pedir `op == mul_op` anda perfecto, aunque `A` y `B` tengan `dist` en la
misma resolución. Por eso las sequences de la sección no chocan con esto: ninguna
usa `with {}`.
Y el rodeo no es una concesión: para un caso dirigido, apagar la constraint de
reparto es lo correcto igual. El `dist` está para que el random pegue en los
bordes; si ya sabés qué valor querés, no tiene nada que aportar.
`constraint_mode(0)` es por **objeto**, no por clase, y el objeto se tira después
de `finish_item()`: no hay que acordarse de volver a prenderla.

---

## Sequences

#### *El item vuelve con el resultado adentro*

{{code:code/u7/sequences/tb_classes/driver.svh#run_phase}}

- El driver escribe `command.result` **antes** de llamar a `item_done()`
- La sequence todavía tiene el handle a ese mismo objeto: cuando `finish_item()`
  vuelve, el resultado está ahí
- Es el camino de vuelta, y por eso `command_transaction` gana un campo `result`
  en esta unidad — el único cambio a la transaction desde que se creó
- Rompe *MOOCOW* a propósito: el driver modifica un objeto que no creó. Está
  acordado entre las dos partes, y es el único lugar del testbench donde se hace

Note:
Este es el punto más sutil de la sección y conviene decirlo despacio: **no hay
ningún canal de vuelta**. No hay un port, no hay una FIFO. Hay un handle
compartido, y las dos partes se pusieron de acuerdo en que el driver escribe y la
sequence lee, y en que el momento seguro para leer es después de `finish_item()`.
Si alguien pregunta "¿y no era que había que clonar?": sí, esa es la regla de las transactions, y ésta es la excepción documentada. UVM tiene además un mecanismo
formal para esto —el par REQ/RSP de `uvm_sequence #(REQ, RSP)` con
`put_response()` del lado del driver y `get_response()` del lado de la sequence—
que casi nadie usa, porque escribir el resultado en el request alcanza en la
enorme mayoría de los casos. Vale nombrarlo para que lo reconozcan si lo ven.
Detalle de implementación que sí importa: el `send_op` lee `bfm.result` en el
mismo flanco en que ve `done` alto. Un flanco más tarde el DUT ya arrancó la
operación siguiente.

---

## Sequences

#### *El camino de vuelta formal: `get_response()`*

```systemverilog
// La sequence declara DOS tipos, y la respuesta ya no es el request
class fib_sequence extends uvm_sequence #(command_transaction, result_transaction);
   start_item(cmd);
   finish_item(cmd);
   get_response(rsp);              // bloquea hasta que el driver conteste

// Y el driver, del otro lado:
   seq_item_port.get_next_item(req);
   rsp = result_transaction::type_id::create("rsp");
   rsp.set_id_info(req);           // sin esto la respuesta no encuentra su sequence
   seq_item_port.item_done(rsp);   // o item_done() ahora y put_response(rsp) después
```

- El handle compartido de la slide anterior vale mientras el driver sea
  **bloqueante y atienda de a uno**. El del curso lo es
- Un driver *pipelined* llama `item_done()` apenas mete el comando y la respuesta
  llega N ciclos más tarde: para entonces la sequence ya mandó otro item, y
  escribir en `req.result` le escribe **al item equivocado**
- `set_id_info(req)` le copia a la respuesta el id de sequence y de transacción.
  Es lo que hace que `get_response()` sepa a quién contestarle
- Los otros dos casos donde hace falta: un VIP que **clona** el item, y un
  protocolo con **más de una respuesta** por request

Note:
Ésta es la media slide que evita una respuesta pobre en una entrevista. La
pregunta suena *"¿cómo le devolvés el dato a la sequence?"*, y contestar "le
escribo el campo `result` al item" es correcto **para este driver** y falla en
cualquier bus real. Conviene decir las dos mitades juntas.
El razonamiento que hay que dejar: el truco del handle compartido no es una
técnica, es una consecuencia de que el driver sea bloqueante. La condición está
escrita en el `get_next_item()`/`item_done()` de la slide anterior — mientras el
`item_done()` esté **después** de tener la respuesta, hay un solo item en vuelo y
el handle alcanza. El día que alguien mueva ese `item_done()` para arriba para
ganar throughput, el testbench sigue compilando y empieza a mentir.
El otro modo de falla, más traicionero: un VIP que clona el item entre la
sequence y el driver. Ahí el driver escribe en su copia, la sequence lee el
original, y el resultado que llega es siempre el anterior. No hay error, no hay
warning: hay un scoreboard corrido en uno.
Y el detalle de `set_id_info()`, que es el que hace que esto falle en silencio la
primera vez: si no está, la respuesta se manda igual y `get_response()` se queda
esperando para siempre. Un test que "cuelga después de la primera transacción" y
usa REQ/RSP es este bug hasta que se demuestre lo contrario.


---

## Sequences

#### *Fibonacci: cuando el estímulo depende del resultado*

{{code:code/u7/sequences/tb_classes/fibonacci_sequence.svh#body}}

- Cada suma necesita el resultado de la anterior: sin camino de vuelta esto no se
  puede escribir
- `finish_item()` vuelve **después** de que la ALU terminó, así que
  `command.result` ya es válido
- Es el mismo `env`, el mismo agent, el mismo driver y el mismo BFM que el test
  random. Cambia sólo la sequence

Note:
Fibonacci no está para enseñar Fibonacci: está para forzar el caso en que el
estímulo N+1 depende del resultado N. Un test así con el `tester` de las transactions
es imposible sin darle al tester un handle al monitor, o sea sin romper la
separación que veníamos construyendo.
Números para el pizarrón: 0 1 1 2 3 5 8 13 21 34 55 89 144 233. Se corta en 233
porque el siguiente es 377 y `A` y `B` son de 8 bits. Que el alumno vea por qué el
`for` va hasta 14 y no hasta 20 vale más que la sequence entera.
Y una que se ve en la corrida real: el test entero tarda **500 unidades de
tiempo**, contra las 43.000 del test random. Trece operaciones. Un test dirigido
bien escrito es barato; lo caro es el random, y por eso se corre de noche.

---

## Sequences

#### *Sequences que llaman sequences*

![full_sequence arrancando tres sub-sequences sobre el mismo sequencer](res/diagrams/sequences_subsequences.svg)
<!-- .element: class="grande" -->

- Una sequence puede arrancar otras: es la forma de componer estímulo sin
  duplicar código
- El `command_sequence` de los agents, partido en tres piezas que ahora se
  combinan como uno quiera
- El sequencer arbitra: reciba lo que reciba, al driver le entrega **un item por
  vez**

Note:
La idea de la slide es que una sequence no es una capa especial: es un objeto con
un `body()`, y adentro de un `body()` se puede arrancar otra sequence igual que
se arranca la primera. No hay un límite de anidamiento ni una clase distinta para
"sequence que llama sequences".
La consecuencia práctica, que es la que vale: el estímulo se compone como
funciones. Una sequence chica —"escribí los cuatro registros", "mandá una
multiplicación máxima"— se escribe una vez y después entra en cualquier
escenario. Es exactamente lo que en el testbench convencional se hacía copiando y
pegando bloques del tester.
El último bullet es el que evita el malentendido más común: que tres sequences
estén compuestas **no** quiere decir que sus items se mezclen en el bus. El
sequencer entrega uno por vez, y si dos sequences compiten sobre el mismo
sequencer hay una política de arbitración decidiendo. Con sequences anidadas
sobre un solo sequencer, el orden es el que dice el `body()`.

---

## Sequences

#### *`full_sequence`: tres piezas, un solo sequencer*

{{code:code/u7/sequences/tb_classes/full_sequence.svh#body}}

- `get_sequencer()` devuelve el sequencer que le pasó `start()` a **esta**
  sequence: las hijas corren sobre el mismo
- El segundo argumento, `this`, las declara **hijas**. Sin él compiten con la
  madre en la arbitración en vez de heredar su turno
- `random_seq.count = count` es la ventaja de que la sequence sea un objeto: se
  configura entre el `create()` y el `start()`
- Para correr dos en paralelo, `fork` / `join` alrededor de los `start()`, y el
  sequencer entrelaza los items

Note:
`get_sequencer()` es el accesor de IEEE 1800.2; el campo se llama `m_sequencer` y
el *UVM Primer* lo usa directo. Las dos formas andan — la del `get_` es la que conviene
enseñar, porque `m_` es la convención de UVM para "esto es interno".
Y si alguien ya leyó código de producción va a preguntar por `p_sequencer`: es un
handle **tipado** al sequencer, que aparece cuando usás
`` `uvm_declare_p_sequencer(mi_sequencer) ``. Sirve sólo si extendiste
`uvm_sequencer` para ponerle algo propio, porque `m_sequencer` es de tipo
`uvm_sequencer_base` y no ve esos campos. Como en este curso el sequencer es un
`typedef` pelado, `p_sequencer` no aporta nada.
El segundo argumento del `start()` es el que casi nadie pone y casi siempre
importa: sin padre, si la madre y la hija piden turno al mismo tiempo el sequencer
las trata como dos sequences independientes. Con padre, la hija hereda prioridad y
contexto.
Si preguntan por el orden con `fork`/`join`: la arbitración por defecto es
`UVM_SEQ_ARB_FIFO`, o sea orden de llegada. Se cambia con `set_arbitration()` del
sequencer, y hay seis modos, incluido uno con pesos.

---

## Sequences

#### *Arrancar una sequence, forma 1: `start()`*

{{code:code/u7/sequences/tb_classes/full_test.svh#run_phase}}

- `start(sequencer)` le pasa a la sequence el sequencer sobre el que va a correr
  y **no vuelve hasta que `body()` terminó**
- El test levanta el objection antes y lo baja después: la corrida dura
  exactamente lo que dura el estímulo
- Es explícito y se lee de arriba a abajo. Para un test que corre una sola
  sequence, es lo que conviene
- Y sigue teniendo el problema de la primera slide: `sequencer_h` salió de
  `env_h.clase_agent_h.sequencer_h`

Note:
`start()` hace tres cosas, en este orden: guarda el sequencer (es lo que después
devuelve `get_sequencer()`), llama a `pre_body()` / `body()` / `post_body()`, y
vuelve.
El detalle que hay que subrayar: el objection lo levanta **el test**, no la
sequence. La sequence no sabe nada de fases. Eso es a propósito — la misma
sequence tiene que poder correr adentro de otra sequence, donde levantar un
objection no tendría sentido, y de hecho es lo que hace `full_sequence` con sus
tres hijas.
El `sequencer_h` lo resuelve `base_test` en `end_of_elaboration_phase`, no en
`build_phase`: durante el `build_phase` del test el agent todavía no construyó su
sequencer. Es la misma razón por la que las conexiones van en `connect_phase`.

---

## Sequences

#### *Forma 2: `default_sequence` por `uvm_config_db`*

{{code:code/u7/sequences/tb_classes/default_seq_test.svh#build_phase}}

- El test **no tiene `run_phase`**: el sequencer arranca la sequence solo, al
  empezar la fase
- El nombre de instancia lleva el sufijo `_phase`: `"...sequencer_h.main_phase"`
  quiere decir *"en la `main_phase` de ese sequencer"*
- Se puede configurar por **instancia** (como acá, con
  `uvm_config_db #(uvm_sequence_base)`) o por **tipo**
  (`uvm_config_db #(uvm_object_wrapper)` + `get_type()`). Si están las dos gana
  la de **mayor precedencia**, y a igual precedencia el **último `set()`**
- El sequencer dejó de ser un handle y pasó a ser una **ruta**: eso ya es
  configuración, no código

Note:
**La trampa, y es de las que no avisan.** Sin la línea
`set_automatic_phase_objection(1)`, nadie levanta el objection de la `main_phase`.
Y una fase sin objection termina en cuanto arranca.
Lo probado con Verilator 5.052: la corrida termina en **t=0**, imprime el Report
Summary con **0 UVM_ERROR / 0 UVM_FATAL**, y sale con código 0. O sea: el test
PASA sin haber mandado un solo estímulo. Está en `code/u7/sequences` como
`no_objection_test`, para poder correrlo en clase al lado del bueno.
Es exactamente el mismo tipo de bug que el `new()` que se come el override de las transactions: no rompe, **miente**. Y en una regresión de mil tests, un test que pasa
en cero segundos no lo mira nadie.
Detalle fino: conviene `main_phase`, no `run_phase`, pero no porque `run_phase` no
sirva — `uvm_task_phase::traverse` llama `start_phase_sequence()` en **toda** fase
de tarea (`base/uvm_task_phase.svh:121`), así que
`"…sequencer_h.run_phase"` funciona igual. La razón es de convivencia: la
`run_phase` corre en paralelo con el cronograma reset → configure → main →
shutdown, y enganchando en `main_phase` la sequence entra en ese cronograma en vez
de por al lado.

---

## Sequences

#### *Cuándo cada una*

| | `seq.start(sqr)` | `default_sequence` |
| --- | --- | --- |
| Dónde se escribe | `run_phase` del test | `build_phase` del test, o el `top` |
| Objection | lo maneja el test | `set_automatic_phase_objection(1)` |
| Se lee | de arriba a abajo | hay que buscarlo |
| Varias sequences en orden | trivial | una por fase |
| Cambiarla sin recompilar | no | sí, es una config |
| Conoce el interior del `env` | sí, por el handle | no, sólo la ruta |
| Agent reusable de terceros | no siempre se puede | es el mecanismo previsto |

- Para los tests del curso: **`start()`**, porque se ve
- Para un agent que le entregás a otro equipo: `default_sequence`, porque le deja
  cambiar el estímulo sin tocar tu código

Note:
En la industria conviven las dos y la elección casi siempre es política, no
técnica: `start()` cuando el que escribe el test es el dueño del testbench,
`default_sequence` cuando el testbench es de otro.
Un tercer camino que vale nombrar sin desarrollar: el mismo `uvm_config_db` desde
el módulo `top`, con `null` como contexto. Ahí el estímulo se elige por línea de
comandos y el testbench ni se recompila. Es como funcionan las regresiones
grandes.
Y la fila que importa para el arco de la sección es la anteúltima: `default_sequence`
es lo que termina de cerrar el `env` que los agents encapsularon.

---

## Sequences

#### *La macro `` `uvm_do `` y por qué el curso no la usa*

```systemverilog
`uvm_do(command)                         // una linea

command = command_transaction::type_id::create("command");   // cuatro
start_item(command);
if (!command.randomize()) `uvm_fatal("SEQ", "randomize() fallo")
finish_item(command);
```

- `` `uvm_do `` hace exactamente esas cuatro cosas: crear, `start_item`,
  randomizar, `finish_item`
- Lo que esconde: el `randomize()` **sin else**, así que una constraint sin
  solución pasa en silencio
- Lo que impide: llenar campos a mano entre las dos llamadas — o sea, todo lo de
  las slides anteriores
- Lo que rompe: el mensaje de error apunta a la macro expandida, no a tu código
- Existe una familia entera (`` `uvm_do_with ``, `` `uvm_create ``,
  `` `uvm_send ``) y el mismo argumento vale para todas

Note:
Es la misma discusión que las macros `` `uvm_field_* `` de las transactions, y la
misma conclusión: ahorran tipeo y te cobran en debug.
Vale ser justo: `` `uvm_do_with `` es genuinamente cómodo para una constraint
inline de una línea, y la vas a ver en todos los testbenches del mundo. Hay que
saber leerla. Lo que el curso no hace es enseñarla primero: quien aprende con la
macro no sabe qué pasa entre `start_item()` y `finish_item()`, y eso es la
sección entera.
Regla práctica para el trabajo: leer todas, escribir las explícitas.

---

## Sequences

#### *El override sigue funcionando, y ninguna sequence se enteró*

{{code:code/u7/sequences/tb_classes/add_test.svh}}

- Es el mismo `add_test` de las transactions, palabra por palabra
- `random_sequence` sigue creando `command_transaction::type_id::create()`; la
  factory le devuelve `add_transaction`
- Resultado medido: 1000 operaciones, **todas** `add_op`, 0 `UVM_ERROR`
- `maxmult_sequence` sigue mandando `mul_op` bajo `add_test` — porque no
  randomiza, y **la constraint sólo actúa en `randomize()`**

Note:
Es la mejor prueba de que la separación funcionó: cambiar el **tipo de dato** no
requirió tocar el estímulo, y cambiar el **estímulo** no requiere tocar el tipo de
dato. Dos ejes independientes, que en las transactions estaban pegados y en los agents
todavía compartían clase.
Y el último bullet es el repaso de la trampa de las transactions, ahora en un lugar
donde se ve corriendo: la factory elige el TIPO, las constraints sólo actúan en
`randomize()`.

---

## Sequences

#### *Dos sequences sobre el mismo sequencer: la arbitración*

- Hasta acá cada sequencer tuvo **una** sequence por vez. En un testbench real
  hay varias en paralelo sobre el mismo driver —tráfico de fondo, un test
  dirigido, un inyector de errores— y alguien tiene que repartir los turnos

```systemverilog
fork
   fondo_seq.start(sqr);                 // prioridad 100, la de por defecto
   urgente_seq.start(sqr, null, 500);    // el tercer argumento es la prioridad
join
```

| El modo, en `sqr.set_arbitration(...)` | Cómo reparte |
| --- | --- |
| `UVM_SEQ_ARB_FIFO` | orden de llegada, y **la prioridad no se mira** (default) |
| `UVM_SEQ_ARB_STRICT_FIFO` | la prioridad manda; a igual prioridad, orden de llegada |
| `UVM_SEQ_ARB_WEIGHTED` | al azar, con la prioridad como peso |
| `UVM_SEQ_ARB_RANDOM` | al azar, todas igual |
| `UVM_SEQ_ARB_STRICT_RANDOM` | al azar, pero sólo entre las de mayor prioridad |
| `UVM_SEQ_ARB_USER` | `user_priority_arbitration()`, la escribís vos |

- El default **ignora la prioridad**: poner un 500 y no cambiar el modo es el
  error de esta slide, y no avisa nadie

Note:
La pregunta que ordena la slide es *"¿quién decide cuál item entra al driver?"*,
y hasta hoy la respuesta era "no hay a quién decidirle". El sequencer arbitra
**por item**, no por sequence: dos sequences en `fork` no se turnan de a bloques,
se intercalan de a items. Vale decirlo porque la intuición dice lo contrario.
El error que hay que dejar grabado está en el último bullet y es de manual: se
escribe la prioridad, se corre, y no pasa nada — porque `UVM_SEQ_ARB_FIFO` no la
mira. La prioridad sin `set_arbitration(UVM_SEQ_ARB_STRICT_FIFO)` es un
comentario caro.
`UVM_SEQ_ARB_STRICT_FIFO` es el que se usa el 90 % de las veces, y el nombre
confunde: *strict* es por la prioridad, no por la FIFO. Primero ordena por
prioridad y recién dentro de cada nivel respeta el orden de llegada.
Y el que casi nadie usa pero conviene nombrar, porque explica para qué existe el
`UVM_SEQ_ARB_USER`: hay protocolos donde el turno depende del estado del DUT —no
mandes una escritura si la FIFO del DUT está llena—. Eso no es una prioridad, es
una función, y para eso está el modo de usuario. El primo de esa idea es
`is_relevant()`, que deja a una sequence fuera de la arbitración hasta que ella
misma diga que está lista.

---

## Sequences

#### *`lock()` y `grab()`: cuando la arbitración no alcanza*

- Hay escenarios que **no se pueden intercalar**: una secuencia de configuración,
  un burst atómico, un lee-modifica-escribe. Si otra sequence mete un item en el
  medio, el escenario dejó de ser el que escribiste

```systemverilog
task body();
   grab();                  // se cuela adelante de todas y cierra la puerta
   ... los items del escenario, sin nadie en el medio ...
   unlock();                // ungrab() es el mismo metodo, con otro nombre
endtask
```

- **`lock()` hace cola**: espera su turno como cualquiera y recién entonces cierra
  la puerta. **`grab()` se cuela**: pasa adelante de todas, incluso de las de más
  prioridad
- Los dos se sueltan con `unlock()`. Sin el `unlock()`, si la sequence **sigue
  viva** el sequencer queda cerrado para siempre y sin un solo error; si su
  `body()` termina, UVM lo saca y grita `SEQFINERR`
- La regla: `grab()` para reset y recuperación de error —lo que no puede esperar—,
  `lock()` para todo lo demás, y el `unlock()` en la misma `body()`

Note:
La diferencia entre los dos es una sola palabra y conviene decirla así: `lock` es
educado, `grab` es maleducado. Los dos terminan con el sequencer para vos solo; lo
que cambia es si esperás tu turno o te lo tomás.
Cuándo hace falta de verdad, porque el abuso de esto es un clásico: sólo cuando el
escenario pierde sentido si algo se intercala. Un lee-modifica-escribe sobre un
registro es el ejemplo canónico —si entre la lectura y la escritura pasa otra
transacción, el valor que escribís es viejo—. Mandar diez items seguidos no
necesita un lock: eso ya lo garantiza una sequence.
Los dos finales del `unlock()` que falta hay que contarlos juntos, porque uno
avisa y el otro no. Si la sequence que tiene el lock termina su `body()`,
`uvm_sequencer_base::remove_sequence_from_queues`
(`seq/uvm_sequencer_base.svh:1258-1267`) le saca el lock y reporta un
`UVM_ERROR SEQFINERR` — "should not finish before locks … are removed": molesto,
pero con nombre y apellido. El caso mudo es el otro: la sequence sigue viva y
bloqueada en otra cosa, y ahí el sequencer queda cerrado sin que nadie diga nada.
Ése es el que manda a buscar al lado equivocado: la simulación no avanza y el
`+UVM_OBJECTION_TRACE` no dice nada raro, porque la objection está bien — el que
está trabado es el driver, esperando un item que nunca va a llegar. La
herramienta que lo muestra es `+UVM_TIMEOUT` y después leer quién tiene el lock.
Y el detalle que salva una tarde: `grab()` no interrumpe el item que está en
vuelo. Se cuela en la próxima arbitración, no en el medio de un handshake — que
es justamente lo que uno quiere.

---

## Sequences

#### *El testbench, completo*

![El testbench final: sequences, agent, sequencer, driver, monitores y la capa de analisis](res/diagrams/sequences_tb_completo.svg)
<!-- .element: class="grande" -->

- Es el diagrama que se dibuja hoy en cualquier proyecto de verificación, con los
  nombres que se usan hoy
- Todo lo que está adentro del `env` se construye una vez y no cambia. Lo que
  cambia entre un test y otro es la nube de sequences de arriba

Note:
El diagrama muestra **un** agent, que es la unidad de reuso; en `code/u7/sequences` hay
dos, el activo y el pasivo de los agents, y el de abajo es idéntico salvo que
no tiene sequencer ni driver.
Vale hacer el recuento en voz alta: el testbench convencional era un `initial`
de cien líneas que manejaba señales. Éste tiene test, env, agent, sequencer,
driver, dos monitores, cobertura y scoreboard, y cada pieza se puede reemplazar
sin tocar las otras. Y las tres capas de arriba —sequences, agent, análisis—
cambian por motivos distintos: el estímulo cambia por test, la estructura por
diseño, el análisis por plan de verificación.

---

## Sequences

#### *Resumen de la unidad · la sequence y el item*

- El estímulo salió del árbol de componentes: es un `uvm_object`, no un
  `uvm_component`, y por eso se crea, se configura, corre y se tira
- Todo pasa adentro de `body()`, entre `start_item()` y `finish_item()`: ahí se
  llena el item, ahí va el `randomize()`, y ahí se enganchan `pre_do` y `mid_do`
- El driver escribe el resultado **adentro del item** antes de `item_done()`: es
  el camino de vuelta, y es lo que hace posible un estímulo que reacciona
- Dos formas de arrancar: `start(sequencer)` explícito, o `default_sequence` por
  `uvm_config_db` — que además saca la última línea cableada del testbench

Note:
La primera mitad del resumen es el mecanismo: qué es una sequence, dónde
vive el `randomize()`, y por dónde vuelve el resultado. Si alguien se perdió en
la unidad, se recupera acá.

---

## Sequences

#### *Resumen de la unidad · cómo se componen*

- Las sequences se componen: una llama a otras, en serie o con `fork`/`join`
- Y cuando hay **más de un sequencer**, la que compone es una **sequence
  virtual**, que llega apenas empieza el día 7 ↪ día 7
- Con **dos sequences sobre el mismo sequencer** el que reparte es el sequencer:
  prioridad y `set_arbitration(...)`, y `lock()`/`grab()` para el escenario que no
  se puede intercalar
- Con esto el testbench del curso está completo —le falta una sola pieza, la de
  mañana— y es la forma en que se escribe hoy en la industria

Note:
Cierre del día 6. Ninguna de las piezas que sí vimos es magia: las construimos todas a mano —el
observer de hablar con varios objetos, la FIFO de put y get, el tester de
transactions— antes de que UVM nos las
diera hechas. Ese es el motivo de que el curso vaya en este orden y no arranque
por el `uvm_agent`.
Y el mejor lugar para seguir leyendo es `code/.uvm/src/`: a esta altura
`uvm_sequence_base.svh` se puede abrir y entender.
Lo que queda para mañana es la **sequence virtual**, y queda afuera de hoy a
propósito: recién se entiende con el testbench de esta unidad cerrado, y la
mañana del día 7 es donde el alumno mira un DUT nuevo y tiene que decidir qué
estructura le corresponde.
