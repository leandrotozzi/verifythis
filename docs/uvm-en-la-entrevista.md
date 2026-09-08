# UVM en la entrevista

Las preguntas que se hacen en una entrevista de verificación, con la respuesta
corta y **el link a la sección del curso y al ejemplo que corre**. No es un
resumen del curso: es el orden en que se pregunta, que no es el orden en que se
enseña.

**Cómo se usa.** Leé la respuesta corta. Si te suena a algo que ya sabías, seguí.
Si no, abrí el link del libro —son cinco minutos— y después corré el ejemplo, que
es la parte que hace que la respuesta te salga con las manos y no de memoria.
Todos los ejemplos corren con **Verilator y nada más**: no hace falta una
licencia para practicar para una entrevista.

> La pregunta que de verdad están haciendo casi nunca es la que dicen. Cuando
> alguien pregunta *"¿qué es la factory?"* está averiguando si escribiste un
> testbench o si leíste un tutorial. Por eso cada respuesta de acá termina en un
> ejemplo: contestar *"sirve para sustituir una clase sin tocar el env"* y poder
> decir **dónde lo hiciste** son dos entrevistas distintas.

---

## Arranque: por qué existe todo esto

### 1 · ¿Por qué UVM y no un testbench de SystemVerilog a mano?

Porque el testbench a mano tiene el estímulo **adentro**: cambiar de test es
cambiar código y recompilar. UVM da vuelta el orden — se compila **una vez** y el
test se elige al arrancar la simulación con `+UVM_TESTNAME`. Mil tests a cinco
minutos de compilación son tres días y medio de máquina para no correr nada
nuevo. Ése es todo el negocio; la ceremonia —factory, fases, constructor con
firma fija— es lo que se paga a cambio.

**Dónde**: [día 3 · Tests](../libro/dia3.html#compilar-una-vez-elegir-el-test-por-línea-de-comandos) ·
**Corre**: `make u4/tests` — una compilación, dos tests

### 2 · ¿Qué es la factory y para qué sirve un override?

Un directorio de nombres a tipos. Registrás la clase con
`` `uvm_component_utils ``, la creás con `type_id::create()` en vez de `new()`, y
a partir de ahí **alguien de afuera puede pedir que en ese lugar se construya
otra clase** sin tocar el env. Eso es el override: cambiar la pieza sin tocar el
plano. Si creás con `new()`, el override no tiene por dónde entrar y no falla —
te ignora.

**Dónde**: [día 3 · el override de la factory](../libro/dia3.html#el-override-cambiar-la-pieza-sin-tocar-el-plano) ·
**Corre**: `make u4/env`

### 3 · ¿Cuál es la diferencia entre `uvm_object` y `uvm_component`?

El component **está en el árbol**: tiene padre, tiene nombre jerárquico, vive
toda la simulación y UVM le corre las fases. El object no: se crea, se usa y se
tira. Por eso una transaction y una sequence son objects —hay millones y son
temporales— y un driver o un monitor son components. La firma del constructor lo
delata: `(name, parent)` contra `(name)`.

**Dónde**: [día 6 · un objeto, no un componente](../libro/dia6.html#un-objeto-no-un-componente)

### 4 · Nombrame las fases. ¿Cuál consume tiempo?

Son nueve, no cinco: `build`, `connect`, `end_of_elaboration`,
`start_of_simulation`, `run`, `extract`, `check`, `report`, `final`. **La única
que consume tiempo de simulación es `run_phase`**, y es la única que es una
`task`; el resto son `function` y corren en tiempo cero. `build_phase` va
top-down —el padre antes que el hijo, porque el padre construye al hijo— y
`connect_phase` bottom-up.

**Dónde**: [día 3 · el cuadro completo](../libro/dia3.html#el-cuadro-completo-son-nueve-no-cinco) ·
**Corre**: `make u4/components`

### 5 · ¿Cómo sabe UVM cuándo terminar la simulación?

Por las **objections**. Todos los `run_phase` corren en paralelo, así que ninguno
puede decidir solo: el que tiene trabajo hace `raise_objection`, y la fase termina
cuando cae la última. Sin `raise` la simulación termina en **t = 0** y el test pasa
con 0 errores sin mandar un estímulo; sin `drop` no termina nunca. Los dos
síntomas son mudos y por eso existen `+UVM_OBJECTION_TRACE` y `+UVM_TIMEOUT`.

**Dónde**: [día 3 · objections](../libro/dia3.html#objections-quién-decide-cuándo-termina)

### 6 · Terminó el test y las últimas transacciones no se compararon. ¿Por qué?

Porque la objection dice *"terminé de **mandar**"*, no *"terminé de
**comparar**"*. Entre las dos hay un scoreboard con una FIFO adentro y
transacciones en vuelo. Se arregla con un `drain_time` —un colchón después del
último `drop`— o, mejor, con `phase_ready_to_end()`, que deja que el componente
que todavía tiene trabajo levante una objection más. Es el bug de la segunda
semana y no reporta nada.

**Dónde**: [día 3 · el final que no es el final](../libro/dia3.html#el-final-que-no-es-el-final-drain_time)

---

## Estructura: quién es quién en el árbol

### 7 · ¿Qué es el `uvm_config_db` y por qué el `get` va en el `build_phase`?

Una base de datos global y **tipada** —el `#(...)` es parte de la llave— con
ámbito jerárquico. El `set` del top va antes de `run_test()`, porque antes de esa
línea no hay un solo objeto de UVM vivo. El `get` va en `build_phase` y **no** en
el constructor, porque cuando corre el constructor el árbol todavía se está
armando. Y siempre adentro de un `if` con su `uvm_fatal`: el `get` devuelve un
bit, y ignorarlo deja un `null` que explota tres capas más abajo.

**Dónde**: [día 3 · el buzón del testbench](../libro/dia3.html#uvm_config_db-el-buzón-del-testbench)

### 8 · ¿Qué es una virtual interface y por qué hace falta?

Las clases no ven las señales de un módulo: la interface se instancia en el
`top`, que es hardware, y el test es un objeto que se crea en tiempo de
simulación. La virtual interface es el handle que cruza esa frontera, y viaja por
el `config_db` porque el constructor de `uvm_component` sólo acepta
`(name, parent)` y no hay por dónde pasárselo.

**Dónde**: [día 3 · el top](../libro/dia3.html#el-top-instanciar-publicar-la-interface-arrancar)

### 9 · ¿Qué hay adentro de un agent? ¿Qué cambia entre activo y pasivo?

Sequencer, driver y monitor. **El pasivo no construye ni el sequencer ni el
driver**: sólo mira. Se elige con `is_active`, que viaja en un objeto de
configuración, y sirve para enchufar el agent sobre un bus que maneja otro —un
módulo heredado, el testbench del diseñador— y verificarlo sin manejarlo. El
agent es la unidad de reuso: es lo que se compra, se vende y se copia entre
proyectos.

**Dónde**: [día 6 · qué hay adentro de un agent](../libro/dia6.html#qué-hay-adentro-de-un-agent) ·
**Corre**: `make u7/agents`

### 10 · ¿Qué es un analysis port y quién es un subscriber?

El patrón *observer* hecho librería: el monitor **publica** con `write()` y no
lleva la lista de quién escucha; los subscribers implementan `write()` y se
enganchan en el `connect_phase`. Un port puede tener varios destinos y no le
cuesta nada. La consecuencia de diseño es la que importa: **de un lado del
monitor se habla en señales y del otro en transactions**, y agregar un observador
es una línea.

**Dónde**: [día 4 · analysis ports](../libro/dia4.html#un-solo-lugar-que-mira-el-cable-1) ·
**Corre**: `make u5/analysis-ports`

### 11 · Un `write()` de un subscriber, ¿puede esperar un flanco?

No. Es una `function`, y una `function` no consume tiempo: la cadena entera
—`always` del BFM → `ap.write()` → los `write()` de los subscribers— pasa en un
solo instante. Cuando el que consume necesita hacer esperar al que produce, la
pieza es la `uvm_tlm_fifo` con `put`/`get`, que sí son `task`.

**Dónde**: [día 4 · put y get](../libro/dia4.html#comunicación-no-bloqueante)

---

## Estímulo: sequences

### 12 · Contame el handshake entre la sequence y el driver.

La sequence hace `start_item(t)` —que bloquea hasta que el driver esté libre—,
llena o randomiza el item, y hace `finish_item(t)`. Del otro lado el driver hace
`get_next_item(t)`, maneja el cable, y **`item_done()`**. Si el driver se olvida
del `item_done()` no hay error: la sequence queda esperando para siempre y la
simulación se cuelga.

**Dónde**: [día 6 · el handshake](../libro/dia6.html#el-handshake-get_next_item--item_done)

### 13 · ¿Cómo le devolvés el resultado a la sequence?

Escribiéndolo **adentro del mismo item**, antes del `item_done()`. Ése es el
camino de vuelta, y es lo que hace posible un estímulo que reacciona: la
Fibonacci del curso necesita el resultado de la operación anterior para armar la
siguiente.

**Dónde**: [día 6 · el item vuelve con el resultado adentro](../libro/dia6.html#el-item-vuelve-con-el-resultado-adentro) ·
**Corre**: `make u7/sequences`

### 14 · Tenés dos sequences sobre el mismo sequencer. ¿Quién decide el orden?

El sequencer, y arbitra **por item**, no por sequence. La prioridad es el tercer
argumento de `start()`, pero el modo por defecto —`UVM_SEQ_ARB_FIFO`— **no la
mira**: hay que pedir `set_arbitration(UVM_SEQ_ARB_STRICT_FIFO)`. Y cuando el
escenario no se puede intercalar —un lee-modifica-escribe— van `lock()` (hace
cola) o `grab()` (se cuela), siempre con su `unlock()`.

**Dónde**: [día 6 · la arbitración](../libro/dia6.html#dos-sequences-sobre-el-mismo-sequencer-la-arbitración)

### 15 · ¿Qué es una sequence virtual y cuándo hace falta?

Cuando hay **más de un sequencer** y el escenario los cruza. No manda items
propios: saca los handles de un `virtual_sequencer`, y coordina —en `fork` o en
serie— las sequences de cada interfaz. El caso que la justifica es el que tiene
un dato que cruza: configurar por un bus, leer el estado, y recién entonces
mandar tráfico por el otro con lo que la configuración devolvió.

**Dónde**: [día 6 · sequences virtuales](../libro/dia6.html#sequences-virtuales-el-problema) ·
**Corre**: `bash code/u7/sequences/virtual/run.sh`

---

## Chequeo y cobertura: la parte que separa

### 16 · Cobertura de código y cobertura funcional, ¿en qué se diferencian?

La de código la da el simulador gratis y dice **qué RTL se ejecutó**. La
funcional la escribís vos y dice **qué escenarios de la spec pasaron**. La
primera engaña: un test que manda siempre la misma operación ejecuta casi todas
las líneas del sumador y no verificó nada, y a un DUT al que le falta una feature
entera le podés sacar 100 % de líneas — las que nadie escribió no aparecen en el
reporte.

**Dónde**: [día 1 · ¿cuándo terminás de verificar?](../libro/dia1.html#¿cuándo-terminás-de-verificar) ·
**Corre**: `make u2/convencional`

### 17 · Tenés 100 % de cobertura funcional. ¿Terminaste?

No, y hay tres razones para decirlo en voz alta. **`option.at_least` vale 1 por
defecto**, así que un bin que pasó una sola vez ya figura cubierto. Un `cross`
sin filtrar infla el denominador con combinaciones que no están en ninguna spec.
Y sobre todo: la cobertura mide **el plan**, y si un caso de la spec no tiene un
bin, nadie se va a enterar de que falta. El número no es la meta; la pregunta
útil es *cuál* bin falta.

**Dónde**: [día 1 · las perillas](../libro/dia1.html#las-perillas-cuándo-un-bin-cuenta-como-cubierto)

### 18 · `ignore_bins` e `illegal_bins`, ¿cuándo cada uno?

`ignore_bins` saca el bin de la cuenta: es para lo que **no se puede** cubrir, y
es documentación ejecutable —dice en voz alta qué no se mide y por qué—.
`illegal_bins` lo saca de la cuenta *y además* reporta un error si alguna vez
pasa: es para lo que la spec **prohíbe**. Y si simplemente todavía no pasó, no va
ninguno de los dos: va un test.

**Dónde**: [día 1 · ignore_bins](../libro/dia1.html#ignore_bins-decir-en-voz-alta-lo-que-no-se-cubre)

### 19 · ¿Cuándo va una assertion y cuándo va el scoreboard?

El scoreboard chequea **el resultado**: la spec funcional, el qué. La assertion
chequea **el protocolo**: reglas de temporizado que se verifican donde ocurren,
ciclo a ciclo, adentro de la interface. La regla práctica es la de la latencia: si
la regla habla de *cuándo*, es una property; si habla de *cuánto*, es el
scoreboard. Y toda assertion va con su `cover property`, porque una assertion que
nunca se dispara pasa en verde sin chequear nada.

**Dónde**: [día 7 · assertion o scoreboard](../libro/dia7.html#assertion-o-scoreboard-la-misma-regla-dos-lugares) ·
**Corre**: `make u8/assertions`

### 20 · El DUT te contesta fuera de orden. ¿Cómo comparás?

La FIFO no sirve más: apenas se cruzan dos respuestas, la comparación aparea la
respuesta de una con el pedido de otra y el scoreboard grita en **todas**. El
patrón es una **tabla asociativa indexada por lo que aparea** —el ID de la
transferencia—, un `delete` cuando se comparó, y un chequeo al final de que la
tabla quedó vacía. Ese último chequeo es la mitad del valor: lo que quedó adentro
son los pedidos que el DUT nunca contestó.

**Dónde**: [día 4 · cuando el DUT no contesta en orden](../libro/dia4.html#cuando-el-dut-no-contesta-en-orden)

---

## La que siempre cae al final

### 21 · ¿Cómo debuggeás un testbench que no anda?

Con esta tabla, que es la del apéndice del día 7 y conviene tenerla de memoria.
La regla de oro está en la segunda columna: **el sospechoso número uno nunca es
el DUT, es el testbench que lo mira.**

| El síntoma | El primer sospechoso | Con qué se mira |
| --- | --- | --- |
| Termina en **t = 0** y dice PASS | nadie levantó la objection | `+UVM_OBJECTION_TRACE` |
| **No termina nunca** | un `item_done()` que no se llamó | `+UVM_TIMEOUT=5ms`, y después el trace |
| El scoreboard **grita en todas** | el monitor muestrea mal | `+UVM_VERBOSITY=UVM_HIGH` |
| El `config_db` **no encuentra** | el ámbito del `set`, no el `get` | `+UVM_CONFIG_DB_TRACE` |
| La cobertura da **0 %** | falta el `new()` o el `sample()` | `verilator_coverage` sobre el `.dat` |
| El árbol **no es el que dibujaste** | un `create()` sin factory | `print_topology()` |

**Dónde**: [día 7 · la caja de debug](../libro/dia7.html#cuál-usar-según-el-síntoma) ·
**Y también**: [`trampas-mudas.md`](trampas-mudas.md), que es la lista de todo lo
que compila, corre y miente

---

## Lo que no te van a preguntar, y sí van a mirar

Ninguna de estas es una pregunta de UVM, y las tres pesan más que las anteriores.

- **¿Escribiste un plan de verificación alguna vez?** Es el entregable que separa
  al que corrió tests del que verificó algo. La plantilla y el ejemplo lleno están
  en [`plan-de-verificacion.md`](plan-de-verificacion.md), y el capstone del curso
  se entrega con el plan lleno — que es exactamente lo que se entrega en un
  proyecto.
- **¿Podés mostrar algo que corra?** Un testbench de UVM sobre un bus, escrito de
  cero, con su covergroup y su scoreboard, en un repo público. Ése es el capstone
  del día 7: `code/ejercicios/d7-final/`.
- **¿Cómo sabés que tu scoreboard funciona?** La respuesta correcta es *"le
  inyecté un bug al DUT y grité"*. Un scoreboard que nunca vio un error no está
  probado, y el corrector del capstone lo verifica corriendo las dos veces.

---

## Y si venís sin el curso

Las preguntas están ordenadas de más a menos frecuente dentro de cada bloque, y
los bloques en el orden en que se preguntan. Si tenés una tarde: 1, 4, 5, 7, 9,
12 y 21. Si tenés una semana, el curso entero son unas 34 horas y todo corre en
tu máquina — [README](../README.md).
