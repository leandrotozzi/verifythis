// Lint de referencias: que el curso no le diga al alumno algo que ya no existe.
//
// Tres reglas, las tres sobre el mismo problema -- una referencia que envejece
// sin que nada la contradiga. Todas se descubrieron el mismo dia: la landing
// mostraba `make ch11`, que dejo de existir cuando los capitulos pasaron a ser
// ocho unidades.
//
//   1. Comandos `make chNN`, que ya no son targets del Makefile.
//   2. Vocabulario viejo: "capitulo N" / "cap. N" en material del alumno.
//      El curso tiene ocho unidades con secciones adentro, sin numeracion.
//   3. Links relativos rotos en los .md (el ROADMAP.md borrado seguia linkeado
//      desde docs/en-que-se-diferencia.md).
//   3b. La generalizacion de la 1: CUALQUIER `make loquesea` escrito como
//      comando (adentro de backticks o de un <code>) que no sea un target del
//      Makefile. La regla 1 solo cachaba `make chNN`, o sea el unico caso que
//      ya habia pasado; esta cacha el proximo -- renombrar code/u7/agents deja
//      muerto el `make u7/agents` que citan los docs, y hasta hoy no avisaba
//      nada. Los targets no se listan a mano: los literales salen del Makefile
//      y los de ejemplo se deducen de los run*.sh, igual que el wildcard.
//   3c. Los links a github.com/<repo>/blob/master/<ruta>: la ruta tiene que
//      existir en el repo. La landing linkea siete docs asi, y renombrar uno da
//      un 404 que solo se ve en produccion. Es lo mismo que la regla 3 pero
//      para links que parecen externos y en realidad apuntan a este repo, o
//      sea los que un link-checker de red tampoco puede validar antes de
//      publicar.
//   4. Numeros de inventario -- cuantos ejemplos, ejercicios, slides, secciones,
//      preguntas, dias, figuras, trampas y bloques de codigo tiene el curso --
//      contra lo que hay en el filesystem (tools/inventario.mjs). Un numero
//      escrito a mano envejece solo, y estos viven repartidos en ~25 lugares
//      entre el README, la landing, el CITATION.cff, los docs y las slides:
//      agregar una slide rompia media docena de frases sin que nada avisara.
//      Se controlan las dos formas, "37 ejemplos" y "catorce soluciones".
//   4b. El numeral SUELTO: el que ocupa el lugar del sustantivo en vez de
//      llevarlo pegado. "Las 21 trampas mudas -- la causa de este bug es una de
//      las diecinueve" (code/ejercicios/d5/README.es.md:58) dice los dos
//      numeros en la misma vineta y la regla 4 solo ve el primero, porque el
//      segundo cierra la oracion sin sustantivo detras. Lo mismo el "no en las
//      400" de docs/editar.md, que quedo viejo cuando el deck paso a 444.
//   5. El corrector honesto. Un `run.sh` de code/ejercicios/ decide si el
//      ejercicio esta resuelto grepeando literales del log; si el que imprime
//      ese literal es un archivo del PROPIO directorio que el alumno edita, el
//      ejercicio se aprueba reescribiendo el $display. Paso cuatro veces:
//      d5b se pasa sin tocar el dist, d1 sin implementar el shift, d2 sin
//      escribir mult_tester y d5c asignando a mano los tres campos que el
//      enunciado prohibe asignar a mano.
//   6. Los sellos, las dos mitades. Un archivo que dice "do not touch" en su
//      comentario tiene que estar listado en el intocables.sha del ejercicio
//      (d5c/chequeo.svh lo dice y no lo esta), y un run.sh que llama a
//      `intocables` tiene que tener el .sha al lado -- porque intocables()
//      devuelve 0 en silencio cuando el archivo falta, asi que borrarlo apaga
//      el unico mecanismo que impide resolver el ejercicio editando el andamiaje.
//   7. TODO(exercise X) dentro de code/ejercicios/<dir>/ tiene que decir el
//      nombre del directorio. Quince marcadores dicen el numero del dia
//      ("exercise 3"), que desde que existen d3 y d3b no nombra a nadie.
//   8. Todo {{code:ruta}} apunta a un archivo que ALGUN build alcanza -- un
//      .f, un `include o la linea vlt de un run.sh. code/README.md dice que las
//      slides no pegan codigo sino que lo incluyen, justamente para que no haya
//      dos copias; once archivos de code/ son copias a mano que ningun build
//      compila, y ya divergieron del original que dicen mostrar.
//   9. Al reves que la 8: todo marcador `// cb: <id>` de code/ tiene que estar
//      citado por alguna directiva. codigo.mjs falla si una directiva pide un
//      marcador que no existe, y nadie mira el caso inverso: el marcador
//      huerfano de d8-dpi/solucion/vtalu_golden.c es peso muerto que se pudre.
//  10. La generalizacion de la 3: las rutas del repo escritas en PROSA, adentro
//      de backticks, de un <code> o de un comentario. El doc de nivelacion
//      manda a abrir code/u2/convencional/vtalu_pkg.sv, que no existe, y es el
//      primer archivo que abre un principiante.
//  11. El #ancla de un link .md -> .html: hoy RE_LINK la matchea solo para
//      tirarla. docs/uvm-en-la-entrevista.md manda a un id inventado y al dia
//      equivocado, y como el archivo existe nadie avisa.
//  12. Un .md nombrado adentro de backticks del que no exista NINGUN archivo
//      con ese basename. `README.en.md` es el nombre de antes del rename y
//      cinco lugares se lo piden al alumno, uno de ellos un comando de una sola
//      linea que falla al pegarlo.
//  13. Los indices de docs/ y docs/en/: todo archivo del directorio esta
//      linkeado desde su README.md. docs/en/README.md lista siete de ocho.
//  14. Un link relativo a .github/ISSUE_TEMPLATE/*.yml abre el YAML, no el
//      formulario. El destino util es issues/new?template=<archivo>, y asi esta
//      escrito en los otros dos lugares del repo.
//  15. La tabla del cuatrimestre de la guia docente: la primera columna tiene
//      que ser 1..N consecutiva y N el numero del titulo. "Las 15 semanas"
//      trae dieciseis clases porque se colo una fila 10b, y la cuenta de horas
//      de tres parrafos mas arriba se hizo con quince.
//  15b. Y el orden: los titulos de seccion que nombra cada fila de esa tabla
//      van en el orden del deck. La fila 10b da vuelta las dos secciones del
//      dia 4 y le pega la glosa --"(put/get y la FIFO)"-- a la que no es.
//  16. Los rangos del banco de examen contra la tabla de semanas: un parcial no
//      puede tomar preguntas del dia que se dicta en esa misma clase. El
//      Parcial 2 cubre 16-35 y las 31-35 son de constrained random, que es lo
//      que se da esa semana.
//  17. Toda ruta code/ejercicios/<x> citada en slides/ existe. La primera
//      instruccion concreta del curso promete code/ejercicios/dN y los dias 6,
//      7 y 8 no siguen ese patron.
//
// Uso: node tools/lint-refs.mjs
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { inventario } from './inventario.mjs';
import { RE_CODE } from './codigo.mjs';
import { SALIDAS } from './i18n.mjs';

// Las slides de cada idioma se sirven desde donde vive su index.html: las de
// slides/es/ desde la raiz, las de slides/en/ desde en/. Una ruta relativa a
// esa raiz es valida aunque no lo sea desde el .md que la escribe.
const RAIZ_SERVIDA = Object.fromEntries(Object.values(SALIDAS)
  .map(s => [path.normalize(s.slides), path.dirname(s.html)]));

// Se revisa lo que lee el alumno. code/.uvm es la libreria vendorizada y
// node_modules/vendor no son nuestros.
const RAICES = ['slides', 'docs', 'code', 'web', 'tools', '.github'];
// CITATION.cff entra aca y no por extension: es el archivo que cita un
// profesor en un programa de materia, o sea el peor lugar para un numero
// viejo, y era el unico de la fase 12.1 que este lint no miraba.
// README.es.md entra porque es la FUENTE del README: cuando el README pasó a
// ingles, el castellano -- el que se escribe primero -- se quedaba sin chequeo
// de numeros, de links y de targets. El rename abrio el agujero en silencio.
// NOTICE y LICENSE, porque no estaban y por eso el "13 ejercicios" del NOTICE
// sobrevivio la fase 12.1 entera.
const SUELTOS = ['README.md', 'README.es.md', 'CONTRIBUTING.md',
                 'Makefile', 'CITATION.cff', 'NOTICE', 'LICENSE'];
const EXT = new Set(['.md', '.html', '.sv', '.svh', '.sh', '.mjs', '.yml', '.xml']);
const IGNORAR = /(^|\/)(node_modules|vendor|\.git|\.uvm|obj_dir|dist|libro)(\/|$)/;

const RE_MAKE_CH = /\bmake\s+ch\d+/g;
// "24 capitulos" es el libro de Salemi, no el curso: esa referencia es correcta.
const RE_CAP = /\b(cap\.\s*\d|cap[ií]tulos?\s+\d)/gi;
const EXCEPCION_CAP = /24 cap[ií]tulos|tiene 24/i;
// Solo links relativos a archivos del repo: nada de http ni mailto. El ancla
// se captura en vez de tirarse: la regla 11 la necesita.
const RE_LINK = /\]\(([^)#?:\s]+?)(?:#([^)]*))?\)/g;
// Un <img> que declara un alto que no es el de la imagen la deforma, y el
// navegador reserva el hueco equivocado. Paso dos veces el mismo dia: la
// og:image de las dos landings decia 1400x875 sobre un archivo de 1200x630, y
// los README declaraban la relacion de la portada anterior. Nadie lo ve en el
// diff -- hay que abrir el PNG.
const RE_IMG = /<img\b[^>]*>/gi;
const ATTR = (t, k) => (t.match(new RegExp(`${k}\\s*=\\s*["']([^"']+)["']`, 'i')) ?? [])[1];

// Un `make X` escrito como COMANDO. El scope importa: en prosa en ingles
// "make sure", "make sense" y "make them" son media docena de falsos positivos
// por archivo, y `sudo apt install git make g++` es otro. Adentro de backticks
// o de un <code>, y en el arranque del comando (o despues de un ; && | $), no
// queda ninguno.
const RE_MAKE = /`([^`\n]+)`|<code[^>]*>([^<]+)<\/code>/g;
const RE_MAKE_CMD = /(?:^|[;&|$]\s*)make\s+([A-Za-z0-9_][A-Za-z0-9_/.-]*)/;
// Los links a ESTE repo, que apuntan a un archivo que tenemos al lado. El slug
// sale del CITATION.cff y no de una constante: es el unico lugar donde ya
// estaba escrito. Los links a repos AJENOS (lowRISC/style-guides, por decir)
// no se pueden chequear asi -- esos son trabajo de `lint-web.mjs --red`.
const REPO = (await readFile('CITATION.cff', 'utf8').catch(() => ''))
  .match(/repository-code:\s*"?https:\/\/github\.com\/([\w.-]+\/[\w.-]+)/)?.[1];
const RE_GH = REPO && new RegExp(String.raw`https://github\.com/${REPO}/(?:blob|raw|tree)/(?:master|main)/([^)"'\`\s>]+)`, 'g');

// Regla 4: los numeros que el curso repite en prosa. El valor real lo cuenta
// tools/inventario.mjs desde el filesystem, no una constante -- una slide nueva
// se cuenta sola. La palabra que sigue al numero es la que lo hace inequivoco.
//
// El sustantivo puede venir separado por un salto de linea (la prosa del repo
// va a 80 columnas), por eso \s+ y no un espacio.
// Los sustantivos van en los dos idiomas: la landing y el README en ingles son
// justo donde un numero viejo no lo ve nadie, porque el que lo escribio lee la
// version en castellano.
const NOMBRES = {
  ejemplos:   /ejemplos|examples/,
  ejercicios: /ejercicios|soluciones|exercises|solutions/,
  slides:     /slides|diapositivas/,
  secciones:  /secciones|sections/,
  preguntas:  /preguntas|questions/,
  // "dias" queda AFUERA por lo mismo que "unidades": no es un numero solo.
  // Son siete de curso mas un octavo OPCIONAL, y la prosa dice las dos cosas
  // segun de que este hablando -- "siete dias de clase" y "ocho dias en el
  // libro" son las dos ciertas. Se sigue contando en el inventario.
  figuras:    /figuras|figures/,
  trampas:    /trampas|traps/,
  // El unico numero del inventario por debajo de diez, y por eso el unico que
  // se escribe siempre con letras: "los cuatro apendices". El deck rotula tres
  // secciones "## Apendice ·" y la prosa dice cuatro en seis lugares, porque a
  // veces cuenta el glosario y a veces no. Lleva su excepcion al piso de diez.
  apendices:  /apéndices|apendices|appendices/,
  // "bloques" queda AFUERA a proposito: el deck tiene 216 bloques de codigo y
  // 157 de ellos vienen de code/, y la prosa usa las dos cuentas segun de que
  // este hablando. Una palabra con dos significados no se puede chequear sin
  // que el lint mienta la mitad de las veces. Para la segunda cuenta el
  // inventario ya expone `recortes`, y {{count:recortes}} la escribe sola.
  // "recortes" tampoco entra como sustantivo: en la guia docente la palabra
  // nombra otra cosa --lo que se saca cuando no entra el cuatrimestre--.
};

// Los numeros escritos con letras. De diez para arriba, salvo los que hacen
// falta para "apendices": por debajo de diez un "cuatro fases" o un "cinco
// slides mas adelante" es un conteo local y no el inventario del curso, y por
// eso los chicos solo se miran cuando el sustantivo es apendices (abajo).
const PALABRAS = {
  diez: 10, once: 11, doce: 12, trece: 13, catorce: 14, quince: 15,
  dieciseis: 16, dieciséis: 16, diecisiete: 17, dieciocho: 18, diecinueve: 19,
  veinte: 20, treinta: 30, cuarenta: 40, cincuenta: 50,
  ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15,
  sixteen: 16, seventeen: 17, eighteen: 18, nineteen: 19,
  twenty: 20, thirty: 30, forty: 40, fifty: 50,
  dos: 2, tres: 3, cuatro: 4, cinco: 5, seis: 6, siete: 7, ocho: 8, nueve: 9,
  two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9,
};
// El piso: de diez para abajo casi siempre es un conteo local. La excepcion es
// el unico numero del inventario que vive ahi.
const PISO = que => (que === 'apendices' ? 2 : 10);

// Conteos legitimos que usan las mismas palabras y NO son el inventario.
//   "Dia 6 - 10 preguntas"        el repaso de un dia, no el banco entero
//   "Day 6 - 10 questions"        lo mismo en el banco en ingles
//   "1 de cada 257 soluciones"    el solver SMT, que resuelve otra cosa
//   "cinco slides mas adelante"   una referencia relativa
const LOCALES = /solve|solver|constraint|randomize|z3|LRM|m[aá]s (adelante|atr[aá]s)/i;
// El marcador de dia iba adentro de LOCALES, que mira 45 caracteres a CADA lado.
// Demasiado: la linea del hero del README —"...un dia 8 opcional— · 400 slides ·
// **38 ejemplos**"— tiene un "dia 8" a 35 caracteres, asi que el numero mas
// importante del repo quedaba exento y podia envejecer sin que nadie avisara.
// Lo que hay que proteger es "## Dia 6 · 10 preguntas", donde el marcador va
// PEGADO adelante. Nueve caracteres, no cuarenta y cinco.
// Y un caso aparte, porque solo se reconoce por lo que viene ANTES del numero:
// "los otros doce ejercicios" son los que no son el capstone, no los catorce.
const RELATIVO = /\b(otr[oa]s?|dem[aá]s|primer[oa]s?|[uú]ltim[oa]s?|siguientes|restantes|other|others|first|last|remaining|previous)\s+$/i;
// "Dia 6 · 10 preguntas": el conteo es de ESE dia, no del curso. Solo cuenta si
// el marcador esta inmediatamente antes del numero.
const DIA_ANTES = /\bD(?:[ií]a|ay)\s+\d+\s*[·\-—:|]?\s*$/i;
// Regla 4b: el numeral que REEMPLAZA al sustantivo va detras de un articulo
// plural ("no en las 400", "una de las diecinueve"). Sin esa ancla la regla
// mide todos los numeros del parrafo y se come los minutos, los porcentajes y
// los numeros de fila: 29 hits para cuatro hallazgos, medido. Con ella, tres.
const ARTICULO = /\b(las|los|the|estas|estos|these|those)\s+$/i;

const errores = [];

async function archivos(dir) {
  const out = [];
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (IGNORAR.test(p)) continue;
    if (e.isDirectory()) out.push(...await archivos(p));
    else if (EXT.has(path.extname(e.name))) out.push(p);
  }
  return out;
}

const existe = async p => stat(p).then(() => true, () => false);

const REAL = await inventario();

// Los targets que el Makefile sabe hacer HOY. Ninguno escrito a mano: los
// literales salen del propio Makefile y los de ejemplo de los run*.sh, que es
// de donde los saca el wildcard. Un ejemplo nuevo entra solo; uno renombrado
// deja en rojo a todos los docs que lo citan, que es el punto.
const makefile = await readFile('Makefile', 'utf8');
const TARGETS = new Set([...makefile.matchAll(/^([a-zA-Z][A-Za-z0-9_-]*):(?!=)/gm)].map(m => m[1]));
for (const f of await archivos('code')) {
  const p = f.split(path.sep).join('/');
  const m = p.match(/^code\/(u\d+\/.+)\/run[^/]*\.sh$/);
  if (!m) continue;
  TARGETS.add(m[1]);                     // make u7/agents
  TARGETS.add(m[1].split('/')[0]);       // make u7
}

// Un numero seguido de un sustantivo del inventario, en digitos o en letras.
// La segunda palabra tambien se prueba: en ingles el adjetivo se mete en el
// medio -- "19 silent traps", "38 running examples" -- y la regla, escrita para
// el castellano, solo miraba la palabra pegada al numero. Se le escapo un
// "19 silent traps" en el README en ingles cuando ya eran 20, con la fila espejo
// en castellano ("20 trampas mudas") correcta al lado.
//
// Y dos agujeros mas del mismo hueco, los dos medidos con cero falsos positivos:
//
//   HUECO   entre el numero y el sustantivo puede haber un salto de linea --la
//           prosa va a 80 columnas-- y ENCIMA el marcador de la linea siguiente:
//           el "> " de un blockquote o el "- " de una lista. README.es.md dice
//           "los mismos 15\n> ejercicios" y el \s+ chocaba con el ">", asi que
//           el numero viejo estaba en la FUENTE y el bueno en la traduccion.
//   PALABRA el adjetivo del medio puede llevar guion. "18 self-checking
//           exercises" en la landing en ingles: la primera palabra era "self",
//           la segunda no existia --venia un "-"-- y "exercises" quedaba fuera
//           de alcance, con la fila espejo en castellano correcta al lado.
const HUECO = String.raw`(?:\s|^[>\-*]\s)+`;
const PALABRA = String.raw`[a-záéíóúñ]+(?:-[a-záéíóúñ]+)*`;
const RE_INVENTARIO = new RegExp(
  String.raw`\b(\d+|${Object.keys(PALABRAS).join('|')})${HUECO}(${PALABRA})(?:${HUECO}(${PALABRA}))?`, 'gim');
// Un numero solo, para la regla 4b.
const RE_NUMERAL = new RegExp(String.raw`\b(\d+|${Object.keys(PALABRAS).join('|')})\b`, 'gi');

// En la landing los numeros van partidos por tags -- <b>400</b><span>slides</span> --
// y asi se le escapan a la regla 4, que es justo donde mas duele: el numero que
// ve el que llega de Google. Los tags se reemplazan por espacios del MISMO largo,
// para que los indices y por lo tanto los numeros de linea sigan valiendo.
const sinTags = s => s.replace(/<[^>]+>/g, m => ' '.repeat(m.length));

// Lo que NO es prosa: bloques de codigo, codigo inline, {{directivas}},
// comentarios, tags, el destino de un link y las URLs. Se borra reemplazando
// por espacios del mismo largo, para no correr las lineas. Es la misma receta
// que usa lint-i18n.mjs para su detector de castellano; aca hace falta porque
// la regla 4b mide numeros sueltos y una ruta como slides/es/010-tendencias.md
// tiene tres.
const enBlanco = m => m.replace(/[^\n]/g, ' ');
const soloProsa = s => s
  .replace(/```[\s\S]*?```/g, enBlanco)
  .replace(/`[^`\n]*`/g, enBlanco)
  .replace(/\{\{[^}]*\}\}/g, enBlanco)
  .replace(/<!--[\s\S]*?-->/g, enBlanco)
  .replace(/<[^>]+>/g, enBlanco)
  .replace(/\]\([^)]*\)/g, enBlanco)
  .replace(/https?:\/\/\S+/g, enBlanco)
  // Un numero adentro de comillas es un EJEMPLO citado, no una afirmacion:
  // docs/editar.md cita *"las 45\npreguntas"* para explicar esta misma regla.
  .replace(/"[^"\n]*"/g, enBlanco);

// Los parrafos de un texto: corridas de lineas no vacias, cortadas ademas en
// cada vineta, titulo, fila de tabla y cita. Una vineta es una unidad de prosa
// -- "Las 21 trampas mudas ... una de las diecinueve" es toda la misma-- y la
// de al lado no tiene nada que ver.
function parrafos(t) {
  const out = [];
  let acc = '', ini = 0, pos = 0;
  for (const l of t.split('\n')) {
    if (/^\s*$/.test(l) || /^\s*([-*+]|\d+\.|#|\||>)/.test(l)) {
      if (acc.trim()) out.push([ini, acc]);
      acc = '';
    }
    if (!/^\s*$/.test(l)) { if (!acc) ini = pos; acc += (acc ? '\n' : '') + l; }
    pos += l.length + 1;
  }
  if (acc.trim()) out.push([ini, acc]);
  return out;
}

// El tamaño real, leido de la cabecera. PNG y GIF alcanzan: son los dos formatos
// rasterizados del repo. Un SVG no tiene tamaño intrinseco obligatorio, asi que
// no se controla.
async function tamano(f) {
  const b = await readFile(f).catch(() => null);
  if (!b) return null;
  if (b.length > 24 && b.toString('ascii', 1, 4) === 'PNG')
    return [b.readUInt32BE(16), b.readUInt32BE(20)];
  if (b.length > 10 && b.toString('ascii', 0, 3) === 'GIF')
    return [b.readUInt16LE(6), b.readUInt16LE(8)];
  return null;
}

// Todos los archivos del repo, sin filtrar por extension: las reglas 10 y 12
// preguntan "existe algo que se llame asi", no "existe un .md que se llame asi".
// Y sin el IGNORAR de arriba, que saltea lo que este lint no LEE: la libreria
// vendorizada, el libro generado y dist/ no se leen, pero sus archivos existen
// y la prosa los nombra -- code/.uvm/src/comps/uvm_agent.svh es una cita, no un
// nombre inventado.
async function todos(dir, out = []) {
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (/(^|\/)(node_modules|\.git|obj_dir|_site)$/.test(p)) continue;
    if (e.isDirectory()) await todos(p, out); else out.push(p);
  }
  return out;
}
const TODOS = await todos('.');
const BASENAMES = new Set(TODOS.map(f => path.basename(f)));

// Regla 10: las rutas del repo escritas en prosa. El primer segmento las
// reconoce, y el que las escribe las escribe desde la raiz del repo.
const RE_RUTA = /\b(?:code|docs|slides|res|tools|web|libro|en)\/[\w./-]+/g;
// Lo que NO es una ruta rota sino una PLANTILLA: el enunciado dice "dN" para
// hablar de los diecinueve a la vez. En slides/ no vale, y ahi esta la regla 17.
const PLANTILLA = /\/(d?N|X|NN|nombre|algo|ruta|dia\d?N|<[^>]+>)(\.\w+)?$|\brepro-|\{|\$/;
// Lo que produce el build y .gitignore excluye: existe despues de `npm run
// build` y no existe en un clone limpio. La regla 12 se pregunta si el archivo
// esta EN EL REPO, y estos no lo estan nunca -- pero citarlos es correcto, que
// es de lo que habla docs/editar.md. Sin esta excepcion el lint decia que si en
// la maquina del que acababa de buildear y que no en el CI, que es la peor
// clase de regla: la que depende de la basura que quedo en el directorio.
const GENERADO = /^(dist|_site|obj_dir)\//;
// Regla 12: un .md nombrado adentro de backticks del que no existe NINGUN
// archivo con ese basename. `README.en.md` es el nombre de antes del rename.
// Solo .md, y no cualquier extension conocida: medido sobre todo el repo, la
// version amplia da 21 hits y 16 son prosa sobre archivos que NO son de este
// repo -- la columna de comandos de Questa (`tb.sv`, `a.dat`), los cuatro
// archivos que docs/verilator.md cuenta que se BORRARON, la salida de un build
// (`dist/regresion/regresion.html`) y la plantilla opcional del PPTX. Un .md
// nombrado en backticks, en cambio, es siempre un documento de este repo que
// se le esta diciendo al lector que abra.
const RE_TOKEN = /^[\w][\w./-]*\.md$/;

const lista = [...SUELTOS];
for (const r of RAICES) if (await existe(r)) lista.push(...await archivos(r));

for (const f of lista) {
  if (!(await existe(f))) continue;
  const txt = await readFile(f, 'utf8');
  const linea = i => txt.slice(0, i).split('\n').length;

  // Un archivo habla DE las referencias viejas, asi que las contiene a
  // proposito: este lint.
  if (path.basename(f) === 'lint-refs.mjs') continue;

  for (const m of txt.matchAll(RE_MAKE_CH)) {
    errores.push(`${f}:${linea(m.index)} — "${m[0]}" no es un target del Makefile (hoy: make u4/tests)`);
  }

  for (const m of txt.matchAll(RE_MAKE)) {
    const cmd = (m[1] ?? m[2]).match(RE_MAKE_CMD);
    if (!cmd || TARGETS.has(cmd[1])) continue;
    // Las variables del propio Makefile (make regresion EJEMPLO=...) no son targets.
    if (cmd[1].includes('=')) continue;
    // `make chNN` ya lo dice la regla 1, con un mensaje que nombra el cambio.
    if (/^ch\d+$/.test(cmd[1])) continue;
    errores.push(`${f}:${linea(m.index)} — "make ${cmd[1]}" no es un target del Makefile.`
      + ` Hay: ${[...TARGETS].filter(t => !t.includes('/')).sort().join(', ')} y los ejemplos code/uN/<nombre>`);
  }

  // --- Regla 10: las rutas del repo escritas en prosa ---
  // La regla 3 solo mira links markdown, y el doc de nivelacion --el que la
  // agenda del dia 1 manda a leer antes de arrancar-- pone la ruta adentro de
  // backticks: "abrir code/u2/convencional/vtalu_pkg.sv", que no existe. Lo
  // mismo el encabezado de provenance de los dos apendices generados, que va
  // adentro de un <!-- --> y nombra slides/172-... , de antes de la particion
  // es/en. Se barre el archivo entero: backticks, <code>, comentarios y prosa.
  const vistas = new Set();
  // Solo los .md: es la prosa que lee el alumno --el README, los docs, las
  // slides, los enunciados de los ejercicios--. Los href y los src de las dos
  // landings ya los resuelve lint-web.mjs contra el sitio armado, y las rutas
  // que arma un tools/*.mjs en tiempo de build no existen hasta que corre.
  for (const m of (path.extname(f) === '.md' ? txt : '').matchAll(RE_RUTA)) {
    const ruta = m[0].replace(/[.,;:)]+$/, '');
    // Un glob o una variable de shell no son una ruta: `code/u*/`, `code/u$N`.
    // Y `libro/dia1..8.html` es una notacion de rango, no un archivo.
    if (/[*$%{]/.test(txt[m.index + m[0].length] ?? '') || ruta.includes('..')) continue;
    // La cola de una URL del sitio publicado no es una ruta del repo:
    // https://leandrotozzi.github.io/verifythis/en/curso.html.
    if (txt[m.index - 1] === '/') continue;
    // Y el archivo que un comando CREA tampoco tiene por que existir todavia:
    // `pandoc -o tools/reference.pptx --print-default-data-file ...`.
    if (/(^|\s)(-o|>|--output[= ])\s*$/.test(txt.slice(Math.max(0, m.index - 12), m.index))) continue;
    // Igual que la regla 3: la ruta puede estar escrita desde la raiz del repo,
    // desde el archivo que la escribe (docs/README.md dice "en/setup.md") o
    // desde donde se sirve el deck de ese idioma.
    const servida = RAIZ_SERVIDA[path.normalize(path.dirname(f))];
    if ((await Promise.all([
      ruta,
      path.normalize(path.join(path.dirname(f), ruta)),
      ...(servida ? [path.normalize(path.join(servida, ruta))] : []),
    ].map(existe))).some(Boolean)) continue;
    const clave = `${linea(m.index)}:${ruta}`;
    if (vistas.has(clave)) continue;
    vistas.add(clave);
    const plantilla = PLANTILLA.test(ruta);
    // --- Regla 17: la plantilla, en las slides, es un error ---
    // "cd code/ejercicios/dN && bash run.sh" es la primera instruccion concreta
    // que ve el que hace el curso solo, y para los dias 6, 7 y 8 no existe
    // ningun directorio con esa forma: son d6-agents, d7-final, d8-ral.
    if (plantilla && !f.startsWith('slides')) continue;
    errores.push(`${f}:${linea(m.index)} — la ruta "${ruta}" no esta en el repo`
      + (plantilla ? ', y como plantilla no sirve: los ejercicios de los dias 6, 7 y 8'
        + ' no se llaman dN. Escribi uno de verdad (code/ejercicios/d1)' : ''));
  }

  // --- Regla 12: el nombre de archivo que no existe en ninguna parte ---
  // Hermana de la de `make X`, y con el mismo scope: adentro de backticks o de
  // un <code>. Cuatro de los cinco lugares que piden `README.en.md` --el nombre
  // de antes del rename-- no son links, asi que RE_LINK no los ve nunca, y uno
  // de ellos es un comando de una sola linea en la portada de un ejercicio: el
  // alumno lo pega y le falla. El filtro que la deja sin falsos positivos es
  // que NO EXISTA NINGUN archivo con ese basename: `docs/verilator.md` da uno
  // y pasa aunque la ruta sea relativa a otro lado.
  for (const m of (path.extname(f) === '.md' ? txt : '').matchAll(RE_MAKE)) {
    for (const tok of (m[1] ?? m[2]).split(/[\s,;'"()<>|&`]+/)) {
      const t = tok.replace(/^[-+]+/, '').replace(/[.,;:]+$/, '');
      if (!RE_TOKEN.test(t)) continue;
      if (BASENAMES.has(path.basename(t)) || PLANTILLA.test(t) || GENERADO.test(t)) continue;
      errores.push(`${f}:${linea(m.index)} — "${t}": no hay ningun archivo con ese nombre en el repo`);
    }
  }

  for (const m of txt.matchAll(RE_GH)) {
    const ruta = decodeURIComponent(m[1]);
    if (await existe(ruta)) continue;
    errores.push(`${f}:${linea(m.index)} — el link a GitHub apunta a "${ruta}", que no esta en el repo.`
      + ' Un 404 que solo se ve publicado: corregi la ruta o borra el link');
  }

  for (const m of txt.matchAll(RE_CAP)) {
    const ctx = txt.slice(Math.max(0, m.index - 40), m.index + 40);
    if (EXCEPCION_CAP.test(ctx)) continue;
    errores.push(`${f}:${linea(m.index)} — "${m[0].trim()}": el curso tiene unidades y secciones, no capitulos numerados`);
  }

  const plano = path.extname(f) === '.html' ? sinTags(txt) : txt;
  for (const m of plano.matchAll(RE_INVENTARIO)) {
    const n = PALABRAS[m[1].toLowerCase()] ?? Number(m[1]);
    const que = Object.keys(NOMBRES).find(k => NOMBRES[k].test(m[2].toLowerCase()))
             ?? (m[3] && Object.keys(NOMBRES).find(k => NOMBRES[k].test(m[3].toLowerCase())));
    // De diez para abajo casi siempre es un conteo local ("cuatro fases"), y
    // un numero un orden de magnitud afuera no es una cuenta vieja: es otra
    // cosa que usa la misma palabra. "1 de cada 257 soluciones" es el solver
    // SMT, no los catorce ejercicios.
    if (!que || n < PISO(que) || n > 10 * REAL[que] || n === REAL[que]) continue;
    // Nombrar un SUBCONJUNTO de los apendices es legitimo y pasa cuatro veces
    // ("los dos apendices generados", "los dos del final del deck"): con un
    // numero que se escribe con letras y vive por debajo de diez no hay forma
    // de distinguirlo de una cuenta vieja. Lo que nunca es cierto es prometer
    // MAS apendices de los que el deck rotula, y eso es lo que se mide.
    if (que === 'apendices' && n < REAL[que]) continue;
    if (LOCALES.test(plano.slice(Math.max(0, m.index - 45), m.index + 45))) continue;
    if (RELATIVO.test(plano.slice(Math.max(0, m.index - 25), m.index))) continue;
    if (DIA_ANTES.test(plano.slice(Math.max(0, m.index - 15), m.index))) continue;
    errores.push(`${f}:${linea(m.index)} — dice "${m[0].replace(/[\s>]+/g, ' ').trim()}" y hoy son ${REAL[que]}`);
  }

  // --- Regla 4b: el numeral suelto, el que ocupa el lugar del sustantivo ---
  // Se mide por parrafo y no por oracion: "Las 21 trampas mudas -- el catalogo
  // ... miente. La causa de este bug es una de las diecinueve" son dos
  // oraciones de la misma vineta, y el sustantivo esta en la primera. Y no por
  // archivo, que seria comparar numeros que no se hablan.
  // Tres candados, y sin los tres la regla da ruido (medido: 29 hits para
  // cuatro hallazgos):
  //   una sola familia   si el parrafo nombra slides Y preguntas no hay forma
  //                      de saber de cual habla el numero suelto
  //   detras de articulo "no en las 400", "una de las diecinueve": el articulo
  //                      plural es lo que hace que el numero reemplace al
  //                      sustantivo en vez de contar otra cosa
  //   sin sustantivo     si lo lleva detras es la regla 4 la que decide, y si
  //                      el sustantivo es otro ("las diez operaciones") el
  //                      numero no es del inventario
  if (path.extname(f) === '.md' || path.extname(f) === '.html') {
    const prosa = soloProsa(txt);
    const enLinea = i => prosa.slice(0, i).split('\n').length;
    for (const [off, parrafo] of parrafos(prosa)) {
      const familias = Object.keys(NOMBRES).filter(k => NOMBRES[k].test(parrafo.toLowerCase()));
      if (familias.length !== 1) continue;
      const que = familias[0];
      // Los numeros que SI llevan su sustantivo: los mira la regla 4, y ademas
      // son el ancla del parrafo -- si la vineta dice "las 21 trampas", el
      // numeral suelto de dos oraciones despues tiene que decir 21.
      const anclas = new Set([REAL[que]]);
      const pegado = new Set();
      for (const m of parrafo.matchAll(RE_INVENTARIO)) {
        if (![m[2], m[3]].some(p => p && NOMBRES[que].test(p.toLowerCase()))) continue;
        anclas.add(PALABRAS[m[1].toLowerCase()] ?? Number(m[1]));
        pegado.add(m.index);
      }
      for (const m of parrafo.matchAll(RE_NUMERAL)) {
        if (pegado.has(m.index)) continue;
        const n = PALABRAS[m[1].toLowerCase()] ?? Number(m[1]);
        const antes = parrafo.slice(Math.max(0, m.index - 25), m.index);
        if (n < PISO(que) || n > 10 * REAL[que] || anclas.has(n)) continue;
        // Si lo sigue una palabra --o un guion, que lo pega a una: "the
        // 15-week map"-- el numero no esta suelto y no es este el que lo mira.
        if (/^\s*[-a-záéíóúñ]/i.test(parrafo.slice(m.index + m[1].length))) continue;
        if (!ARTICULO.test(antes)) continue;
        if (LOCALES.test(parrafo.slice(Math.max(0, m.index - 45), m.index + 45))) continue;
        if (RELATIVO.test(antes) || DIA_ANTES.test(antes)) continue;
        errores.push(`${f}:${enLinea(off + m.index)} — "${m[1]}" suelto en un parrafo que habla de `
          + `${que}, y son ${[...anclas].join(' o ')}. Escribi el sustantivo al lado del numero`);
      }
    }
  }

  for (const m of txt.matchAll(RE_IMG)) {
    const src = ATTR(m[0], 'src'), w = +ATTR(m[0], 'width'), h = +ATTR(m[0], 'height');
    if (!src || !w || !h || /^(https?:|data:|\/\/)/.test(src)) continue;
    const abs = path.normalize(path.join(path.dirname(f), src));
    const real = await tamano(abs) ?? await tamano(path.normalize(src));
    if (!real) continue;
    // Se compara la RELACION, no los pixeles: escalar una imagen esta bien,
    // deformarla no. Medio punto porcentual de tolerancia por el redondeo.
    const dec = w / h, nat = real[0] / real[1];
    if (Math.abs(dec - nat) / nat > 0.005) {
      errores.push(`${f}:${linea(m.index)} — <img ${src}> declara ${w}x${h} y la imagen es `
        + `${real[0]}x${real[1]}: sale deformada. A ${w} de ancho el alto es ${Math.round(w * real[1] / real[0])}`);
    }
  }

  if (path.extname(f) === '.md') {
    for (const m of txt.matchAll(RE_LINK)) {
      const destino = m[1];
      if (/^(https?:|mailto:|\/\/)/.test(destino)) continue;
      // Las slides se sirven desde la raiz del repo, asi que sus rutas son
      // relativas a la raiz; los docs las escriben relativas a si mismos. Vale
      // cualquiera de las dos. Y un `../../algo` que se escapa del repo es un
      // link relativo de GitHub (../../discussions), no un archivo.
      const servida = RAIZ_SERVIDA[path.normalize(path.dirname(f))];
      const candidatos = [
        path.normalize(path.join(path.dirname(f), destino)),
        path.normalize(destino),
        ...(servida ? [path.normalize(path.join(servida, destino))] : []),
      ];
      // Se descartan los candidatos que se ESCAPAN del repo, no el link entero.
      // Con `.some()` alcanzaba con que UNO se escapara para no chequear nada, y
      // `../algo` siempre genera uno: normalize('../algo') se escapa aunque
      // join('docs/en', '../algo') caiga justo adentro. Resultado: los 55 links
      // `../` de docs/en/ no los miraba nadie -- todo el arbol de docs en ingles.
      // Si NINGUN candidato cae adentro es un link relativo de GitHub
      // (../../discussions), que no es un archivo y no se chequea.
      const dentro = candidatos.filter(c => !c.startsWith('..'));
      if (!dentro.length) continue;
      if (!(await Promise.all(dentro.map(existe))).some(Boolean)) {
        errores.push(`${f}:${linea(m.index)} — link roto: ${destino}`);
        continue;
      }

      // --- Regla 14: el link al YAML de un formulario de issue ---
      // GitHub lo resuelve al FUENTE del formulario, con numeritos de linea, no
      // al formulario. Los otros dos lugares del repo lo escriben bien.
      if (/(^|\/)\.github\/ISSUE_TEMPLATE\/.+\.ya?ml$/.test(path.normalize(path.join(path.dirname(f), destino)))
          || /(^|\/)ISSUE_TEMPLATE\/.+\.ya?ml$/.test(destino)) {
        errores.push(`${f}:${linea(m.index)} — "${destino}" abre el YAML del formulario, no el formulario.`
          + ` Se linkea ../../issues/new?template=${path.basename(destino)}`);
        continue;
      }

      // --- Regla 11: el #ancla de un link a un .html del repo ---
      // Solo .html: ahi el id esta escrito literal y no hay que reproducir el
      // slugificador de GitHub, que es el que decide las anclas de un .md.
      if (!m[2] || !/\.html$/.test(destino)) continue;
      const html = (await Promise.all(dentro.map(c => readFile(c, 'utf8').catch(() => null))))
        .find(Boolean);
      if (html && !new RegExp(`id="${m[2].replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}"`).test(html)) {
        errores.push(`${f}:${linea(m.index)} — el ancla "#${m[2]}" no es un id de ${destino}.`
          + ' El destino existe, asi que el link abre la pagina arriba de todo y nadie se entera');
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Reglas 5, 6 y 7: los ejercicios que se corrigen solos
// ---------------------------------------------------------------------------
// Ningun linter del repo abria un code/ejercicios/*/run.sh, y son los 19
// archivos que deciden si un alumno resolvio o no el ejercicio.
const EJERCICIOS = 'code/ejercicios';
const IMPRIME = /\$display|\$write|`uvm_(info|error|warning|fatal)|printf/;
const NO_TOCAR = /do ?n[o']t touch|not to be touched|no l[oa]s? toques|no tocar/i;

// Los literales que un run.sh saca del log. Solo los que tienen pinta de marca:
// [TAG], clave=, MAYUSCULAS y los identificadores con guion bajo. Sin ese
// filtro entran "grep", "print" y "errors", que son ruido del propio comando.
function literalesDelLog(run) {
  const out = new Set();
  for (const l of run.split('\n')) {
    if (!l.includes('$VLT_LOG')) continue;
    for (const c of l.matchAll(/'([^']*)'|"([^"]*)"/g)) {
      const s = c[1] ?? c[2];
      if (s.includes('VLT_LOG')) continue;
      for (const t of s.matchAll(/\\\[([^\\\]]+)\\\]|([A-Za-z_][A-Za-z0-9_]*)=|\b([A-Z][A-Z_]{3,})\b|\b([a-z][a-z0-9]*(?:_[a-z0-9]+)+)\b/g))
        out.add((t[1] ?? t[2] ?? t[3] ?? t[4]).trim());
    }
  }
  return out;
}

for (const e of (await readdir(EJERCICIOS, { withFileTypes: true })).filter(d => d.isDirectory())) {
  const dir = path.join(EJERCICIOS, e.name);
  const run = await readFile(path.join(dir, 'run.sh'), 'utf8').catch(() => null);
  if (!run) continue;
  const sha = await readFile(path.join(dir, 'intocables.sha'), 'utf8').catch(() => null);
  const sellados = new Set([...(sha ?? '').matchAll(/^\S+\s+(.+)$/gm)].map(m => m[1].trim()));

  // --- Regla 6b: el sello que se apaga solo ---
  // intocables() (code/verilator/common.sh) devuelve 0 en silencio cuando no
  // encuentra el .sha, asi que borrarlo apaga el chequeo sin que nada avise y
  // el run.sh sigue imprimiendo EXERCISE OK. Las dos mitades tienen que estar.
  if (/^\s*intocables\b/m.test(run) !== !!sha) {
    errores.push(sha
      ? `${dir}/intocables.sha — hay sello y el run.sh no llama a intocables: no lo chequea nadie`
      : `${dir}/run.sh — llama a intocables y no hay intocables.sha al lado.`
        + ` Regeneralo: cd ${dir} && sha256 <archivos> > intocables.sha`);
  }

  const propios = TODOS.filter(x => x.startsWith(dir + path.sep)
    && /\.(sv|svh|c|h)$/.test(x) && !/(^|[\\/])(obj_dir|solucion)[\\/]/.test(x));
  const fuente = new Map();
  for (const x of propios) fuente.set(x, (await readFile(x, 'utf8')).split('\n'));

  // --- Regla 6a: el archivo que pide no ser tocado y nada lo sella ---
  for (const [x, ls] of fuente) {
    const i = ls.findIndex(l => NO_TOCAR.test(l) && /^\s*(\/\/|\/\*|#)/.test(l));
    if (i < 0 || sellados.has(path.relative(dir, x))) continue;
    errores.push(`${x}:${i + 1} — dice que no se toca y no esta en ${dir}/intocables.sha.`
      + ' Un pedido por favor no es un sello: el ejercicio se resuelve editandolo');
  }

  // --- Regla 5: el corrector honesto ---
  // Si el literal que el run.sh busca en el log lo imprime un archivo del
  // propio directorio que el alumno edita, el ejercicio se aprueba reescribiendo
  // ese $display. La excepcion es el corrector que ADEMAS lee un literal de un
  // archivo sellado: ahi tiene un testigo que el alumno no puede falsificar, y
  // es lo que hacen d3b y d6-sequences con su chequeo.svh.
  const rojos = new Map();
  let testigo = false;
  for (const lit of literalesDelLog(run)) {
    const tok = new RegExp(`(^|[^A-Za-z0-9_])${lit.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}([^A-Za-z0-9_]|$)`);
    for (const [x, ls] of fuente) {
      let i = ls.findIndex(l => l.includes(lit) && IMPRIME.test(l));
      // El literal puede no estar escrito: un enum sale por %s con .name(), y
      // asi es como el ' mul_op ' que d2 cuenta lo imprime tester.svh.
      if (i < 0 && ls.some(l => tok.test(l) && !/^\s*\/\//.test(l)))
        i = ls.findIndex(l => IMPRIME.test(l) && /\.name\(\)/.test(l));
      if (i < 0) continue;
      if (sellados.has(path.relative(dir, x))) { testigo = true; continue; }
      if (!rojos.has(`${x}:${i + 1}`)) rojos.set(`${x}:${i + 1}`, lit);
    }
  }
  if (!testigo) for (const [donde, lit] of rojos) {
    errores.push(`${donde} — imprime "${lit}", que es lo que ${dir}/run.sh grepea del log`
      + ' para decidir si el ejercicio esta resuelto, y el alumno edita este archivo.'
      + ' El corrector tiene que cruzar contra algo sellado en intocables.sha');
  }

  // --- Regla 7: TODO(exercise X) con el nombre del directorio ---
  for (const [x, ls] of fuente) {
    ls.forEach((l, i) => {
      const m = l.match(/TODO\(exercise ([^)]*)\)/);
      if (m && m[1] !== e.name) {
        errores.push(`${x}:${i + 1} — "TODO(exercise ${m[1]})" y el directorio es ${e.name}.`
          + ' El formato lo fija code/verilator/common.sh: TODO(exercise <dir>)');
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Reglas 8 y 9: el codigo que las slides muestran
// ---------------------------------------------------------------------------
const FUENTES_CODE = TODOS.filter(x => x.startsWith('code' + path.sep)
  && !/[\\/](obj_dir|\.uvm)[\\/]/.test(x));

// Lo que ALGUN build alcanza: los .f, los `include y la linea vlt de un run.sh.
// Por basename y no por ruta, que es como los nombran los tres.
const COMPILADOS = new Set();
for (const x of FUENTES_CODE) {
  const t = await readFile(x, 'utf8').catch(() => '');
  if (x.endsWith('.f'))
    for (const l of t.split('\n')) {
      const n = l.trim().replace(/^\+incdir\+/, '');
      if (n && !n.startsWith('//') && !n.startsWith('-')) COMPILADOS.add(path.basename(n));
    }
  for (const m of t.matchAll(/`include\s+"([^"]+)"/g)) COMPILADOS.add(path.basename(m[1]));
  if (!/run[^/\\]*\.sh$/.test(x)) continue;
  // El comando parte en varias lineas con "\", y el archivo puede estar en
  // cualquiera de ellas: se pegan antes de mirar.
  // Y no solo la linea `vlt`: u6/jerarquias corre wrong.sv con un
  // `verilator --lint-only` suelto, que tambien es un build que lo alcanza.
  // Las lineas comentadas no cuentan: nombrar un archivo en un comentario no
  // es compilarlo, que es justo lo que la regla mide.
  const cmd = t.replace(/\\\n\s*/g, ' ');
  for (const l of cmd.split('\n')) {
    if (/^\s*#/.test(l)) continue;
    for (const tok of l.split(/[\s"']+/)) if (/\.(sv|svh|c|h)$/.test(tok)) COMPILADOS.add(path.basename(tok));
  }
  // Y puede llegar por una variable: `for f in 01_dist 02_with; do vlt "$f.sv"`.
  // Los nombres estan en la lista del for, sin extension, y ningun regex de
  // nombres de archivo los ve.
  for (const m of cmd.matchAll(/\bfor\s+\w+\s+in\s+([^;\n]+)/g))
    for (const stem of m[1].split(/\s+/))
      for (const ext of ['.sv', '.svh', '.c', '.h']) COMPILADOS.add(stem + ext);
}
// Y por el Makefile: los repros de code/verilator/ no tienen run.sh -- los
// compila el target `repros`, que arma el nombre con $$f.sv. Sin esto los seis
// son invisibles para esta regla, y el dia que una slide cito uno (la trampa
// del for/fork) el lint lo acuso de ser una copia a mano que nadie compila.
{
  const mk = (await readFile('Makefile', 'utf8').catch(() => '')).replace(/\\\n\s*/g, ' ');
  for (const m of mk.matchAll(/^\s*REPROS\s*:?=\s*(.+)$/gm))
    for (const stem of m[1].trim().split(/\s+/))
      for (const ext of ['.sv', '.svh']) COMPILADOS.add(stem + ext);
}

// --- Regla 8: el {{code:}} que apunta a un archivo que no compila nadie ---
// code/README.md lo dice: las slides no pegan el codigo, lo incluyen, "para que
// el dia que se arregle uno el otro no quede roto sin que nada avise". Un
// archivo de code/ que ningun build toca es exactamente eso -- una copia a mano
// disfrazada de fuente-- y once de ellos ya divergieron del original.
// La excepcion es la marca que el repo ya invento y uso una vez:
// "// ILLUSTRATION -- not compiled" (code/u7/agents/env_un_agent.svh:1).
const CITADOS = new Set();
for (const f of lista) {
  if (!/^(slides|docs)[\\/]/.test(f) || path.extname(f) !== '.md') continue;
  const txt = await readFile(f, 'utf8');
  const linea = i => txt.slice(0, i).split('\n').length;
  for (const m of txt.matchAll(RE_CODE)) {
    const ruta = m[2].trim();
    if (m[3]) CITADOS.add(`${ruta}#${m[3]}`);
    if (!/\.(sv|svh|c|h)$/.test(ruta)) continue;   // un .txt capturado no compila
    if (COMPILADOS.has(path.basename(ruta))) continue;
    const cabeza = (await readFile(ruta, 'utf8').catch(() => '')).slice(0, 400);
    if (/ILLUSTRATION/.test(cabeza)) continue;
    errores.push(`${f}:${linea(m.index)} — {{code:${ruta}}} muestra un archivo que ningun build compila:`
      + ' no esta en un .f, ni en un `include, ni en la linea vlt de un run.sh. O es una copia a mano'
      + ' del original (recortalo del que si se compila) o es pseudocodigo, y va con'
      + ' "// ILLUSTRATION -- not compiled" en la primera linea');
  }
}

// --- Regla 9: el marcador // cb: que no cita nadie ---
for (const x of FUENTES_CODE) {
  const ls = (await readFile(x, 'utf8').catch(() => '')).split('\n');
  ls.forEach((l, i) => {
    const m = l.match(/^\s*(?:\/\/|#)\s*cb:\s*(\S+)\s*$/);
    if (!m || m[1] === 'end' || CITADOS.has(`${x.split(path.sep).join('/')}#${m[1]}`)) return;
    errores.push(`${x}:${i + 1} — el marcador "cb: ${m[1]}" no lo cita ningun {{code:}}.`
      + ' Un marcador huerfano se pudre: borralo o citalo');
  });
}

// ---------------------------------------------------------------------------
// Regla 13: los indices de docs/ y docs/en/
// ---------------------------------------------------------------------------
// El README de cada uno de los dos directorios es su indice, y un doc que no
// esta indexado no lo encuentra nadie: docs/en/README.md dice "the part of
// docs/ that exists in English" y lista siete de los ocho que hay.
for (const dir of ['docs', 'docs/en']) {
  const indice = await readFile(path.join(dir, 'README.md'), 'utf8').catch(() => '');
  for (const e of await readdir(dir)) {
    if (e === 'README.md' || e.startsWith('.') || !/\.(md|pdf)$/.test(e)) continue;
    if (indice.includes(e)) continue;
    errores.push(`${dir}/README.md — no indexa ${e}, que esta al lado.`
      + ' Un doc que el indice de su directorio no nombra no lo encuentra nadie');
  }
}

// ---------------------------------------------------------------------------
// Reglas 15 y 16: la guia docente
// ---------------------------------------------------------------------------
// El banco por dia, para la regla 16. Sale del propio banco: cada "## Dia N"
// dice cuantas trae, y los rangos se acumulan en orden.
const RANGOS = {};
{
  const banco = await readFile('docs/banco-de-examen.md', 'utf8').catch(() => '');
  let desde = 1;
  for (const m of banco.matchAll(/^## D[ií]a (\d+) · (\d+) pregunta/gm)) {
    RANGOS[+m[1]] = [desde, desde + +m[2] - 1];
    desde += +m[2];
  }
}

for (const guia of ['docs/para-docentes.md', 'docs/en/for-teachers.md']) {
  const txt = await readFile(guia, 'utf8').catch(() => null);
  if (!txt) continue;
  const linea = i => txt.slice(0, i).split('\n').length;

  // --- Regla 15: la tabla del cuatrimestre ---
  // El titulo promete N clases y la primera columna las numera. Se colo una
  // fila "10b" --una seccion mas sin renumerar-- y quedaron dieciseis clases
  // bajo un titulo que dice quince, con la cuenta de horas hecha con quince.
  const titulo = txt.match(/^## (?:Las|The) (\d+) (?:semanas|weeks)\s*$/m);
  if (!titulo) continue;
  // La seccion del titulo y nada mas: el archivo trae otras seis tablas.
  const desde = titulo.index;
  const hasta = txt.indexOf('\n## ', desde + 1);
  const sec = txt.slice(desde, hasta < 0 ? txt.length : hasta);
  const filas = [...sec.matchAll(/^\|(?! *:?-)(?! *#)(?! *\|) *([^|]*?) *\|/gm)]
    .map(m => [desde + m.index, m[1]]);
  const numeradas = filas.filter(([, c]) => !['—', '+'].includes(c));
  // La PRIMERA que rompe, y se corta: una fila de mas corre a todas las de
  // abajo, y seis mensajes para un solo defecto no ayudan a nadie.
  const rota = numeradas.findIndex(([, c], k) => c !== String(k + 1));
  if (rota >= 0) {
    errores.push(`${guia}:${linea(numeradas[rota][0])} — la fila "${numeradas[rota][1]}" rompe la numeracion`
      + ` 1..${titulo[1]} de la tabla de "${titulo[0].replace('## ', '').trim()}". Son ${numeradas.length}`
      + ' clases: o se renumera, o el titulo y la cuenta de horas de arriba dicen eso');
  }

  // --- Regla 15b: el orden de las secciones que nombra cada fila ---
  // Cada celda de Teoria lista los titulos de las secciones de esa clase, y el
  // deck ya los tiene en orden. Dos candados, y sin ellos la regla no sirve
  // (medido: 16 hits de ruido contra 2 hallazgos):
  //   se saltean las filas que reordenan A PROPOSITO, y el propio texto las
  //   declara ("y Callbacks si entra" / "and Callbacks if it fits");
  //   se ignora el titulo que no resuelve, porque la celda tambien trae
  //   parafrasis ("Que es UVM", "Repaso de U5") y el encabezado de la tabla.
  const deck = [];
  for (const s of (await readdir(path.join('slides', guia.includes('/en/') ? 'en' : 'es'))).sort()) {
    if (!s.endsWith('.md')) continue;
    const t = (await readFile(path.join('slides', guia.includes('/en/') ? 'en' : 'es', s), 'utf8'))
      .match(/^## (.*)$/m);
    if (t) deck.push(t[1].trim().toLowerCase());
  }
  for (const m of sec.matchAll(/^\|[^|]*\|([^|]*)\|/gm)) {
    if (/si entra|if it fits/i.test(m[1])) continue;
    const orden = m[1].split('·')
      .map(s => s.replace(/\*\*U\d+\*\*/g, '').replace(/[*`]/g, '').trim().toLowerCase())
      .filter(s => s.length > 3)
      .map(s => deck.findIndex(t => t.startsWith(s) || s.startsWith(t)))
      .filter(i => i >= 0);
    const k = orden.findIndex((v, j) => j > 0 && v < orden[j - 1]);
    if (k > 0) {
      errores.push(`${guia}:${linea(desde + m.index)} — la fila nombra las secciones al reves del deck:`
        + ` "${deck[orden[k]]}" va antes que "${deck[orden[k - 1]]}". La glosa que las acompaña`
        + ' queda pegada a la que no es');
    }
  }

  // --- Regla 16: el parcial que toma lo que se dicta esa misma clase ---
  // La fila de la semana dice que ejercicio va de laboratorio, y el nombre del
  // ejercicio dice de que dia es (d5c -> dia 5). Si el rango del parcial que se
  // toma en esa fila llega hasta ese dia, el alumno rinde lo que esta viendo.
  const parciales = {};
  for (const m of txt.matchAll(/^\| *\*\*(?:Parcial|Midterm) (\d+)\*\* *\|.*?\| *\*\*(\d+)[–-](\d+)\*\* *\|/gm))
    parciales[+m[1]] = [+m[2], +m[3]];
  for (const m of sec.matchAll(/^\|.*\*\*(?:Parcial|Midterm) (\d+)\*\*.*$/gm)) {
    const rango = parciales[+m[1]];
    if (!rango) continue;
    for (const ej of new Set([...m[0].matchAll(/code\/ejercicios\/d(\d+)/g)].map(x => +x[1]))) {
      const dia = RANGOS[ej];
      if (!dia || dia[0] > rango[1]) continue;
      errores.push(`${guia}:${linea(desde + m.index)} — el Parcial ${m[1]} cubre las preguntas ${rango[0]}-${rango[1]}`
        + ` y esa misma clase dicta el dia ${ej}, que son las ${dia[0]}-${dia[1]} del banco.`
        + ' Se rinde lo que se esta viendo: corre el parcial una semana o bajale el rango');
    }
  }
}

if (errores.length) {
  console.error(`✗ ${errores.length} referencia(s) que ya no existen:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
console.log('✓ lint de referencias: sin comandos, capitulos ni links colgados');
console.log(`✓ inventario al dia: ${Object.entries(REAL).map(([k, v]) => `${v} ${k}`).join(', ')}`);
