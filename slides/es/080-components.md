## Components y fases

#### *Un component es lo que está en el árbol, y al árbol lo recorre UVM*

- Un testbench tiene tres cosas distintas: la **estructura** —qué partes hay y
  cómo se conectan—, las **secuencias** —qué comandos, en qué orden— y los
  **datos**. Esta unidad es la primera; los datos son el día 5 y las secuencias el día 6
- En los tests el test hacía `new()` de tres objetos sueltos y los llamaba
  él mismo. Eso no es una estructura: es una función larga
- Un `uvm_component` es un **nodo con nombre y con padre**. UVM arma el árbol
  completo y después lo recorre entero llamando **fases**, en un orden que
  garantiza
- Convertir una clase en component son cuatro pasos, siempre los mismos:

  1. extender `uvm_component` o una hija suya
  2. registrarla con `` `uvm_component_utils() ``
  3. el constructor mínimo: `(string name, uvm_component parent)`
  4. override de las fases que le hagan falta

Note:
La frase de la slide es la que ordena la unidad: *un component es lo que está en
el árbol*. Todo lo demás —el nombre, el padre, las fases, el `print_topology` de
los agents— sale de ahí.
La consecuencia práctica que hay que decir en voz alta: si algo no es un
component, UVM no lo ve. No lo construye, no le llama fases y no aparece en la
topología. Más adelante vamos a tener objetos que a propósito **no** son
components —las transactions— y ahí la distinción se cobra.
Los tres ejes —estructura, secuencias, datos— valen como mapa del resto del
curso: components y `env` son estructura, transactions son datos, sequences son
secuencias.

---

## Components y fases

#### *Intro UVM phases*

- Todos los uvm components tienen estos phase methods por herencia
- UVM crea el TB y va llamando estos métodos en orden
- Las fases son *métodos*: se overridean como cualquier otro método virtual.
  Si además conviene llamar a `super`, es tema de la slide que sigue

- *function void build_phase(uvm_phase phase):* UVM crea el TB (top-down). Los componentes UVM se instancian en este método. Si tratás de instanciarlos en otro lado es error
- *function void connect_phase(uvm_phase phase):* Conexión de componentes
- *function void end_of_elaboration_phase(uvm_phase phase):* UVM lo llama una vez que creó y conectó todos los componentes
- *task run_phase(uvm_phase phase):* UVM ejecuta esta task en su propio thread. Todos los run_phase se ejecutan simultáneamente
- *function void report_phase(uvm_phase phase):* Se ejecuta cuando se termina la última objection del test. Muestra Resultados

Note:
Tres cosas que hay que decir sí o sí: build_phase es top-down, connect_phase es
bottom-up, y todos los run_phase corren en paralelo, cada uno en su thread.
Y el error clásico: crear componentes **después** de que build terminó. UVM sí te
avisa, y bien: `ILLCRT` te dice qué componente y bajo qué padre.

---

## Components y fases

#### *El árbol, dos veces: una baja y la otra sube*

![El árbol recorrido dos veces: build_phase baja y connect_phase sube, y el orden real en que se construye un hijo](res/diagrams/components_fases.svg)
<!-- .element: class="grande" -->

- `build_phase` baja porque el padre tiene que existir para crear a sus hijos
- `connect_phase` sube por lo contrario: el otro extremo ya tiene que estar
- El hijo se **crea** adentro del build del padre; su propio build corre después
- Por eso el `set()` del `config_db` va **antes** del `create()` que lo construye

Note:
El dibujo contesta dos preguntas que en la tabla se leen como una convención
arbitraria. La primera: por qué `build_phase` es top-down. Porque un padre tiene
que existir para crear a sus hijos, y no hay otra forma de armar un árbol; las
del medio necesitan lo contrario, que los hijos ya estén.
La segunda es la que se pregunta en voz baja: si el padre crea al hijo adentro de
su propio `build_phase`, ¿cuándo corre el `build_phase` del hijo? Después, y ésa
es la parte que hay que decir despacio: `create()` llama al **constructor**, no a
la fase. UVM recorre el árbol llamando la fase a los componentes que fueron
apareciendo, así que el hijo se construye en dos tiempos.
La consecuencia práctica es la del último bullet y es la que se cobra: un
`uvm_config_db::set()` escrito **después** del `create()` del hijo llega tarde,
el hijo ya leyó, y el campo queda en su default sin que nadie avise. Es el mismo
modo de falla asimétrico de la slide que sigue.
Si alguien pregunta por el código: `uvm_topdown_phase::traverse` ejecuta la fase
en el componente y recién después recorre sus hijos —`get_first_child()`—, que
para entonces ya existen.

---

## Components y fases

#### *¿Y el `super.build_phase()`?*

```systemverilog
// uvm_component.svh:2385-2393 — uvm-core 2020.3.1, con el return; elidido
function void uvm_component::build_phase(uvm_phase phase);
   build();            // -> apply_config_settings(): la config automatica
endfunction

function void uvm_component::connect_phase(uvm_phase phase);
   connect();          // -> return;  esta vacia, igual que las demas
endfunction
```

- `build_phase` es la **única** fase que hace algo en `uvm_component`: aplica los
  campos registrados con `` `uvm_field_* ``. El curso no usa esas macros
- Ojo, hay **dos `super` distintos**: ése, y el de una clase base **tuya**, que
  construye lo que vos escribiste. El segundo el curso **sí** lo llama
- Afuera: **ponelo siempre, salvo que puedas nombrar por qué en tu caso es un
  no-op**. De más no cuesta nada; de menos —un `` `uvm_field_* ``, o heredar de
  `uvm_agent`— el campo queda en su default y **nadie te avisa**
- Y el orden importa: lo que tenga que estar decidido *antes* de construir los
  hijos va antes del `super`. El `set_type_override` de `add_test` es eso

Note:
Esta slide existe porque el alumno va a ver `super.build_phase(phase)` en todo el
material de internet y en la mayoría de los `build_phase` del curso no está. La
respuesta honesta no es "se olvidaron": es que sin las macros de campo la llamada
al de `uvm_component` no hace nada.
Los números, para que nadie tenga que creernos:
`grep -rn 'super\.build_phase' code/ --include='*.sv' --include='*.svh' --exclude-dir=.uvm`
da {{count:super-build-phase}} llamadas reales —más {{count:super-build-phase-comentarios}}
comentarios que hablan de ellas— sobre {{count:build-phase}} `build_phase`. Las
{{count:super-build-phase}} llaman al
`super` de un `base_test` o un `random_test` **nuestro**, que construye el env.
Ninguna llama al de `uvm_component`, que es de lo que habla la slide.
La otra diferencia de fondo: hay dos formas de configurar un componente. La
automática (`` `uvm_field_* `` + config_db, magia por macros) y la manual
(`uvm_config_db::get()` en el build_phase, que es la que usa el curso). La manual
es más código y muchísimo más fácil de debuggear — las macros de campo generan
cientos de líneas que no vas a leer nunca.
Por qué la recomendación de afuera es la contraria a lo que hace el curso: el
modo de falla es asimétrico. Ponerlo de más es cero efecto. No ponerlo cuando
hacía falta es silencio: el campo queda en su default y la simulación corre.
Este curso puede nombrar por qué en su caso es un no-op —no hay una sola macro
`` `uvm_field_* `` en `code/` fuera de la librería vendorizada —son
{{count:uvm-field-macros}}, y el número lo cuenta el build—; el que entra a un testbench ajeno no
puede. `uvm_agent` es el contraejemplo que tenemos a mano: además de `uvm_component`,
lo implementan `uvm_agent` —que ahí lee `is_active`— y las dos bases del
sequencer (`seq/uvm_sequencer_base.svh:122`, que lee
`wait_for_sequences_count` del config_db, y `seq/uvm_sequencer_param_base.svh:236`).
Vuelve en el día 6.
Con las otras fases pasa lo mismo, más barato todavía: en `uvm_component` son
`return;`, pero `uvm_driver::end_of_elaboration_phase` chequea que el
`seq_item_port` esté conectado, y ése lo extendemos nosotros.

---

## Components y fases

#### *El cuadro completo: son nueve, no cinco*

<!-- tabla: fases -->
| Fase | Para qué | Orden |
| --- | --- | --- |
| `build_phase` | instanciar los componentes | **top-down** |
| `connect_phase` | conectar los ports | bottom-up |
| `end_of_elaboration_phase` | jerarquía lista, antes de simular | bottom-up |
| `start_of_simulation_phase` | último aviso antes del tiempo 0 | bottom-up |
| `run_phase` | **task**: acá pasa la simulación | un thread c/u |
| `extract_phase` | juntar los datos de la corrida | bottom-up |
| `check_phase` | decidir si pasó o no | bottom-up |
| `report_phase` | imprimir el veredicto | bottom-up |
| `final_phase` | cerrar archivos y salir | **top-down** |
<!-- tabla: end -->

- El curso usa cinco. Las otras cuatro existen, están vacías, y las vas a ver

Note:
La tabla está para que nadie se vaya creyendo que UVM tiene cinco fases: tiene
nueve comunes y doce runtime. El curso usa cinco porque con un solo agent
alcanza, y eso hay que decirlo — no es que las otras no importen.
Las tres que más se van a cruzar afuera: `start_of_simulation_phase` es donde la
gente imprime el banner de configuración del test; `check_phase` es donde un
scoreboard prolijo decide el veredicto, en vez de contar errores sobre la
marcha; y `report_phase` es la que ya vieron.
Que `extract` / `check` / `report` estén separadas tiene una razón concreta: son
bottom-up, así que un scoreboard hijo termina de extraer antes de que el env
padre decida. Si hacés las tres cosas en `report_phase`, perdés esa garantía.
La pregunta que ordena la tabla: ¿por qué `build_phase` es top-down?
Porque un padre tiene que existir para poder crear a sus hijos. Las del medio
necesitan lo contrario — que los hijos ya estén. La otra top-down es
`final_phase`, que cierra el árbol en el mismo orden en que se construyó.

---

## Components y fases

#### *Y adentro del `run_phase`, un cronograma*

![Las doce fases runtime corriendo en paralelo con run_phase, y dónde se engancha la default_sequence](res/diagrams/components_runtime.svg)
<!-- .element: class="grande" -->

- Las doce son `task`, corren **en paralelo** con `run_phase`, y están para
  coordinar componentes de equipos distintos sin banderas a mano
- El curso usa `run_phase` y nada más — con un solo agent no hay nada que
  coordinar. Pero el `default_sequence` del día 6 se engancha a **`main_phase`**

Note:
Esta slide existe para que `main_phase` no aparezca por primera vez en el día 6.
La distinción exacta, que confunde a todo el mundo: `run_phase` y el cronograma
`reset → configure → main → shutdown` corren **a la vez**, no uno adentro del
otro. Un componente puede implementar cualquiera de los dos caminos; lo que no
conviene es mezclarlos en el mismo testbench, porque después nadie sabe qué
corre cuándo.
La pregunta honesta es "¿y entonces cuál uso?". Para un testbench de un solo
bloque, `run_phase`, que es lo que hace el curso. El cronograma se gana el
sueldo en integración: el agent del bus de configuración termina su `configure`
y recién ahí el de datos arranca su `main`, sin que ninguno de los dos equipos
haya tenido que escribir un `uvm_event` ni una bandera compartida.

---

## Components y fases

#### *El scoreboard, ahora como component*

{{code:code/u4/components/tb_classes/scoreboard.svh#class-and-build}}

- Los cuatro pasos, en orden: extiende `uvm_component`, se registra, constructor
  `(name, parent)`, y override de `build_phase`
- El cambio de fondo no se ve en el diff: antes el **test** recibía la BFM y se
  la pasaba al scoreboard por el constructor. Ahora el scoreboard **se la pide
  solo** al config_db
- El `run_phase` es el `execute()` del testbench en objetos sin tocar una coma: el
  chequeo no cambió, cambió quién lo arranca

Note:
El punto de la slide es la autosuficiencia. Un componente que necesita que
alguien le pase sus dependencias obliga a que ese alguien las conozca, y el test
termina siendo un repartidor de handles que no usa. Con el config_db, el test no
sabe que el scoreboard necesita una BFM.
Eso es exactamente lo que hace que el `env` pueda existir: si
cada componente se configura solo, el padre sólo tiene que construirlo.
El precio también hay que decirlo: la dependencia dejó de estar en el
constructor, donde se veía, y pasó a un string. `"bfm"` mal escrito compila. Por
eso el `if (!get(...)) uvm_fatal` no es opcional.

---

## Components y fases

#### *El test construye el árbol y se va*

{{code:code/u4/components/tb_classes/random_test.svh}}

- Los tres `new("nombre", this)` son lo que crea el árbol: `this` es el padre, y
  el string es el nombre que va a salir en `print_topology` y en cada mensaje
- Van en `build_phase` **y en ningún otro lado**. En el constructor todavía no
  hay jerarquía; después de `build_phase`, UVM ya siguió
- `random_test` **no tiene `run_phase`**: su trabajo terminó cuando el árbol
  quedó armado. Los tres hijos tienen el suyo, y corren en paralelo

Note:
Es el cambio de mentalidad de la unidad, y conviene decirlo con estas palabras:
el test dejó de *hacer* el test. Ahora lo arma y se corre a un costado.
La objection también se mudó: ya no la levanta el test, la levantan los
componentes que tienen trabajo — o, en este ejemplo, el tester. Vale mostrar
`random_tester.svh` un segundo para que se vea.
Y la trampa que va a aparecer sola: `new()` acá funciona porque el tipo está
escrito en la declaración. En el env eso se reemplaza por
`type_id::create()`, y ése es el cambio que habilita los overrides. Todavía no,
pero conviene sembrarlo.

---

## Components y fases

#### *El segundo test: hereda, y aun así copia*

{{code:code/u4/components/tb_classes/add_test.svh}}

- `add_test` extiende `random_test`, así que hereda `coverage_h` y
  `scoreboard_h`. Sólo redeclara `tester_h`, con otro tipo
- Pero el `build_phase` está **escrito de nuevo entero**, y las tres líneas son
  idénticas salvo una. Heredar la clase no alcanzó para heredar la estructura
- Y hay algo peor escondido: `add_tester tester_h;` **tapa** al `tester_h` de la
  clase base. Son dos variables distintas con el mismo nombre
- Es el mismo problema de los tests, disfrazado. El env lo resuelve de
  verdad: **una** estructura, y la factory sustituye la pieza que cambia

Note:
Ésta es la slide que hay que dejar incómoda. Si el alumno sale pensando "esto
sigue estando mal", el env se explica sola.
El shadowing del handle merece un minuto: en la clase base hay un
`random_tester tester_h` y acá un `add_tester tester_h`. Cualquier método
heredado de `random_test` que use `tester_h` va a ver el de la base, que quedó en
`null`. Acá no molesta porque no hay ninguno, pero es una bomba de tiempo y es
exactamente el tipo de error mudo que el curso persigue.
El enganche: en el `env` no hay dos tests, hay uno; y `add_test` pasa a ser una
línea de `set_type_override_by_type`.

---

## Components y fases

#### *Resumen de la unidad*

- Un `uvm_component` es un **nodo con nombre y con padre**. UVM arma el árbol
  con esos dos datos y después lo recorre solo
- Convertir una clase en component son **cuatro pasos, siempre los mismos**:
  extender, registrar con la macro, el constructor de dos argumentos, y las
  fases
- Las **fases** son métodos virtuales que UVM llama **en orden**: `build_phase`
  (top-down), `connect_phase`, `end_of_elaboration_phase`, `run_phase`,
  `report_phase`
- Los componentes se instancian **en el `build_phase` y en ningún otro lado**
- Todos los `run_phase` corren **en paralelo**, cada uno en su thread. Ninguno
  decide solo cuándo termina la simulación: eso son las **objections**
- Hay **dos `super.build_phase()`**: el de `uvm_component` y el de tu clase base.
  **Ponelo siempre, salvo que puedas nombrar por qué en tu caso es un no-op**

Note:
La unidad que convierte el testbench en algo que UVM puede recorrer, y con eso
aparecen las herramientas que no existían antes: `print_topology()` muestra el
árbol, y el `uvm_config_db` puede usar rutas porque ahora hay rutas.
El `super.build_phase()` merece la vuelta que le dimos porque es la pregunta más
repetida de los foros. Lo que hay que dejar dicho es la asimetría: no llamarlo
apaga la asignación automática de los campos registrados con `` `uvm_field_* ``,
y eso no da error, da un default. Este curso no usa esas macros y por eso puede
no llamarlo; el alumno que cae en un testbench ajeno no sabe si puede, así que
lo pone. Lo que no es válido es hacer media cosa de cada una.
