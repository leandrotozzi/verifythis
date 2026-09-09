## Un solo lugar que mira el cable

#### *Un solo lugar que mira el cable*

- Hoy el scoreboard y la cobertura miran **las señales** cada uno por su cuenta:
  los dos esperan `done`, los dos leen `op_set`, los dos saben el protocolo
- Eso es el mismo código escrito dos veces, y el día que el protocolo cambie hay
  que acordarse de los dos lugares
- La pieza que falta tiene nombre en la industria: el **monitor**. Uno solo mira
  el bus, arma la transacción y la publica
- El scoreboard y la cobertura pasan a ser **subscribers** de los dados de la
  unidad anterior: no vuelven a tocar un cable
- En la jerga UVM esos dos forman el *analysis layer*, y de ahí sale el nombre
  `uvm_analysis_port`

Note:
Es el mismo patrón de los dados, ahora sobre el DUT — y ésa es toda la sección.
Lo que hay que remarcar es cuál es la línea divisoria del testbench, porque es la
que ordena todo lo que viene: **de un lado del monitor se habla en señales, del
otro en transacciones.** El BFM de interfaces y BFM hizo eso para el estímulo; el
monitor lo hace para el análisis.
La consecuencia práctica vale decirla en voz alta: a partir de acá, cualquier
componente de análisis se puede escribir sin saber nada del protocolo. Un
subscriber nuevo no necesita saber que existe un `done`.
Y la que se ve recién en los agents: si todo lo que sabe hablar el protocolo está
junto —BFM, monitores, driver—, esa caja se puede instanciar dos veces. Eso es
el agent, y esta sección es el que junta las piezas.

---

## Un solo lugar que mira el cable

#### *Qué piezas aparecen*

- **`command_monitor`** — mira el arranque de cada operación y publica qué se pidió
- **`result_monitor`** — mira el `done` y publica qué contestó el DUT
- El **BFM** deja de ser sólo señales: gana tres `always` y un handle a cada monitor
- El **scoreboard** y la **cobertura** dejan de esperar flancos y pasan a tener un
  `write()`
- El **`tester`** no se entera de nada: sigue mandando estímulo igual que ayer

Note:
La slide es el inventario de la sección y conviene usarla como mapa: son cinco
piezas y sólo dos son nuevas. Vale decir en voz alta cuáles, porque el alumno
tiende a creer que un tema nuevo reescribe el testbench entero.
Que haya **dos** monitores y no uno es la decisión que más se pregunta, así que
mejor adelantarla: miran cosas distintas y en momentos distintos. El
`command_monitor` mira cuando arranca una operación; el `result_monitor`, cuando
el DUT contesta. Entre esos dos instantes hay ciclos de por medio, así que no
pueden ser el mismo `always`.
Y el último bullet es el que hay que subrayar, porque es la promesa que la
sección cumple: el `tester` **no se toca**. Todo el trabajo de esta sección pasa
del lado del análisis, y el lado del estímulo ni se entera. Es la primera vez que
el curso separa las dos mitades del testbench, y en la sección siguiente se hace
la otra.

---

## Un solo lugar que mira el cable

#### *Diagrama del Testbench*

![TB del VTALU con analysis ports](res/diagrams/analysis-ports_fig102.svg)
<!-- .element: class="grande" -->

---

## Un solo lugar que mira el cable

#### *Los handles que la BFM guarda*

- Hasta ahora la clase leía la interface. Acá se da vuelta: **la interface guarda
  un handle a la clase** y es ella la que llama al método

{{code:code/u5/analysis-ports/vtalu_bfm.sv|from=interface vtalu_bfm;|to=op_set;}}

- Estos handles los setea cada monitor en su `build_phase`, justo después de
  sacar la BFM del config_db

{{code:code/u5/analysis-ports/tb_classes/command_monitor.svh|lines=6-16}}

Note:
Esta slide tiene la inversión que más cuesta de la sección y conviene decirla
despacio: hasta ahora **la clase leía la interface**. Acá es al revés — la
interface tiene un handle a la clase (`bfm.command_monitor_h = this`) y es ella
la que llama al método.
El motivo es que un `always` de la interface **sí** puede tener lista de
sensibilidad, y una función de clase no. Necesitamos que el hardware avise; para
eso el hardware tiene que saber a quién avisarle.
La línea que hace todo es `bfm.command_monitor_h = this`, y va en el
`build_phase`. Si te la olvidás, el monitor compila, corre, y no publica nunca:
el scoreboard se queda sin comandos y el `uvm_fatal` aparece del otro lado, en
una clase que no tiene la culpa. Es de esos errores que se buscan en el lugar
equivocado.
Detalle que ayuda: el handle es de la clase, no `virtual`. Por eso el `always`
puede llamar directo a `write_to_monitor()` sin el agujero de Verilator que
afecta a las tasks — acá el que declara la task es la clase, no la interface.

---

## Un solo lugar que mira el cable

#### *Monitoreando los comandos del VTALU*

- Tres `always` en el BFM: el del comando dispara cuando arranca una operación,
  el del reset en el flanco de bajada de `reset_n`, y el del resultado cuando el
  DUT levanta `done`

{{code:code/u5/analysis-ports/vtalu_bfm.sv|from=// Here is the first monitor|to=end : rslt_monitor}}

- Y del otro lado, el método al que le avisan: empaqueta la `command_s` y la
  publica en el analysis port

{{code:code/u5/analysis-ports/tb_classes/command_monitor.svh|lines=18-26}}

Note:
Los tres `always` son la costura entre el hardware y las clases, y conviene leer
la condición de cada uno: el de comandos dispara cuando `start` sube y no había
un comando en vuelo; el de reset, en el flanco de bajada de `reset_n`; el de
resultado, cuando el DUT levanta `done`.
La guarda `if (command_monitor_h != null)` no es paranoia: en el tiempo 0 el
árbol de UVM todavía no existe y el `negedge reset_n` ya llegó. Sin la guarda es
un null pointer del simulador.
El `write_to_monitor()` es corto a propósito: arma la `command_s`, la loguea con
`UVM_HIGH` —o sea que sólo se ve con `+UVM_VERBOSITY=UVM_HIGH`— y llama a
`ap.write()`. Todo lo demás pasa del otro lado del port, y el monitor no sabe
quién está ahí.
Y el detalle que se cobra en las transactions: lo que viaja todavía es una `struct`.
El día que sea una transaction, esta misma línea va a ser un `create()`.

---

## Un solo lugar que mira el cable

#### *VTALU Coverage Class como Subscriber*

- Con el `command_monitor` hay **un solo lugar** en todo el testbench que sabe
  cómo se ve un comando en el cable
- El que necesite saber qué operación se ejecutó se suscribe a su analysis port e
  implementa `write()`. No vuelve a mirar una señal

{{code:code/u5/analysis-ports/tb_classes/coverage.svh|from=// With the analysis port this is far simpler|to=endfunction : write}}

Note:
Vale abrir al lado la clase `coverage` del testbench en objetos y comparar: allá había un
`forever` esperando flancos; acá hay un `write()` y nada más. La cobertura dejó
de tener noción del tiempo.
Y eso no es cosmético, es la respuesta a la pregunta que quedó abierta en el testbench convencional: **dónde se muestrea**. Antes se muestreaba por reloj, o sea que se
contaban ciclos; ahora se muestrea cuando el monitor ve un comando, o sea que se
cuentan **operaciones**. Es lo correcto, y el número de cobertura cambia de
significado.
La pregunta para el grupo: si el DUT quedara diez ciclos sin hacer nada, ¿cuántas
muestras tomaba la versión vieja y cuántas ésta? Diez y cero. La vieja estaba
llenando bins con la nada.

---

## Un solo lugar que mira el cable

#### *Suscribiéndose a múltiples analysis ports*

- El mecanismo básico de analysis port de UVM permite que un uvm_subscriber agarre un único analysis_port
- Sin embargo, en casos como un scoreboard, necesitamos que un mismo componente reciba datos de 2 analysis port
- El motivo del límite: `uvm_subscriber` te da **un solo** `write()`, y ése es el
  método que el puerto llama. Dos puertos no tienen dónde entrar
- UVM lo resuelve sin partir el componente, con la clase *uvm_tlm_analysis_fifo*
- Es paramétrica y tiene dos caras: un *analysis_export* de un lado —que se conecta
  como cualquier subscriber— y un `try_get()` del otro
- `try_get()` saca un elemento y devuelve 0 si la FIFO está vacía, sin bloquear
- O sea: convierte *"me avisan cuando llega"* en *"lo busco cuando lo necesito"*

Note:
El scoreboard necesita dos fuentes —el comando y el resultado— y un
uvm_subscriber puede escuchar una sola. La FIFO convierte "me avisan cuando
llega" en "lo busco cuando quiero", que es lo que necesita para comparar de a
pares.

---

## Un solo lugar que mira el cable

#### *Suscribiéndose a múltiples analysis ports*

- Clase Scoreboard:

{{code:code/u5/analysis-ports/tb_classes/scoreboard.svh|from=uvm_tlm_analysis_fifo #(command_s) cmd_f;|to=endfunction : write}}

Note:
El scoreboard es asimétrico y ahí está toda la gracia: el **resultado** le llega
por `write()` —lo empujan— y el **comando** lo va a buscar él con `try_get()` a la
FIFO. Uno es push, el otro es pull.
Por qué así y no dos `write()`: un `uvm_subscriber` tiene un solo `write()`, y
además el orden importa. El scoreboard no quiere que le avisen del comando cuando
llega; lo quiere en el momento en que aparece el resultado, para poder comparar
de a pares. La FIFO convierte "me avisan" en "lo busco cuando quiero".
El `do ... while` que saltea `no_op` y `rst_op` es la parte que se copia mal:
esas dos operaciones **no producen resultado**, así que si no se descartan, la
comparación se desfasa un lugar y a partir de ahí falla todo. El síntoma es un
scoreboard que grita en cada línea, y es exactamente el ejercicio del día 5.
Y el `uvm_fatal` del `try_get()` no es paranoia: si hay un resultado y no hay
comando, el que está roto es el testbench, no el DUT. Mejor morir ahí que
reportar mil errores falsos.

---

## Un solo lugar que mira el cable

#### *La otra forma: `` `uvm_analysis_imp_decl ``*

```systemverilog
`uvm_analysis_imp_decl(_cmd)        // fabrica la clase uvm_analysis_imp_cmd
`uvm_analysis_imp_decl(_result)

class scoreboard extends uvm_component;
   uvm_analysis_imp_cmd    #(command_s, scoreboard) cmd_imp;
   uvm_analysis_imp_result #(shortint,  scoreboard) result_imp;

   function void write_cmd(command_s t);    ... endfunction   // un write por puerto
   function void write_result(shortint t);  ... endfunction
endclass
```

- La macro **genera una clase** por cada sufijo, y cada una llama a un `write_`
  distinto: así un componente recibe de dos puertos sin FIFO
- Es lo que vas a ver en la mayoría del código de producción, así que **hay que
  saber leerla**
- El curso usa la FIFO igual, por una razón de fondo: `write_cmd()` se ejecuta
  **cuando llega el comando**, y el scoreboard lo necesita **cuando llega el
  resultado**. La FIFO le da ese control; la macro lo obliga a guardarse el dato
  a mano

Note:
Mismo trato que las macros `` `uvm_field_* `` de los components y que `` `uvm_do ``
de las sequences: se nombran, se explican, y se dice por qué el curso no las usa. La regla
del curso, otra vez: **leer todas, escribir las explícitas.**
Lo que la macro esconde y conviene decir: `uvm_analysis_imp` es una clase que ya
existe en UVM; lo único que hace el `` `uvm_analysis_imp_decl `` es fabricar
variantes con nombre distinto, porque SystemVerilog no deja tener dos `write()` en
la misma clase. O sea que la macro no agrega mecanismo, agrega nombres.
Dónde va: en el package, **fuera** de toda clase, y una sola vez por sufijo en
todo el testbench. Declararla dos veces con el mismo sufijo es un error de
compilación que aparece lejos del lugar donde uno lo escribió.
Y la comparación honesta: con la macro el scoreboard queda más corto y más
acoplado —tiene que llevarse el comando a mano hasta que llegue el resultado—; con
la FIFO queda una línea más largo y el orden lo decide él. Para un scoreboard que
empareja de a pares, la FIFO gana. Para un componente que sólo cuenta cosas de dos
puertos, la macro es mejor.

---

## Un solo lugar que mira el cable

#### *Suscribiendo los monitores*

- Conectamos los analysis port a los monitores usando el método connect_phase() en la clase env:

{{code:code/u5/analysis-ports/tb_classes/env.svh}}

Note:
Tres `connect()` y ahí está el testbench entero. Vale leerlos en voz alta como
frases: *el resultado va al scoreboard*, *el comando va a la FIFO del
scoreboard*, *el comando también va a la cobertura*.
El que sorprende es el segundo: `command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export)`.
El export no es del scoreboard, es **de la FIFO que el scoreboard tiene adentro**.
Un `uvm_analysis_port` puede tener varios destinos —el `ap` del command_monitor
alimenta dos— y no le cuesta nada: `write()` los recorre a todos.
Y el detalle que se olvida y no avisa: `cmd_f` se instancia con `new()`, no con
la factory. Las FIFOs y los ports no están registrados. Si te olvidás del `new()`
el `connect()` explota con un null, y ese al menos es un error honesto.

---

## Un solo lugar que mira el cable

#### *Cuando el DUT no contesta en orden*

- El scoreboard de esta sección hace `try_get()` de una FIFO: el primer comando
  que entró es el que corresponde al primer resultado que salió. Eso vale porque
  **la VTALU contesta en orden**, una operación por vez
- Un bus real no. En AXI cada transferencia lleva un **ID** y las respuestas
  pueden volver cruzadas: la FIFO empieza a comparar la respuesta de una con el
  pedido de otra, y grita en todas

```systemverilog
transaccion esperado [int];              // asociativo, indexado por lo que aparea

function void write_cmd(transaccion c);  esperado[c.id] = c;  endfunction

function void write_result(respuesta r);
   if (!esperado.exists(r.id)) `uvm_error("SB", "una respuesta que nadie pidio")
   else begin comparar(esperado[r.id], r); esperado.delete(r.id); end
endfunction
```

- El patrón es siempre el mismo: **una tabla indexada por lo que aparea**, un
  `delete` cuando se comparó, y al final de la corrida la tabla **tiene que
  quedar vacía**
- Ese chequeo del final es la mitad del valor: lo que quedó adentro son los
  pedidos que el DUT nunca contestó

Note:
La pregunta que abre la slide es la que hay que hacerle a cualquier scoreboard
ajeno antes de confiar en él: *"¿y si el DUT contesta desordenado?"*. El de esta
sección se cae, y está bien que se caiga — la VTALU no lo hace. Lo que no está
bien es no saberlo.
El síntoma cuando pasa es cruel y conviene anticiparlo, porque manda a buscar al
lugar equivocado: no falla **una** comparación, fallan **todas** las que vienen
después de la primera que se cruzó. El testbench dice mil errores y el DUT tiene
cero. Es la fila *"el scoreboard grita en todas"* del apéndice de debug, con otra
causa.
La tabla asociativa es la respuesta canónica y no tiene misterio; lo que se
olvida siempre es el `check_phase` que verifica que quedó vacía. Sin eso, un DUT
que deja de contestar pasa en verde: nunca hay una comparación mal, simplemente
hay comparaciones que no se hicieron. Es el mismo agujero que el `drain_time` de
los tests, visto desde el otro lado.
Y la variante que aparece cuando no hay ID: aparear por contenido. Se guarda una
cola de esperados y se busca el que matchea, en vez del primero. Es más caro y
tiene una trampa propia —dos transacciones idénticas—, y por eso el ID existe.

---

## Un solo lugar que mira el cable

#### *De un lado del monitor se habla en señales, del otro en transactions*

- El **monitor** es la única clase que sabe que existe un `clk`. Coverage y
  scoreboard reciben datos y no tienen idea de dónde salieron
- El Observer de hablar con varios objetos, aplicado al DUT: el monitor publica y no lleva la
  lista. Agregar un observador es una línea en el `connect_phase`
- Y el límite, que es la sección que sigue: todo esto pasa en **un solo
  thread**. El `always` del BFM llama a `write_to_monitor()`, que llama a
  `ap.write()`, que llama a los `write()` de los subscribers — una cadena de
  funciones, sin que avance el tiempo

Note:
La frase del título es el resumen real de la sección y conviene dejarla escrita:
**de un lado del monitor se habla en señales, del otro en transactions.** Esa
frontera es lo que hace que el scoreboard de las transactions pueda existir sin
mirar un cable.
El tercer bullet es la bisagra hacia la comunicación entre threads: como es todo una cadena de
`function`, ningún eslabón puede esperar. Si el que consume necesita hacer
esperar al que produce —o al revés—, hace falta otra cosa, y eso es la
`uvm_tlm_fifo`.
Vale hacer la pregunta antes de pasar: ¿qué pasaría si el `write()` de un
subscriber tuviera un `@(posedge clk)` adentro? No compila. Una `function` no
puede consumir tiempo, y ésa es la limitación entera.

---

## Un solo lugar que mira el cable

#### *Resumen de la unidad*

- Hasta ayer el scoreboard y la cobertura miraban **las señales** cada uno por
  su cuenta: el mismo código de protocolo escrito dos veces
- La pieza que faltaba tiene nombre en la industria: el **monitor**. Uno solo
  mira el cable y **publica** lo que vio
- Son dos: **`command_monitor`** publica qué se pidió, **`result_monitor`**
  publica qué contestó el DUT
- El scoreboard y la cobertura pasan a ser **subscribers**: dejan de esperar
  flancos y sólo implementan `write()`
- Ese par —monitores que publican, subscribers que analizan— es el **analysis
  layer**, y de ahí viene el nombre del puerto
- El `tester` **no se entera de nada**. Ésa es la prueba de que el reparto quedó
  bien: cambiar el análisis no toca el estímulo
- Y el scoreboard con FIFO vale **mientras el DUT conteste en orden**. Cuando no,
  el patrón es una tabla por ID que tiene que quedar vacía al final

Note:
Cierre de la unidad donde el testbench toma la forma que va a tener hasta el
final. Vale decirlo así: de acá en adelante, cada vez que haya que analizar algo
nuevo —una cobertura más, un checker más— la respuesta va a ser siempre la misma,
**colgar un subscriber**, y nunca tocar el monitor.
Es literalmente el ejercicio del día, y es también lo que va a quedar afuera del
agent en los agents.
