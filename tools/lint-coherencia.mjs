// Lint de coherencia: que un mismo dato no diga dos cosas distintas segun donde
// lo leas, y que ninguna referencia dependa de contar slides.
//
// Sale de medir la revision de septiembre contra la de hoy. De ~80 hallazgos
// nuevos, la causa numero uno --unos 25-- fue siempre la misma: el dato esta
// escrito en N lugares (slide ES, slide EN, figura ES, figura EN, machete HTML,
// machete SVG, README, docs, comentario del codigo) y el arreglo entro en N-1.
// Ejemplos reales, todos del mismo dia:
//
//   - la figura EN del polimorfismo ya decia `mojito` y la ES seguia diciendo
//     `gancia`, una clase que no existe en el repo;
//   - la slide, su nota y el codigo decian que los dos agents arrancan PASIVOS,
//     y la figura que se proyecta en esa misma slide decia ACTIVOS;
//   - la slide del dia 3 decia bien que `final_phase` es top-down, y el machete
//     --el papel que el alumno se lleva-- decia bottom-up.
//
// Ninguna de las tres se puede pescar leyendo: hay que mirar los N lugares a la
// vez. Eso es lo que hace la regla 1.
//
//   1. HECHOS. Cada hecho declara una `fuente` --el archivo del repo o de la
//      libreria vendorizada que lo hace verdadero-- y los `lugares` que lo
//      repiten. Si la fuente deja de matchear, el hecho cambio y el lint pide
//      revisar los lugares (es lo que va a pasar el dia que se actualice UVM).
//      Si un lugar no dice lo que la fuente dice, ese lugar quedo viejo.
//
//      Tres cosas que la revision por clase de error obligo a agregar:
//
//      a) UN LUGAR PUEDE SER UNA FIGURA. Cinco figuras contradicen al codigo o a
//         la slide que las proyecta --`TB_UVM.svg` rotula el scoreboard como
//         `uvm_scoreboard` y en los doce scoreboards del curso extiende
//         `uvm_subscriber`; `sequences_handshake.svg` le pone un `randomize()`
//         a la `reset_sequence`, que no lo tiene; `TB.svg` dibuja un `mailbox`
//         haciendo broadcast y no hay un solo `mailbox` en `code/`--. El texto
//         del `.svg` se lee con el mismo extractor de `<text>`/`<tspan>` que usa
//         `lint-i18n` regla 9, porque una frase partida en dos `<tspan>` no
//         matchea contra el XML crudo.
//
//      b) UN HECHO PUEDE SER UN NUMERO. Los nueve hechos originales eran todos
//         cualitativos, y la mitad de los hallazgos de numeros son de esta forma:
//         `docs/demo.sh` graba el GIF del hero con `72.6% (53/73)` y el pie de
//         los dos README dice 86,8 %, que es lo que el ejemplo imprime hoy. Un
//         numero medido declara como fuente la salida capturada que lo produce.
//
//      c) UNA FUENTE PUEDE FALTAR TODAVIA. `u8/assertions` es el unico ejemplo
//         del curso con la salida capturada (`sva.txt`, `cover.txt`), y por eso
//         el 154 y el 80,0 % son los dos unicos numeros medidos que estan
//         garantizados. Los hechos cuya salida nadie capturo declaran el `.txt`
//         que falta y el comando que lo genera: el lint pide el archivo y
//         mientras tanto sigue comparando los lugares entre si.
//
//   2. REFERENCIAS DE DISTANCIA. "dos slides mas adelante", "hace tres slides".
//      Se rompen solas cuando alguien inserta una slide en el medio, y no hay
//      forma de verificarlas leyendo la slide que las escribe. Medido: de las
//      referencias de distancia que habia, se rompieron 4 de 4 --una decia dos
//      y eran cuatro, otra tres y eran seis, otra dos y eran once--. Se
//      reemplazan nombrando la slide, que es lo que ya hacia bien 026.
//      Las de ±1 ("la slide anterior", "la slide siguiente") NO se prohiben: son
//      ~80, rompieron 3 veces, y son la forma natural de hablar apuntando a la
//      pantalla. Prohibirlas seria mucho ruido para poca senal -- SALVO en el
//      ultimo slide de un archivo, donde "la que sigue" cruza el limite de
//      seccion y el que escribe no la tiene a la vista: `175-cierre` dice que el
//      dia 8 "arranca en la slide que sigue" y entre medio hay las tres slides
//      de la autoevaluacion. Medido sobre los dos decks: 2 coincidencias, las
//      dos son ese bug, cero falsos positivos.
//
//   3. CITAS A UN ARCHIVO Y LINEA. El curso cita la libreria por linea en ~34
//      lugares (`uvm_root.svh:1187`, `uvm_reg.svh:2782-2788`). Es lo que le da
//      autoridad, y es lo que nadie puede verificar leyendo la slide. Se chequea
//      que el archivo exista, que la linea exista y --lo que ataja el caso
//      real-- que NO este en blanco: `uvm_callback.svh:744` apuntaba a una linea
//      vacia y el `uvm_report_warning` estaba en la 745, y el rango
//      `uvm_reg_bit_bash_seq.svh:129-135` terminaba dos lineas despues del
//      `case` que dice cerrar. Las dos sobrevivieron dos revisiones.
//      Se agregan dos formas que no se miraban: la CITA ABREVIADA `` `:777-783` ``
//      --que se resuelve contra el ultimo `.svh` nombrado antes en el archivo, y
//      que en `146-callbacks` arranca en una linea en blanco y corta dos lineas
//      antes del `add()` que dice mostrar-- y los `docs/*.sh`, que graban los
//      GIF y citan `uvm_root.svh:633` sin que nadie los mire.
//
//   4. EL ORDEN DE LAS NUEVE FASES contra uvm_common_phases.svh. Las tablas ya
//      salen de una fuente unica (tools/datos-machete.mjs -> tools/tablas.mjs),
//      pero el `orden` de cada fase sigue escrito a mano ahi; esto lo ata a la
//      clase de la que cada fase extiende, que es quien lo decide.
//
//   5. LAS HORAS DE CADA DIA, con la agenda como fuente. Las 8 agendas suman
//      31 h los siete dias y 35 h con el dia 8; los once lugares que declaran el
//      total dicen 30 h 30 / 34 h 30. El origen es un arreglo que entro en N-1
//      lugares: un commit rebalanceo dia 6 y dia 7 y dejo el README en 4 h 15,
//      otro toco solo la slide y la puso en 4 h 45 --que era el valor viejo del
//      dia 7--, y las tarjetas de la landing quedaron con el dia 5 en 4 h cuando
//      todo el resto del repo dice 4 h 30. La agenda es la fuente porque es a la
//      que `002-como-usar` manda: "y cada agenda trae el suyo".
//
//   6. UN BLOQUE QUE CITA LA LIBRERIA SIN `:NNN`. `080-components` muestra el
//      `connect_phase` de `uvm_component.svh` diciendo "tal cual" y le falta el
//      `return;`. Como la cita no lleva numero de linea, la regla 3 no la ve: el
//      dia que UVM se actualice el bloque envejece en silencio.
//
//   7. LA REFERENCIA ABSOLUTA A UNA SLIDE. "la regla de la slide 1 del dia 1"
//      parece verificable y es peor que una de distancia. La slide 1 de cada dia
//      es SIEMPRE la agenda, que no dice nada de contenido: la regla del
//      protocolo que 160-assertions cita esta en la slide 14. Se resuelve contra
//      el orden real de `slides/es/`, cortando en cada `agenda-dayN`.
//
//   8. LOS ORDINALES SOBRE LA AUTOEVALUACION. Seis de las siete agendas citan la
//      fila de la rubrica por numero ("las filas 13 y 14"). La del dia 1 usa un
//      ordinal --"las tres primeras filas"-- y es la unica que miente: sus
//      objetivos son la 2, la 4 y la 5.
//
// Uso: node tools/lint-coherencia.mjs
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';

// [ruta, /debe aparecer/] o [ruta, /debe/, /nunca/] o [ruta, null, /nunca/]
// Un lugar `.svg` se compara contra el TEXTO de la figura, no contra el XML.
// Una `fuente` con tercer elemento es una salida que todavia nadie capturo, y
// ese elemento es el comando que la genera.
const HECHOS = [
  {
    // reveal.js vive en DOS lugares: el pin de package.json y la copia
    // vendorizada, que es la que el deck de verdad carga --index.html pide
    // vendor/reveal/dist/reveal.js, no node_modules--. El PR #1 de dependabot
    // subia el pin a 6.0.1 y dejaba la copia en 5.2.1, y ningun check lo miraba:
    // `npm run check` no corre `vendor`. El bump quedaba INERTE hasta que alguien
    // re-vendorizara, y ahi el deck cambiaba de major sin que nadie lo pidiera.
    // Por eso el pin es exacto y sin `^`: tiene que ser el mismo numero.
    // Cuando reveal se suba de verdad, se cambian los dos y tambien este hecho.
    que: 'el reveal.js que carga el deck es el 5.2.1 de vendor/reveal/, no el de node_modules',
    fuente: ['package.json', /"reveal\.js": "5\.2\.1"/],
    lugares: [
      ['vendor/reveal/VERSION', /reveal\.js 5\.2\.1/],
    ],
  },
  {
    que: 'la tercera clase del ejemplo de polimorfismo se llama `mojito`',
    fuente: ['code/u3/polimorfismo/01-sin-virtual/not_virtual.sv', /class mojito extends trago/],
    lugares: [
      ['res/diagrams/uml-poli.svg', /mojito/, /gancia/i],
      ['res/diagrams/en/uml-poli.svg', /mojito/, /gancia/i],
      ['slides/es/047-polimorfismo.md', /mojito/, /gancia/i],
      ['slides/en/047-polimorfismo.md', /mojito/, /gancia/i],
    ],
  },
  {
    que: 'los dos agents del ejemplo arrancan PASIVOS (el `"*"` del config_db pisa la clave)',
    fuente: ['code/u7/agents/tb_classes/env.svh', /UVM_PASSIVE/],
    lugares: [
      ['res/diagrams/agents_config_scope.svg', /arrancan pasivos/, /arrancan activos/],
      ['res/diagrams/en/agents_config_scope.svg', /start passive/, /start active/],
      ['slides/es/145-agents.md', /los dos arrancan\s+pasivos/, /los dos arrancan\s+activos/],
      ['slides/en/145-agents.md', /both\s+start up passive/, /both\s+start up active/],
    ],
  },
  {
    que: 'el `uvm_error` del scoreboard de reporting esta en la linea 39',
    fuente: ['code/u4/reporting/tb_classes/scoreboard_error.txt', /scoreboard\.svh\(39\)/],
    lugares: [
      ['res/diagrams/UVM-hierarchy.svg', /scoreboard\.svh\(39\)/, /scoreboard\.svh\(3[0-8]\)/],
      ['res/diagrams/en/UVM-hierarchy.svg', /scoreboard\.svh\(39\)/, /scoreboard\.svh\(3[0-8]\)/],
    ],
  },
  {
    que: 'la clase que el ejercicio d3 pide escribir se llama `mult_tester`',
    fuente: ['code/ejercicios/d3/vtalu_pkg.sv', /mult_tester/],
    lugares: [
      ['res/diagrams/env_adaptable_sol.svg', /mult_tester/, /\bmul_tester\b/],
      ['res/diagrams/en/env_adaptable_sol.svg', /mult_tester/, /\bmul_tester\b/],
      ['slides/es/085-env.md', /mult_tester/, /\bmul_tester\b/],
    ],
  },
  {
    que: '`+TOPOLOGY` es un plusarg: seis de las siete perillas de debug lo son',
    fuente: ['code/u7/sequences/tb_classes/base_test.svh', /test\$plusargs\("TOPOLOGY"\)/],
    lugares: [
      ['slides/es/171-apendice-debug.md', /seis de abajo son \*\*plusargs\*\*/i],
      ['res/machete.html', /seis son plusargs/, /cinco son plusargs/],
      ['res/en/machete.html', /six are plusargs/, /five are plusargs/],
      ['res/machete-debug.svg', /\+TOPOLOGY/],
      ['res/en/machete-debug.svg', /\+TOPOLOGY/],
    ],
  },
  {
    que: 'las report actions de UVM son siete (la septima es `UVM_RM_RECORD`)',
    fuente: ['code/.uvm/src/base/uvm_object_globals.svh', /UVM_RM_RECORD\s*=\s*'b1000000/],
    lugares: [
      ['code/u4/reporting/tb_classes/UVM_report_actions.sv', /UVM_RM_RECORD/],
      ['slides/es/088-reporting.md', /siete cosas posibles/, /seis cosas posibles/],
      ['slides/en/088-reporting.md', /seven possible things/, /six possible things/],
    ],
  },
  {
    que: '`+UVM_TIMEOUT` lleva un entero y un `,NO`: `5ms` se lee como 5 ns',
    fuente: ['code/.uvm/src/base/uvm_root.svh', /\+UVM_TIMEOUT=/],
    lugares: [
      ['slides/es/171-apendice-debug.md', /\+UVM_TIMEOUT=5000000,NO/],
      ['slides/es/172-apendice-trampas.md', /\+UVM_TIMEOUT=5000000,NO/],
      ['res/machete-debug.svg', /\+UVM_TIMEOUT=5000000,NO/, /\+UVM_TIMEOUT=\d+ms/],
      ['res/en/machete-debug.svg', /\+UVM_TIMEOUT=5000000,NO/, /\+UVM_TIMEOUT=\d+ms/],
    ],
  },
  {
    // El `nunca` es la razon invertida: la FIFO no es ilimitada porque el
    // `write()` sea una `function`, es ilimitada porque el constructor le pasa
    // `size = 0` (`uvm_tlm_fifos.svh:281`). Que el `write()` sea una `function`
    // --`void'(this.try_put(t))`-- es el motivo por el que, SI estuviera
    // acotada, tiraria en silencio. La conclusion de la slide es cierta y el
    // porque que da implica lo contrario, asi que el `debe` solo no alcanza.
    que: 'la `uvm_tlm_analysis_fifo` es ilimitada porque su constructor le pasa `size = 0`, no porque el `write()` sea una `function`',
    fuente: ['code/.uvm/src/tlm1/uvm_tlm_fifos.svh', /analysis fifo must be unbounded/],
    lugares: [
      ['slides/es/105-analysis-ports.md', /ilimitada por construcción/, /no puede\s+bloquear, así que no puede tirar/],
      ['slides/en/105-analysis-ports.md', /unbounded by construction/, /cannot\s+block, so it cannot drop/],
    ],
  },
  {
    que: "el opcode libre 3'b110 levanta `done` igual, con el result anterior",
    fuente: ['code/vtalu_dut/vtalu_1c.sv', /done_1c <= start && \(op != 3'b000\)/],
    lugares: [
      ['slides/es/020-spec-vtalu.md', /levanta `done` igual/, /el que está libre no hace nada/],
      ['slides/en/020-spec-vtalu.md', /raises `done` all the same/, /the free one does nothing/],
    ],
  },
  {
    // El gancho del dia 1 cita el 14 % en prosa, y el numero vive en data.json,
    // de donde salen las figuras. Si Wilson publica otro estudio y se actualiza
    // el json, la slide tiene que cambiar con el.
    que: 'el 14 % de exito en primer silicio del gancho es el de res/trends/data.json',
    fuente: ['res/trends/data.json', /"First-silicon success" \}, "value": 14,/],
    lugares: [
      ['slides/es/007-el-gancho.md', /\*\*14 %\*\* de los proyectos/],
      ['slides/en/007-el-gancho.md', /\*\*14 %\*\* of projects/],
    ],
  },

  // --- Figuras que contradicen al codigo o a la slide que las proyecta ---
  {
    // La figura dibuja dos cajas hermanas colgando de `uvm_component`, cada una
    // con su `run_phase()`, y un "duplicado" en ambar en el medio. El estado
    // real del codigo en ese punto del curso --`u4/components`, que es lo que la
    // seccion anterior deja-- es `add_tester extends random_tester` con un solo
    // metodo, `get_op()`: el `run_phase()` se hereda, no se escribe dos veces.
    // La duplicacion que si existe esta en los TESTS, y de esa se ocupa
    // `env_struct_level.svg` cuatro slides mas adelante.
    que: '`add_tester` extiende `random_tester` y HEREDA el `run_phase()`: no lo escribe dos veces',
    fuente: ['code/u4/components/tb_classes/add_tester.svh', /class add_tester extends random_tester/],
    lugares: [
      ['res/diagrams/env_intract_sol_1.svg', null, /run_phase\(\) escrito dos veces/],
      ['res/diagrams/en/env_intract_sol_1.svg', null, /run_phase\(\) written twice/],
      ['slides/es/085-env.md', null, /extienden `uvm_component` \*\*por separado\*\*/],
      ['slides/en/085-env.md', null, /extend `uvm_component` \*\*separately\*\*/],
    ],
  },
  {
    // La figura rotula cada caja con su clase base de UVM y para el scoreboard
    // escribe `uvm_scoreboard`. En el repo `uvm_scoreboard` se extiende UNA vez
    // --la solucion de un ejercicio opcional del dia 8--: son 8 `uvm_subscriber`
    // y 4 `uvm_component`. Y la propia `agents_env_antes_despues.svg` cuenta
    // "1 agent y 2 subscribers", que es lo correcto.
    que: 'el scoreboard del curso extiende `uvm_subscriber`',
    fuente: ['code/u7/agents/tb_classes/scoreboard.svh', /class scoreboard extends uvm_subscriber/],
    lugares: [
      ['res/TB_UVM.svg', /uvm_subscriber/, /uvm_scoreboard/],
      ['res/en/TB_UVM.svg', /uvm_subscriber/, /uvm_scoreboard/],
      ['res/machete.html', null, /uvm_scoreboard/],
      ['res/en/machete.html', null, /uvm_scoreboard/],
    ],
  },
  {
    // El carril de arriba se llama `reset_sequence` y adentro dice "llena el
    // item / randomize()", y termina con `cmd.result`. La slide anterior muestra
    // el `reset_sequence.svh` ENTERO: su `body()` hace `command.op = rst_op;`,
    // sin `randomize()`, y nunca lee `result`. La que randomiza es
    // `random_sequence` y la unica que lee `command.result` es
    // `fibonacci_sequence`. El alumno tiene el archivo en la retina.
    que: 'la `reset_sequence` no randomiza nada: su `body()` solo pone `command.op = rst_op`',
    fuente: ['code/u7/sequences/tb_classes/reset_sequence.svh', /command\.op = rst_op/],
    lugares: [
      ['res/diagrams/sequences_handshake.svg', null, /reset_sequence[\s\S]{0,60}randomize\(\)/],
      ['res/diagrams/en/sequences_handshake.svg', null, /reset_sequence[\s\S]{0,60}randomize\(\)/],
    ],
  },
  {
    // La figura se titula "Jerarquia de instancias que UVM arma en build_phase"
    // y dibuja `env_h` con seis hijos. El env que retrata construye SIETE: los
    // seis mas `command_f`, un `uvm_tlm_fifo`, que es un `uvm_component` y por
    // lo tanto sale en el arbol. Y la nota de la slide invita explicitamente a
    // comparar con `uvm_top.print_topology()` "para mostrar que no es un
    // dibujo": se hace la demo y el arbol no es el del dibujo.
    que: 'el `env` de `u4/reporting` construye siete componentes, y el septimo es la FIFO `command_f`',
    fuente: ['code/u4/reporting/tb_classes/env.svh', /command_f = new\("command_f", this\)/],
    lugares: [
      ['res/diagrams/UVM-hierarchy.svg', /command_f/],
      ['res/diagrams/en/UVM-hierarchy.svg', /command_f/],
    ],
  },
  {
    // La etiqueta `mailbox` esta sobre el nodo del que salen DOS flechas --al
    // scoreboard y al coverage--, en la misma posicion donde `TB_UVM.svg` pone
    // `uvm_analysis_port`. Un mailbox de SystemVerilog no hace broadcast: cada
    // `get()` SACA el item, asi que dos lectores se repartirian las
    // transacciones. Y no hay un solo `mailbox` en `code/`: el testbench de
    // clases del dia 2 le pasa la misma BFM a las tres piezas por el constructor.
    que: 'el testbench de clases comparte la BFM por el constructor: no hay un solo `mailbox` en `code/`',
    fuente: ['code/u3/tb-en-objetos/tb_classes/testbench.svh', /tester_h = new\(bfm\)/],
    lugares: [
      ['res/TB.svg', null, /mailbox/],
      ['res/en/TB.svg', null, /mailbox/],
    ],
  },

  // --- Afirmaciones sobre la libreria, contra la libreria ---
  {
    // Tres secciones repiten, con distintas palabras, que las TLM FIFO no estan
    // registradas en la factory y por eso se instancian con `new()`.
    // `uvm_tlm_fifo` y `uvm_tlm_analysis_fifo` SI estan registradas
    // (`uvm_tlm_fifos.svh:62` y `:256`) y `type_id::create()` funciona sobre las
    // dos. Los que no estan son los PORTS y los EXPORTS, que extienden
    // `uvm_port_base` sin macro de utils. Media afirmacion cierta, generalizada.
    que: 'las TLM FIFO SI estan en la factory (`uvm_component_param_utils`); los que no estan son los ports y los exports',
    fuente: ['code/.uvm/src/tlm1/uvm_tlm_fifos.svh', /uvm_component_param_utils\(uvm_tlm_fifo#\(T\)\)/],
    lugares: [
      ['slides/es/105-analysis-ports.md', null, /FIFOs?\b[\s\S]{0,40}?no\s+est[áa]n\s+(?:en\s+la\s+factory|registrad)/],
      ['slides/es/115-put-get.md', null, /FIFOs?\b[\s\S]{0,40}?no\s+est[áa]n\s+(?:en\s+la\s+factory|registrad)/],
      ['slides/es/135-transactions.md', null, /FIFOs?\b[\s\S]{0,40}?no\s+est[áa]n\s+(?:en\s+la\s+factory|registrad)/],
      ['slides/en/105-analysis-ports.md', null, /FIFOs?\b[\s\S]{0,40}?are\s+not\s+(?:in\s+the\s+factory|registered)/],
      ['slides/en/115-put-get.md', null, /FIFOs?\b[\s\S]{0,40}?are\s+not\s+(?:in\s+the\s+factory|registered)/],
      ['slides/en/135-transactions.md', null, /FIFOs?\b[\s\S]{0,40}?are\s+not\s+(?:in\s+the\s+factory|registered)/],
    ],
  },
  {
    // La slide tranquiliza diciendo que olvidarse el `uvm_component_utils` es un
    // error de compilacion. Solo es cierto si NINGUN ancestro esta registrado.
    // En la jerarquia que la propia seccion construye --add_tester extends
    // random_tester extends base_tester-- el `type_id` se HEREDA: compila
    // limpio, `add_tester::get_type()` devuelve `random_tester`, y el
    // `set_type_override` del `add_test` corre estimulo random con UVM_ERROR : 0.
    // Es la familia "no rompe, miente" que el apendice de trampas persigue.
    que: 'sin la macro el `type_id` se HEREDA del ancestro registrado: compila, corre, y construye la clase de arriba',
    fuente: ['code/.uvm/src/macros/uvm_object_defines.svh', /typedef uvm_component_registry\b/],
    lugares: [
      ['slides/es/085-env.md', null, /sin la\s+macro no hay `type_id`/],
      ['slides/en/085-env.md', null, /without the\s+macro there is no `type_id`/],
    ],
  },
  {
    // "La instancia gana si estan las dos". `uvm_sequencer_base::
    // start_phase_sequence` hace `sort_by_precedence` y se queda con el primero
    // de la cola, sea del tipo que sea; el comentario de Accellera promete
    // prioridad a `uvm_sequence_base` y el `for` no la implementa. A igual
    // precedencia el orden es "most recently set first", asi que con los dos
    // `set()` desde el mismo contexto gana el que se escribio ultimo. El modo de
    // falla real es poner las dos y no saber cual corrio.
    que: 'entre dos `default_sequence` gana la de mayor precedencia, y a igual precedencia el ultimo `set()`',
    fuente: ['code/.uvm/src/base/uvm_resource_pool.svh', /most recently set first/],
    lugares: [
      ['slides/es/150-sequences.md', null, /La instancia gana/],
      ['slides/en/150-sequences.md', null, /The instance wins/],
    ],
  },
  {
    // El dia 3 dice que `uvm_agent` es "la unica clase de la libreria, ademas de
    // `uvm_component`, que implementa `build_phase`". El dia 6 dice --bien, y
    // con cita-- que son dos. En la libreria son cinco: `uvm_component`,
    // `uvm_agent`, `uvm_sequencer_base`, `uvm_sequencer_param_base` y
    // `uvm_root`. El argumento del dia 3 --"ponelo siempre salvo que puedas
    // nombrar por que es un no-op"-- se apoya en ese "unica", asi que la
    // exageracion debilita justo la regla que la slide quiere dejar.
    que: '`uvm_sequencer_base` tambien implementa `build_phase`: `uvm_agent` no es la unica',
    fuente: ['code/.uvm/src/seq/uvm_sequencer_base.svh', /function void uvm_sequencer_base::build_phase/],
    lugares: [
      ['slides/es/080-components.md', null, /única clase de\s+la librería/],
      ['slides/en/080-components.md', null, /the only\s+class in the library/],
    ],
  },
  {
    // El comentario adentro del bloque de SVA dice "El default de SystemVerilog:
    // MATA la simulacion en la primera falla". El default del LRM (1800-2017
    // §16.3) para una assertion sin `else` es llamar a `$error`, que NO corta la
    // simulacion. El bullet que esta tres centimetros mas abajo lo dice bien, y
    // `docs/verilator.md` lo dice bien y acotado a la herramienta: el comentario
    // que el alumno copia es el unico de los tres lugares que generaliza al
    // lenguaje. `lint-i18n` no lo ve porque ES y EN dicen lo mismo mal.
    que: 'el `$stop` de una assertion sin `else` es de Verilator, no del lenguaje: el default del LRM es `$error`',
    fuente: ['docs/verilator.md', /accion por defecto de una assertion sin `else` es `\$stop`/],
    lugares: [
      ['slides/es/160-assertions.md', null, /default de SystemVerilog: MATA/],
      ['slides/en/160-assertions.md', null, /SystemVerilog default: it KILLS/],
    ],
  },

  // --- Los dos enums de la libreria que el curso proyecta como codigo ---
  {
    // Las dos slides muestran el `typedef enum` SIN el punto y coma final: es
    // SystemVerilog que no compila, proyectado como si fuera la libreria. Los
    // valores si coinciden con UVM 2020.3.1; lo que no coincide es que sea
    // codigo. Declararlos como hecho ata las dos copias a su fuente real: el dia
    // que se actualice UVM el lint pide revisarlas.
    que: 'el enum `uvm_verbosity` del curso es el de la libreria, y es SystemVerilog que compila',
    fuente: ['code/.uvm/src/base/uvm_object_globals.svh', /UVM_DEBUG\s+=\s+500/],
    lugares: [
      ['code/u4/reporting/tb_classes/verbosidad.svh', /UVM_DEBUG\s*=\s*500[\s\S]*\}\s*uvm_verbosity;/],
    ],
  },
  {
    que: 'el enum `uvm_action_type` del curso es el de la libreria, y es SystemVerilog que compila',
    fuente: ['code/.uvm/src/base/uvm_object_globals.svh', /UVM_RM_RECORD\s*=\s*'b1000000/],
    lugares: [
      ['code/u4/reporting/tb_classes/UVM_report_actions.sv', /UVM_RM_RECORD\s*=\s*7?'b1000000[\s\S]*\}\s*uvm_action_type;/],
    ],
  },

  // --- Numeros medidos, con la salida que los produce como fuente ---
  {
    // `docs/demo.sh` se declara "la salida verbatim de make u4/tests" y hoy no
    // lo es: el covergroup paso de 73 a 76 bins cuando entro el `borrow` de la
    // rev2 del VTALU. El GIF del hero de los dos README muestra 72.6% (53/73) y
    // el pie de abajo dice 86,8 % -- el lector ve un GIF que contradice la linea
    // que tiene debajo.
    que: '`make u4/tests` cierra el covergroup en 86.8% (66/76)',
    fuente: ['docs/verilator.md', /`u4\/tests`\s*\|\s*PASA\s*\|\s*86\.8% \(66\/76\)/],
    lugares: [
      ['docs/demo.sh', /86\.8% \(66\/76\)/, /72\.6%/],
      ['README.es.md', /86,8 % de cobertura funcional/],
      // El espacio antes del % lo exige la regla 16 de lint-i18n para el arbol
      // castellano y el README lo usa: sin el \s? las dos reglas se contradicen
      // y no hay texto que las satisfaga a las dos.
      ['README.md', /86\.8\s?% functional coverage/],
    ],
  },
  {
    // Tres numeros para lo mismo: la matriz dice 28.9 % (que es `random_test`
    // solo, o sea anterior a que `add_test` entrara al run.sh), el ejemplo
    // imprime 34.2 %, y el comentario del tester dice 28,8 % --que no es ninguno
    // de los dos-- y dice que con mil operaciones daria 72,6 %, que es el numero
    // viejo de cuando el covergroup tenia 73 bins. Ningun lint abria un
    // comentario de `.svh` buscando un porcentaje. El hecho no fija cual es el
    // numero bueno --eso lo decide regenerar la matriz-- sino que prohibe los
    // dos que con seguridad no salen de correr nada.
    que: 'ni 28,8 % ni 72,6 % salen de correr `u4/reporting`: el numero de verdad es el de la matriz de docs/verilator.md',
    fuente: ['docs/verilator.md', /`u4\/reporting`\s*\|\s*PASA\s*\|\s*28\.9% \(22\/76\)/],
    lugares: [
      ['code/u4/reporting/tb_classes/base_tester.svh', null, /(?:28,8|72,6) %/],
    ],
  },
  {
    // El caso N-1 de manual: `revision/TAREAS.md` dice que con la FIFO sin tope
    // el bus ve 13 de las 1000 operaciones, no ~25, y el arreglo entro en las
    // cuatro slides pero no en el archivo que el alumno abre primero -- el
    // enunciado esta adentro del `driver.svh` que tiene que editar.
    // `lint-i18n` compara ES contra EN y las dos dicen 13, asi que pasa.
    que: 'con la FIFO sin tope el bus de `d4b` ve 13 de las 1000 operaciones',
    // La fuente es la linea del MONITOR, no la frase del corrector: el numero
    // que vale es el que midio el monitor sobre el bus, y la prosa del "not yet"
    // podria envejecer igual que envejecio la de la slide.
    fuente: ['code/ejercicios/d4b/roto.txt', /\[COMMAND MONITOR\]\s+13\b/, 'sh tools/regen-outputs.sh d4b'],
    lugares: [
      ['code/ejercicios/d4b/driver.svh', null, /about twenty-five/],
      ['slides/es/118b-ejercicio-day4b.md', /13 comandos/],
      ['slides/en/118b-ejercicio-day4b.md', /13 commands/],
    ],
  },
  {
    // La nota compara el test dirigido con el random: el dirigido termina en 500
    // y el random en 43 ns, o sea 43.000 unidades. Las otras dos cuentas de la
    // misma nota --"Trece operaciones" y el `for` hasta 14-- si estan bien.
    // `u7/sequences` es el candidato natural para regen-outputs.sh: sin el .txt
    // no hay fuente que chequear y el lint no es posible sin correr UVM.
    que: 'el `full_test` de `u7/sequences` termina en 43 ns, o sea 43.000 unidades de tiempo',
    fuente: ['code/u7/sequences/full_test.txt', /finish at 43ns/, 'sh tools/regen-outputs.sh u7/sequences'],
    lugares: [
      ['slides/es/150-sequences.md', /43\.000/, /44\.000/],
      ['slides/en/150-sequences.md', /43,000/, /44,000/],
    ],
  },
  {
    // El modelo de la regla, y el unico que hoy esta garantizado: el bloque de
    // la slide sale de `{{code:}}` sobre el .txt capturado, pero la prosa que lo
    // repite dos veces no la mira nadie.
    que: 'la assertion del ejemplo caza el operando cambiado 154 veces',
    fuente: ['code/u8/assertions/sva.txt', /UVM_ERROR :\s+154/],
    lugares: [
      ['slides/es/160-assertions.md', /\b154\b/],
      ['slides/en/160-assertions.md', /\b154\b/],
    ],
  },
  {
    // El archivo que el alumno de d5b abre primero dice "10000 randomizations"
    // y el `localparam` que tiene veinticuatro lineas mas abajo dice 4000. Los
    // otros seis lugares --los dos README del ejercicio y las dos slides-- dicen
    // 4000, y la propia corrida lo desmiente en la linea de arriba de la que el
    // corrector lee.
    que: 'el histograma de `d5b` hace 4000 randomizaciones',
    fuente: ['code/ejercicios/d5b/histograma.sv', /localparam int N = 4000/],
    lugares: [
      ['code/ejercicios/d5b/histograma.sv', null, /10000 randomizations/],
      ['code/ejercicios/d5b/README.es.md', /4000/],
      ['code/ejercicios/d5b/README.md', /4000/],
      ['slides/es/139-ejercicio-day5b.md', /4000/],
      ['slides/en/139-ejercicio-day5b.md', /4000/],
    ],
  },

  // --- Reparto: de que unidad y de que dia es cada seccion ---
  {
    // El ejemplo vive en `code/u7/sequences/virtual/`, o sea unidad 7, y la guia
    // docente lo dice bien. La tabla de los dos README la pone en la fila
    // "8 · La otra mitad", y la pregunta 15 de la entrevista manda al dia 6
    // cuando la seccion va despues de `159-agenda-day7.md`. Importa porque el
    // reparto de los parciales se define por unidad: "Parcial 2 · U4-U6",
    // "Final · U7-U8".
    que: 'las sequences virtuales son la unidad 7 y se dictan el dia 7 (el ejemplo corre en `code/u7/sequences/virtual/`)',
    fuente: ['code/u7/sequences/virtual/run.sh', /./],
    lugares: [
      ['docs/para-docentes.md', /\*\*Sequences virtuales\*\* \(U7\)/],
      ['docs/en/for-teachers.md', /\*\*Virtual sequences\*\* \(U7\)/],
      ['README.es.md', null, /\*\*8 ·\*\* La otra mitad \| Sequences virtuales/],
      ['README.md', null, /\*\*8 ·\*\* The other half \| Virtual sequences/],
      ['docs/uvm-en-la-entrevista.md', null, /día 6 · sequences virtuales/],
      ['docs/en/uvm-interview.md', null, /day 6 · virtual sequences/],
    ],
  },
  {
    // La fila 10b del cronograma de 15 semanas da vuelta las dos secciones de la
    // U5: dice "Quien espera a quien · Cuando alguien tiene que esperar", y en
    // el deck `110-threads` ("Cuando alguien tiene que esperar") va ANTES que
    // `115-put-get` ("Quien espera a quien"). El docente que siga la tabla da la
    // FIFO bloqueante despues de haberla usado. ES y EN estan igual de mal, asi
    // que `lint-i18n` pasa en verde.
    que: 'en la U5 va primero *Cuando alguien tiene que esperar* y despues *Quien espera a quien*',
    fuente: ['slides/es/095-agenda-day4.md', /Cuando alguien tiene que esperar[\s\S]{0,40}Quién espera a quién/],
    lugares: [
      ['docs/para-docentes.md', null, /Quién espera a quién · Cuando alguien tiene que esperar/],
      ['docs/en/for-teachers.md', null, /Who waits for whom · When somebody has to wait/],
    ],
  },
];

// Referencias que dependen de contar slides. Las de ±1 quedan afuera a proposito
// (ver la cabecera): esto solo caza las que nadie puede verificar leyendo.
const DISTANCIA = [
  /\b(?:una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|\d+)\s+slides?\s+(?:m[áa]s\s+)?(?:adelante|atr[áa]s|despu[ée]s|antes)\b/gi,
  /\bhace\s+(?:una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|\d+)\s+slides?\b/gi,
  /\ben\s+(?:dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|\d+)\s+slides?\b/gi,
  /\b(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+slides?\s+(?:further\s+(?:on|back)|later|back|ago|earlier)\b/gi,
];

// La de +1, que solo se prohibe en el ULTIMO slide de un archivo: ahi "la que
// sigue" es la primera de otra seccion, y el que escribe no la tiene a la vista.
const SIGUIENTE = /\bla\s+(?:slide\s+que\s+sigue|slide\s+siguiente|pr[óo]xima\s+slide)\b|\bthe\s+(?:next\s+slide|slide\s+that\s+follows)\b/gi;

const leer = f => readFile(f, 'utf8').catch(() => null);
const errores = [];
const linea = (t, i) => t.slice(0, i).split('\n').length;
// El texto matcheado, en una linea: un `nunca` que cruza un salto de linea
// dejaria el mensaje de error partido en dos.
const enUnaLinea = s => s.trim().replace(/\s+/g, ' ');

// El texto que se LEE de una figura, para poder declarar un `.svg` como lugar de
// un hecho. Es el extractor de `lint-i18n` regla 9 sin su filtro de
// monoespaciado: ahi se busca IDIOMA y el codigo no cuenta, aca se busca
// CONTENIDO y los nombres de clase estan justamente en mono. Sin esto una frase
// partida en dos <tspan> no matchea contra el XML crudo.
function textoDeFigura(svg) {
  const partes = [...svg.matchAll(/<title>([\s\S]*?)<\/title>/g)].map(m => m[1]);
  for (const m of svg.matchAll(/<text\b[^>]*>([\s\S]*?)<\/text>/g)) partes.push(m[1]);
  return partes.join(' ').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ');
}
const contenido = async ruta => {
  const t = await leer(ruta);
  return t === null || !ruta.endsWith('.svg') ? t : textoDeFigura(t);
};

// code/.uvm es la libreria vendorizada: la baja `make uvm` y el job de docs del
// CI no la tiene. Sin ella no se puede PROBAR que el hecho siga siendo cierto,
// pero si se puede chequear que los N lugares digan lo mismo entre si -- que es
// la parte que ataja el defecto. Un fuente que falta y NO es de la libreria si
// es un error: alguien borro o movio el archivo que sostiene el hecho.
const VENDORIZADA = /^code\/\.uvm\//;
let sinFuente = 0;

// --- Regla 1: los hechos ---
for (const h of HECHOS) {
  const [rutaF, reF, capturar] = h.fuente;
  const fuente = await leer(rutaF);
  if (fuente === null) {
    if (capturar) {
      // La salida que sostiene el numero todavia no la capturo nadie. El hecho
      // igual compara los lugares entre si, que es la mitad que se puede.
      errores.push(`${rutaF} — falta la salida capturada que sostiene "${h.que}": corre \`${capturar}\``);
    } else if (!VENDORIZADA.test(rutaF)) {
      errores.push(`${rutaF} — la fuente de "${h.que}" no existe`); continue;
    } else sinFuente++;
  } else if (!reF.test(fuente)) {
    const n = h.lugares.length;
    errores.push(`${rutaF} — cambio el hecho "${h.que}". Revisa ${n === 1 ? 'el lugar que lo repite' : `los ${n} lugares que lo repiten`} y actualiza este lint`);
    continue;
  }
  for (const [ruta, debe, nunca] of h.lugares) {
    const t = await contenido(ruta);
    if (t === null) { errores.push(`${ruta} — no existe, y "${h.que}" lo nombra`); continue; }
    if (debe && !debe.test(t)) errores.push(`${ruta} — quedo viejo: "${h.que}" (no dice ${debe})`);
    if (nunca && nunca.test(t)) errores.push(`${ruta} — dice lo contrario de "${h.que}" (${nunca})`);
  }
}

// --- Regla 2: las referencias de distancia ---
for (const dir of ['slides/es', 'slides/en']) {
  for (const f of (await readdir(dir)).filter(f => f.endsWith('.md'))) {
    const t = await leer(`${dir}/${f}`);
    for (const re of DISTANCIA) {
      for (const m of t.matchAll(re)) {
        errores.push(`${dir}/${f}:${linea(t, m.index)} — referencia de distancia "${enUnaLinea(m[0])}": nombra la slide, contar se pudre solo`);
      }
    }
    // El ultimo slide del archivo: lo que "sigue" es de otra seccion.
    const corte = t.lastIndexOf('\n---\n');
    const ultimo = corte < 0 ? t : t.slice(corte);
    for (const m of ultimo.matchAll(SIGUIENTE)) {
      errores.push(`${dir}/${f}:${linea(t, (corte < 0 ? 0 : corte) + m.index)} — "${enUnaLinea(m[0])}" en el ULTIMO slide del archivo: lo que sigue es otra seccion, nombrala`);
    }
  }
}

// --- Regla 3: las citas archivo:linea ---
// Se acepta con o sin backticks y con o sin parte de la ruta: la slide escribe
// `uvm_root.svh:1187` y tambien `seq/uvm_sequencer_base.svh:1258-1267`.
const RE_CITA = /(?:^|[\s`(\/])((?:[\w-]+\/)*[\w-]+\.svh?):(\d+)(?:-(\d+))?/g;
// Y la cita ABREVIADA, que solo lleva la linea: se resuelve contra el ultimo
// `.svh` que el archivo nombro antes. Los backticks son obligatorios, porque un
// `:NNN` suelto es cualquier cosa (un `@ 290:` de un log, una hora).
const RE_CITA_CORTA = /`:(\d+)(?:-(\d+))?`/g;
const RE_ARCHIVO = /((?:[\w-]+\/)*[\w-]+\.svh?)\b/g;
const hayUvm = await stat('code/.uvm').then(() => true, () => false);
let citasSinFuente = 0, citas = 0;

const indice = new Map();
async function* fuentes(dir) {
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (/(^|\/)obj_dir(\/|$)/.test(p)) continue;
    if (e.isDirectory()) yield* fuentes(p); else yield p;
  }
}
for await (const f of fuentes('code')) {
  const b = path.basename(f);
  if (!indice.has(b)) indice.set(b, []);
  indice.get(b).push(f);
}

// Chequea una cita ya resuelta a `ref`. Los dos extremos del rango tienen que
// existir y no estar en blanco: la cita corrida siempre empieza o termina en una
// linea vacia, que es lo que la delata.
async function chequeaCita(donde, ref, desde, hasta) {
  citas++;
  const cands = (indice.get(path.basename(ref)) || []).filter(p => p.endsWith(ref));
  if (!cands.length) {
    // Sin la libreria vendorizada no se puede resolver una cita a uvm_*.
    if (!hayUvm) { citasSinFuente++; return; }
    errores.push(`${donde} — cita \`${ref}:${desde}\` y ese archivo no existe`);
    return;
  }
  if (cands.length > 1) {
    errores.push(`${donde} — \`${ref}\` es ambiguo (${cands.length} archivos): agrega parte de la ruta`);
    return;
  }
  const src = (await leer(cands[0])).split('\n');
  for (const n of [desde, hasta].filter(Boolean).map(Number)) {
    if (n > src.length) errores.push(`${donde} — cita ${ref}:${n} y el archivo tiene ${src.length} lineas`);
    else if (!src[n - 1].trim()) errores.push(`${donde} — ${ref}:${n} es una linea EN BLANCO: la cita esta corrida`);
  }
}

// Los `docs/*.sh` graban los GIF del hero y citan la libreria adentro de la
// salida que simulan: nadie los miraba.
const CITADORES = [['slides/es', /\.md$/], ['slides/en', /\.md$/], ['docs', /\.(md|sh)$/], ['docs/en', /\.md$/]];
for (const [dir, ext] of CITADORES) {
  for (const f of (await readdir(dir)).filter(x => ext.test(x))) {
    const ruta = `${dir}/${f}`;
    const texto = await leer(ruta);
    for (const m of texto.matchAll(RE_CITA)) {
      await chequeaCita(`${ruta}:${linea(texto, m.index)}`, m[1], m[2], m[3]);
    }
    // El ultimo `.svh` nombrado antes de cada cita abreviada.
    const nombrados = [...texto.matchAll(RE_ARCHIVO)];
    for (const m of texto.matchAll(RE_CITA_CORTA)) {
      const previo = nombrados.filter(a => a.index < m.index).pop();
      const donde = `${ruta}:${linea(texto, m.index)}`;
      if (!previo) { errores.push(`${donde} — la cita \`:${m[1]}\` no tiene ningun archivo nombrado antes: escribi el nombre`); continue; }
      await chequeaCita(donde, previo[1], m[1], m[2]);
    }
  }
}

// --- Regla 4: el orden de las nueve fases, contra la libreria ---
// tools/datos-machete.mjs es la fuente unica de las tablas (tools/tablas.mjs las
// renderiza a los ocho destinos), pero el `orden` de cada fase sigue siendo un
// dato escrito a mano ahi. Esto lo ata a uvm_common_phases.svh, que es quien lo
// decide de verdad: `uvm_final_phase extends uvm_topdown_phase`. Es el hecho que
// el machete impreso tuvo mal durante dos revisiones.
const COMUNES = 'code/.uvm/src/base/uvm_common_phases.svh';
const src = await leer(COMUNES);
if (src === null) {
  sinFuente++;
} else {
  const { FASES } = await import('./datos-machete.mjs');
  const KIND = { topdown: 'top-down', bottomup: 'bottom-up', task: 'un thread c/u' };
  for (const f of FASES) {
    const m = src.match(new RegExp(`^class uvm_${f.fase}_phase extends uvm_(topdown|bottomup|task)_phase`, 'm'));
    if (!m) { errores.push(`${COMUNES} — no encontre \`uvm_${f.fase}_phase\`: cambio la libreria`); continue; }
    if (KIND[m[1]] !== f.orden) {
      errores.push(`tools/datos-machete.mjs — \`${f.fase}\` dice "${f.orden}" y la libreria dice "${KIND[m[1]]}" (${COMUNES})`);
    }
  }
}

// --- Regla 5: las horas de cada dia, con la agenda como fuente ---
// El total no se escribe: se suma. Los literales de mas de diez horas son los
// totales del curso; los de menos son la duracion de un dia. El `≈` es
// obligatorio a proposito -- `para-docentes.md` dice tambien "un cuatrimestre de
// 15 semanas con 2 h de teoria son 30 h", que no es un total del curso.
const RE_HORAS = /≈\s*(\d+)\s*h(?![a-záéíóúñ])(?:\s*(\d+))?/g;
const minutos = m => +m[1] * 60 + +(m[2] || 0);
const hhmm = n => (n % 60 ? `${(n / 60) | 0} h ${n % 60}` : `${n / 60} h`);

const agenda = new Map();   // dia -> minutos, segun las 8 agendas de slides/es
for (const dir of ['slides/es', 'slides/en']) {
  for (const f of (await readdir(dir)).filter(x => /agenda-day\d/.test(x))) {
    const dia = +f.match(/agenda-day(\d)/)[1];
    const t = await leer(`${dir}/${f}`);
    const m = new RegExp(String.raw`^#### \*(?:Día|Day) ${dia} · ≈\s*(\d+)\s*h(?:\s*(\d+))?`, 'm').exec(t);
    if (!m) { errores.push(`${dir}/${f} — no encontre el "≈ N h" del encabezado de la agenda del dia ${dia}`); continue; }
    const v = minutos(m);
    if (!agenda.has(dia)) agenda.set(dia, v);
    else if (agenda.get(dia) !== v) errores.push(`${dir}/${f} — el dia ${dia} dura ${hhmm(v)} y la agenda del otro idioma dice ${hhmm(agenda.get(dia))}`);
  }
}

// Las filas de los dos README y las tarjetas `class="cola"` de las dos landings.
const REPITEN = [
  ['README.es.md', /^\| \*\*(\d)\*\*.*\| ≈ ([^|]+)\|$/gm, 1, 2],
  ['README.md', /^\| \*\*(\d)\*\*.*\| ≈ ([^|]+)\|$/gm, 1, 2],
  ['web/index.html', /<p class="cola"><b>≈ ([^<]+)<\/b>/g, null, 1],
  ['web/en/index.html', /<p class="cola"><b>≈ ([^<]+)<\/b>/g, null, 1],
];
for (const [ruta, re, gDia, gHoras] of REPITEN) {
  const t = await leer(ruta);
  if (t === null) { errores.push(`${ruta} — no existe, y ahi se repiten las horas de cada dia`); continue; }
  let n = 0;
  for (const m of t.matchAll(re)) {
    const dia = gDia ? +m[gDia] : ++n;
    const v = minutos(/(\d+)\s*h(?:\s*(\d+))?/.exec(m[gHoras]));
    if (!agenda.has(dia)) { errores.push(`${ruta}:${linea(t, m.index)} — habla del dia ${dia} y no hay agenda-day${dia}`); continue; }
    if (agenda.get(dia) !== v) {
      errores.push(`${ruta}:${linea(t, m.index)} — el dia ${dia} dura ${hhmm(v)} aca y ${hhmm(agenda.get(dia))} en slides/es/*agenda-day${dia}.md, que es la fuente`);
    }
  }
}

// Y los totales: la suma de los siete dias y la de los ocho.
const suma = d => [...agenda].filter(([k]) => k <= d).reduce((a, [, v]) => a + v, 0);
const TOTALES = [suma(7), suma(8)];
for (const ruta of ['README.es.md', 'README.md', 'docs/para-docentes.md', 'docs/en/for-teachers.md',
  'slides/es/002-como-usar.md', 'slides/en/002-como-usar.md', 'web/index.html', 'web/en/index.html']) {
  const t = await leer(ruta);
  if (t === null) continue;
  for (const m of t.matchAll(RE_HORAS)) {
    const v = minutos(m);
    if (v < 600 || TOTALES.includes(v)) continue;
    errores.push(`${ruta}:${linea(t, m.index)} — dice "${m[0]}" y las 8 agendas suman ${hhmm(TOTALES[0])} los siete dias y ${hhmm(TOTALES[1])} con el dia 8`);
  }
}

// --- Regla 6: un bloque que cita la libreria sin `:NNN` ---
// Solo adentro de un fence: en prosa nombrar `uvm_agent.svh` para decir "se
// puede abrir" es legitimo y hay cuatro. Adentro de un bloque que dice mostrar
// la libreria, el nombre sin linea es una cita que nadie puede verificar.
const RE_FENCE = /^```[\s\S]*?^```/gm;
if (hayUvm) {
  for (const dir of ['slides/es', 'slides/en']) {
    for (const f of (await readdir(dir)).filter(x => x.endsWith('.md'))) {
      const t = await leer(`${dir}/${f}`);
      for (const bloque of t.matchAll(RE_FENCE)) {
        for (const m of bloque[0].matchAll(/([\w-]+\.svh)(?!:\d)/g)) {
          const cands = indice.get(m[1]) || [];
          if (!cands.some(p => p.startsWith('code/.uvm/'))) continue;
          errores.push(`${dir}/${f}:${linea(t, bloque.index + m.index)} — el bloque cita \`${m[1]}\` sin \`:NNN\`: agrega el rango de lineas o la cita no se puede verificar`);
        }
      }
    }
  }
}

// --- Regla 7: "la slide N del dia M" ---
// El orden real: los archivos de slides/es en orden, cortados en cada
// agenda-dayN, y cada slide separada por `---`. La slide 1 de un dia es siempre
// su agenda, que no dice nada de contenido: una referencia de contenido que cae
// ahi esta mal por construccion.
const RE_SLIDE_N = /\bla\s+slide\s+(\d+)\s+del\s+d[íi]a\s+(\d)|\bslide\s+(\d+)\s+of\s+day\s+(\d)/gi;
const porDia = new Map();
{
  let dia = 0;
  for (const f of (await readdir('slides/es')).sort().filter(x => x.endsWith('.md'))) {
    const m = f.match(/agenda-day(\d)/);
    if (m) dia = +m[1];
    const t = await leer(`slides/es/${f}`);
    if (!porDia.has(dia)) porDia.set(dia, []);
    porDia.get(dia).push([f, t.split('\n').filter(l => l === '---').length + 1]);
  }
}
for (const dir of ['slides/es', 'slides/en']) {
  for (const f of (await readdir(dir)).filter(x => x.endsWith('.md'))) {
    const t = await leer(`${dir}/${f}`);
    for (const m of t.matchAll(RE_SLIDE_N)) {
      const n = +(m[1] ?? m[3]), dia = +(m[2] ?? m[4]);
      const donde = `${dir}/${f}:${linea(t, m.index)}`;
      const archivos = porDia.get(dia);
      if (!archivos) { errores.push(`${donde} — "${enUnaLinea(m[0])}" y no hay un dia ${dia}`); continue; }
      let resto = n, cae = null;
      for (const [nombre, cuantas] of archivos) { if (resto <= cuantas) { cae = nombre; break; } resto -= cuantas; }
      if (!cae) { errores.push(`${donde} — "${enUnaLinea(m[0])}" y el dia ${dia} tiene ${archivos.reduce((a, b) => a + b[1], 0)} slides`); continue; }
      if (/agenda-day/.test(cae)) {
        errores.push(`${donde} — "${enUnaLinea(m[0])}" cae en ${cae}, que es la agenda del dia: nombra la slide en vez de contarla`);
      }
    }
  }
}

// --- Regla 8: los ordinales sobre las filas de la autoevaluacion ---
// Seis de las siete agendas citan la fila por numero y todas cierran; la del dia
// 1 usa un ordinal y es la unica que miente. El numero se puede verificar contra
// `175b-autoevaluacion.md`, el ordinal no.
const RE_ORDINAL = /\b(?:primeras?|últimas?|siguientes)\s+\w*\s*filas?\s+de\s+la\s+autoevaluaci[óo]n|\b(?:first|last|next)\s+\w+\s+rows?\s+of\s+the\s+(?:closing\s+)?self-assessment/gi;
for (const dir of ['slides/es', 'slides/en']) {
  for (const f of (await readdir(dir)).filter(x => /agenda-day\d/.test(x))) {
    const t = await leer(`${dir}/${f}`);
    for (const m of t.matchAll(RE_ORDINAL)) {
      errores.push(`${dir}/${f}:${linea(t, m.index)} — "${enUnaLinea(m[0])}": cita la fila de la autoevaluacion por NUMERO, que es lo que hacen las otras seis agendas y lo unico verificable`);
    }
  }
}

if (errores.length) {
  console.error(`✗ ${errores.length} problema(s) de coherencia:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
const lugares = HECHOS.reduce((n, h) => n + h.lugares.length, 0);
console.log(`✓ lint de coherencia: ${HECHOS.length} hechos con ${lugares} lugares al dia, y ninguna referencia de distancia`);
console.log(`✓ lint de citas: ${citas} citas archivo:linea, todas a una linea que existe y no esta en blanco`);
console.log(`✓ lint de agendas: ${agenda.size} dias, ${hhmm(TOTALES[0])} los siete y ${hhmm(TOTALES[1])} con el dia 8`);
if (sinFuente || citasSinFuente) console.log(`  (${sinFuente} hecho(s) y ${citasSinFuente} cita(s) sin verificar: code/.uvm no esta vendorizada — corre 'make uvm')`);
