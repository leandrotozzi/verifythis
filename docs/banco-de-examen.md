<!-- Generado por tools/build.mjs desde slides/*quiz*.md. NO editar a mano:
     la pregunta se corrige en la slide y esto se regenera con `npm run build`.
     `npm run check` falla si quedo viejo. -->

# Banco de examen

Las **58 preguntas de repaso** del curso, sin la respuesta
marcada — que es lo único que separa un repaso en clase de un parcial. Salen de
las mismas `slides/*quiz*.md` que el deck, así que no hay dos versiones de una
pregunta.

La **clave está al final**, con el porqué de cada una: es lo que se necesita
para corregir sin volver a buscar la slide.

Cómo se usa, y qué evaluar en cada parcial: **[`para-docentes.md`](para-docentes.md)**.

> El curso es **CC BY 4.0**: se puede imprimir, cortar, reordenar y tomar como
> examen propio. Lo único que se pide es citar la fuente.

---

## Día 1 · 7 preguntas

**1. Tendencias**

Según el estudio de Wilson 2024, ¿en qué se le va la mayor parte del tiempo a un verificador?

- **a)** En escribir el testbench
- **b)** En debug
- **c)** En correr regresiones
- **d)** En escribir la especificación

**2. La spec de la ALU**

Mientras la VTALU está ejecutando una operación, ¿qué tienen que hacer `start` y los operandos?

- **a)** `start` baja enseguida: es un pulso de arranque, y el DUT ya latcheó todo
- **b)** Da igual: el DUT los registra en el primer flanco
- **c)** Los operandos tienen que cambiar en cada ciclo
- **d)** `start` en 1 y los operandos quietos hasta que sube `done`

**3. Cobertura funcional**

El test corre 1000 operaciones al azar y la cobertura de *código* da 100 %. ¿Qué te dice eso sobre la verificación?

- **a)** Que el DUT está verificado y el plan de verificación se puede cerrar
- **b)** Muy poco: mide el RTL que se ejecutó, no la spec
- **c)** Que el testbench no tiene bugs
- **d)** Que faltan pocos escenarios: el 100 % ya recorrió el diseño entero

**4. covergroup**

Declarás un `covergroup`, le hacés `new()`, corrés mil operaciones y el reporte da 0 %. ¿Qué es lo primero que hay que mirar?

- **a)** Que los bins estén mal definidos y no matcheen ningún valor
- **b)** Que nadie esté llamando a `sample()`
- **c)** Que el DUT no esté respondiendo
- **d)** Que falten `ignore_bins`

**5. Interfaces y BFM**

¿Qué gana el testbench cuando el protocolo se mueve a un BFM?

- **a)** Deja de hablar en señales y pasa a hablar en operaciones
- **b)** Simula más rápido: una tarea del BFM le cuesta menos al simulador que mover cables
- **c)** Se puede sintetizar el testbench
- **d)** Se ahorra tener que declarar un `clk`

**6. El plan de verificación**

En el plan de verificación, ¿qué va en la columna *Medida*?

- **a)** Cuánto tarda el escenario en correr, para poder estimar la regresión
- **b)** El nombre del archivo del testbench que cubre esa fila
- **c)** Qué bin se llena cuando el escenario pasa
- **d)** Cuántas veces hay que correr el test para darlo por cubierto

**7. clocking block**

¿Hacen falta los clocking blocks para escribir un testbench UVM sin races?

- **a)** Sí: sin clocking block, driver y DUT compiten siempre en el mismo flanco
- **b)** Sí, y además son parte de la librería UVM
- **c)** No: alcanza con NBA en el driver y disciplina de scheduler
- **d)** No: los reemplaza el `uvm_driver`, que ya muestrea en la región correcta

---

## Día 2 · 8 preguntas

**8. Handle y objeto**

`rectangle rectangle_h;` — después de esa línea, ¿cuántos objetos hay?

- **a)** Ninguno: `rectangle_h` vale `null` hasta que alguien llame a `new()`
- **b)** Uno, con `length` y `width` en 0
- **c)** Uno a medio construir: los campos existen pero el constructor no corrió
- **d)** Depende de si la clase tiene constructor

**9. Polimorfismo**

Una variable de tipo `trago` guarda un objeto `fernet`. Si `servir()` no es `virtual`, ¿qué se ejecuta?

- **a)** El `servir()` de `fernet`
- **b)** Error de compilación
- **c)** El `servir()` de `trago`
- **d)** Los dos, primero el de la clase base

**10. Clases abstractas**

¿Qué gano usando una clase abstracta con métodos `pure virtual` en vez de una clase base cuyo método hace `$fatal`?

- **a)** Nada, es cuestión de estilo
- **b)** Que el error pasa de la simulación al compilador
- **c)** Que se puede instanciar la clase base
- **d)** Que el simulador puede elegir el override más específico en tiempo de ejecución

**11. Variables estáticas**

Instancio 10 objetos de una clase que tiene una variable `static`. ¿Cuántas copias hay en memoria?

- **a)** 10, una por objeto
- **b)** 0 hasta que alguien la escribe: la memoria se reserva en el primer acceso
- **c)** 1, compartida por todas las instancias
- **d)** Depende del simulador

**12. Métodos estáticos**

¿Por qué conviene declarar `protected` la variable estática y exponerla con métodos estáticos?

- **a)** Para poder cambiar la estructura de datos sin tocar a quien la usa
- **b)** Porque una `static` sin `protected` se reserva una vez por instancia
- **c)** Para que ocupe menos memoria
- **d)** Porque UVM lo exige

**13. Clases paramétricas**

`bandeja#(fernet)` y `bandeja#(mojito)` tienen adentro una queue `static`. ¿Comparten la queue?

- **a)** Sí, `static` es una sola para todos
- **b)** Sí: el parámetro cambia el tipo de los métodos, no el almacenamiento estático
- **c)** Depende de si se instancian o no
- **d)** No: cada especialización es una clase distinta, con su propia queue

**14. El patrón factory**

¿Qué problema resuelve el patrón factory?

- **a)** Crear objetos más rápido
- **b)** Decidir en tiempo de ejecución qué subtipo construir
- **c)** Evitar tener que declarar clases
- **d)** Centralizar los `new()` en una sola clase, para poder contarlos y liberarlos

**15. $cast**

¿Cuándo tiene éxito un `$cast(destino, origen)`?

- **a)** Siempre: convierte cualquier clase en cualquier otra
- **b)** Sólo entre clases sin herencia
- **c)** Cuando las dos clases tienen los mismos campos, aunque no estén emparentadas
- **d)** Sólo si el objeto de `origen` es de la clase de `destino` o de una derivada

---

## Día 3 · 7 preguntas

**16. `uvm_test`**

¿Qué te permite hacer `+UVM_TESTNAME=add_test` que antes no podías?

- **a)** Elegir el test sobre un testbench ya compilado
- **b)** Correr más rápido la simulación
- **c)** Cambiar el DUT sin recompilar: UVM vuelve a elaborar al arrancar
- **d)** Bajar la verbosidad de los mensajes

**17. UVM Phases**

¿En qué orden recorre UVM la jerarquía en `build_phase` y en `connect_phase`?

- **a)** Las dos de arriba hacia abajo
- **b)** Las dos de abajo hacia arriba
- **c)** `build_phase` top-down, `connect_phase` bottom-up
- **d)** En el orden en que se declararon los componentes, de arriba hacia abajo

**18. Objections**

¿Para qué sirve `raise_objection()` / `drop_objection()` en el `run_phase`?

- **a)** Para reportar errores del scoreboard
- **b)** Para mantener viva la simulación mientras hay trabajo
- **c)** Para sincronizar dos threads
- **d)** Para que las `run_phase` de todos los componentes arranquen a la vez

**19. El env**

¿Qué le toca a cada uno: `uvm_env` y `uvm_test`?

- **a)** `env` genera el estímulo; `test` arma la estructura
- **b)** Los dos hacen lo mismo, `env` es opcional
- **c)** `env` corre el DUT; `test` corre el scoreboard
- **d)** `env` arma la estructura; `test` elige el estímulo

**20. Factory override**

`set_type_override()` reemplaza `base_tester` por `add_tester`. ¿Cuándo hay que llamarlo?

- **a)** Antes de que corra el `build_phase` que crea el objeto
- **b)** En cualquier momento: la factory lo aplica retroactivamente a lo ya creado
- **c)** Después del `connect_phase`
- **d)** Dentro del `run_phase` del tester

**21. Verbosidad**

El techo de verbosidad (`+UVM_VERBOSITY=UVM_HIGH`), ¿sobre qué macros actúa?

- **a)** Sobre las cuatro: info, warning, error y fatal
- **b)** Sólo sobre `` `uvm_info ``
- **c)** Sobre error y fatal solamente
- **d)** Sobre ninguna: sólo cambia el formato del mensaje

**22. Report actions**

Querés silenciar los `` `uvm_error `` de un scoreboard que otra persona está arreglando. ¿Dónde va el `set_report_severity_action_hier()`?

- **a)** En el `build_phase` del `env`
- **b)** En el `run_phase` del test, antes de levantar el objection
- **c)** En el constructor del scoreboard
- **d)** En el `end_of_elaboration_phase` del `env`

---

## Día 4 · 5 preguntas

**23. Observer Pattern**

En el patrón Observer, ¿qué sabe el objeto observado sobre sus observadores?

- **a)** Cuántos son y de qué tipo
- **b)** Sólo el primero que se suscribió
- **c)** Los conoce porque se los pasan en el constructor, uno por uno
- **d)** Nada: ni cuántos son, ni quiénes son

**24. Analysis Ports**

Un `uvm_subscriber` necesita datos de dos analysis ports distintos. ¿Cómo se resuelve?

- **a)** Implementando dos veces el método `write()`
- **b)** Con una `uvm_tlm_analysis_fifo` para el segundo puerto
- **c)** Registrando el componente dos veces en la factory, una por puerto
- **d)** Conectando los dos puertos al mismo `analysis_export`

**25. Intra vs. inter thread**

Cuando el monitor publica y se ejecutan los `write()` de los subscribers, ¿cuántos threads intervienen?

- **a)** Uno por subscriber
- **b)** Dos: el del publicador y el del suscriptor
- **c)** Uno solo: `write()` es una llamada a función
- **d)** Uno por subscriber más el del monitor, y UVM los sincroniza al final del delta

**26. Put y get ports**

El consumidor llama a `get()` y la `uvm_tlm_fifo` está vacía. ¿Qué pasa?

- **a)** Se bloquea hasta que el productor ponga un dato
- **b)** Devuelve 0 y sigue
- **c)** Error fatal de UVM
- **d)** Devuelve el último dato leído, que sigue en la FIFO hasta que lo pisen

**27. try_get()**

¿Y `try_get()` con la FIFO vacía?

- **a)** Se bloquea igual que `get()`
- **b)** Devuelve 1 con un dato basura
- **c)** Devuelve 0 inmediatamente, sin bloquear
- **d)** Espera un ciclo de reloj y reintenta, hasta el timeout de la fase

---

## Día 5 · 8 preguntas

**28. Copia profunda**

`obj1_h = obj2_h`. ¿Qué copié?

- **a)** Nada: los dos handles apuntan al mismo objeto
- **b)** Todos los campos de `obj2_h` a `obj1_h`
- **c)** Sólo los campos `rand`
- **d)** Una copia superficial: el primer nivel se copia y los handles de adentro se comparten

**29. super.do_copy()**

¿Por qué cada `do_copy()` de la jerarquía tiene que llamar a `super.do_copy()`?

- **a)** Porque UVM lo exige para registrar la clase
- **b)** Para que el objeto quede registrado en la factory
- **c)** Porque si no, los campos de las clases de arriba no se copian
- **d)** Porque `do_copy()` es `pure virtual` y la clase base no tiene implementación

**30. clone()**

`clone()` devuelve un `uvm_object`. ¿Por qué se recomienda escribir además un `clone_me()`?

- **a)** Para encapsular el `$cast` en un solo lugar
- **b)** Porque `clone()` no copia los datos
- **c)** Porque `clone()` está deprecado en IEEE 1800.2 y lo reemplaza `copy()`
- **d)** Para poder clonar componentes además de transacciones

**31. `dist`: `:=` contra `:/`**

`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — ¿cada cuánto sale `A = 8'h00`?

- **a)** Un tercio de las veces: son tres entradas con el mismo peso
- **b)** La mitad: los bordes se reparten entre los dos
- **c)** Una vez cada 256: con `:=` el peso va a **cada valor**
- **d)** Nunca: `:=` sólo acepta valores sueltos, no rangos, y el rango se descarta

**32. `randomize() with {}`**

`cmd.randomize() with { A == 8'hFF; }` — ¿qué pasa con las constraints que la clase ya tenía?

- **a)** Se reemplazan: para esa llamada vale sólo lo que está entre las llaves
- **b)** Se suman: hay que satisfacer las dos
- **c)** Quedan apagadas hasta el próximo `randomize()` sin `with`
- **d)** Depende del orden de declaración: gana la que está más abajo en el archivo

**33. constraint_mode()**

`randomize() with { A == 8'hFF; }` sobre un campo que la clase reparte con `dist` devuelve 0 tres de cada cuatro veces. ¿Cuál es el rodeo?

- **a)** Reintentar en un `do ... while` hasta que devuelva 1
- **b)** `constraint_mode(0)` sobre la constraint del `dist`, para ese objeto
- **c)** Subir el peso del bin `8'hFF` en el `dist` de la clase
- **d)** `rand_mode(0)` sobre el campo: saca el `dist` de la ecuación y deja mandar al `with`

**34. rand_mode()**

¿Qué hace `cmd.A.rand_mode(0)`?

- **a)** Apaga todas las constraints que mencionan ese campo
- **b)** Saca el campo del sorteo y le deja el valor que tenía
- **c)** Lo randomiza una sola vez y después lo congela
- **d)** Hace que el solver lo resuelva último, después de todos los demás campos

**35. El orden de resolución**

`rand bit es_reset; rand byte unsigned A;` con `constraint c { es_reset -> A == 8'h00; }`. ¿Cada cuánto sale `es_reset = 1`?

- **a)** La mitad de las veces: es un bit `rand` y nada lo prohíbe
- **b)** Nunca: la implicación lo fuerza a 0
- **c)** 1 de cada 257: el solver sortea entre las **soluciones**
- **d)** Depende de la semilla, y con suficientes corridas promedia la mitad

---

## Día 6 · 10 preguntas

**36. is_active**

Un agent en `UVM_PASSIVE`, ¿qué construye su `build_phase`?

- **a)** Nada: un agent pasivo es una cáscara vacía
- **b)** Todo igual que uno activo, pero sin conectar el driver al sequencer
- **c)** Los monitores y los analysis ports; el driver y el sequencer, no
- **d)** Sólo el sequencer, para poder recibir sequences de otro agent del mismo env

**37. El handshake del driver**

El driver llama a `get_next_item()`, maneja las señales y se olvida del `item_done()`. ¿Qué pasa?

- **a)** Error de compilación: UVM exige el par completo
- **b)** El sequencer entrega el siguiente item igual, con un warning
- **c)** El item se descarta y el scoreboard reporta un mismatch en la comparación siguiente
- **d)** La sequence se queda esperando en `finish_item()` y no avanza más

**38. Ámbito del config_db**

El `env` instancia dos agents y hace los dos `set()` con el ámbito `"*"`. ¿Qué recibe cada uno?

- **a)** Los dos fallan con `uvm_fatal`: el string `"config"` está duplicado
- **b)** Cada uno recibe el suyo, por orden de creación
- **c)** Los dos reciben el mismo: el segundo `set()` pisa al primero
- **d)** El primero recibe su config y el segundo queda con `cfg == null`

**39. El sequencer**

`typedef uvm_sequencer #(command_transaction) sequencer;` compila sin tocar la transaction de las transactions. ¿Por qué?

- **a)** Porque está registrada en la factory con `` `uvm_object_utils ``
- **b)** Porque `uvm_sequencer` acepta cualquier `uvm_object`
- **c)** Porque el driver hace el `$cast` por dentro
- **d)** Porque `command_transaction` extiende `uvm_sequence_item`

**40. super.build_phase()**

En vez del config object, ponés `is_active` directo en el `uvm_config_db`. En este curso el agent arranca activo igual. ¿Por qué?

- **a)** Porque `is_active` es `protected` y el `config_db` no lo puede escribir
- **b)** Porque el `config_db` no acepta tipos enumerados, sólo `int` y `string`
- **c)** Porque `is_active` se fija en el constructor y `build_phase` llega tarde
- **d)** Porque quien lo lee es `uvm_agent::build_phase`, y nadie llama a `super`

**41. Object, no component**

¿Cuál es la diferencia práctica de que una `uvm_sequence` sea un `uvm_object` y no un `uvm_component`?

- **a)** Que no se puede registrar en la factory ni overridear
- **b)** Que se crea, corre y se tira
- **c)** Que no puede tener campos `rand` ni constraints
- **d)** Que UVM la construye en `build_phase`, como a cualquier otra clase del árbol

**42. start_item()**

`start_item(command)` acaba de volver. ¿Qué es lo que eso garantiza?

- **a)** Que el driver ya recibió el item y está manejando las señales
- **b)** Que el sequencer le dio el turno a esta sequence
- **c)** Que el `randomize()` ya se resolvió con las constraints de la clase
- **d)** Que el objection de la fase ya está levantado por el sequencer

**43. El camino de vuelta**

¿En qué momento `command.result` tiene un valor que se puede leer?

- **a)** Apenas volvió `start_item()`
- **b)** Cuando el `result_monitor` lo publica por su analysis port
- **c)** Cuando volvió `finish_item()`, porque el driver lo escribió antes de llamar a `item_done()`
- **d)** Nunca: para recibir una respuesta hay que usar el par REQ/RSP de `uvm_sequence #(REQ, RSP)`

**44. default_sequence**

Configurás una `default_sequence` por `uvm_config_db` y te olvidás del `set_automatic_phase_objection(1)`. ¿Qué pasa?

- **a)** `uvm_fatal` en `build_phase`: la sequence no encuentra el sequencer
- **b)** Corre igual: cuando hay `default_sequence`, el objection lo levanta el sequencer solo
- **c)** La `main_phase` termina en t=0 y el test pasa con 0 errores
- **d)** La simulación se cuelga esperando un objection que nadie baja

**45. Sub-sequences**

`full_sequence` arranca a sus hijas con `reset_seq.start(get_sequencer(), this)`. ¿Para qué está el segundo argumento?

- **a)** Para pasarle el sequencer, porque `get_sequencer()` sólo devuelve el tipo
- **b)** Para declarar a la hija sub-sequence de la madre
- **c)** Para que la hija corra en un hilo aparte, en paralelo con la madre
- **d)** Para registrar a la hija en la factory con el nombre de la madre, y poder overridearla

---

## Día 7 · 5 preguntas

**46. Inmediatas y concurrentes**

¿Cuál es la diferencia de fondo entre `assert(x.randomize())` y `assert property (@(posedge clk) …)`?

- **a)** Ninguna: la segunda es azúcar sintáctico de la primera
- **b)** La primera se puede apagar por línea de comandos y la segunda no
- **c)** Una es una **sentencia**; la otra, una **declaración con reloj**
- **d)** La primera sólo vale adentro de una clase y la segunda sólo adentro de un módulo, por el scheduler

**47. `|->` contra `|=>`**

El `done` del VTALU sale de un `always_ff`. ¿Qué implicación va en `start |?? done`?

- **a)** `|->`, porque el antecedente y el consecuente son de la misma transacción
- **b)** `|=>`, porque lo que se escribe con `<=` se lee un flanco después
- **c)** Cualquiera de las dos: la diferencia es de estilo
- **d)** Ninguna: para señales registradas hay que usar `$past()` sobre el antecedente

**48. El flanco de muestreo**

Todas las properties del VTALU muestreadas en `@(posedge clk)` dan 145 errores sobre 1000 operaciones, y el DUT está sano. ¿Por qué?

- **a)** Falta el `disable iff (!reset_n)`
- **b)** El `posedge` es demasiado rápido: hay que dividir el reloj
- **c)** El estímulo se escribe en el `negedge` y el muestreo no lo ve
- **d)** Los covergroups y las assertions no pueden compartir el reloj sin un `clocking block`

**49. La assertion que no chequea nada**

Una property `assert` reporta 0 fallas durante toda la regresión. ¿Qué se sabe?

- **a)** Que la regla que describe se cumple
- **b)** Que el DUT está libre de bugs de protocolo
- **c)** Nada todavía: puede que nunca se haya evaluado
- **d)** Que la property tiene un `disable iff` mal escrito y quedó apagada todo el tiempo

**50. Assertion o scoreboard**

El DUT devuelve el `result` correcto pero baja `done` un ciclo antes de lo que dice la especificación. ¿Quién lo caza?

- **a)** El scoreboard, cuando compare el resultado
- **b)** La cobertura funcional, porque el bin de `done` queda vacío
- **c)** Una assertion en la interface: es un bug de **protocolo**
- **d)** El `uvm_fatal` del `command_monitor`, que dejaría de ver comandos en el bus

---

## Día 8 · 8 preguntas

**51. El string de acceso**

`CLR` se limpia solo cuando le escribís un 1. Lo declarás `"WOC"`, y `bit_bash` y `mirror(UVM_CHECK)` dan cero errores. ¿Qué pasó?

- **a)** Nada: `WOC` es el acceso que describe un campo que se limpia al escribirlo
- **b)** `WOC` no está en el LRM, así que UVM lo trata como un `RW` cualquiera
- **c)** Los dos saltean los accesos `WO*`: ese bit no se testeó
- **d)** El predictor deja el espejo en `x`, y una comparación contra `x` siempre pasa

**52. Predicción automática o explícita**

¿Qué cambia entre `set_auto_predict(1)` y enganchar un `uvm_reg_predictor` al monitor?

- **a)** Nada: el predictor es la implementación interna del auto-predict
- **b)** Con auto-predict el modelo cree lo que **quiso** mandar, no lo que pasó
- **c)** El predictor es más rápido: no arma la transaction del bus
- **d)** El auto-predict sólo sirve para el frontdoor, y el predictor también para el backdoor

**53. volatile**

`STATUS` cambia solo, sin que nadie le escriba. ¿Qué querés decir al declararlo `volatile` en `configure()`?

- **a)** Que UVM lo va a releer del DUT antes de cada comparación, para no equivocarse
- **b)** Que el espejo no es evidencia: el valor pudo cambiar sin pasar por el bus
- **c)** Que el campo queda fuera del mapa y deja de tener dirección
- **d)** Que hay que leerlo por backdoor, porque el frontdoor no llega a tiempo

**54. mirror() contra read()**

`model.CTRL.read(status, data)` y `model.CTRL.mirror(status, UVM_CHECK)`. ¿En qué se diferencian?

- **a)** `read` va por el bus y `mirror` se queda en el espejo, sin generar una transferencia
- **b)** Las dos leen del DUT; `mirror` además compara contra lo que el modelo creía
- **c)** `mirror` escribe el espejo en el DUT, para dejar a los dos iguales
- **d)** `read` actualiza el espejo y `mirror` no lo toca, para no tapar un error

**55. Quién sabe del bus**

¿Qué sabe el `uvm_reg_block` sobre el APB?

- **a)** La dirección base y el ancho de `PADDR`, que le llegan por el `uvm_reg_map`
- **b)** Nada: el único que sabe del bus es el adapter
- **c)** Todo: por eso hay un modelo de registros por protocolo
- **d)** Los tiempos de SETUP y ACCESS, para predecir el wait state de la lectura

**56. DPI y el tiempo**

Una `import "DPI-C" function` del golden model, ¿puede esperar un flanco de reloj?

- **a)** Sí, poniendo un `#1` adentro del `.c`
- **b)** No: una `function` corre en tiempo cero
- **c)** Sí, siempre que el `.c` se compile con el soporte de timing de Verilator
- **d)** Sí: el simulador suspende el hilo de C mientras dura la llamada

**57. undefined reference**

El `.c` está escrito y compila, y el link falla con *undefined reference* a la función del golden model. ¿Qué mirás primero?

- **a)** Que falte el flag de DPI en la línea de `verilator`
- **b)** Que el `.c` esté en un `-f` aparte y no mezclado con los `.sv`
- **c)** El nombre, y el `extern "C"`: el símbolo pudo salir decorado
- **d)** Que la `function` de SystemVerilog esté declarada `virtual` para exportar el símbolo

**58. El scoreboard que nunca gritó**

El scoreboard con golden model en C corre mil operaciones y no reporta ni una. ¿Alcanza?

- **a)** Sí: mil comparaciones sin una sola diferencia es la definición de verificado
- **b)** Sí, siempre que además la cobertura funcional haya cerrado al 100 %
- **c)** No: un scoreboard que nunca vio un error no está probado
- **d)** No, porque los dos lados comparten el `enum` de opcodes y se anulan entre sí

---

## Clave

| # | Día | Tema | Correcta | Por qué |
|--:|:--:|:--|:--:|:--|
| 1 | 1 | Tendencias | **b** | **En debug** — el 47 % del tiempo del verificador se va ahí. Por eso el curso le dedica una sección entera al reporting: un scoreboard que sólo dice "falló" te deja justo en ese 47 %. |
| 2 | 1 | La spec de la ALU | **d** | **Estables hasta `done`** — es el protocolo del DUT, y es exactamente el motivo por el que existe el BFM: encapsular esa regla en un solo lugar para que ningún test se la olvide. El primer distractor describe un protocolo real —arranque por pulso, operandos latcheados— que este DUT no tiene. |
| 3 | 1 | Cobertura funcional | **b** | **Muy poco** — la cobertura de código mide el DUT; la funcional mide la spec. Una feature que el diseñador nunca escribió da 100 % de líneas y 0 % de lo que importa, y el reporte no te lo va a decir. |
| 4 | 1 | covergroup | **b** | **El `sample()`** — el covergroup no se muestrea solo: alguien tiene que llamarlo, en el flanco o cuando llega una transacción. Sin esa llamada el código compila, corre, y el reporte da 0 sin una sola advertencia. |
| 5 | 1 | Interfaces y BFM | **a** | **Deja de hablar en señales** — el BFM traduce *una operación* a *un handshake de señales*. El tester, el scoreboard y el coverage no vuelven a tocar un cable: es el primer paso hacia UVM. |
| 6 | 1 | El plan de verificación | **c** | **Qué bin se llena** — las cinco columnas son *Feature*, *Escenario*, *Estímulo*, *Chequeo* y *Medida*, y ésta es la que más cuesta: obliga a decidir **antes** qué se va a contar. Si queda vacía, nadie se va a enterar de que el escenario nunca pasó — un caso que el random no tocó y que no tiene bin es indistinguible de uno que pasó mil veces. |
| 7 | 1 | clocking block | **c** | **No hacen falta, y conviene usarlos igual** — son de **SystemVerilog**, no de UVM, y ningún `uvm_driver` muestrea por vos. Lo que evita la race es entender el scheduler: un driver que maneja con `<=` contra un DUT que registra con `<=` ya es determinista. El clocking block no reemplaza ese entendimiento, lo **encapsula** — y ahí es donde paga: agents reutilizables, VIP, gate-level y protocolos con setup/hold en la spec. |
| 8 | 2 | Handle y objeto | **a** | **Ninguno** — declarar un handle no reserva nada. Ahí está la diferencia con una `struct`, que el simulador reserva apenas la ve. Y usar el handle antes del `new()` no falla al compilar: revienta en medio de la simulación. |
| 9 | 2 | Polimorfismo | **c** | **El de `trago`** — sin `virtual`, SystemVerilog mira el **tipo de la variable**, no el del objeto. Es literal lo que imprime `code/u3/polimorfismo/01-sin-virtual`: *"A generic trago cannot be served"*. |
| 10 | 2 | Clases abstractas | **b** | **El error pasa al compilador** — con `$fatal` te enterás a mitad de la simulación de que faltaba un override. Con `pure virtual` no compila. Atajar antes siempre es más barato. |
| 11 | 2 | Variables estáticas | **c** | **Una sola** — y existe aunque no instancies ningún objeto. Eso es lo que la hace útil para datos globales del TB, y lo que la hace peligrosa si la dejás pública. |
| 12 | 2 | Métodos estáticos | **a** | **Para poder cambiarla después** — si la cola está a la vista, el día que la cambiás por otra estructura tenés que salir a corregir todos los lugares que la tocaban. Encapsular es poder cambiar de opinión. |
| 13 | 2 | Clases paramétricas | **d** | **No la comparten** — SystemVerilog genera **una clase por combinación de parámetros**. `static` es único dentro de cada una de esas clases, no entre todas. UVM se apoya en esto todo el tiempo. |
| 14 | 2 | El patrón factory | **b** | **Decidir el subtipo en runtime** — sin hardcodear el `new`: le pedís un objeto a la fábrica y ella decide cuál. Es la pieza que después te va a dejar cambiar el estímulo de un test entero sin tocar el código del `env`. |
| 15 | 2 | $cast | **d** | **Sólo si el objeto lo permite** — `$cast` chequea **en runtime** y devuelve 0 si no da. Por eso la factory de UVM es más cómoda que la `cantina` de la sección: el `type_id::create()` devuelve el tipo correcto y te ahorra el casteo. |
| 16 | 3 | `uvm_test` | **a** | **Elegir el test sin recompilar** — UVM lee ese plusarg y le pide el test a la **factory** por nombre. Es la diferencia entre 1000 tests × 5 minutos de compilación y una sola compilación. |
| 17 | 3 | UVM Phases | **c** | **Build top-down, connect bottom-up** — y tiene sentido: no podés conectar un componente que todavía no existe, así que primero se construye toda la jerarquía y recién después se conecta. |
| 18 | 3 | Objections | **b** | **Para que la fase no termine antes** — todos los `run_phase` corren en paralelo, cada uno en su thread, y la fase termina cuando **cae la última objection**. Sin levantarla, la simulación se te termina en el tiempo 0. |
| 19 | 3 | El env | **d** | **Estructura vs. estímulo** — cada clase hace **una sola cosa bien**. Por eso el `env` casi siempre tiene sólo `build_phase` y `connect_phase`, y el test casi siempre tiene sólo un override de la factory. |
| 20 | 3 | Factory override | **a** | **Antes del `build_phase`** — la factory decide qué construir **en el momento del `create()`**. Si el override llega tarde, el `env` ya instanció la clase base y no hace nada. |
| 21 | 3 | Verbosidad | **b** | **Sólo sobre `` `uvm_info ``** — warnings, errores y fatales son **inmunes** al techo de verbosidad, y está bien que así sea: nadie quiere apagar un error sin querer. Para esos hace falta el mecanismo de *actions*. |
| 22 | 3 | Report actions | **d** | **En `end_of_elaboration_phase`** — tiene que ser **después** de que la jerarquía esté construida (si no, el componente todavía no existe) y **antes** de que arranque la simulación. Esa fase es exactamente esa ventana. |
| 23 | 4 | Observer Pattern | **d** | **No sabe nada** — y esa ignorancia es la gracia. Agregar un cuarto subscriber no obliga a tocar una línea del que publica. |
| 24 | 4 | Analysis Ports | **b** | **Con una `uvm_tlm_analysis_fifo`** — un `uvm_subscriber` tiene un solo `write()`, así que sólo puede escuchar un puerto. La FIFO da un `analysis_export` de un lado y un `try_get()` del otro. Es lo que hace el scoreboard del VTALU. |
| 25 | 4 | Intra vs. inter thread | **c** | **Uno solo, y es comunicación intra-thread** — `write()` es una `function`, no una `task`: no consume tiempo y corre en el thread del que publica. Justamente por eso hace falta **otro** mecanismo (put/get + FIFO) para hablar entre threads. |
| 26 | 4 | Put y get ports | **a** | **Se bloquea** — `get()` es bloqueante, y por eso se declara `task` y no `function`. Esa es toda la sincronización: no hace falta un handshake de señales a mano. |
| 27 | 4 | try_get() | **c** | **Devuelve 0 y sigue** — es la versión no bloqueante, y por eso puede ser una `function`. Fijate que el scoreboard la usa en un `do ... while` para saltear los `no_op` y los `rst_op`. |
| 28 | 5 | Copia profunda | **a** | **Nada** — no hay copia, hay un segundo nombre para el mismo objeto. Si lo modificás por un handle, el otro lo ve. De ahí sale la regla del *MOOCOW*: si vas a modificar, copiá primero. |
| 29 | 5 | super.do_copy() | **c** | **Si no, se pierden los campos de arriba** — es el mismo problema que `convert2string()`: el día que alguien mete un nivel nuevo en el medio, el método deja de ver la mitad de los datos y no te avisa nadie. |
| 30 | 5 | clone() | **a** | **Para no repetir el `$cast`** — sin él, cada lugar que clona termina escribiendo su propio casteo. Es la misma idea de siempre: si lo vas a repetir, encapsulalo. |
| 31 | 5 | `dist`: `:=` contra `:/` | **c** | **1 de cada 256** — `:=` le da peso 1 a *cada uno* de los 254 valores del medio, así que el rango pesa 254 contra 1 y 1 de los bordes. Para repartir el peso *dentro* del rango va `:/`. Las dos formas compilan y corren: la diferencia sólo aparece en la cobertura que no sube. |
| 32 | 5 | `randomize() with {}` | **b** | **Se suman** — el `with {}` agrega constraints **sólo para esa llamada** y no borra nada. Por eso es la herramienta para cerrar un bin sin escribir una clase nueva: tres líneas en el punto de uso, y el resto del estímulo sigue siendo el de siempre. Y por eso también choca con un `dist` que ya sesgue el mismo campo: las dos tienen que dar a la vez. |
| 33 | 5 | constraint_mode() | **b** | **Apagar la constraint que estorba** — Verilator resuelve el `dist` **eligiendo un valor primero** y recién después chequea el resto, así que la probabilidad de éxito es la del bin: medido, `with {A == 8'hFF}` resuelve el 25 % de las veces. `constraint_mode(0)` la apaga sólo para ese objeto y no toca a nadie más. Es exactamente la línea que pide el ejercicio `d5c`. |
| 34 | 5 | rand_mode() | **b** | **Deja de ser `rand`** — son las dos perillas de tiempo de ejecución y se confunden seguido: `rand_mode(0)` saca **un campo** del sorteo, `constraint_mode(0)` apaga **una constraint**. Una elige *qué se sortea*, la otra *qué reglas valen*. Sirve para fijar un operando a mano y seguir randomizando el resto. |
| 35 | 5 | El orden de resolución | **c** | **1 de cada 257** — el solver elige uniformemente entre las *soluciones*, no entre los valores de cada campo: `es_reset=1` deja una sola combinación (`A = 00`) y `es_reset=0` deja 256. El bin *"cualquier operación después de un reset"* del plan no se llena, y el reporte no dice por qué. La respuesta del lenguaje es `solve es_reset before A`; Verilator la acepta y **no la respeta**, así que el rodeo portable es pedir el reparto del campo de control con un `dist`. |
| 36 | 6 | is_active | **c** | **Los monitores, siempre; el sequencer y el driver quedan en `null`** — mirar nunca es opcional: un agent pasivo sigue alimentando scoreboard y cobertura. Lo que se saltea es lo que *maneja* la interface, porque ahí ya hay otro manejándola. |
| 37 | 6 | El handshake del driver | **d** | **Se cuelga en `finish_item()`, y sin decir nada** — es el error clásico de la primera semana, y el síntoma engaña: no hay error ni warning, el tiempo deja de avanzar y el objection nunca se baja. `get_next_item()` es un préstamo; `item_done()` es devolverlo. |
| 38 | 6 | Ámbito del config_db | **c** | **Los dos reciben lo mismo** — el `uvm_config_db` no empareja por orden ni por tipo: empareja por **ruta**. Con `"*"` las dos entradas describen a los mismos componentes, así que la última gana. El ámbito es una ruta en el árbol, no una etiqueta. |
| 39 | 6 | El sequencer | **d** | **Por la clase base que elegimos en transactions** — `uvm_sequencer #(T)` exige que `T` derive de `uvm_sequence_item`. Si aquel día la transaction hubiera extendido `uvm_transaction` a secas, este `typedef` hoy no compilaría. Una decisión de una sección habilitando la siguiente. |
| 40 | 6 | super.build_phase() | **d** | **Ese mecanismo está apagado** — `uvm_agent::build_phase` busca `is_active` en el resource pool (está en `code/.uvm/src/comps/uvm_agent.svh`, se puede abrir). Sin `super.build_phase()` esa línea no corre nunca, y nadie avisa. Las dos formas son válidas; lo que no funciona es la mitad de cada una. |
| 41 | 6 | Object, no component | **b** | **Se crea, corre y se tira** — podés arrancar varias, una detrás de otra, sobre el mismo sequencer. Un componente se construye una vez en `build_phase` y vive hasta el final. Por eso el estímulo no puede ser un componente: cambia test a test, y a veces dentro del mismo test. De ahí sale también que se pueda configurar entre el `create()` y el `start()`, como hace `full_seq.count = 200`. |
| 42 | 6 | start_item() | **b** | **Tenés el turno —nadie más te va a ganar el driver—, y todavía no entregaste nada** — y por eso el `randomize()` va *después*: es el último momento posible para elegir los valores, cuando ya sabés en qué estado está el DUT. Eso es la randomización tardía, y es donde se enganchan `pre_do()` y `mid_do()`. |
| 43 | 6 | El camino de vuelta | **c** | **Después de `finish_item()`** — no hay ningún canal de vuelta: hay un handle compartido y un acuerdo entre las dos partes. El par REQ/RSP existe y es el mecanismo formal, pero casi nadie lo usa: escribir el resultado en el request alcanza. Esto es lo que hace posible Fibonacci. |
| 44 | 6 | default_sequence | **c** | **Pasa en cero segundos sin mandar un solo estímulo, y miente** — una fase sin objection termina en cuanto arranca. Es el mismo tipo de bug que el `new()` que se come el override: no rompe, engaña. Y en una regresión de mil tests, el que pasa en cero segundos no lo mira nadie. |
| 45 | 6 | Sub-sequences | **b** | **Declara la relación madre-hija** — sin él, el sequencer trata a las dos como sequences independientes y compiten por el turno. Con él, la hija hereda el turno de la madre y su prioridad en la arbitración. Y para el paralelo no alcanza con eso: hace falta un `fork` / `join` alrededor de los `start()`. |
| 46 | 7 | Inmediatas y concurrentes | **c** | **Sentencia contra declaración** — la inmediata corre cuando el hilo pasa por ahí; la concurrente se evalúa sola, en cada flanco de su reloj. Es a un `if` lo que la concurrente es a un `always_ff`: una se ejecuta, la otra se instancia. Por eso sólo la concurrente puede describir algo que dura varios ciclos. |
| 47 | 7 | `\|->` contra `\|=>` | **b** | **`\|=>` cuando el consecuente sale de un `<=`** — porque `\|=>` *es* `\|-> ##1`, y lo que hay que preguntarse es cuántos flancos después lo promete la spec. Con `\|->` contra una señal registrada la property no pasa en vacío: **falla en cada transacción**, porque compara contra el `done` viejo. La que sí pasa callada es aquella cuyo antecedente nunca ocurre — por eso va siempre con su `cover property`. |
| 48 | 7 | El flanco de muestreo | **c** | **Una assertion vale lo que vale su muestreo** — la BFM escribe el estímulo en el `negedge`, y en dos `no_op` seguidas `start` baja y vuelve a subir entre dos `posedge`: el muestreo no lo ve bajar. El estímulo se muestrea donde el estímulo se escribe. Estímulo en `negedge`, respuesta del DUT en `posedge`: cero errores. Con un solo reloj no hay forma. |
| 49 | 7 | La assertion que no chequea nada | **c** | **Cero fallas y cero evaluaciones se ven igual** — puede que su antecedente no haya ocurrido nunca, o que falte `--assert` y ni siquiera se esté evaluando. Por eso toda assertion va con su `cover property`: es el único chequeo del chequeo. En la sección, `c_mult_3ciclos` se queda en 0 y delata que la latencia real son cuatro flancos, no tres. |
| 50 | 7 | Assertion o scoreboard | **c** | **Protocolo → assertion. Datos → scoreboard** — y no es una preferencia: para cuando la transaction llega al scoreboard, el protocolo ya no está. Escribir el chequeo ahí sería reconstruir a mano el tiempo que el monitor acaba de borrar. |
| 51 | 8 | El string de acceso | **c** | **Verde no es chequeado** — `uvm_reg_bit_bash_seq.svh:129-133` saltea todo campo cuyo acceso empiece con `WO` (*"you are not supposed to read them"*), y `do_check` lo saca de la máscara de comparación (`uvm_reg.svh:2782-2788`). El único rastro está en los tiempos: el bashing de `CTRL` dura cuatro transferencias menos. El acceso correcto es `WC` (o `W1C`), y con él el bit sí se batea. Un acceso `WO*` es la forma más barata que hay de apagar un chequeo sin enterarse. |
| 52 | 8 | Predicción automática o explícita | **b** | **El que chequea no puede creerle al que estimula** — con `set_auto_predict(1)`, `model.CTRL.write()` actualiza el espejo en el momento de la llamada, antes de que el bus haya hecho nada: si el driver manda mal la transferencia, el modelo sigue convencido. Con el predictor, el espejo cambia recién cuando el monitor vio el cable. Es el mismo dibujo del scoreboard del capstone, con una pieza de la librería en lugar de una clase a mano. Y es gratis: el monitor y su analysis port **ya estaban**. |
| 53 | 8 | volatile | **b** | **El espejo deja de ser evidencia** — un modelo predice *"lo que escribí es lo que voy a leer"*, y para un campo `volatile` esa frase es falsa. Los dos `UVM_WARNING GET_MIRRORED_VAL/VOL` del ejemplo son la librería diciendo exactamente eso, y están en la salida a propósito. Lo que sí hay que chequear se chequea donde se sabe: en el **scoreboard**, y en el modelo va `set_compare(UVM_NO_CHECK)` sobre ese campo para que RAL no invente un error. |
| 54 | 8 | mirror() contra read() | **b** | **`mirror` es un scoreboard de registros en una palabra** — las dos leen del DUT; la diferencia es que `mirror` compara contra lo que el modelo creía **antes** de la lectura, y si no coincide reporta un `uvm_error` sin que nadie escriba un chequeo. Y una lectura *es* una predicción: las dos actualizan el espejo después. |
| 55 | 8 | Quién sabe del bus | **b** | **El modelo no sabe que abajo hay un APB** — cambiás el adapter y el mismo modelo maneja un AHB. El adapter son veinte líneas, una vez por protocolo, y es el archivo que te viene con un VIP comprado. Ojo con una: `bus2reg` lo llama **también el predictor**, con el item que vio el monitor, así que un adapter que dependa de algo que puso el driver funciona en un sentido y falla en el otro. |
| 56 | 8 | DPI y el tiempo | **b** | **Tiempo cero, como cualquier `function`** — para consumir tiempo hace falta `import "DPI-C" task`, y con una aclaración que casi todos los tutoriales se saltean: el C no puede bloquear por sí mismo. Una task de DPI consume tiempo **sólo** si se declara `context` y desde el C llama de vuelta a una `export "DPI-C" task` de SystemVerilog, que es la que espera el flanco. Y ahí ya no es un golden model, es un modelo de bus. |
| 57 | 8 | undefined reference | **c** | **El compilador no cruza las dos declaraciones: el que las junta es el linker** — de ahí que el error hable de algo que está escrito, ahí, a la vista. Casi siempre es una de dos: el nombre no coincide letra por letra, o el archivo se compiló como C++ y el símbolo salió con el nombre decorado. Eso último es literal acá: Verilator le pasa los fuentes del usuario al compilador de C++, así que el `.c` necesita su `extern "C"`. Y no hay flag de DPI: el `.c` va en la línea de `verilator` como un fuente más. |
| 58 | 8 | El scoreboard que nunca gritó | **c** | **Hay que romper el modelo a propósito** — `vtalu_golden_bug(1)` muta la multiplicación y el `run.sh` exige que el scoreboard grite. Si no grita, el testbench está comparando contra sí mismo y nadie se iba a enterar: es el mismo test de mutación que el corrector del capstone hace con `+BUG=1`, del otro lado del cable. Y el `enum` duplicado es real pero es otro síntoma: si fallan **todas** las comparaciones a la vez, es el mapeo; si falla una de cada seis, es el DUT. |
