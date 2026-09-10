## Reporting

#### *El 47 % del tiempo se va acá*

- El primer gráfico del curso decía que casi la mitad del tiempo de un verificador
  se va en **debug**. Esta sección es sobre esa mitad
- Un scoreboard que sólo dice `FAIL` te deja justo ahí: sabés que algo está mal y
  no sabés qué componente, en qué momento, ni con qué datos
- La reacción natural es llenar el código de `$display`, y después borrarlos.
  Y volver a ponerlos la semana que viene
- UVM lo resuelve al revés: los mensajes **se dejan puestos** y se filtran. Cada
  uno trae solo el tiempo, la ruta jerárquica del componente y el archivo
- Y hay dos perillas distintas, que se confunden todo el tiempo: la **verbosidad**
  filtra `` `uvm_info ``; las **actions** controlan warnings, errores y fatales

Note:
Vale volver al gráfico del día 1 antes de arrancar, porque esta sección parece
de plomería y es el que más horas devuelve. El argumento no es "los mensajes
lindos": es que un mensaje que trae solo la ruta jerárquica te ahorra la pregunta
"¿quién lo dijo?", que es la mitad de cualquier debug.
La segunda idea, que es la que cuesta: los mensajes de debug **no se borran**. Un
`` `uvm_info `` en UVM_HIGH no cuesta nada cuando el techo está en UVM_MEDIUM, y
el día que lo necesitás está ahí. Que el ejercicio del día 5 se resuelva subiendo
la verbosidad no es casualidad — está armado para que lo vivan.
Y la distinción de la última línea conviene anotarla en el pizarrón de entrada,
porque es la pregunta 6 del repaso: verbosidad e info por un lado, actions y
error/warning/fatal por el otro. Nunca se cruzan.

---

## Reporting

#### *Lo que `$display` no puede hacer*

- Mil operaciones por test, decenas de tests por regresión: un `$display` por
  transacción y el log deja de ser legible antes del primer café
- Y con `$display` la única forma de bajar el ruido es **borrar líneas**, o sea
  perder justo lo que vas a necesitar la próxima vez
- UVM reemplaza el `$display` por cuatro macros que traen dos cosas gratis:
  contexto —tiempo, componente, archivo— y un **filtro** que se maneja desde
  afuera

Note:
La pregunta que ordena la slide, y conviene tirarla al grupo antes de la
respuesta: *¿qué tiene de malo `$display`?* La respuesta que sale siempre es "es
feo", y no es ésa. `$display` imprime **o no existe**: la decisión de si un
mensaje sale se toma en el momento de escribirlo, editando el código.
Lo que UVM agrega no es formato, es que la decisión se mueve al momento de
**correr**, y se toma desde afuera con un plusarg. Ese cambio de tiempo es toda
la sección: por eso los mensajes se pueden dejar puestos, y por eso el log de una
regresión y el log de un debug pueden salir del mismo binario.
El dato de contexto, para el que viene de VHDL o de Verilog puro: nada de esto
es magia del simulador. `` `uvm_info `` es una macro que arma un string y se lo
pasa a un objeto —el *report server*— que decide qué hacer. Todo lo que sigue en
la sección es configurar ese objeto.

---

## Reporting

#### *Las macros de reporting*

- Son cuatro y se diferencian por la **severidad**: `` `uvm_info ``,
  `` `uvm_warning ``, `` `uvm_error `` y `` `uvm_fatal ``. **Las cuatro** se cuentan
  en el *Report Summary*; lo que cambia es la **acción** por defecto — `` `uvm_error ``
  trae `UVM_DISPLAY|UVM_COUNT` y `` `uvm_fatal `` además mata la simulación
- El **ID** es el primer argumento: un string que dice quién habla. Con él se
  filtra después, así que conviene que sea el nombre del componente y siempre el
  mismo
- El **mensaje** es el segundo, y se arma con `$sformatf` cuando lleva datos
- La **verbosidad** es el tercero, y la tiene **sólo** `` `uvm_info ``: es la que
  decide si el mensaje sale o no

{{code:code/u4/reporting/reporting.sv}}

Note:
La confusión de siempre: la verbosidad filtra `` `uvm_info ``, y nada más. Los
warnings, errores y fatales no tienen verbosidad — se controlan con actions, que
es la última parte de la sección.

---

## Reporting

#### *Las macros de reporting: qué hace cada una*

- Así se ve en el scoreboard: un `` `uvm_error `` cuando la comparación falla, con
  el mensaje armado con `$sformatf`
- Y así sale en el log. Fijate lo que trae la línea **sin que nadie lo pida**: el
  tiempo, el archivo y la línea, y la ruta jerárquica del componente que habló

{{code:code/u4/reporting/tb_classes/score_ppt.svh}}

{{code:code/u4/reporting/tb_classes/scoreboard_error.txt}}

Note:
Vale detenerse en la línea del log y leerla en voz alta de izquierda a derecha,
campo por campo, porque es la que el alumno va a mirar mil veces y nadie se la
explica nunca: severidad, tiempo, archivo y línea del `` `uvm_error ``, y después
`uvm_test_top.env_h.scoreboard_h` — la ruta de instancia. Recién ahí viene el ID
y el mensaje.
El punto pedagógico es lo que **no** está en el código: el scoreboard no imprimió
el tiempo ni su propio nombre. Los puso la macro. Ése es todo el argumento a
favor de no volver a escribir un `$display` en un testbench.
Y la comparación honesta con el `$error` del día 2: aquel scoreboard también
hacía fallar el test, pero el contexto había que escribirlo a mano — y ahí nadie
escribe la ruta jerárquica, porque no la sabe.

---

## Reporting

#### *Los seis niveles, y por qué el mensaje se queda*

- El ciclo de siempre: llenás el código de `$display`, encontrás el bug, borrás
  todo — y la semana que viene lo escribís de nuevo
- Con verbosidad los mensajes **se quedan puestos** y no molestan. Son dos pasos,
  y el segundo no toca el código:
  - poner una verbosidad en cada `` `uvm_info ``, según cuánto ruido es
  - fijar el **techo** de la corrida: global, o por rama del árbol
- Un mensaje sale si su verbosidad es **menor o igual** al techo. Por eso
  `UVM_NONE` sale siempre

{{code:code/u4/reporting/tb_classes/verbosidad.svh}}

Note:
Los seis niveles, de menos a más ruidoso: `UVM_NONE`, `UVM_LOW`, `UVM_MEDIUM`
—el que está por defecto—, `UVM_HIGH`, `UVM_FULL` y `UVM_DEBUG`. `UVM_FULL` es el
que nadie usa y el que aparece en el enum de la slide, así que vale nombrarlo. Un
mensaje se imprime si su
verbosidad es **menor o igual** al techo, así que `UVM_NONE` sale siempre.
La regla práctica que conviene bajar, porque si no cada uno inventa la suya:
`UVM_LOW` para lo que querés ver en una regresión —qué test corrió, cuántas
transacciones—; `UVM_MEDIUM` para el resumen de un componente; `UVM_HIGH` para
cada transacción que pasa. Los monitores del curso son `UVM_HIGH` justamente por
eso: en una corrida normal no se ven, y cuando algo falla se prenden con un
plusarg.
El detalle de forma que se copia mal: la verbosidad es el **tercer** argumento del
`` `uvm_info ``, y si te la olvidás no compila. El ID —el primero— es un string
libre, pero no lo elijas al azar: es la llave con la que después vas a filtrar.
Que sea el nombre del componente, en mayúsculas, y siempre el mismo.

---

## Reporting

#### *El techo global: un plusarg, sin recompilar*

- Se fija de dos formas, y la primera es la que se usa todos los días: un
  **plusarg** en la línea de comando
- No hay que tocar código ni recompilar. El mismo binario da el log de la
  regresión y el log del debug
- El problema aparece con el equipo: si son diez personas con sus propios mensajes
  de debug, subir el techo global te trae los de todos
- Por eso hace falta poder pedirlo **por componente**, que es la slide siguiente

{{code:code/u4/reporting/tb_classes/verbosity_ceiling.txt}}

Note:
Conviene correrlo en vivo, porque es la demostración más barata de la sección:
el mismo `make u4/reporting` con y sin `+UVM_VERBOSITY=UVM_HIGH`, y el log pasa
de 7 `uvm_info` a 22. Sin recompilar nada — es el mismo binario. Parecen pocos
porque este ejemplo manda **diez** operaciones a propósito, para que el
transcript entre en la pantalla; con las mil de las otras secciones la diferencia
es de tres órdenes de magnitud.
El detalle que hay que decir para que después no sorprenda: el plusarg fija el
techo del **árbol entero**, desde `uvm_top` para abajo. No hay forma de pedir
"alto, pero sólo el monitor" desde la línea de comando con este flag; para eso
está `+uvm_set_verbosity`, que es más largo de escribir y casi nadie recuerda.
La salida honesta, y la que enseña la slide siguiente, es fijarlo desde el
código en el componente que te interesa.
Y el argumento de fondo, por si el grupo lo subestima: éste es el mecanismo que
hace que un log de regresión de mil tests sea legible. No es cosmética de aula.

---

## Reporting

#### *`uvm_cmdline_processor`: la línea de comandos, entera*

- `+UVM_VERBOSITY` y `+UVM_TESTNAME` no los lee magia: los lee **una clase**, y
  está disponible para tus propios plusargs

```systemverilog
uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
string valor;

if (clp.get_arg_value("+COUNT=", valor)) count = valor.atoi();
```

- Es un **singleton**: `get_inst()` desde cualquier clase, sin construir nada y
  sin pasarlo por el `config_db`
- `get_arg_value` devuelve **cuántas veces apareció** el argumento, no el valor:
  el valor sale por el `ref`. Si apareció dos veces te enterás — `$value$plusargs`
  se queda callado con el primero
- Y están `get_args()`, `get_plusargs()` y `get_uvm_args()`, que devuelven la
  línea de comandos entera en un queue: es como se imprime en qué condiciones
  corrió una regresión de hace tres meses

Note:
El curso usa `$value$plusargs` y `$test$plusargs` en los `base_test` porque son
una línea y se leen solos. Vale decir por qué en un testbench de producción
aparece siempre esta clase: `$value$plusargs` es una system task, así que no se
puede heredar, no se puede sustituir por la factory y no se puede testear. El
`uvm_cmdline_processor` es un objeto, y eso alcanza para las tres cosas.
El argumento que más rinde es el último bullet y no es el que uno espera:
`get_args()` imprimiendo la línea entera en el `start_of_simulation_phase` es lo
que convierte un log viejo en algo reproducible. Sin eso, el log dice qué pasó
pero no con qué se corrió, y una regresión de hace tres meses no se puede repetir.
La diferencia del segundo bullet vale una anécdota: dos `+COUNT=` en la misma
línea —porque el script los agrega y el usuario también— es un caso real, y
`$value$plusargs` toma uno sin decir cuál. El `uvm_cmdline_processor` devuelve 2,
así que al menos te podés dar cuenta. Es la clase de cosa que se paga una vez y
se recuerda.

---

## Reporting

#### *El techo por rama: dos métodos y un árbol*

- Todo `uvm_component` trae métodos para fijar su propio techo, en dos sabores:
  sólo él, o él **y todo lo que cuelga debajo** (`_hier`)
- Ojo con qué jerarquía es: **no** es la de módulos del DUT. Es el árbol que UVM
  arma llamando `build_phase()` de arriba hacia abajo
- Es el mismo árbol del que sale el prefijo de cada mensaje, y el mismo que usa el
  `uvm_config_db` como ámbito

![Jerarquia de instancias y de donde sale el prefijo de los mensajes](res/diagrams/UVM-hierarchy.svg)
<!-- .element: class="grande" -->

Note:
Este diagrama vale más de lo que parece, porque explica de dónde sale ese prefijo
larguísimo que trae cada mensaje: `uvm_test_top.env_h.scoreboard_h`. No es
decoración — es la **ruta de instancia** del componente que habló.
Y es la misma ruta que usa el `uvm_config_db` para el ámbito. Vale decirlo
explícito: cuando en los tests dijimos "el ámbito es una ruta jerárquica", era
literalmente esta ruta. Un solo árbol sirve para las dos cosas.
La aclaración del bullet no es un detalle: esta jerarquía **no es la del DUT**. Un
scoreboard no está adentro de ningún módulo. Es el árbol que UVM arma llamando
`build_phase` de arriba hacia abajo, y existe sólo en el testbench.
Truco para el aula: `uvm_top.print_topology()` imprime este árbol de verdad,
escrito por la librería. Es la mejor forma de mostrar que no es un dibujo.
`+UVM_CONFIG_DB_TRACE` es otra cosa y conviene no mezclarlas: no dibuja el árbol,
traza cada `set()` y cada `get()` del `config_db` con el ámbito que se usó — que
es la perilla del otro problema, el del ámbito que no matchea.

---

## Reporting

#### *El techo por rama: dónde va la llamada*

- El llamado va **después** de que la jerarquía exista —si no, el componente
  todavía no está— y **antes** de que arranque la simulación
- Esa ventana tiene nombre y es una de las nueve fases: `end_of_elaboration_phase`
- `set_report_verbosity_level_hier()` alcanza al componente **y a sus hijos**;
  `set_report_verbosity_level()`, sólo a él

{{code:code/u4/reporting/tb_classes/ceil_hierar.sv}}

Note:
La ventana es lo que hay que dejar grabado, porque el error se comete en las dos
direcciones. Si la llamada va en el `build_phase`, el componente al que le querés
subir el techo **todavía no existe** —lo construye su padre más abajo— y la
llamada no encuentra a nadie. Si va en el `run_phase`, la simulación ya arrancó y
te perdiste los mensajes de las fases anteriores.
`end_of_elaboration_phase` es exactamente el hueco entre las dos cosas: el árbol
completo, y el tiempo todavía en cero. Es la primera vez en el curso que se usa
para algo, y vale decirlo así — en la tabla de las nueve fases del día 3 no
estaba de adorno.
El sufijo `_hier` es el que se olvida, y falla en silencio: fijás el techo del
`env` sin `_hier`, el `env` no imprime nada de todos modos, y el monitor que
querías escuchar sigue callado. Regla práctica: si apuntás a una rama, `_hier`;
si apuntás a una clase, sin.

---

## Reporting

#### *Apagar warnings, errores y mensajes fatales*

- Situación real: el DUT está bien, el scoreboard predice mal la suma, y la clase
  la está arreglando otra persona. Necesitás seguir trabajando mientras tanto
- Bajar el techo de verbosidad **no sirve**: sólo afecta a `` `uvm_info ``, y lo
  que hay que callar es un `` `uvm_error ``
- Hace falta otra perilla

{{code:code/u4/reporting/scoreboard1.txt}}

Note:
El log de la slide es el de un scoreboard que suma mal a propósito, y conviene
mirar el *Report Summary* del final antes que el error: `UVM_ERROR : 2`, uno por
cada `add_op` que salió en las diez operaciones del ejemplo. Ahí está la cuenta
que hay que hacer en voz alta: con las mil operaciones de las otras secciones son
**cien y pico de errores**, uno por cada suma. Ése es el problema real que la
sección viene a resolver — no "el mensaje molesta", sino que **el log deja de
servir para buscar otra cosa**.
La pregunta para tirar al grupo, porque la respuesta equivocada es la intuitiva:
*"¿bajo el techo de verbosidad y listo?"*. No. Un `` `uvm_error `` no tiene
verbosidad; el techo no lo toca. Es la misma distinción de la primera slide, y
acá se cobra por primera vez.
Y la aclaración honesta antes de enseñar a apagar errores, porque si no queda
sonando raro: esto no es para que la regresión dé verde. Es para poder trabajar
media tarde mientras otro arregla su clase, y se saca el mismo día.

---

## Reporting

#### *Apagar mensajes: por dónde se hace*

- Warnings, errores y fatales son **inmunes** al techo de verbosidad, y está bien
  que así sea: nadie quiere apagar un error sin querer
- La perilla que sí los alcanza se llama **actions**, y responde a otra pregunta:
  no *"¿se imprime?"* sino *"¿qué se hace con este mensaje?"*
- Imprimir es sólo una de las siete cosas posibles

{{code:code/u4/reporting/tb_classes/UVM_report_actions.sv}}

Note:
Las siete acciones son un OR de bits, no una lista de opciones excluyentes: un
mismo mensaje puede imprimirse **y** escribirse a un archivo **y** contar para el
resumen. Por eso se combinan con `|`.
`UVM_COUNT` es la que más se explica mal, y conviene decirla completa: ya está
puesta por defecto en todo `` `uvm_error ``, y lo que incrementa es **un contador
global** de la corrida, no uno por ID. Sola no mata nada, porque el máximo por
defecto es 0, que quiere decir "sin límite". La que corta es
`+UVM_MAX_QUIT_COUNT=N` (`uvm_root.svh:1187`) —o `set_report_max_quit_count(N)`,
`uvm_report_object.svh:578`—, y
ésa sí es la respuesta al log de cuatro gigas cuando un scoreboard falla en cada
transacción: te enterás igual, y en treinta segundos en vez de en veinte minutos.
`UVM_NO_ACTION` es la que usa la slide siguiente para apagar los errores, y hay
que decir en voz alta para qué **no** sirve: no es para que la regresión dé verde.
Es para seguir trabajando mientras otro arregla su clase, y se saca el mismo día.
Un `UVM_NO_ACTION` que sobrevive a un commit es un bug esperando.
Y el par que conviene nombrar: `set_report_severity_action` es por severidad,
`set_report_id_action` es por ese string de ID que elegiste al escribir el
mensaje. Ahí se paga la disciplina de haber usado siempre el mismo.

---

## Reporting

#### *Apagar mensajes: el ejemplo completo, y el log que queda*

- `set_report_severity_action_hier(UVM_ERROR, UVM_NO_ACTION)` sobre el scoreboard:
  cuando aparezca un error ahí adentro, que no haga nada
- Va en el `end_of_elaboration_phase` del `env`, por el mismo motivo que la
  verbosidad jerárquica
- Y el log de abajo es el resultado: mismo DUT, mismo scoreboard roto, cero
  errores en el *Report Summary*

{{code:code/u4/reporting/tb_classes/env_disable_error.sv}}

{{code:code/u4/reporting/scoreboard2.txt}}

Note:
Decirlo en voz alta: apagar errores sirve para seguir trabajando mientras otro
arregla su clase, no para que la regresión dé verde.
Y mostrar el *Report Summary* del segundo log al lado del primero es la mejor
advertencia que da la sección: el testbench dice **0 UVM_ERROR** y el DUT sigue
exactamente igual de roto que cuando lo rompimos. Ésa es la razón de que un
`UVM_NO_ACTION` no pueda sobrevivir a un commit — es una trampa muda, y está en
el apéndice.
El scoreboard de esta sección suma de más A PROPÓSITO, es el bug que estamos
mostrando. Por eso `code/u4/reporting/run.sh` exporta UVM_ERRORS_OK=1: por
defecto un uvm_error hace fallar la corrida, y acá el error es el ejemplo.

---

## Reporting

#### *`uvm_report_catcher`: demotar el error que esperabas*

- `UVM_NO_ACTION` apaga **todos** los errores de una rama. Cuando el test
  verifica el camino de error a propósito —un `PSLVERR` que tiene que llegar— lo
  que hay que callar es **uno solo**, y el resto tiene que seguir gritando

```systemverilog
class demotar_pslverr extends uvm_report_catcher;
   virtual function action_e catch();
      if (get_severity() == UVM_ERROR && get_id() == "PSLVERR")
         set_severity(UVM_INFO);      // deja de contar como error
      return THROW;                   // y sigue viaje, ya degradado
   endfunction
endclass

demotar_pslverr c = new();
uvm_report_cb::add(null, c);          // null = todo el testbench; o un componente
```

- El catcher se mete **antes** del reporte: ve cada mensaje y puede cambiarle la
  severidad, el ID, el texto o la acción
- `THROW` lo deja seguir ya modificado; `CAUGHT` lo hace desaparecer
- Y la diferencia que importa: el resumen imprime *Number of demoted UVM_ERROR
  reports : 1*. **El apagón deja rastro**, que es lo que `UVM_NO_ACTION` no hace

Note:
Es la respuesta correcta a la slide anterior, y la diferencia es de honestidad,
no de sintaxis. `UVM_NO_ACTION` sobre el scoreboard apaga el error y el log queda
idéntico al de un testbench sano: nadie que lea ese log se entera. El catcher
degrada **ese** mensaje, deja pasar todos los demás, y encima lo cuenta en una
línea propia del *UVM Report catcher Summary*. Un revisor que abre el log ve que hubo un
error y que alguien decidió que estaba bien.
Cuándo se usa de verdad: en los tests negativos, que son la mitad de un plan de
verificación serio. Escribir en un registro de sólo lectura tiene que dar
`PSLVERR`; el test que lo prueba **espera** el error, y sin catcher ese test no
puede dar verde nunca. Es exactamente el caso del capstone.
El detalle de implementación que sorprende: un catcher es un `uvm_callback`, o
sea la misma pieza de los callbacks del día 6. Por eso se registra con
`uvm_report_cb::add` y no con un `set_` del componente.
Y la trampa: si el catcher es demasiado ancho —por severidad y nada más— apagaste
todos los errores del testbench con más ceremonia que `UVM_NO_ACTION`. El
`get_id()` del `if` no es opcional.

---

## Reporting

#### *Resumen de la unidad*

- Dos perillas, y no se cruzan: **verbosidad** filtra `` `uvm_info ``; **actions**
  decide qué se hace con warnings, errores y fatales
- Las dos se pueden fijar por componente o por rama, en `end_of_elaboration_phase`
- Y hay una tercera para el error **esperado**: el `uvm_report_catcher` lo demota
  y lo deja contado en el resumen, en vez de apagarlo sin dejar rastro
- Con eso los mensajes de debug se escriben una vez y se quedan puestos para
  siempre — que es lo único que hace el debug barato
- Y llega acá, al final del día 3, a propósito: es la herramienta con la que se
  debuggean los ejercicios de los días 4 y 5 — el del día 5 se resuelve
  **subiendo la verbosidad**, y no hay otra forma de encontrarlo

Note:
Cerrar el día volviendo al 47 %: de todo lo que se vio hoy —tests, components,
fases, env— ésta es la sección que se usa **todos los días**, y la única que se
nota cuando falta. Un testbench sin reporting funciona igual; debuggearlo cuesta
el doble.
La pregunta de control, que además es la 6 del repaso: *"bajé el techo de
verbosidad y el `` `uvm_error `` sigue apareciendo, ¿por qué?"*. Si el grupo la
contesta sin dudar, la sección cerró.
Y el aviso para el ejercicio del día 5, que conviene dar ahora y no cuando estén
trabados: el bug no se ve en el log por defecto. Está impreso, en `UVM_HIGH`. El
que no se acuerde de esta sección va a leer el código media hora antes de subir
la verbosidad.
