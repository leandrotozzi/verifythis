<!-- Generado por tools/build.mjs desde slides/*quiz*.md. NO editar a mano:
     la pregunta se corrige en la slide y esto se regenera con `npm run build`.
     `npm run check` falla si quedo viejo. -->

# Banco de examen

Las **45 preguntas de repaso** del curso, sin la respuesta
marcada — que es lo único que separa un repaso en clase de un parcial. Salen de
las mismas `slides/*quiz*.md` que el deck, así que no hay dos versiones de una
pregunta.

La **clave está al final**, con el porqué de cada una: es lo que se necesita
para corregir sin volver a buscar la slide.

Cómo se usa, y qué evaluar en cada parcial: **[`para-docentes.md`](para-docentes.md)**.

> El curso es **CC BY 4.0**: se puede imprimir, cortar, reordenar y tomar como
> examen propio. Lo único que se pide es citar la fuente.

---

## Día 1 · 6 preguntas

**1. Tendencias**

Según el estudio de Wilson 2024, ¿en qué se le va la mayor parte del tiempo a un verificador?

- **a)** En escribir el testbench
- **b)** En debug
- **c)** En correr regresiones
- **d)** En escribir la especificación

**2. La spec de la ALU**

Mientras la VTALU está ejecutando una operación, ¿qué tienen que hacer `start` y los operandos?

- **a)** `start` baja enseguida; los operandos pueden cambiar
- **b)** Da igual: el DUT los registra en el primer flanco
- **c)** Los operandos tienen que cambiar en cada ciclo
- **d)** `start` se mantiene en 1 y los operandos estables hasta que sube `done`

**3. Cobertura funcional**

El test corre 1000 operaciones al azar y la cobertura de *código* da 100 %. ¿Qué te dice eso sobre la verificación?

- **a)** Que el DUT está verificado
- **b)** Muy poco: dice qué RTL se **ejecutó**, no qué escenarios de la **spec** pasaron
- **c)** Que el testbench no tiene bugs
- **d)** Que ya se puede cerrar el plan de verificación

**4. covergroup**

Declarás un `covergroup`, le hacés `new()`, corrés mil operaciones y el reporte da 0 %. ¿Qué es lo primero que hay que mirar?

- **a)** Que los bins estén mal definidos
- **b)** Que nadie esté llamando a `sample()`
- **c)** Que el DUT no esté respondiendo
- **d)** Que falten `ignore_bins`

**5. Interfaces y BFM**

¿Qué gana el testbench cuando el protocolo se mueve a un BFM?

- **a)** El resto del TB deja de hablar en señales y pasa a hablar en operaciones
- **b)** Simula más rápido
- **c)** Se puede sintetizar el testbench
- **d)** Se ahorra tener que declarar un `clk`

**6. clocking block**

¿Hacen falta los clocking blocks para escribir un testbench UVM sin races?

- **a)** Sí: sin clocking block, driver y DUT compiten siempre en el mismo flanco
- **b)** Sí, y además son parte de la librería UVM
- **c)** No: con NBA en el driver y disciplina de scheduler alcanza — son una abstracción opcional, útil sobre todo en agents reutilizables
- **d)** No, y por eso no conviene usarlos nunca

---

## Día 2 · 8 preguntas

**7. Handle y objeto**

`rectangle rectangle_h;` — después de esa línea, ¿cuántos objetos hay?

- **a)** Ninguno: `rectangle_h` vale `null` hasta que alguien llame a `new()`
- **b)** Uno, con `length` y `width` en 0
- **c)** Uno, a medio construir
- **d)** Depende de si la clase tiene constructor

**8. Polimorfismo**

Una variable de tipo `trago` guarda un objeto `fernet`. Si `servir()` no es `virtual`, ¿qué se ejecuta?

- **a)** El `servir()` de `fernet`
- **b)** Error de compilación
- **c)** El `servir()` de `trago`
- **d)** Los dos, primero el de la clase base

**9. Clases abstractas**

¿Qué gano usando una clase abstracta con métodos `pure virtual` en vez de una clase base cuyo método hace `$fatal`?

- **a)** Nada, es cuestión de estilo
- **b)** Que el error pasa de la simulación al compilador
- **c)** Que se puede instanciar la clase base
- **d)** Que los métodos se ejecutan más rápido

**10. Variables estáticas**

Instancio 10 objetos de una clase que tiene una variable `static`. ¿Cuántas copias hay en memoria?

- **a)** 10, una por objeto
- **b)** 0 hasta que alguien la escribe
- **c)** 1, compartida por todas las instancias
- **d)** Depende del simulador

**11. Métodos estáticos**

¿Por qué conviene declarar `protected` la variable estática y exponerla con métodos estáticos?

- **a)** Para poder cambiar la estructura de datos sin tocar a quien la usa
- **b)** Porque si no, no compila
- **c)** Para que ocupe menos memoria
- **d)** Porque UVM lo exige

**12. Clases paramétricas**

`bandeja#(fernet)` y `bandeja#(mojito)` tienen adentro una queue `static`. ¿Comparten la queue?

- **a)** Sí, `static` es una sola para todos
- **b)** Sí, salvo que se declare `protected`
- **c)** Depende de si se instancian o no
- **d)** No: cada especialización del parámetro es una clase distinta, con su propia queue

**13. El patrón factory**

¿Qué problema resuelve el patrón factory?

- **a)** Crear objetos más rápido
- **b)** Decidir en tiempo de ejecución qué subtipo construir, sin hardcodear el `new`
- **c)** Evitar tener que declarar clases
- **d)** Copiar objetos sin compartir el handle

**14. $cast**

¿Cuándo tiene éxito un `$cast(destino, origen)`?

- **a)** Siempre: convierte cualquier clase en cualquier otra
- **b)** Sólo entre clases sin herencia
- **c)** Sólo en tiempo de compilación
- **d)** Sólo si el objeto de `origen` es realmente de la clase de `destino` o de una derivada

---

## Día 3 · 7 preguntas

**15. `uvm_test`**

¿Qué te permite hacer `+UVM_TESTNAME=add_test` que antes no podías?

- **a)** Elegir el test sobre un testbench ya compilado, sin recompilar
- **b)** Correr más rápido la simulación
- **c)** Cambiar el DUT sin recompilar
- **d)** Bajar la verbosidad de los mensajes

**16. UVM Phases**

¿En qué orden recorre UVM la jerarquía en `build_phase` y en `connect_phase`?

- **a)** Las dos de arriba hacia abajo
- **b)** Las dos de abajo hacia arriba
- **c)** `build_phase` top-down, `connect_phase` bottom-up
- **d)** En el orden en que se declararon los componentes

**17. Objections**

¿Para qué sirve `raise_objection()` / `drop_objection()` en el `run_phase`?

- **a)** Para reportar errores del scoreboard
- **b)** Para mantener viva la simulación mientras el componente tiene trabajo
- **c)** Para sincronizar dos threads
- **d)** Para registrar la clase en la factory

**18. El env**

¿Qué le toca a cada uno: `uvm_env` y `uvm_test`?

- **a)** `env` genera el estímulo; `test` arma la estructura
- **b)** Los dos hacen lo mismo, `env` es opcional
- **c)** `env` corre el DUT; `test` corre el scoreboard
- **d)** `env` arma la estructura del TB; `test` define qué estímulo se aplica

**19. Factory override**

`set_type_override()` reemplaza `base_tester` por `add_tester`. ¿Cuándo hay que llamarlo?

- **a)** Antes de que corra el `build_phase` que crea el objeto
- **b)** En cualquier momento: la factory lo aplica retroactivamente
- **c)** Después del `connect_phase`
- **d)** Dentro del `run_phase` del tester

**20. Verbosidad**

El techo de verbosidad (`+UVM_VERBOSITY=UVM_HIGH`), ¿sobre qué macros actúa?

- **a)** Sobre las cuatro: info, warning, error y fatal
- **b)** Sólo sobre `` `uvm_info ``
- **c)** Sobre error y fatal solamente
- **d)** Sobre ninguna: sólo cambia el formato del mensaje

**21. Report actions**

Querés silenciar los `` `uvm_error `` de un scoreboard que otra persona está arreglando. ¿Dónde va el `set_report_severity_action_hier()`?

- **a)** En el `build_phase` del `env`
- **b)** En el `run_phase` del test
- **c)** En el constructor del scoreboard
- **d)** En el `end_of_elaboration_phase` del `env`

---

## Día 4 · 5 preguntas

**22. Observer Pattern**

En el patrón Observer, ¿qué sabe el objeto observado sobre sus observadores?

- **a)** Cuántos son y de qué tipo
- **b)** Sólo el primero que se suscribió
- **c)** Los conoce porque se los pasan en el constructor
- **d)** Nada: ni cuántos son, ni quiénes, ni qué hacen con el dato

**23. Analysis Ports**

Un `uvm_subscriber` necesita datos de dos analysis ports distintos. ¿Cómo se resuelve?

- **a)** Implementando dos veces el método `write()`
- **b)** Con una `uvm_tlm_analysis_fifo` para el segundo puerto
- **c)** Registrando el componente dos veces en la factory, una por puerto
- **d)** Conectando los dos puertos al mismo `analysis_export`

**24. Intra vs. inter thread**

Cuando el monitor publica y se ejecutan los `write()` de los subscribers, ¿cuántos threads intervienen?

- **a)** Uno por subscriber
- **b)** Dos: el del publicador y el del suscriptor
- **c)** Uno solo: es comunicación **intra**-thread, son llamadas a función
- **d)** Depende de la cantidad de subscribers

**25. Put y get ports**

El consumidor llama a `get()` y la `uvm_tlm_fifo` está vacía. ¿Qué pasa?

- **a)** Se bloquea hasta que el productor ponga un dato
- **b)** Devuelve 0 y sigue
- **c)** Error fatal de UVM
- **d)** Devuelve el último dato leído

**26. try_get()**

¿Y `try_get()` con la FIFO vacía?

- **a)** Se bloquea igual que `get()`
- **b)** Devuelve 1 con un dato basura
- **c)** Devuelve 0 inmediatamente, sin bloquear
- **d)** Espera un ciclo de reloj y reintenta

---

## Día 5 · 4 preguntas

**27. Copia profunda**

`obj1_h = obj2_h`. ¿Qué copié?

- **a)** Nada: los dos handles apuntan al mismo objeto
- **b)** Todos los campos de `obj2_h` a `obj1_h`
- **c)** Sólo los campos `rand`
- **d)** Una copia superficial del primer nivel

**28. super.do_copy()**

¿Por qué cada `do_copy()` de la jerarquía tiene que llamar a `super.do_copy()`?

- **a)** Porque UVM lo exige para registrar la clase
- **b)** Para que el objeto quede registrado en la factory
- **c)** Porque si no, los campos de las clases de arriba no se copian
- **d)** Para poder randomizar después de copiar

**29. clone()**

`clone()` devuelve un `uvm_object`. ¿Por qué se recomienda escribir además un `clone_me()`?

- **a)** Para encapsular el `$cast` en un solo lugar y no repetirlo en todo el TB
- **b)** Porque `clone()` no copia los datos
- **c)** Porque `clone()` está deprecado en IEEE 1800.2
- **d)** Para poder clonar componentes además de transacciones

**30. Constrained Random**

`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — ¿cada cuánto sale `A = 8'h00`?

- **a)** Un tercio de las veces: son tres entradas con el mismo peso
- **b)** La mitad: los bordes se reparten entre los dos
- **c)** Una vez cada 256: con `:=` el peso se aplica a **cada valor** del rango
- **d)** Nunca: `:=` sólo acepta valores sueltos, no rangos

---

## Día 6 · 10 preguntas

**31. is_active**

Un agent en `UVM_PASSIVE`, ¿qué construye su `build_phase`?

- **a)** Nada: un agent pasivo es una cáscara vacía
- **b)** Todo igual que uno activo, pero sin conectar el driver al sequencer
- **c)** Los monitores y los analysis ports; el sequencer y el driver quedan en `null`
- **d)** Sólo el sequencer, para poder recibir sequences de otro agent

**32. El handshake del driver**

El driver llama a `get_next_item()`, maneja las señales y se olvida del `item_done()`. ¿Qué pasa?

- **a)** Error de compilación: UVM exige el par completo
- **b)** El sequencer entrega el siguiente item igual, con un warning
- **c)** El item se descarta y el scoreboard reporta un mismatch
- **d)** La sequence se queda esperando en `finish_item()` y la simulación no avanza más

**33. Ámbito del config_db**

El `env` instancia dos agents y hace los dos `set()` con el ámbito `"*"`. ¿Qué recibe cada uno?

- **a)** Los dos fallan con `uvm_fatal`: el string `"config"` está duplicado
- **b)** Cada uno recibe el suyo, por orden de creación
- **c)** Los dos reciben el mismo objeto: el segundo `set()` pisa al primero
- **d)** El primero recibe su config y el segundo queda con `cfg == null`

**34. El sequencer**

`typedef uvm_sequencer #(command_transaction) sequencer;` compila sin tocar la transaction de las transactions. ¿Por qué?

- **a)** Porque está registrada en la factory con `` `uvm_object_utils ``
- **b)** Porque `uvm_sequencer` acepta cualquier `uvm_object`
- **c)** Porque el driver hace el `$cast` por dentro
- **d)** Porque `command_transaction` extiende `uvm_sequence_item`

**35. super.build_phase()**

En vez del config object, ponés `is_active` directo en el `uvm_config_db`. En este curso el agent arranca activo igual. ¿Por qué?

- **a)** Porque `is_active` es `protected` y el `config_db` no lo puede escribir
- **b)** Porque el `config_db` no acepta tipos enumerados
- **c)** Porque `is_active` se fija en el constructor y `build_phase` llega tarde
- **d)** Porque quien lo lee es el `build_phase` de `uvm_agent`, y nunca llamamos a `super.build_phase()`

**36. Object, no component**

¿Cuál es la diferencia práctica de que una `uvm_sequence` sea un `uvm_object` y no un `uvm_component`?

- **a)** Que no se puede registrar en la factory ni overridear
- **b)** Que se crea, corre y se tira: podés arrancar varias, una detrás de otra, sobre el mismo sequencer
- **c)** Que no puede tener campos `rand` ni constraints
- **d)** Que arranca sola al empezar la simulación, sin que nadie la llame

**37. start_item()**

`start_item(command)` acaba de volver. ¿Qué es lo que eso garantiza?

- **a)** Que el driver ya recibió el item y está manejando las señales
- **b)** Que el sequencer le dio el turno a esta sequence: nadie más le va a ganar el driver
- **c)** Que el `randomize()` ya se resolvió con las constraints de la clase
- **d)** Que el objection de la fase ya está levantado

**38. El camino de vuelta**

¿En qué momento `command.result` tiene un valor que se puede leer?

- **a)** Apenas volvió `start_item()`
- **b)** Cuando el `result_monitor` lo publica por su analysis port
- **c)** Cuando volvió `finish_item()`, porque el driver lo escribió antes de llamar a `item_done()`
- **d)** Nunca: para recibir una respuesta hay que usar el par REQ/RSP de `uvm_sequence #(REQ, RSP)`

**39. default_sequence**

Configurás una `default_sequence` por `uvm_config_db` y te olvidás del `set_automatic_phase_objection(1)`. ¿Qué pasa?

- **a)** `uvm_fatal` en `build_phase`: la sequence no encuentra el sequencer
- **b)** Corre igual: cuando hay `default_sequence`, el objection lo levanta el sequencer
- **c)** La `main_phase` termina en t=0 y el test pasa con 0 errores sin haber mandado un solo estímulo
- **d)** La simulación se cuelga esperando un objection que nadie baja

**40. Sub-sequences**

`full_sequence` arranca a sus hijas con `reset_seq.start(get_sequencer(), this)`. ¿Para qué está el segundo argumento?

- **a)** Para pasarle el sequencer, porque `get_sequencer()` sólo devuelve el tipo
- **b)** Para declarar a la hija sub-sequence de la madre: hereda su turno y su prioridad en la arbitración
- **c)** Para que la hija corra en un hilo aparte, en paralelo con la madre
- **d)** Para registrar a la hija en la factory con el nombre de la madre

---

## Día 7 · 5 preguntas

**41. Inmediatas y concurrentes**

¿Cuál es la diferencia de fondo entre `assert(x.randomize())` y `assert property (@(posedge clk) …)`?

- **a)** Ninguna: la segunda es azúcar sintáctico de la primera
- **b)** La primera se puede apagar por línea de comandos y la segunda no
- **c)** La primera es una **sentencia** que corre cuando el hilo pasa por ahí; la segunda es una **declaración con reloj** que se evalúa en cada flanco, sola
- **d)** La primera sólo vale adentro de una clase y la segunda sólo adentro de un módulo

**42. `|->` contra `|=>`**

El `done` del VTALU sale de un `always_ff`. ¿Qué implicación va en `start |?? done`?

- **a)** `|->`, porque el antecedente y el consecuente son de la misma transacción
- **b)** `|=>`, porque lo que se escribe con `<=` en el flanco *n* recién se lee en el *n+1*
- **c)** Cualquiera de las dos: la diferencia es de estilo
- **d)** Ninguna: para señales registradas hay que usar `$past()`

**43. El flanco de muestreo**

Todas las properties del VTALU muestreadas en `@(posedge clk)` dan 185 errores sobre 1000 operaciones, y el DUT está sano. ¿Por qué?

- **a)** Falta el `disable iff (!reset_n)`
- **b)** El `posedge` es demasiado rápido: hay que dividir el reloj
- **c)** La BFM escribe el estímulo **en el `negedge`**, y en dos `no_op` seguidas `start` baja y vuelve a subir entre dos `posedge`: el muestreo no lo ve bajar
- **d)** Los covergroups y las assertions no pueden compartir el mismo reloj

**44. La assertion que no chequea nada**

Una property `assert` reporta 0 fallas durante toda la regresión. ¿Qué se sabe?

- **a)** Que la regla que describe se cumple
- **b)** Que el DUT está libre de bugs de protocolo
- **c)** Nada todavía: puede que su antecedente no haya ocurrido nunca, o que falte `--assert` y ni siquiera se esté evaluando
- **d)** Que la property tiene un `disable iff` mal escrito

**45. Assertion o scoreboard**

El DUT devuelve el `result` correcto pero baja `done` un ciclo antes de lo que dice la especificación. ¿Quién lo caza?

- **a)** El scoreboard, cuando compare el resultado
- **b)** La cobertura funcional, porque el bin de `done` queda vacío
- **c)** Una assertion en la interface: es un bug de **protocolo**, y el monitor ya borró el tiempo antes de que la transaction llegue al scoreboard
- **d)** El `uvm_fatal` del `command_monitor`, que dejaría de ver comandos

---

## Clave

| # | Día | Tema | Correcta | Por qué |
|--:|:--:|:--|:--:|:--|
| 1 | 1 | Tendencias | **b** | **En debug** — el 47 % del tiempo del verificador se va ahí. Por eso el curso le dedica una sección entera al reporting: un scoreboard que sólo dice "falló" te deja justo en ese 47 %. |
| 2 | 1 | La spec de la ALU | **d** | **Estables hasta `done`** — es el protocolo del DUT, y es exactamente el motivo por el que existe el BFM: encapsular esa regla en un solo lugar para que ningún test se la olvide. |
| 3 | 1 | Cobertura funcional | **b** | **Muy poco** — la cobertura de código mide el DUT; la funcional mide la spec. Una feature que el diseñador nunca escribió da 100 % de líneas y 0 % de lo que importa, y el reporte no te lo va a decir. |
| 4 | 1 | covergroup | **b** | **El `sample()`** — el covergroup no se muestrea solo: alguien tiene que llamarlo, en el flanco o cuando llega una transacción. Sin esa llamada el código compila, corre, y el reporte da 0 sin una sola advertencia. |
| 5 | 1 | Interfaces y BFM | **a** | **Deja de hablar en señales** — el BFM traduce *una operación* a *un handshake de señales*. El tester, el scoreboard y el coverage no vuelven a tocar un cable: es el primer paso hacia UVM. |
| 6 | 1 | clocking block | **c** | **No hacen falta, y conviene usarlos igual** — son de **SystemVerilog**, no de UVM. Lo que evita la race es entender el scheduler: un driver que maneja con `<=` contra un DUT que registra con `<=` ya es determinista. El clocking block no reemplaza ese entendimiento, lo **encapsula** — y ahí es donde paga: agents reutilizables, VIP, gate-level y protocolos con setup/hold en la spec. |
| 7 | 2 | Handle y objeto | **a** | **Ninguno** — declarar un handle no reserva nada. Ahí está la diferencia con una `struct`, que el simulador reserva apenas la ve. Y usar el handle antes del `new()` no falla al compilar: revienta en medio de la simulación. |
| 8 | 2 | Polimorfismo | **c** | **El de `trago`** — sin `virtual`, SystemVerilog mira el **tipo de la variable**, no el del objeto. Es literal lo que imprime `code/u3/polimorfismo/01-sin-virtual`: *"A generic trago cannot be served"*. |
| 9 | 2 | Clases abstractas | **b** | **El error pasa al compilador** — con `$fatal` te enterás a mitad de la simulación de que faltaba un override. Con `pure virtual` no compila. Atajar antes siempre es más barato. |
| 10 | 2 | Variables estáticas | **c** | **Una sola** — y existe aunque no instancies ningún objeto. Eso es lo que la hace útil para datos globales del TB, y lo que la hace peligrosa si la dejás pública. |
| 11 | 2 | Métodos estáticos | **a** | **Para poder cambiarla después** — si la cola está a la vista, el día que la cambiás por otra estructura tenés que salir a corregir todos los lugares que la tocaban. Encapsular es poder cambiar de opinión. |
| 12 | 2 | Clases paramétricas | **d** | **No la comparten** — SystemVerilog genera **una clase por combinación de parámetros**. `static` es único dentro de cada una de esas clases, no entre todas. UVM se apoya en esto todo el tiempo. |
| 13 | 2 | El patrón factory | **b** | **Decidir el subtipo en runtime** — le pedís un objeto a la fábrica y ella decide cuál. Es la pieza que después te va a dejar cambiar el estímulo de un test entero sin tocar el código del `env`. |
| 14 | 2 | $cast | **d** | **Sólo si el objeto lo permite** — `$cast` chequea **en runtime** y devuelve 0 si no da. Por eso la factory de UVM es más cómoda que el ejemplo de los animales: devuelve el tipo correcto y te ahorra el casteo. |
| 15 | 3 | `uvm_test` | **a** | **Elegir el test sin recompilar** — UVM lee ese plusarg y le pide el test a la **factory** por nombre. Es la diferencia entre 1000 tests × 5 minutos de compilación y una sola compilación. |
| 16 | 3 | UVM Phases | **c** | **Build top-down, connect bottom-up** — y tiene sentido: no podés conectar un componente que todavía no existe, así que primero se construye toda la jerarquía y recién después se conecta. |
| 17 | 3 | Objections | **b** | **Para que la fase no termine antes** — todos los `run_phase` corren en paralelo, cada uno en su thread, y la fase termina cuando **cae la última objection**. Sin levantarla, la simulación se te termina en el tiempo 0. |
| 18 | 3 | El env | **d** | **Estructura vs. estímulo** — cada clase hace **una sola cosa bien**. Por eso el `env` casi siempre tiene sólo `build_phase` y `connect_phase`, y el test casi siempre tiene sólo un override de la factory. |
| 19 | 3 | Factory override | **a** | **Antes del `build_phase`** — la factory decide qué construir **en el momento del `create()`**. Si el override llega tarde, el `env` ya instanció la clase base y no hace nada. |
| 20 | 3 | Verbosidad | **b** | **Sólo sobre `` `uvm_info ``** — warnings, errores y fatales son **inmunes** al techo de verbosidad, y está bien que así sea: nadie quiere apagar un error sin querer. Para esos hace falta el mecanismo de *actions*. |
| 21 | 3 | Report actions | **d** | **En `end_of_elaboration_phase`** — tiene que ser **después** de que la jerarquía esté construida (si no, el componente todavía no existe) y **antes** de que arranque la simulación. Esa fase es exactamente esa ventana. |
| 22 | 4 | Observer Pattern | **d** | **No sabe nada** — y esa ignorancia es la gracia. Agregar un cuarto subscriber no obliga a tocar una línea del que publica. |
| 23 | 4 | Analysis Ports | **b** | **Con una `uvm_tlm_analysis_fifo`** — un `uvm_subscriber` tiene un solo `write()`, así que sólo puede escuchar un puerto. La FIFO da un `analysis_export` de un lado y un `try_get()` del otro. Es lo que hace el scoreboard del VTALU. |
| 24 | 4 | Intra vs. inter thread | **c** | **Uno solo** — `write()` es una `function`, no una `task`: no consume tiempo y corre en el thread del que publica. Justamente por eso hace falta **otro** mecanismo (put/get + FIFO) para hablar entre threads. |
| 25 | 4 | Put y get ports | **a** | **Se bloquea** — `get()` es bloqueante, y por eso se declara `task` y no `function`. Esa es toda la sincronización: no hace falta un handshake de señales a mano. |
| 26 | 4 | try_get() | **c** | **Devuelve 0 y sigue** — es la versión no bloqueante, y por eso puede ser una `function`. Fijate que el scoreboard la usa en un `do ... while` para saltear los `no_op` y los `rst_op`. |
| 27 | 5 | Copia profunda | **a** | **Nada** — no hay copia, hay un segundo nombre para el mismo objeto. Si lo modificás por un handle, el otro lo ve. De ahí sale la regla del *MOOCOW*: si vas a modificar, copiá primero. |
| 28 | 5 | super.do_copy() | **c** | **Si no, se pierden los campos de arriba** — es el mismo problema que `convert2string()`: el día que alguien mete un nivel nuevo en el medio, el método deja de ver la mitad de los datos y no te avisa nadie. |
| 29 | 5 | clone() | **a** | **Para no repetir el `$cast`** — sin él, cada lugar que clona termina escribiendo su propio casteo. Es la misma idea de siempre: si lo vas a repetir, encapsulalo. |
| 30 | 5 | Constrained Random | **c** | **1 de cada 256** — `:=` le da peso 1 a *cada uno* de los 254 valores del medio, así que el rango pesa 254 contra 1 y 1 de los bordes. Para repartir el peso *dentro* del rango va `:/`. Las dos formas compilan y corren: la diferencia sólo aparece en la cobertura que no sube. |
| 31 | 6 | is_active | **c** | **Los monitores, siempre** — mirar nunca es opcional: un agent pasivo sigue alimentando scoreboard y cobertura. Lo que se saltea es lo que *maneja* la interface, porque ahí ya hay otro manejándola. |
| 32 | 6 | El handshake del driver | **d** | **Se cuelga, y sin decir nada** — es el error clásico de la primera semana, y el síntoma engaña: no hay error ni warning, el tiempo deja de avanzar y el objection nunca se baja. `get_next_item()` es un préstamo; `item_done()` es devolverlo. |
| 33 | 6 | Ámbito del config_db | **c** | **Los dos reciben lo mismo** — el `uvm_config_db` no empareja por orden ni por tipo: empareja por **ruta**. Con `"*"` las dos entradas describen a los mismos componentes, así que la última gana. El ámbito es una ruta en el árbol, no una etiqueta. |
| 34 | 6 | El sequencer | **d** | **Por la clase base que elegimos en transactions** — `uvm_sequencer #(T)` exige que `T` derive de `uvm_sequence_item`. Si aquel día la transaction hubiera extendido `uvm_transaction` a secas, este `typedef` hoy no compilaría. Una decisión de una sección habilitando el siguiente. |
| 35 | 6 | super.build_phase() | **d** | **Ese mecanismo está apagado** — `uvm_agent::build_phase` busca `is_active` en el resource pool (está en `code/.uvm/src/comps/uvm_agent.svh`, se puede abrir). Sin `super.build_phase()` esa línea no corre nunca. Las dos formas son válidas; lo que no funciona es la mitad de cada una. |
| 36 | 6 | Object, no component | **b** | **Se crea, corre y se tira** — un componente se construye una vez en `build_phase` y vive hasta el final. Por eso el estímulo no puede ser un componente: cambia test a test, y a veces dentro del mismo test. De ahí sale también que se pueda configurar entre el `create()` y el `start()`, como hace `full_seq.count = 200`. |
| 37 | 6 | start_item() | **b** | **Tenés el turno, todavía no entregaste nada** — y por eso el `randomize()` va *después*: es el último momento posible para elegir los valores, cuando ya sabés en qué estado está el DUT. Eso es la randomización tardía, y es donde se enganchan `pre_do()` y `mid_do()`. |
| 38 | 6 | El camino de vuelta | **c** | **Después de `finish_item()`** — no hay ningún canal de vuelta: hay un handle compartido y un acuerdo entre las dos partes. El par REQ/RSP existe y es el mecanismo formal, pero casi nadie lo usa: escribir el resultado en el request alcanza. Esto es lo que hace posible Fibonacci. |
| 39 | 6 | default_sequence | **c** | **Pasa en cero segundos, y miente** — una fase sin objection termina en cuanto arranca. Es el mismo tipo de bug que el `new()` que se come el override: no rompe, engaña. Y en una regresión de mil tests, el que pasa en cero segundos no lo mira nadie. |
| 40 | 6 | Sub-sequences | **b** | **Declara la relación madre-hija** — sin él, el sequencer trata a las dos como sequences independientes y compiten por el turno. Con él, la hija hereda el contexto. Y para el paralelo no alcanza con eso: hace falta un `fork` / `join` alrededor de los `start()`. |
| 41 | 7 | Inmediatas y concurrentes | **c** | **Sentencia contra declaración** — la inmediata es a un `if` lo que la concurrente es a un `always_ff`: una se ejecuta, la otra se instancia. Por eso sólo la concurrente puede describir algo que dura varios ciclos. |
| 42 | 7 | `\|->` contra `\|=>` | **b** | **`\|=>` cuando el consecuente sale de un `<=`** — y la regla operativa es mirar el RTL, no la property: si el consecuente sale de un `assign`, va `\|->`. Equivocarse acá casi nunca da un error: da una property que pasa siempre. |
| 43 | 7 | El flanco de muestreo | **c** | **Una assertion vale lo que vale su muestreo** — el estímulo se muestrea donde el estímulo se escribe. Estímulo en `negedge`, respuesta del DUT en `posedge`: cero errores. Con un solo reloj no hay forma. |
| 44 | 7 | La assertion que no chequea nada | **c** | **Cero fallas y cero evaluaciones se ven igual** — por eso toda assertion va con su `cover property`: es el único chequeo del chequeo. En la sección, `c_mult_3ciclos` se queda en 0 y delata que la latencia real son cuatro flancos, no tres. |
| 45 | 7 | Assertion o scoreboard | **c** | **Protocolo → assertion. Datos → scoreboard** — y no es una preferencia: para cuando la transaction llega al scoreboard, el protocolo ya no está. Escribir el chequeo ahí sería reconstruir a mano el tiempo que el monitor acaba de borrar. |
