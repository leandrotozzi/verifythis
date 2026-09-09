## Tests

#### *Compilar una vez, elegir el test por línea de comandos*

- El testbench en objetos tiene el estímulo **adentro**: cambiar de test es
  cambiar código y volver a compilar
- Mil tests a cinco minutos de compilación cada uno son **5000 minutos**: tres
  días y medio de máquina para no correr nada nuevo
- UVM da vuelta el orden: el testbench se compila **una vez**, y el test que
  corre se elige al arrancar la simulación

```bash
$ ./obj_dir/top/sim +UVM_TESTNAME=random_test
$ ./obj_dir/top/sim +UVM_TESTNAME=add_test     # el mismo binario
```

- Eso es lo que se cobra en esta unidad, y lo que se paga con la ceremonia que
  viene: registro en la factory, constructor con firma fija y fases

Note:
La cuenta es el argumento comercial de UVM, y conviene decirla con los números
en la mano: no es que el testbench modular esté mal, es que no escala.
Si se puede, en vivo: compilar una vez y correr las dos líneas de arriba. Que
vean que la segunda no compila nada.
Lo que se cobra del testbench en objetos: el testbench ya está partido en tester,
coverage y scoreboard, y por eso se puede cambiar sólo el tester. Lo que se
paga adelante: en los components esas tres clases dejan de ser objetos sueltos que
el test hace `new()` y pasan a ser components del árbol.

---

## Tests

#### *El top: instanciar, publicar la interface, arrancar*

{{code:code/u4/tests/top.sv|lines=21-28}}

- El `top` sigue siendo un **módulo**: instancia el BFM y el DUT igual que
  antes. Lo único nuevo son estas dos líneas
- `run_test()` sin argumento significa *"el que diga `+UVM_TESTNAME`"*. Con un
  argumento —`run_test("random_test")`— volvés a hardcodear el test
- Antes de `run_test()` no hay ningún objeto de UVM vivo: por eso el `set` va acá

Note:
La virtual interface se pasa por el config_db porque las clases no ven las
señales del módulo: `bfm` vive en `top`, y `random_test` es un objeto que se
crea en tiempo de simulación. No hay forma de pasárselo por el constructor —
el de `uvm_component` sólo acepta `name` y `parent`.
Vale la pena señalar el orden: primero el `set`, después `run_test()`. Al revés
el test se construye antes de que el dato esté en la base y el `get` falla con
el fatal. Es un error que se ve poco porque casi nadie escribe el top al revés,
pero explica por qué el `set` no puede ir en un `initial` aparte.
La slide que sigue es la que hay que explicar bien: es el error número uno del
que arranca con UVM.

---

## Tests

#### *uvm_config_db: el buzón del testbench*

- Base de datos global y **tipada**: el `#(...)` es parte de la llave
- Cuatro argumentos: *ámbito* (`cntxt`, `inst_name`), *nombre* y *dato*
- El **ámbito** es una ruta jerárquica, y ahí está toda la gracia

{{code:code/u4/tests/config_db.svh}}

Note:
Los dos primeros argumentos son *dónde*, el tercero es *qué*. En el `set` del
top va `null, "*"` porque `top` es un módulo, no está en el árbol de UVM: la
traducción es "desde la raíz, visible para todos".
En el `get` va `this, ""`, o sea "yo". Vale la pena escribir en el pizarrón la
ruta que sale: `uvm_test_top.env_h.driver_h`.
Y el atajo que hay que desaconsejar de entrada: `get(null, "*", ...)` también
compila y también anda — busca en todo el árbol y se queda con lo primero que
encuentra. Con una sola interface no se nota nunca. El día que el testbench
tiene dos, el driver del bus A puede terminar manejando el bus B, y no falla:
miente. Es de esos errores que se pagan tres meses después.

---

## Tests

#### *Un test en tres partes: 1 · registrarlo*

{{code:code/u4/tests/tb_classes/random_test.svh|lines=4-7}}

- `random_test` extiende `uvm_test`, que extiende `uvm_component`: es un nodo
  del árbol, no un objeto suelto
- La macro `` `uvm_component_utils `` lo **inscribe en la factory**. Sin esa
  línea, `+UVM_TESTNAME=random_test` no encuentra nada y UVM aborta
- El handle a la virtual interface se **declara** acá y se **llena** en el
  `build_phase`: son dos momentos distintos

Note:
Es la primera vez que aparece la factory en serio, y todavía no se ve para qué
sirve: acá sólo hace de directorio de nombres. La segunda mitad —crear por tipo
y poder sustituirlo desde afuera— llega en el env con los overrides.
El punto y coma después de la macro sobra y UVM lo tolera. Está en el código del
libro y lo dejamos igual para que el que compare no se maree, pero si alguien
pregunta: no hace falta.

---

## Tests

#### *2 · el constructor y el `build_phase`*

{{code:code/u4/tests/tb_classes/random_test.svh|lines=9-18}}

- El constructor de un `uvm_component` tiene **firma fija**: `name` y `parent`,
  en ese orden, y `super.new(name, parent)` como primera línea
- El `get` del config_db va en `build_phase`, **no** en el constructor: cuando
  corre el constructor el árbol todavía se está armando
- `if (!get(...)) uvm_fatal`: el `get` devuelve un bit. Ignorarlo deja el handle
  en `null` y la falla aparece cien líneas después, en otro archivo

Note:
La firma fija es lo primero que rompe todo el mundo: un constructor con un
argumento de más y la factory no lo puede crear, porque llama siempre con
`(name, parent)`.
`build_phase` es una fase, no una función que llames vos: UVM la recorre
top-down sobre el árbol ya armado. En este test todavía no se nota, porque el
árbol es un solo nodo; en los components, cuando el env construye sus hijos, el
orden top-down es lo que hace que el padre exista antes que el hijo.
El fatal no es paranoia: sin él, un typo en el nombre del dato —"bfm" contra
"BFM"— da una simulación que corre, no manda un solo estímulo y termina con 0
errores.

---

## Tests

#### *3 · el `run_phase`: acá pasa la simulación*

{{code:code/u4/tests/tb_classes/random_test.svh|lines=20-39}}

- Es el mismo cuerpo que el `execute()` del testbench en objetos: tester, coverage y
  scoreboard, con los dos observadores en `fork ... join_none`
- Lo que cambia es **quién lo llama**: antes lo llamaba el módulo `top`, ahora
  lo llama UVM cuando le toca a la fase de run
- Las dos líneas nuevas son el `raise` y el `drop` de la objection, que son las
  que deciden cuándo termina todo

Note:
Conviene mostrarlo al lado del `tb.execute()` del testbench en objetos: el estímulo no
cambió ni una línea. Lo único que hicimos fue moverlo adentro de una clase que
UVM sabe crear y llamar. Ese es todo el trabajo de esta unidad.
`join_none` y no `join`: coverage y scoreboard son bucles infinitos que miran
las señales. Si esperáramos a que terminen, no termina nunca.
Y el que se pierde: la simulación no dura lo que dura el `run_phase`, dura lo
que duran las objections. Eso es lo que viene ahora.

---

## Tests

#### *Objections: quién decide cuándo termina*

```systemverilog
task run_phase(uvm_phase phase);
   phase.raise_objection(this);    // "todavia tengo trabajo"
   ...                             // el estimulo
   phase.drop_objection(this);     // "listo, por mi que termine"
endtask
```

- Todos los `run_phase` corren **en paralelo**: ninguno puede decidir solo
  cuándo terminar. UVM cuenta, y la fase termina cuando cae la **última**
  objection
- Sin `raise_objection` la simulación se termina en el **tiempo 0**, y el test
  pasa con 0 errores sin haber mandado un estímulo
- Sin `drop_objection` no termina nunca: no hay error, la simulación sigue
  corriendo sola
- Los dos síntomas son **mudos**, y por eso existen dos plusargs:
  `+UVM_OBJECTION_TRACE` dice quién la levantó y quién la bajó, y `+UVM_TIMEOUT`
  le pone un techo a la corrida

Note:
Es el mecanismo que decide cuánto dura la simulación, y es el que produce los
dos cuelgues clásicos de la primera semana. Vale escribir las dos fallas en el
pizarrón, porque el alumno las va a ver antes que a cualquier bug del DUT.
La regla práctica: la objection la levanta **el que tiene trabajo**, y la baja
**el mismo**. En este curso siempre es el test. Nunca la levantes en un
componente y la bajes en otro — eso es cómo se cuelga un testbench de verdad.
Y falta un tercer participante, que es la slide que sigue: la objection sabe
cuándo el test terminó de **mandar**, no cuándo el scoreboard terminó de
**comparar**. Ésa es la diferencia que paga el `drain_time`.
Y el enganche del día 6: `set_automatic_phase_objection(1)` es esto mismo, hecho
por el sequencer en vez de por el test.

---

## Tests

#### *El final que no es el final: `drain_time`*

- La objection dice *"terminé de **mandar**"*. No dice *"terminé de
  **comparar**"*: entre las dos hay un scoreboard con una FIFO adentro y
  resultados que el DUT todavía no contestó
- Cuando cae la última objection la fase corta **en ese instante**: lo que
  quedó en vuelo no llega, nadie lo compara, y el resumen dice `UVM_ERROR : 0`

```systemverilog
task run_phase(uvm_phase phase);
   phase.get_objection().set_drain_time(this, 200ns);  // un colchon tras el ultimo drop
   phase.raise_objection(this);
   ...                                                 // el estimulo
   phase.drop_objection(this);
endtask
```

- El `drain_time` es un número elegido a ojo. La versión con criterio es
  **`phase_ready_to_end()`**: UVM la llama cuando cayó la última objection, y el
  componente que todavía tiene trabajo levanta una más y la fase sigue
- Es **el** bug de la segunda semana, y es mudo: no hay error, no hay cuelgue, y
  las últimas transacciones nunca se compararon

Note:
Es la contracara de la slide anterior y conviene decirlo con esas palabras: la
objection mide **el estímulo**, no el análisis. El test sabe cuándo terminó de
mandar; el scoreboard es el que sabe cuándo terminó de comparar, y nadie le
preguntó.
El `drain_time` es la respuesta barata y alcanza para el 90 % de los casos: un
colchón fijo después del último `drop_objection`, en el orden de lo que tarda el
DUT en contestar. En este curso serían un par de ciclos; en un bus con latencia,
lo que diga la spec.
`phase_ready_to_end()` es la respuesta cara y la que se usa en un testbench
serio, porque no es un número: el scoreboard mira su propia FIFO, y si le quedan
items levanta una objection más. La forma es siempre la misma —chequear
`phase.get_name() == "run"`, y levantar sólo si de verdad falta algo—, y hay que
decir la trampa: si el que la implementa nunca la baja, colgó la fase.
La tercera pieza, para el que quiera engancharse justo en ese instante, es
`all_dropped`: un callback del objeto objection que se dispara cuando la cuenta
llega a cero.
Y el enganche hacia adelante: el scoreboard con FIFO de los analysis ports es
exactamente el caso de esta slide, y el capstone lo pisa de nuevo.

---

## Tests

#### *El segundo test: lo mismo, con otro tester*

{{code:code/u4/tests/tb_classes/add_test.svh|lines=17-35}}

- `add_test` es `random_test` con **una línea distinta**: `add_tester` en lugar
  de `random_tester`. Todo lo demás se repite tal cual
- Esa repetición es real y es fea, y es la deuda que paga los components: cuando
  el testbench sea un árbol de components, el test va a construir un `env` y no
  va a tocar el estímulo
- Por ahora vale la pena que se vea copiada: es el problema que motiva lo que
  sigue

Note:
No hay que disculpar la duplicación, hay que señalarla. El alumno tiene que
terminar esta slide con la sensación de "esto no puede ser así", porque esa
sensación es exactamente el motivo de los components y del env.
Si alguien se adelanta y propone una clase base con el `run_phase` común y un
método virtual para elegir el tester: está bien, y es más o menos lo que hace
`base_test` en las sequences. Decírselo y seguir.

---

## Tests

#### *Cómo se corre, y qué imprime*

{{code:code/u4/tests/run.sh|lines=9-14}}

{{code:code/u4/tests/output.txt|lines=1-13}}

- Un solo `vlt_uvm`, dos `run_sim`: **una compilación, dos tests**. Eso es todo
  lo que promete la unidad, y acá está hecho
- `[RNTST] Running test random_test...` es UVM diciendo qué encontró en la
  factory con el nombre que le pasaste
- El *Report Summary* con `UVM_ERROR : 0` es el veredicto: reporting lo
  desarma y explica de dónde sale cada fila

Note:
Vale correrlo en vivo y cronometrar: la compilación tarda minutos, los dos
`run_sim` tardan segundos. Ése es el número que justifica toda la ceremonia de
la unidad.
El `$finish at 46ns` del final es del primer test; el `add_test` termina en 41 ns.
Los dos mandan la misma cantidad de operaciones, pero la multiplicación toma más
ciclos que la suma, así que el tiempo depende de qué salió al azar.
Y una advertencia útil: `UVM_ERROR : 0` quiere decir "nadie llamó a
`uvm_error`", no "el DUT está bien". Acá el scoreboard sí reporta con
`` `uvm_error ``, así que la cuenta vale — pero un scoreboard que nunca recibe
nada da exactamente el mismo cero. Reporting muestra cómo distinguirlos.

---

## Tests

#### *Resumen de la unidad*

- El testbench se compila **una vez** y el test se elige por línea de comandos:
  `+UVM_TESTNAME=random_test`. Ése es todo el negocio de la sección
- La cuenta que lo justifica: mil tests a cinco minutos de compilación cada uno
  son **tres días y medio** de esperar a que compile
- El `top` sigue siendo un módulo. Publica la BFM en el `uvm_config_db` **antes**
  de `run_test()`, porque antes de esa línea no hay un solo objeto de UVM vivo
- El **`uvm_config_db`** es una base de datos global y **tipada**: el `#(...)`
  es parte de la llave, y el ámbito es una **ruta jerárquica**
- Un test se registra con `` `uvm_component_utils ``. Sin esa línea, la factory
  no lo encuentra y UVM aborta
- La virtual interface se **declara** en la clase y se **llena** en el
  `build_phase`: son dos momentos distintos, y confundirlos deja un `null`
- La objection dice cuándo el test terminó de **mandar**, no cuándo el scoreboard
  terminó de **comparar**. Esa diferencia se paga con `drain_time`, o bien con
  `phase_ready_to_end()`

Note:
Cierre de la primera unidad de UVM de verdad. Vale reconocer la incomodidad en
voz alta: hoy pusieron mucha ceremonia para hacer lo mismo que ya hacían. Lo que
compraron es el primer bullet, y no se cobra hasta que hay dos tests — que es el env.
El error que se van a comer y conviene anticipar: el `get()` que se olvida de
chequear el valor de retorno. No falla, **miente**: deja la virtual interface en
`null` y el testbench se cae tres capas más abajo. Por eso todos los `get` del
curso van adentro de un `if` con su `uvm_fatal`.
