## Agents

#### *El problema: un testbench que no se puede copiar*

- El `env` que dejamos en las transactions funciona, pero es un **bloque soldado**:
  siete componentes y cinco `connect()` escritos a mano
- Cada uno de esos componentes existe por una sola razón: **maneja o mira la
  misma interface**, la `vtalu_bfm`
- Preguntá qué pasa si el diseño trae *dos* VTALU: hay que copiar los siete
  objetos, las cinco conexiones, y renombrar todo
- Copiar y pegar estructura es exactamente lo que veníamos evitando desde el `env`
- UVM le pone nombre a la solución: **`uvm_agent`**

![El env de transactions contra el env con agent](res/diagrams/agents_env_antes_despues.svg)
<!-- .element: class="grande" -->

Note:
La pregunta que ordena la sección entera: ¿cuál es la unidad natural de reuso
en un testbench? No es el componente, y no es el env. Es **la interface**.
Todo lo que sabe hablar un protocolo se empaqueta junto, y esa caja se instancia
una vez por cada interface del diseño. Ese es el agent, y no es más que eso.
Si el grupo viene de RTL, la analogía funciona sola: el agent es al testbench lo
que un módulo parametrizable es al RTL. Nadie instancia una FIFO copiando sus
registros de a uno.

---

## Agents

#### *Qué hay adentro de un agent*

- Un `uvm_agent` es un `uvm_component` más: mismo árbol, mismas fases, misma
  factory
- Lo que cambia es **qué mete adentro**, siempre lo mismo:
  - un *sequencer*, que entrega estímulo
  - un *driver*, que lo convierte en señales de la BFM
  - los *monitores*, que miran el bus y publican transactions
- Y expone hacia afuera **dos `uvm_analysis_port`**: el que publica comandos y
  el que publica resultados
- El scoreboard y la cobertura **no van adentro**: son análisis, y viven en el
  `env` colgados de esos dos puertos
- Desde esta sección cada pieza usa **su** clase base: `uvm_driver #(T)`,
  `uvm_sequencer #(T)` y `uvm_monitor` en vez de `uvm_component` a secas

![Estructura interna del agent](res/diagrams/agents_agent.svg)
<!-- .element: class="grande" -->

Note:
Acá hay una decisión que conviene decir en voz alta porque el *UVM Primer* la
toma al revés: mete el scoreboard y el coverage *adentro* del agent. Nosotros no.
La razón es práctica: el día que ponés un agent pasivo sobre una interface que
maneja otro, no querés que aparezca un segundo scoreboard de regalo. El agent es
la capa de **protocolo**; el análisis es del env, que es el que sabe qué se está
verificando.
La otra razón es que si el scoreboard vive adentro, los dos analysis ports que
el agent expone no tienen a quién servir, y la mitad del diseño queda decorativa.
Sobre el último bullet, porque alguien va a abrir `code/u7/agents` y lo va a ver:
hasta las transactions los monitores extendían `uvm_component`; desde acá extienden
`uvm_monitor`. Y `uvm_monitor` **no agrega ni una línea de comportamiento** — es
`uvm_component` con otro nombre. Lo que agrega es intención: cualquiera que abra
el testbench sabe qué hace esa clase sin leerla, y `print_topology()` la muestra
como monitor.
Es la misma economía que `uvm_env`: la mitad del valor de UVM no está en el
código de la librería, está en que todos usan los mismos nombres para las mismas
cosas. `uvm_driver` y `uvm_sequencer` sí traen cosas —el `seq_item_port` y la
arbitración—; `uvm_monitor`, `uvm_env` y `uvm_agent` son casi puro vocabulario.

---

## Agents

#### *El salto: del tester a la sequence*

- En los put y get ports partimos el estímulo en dos: el `tester` elegía **qué**
  mandar, el `driver` sabía **cómo**
- Los uníamos con `uvm_put_port` / `uvm_get_port` y una `uvm_tlm_fifo` en el
  medio: tres componentes en el árbol y dos `connect()`
- UVM ya trae eso hecho, y con un nombre: el **`uvm_sequencer`**
- El `driver` deja de ser un `uvm_component` genérico y pasa a ser
  `uvm_driver #(T)`, que **ya viene con un `seq_item_port`**
- Y el `tester` desaparece: lo reemplaza una `uvm_sequence`, que **no es un
  componente** — es un objeto, no está en el árbol y no se conecta

![Del put/get al seq_item_port](res/diagrams/agents_seq_item_port.svg)
<!-- .element: class="grande" -->

Note:
Éste es el salto que más cuesta del curso, y el motivo es que hay dos cambios en
la misma línea. Conviene separarlos.
Cambio uno, estructural: la FIFO se llama sequencer y viene con el driver.
Cambio dos, conceptual: el generador de estímulo **deja de ser un componente**.
Un componente se construye una vez en `build_phase` y vive toda la simulación;
una sequence se crea, corre, termina y se tira — y podés correr otra a
continuación sobre el mismo sequencer. Eso es lo que hace que un test pueda
combinar estímulos sin tocar la estructura, y de eso se trata la sección de
sequences.
La pregunta para tirar al grupo: ¿por qué el driver del agent pasivo no existe,
pero el monitor sí? Porque manejar es opcional, mirar no.

---

## Agents

#### *El handshake: `get_next_item()` / `item_done()`*

- El driver ya no hace `get()`: hace `get_next_item()`, que **bloquea** hasta
  que la sequence tenga algo
- Cuando terminó de manejar las señales, llama a `item_done()`
- Esa segunda llamada es lo que el par `put`/`get` **no tenía**: es el driver
  avisando *"ya está, mandame el próximo"*
- Sin `item_done()` la sequence se cuelga para siempre en su `finish_item()`, y
  la simulación se queda sin avanzar sin un solo mensaje de error
- El par siempre va completo, y en ese orden

{{code:code/u7/agents/tb_classes/driver.svh|lines=18-24}}

Note:
El olvido de `item_done()` es el error número uno de la primera semana, y el
síntoma es engañoso: no hay error, no hay warning, la simulación simplemente
deja de avanzar en el tiempo y el objection nunca se baja. Verilator no tiene
timeout por defecto: se queda girando hasta que lo matás.
El truco para acordarse: `get_next_item` / `item_done` es un **préstamo**, no
una copia. La sequence te presta el item y se queda esperando a que lo
devuelvas. `put`/`get` era una entrega: el tester soltaba el comando y seguía.
Y de ahí sale la otra diferencia útil: como la sequence sigue teniendo el
handle, el driver puede escribirle el resultado adentro y la sequence lo lee al
volver de `finish_item()`. Eso lo usa la sección de sequences.

---

## Agents

#### *El driver, ahora `uvm_driver`*

- `uvm_driver #(command_transaction)` trae el `seq_item_port` gratis: no se
  declara ni se instancia con `new()`
- El `build_phase` ya no busca la BFM directo en el `config_db`: se la pide al
  **config del agent**
- El `run_phase` es **tres líneas**: pedir el item, `bfm.send_op(...)`, avisar
  que terminó. El driver no toca un cable
- El protocolo sigue donde lo dejamos en interfaces y BFM: **adentro de la BFM**. Por
  eso el driver de un agent es tan corto, y por eso cambiar de protocolo no lo
  toca

{{code:code/u7/agents/tb_classes/driver.svh}}

Note:
Conviene abrir el driver de los put y get ports al lado y contar líneas: son casi las
mismas. Lo único que cambió es de dónde sale el item —antes un `uvm_get_port`,
ahora el `seq_item_port`— y que hay un `item_done()` al final.
La pregunta que vale hacer: ¿por qué el driver es tan corto? Porque el protocolo
no está acá. Está en la BFM desde interfaces y BFM, y esta clase sólo traduce
*transaction* a *llamada*. Ése es el reparto de trabajo que hace que un agent de
AXI tenga el mismo driver de veinte líneas.
Y el corolario, que es el del apéndice del bus: cuando cambia el protocolo,
cambia la BFM y el monitor. El driver, el agent, el env y el test no se enteran.

---

## Agents

#### *El sequencer se declara con un `typedef`*

- `uvm_sequencer` es una clase paramétrica: se parametriza con el tipo de item
  que va a entregar
- No hace falta extenderla para nada: se usa tal cual
- Un `typedef` en el package le pone nombre corto, y ese nombre es el que usan
  el agent y el `create()`

```systemverilog
typedef uvm_sequencer #(command_transaction) sequencer;
```

- La `command_transaction` de las transactions ya extiende `uvm_sequence_item`, así
  que **no hay que tocarla**: por eso elegimos esa clase base y no
  `uvm_transaction`
- El `typedef` va **después** del `` `include `` de la transaction y **antes**
  del driver y del agent

Note:
Éste es el momento en que se cobra la decisión de las transactions. Si aquel día la
transaction hubiera extendido `uvm_transaction`, hoy este `typedef` no compila:
`uvm_sequencer #(T)` exige que `T` derive de `uvm_sequence_item`.
Vale decirlo explícitamente: es la primera vez en el curso que una decisión de
una sección anterior habilita —o rompe— la siguiente. Eso es exactamente lo que
significa "código adaptable" y no es una frase de manual.
Y por si alguien lo intenta: extender `uvm_sequencer` para agregarle cosas es
casi siempre señal de que eso iba en la sequence. El sequencer es un árbitro, no
un lugar donde poner lógica.

---

## Agents

#### *La sequence mínima*

- Una `uvm_sequence #(T)` tiene una task `body()`: eso es todo lo que hay que
  escribir
- Cada item va entre `start_item()` y `finish_item()`
- `start_item()` bloquea hasta que el sequencer nos da el turno; `finish_item()`
  bloquea hasta que el driver llamó a `item_done()`
- El `randomize()` va **entre los dos**: así las constraints se resuelven en el
  momento en que el item se va a entregar, no antes
- Ésta es la traducción directa del `tester` de las transactions, y nada más que
  eso — la sección de sequences es sobre lo que se puede hacer acá adentro

{{code:code/u7/agents/tb_classes/command_sequence.svh|lines=6-43}}

Note:
Dos cosas que conviene marcar en el código, porque son las que se copian mal.
Primera: la transaction sale de `type_id::create()`, también la del reset y la
de la multiplicación dirigida. Es la misma regla de las transactions —la factory
sólo se entera de lo que pasa por `create()`— y acá vuelve a importar porque el
`add_test` sigue existiendo.
Segunda: `randomize()` entre `start_item` y `finish_item` no es un capricho de
estilo. Randomizar antes funciona igual hoy, pero rompe el día que una constraint
depende del estado del DUT o de la respuesta anterior: para ese momento el valor
ya estaba elegido. Randomizar tarde es la costumbre correcta y no cuesta nada
adoptarla desde el primer día.

---

## Agents

#### *`is_active`: activo y pasivo*

- `uvm_agent` trae un campo `is_active` de tipo `uvm_active_passive_enum`, con
  dos valores: `UVM_ACTIVE` y `UVM_PASSIVE`
- **Activo**: se construyen el sequencer y el driver. El agent maneja la
  interface
- **Pasivo**: no se construyen. El agent **sólo mira** una interface que maneja
  otro
- Los monitores y los dos analysis ports se construyen **siempre**: un agent
  pasivo sigue alimentando scoreboard y cobertura
- Se lee con `get_is_active()` y se decide en el `build_phase`, con un `if`

![Activo contra pasivo](res/diagrams/agents_active_passive.svg)
<!-- .element: class="grande" -->

Note:
La pregunta honesta es "¿y para qué quiero un agent que no maneja nada?". Tres
respuestas de campo, en orden de frecuencia:
Uno, interfaces de salida. Un puerto que el DUT maneja y vos sólo verificás no
necesita driver, y el agent pasivo te da el monitor y la cobertura gratis.
Dos, integración. Cuando el bloque que verificaste pasa a formar parte de un
chip, la interface deja de ser tuya: la maneja el bloque de al lado. El mismo
agent, con una línea distinta en el config, sigue sirviendo. Ese es el retorno
real de haber armado un agent.
Tres, lo del ejemplo: convivir con estímulo que no es tuyo — un módulo heredado,
un modelo de referencia, un generador de otro equipo.

---

## Agents

#### *Y se puede ver*

- `bash run.sh +TOPOLOGY` imprime el árbol de componentes que UVM armó

```
      clase_agent_h          vtalu_agent
        command_ap           uvm_analysis_port
        command_monitor_h    command_monitor
        driver_h             driver
          seq_item_port      uvm_seq_item_pull_port
        result_ap            uvm_analysis_port
        result_monitor_h     result_monitor
        sequencer_h          uvm_sequencer
          seq_item_export    uvm_seq_item_pull_imp
      modulo_agent_h         vtalu_agent
        command_ap           uvm_analysis_port
        command_monitor_h    command_monitor
        result_ap            uvm_analysis_port
        result_monitor_h     result_monitor
```

- Misma clase, dos instancias, y una tiene cuatro componentes menos
- Ahí están también el `seq_item_port` y el `seq_item_export` que el driver y el
  sequencer traen puestos, sin que nadie los declare — contra los put y get ports,
  donde el `uvm_put_port` había que declararlo y hacerle `new()`
- `print_topology()` es además la herramienta de debug cuando un `connect()`
  apunta a un componente que no existe

Note:
Este árbol lo imprime la librería, no el curso, y ése es todo el punto: hasta acá
la jerarquía era un diagrama en una slide, y ahora es una salida que se puede
grepear. Vale correrlo en vivo — es el `print_topology()` de la sección de
reporting, ahora con algo que valga la pena mirar.
Las dos cosas que hay que hacer ver, una al lado de la otra: `clase_agent_h`
tiene `driver_h` y `sequencer_h`, y `modulo_agent_h` **no**. Ése es el
`is_active` en la práctica — el mismo tipo de clase, instanciado dos veces, y uno
construyó dos objetos menos. Los dos monitores están en los dos, porque mirar
nunca es opcional.
Y la que no está: no hay ninguna `sequence` en este árbol. Una sequence es un
`uvm_object`, no un `uvm_component`, así que no vive en la topología. Es la
pregunta que se tiró el día 3 con el diagrama de clases, y acá se puede contestar
señalando la pantalla.

---

## Agents

#### *El config object del agent*

- El agent necesita dos datos de afuera: **cuál BFM** y **si es activo**
- Los dos viajan juntos en un objeto de configuración, que es la interface
  pública del agent
- Es una **clase pelada**, no un `uvm_object`: por eso el constructor puede
  **exigir** los dos datos, y quien se olvide de uno no compila
- Un `uvm_object` se crea con `type_id::create()`, que sólo toma un `name`: la
  garantía del constructor se pierde
- El campo `is_active` va `protected` con un getter: nadie lo cambia después de
  que el agent se construyó

{{code:code/u7/agents/tb_classes/vtalu_agent_config.svh}}

Note:
Acá el curso se aparta de la costumbre de la industria a propósito, y conviene
decirlo: la mayoría de los proyectos hace `class agent_config extends uvm_object`
y lo registra en la factory, para poder overridearlo. Es una decisión legítima y
tiene su razón. La contra es la que está en el bullet: se pierde el constructor
que obliga.
Lo que no es negociable es la idea de fondo, y es la que hay que dejar: **cada
nivel de jerarquía recibe su configuración por un objeto**. Si un componente
necesita cinco datos, no son cinco `uvm_config_db::get()` desparramados: es un
config. El día que agregás el sexto dato, tocás una clase y no seis.
Fijate que el driver y los dos monitores también piden el config, no la BFM: el
agent no reparte handles a mano.

---

## Agents

#### *La clase agent: `build_phase`*

- Pide su config al `uvm_config_db` y copia el `is_active` **a mano**: sin
  `super.build_phase()`, el de `uvm_agent` que lo leería no corre
- Construye sequencer y driver **sólo si es activo**; los monitores y los dos
  analysis ports, siempre
- Los analysis ports son ports: se instancian con `new()`, no con la factory

{{code:code/u7/agents/tb_classes/vtalu_agent.svh|lines=1-33}}

Note:
Un detalle que vale oro y que nadie cuenta: el `build_phase` de `uvm_agent` que
trae la librería **lee solo el `is_active` del resource pool**. Está en
`code/.uvm/src/comps/uvm_agent.svh`, se puede abrir en clase.
O sea que en un testbench que llama a `super.build_phase()`, un
`uvm_config_db#(int)::set(this, "mi_agent", "is_active", UVM_PASSIVE)` funciona
solo, sin config object. Como este `vtalu_agent` no lo llama, ese mecanismo
**está apagado**, y por eso lo asignamos a mano.
Y acá se cobra lo del día 3: `uvm_agent` es la única clase de la librería,
además de `uvm_component`, que implementa `build_phase`. Es exactamente el caso
que la regla de afuera cubre — heredaste de una clase intermedia que hace
trabajo real, y saltearte el `super` lo apaga sin decir nada. Nosotros podemos
saltearlo porque escribimos la línea que reemplaza; el que no la escribe, no.
Las dos formas son válidas. Lo que no es válido es la mitad de cada una: poner
`is_active` en el config_db, no llamar a `super.build_phase()`, y después
preguntarse por qué el agent arranca activo. Pasa seguido.

---

## Agents

#### *La clase agent: `connect_phase`*

- Adentro: el `seq_item_port` del driver contra el `seq_item_export` del
  sequencer — **una sola línea**, y sólo si es activo
- Hacia afuera: el `ap` de cada monitor se conecta al analysis port **del
  agent**
- Ese segundo `connect()` es el que hace que el agent sea una caja cerrada: el
  `env` nunca toca `command_monitor_h`, habla con `command_ap`
- Sigue valiendo el mantra *ports connect to exports*, con una vuelta más: un
  port también se conecta **a otro port del mismo tipo, hacia afuera**. Eso es
  `command_monitor_h.ap.connect(command_ap)`, y se llama *port forwarding*

Note:
El *port forwarding* es lo que confunde, y conviene decir por qué existe antes de
cómo se escribe. El agent quiere ofrecer hacia afuera un dato que produce un hijo
suyo. Podría exponer el hijo —el `env` mirando `agent.command_monitor_h.ap`— y
ahí se termina la encapsulación: el día que el monitor cambie de nombre, se rompe
el `env`.
La salida es que el agent tenga **su propio** analysis port y lo enchufe al del
monitor. Desde afuera se ve un solo port, `command_ap`, y adentro puede haber lo
que sea. Es exactamente lo que hace un módulo cuando conecta un puerto suyo al de
un submódulo — la misma idea, con clases.
El detalle que parece romper el mantra: acá un **port se conecta a otro port**, no
a un export. No es una excepción caprichosa — la dirección sigue siendo la misma,
del que llama al que implementa; lo único que pasa es que el agent está en el
medio y no implementa nada, sólo reenvía.

---

## Agents

#### *Cómo queda el `env`*

- Cuatro líneas de estructura en vez de siete objetos y cinco conexiones
- El `env` ya no sabe que existe un driver, ni un sequencer, ni una FIFO: sabe
  que hay un agent y que tiene dos analysis ports
- El scoreboard y la cobertura quedan igual que en los analysis ports: son
  subscribers, y no se enteran de nada

{{code:code/u7/agents/env_un_agent.svh|lines=3-34}}

- Ese es el `env` de una sola VTALU. Con dos, cambia menos de lo que parece

Note:
Ésta es la slide para hacer la comparación en vivo: abrir el `env.svh` de transactions
al lado. La diferencia no es que sea más corto —que también—, es **qué
desapareció**: el `env` de transactions nombraba `command_f`, o sea que conocía el
mecanismo interno de cómo el estímulo llegaba al driver. El de acá no lo
nombra. Eso es encapsulamiento medido de forma objetiva: contá los nombres que
la clase de arriba tiene que conocer.
Si el grupo viene bien de tiempo, vale la pena la pregunta: ¿qué habría que
cambiar en este `env` para pasar de una FIFO a un sequencer? Nada. Ya está
adentro del agent.

---

## Agents

#### *Dos agents, un solo string*

- Los dos agents ejecutan **la misma línea**:
  `uvm_config_db#(vtalu_agent_config)::get(this, "", "config", cfg)`
- Y sin embargo tienen que recibir **objetos distintos**
- Lo resuelve el segundo argumento del `set()`: el **ámbito**, que es la ruta
  del componente que va a leer
- `"clase_agent_h*"` alcanza a ese agent y a todo lo que cuelga de él — por eso
  el driver y los monitores encuentran el mismo config sin que nadie se lo pase
- El `this` del `set()` es el punto de partida de esa ruta: el `env`

![El ámbito jerárquico del config_db](res/diagrams/agents_config_scope.svg)
<!-- .element: class="grande" -->

Note:
Acá está la trampa clásica de la sección, y es de las que no fallan. Con un solo
agent, todo el mundo escribe `"*"` en el ámbito y funciona. El día que aparece el
segundo, el segundo `set()` pisa al primero y **los dos agents arrancan
activos**: dos drivers manejando dos interfaces distintas con la configuración
equivocada. El error no aparece en `build_phase`, aparece como un scoreboard
que falla en la interface que no tocaste.
El asterisco importa: `"clase_agent_h*"` con asterisco alcanza a los hijos;
`"clase_agent_h"` sin asterisco, sólo al agent. Si lo escribís sin asterisco, el
agent encuentra su config y el driver no — `uvm_fatal` en `build_phase`, que al
menos es un error honesto.
Regla corta para llevarse: **el ámbito del `set()` es una ruta, no una etiqueta.**

---

## Agents

#### *Cuando el `config_db` no encuentra: `+UVM_CONFIG_DB_TRACE`*

```sh
$ bash run.sh +UVM_CONFIG_DB_TRACE
UVM_INFO ... Configuration 'config' (type vtalu_agent_config) set by env_h
UVM_INFO ... Configuration 'config' read by
             accessor=uvm_test_top.env_h.clase_agent_h.driver_h
UVM_INFO ... Configuration 'config' read by
             accessor=uvm_test_top.env_h.modulo_agent_h.command_monitor_h
```

- El `config_db` es una base de datos por strings: cuando falla, **falla en
  silencio** o con un `uvm_fatal` que no dice por qué
- `+UVM_CONFIG_DB_TRACE` hace que UVM imprima **cada `set()` y cada `get()`**,
  con la ruta jerárquica completa del componente que lo pidió
- Sirve para las dos preguntas que uno se hace: *¿el `set()` llegó a este
  componente?* y *¿qué componentes existen de verdad?*
- Es un plusarg, no código: no hay que tocar ni recompilar nada

Note:
Ésta es la herramienta que le faltaba a los tests, cuando dijimos que
`get(null, "*", ...)` "no falla: miente". Con el trace prendido, mentir se hace
difícil: se ve quién puso qué y quién lo leyó.
El uso que casi nadie descubre solo es el segundo: **como cada `get()` imprime la
ruta del componente que lo llamó, la salida es un censo del árbol escrito por la
librería.** Si un componente no aparece, no se construyó. El ejercicio del día
usa exactamente eso para corregirse, y por eso no puede hacerse trampa: el
alumno no escribe esas líneas.
Pariente cercano que vale nombrar: `+UVM_OBJECTION_TRACE`, para el otro cuelgue
clásico —la simulación que no termina porque alguien no bajó su objection—.

---

## Agents

#### *El ejemplo: dos VTALU y el módulo heredado*

- El caso que justifica todo esto: hay que comparar **dos fuentes de estímulo**
  sobre el mismo diseño
- El `top` instancia dos VTALU y dos `vtalu_bfm`
- La primera la maneja nuestro agent, en `UVM_ACTIVE`
- La segunda la maneja `vtalu_tester_module`, un módulo de siempre sin una línea
  de UVM, y le colgamos un agent en `UVM_PASSIVE` para mirarlo
- Dos scoreboards y **dos coberturas**: eso es lo que responde cuál de los dos
  estímulos cubre más

{{code:code/u7/agents/top.sv|lines=1-35}}

- El módulo llama **a la misma `bfm.send_op()`** que el driver: recibe la
  interface por su **puerto** en vez de por una virtual interface, pero el
  protocolo que ejecuta es exactamente el mismo código
- Eso es lo que hace justa la comparación: los dos estímulos hablan idéntico con
  el DUT. Lo único que se compara es **qué** manda cada uno, no cómo

Note:
Este `top.sv` es el que cierra el argumento de la sección, y conviene leerlo
buscando lo que **no** cambió: hay dos VTALU, dos interfaces, dos `config_db`
distintos, y el `vtalu_tester_module` sigue siendo el mismo módulo de Verilog de
siempre. Nadie lo tocó para que conviva con UVM.
Ése es el escenario real que la sección viene a resolver, y vale nombrarlo así:
llegás a un proyecto donde ya hay un estímulo escrito en Verilog que funciona y
nadie va a reescribir. Con un agent pasivo lo podés **mirar** —scoreboard,
cobertura, assertions— sin pedirle permiso a nadie ni tocar una línea suya.
El detalle técnico que hace justa la comparación, y que hay que señalar con el
dedo: el módulo llama a la misma `bfm.send_op()` que el driver. Recibe la
interface por puerto en vez de por virtual interface, pero el protocolo es el
mismo código. Si cada uno manejara el bus a su manera, comparar coberturas no
querría decir nada.

---

## Agents

#### *El test, y lo que todavía falta*

- El `test` saca las dos BFM del `config_db`, arma el `env_config` y lo baja
- Después arranca la sequence **a mano**, sobre el sequencer del agent activo:

```systemverilog
seq = command_sequence::type_id::create("seq");
seq.start(env_h.clase_agent_h.sequencer_h);
```

- Funciona, pero mirá lo que hace esa línea: el test **atraviesa la jerarquía**
  para llegar al sequencer, y con eso vuelve a conocer el interior del env
- Todo lo que acabamos de encapsular se filtra en una línea
- La sección de sequences lo arregla: la sequence se le pasa al sequencer **por
  `config_db`**, y el test deja de saber dónde está

{{code:code/u7/agents/tb_classes/dual_test.svh|lines=10-44}}

Note:
Ésta es la slide con la que conviene cerrar el día si el tiempo no da para el
resumen: deja una pregunta abierta y una promesa concreta.
Y es honesta: `seq.start(env_h.clase_agent_h.sequencer_h)` es código real que
funciona y que se ve en muchos testbenches. No está "mal". Simplemente es la
última cosa del testbench que sigue estando cableada, y es la que la sección
que viene se lleva puesta.
Si alguien pregunta por qué no lo hacemos bien de una: porque para entender el
`default_sequence` primero hay que haber sufrido escribir el `start()` a mano.

---

## Agents

#### *Lo que esta sección hace distinto*

- **El libro no usa sequencer acá.** En *The UVM Primer* el agent de esta
  sección todavía tiene el `tester` y la `uvm_tlm_fifo` adentro, y el sequencer
  recién aparece con las sequences — donde además el `tester` desaparece
- Nosotros armamos el agent **completo de una**: es la forma en que se escribe
  hoy, y hace que la sección de sequences sea sólo sobre sequences
- **El scoreboard y la cobertura quedan afuera del agent**, contra lo que hace
  el *UVM Primer*. Un agent pasivo no debería arrastrar un scoreboard
- **El config del agent no es un `uvm_object`**: es una clase pelada, para que
  el constructor obligue. La industria suele hacerlo `uvm_object`
- El protocolo vive en la BFM, igual que en el *UVM Primer*. Hasta Verilator 5.051 esto no
  se podía: una task de interface llamada por una virtual interface no
  propagaba. Se arregló en 5.052 — `docs/verilator.md`

Note:
Que el material diga en qué se aparta de sus fuentes no es un detalle de
prolijidad: es lo que le permite al alumno leer el *UVM Primer* después sin
creer que uno de los dos está roto.
Y de paso deja la lección que más se usa en el trabajo: la estructura de un
testbench UVM no la fija el estándar, la fija la costumbre. IEEE 1800.2 no dice
en ningún lado que el scoreboard vaya en el env. Dice qué es un `uvm_agent` y
nada más. Todo lo demás es convención — buena, pero convención.

---

## Agents

#### *Resumen de la unidad*

- Un **agent** empaqueta todo lo que sabe hablar una interface: sequencer,
  driver y monitores, cableados adentro una sola vez
- Se instancia **una vez por interface**, y se configura con un **objeto de
  configuración**, no con handles sueltos
- **`is_active`** decide si además de mirar, maneja
- El `env` pasó de siete componentes cableados a mano a **un agent y dos
  subscribers**
- El `uvm_config_db` deja de ser un buzón global: el **ámbito** es una ruta en
  el árbol, y con más de un agent es lo que hace que cada uno reciba lo suyo
- Quedó una sola cosa cableada: el test todavía busca el sequencer a mano para
  arrancar la sequence. **Eso es la sección de sequences**

Note:
Cierre de la sección y del salto más grande del curso. Vale decir dónde quedaron
parados: con lo de hoy, el alumno puede leer el testbench de cualquier proyecto
UVM y reconocer la estructura. Agent por interface, config por nivel, análisis
en el env. Es literalmente el 80 % de lo que va a ver el primer día.
Lo que falta —sequences— es lo que va a *escribir* el primer día. Por eso van
juntas en el mismo día y en este orden: primero la casa, después lo que pasa
adentro.
