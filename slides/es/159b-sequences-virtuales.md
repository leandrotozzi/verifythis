## Sequences virtuales

#### *El problema: dos interfaces y un solo `start()`*

- Una **sequence virtual** es una sequence que no manda items propios: sólo
  arranca otras sequences, sobre **varios sequencers**
- Aparece cuando el DUT tiene más de una interfaz —un bus de configuración y un
  stream de datos, por ejemplo— y el test necesita coordinarlas: *configurá
  primero, después mandá tráfico*
- Se le llama "virtual" porque no está atada a un tipo de item ni a un sequencer
- El `u7/agents` ya nos dejó el escenario armado: **dos VTALU**. Ahí el segundo agent
  era pasivo; con los dos activos hay **dos sequencers**, y algo que coordinar
- `full_sequence` ya es media sequence virtual: no manda items propios, sólo
  arranca otras. Lo único que le falta es el segundo sequencer

Note:
Primera hora del día 7, y es a propósito. Es la última pieza del testbench
reutilizable, y llega el día del capstone porque es el día en que el alumno mira
un DUT nuevo y decide qué estructura le corresponde. El capstone tiene **dos**
esclavos APB, cada uno con su interface —uno lo maneja el testbench, el otro un
módulo— y esa es la forma de los agents: uno activo y uno pasivo, un solo
sequencer, y ninguna sequence virtual. Esta hora es la que le da al alumno el
criterio para decidirlo en vez de adivinarlo, y la que le deja escrita la
respuesta para el día en que el segundo esclavo también sea suyo.
Conviene arrancar por el problema y no por la sintaxis, porque la sintaxis es
media pantalla: lo difícil de entender es por qué hace falta una clase nueva
cuando `full_sequence` ya compone sequences.
La respuesta es la del último bullet, y es geométrica: una sequence normal
conoce **un** sequencer, el que le pasó `start()`. Todo lo que quiera hablarle a
dos interfaces necesita dos handles, y esos handles tienen que venir de algún
lado.
El ejemplo corre y está en `code/u7/sequences/virtual/`: es el testbench de esta
sección con **dos líneas** cambiadas en el `env`, y todo lo demás por
referencia. Vale decirlo antes de mostrar el código, porque es la mitad del
argumento: una sequence virtual no cambia la estructura del testbench.

---

## Sequences virtuales

#### *El virtual sequencer: handles, no items*

{{code:code/u7/sequences/virtual/tb_classes/virtual_sequencer.svh#the-handles}}

{{code:code/u7/sequences/virtual/tb_classes/env.svh#wiring-the-sequencers}}

- No tiene cola, no arbitra, no habla con ningún driver. Es un `uvm_component`
  que existe para **tener los handles** y para vivir en el árbol con un nombre
- Extiende `uvm_sequencer` **sin parametrizar**: el item por defecto es
  `uvm_sequence_item` y nunca se manda ninguno
- Los handles se asignan en el `connect_phase`, donde los agents ya existen

Note:
La pregunta que aparece sola: ¿y por qué un componente, si es sólo dos punteros?
Por dos motivos. Uno, para que la sequence lo alcance con `p_sequencer` en vez
de buscar por string. Dos, porque tiene que estar en el árbol para que el test
pueda arrancarle una sequence encima: `seq.start(env_h.virtual_sequencer_h)`.
El libro resuelve los handles con `uvm_top.find("*.env_h.sequencer_h")`. Sigue
funcionando —`uvm_top` está por compatibilidad, la forma actual es
`uvm_root::get()`— pero buscar componentes por string es frágil: el día que
alguien renombra el `env_h`, el `find()` devuelve `null` y el fatal aparece
lejos del cambio. Asignarlos en el `connect_phase` **no compila** si el nombre
cambió, que es exactamente lo que uno quiere.

---

## Sequences virtuales

#### *La sequence virtual: `p_sequencer` y dos ramas*

{{code:code/u7/sequences/virtual/tb_classes/coordinada_sequence.svh#p-sequencer}}

{{code:code/u7/sequences/virtual/tb_classes/coordinada_sequence.svh#the-fork}}

- `` `uvm_declare_p_sequencer `` declara `p_sequencer` **con el tipo del
  sequencer virtual** y lo castea solo. Sin él, `get_sequencer()` devuelve un
  `uvm_sequencer_base` y hay que castear a mano en cada uso
- El `fork`/`join` es sobre **dos sequencers**: cada rama bloquea en su driver y
  el `join` espera a las dos
- Eso no se puede escribir adentro de una sequence normal, que conoce un solo
  sequencer

Note:
El `uvm_declare_p_sequencer` es azúcar, y conviene decirlo: lo único que hace es
declarar la variable y redefinir `m_set_p_sequencer()` con el `$cast`. Si el
sequencer sobre el que se arranca no es de ese tipo, el fatal salta ahí y no
veinte líneas después.
El detalle que se pasa por alto: las dos ramas del `fork` arrancan sequences
**distintas** sobre sequencers **distintos**. Si fueran dos sequences sobre el
mismo sequencer, competirían por la arbitración y los items saldrían
intercalados — que es un escenario legítimo, pero es otro.
Y una advertencia de campo: una sequence virtual con un solo sequencer es una
sequence normal con más ceremonia. La clase se justifica cuando hay dos.

---

## Sequences virtuales

#### *Lo que ninguna sequence sola puede*

{{code:code/u7/sequences/virtual/tb_classes/coordinada_sequence.svh#the-ordered-pair}}

- El resultado de la VTALU **A** entra como operando de la **B**: una dependencia
  **entre interfaces**, y en serie. La segunda no puede ni armarse hasta que la
  primera contestó
- El `result` vuelve adentro del item, que es el camino de vuelta de esta unidad
- `0F × 07 = 105`, y la B contesta `106`. Corre: `code/u7/sequences/virtual/run.sh`

Note:
Ésta es la slide que justifica la clase. Los dos `fork` de la slide anterior se
podrían imitar con dos tests corriendo en paralelo; esto no, porque hay un dato
que cruza de una interfaz a la otra en el medio del escenario.
Es exactamente la forma que tiene el caso real que el apéndice del bus promete:
configurar por APB, leer el estado, y recién entonces mandar tráfico por AXI con
lo que la configuración devolvió. Cambia el protocolo, no la estructura.
Y el criterio para la tarde: en el capstone el segundo esclavo lo maneja un
módulo, así que hay **un** sequencer y esto no hace falta. La sequence virtual
entra el día que las dos interfaces son del testbench y una depende de la otra —
y entonces se escribe igual que acá.
Y el cierre honesto: el ejemplo corre sobre dos VTALU porque es el DUT que
tenemos. Con dos interfaces distintas —dos transactions, dos drivers— la
sequence virtual se escribe **igual**: los handles serían de dos tipos de
sequencer, y nada más.

---

## Sequences virtuales

#### *¿Y si la rama B tiene que esperar a la A?*

```systemverilog
// uvm_event: un aviso, de uno a muchos. Sale del pool global, nadie lo construye
uvm_event listo = uvm_event_pool::get_global("dut_configurado");

listo.trigger();          // la rama que configuró avisa
listo.wait_trigger();     // la que espera bloquea acá
listo.wait_ptrigger();    // igual, pero si ya pasó, sigue de largo

// uvm_barrier: un punto de encuentro entre N ramas
uvm_barrier arranque = uvm_barrier_pool::get_global("arranque");
arranque.set_threshold(2);
arranque.wait_for();      // ninguna de las dos pasa hasta que llegaron las dos
```

- El `join` sincroniza **al final**. Cuando la rama B tiene que esperar a la A
  **en el medio**, hace falta un objeto de sincronización
- `uvm_event` es de **uno a muchos**: uno avisa, los que esperan siguen. Y
  `trigger(data)` puede llevar un `uvm_object` adjunto
- `uvm_barrier` es **simétrico**: nadie pasa hasta que llegaron todos. Es el
  "arranquen juntos" de dos agents que tienen que empezar en el mismo ciclo
- Un `bit` compartido con `wait(flag)` no alcanza: **pierde el pulso** si el que
  espera llegó tarde, y no lleva dato

Note:
Ésta es la pregunta que aparece sola apenas se dibuja el `fork` de la slide
anterior, y conviene contestarla ahí mismo: *"¿y si la rama B no puede arrancar
hasta que la A configuró el DUT?"*.
La distinción que hay que dejar clara es **uno a muchos contra simétrico**. El
`uvm_event` tiene un lado que avisa y otro que espera, y los papeles no se
cambian: sirve para "el reset terminó", "el DUT quedó configurado", "llegó la
interrupción". El `uvm_barrier` no tiene lados: las N ramas ejecutan la misma
línea y ninguna pasa hasta que están todas. Sirve para "arranquen juntas" y para
"esperen todas a que termine la fase de configuración".
El `wait_ptrigger()` merece su propio segundo, porque es la carrera clásica: si
la rama A dispara antes de que la B llegue al `wait_trigger()`, la B espera para
siempre. La `p` es de *persistent*: pregunta si el evento **ya** pasó alguna vez.
La regla práctica: si no podés garantizar el orden, `wait_ptrigger()`.
Y por qué no un `bit` compartido, que es lo primero que se intenta: un `bit` no
guarda historia, no lleva dato adjunto, y no se puede resetear entre fases sin
que alguien se coma un pulso. Los dos objetos de UVM existen precisamente porque
esa versión casera falla una vez de cada cien corridas.
El modo de falla propio: un barrier con el threshold mal puesto no da error —
cuelga. El síntoma es un test que termina por `+UVM_TIMEOUT` sin un solo
`UVM_ERROR`, y `+UVM_OBJECTION_TRACE` muestra la objection arriba y nadie
avanzando.
