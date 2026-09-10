// La fuente unica de las dos tablas que viven repetidas: las nueve fases y las
// siete perillas de debug.
//
// Antes cada una estaba escrita a mano en cuatro lugares --la slide ES, la slide
// EN, res/machete.html y res/en/machete.html-- y el dia que una cambio, cambio
// en tres. El machete impreso decia que `final` es bottom-up mientras la slide
// del mismo dia decia top-down, que es lo correcto. El alumno se lleva el papel.
//
// Aca esta el dato; tools/tablas.mjs lo renderiza a cada destino entre marcadores
// `<!-- tabla: N -->` ... `<!-- tabla: end -->`, y `npm run check` falla si algun
// destino quedo viejo. Que el `orden` de cada fase siga siendo el que dice la
// libreria lo verifica tools/lint-coherencia.mjs contra uvm_common_phases.svh.
//
// Para cambiar una fila: aca, y `npm run build`.

// `fuerte` son las dos que el machete resalta: la unica top-down de arranque y
// la unica que consume tiempo.
export const FASES = [
  { fase: 'build',              orden: 'top-down',     fuerte: true,
    es: 'instanciar los componentes',            en: 'instantiate the components' },
  { fase: 'connect',            orden: 'bottom-up',
    es: 'conectar los ports',                    en: 'connect the ports' },
  { fase: 'end_of_elaboration', orden: 'bottom-up',
    es: 'jerarquía lista, antes de simular',     en: 'hierarchy ready, before simulating' },
  { fase: 'start_of_simulation', orden: 'bottom-up',
    es: 'último aviso antes del tiempo 0',       en: 'last call before time 0' },
  { fase: 'run',                orden: 'un thread c/u', ordenEn: 'one thread each', fuerte: true,
    es: '**task**: acá pasa la simulación',      en: '**task**: this is where the simulation happens' },
  { fase: 'extract',            orden: 'bottom-up',
    es: 'juntar los datos de la corrida',        en: 'gather the data from the run' },
  { fase: 'check',              orden: 'bottom-up',
    es: 'decidir si pasó o no',                  en: 'decide whether it passed' },
  { fase: 'report',             orden: 'bottom-up',
    es: 'imprimir el veredicto',                 en: 'print the verdict' },
  { fase: 'final',              orden: 'top-down',
    es: 'cerrar archivos y salir',               en: 'close files and exit' },
];

// Las dos tablas de perillas NO tienen las mismas columnas --la slide dice en que
// seccion salio cada una, el machete que sintoma resuelve-- pero si tienen que
// tener las mismas siete filas, en el mismo orden, y coincidir en cuales son
// plusargs. Eso es lo que se comparte.
export const PERILLAS = [
  { perilla: '`VLT_TRACE=1` + GTKWave', machete: 'VLT_TRACE=1', plusarg: false,
    es: 'ver las señales de verdad',                              en: 'see the real signals',
    dondeEs: 'La spec del VTALU',                                 dondeEn: 'The VTALU spec',
    sintomaEs: 'cuando el log ya no alcanza — el 47 % del trabajo',
    sintomaEn: 'when the log is no longer enough — 47 % of the work' },
  { perilla: '`+UVM_VERBOSITY=UVM_HIGH`', machete: '+UVM_VERBOSITY=UVM_HIGH', plusarg: true,
    es: 'ver los mensajes de los monitores',                      en: 'see the monitors’ messages',
    dondeEs: 'Reporting',                                         dondeEn: 'Reporting',
    sintomaEs: 'el scoreboard <b>grita en todas</b>: el monitor muestrea mal, el DUT casi nunca es',
    sintomaEn: 'the scoreboard <b>screams on every one</b>: the monitor samples wrong, the DUT almost never is' },
  { perilla: '`+UVM_CONFIG_DB_TRACE`', machete: '+UVM_CONFIG_DB_TRACE', plusarg: true,
    es: 'quién puso qué en el `config_db`, y quién lo leyó',       en: 'who put what in the `config_db`, and who read it',
    dondeEs: 'Agents',                                            dondeEn: 'Agents',
    sintomaEs: 'el <span class="m">config_db</span> «no encuentra»: mirá el ámbito del <span class="m">set</span>, no el <span class="m">get</span>',
    sintomaEn: 'the <span class="m">config_db</span> “does not find it”: look at the scope of the <span class="m">set</span>, not the <span class="m">get</span>' },
  { perilla: '`+TOPOLOGY` → `print_topology()`', machete: '+TOPOLOGY<br>&nbsp;&nbsp;→ print_topology()', plusarg: true,
    es: 'el árbol que UVM armó **de verdad**',                    en: 'the tree UVM **actually** built',
    dondeEs: 'Agents',                                            dondeEn: 'Agents',
    sintomaEs: 'el árbol no es el que dibujaste: un <span class="m">create()</span> sin factory, o un override tardío',
    sintomaEn: 'the tree is not the one you drew: a <span class="m">create()</span> without the factory, or a late override' },
  { perilla: '`+UVM_OBJECTION_TRACE`', machete: '+UVM_OBJECTION_TRACE', plusarg: true,
    es: 'quién levantó y quién bajó la objection',                en: 'who raised and who dropped the objection',
    dondeEs: 'Tests',                                             dondeEn: 'Tests',
    sintomaEs: 'termina en <b>t = 0</b> y dice PASS, o <b>no termina nunca</b>',
    sintomaEn: 'it ends at <b>t = 0</b> and says PASS, or it <b>never ends</b>' },
  { perilla: '`+UVM_TIMEOUT=N,NO`', machete: '+UVM_TIMEOUT=5000000,NO', plusarg: true,
    es: 'un techo para el cuelgue, en vez de esperar',            en: 'a ceiling for the hang, instead of waiting',
    dondeEs: 'Tests',                                             dondeEn: 'Tests',
    sintomaEs: 'la simulación se colgó y no sabés dónde',
    sintomaEn: 'the simulation hung and you do not know where' },
  { perilla: '`+UVM_MAX_QUIT_COUNT=N`', machete: '+UVM_MAX_QUIT_COUNT=N', plusarg: true,
    es: 'matar la corrida al N-ésimo error',                      en: 'kill the run at the Nth error',
    dondeEs: 'Reporting',                                         dondeEn: 'Reporting',
    sintomaEs: 'el log de cuatro gigas cuando el scoreboard falla en cada transacción',
    sintomaEn: 'the four-gigabyte log when the scoreboard fails on every transaction' },
];

export const PLUSARGS = PERILLAS.filter(p => p.plusarg).length;
