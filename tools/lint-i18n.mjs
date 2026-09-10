// El linter que reemplaza al templating: detecta que las dos versiones del curso
// divergieron, en vez de tratar de impedirlo.
//
// El repo ya usa esta estrategia en todos lados -- index.html y libro/ van
// commiteados y un --check falla si quedaron viejos; los numeros del inventario
// se cuentan del filesystem y lint-refs los verifica contra la prosa. Aca es lo
// mismo aplicado al idioma: slides/es/ y slides/en/ son dos archivos, y este
// script es el que se da cuenta cuando uno se movio y el otro no.
//
// Hay dos clases de divergencia, y las dos importan:
//
//   ESTRUCTURAL  el ingles tiene una slide de menos, incluye otro archivo de
//                code/, o el quiz tiene la respuesta marcada en otra opcion.
//                Se ve comparando los dos archivos (reglas 1 a 6).
//   DE SENTIDO   alguien edito un bullet en castellano y la traduccion quedo
//                diciendo otra cosa. Estructuralmente son identicos, asi que
//                NINGUNA de las reglas de arriba lo ve. Por eso cada archivo de
//                slides/en/ lleva el sha del archivo ES del que salio (regla 7):
//                si el ES cambio, el check falla y dice cual hay que revisar.
//
// Y una CUARTA, que no esta en los .md: las FIGURAS (regla 9). El deck las
// incluye con <img>, asi que un SVG es un documento aparte y ninguna regla de
// arriba lo abre -- el curso en castellano estuvo mostrando en ingles casi todas
// sus figuras, sin que nada avisara.
//
// Y una tercera, que no es divergencia sino traduccion a medias (regla 8):
// castellano que quedo sin traducir en el arbol EN. Estructuralmente no se ve
// -- la slide tiene la misma cantidad de bullets -- y el sello es-sha tampoco,
// porque se sella igual. La unica forma de cacharlo era leer las 444 slides.
// Es LA falla tipica de una traduccion larga: un bullet, una Note: o la celda
// de una tabla que se saltearon, en el medio de una seccion por lo demas
// completa. Se buscan palabras funcionales del castellano que no son palabras
// del ingles, fuera del codigo y de los links.
//
// El arbol EN es un SUBCONJUNTO a proposito: el dia 1 se publica en ingles
// mucho antes que el 7. Lo que no se permite es un huerfano -- un archivo en
// en/ que no exista en es/ --, porque eso es una traduccion de algo que ya no
// existe.
//
// LO QUE EL SELLO NO DICE, escrito para que no haga falta deducirlo: `es-sha`
// dice "el ES no cambio desde que se bendijo esta traduccion", NO dice "la
// traduccion es correcta". Una traduccion mal hecha se sella igual de bien que
// una buena. La revision de las 444 slides de septiembre 2026 encontro 27
// divergencias de sentido y DIEZ de ellas no tienen lint posible por esto
// mismo: "se puede cambiar solo el tester" traducido como "only the tester can
// be changed" invierte la oracion sin mover una slide, un {{code:}}, un
// backtick ni un numero. Las reglas 10 a 16 son los pedazos de esa familia que
// SI dejan huella contable; el resto sale de leer los dos archivos al lado, y
// no hay forma de automatizarlo:
//
//   10  castellano adentro de code/, comentarios y mensajes al alumno
//   11  el glosario: una traduccion por termino del curso, y sin colisiones
//   12  los links de un arbol al otro, y el "(in Spanish)" cuando no hay gemelo
//   13  el multiconjunto de spans `inline` de una slide
//   14  el `cd <dir> && cat <archivo>` de las slides de ejercicio
//   15  los bloques ``` pegados a mano, sin contar comentarios ni strings
//   16  la tipografia de los porcentajes, por arbol
//
//   node tools/lint-i18n.mjs                      chequea
//   node tools/lint-i18n.mjs --pendientes         cuanto falta, por dia
//   node tools/lint-i18n.mjs --dia 3              que secciones faltan de ese dia
//   node tools/lint-i18n.mjs --bless <archivo>    re-sella despues de traducir
import { readFile, writeFile, readdir, stat } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import path from 'node:path';
import { SALIDAS } from './i18n.mjs';

const ES = SALIDAS.es.slides;
const EN = SALIDAS.en.slides;
// Los README de los ejercicios son el enunciado, no documentacion del codigo:
// se traducen con las slides y van como par, con el mismo sha.
// Y la spec del capstone, que es enunciado igual que el README: el ejercicio es
// leerla y desconfiar de ella, asi que en ingles tiene que estar en ingles.
// Los README van al reves que el resto, por lo mismo que el de la raiz: GitHub
// renderiza README.md y ningun otro al entrar a un directorio, asi que ese
// tiene que ser el ingles. La fuente sigue siendo el castellano, ahora .es.md.
const PARES_MD = [['code/ejercicios', 'README.es.md', 'README.md'],
                  ['code/ejercicios', 'spec.md', 'spec.en.md']];
// Y la landing, que es prosa a mano en los dos idiomas. Y el README.
//
// El README va al reves que todo el resto del repo, y es a proposito: la
// TRADUCCION se llama README.md y el ORIGINAL README.es.md. GitHub renderiza
// README.md y ningun otro, asi que el que cae al repo desde una busqueda en
// ingles -- casi todo el trafico de un repo de UVM -- se comia 35 KB de
// castellano y se iba asumiendo que el curso era solo en castellano. Es el
// mismo bug que tenia la landing en ingles cuando decia "day 1 is complete"
// con los ocho dias ya traducidos: el lector se va antes de enterarse.
// Escribir se sigue escribiendo en castellano -- README.es.md es la fuente y
// este lint sella el ingles contra ella, igual que slides/en/ contra slides/es/.
//
// El par se declara [fuente, traduccion], asi que la inversion del sufijo no
// necesito tocar el mecanismo: origenDe() prueba el sufijo .en.md antes de
// mirar esta tabla, y "README.md" no termina en ".en.md", asi que cae aca.
//
// Y tres docs. docs/ es el unico arbol del repo donde la traduccion NO vive al
// lado con otro sufijo ni en un arbol espejo completo: la fuente esta en docs/
// y el ingles en docs/en/, con el nombre traducido tambien -- instalar.md pasa
// a ser setup.md, que es lo que un anglohablante busca. Por eso van como par
// suelto y no por regla: el nombre no se puede derivar.
//
// Solo estos cinco, y no docs/ entero, porque son los que estan en el
// camino del lector en ingles: setup.md es el CRITICO -- el README en ingles lo
// linkea como el lugar donde estan los cuatro caminos de instalacion, o sea que
// es donde el lector pasa de "quiero probarlo" a "me corre"; uvm-interview.md es
// el que trae trafico nuevo; for-teachers.md es el que decide una adopcion.
// El resto de docs/ sigue en castellano y linkeado con "(in Spanish)" al lado,
// que es honestidad y no deuda: el lector se entera antes de hacer clic.
//
// La comparacion estructural (cantidad de slides, {{code:}}, quiz) se les
// aplica igual, porque el nombre termina en .md y no dice README. En prosa eso
// significa que los dos tienen que tener los mismos separadores "---": no es
// para lo que se escribio la regla, pero es cierto y es gratis -- una seccion
// que se cae en la traduccion se ve.
const PARES_SUELTOS = [['web/index.html', 'web/en/index.html'],
                       ['README.es.md', 'README.md'],
                       ['code/README.es.md', 'code/README.md'],
                       ['docs/instalar.md', 'docs/en/setup.md'],
                       ['docs/uvm-en-la-entrevista.md', 'docs/en/uvm-interview.md'],
                       ['docs/para-docentes.md', 'docs/en/for-teachers.md'],
                       // Los dos que la etapa 8 puso en ingles: el plan de
                       // verificacion viaja con el capstone --se entrega, asi
                       // que el alumno en ingles lo necesita en ingles-- y la
                       // matriz es lo primero que se mira cuando algo no
                       // compila. La matriz ademas la GENERA make matrix, o sea
                       // que su ES se reescribe entero cada vez que se cambia de
                       // version de Verilator: ahi este sello es justo lo que
                       // avisa que la traduccion quedo con los numeros viejos.
                       ['docs/plan-de-verificacion.md', 'docs/en/verification-plan.md'],
                       ['docs/verilator.md', 'docs/en/verilator.md'],
                       // La carilla imprimible. Es HTML y no .md, asi que de las
                       // reglas de arriba solo le corre el sello: alcanza, que es
                       // lo unico que avisa cuando una se edita y la otra no.
                       ['res/machete.html', 'res/en/machete.html']];
// En un .md la marca va primera; en un .html va DESPUES del doctype, porque un
// comentario antes del <!doctype> manda al navegador a quirks mode.
const MARCA = /^(?:<!doctype html>\n)?<!-- es-sha: ([0-9a-f]{12}) -->\n/i;

const sha = s => createHash('sha256').update(s).digest('hex').slice(0, 12);
const sinMarca = s => s.replace(MARCA, m => m.toLowerCase().startsWith('<!doctype') ? m.split('\n')[0] + '\n' : '');

const errores = [], avisos = [];
const fail = (f, msg) => errores.push(`${f}: ${msg}`);
// Aviso y no error donde el informe lo pide: la regla 12b marca una cita a un
// doc que sigue en castellano, y ahi lo que falta es una aclaracion, no un
// archivo. Falla igual con --avisos-fallan, como lint-slides y lint-web.
const avisa = (f, msg) => avisos.push(`${f}: ${msg}`);

// --- --bless: re-sellar una traduccion ya revisada ---------------------------
const bless = process.argv.slice(2).filter(a => a !== '--bless' && !a.startsWith('--'));
if (process.argv.includes('--bless')) {
  if (!bless.length) {
    console.error('uso: node tools/lint-i18n.mjs --bless slides/en/060-factory.md ...');
    process.exit(1);
  }
  for (const f of bless) {
    const origen = await origenDe(f);
    if (!origen) { console.error(`✗ ${f}: no encuentro el archivo en castellano del que sale`); process.exit(1); }
    const crudo = await readFile(f, 'utf8');
    const doctype = crudo.match(/^<!doctype html>\n/i)?.[0] ?? '';
    const cuerpo = sinMarca(crudo).slice(doctype.length);
    await writeFile(f, `${doctype}<!-- es-sha: ${sha(await readFile(origen, 'utf8'))} -->\n${cuerpo}`);
    console.log(`✓ ${f} sellado contra ${origen}`);
  }
  process.exit(0);
}

// El archivo ES del que sale una traduccion: mismo nombre en el arbol es/, el
// hermano del .en.md, el hermano declarado en PARES_MD, o un par suelto.
async function origenDe(f) {
  const n = path.normalize(f);
  if (n.startsWith(EN + path.sep)) return path.join(ES, path.basename(n));
  if (n.endsWith('.en.md')) return n.replace(/\.en\.md$/, '.md');
  // PARES_MD: la traduccion se llama README.md y la fuente README.es.md al
  // lado. Sin esto --bless no sabe contra que sellar y muere en el primero.
  for (const [raiz, base, hermano] of PARES_MD) {
    const dir = path.dirname(n);
    if (path.basename(n) === hermano && (dir === path.normalize(raiz) || path.dirname(dir) === path.normalize(raiz))) {
      return path.join(dir, base);
    }
  }
  const suelto = PARES_SUELTOS.find(([, en]) => path.normalize(en) === n);
  return suelto ? suelto[0] : null;
}

// --- las piezas que NO pueden divergir ---------------------------------------
const partes = md => ({
  // Una slide por bloque: el separador es un --- en una linea sola.
  slides: 1 + (md.match(/^---$/gm) ?? []).length,
  // El codigo se incluye, no se pega: las dos versiones tienen que mostrar
  // exactamente los mismos archivos, en el mismo orden y con el mismo recorte.
  codigo: [...md.matchAll(/\{\{code:([^}]+)\}\}/g)].map(m => m[1].trim()),
  // Los marcadores de dia: si el ingles pone id="day3" en otra seccion, el libro
  // reparte las slides distinto y los dos cursos dejan de ser el mismo.
  dias: [...md.matchAll(/id="(day\d)"/g)].map(m => m[1]),
  // Las notas del presentador son la mitad del curso y el cuerpo del libro: una
  // slide con nota en un idioma y sin nota en el otro es media pagina perdida.
  notas: (md.match(/^Note:$/gm) ?? []).length,
  // Los quizzes: misma cantidad de opciones y la correcta en el mismo lugar.
  quiz: md.split(/^---$/m).map(s => {
    const ops = [...s.matchAll(/^- \[([ x])\]/gm)].map(m => m[1]);
    return ops.length ? `${ops.length}:${ops.indexOf('x')}` : '';
  }).join('|'),
});

// --- regla 8: castellano sin traducir --------------------------------------
// Solo palabras funcionales, y solo las que NO son tambien palabras del ingles:
// "no", "un", "en", "es", "solo" y "a" existen en los dos idiomas y no dicen
// nada. Nada de sustantivos: "monitor", "sequence" y "driver" se escriben igual
// en las dos versiones a proposito, que es justo lo que hay que respetar.
const CASTELLANO = ['qué', 'que', 'para', 'porque', 'pero', 'cuando', 'cuándo', 'donde', 'dónde',
  'esto', 'esta', 'este', 'esa', 'ese', 'esos', 'esas', 'cada', 'todo', 'toda', 'todos', 'todas',
  'hay', 'tiene', 'tienen', 'puede', 'pueden', 'hace', 'hacen', 'desde', 'hasta', 'entre',
  'sobre', 'también', 'más', 'así', 'nunca', 'siempre', 'mismo', 'misma', 'otro', 'otra',
  'cómo', 'además', 'aunque', 'entonces', 'ahora', 'después', 'antes', 'mientras', 'según',
  'del', 'las', 'los', 'una', 'unas', 'unos', 'con', 'por', 'sin', 'ya',
  // "y" y "contra" entraron con la regla 8 extendida a los .html (abajo): los
  // tres <li> del temario de la landing en ingles que quedaron en castellano
  // son "uvm_test y +UVM_TESTNAME", "uvm_component y las fases" y "|-> contra
  // |=>", y con la lista vieja no habia una sola palabra que los marcara. En
  // los .md no cambian nada: medido, cero hits nuevos sobre las 444 slides.
  'y', 'contra'];
const RE_CASTELLANO = new RegExp(String.raw`(?<![\w'’-])(${CASTELLANO.join('|')})(?![\w'’-])`, 'gi');

// Todo lo que NO es prosa: los bloques de codigo, el codigo inline, los
// {{code:}}, los comentarios, las URLs, el destino de un link y los tags. Se
// borran reemplazando por espacios del mismo largo, para no correr las lineas.
//
// En los .html hay tres cosas mas que borrar, y las tres por el mismo motivo
// que los comentarios: estan en castellano A PROPOSITO. El <script> y el
// <style> llevan los comentarios de mantenimiento, que es la convencion del
// repo; el <pre> de la landing es salida literal de Verilator; y un elemento
// con lang="es" es el callout que invita al lector al otro idioma --el propio
// HTML ya declara que ese pedazo es castellano, asi que no hace falta una
// lista de excepciones a mano--.
const enBlanco = m => m.replace(/[^\n]/g, ' ');
const soloProsa = md => md
  .replace(/```[\s\S]*?```/g, enBlanco)
  .replace(/<(script|style|pre)\b[^>]*>[\s\S]*?<\/\1>/gi, enBlanco)
  // El <html lang="es"> de la landing castellana queda afuera a proposito: si
  // no, esta linea borraria la pagina entera.
  .replace(/<(?!html\b|body\b)(\w+)[^>]*\slang="es"[^>]*>[\s\S]*?<\/\1>/g, enBlanco)
  .replace(/`[^`\n]*`/g, enBlanco)
  .replace(/\{\{[^}]*\}\}/g, enBlanco)
  .replace(/<!--[\s\S]*?-->/g, enBlanco)
  .replace(/<[^>]+>/g, enBlanco)
  .replace(/\]\([^)]*\)/g, enBlanco)
  .replace(/https?:\/\/\S+/g, enBlanco);

function castellanoSuelto(f, md, umbral = 2) {
  const t = soloProsa(md);
  const lineas = new Map();
  for (const m of t.matchAll(RE_CASTELLANO)) {
    const n = t.slice(0, m.index).split('\n').length;
    if (!lineas.has(n)) lineas.set(n, []);
    lineas.get(n).push(m[0]);
  }
  for (const [n, ps] of lineas) {
    // Una sola coincidencia suelta en una linea suele ser un nombre propio o
    // una cita ("Verify This!" no, pero "el machete" sí aparece citado). Dos o
    // mas en la misma linea es una frase en castellano, sin vuelta.
    if (ps.length < umbral) continue;
    fail(`${f}:${n}`, `quedo castellano sin traducir ("${ps.slice(0, 4).join(' ')}"...) — traducila`
      + ` y despues: node tools/lint-i18n.mjs --bless ${f}`);
  }
}

// --- regla 8, la otra mitad: los placeholders de adentro del codigo inline ---
// soloProsa() blanquea los `...` a proposito y con razon: `this`,
// `type_id::create` y `set()` no son castellano. Pero eso deja afuera los
// placeholders, que SI se traducen -- la misma seccion de assertions traduce
// `@(clock) antecedent |-> consequent` y se olvido de `begin : nombre`, la
// unica aparicion de ese constructo en todo el arbol EN. La lista es CERRADA:
// son las once palabras que el curso usa como hueco para completar, y no
// crece, porque "nombre" tambien puede ser un identificador de verdad.
const PLACEHOLDERS = ['nombre', 'valor', 'algo', 'destino', 'origen', 'reloj',
  'acción', 'antecedente', 'consecuente', 'etiqueta', 'tipo'];
const RE_PLACEHOLDER = new RegExp(String.raw`(?<![\w'’-])(${PLACEHOLDERS.join('|')})(?![\w'’-])`, 'gi');

function placeholderSinTraducir(f, md) {
  const t = md.replace(/```[\s\S]*?```/g, enBlanco).replace(/<!--[\s\S]*?-->/g, enBlanco);
  for (const m of t.matchAll(/`([^`\n]+)`/g)) {
    const hits = [...m[1].matchAll(RE_PLACEHOLDER)].map(x => x[0]);
    if (!hits.length) continue;
    fail(`${f}:${t.slice(0, m.index).split('\n').length}`,
      `el placeholder "${hits[0]}" quedo en castellano adentro de \`${m[1]}\` — traducilo`
      + ` y despues: node tools/lint-i18n.mjs --bless ${f}`);
  }
}

// --- regla 11: el glosario de terminos del curso -----------------------------
// El bug que la motiva es el mas caro de los 27 de la revision: el castellano
// distingue el CAMINO de vuelta (el handle compartido, que existe) del CANAL de
// vuelta (un port, una FIFO, que no existe), y esa distincion ES el punto de la
// slide. El ingles tradujo los dos como "way back", asi que
// slides/en/150-sequences.md:225 niega lo que la misma slide enseno siete
// lineas antes, y el quiz del dia 6 titula una pregunta "The way back" y
// contesta que no hay ninguno. Ninguna regla de arriba lo ve: los dos archivos
// tienen las mismas slides, los mismos {{code:}} y el mismo quiz, y el sello
// dice que el ES no se movio -- que es cierto y no sirve.
//
// La regla es cardinalidad: si el termino aparece N veces en el archivo ES, su
// traduccion bendecida tiene que aparecer N veces en el EN. Y ademas el termino
// CASTELLANO no puede aparecer en el archivo ingles -- asi cae el ribbon
// "Machete UVM" que README.md manda a buscar y que en el deck en ingles se
// llama "UVM cheat sheet".
//
// Los terminos se escriben como fuente de regex y el espacio vale por
// "espacio o guion o salto de linea": la prosa va a 80 columnas y
// "silent-traps" con guion es la misma cosa que "silent traps".
//
// La tabla NO crece por las dudas. Cada entrada esta aca porque hay un hallazgo
// leido detras, y las que se midieron con ruido quedaron afuera a proposito:
// "reparto" (10 desajustes, 2 reales: tambien significa "split" y
// "distribution"), "al reves" (8 desajustes, 2 reales: "the other way round" es
// una frase hecha del ingles) y "bin" contra "bin" (2 desajustes, 1 real).
const GLOSARIO = [
  ['canal de vuelta',      'return channel'],       // H2: hoy dice "way back", que es la otra cosa
  ['camino de vuelta',     'way back'],             // el par del anterior: lo que "way back" SI significa
  ['rodeo(?! de )',        'workaround'],           // H17: sale "way round", "way around it" y "workaround"
                                                    // el "(?! de )" saca el otro sentido, "un rodeo de programacion"
  ['fila del plan',        'row of the plan'],      // H20: el quiz dice "row" donde la slide dice "bin"
  ['verificador',          'verification engineer'],// H21: "verifier" en once lugares y "engineer" en el gancho
  ['Machete (de )?UVM',    'UVM cheat sheet'],      // H15: el README manda a buscar un ribbon que no dice eso
  ['trampas mudas',        'silent traps'],         // el termino del dia 7, hoy consistente: la entrada lo sostiene
];
// El chequeo que el informe pide "sobre todo": dos terminos ES distintos no
// pueden mapear a la misma cadena EN. Hoy no colisiona ninguno; lo que ataja es
// el commit de manana que, para arreglar H17, bendiga "rodeo -> way round"
// teniendo "al reves -> way round" al lado. Corre una vez, al cargar.
{
  const porTraduccion = new Map();
  for (const [es, en] of GLOSARIO) {
    if (porTraduccion.has(en))
      fail('tools/lint-i18n.mjs', `el glosario le da la misma traduccion "${en}" a "${legible(porTraduccion.get(en))}" y a "${legible(es)}": son dos terminos distintos del curso y no pueden colapsar en uno`);
    porTraduccion.set(en, es);
  }
}
const reTermino = t => new RegExp(String.raw`(?<![\w'’-])${t.replace(/ /g, '[\\s-]+')}s?(?![\w-])`, 'gi');
// El termino se escribe como regex y se lee como termino: el mensaje de error
// dice "rodeo" y no "rodeo(?! de )", que no le sirve a nadie.
const legible = t => t.replace(/\(\?![^)]*\)/g, '').replace(/\(([^)]*)\)\?/g, '').trim();
const cuantas = (t, termino) => (t.match(reTermino(termino)) ?? []).length;

function glosario(fEs, fEn, aEs, aEn) {
  const [a, b] = [soloProsa(aEs), soloProsa(aEn)];
  for (const [es, en] of GLOSARIO) {
    const intruso = es === en ? 0 : cuantas(b, es);
    if (intruso) {
      fail(fEn, `dice el termino en castellano "${legible(es)}" ${intruso} vez(ces): la traduccion del curso es "${en}"`);
      continue;
    }
    const [x, y] = [cuantas(a, es), cuantas(b, en)];
    if (x !== y) fail(fEn, `"${legible(es)}" aparece ${x} vez(ces) en ${fEs} y su traduccion "${en}" ${y} en la version inglesa`
      + ` — el glosario de tools/lint-i18n.mjs le da una sola traduccion a cada termino del curso`);
  }
}

// --- regla 13: el multiconjunto de spans `inline` ----------------------------
// Es la regla 3 --los {{code:}} tienen que ser los mismos-- llevada al codigo
// citado en prosa, que es donde vive la mitad del vocabulario del curso. El bug
// que la motiva: el castellano avisa que `get_export` es un alias de
// `get_peek_export` y que ESE es el nombre que se ve en `print_topology()`; el
// ingles corto la aposicion entera, y `get_peek_export` no aparece ni una vez
// en las 444 slides en ingles. Estructuralmente los dos archivos son identicos.
//
// Tokenizador de backticks de verdad y no una regex suelta: una corrida de N
// backticks abre y la siguiente corrida de N cierra (asi ``a ` b`` es un span y
// no tres). Un span que se estira mas de un renglon no es un span -- es un
// backtick perdido --, pero UNO solo si, porque la prosa va a 80 columnas y
// parte los spans largos al medio.
//
// Los alias son de SPAN ENTERO y no de palabra, y eso no es un detalle: `name`
// suelto es el placeholder que el curso traduce, pero el `name` de
// `(string name, uvm_component parent)` es la firma de UVM y se escribe igual
// en los dos idiomas. Cambiar la palabra adentro del span rompia doce lugares del deck.
const ALIAS_SPAN = new Map([
  ['cb.d_in <= value', 'cb.d_in <= valor'],
  ['$cast(destination, source)', '$cast(destino, origen)'],
  ['source', 'origen'],
  ['destination', 'destino'],
  ['new("name", this)', 'new("nombre", this)'],
  ['@(posedge something)', '@(posedge algo)'],
  ['"it arrived"', '"llegó"'],
  ['begin : name', 'begin : nombre'],
  ['label : assert property (@(clock) disable iff (reset) antecedent |-> consequent) else action;',
   'label : assert property (@(reloj) disable iff (reset) antecedente |-> consecuente) else acción;'],
]);
// Las rutas que tienen gemelo en disco van aparte porque valen como SUBCADENA:
// el mismo `spec.en.md` aparece solo y adentro del `cd ... && cat ...`.
const ALIAS_RUTA = new Map([
  ['en/libro/day1.html', 'libro/dia1.html'],
  ['docs/en/uvm-cheatsheet.pdf', 'docs/machete-uvm.pdf'],
  ['res/en/machete.html', 'res/machete.html'],
  ['spec.en.md', 'spec.md'],
  // Los docs que ganaron traduccion: el arbol EN tiene que linkear la suya (lo
  // exige la regla 12), y sin estos alias la regla 13 lee ese acierto como
  // divergencia. Las dos reglas se pisaban en once archivos del deck.
  ['docs/en/verilator.md', 'docs/verilator.md'],
  ['docs/en/verification-plan.md', 'docs/plan-de-verificacion.md'],
  // Los README de los ejercicios van al reves que las slides: README.md es el
  // ingles y README.es.md el castellano, porque GitHub solo renderiza el primero.
  ['code/ejercicios/README.md', 'code/ejercicios/README.es.md'],
  ['cat README.md', 'cat README.es.md'],
]);
const RE_ALIAS_RUTA = new RegExp([...ALIAS_RUTA.keys()].map(k => k.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|'), 'g');
const aEspanol = s => ALIAS_SPAN.get(s) ?? s.replace(RE_ALIAS_RUTA, k => ALIAS_RUTA.get(k));

function spansInline(md) {
  const t = md.replace(/```[\s\S]*?```/gm, enBlanco).replace(/<!--[\s\S]*?-->/g, enBlanco);
  const out = [];
  const re = /`+/g;
  let m, abierto = null;
  while ((m = re.exec(t))) {
    if (!abierto) { abierto = m; continue; }
    if (m[0].length !== abierto[0].length) continue;
    const cuerpo = t.slice(abierto.index + abierto[0].length, m.index);
    if ((cuerpo.match(/\n/g) ?? []).length <= 1) out.push(cuerpo.replace(/\s+/g, ' ').trim());
    abierto = null;
  }
  return out;
}

const contar = xs => xs.reduce((m, x) => m.set(x, (m.get(x) ?? 0) + 1), new Map());
const sobrantes = (a, b) => [...a].filter(([k, v]) => (b.get(k) ?? 0) < v)
  .map(([k, v]) => `\`${k}\`${v - (b.get(k) ?? 0) > 1 ? ` ×${v - (b.get(k) ?? 0)}` : ''}`);

function comparaSpans(fEs, fEn, aEs, aEn) {
  const a = contar(spansInline(aEs));
  const b = contar(spansInline(aEn).map(aEspanol));
  const faltan = sobrantes(a, b), sobran = sobrantes(b, a);
  if (!faltan.length && !sobran.length) return;
  fail(fEn, `no coinciden los spans de codigo inline con ${fEs}:`
    + (faltan.length ? `\n      solo en es: ${faltan.join(' · ')}` : '')
    + (sobran.length ? `\n      solo en en: ${sobran.join(' · ')}` : ''));
}

// --- regla 15: los bloques ``` escritos a mano -------------------------------
// code/README.md:59-64 fija la politica y code/ la cumple al 100 %: los
// identificadores NO se traducen. Los bloques pegados a mano en las slides son
// el unico lugar donde no aplica, y ahi se aplica a medias: tres bloques
// traducen el identificador (`valor`→`value`, `demotar_pslverr`→`demote_pslverr`,
// `transaccion esperado`→`transaction expected`) y ocho no, asi que el alumno
// que compara los dos decks ve una clase con dos nombres.
//
// Lo que SI se traduce y por eso no cuenta: los comentarios y los strings
// --el `uvm_error("SB", "una respuesta que nadie pidio")` le habla al alumno--.
// Se comparan solo los bloques de lenguaje de codigo: un bloque sin lenguaje o
// en `sh` suele ser salida de consola, que va traducida entera.
const sinTextoTraducible = s => s.split('\n')
  .map(l => l
    .replace(/"[^"\n]*"|'[^'\n]*'/g, '""')          // los strings le hablan al alumno
    .replace(/\/\/.*$/, '').replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/(?<![:\w"])#(?!\{).*$/, '')
    .replace(/\s+/g, ' ').trim())
  // Una linea que abre y cierra con "..." es prosa haciendo de codigo
  // ("... los items del escenario, sin nadie en el medio ..."), no codigo.
  .filter(l => !/^\.\.\..*\.\.\.$/.test(l))
  .join('\n').trim();

function comparaBloques(fEs, fEn, aEs, aEn) {
  const bloques = md => [...md.matchAll(/^```(\w*)\n([\s\S]*?)^```/gm)].map(m => [m[1], m[2]]);
  const [A, B] = [bloques(aEs), bloques(aEn)];
  for (let i = 0; i < Math.min(A.length, B.length); i++) {
    if (!/^(systemverilog|sv|verilog)$/.test(A[i][0]) || A[i][1] === B[i][1]) continue;
    const [x, y] = [sinTextoTraducible(A[i][1]), sinTextoTraducible(B[i][1])];
    if (x === y) continue;
    const linea = y.split('\n').find((l, j) => l !== x.split('\n')[j]) ?? '';
    fail(fEn, `el bloque \`\`\` #${i + 1} difiere de ${fEs} en algo que no es un comentario ni un string`
      + ` ("${linea.slice(0, 60)}") — los identificadores no se traducen (code/README.md:59-64)`);
  }
}

// --- regla 14: el `cd <dir> && cat <archivo>` de las slides de ejercicio ------
// La slide de arranque de un ejercicio ES el comando que el alumno copia y
// pega. El ingles decia `cat README.en.md`, un archivo que no existe en ningun
// lado del repo; el castellano decia `cat README.md`, que en code/ejercicios/
// es JUSTO el enunciado en ingles. Cada arbol mandaba al lugar equivocado para
// su propio lector, y el pegado fallaba en uno de los dos casos.
//
// El mapa ya esta en PARES_MD: [fuente, traduccion]. El deck en castellano
// tiene que nombrar la fuente y el ingles la traduccion.
async function comandoDeEjercicio(fEs, fEn) {
  for (const [f, es] of [[fEs, true], [fEn, false]]) {
    const md = await readFile(f, 'utf8');
    for (const m of md.matchAll(/`cd ([^`\n]+?) && cat ([^`\n]+?)`/g)) {
      const [, dir, base] = m, ruta = path.join(dir, base);
      const n = md.slice(0, m.index).split('\n').length;
      if (!await stat(ruta).then(() => true, () => false)) {
        fail(`${f}:${n}`, `el comando de la slide abre ${ruta} y ese archivo no existe`);
        continue;
      }
      const par = PARES_MD.find(([, fuente, trad]) => base === fuente || base === trad);
      if (!par) continue;
      const debe = es ? par[1] : par[2];
      if (base !== debe)
        fail(`${f}:${n}`, `el comando de la slide abre ${base}, que en ${dir} es la version del OTRO idioma`
          + ` — el deck en ${es ? 'castellano' : 'ingles'} tiene que decir ${debe}`);
    }
  }
}

// --- regla 16: la tipografia de los porcentajes ------------------------------
// Cada arbol es casi consistente y los tres desvios estan en los lugares mas
// visibles: el alt del GIF del README fuente dice `86.8%` y dos renglones mas
// abajo el mismo numero se escribe `86,8 %`; docs/verilator.md es el unico
// lugar del arbol castellano con punto decimal en prosa; y README.md es el
// unico archivo del arbol ingles sin el espacio que sus otros 103 porcentajes
// llevan. Se mira SOLO el numero pegado a un %, que es donde el repo tiene una
// convencion: 1800.2, 2020.3 y CC BY 4.0 son versiones y normas, no decimales.
// Y se deja afuera la salida literal de la herramienta, `86.8% (66/76)`, que es
// la que escribe `make matrix` y no se toca.
const RE_PORCENTAJE = /(?<![\w.,])(\d+)(?:([.,])(\d+))?(\s?)%/g;

function tipografia(f, md, es) {
  // Aca NO se usa soloProsa(): borra los tags enteros y el `86.8%` que arranca
  // este hallazgo esta adentro del alt= del GIF del README, que es texto que el
  // lector VE. Lo que se borra es el `style="width:26%"`, que es CSS.
  const t = md
    .replace(/```[\s\S]*?```/g, enBlanco)
    .replace(/<(script|style|pre)\b[^>]*>[\s\S]*?<\/\1>/gi, enBlanco)
    .replace(/<!--[\s\S]*?-->/g, enBlanco)
    .replace(/`[^`\n]*`/g, enBlanco)
    .replace(/style="[^"]*"/g, enBlanco)
    .replace(/\d\s?%\s*\(\s*\d+\s*\/\s*\d+\s*\)/g, enBlanco);
  for (const m of t.matchAll(RE_PORCENTAJE)) {
    const mal = [];
    if (m[2] && m[2] !== (es ? ',' : '.')) mal.push(`el separador decimal del arbol ${es ? 'castellano es la coma' : 'ingles es el punto'}`);
    if (m[4] !== ' ') mal.push('falta el espacio antes del %');
    if (!mal.length) continue;
    fail(`${f}:${t.slice(0, m.index).split('\n').length}`, `"${m[0].trim()}": ${mal.join(' y ')}`);
  }
}

const CAMPOS = [
  ['slides', 'la cantidad de slides'],
  ['dias', 'los marcadores id="dayN"'],
  ['notas', 'la cantidad de Note:'],
  ['quiz', 'las opciones del quiz o cual esta marcada'],
  ['codigo', 'los {{code:}} que se incluyen'],
];

// Los pares que este linter efectivamente comparo: son el mapa fuente↔traduccion
// que necesita la regla 12, y sale de aca y no de una segunda tabla a mano.
const paresVistos = [];

async function comparar(fEs, fEn, nombre) {
  paresVistos.push([fEs, fEn].map(p => p.split(path.sep).join('/')));
  const [aRaw, bRaw] = await Promise.all([readFile(fEs, 'utf8'), readFile(fEn, 'utf8')]);
  const marca = bRaw.match(MARCA);
  if (!marca) fail(fEn, 'le falta la linea "<!-- es-sha: ... -->" del principio — corre: node tools/lint-i18n.mjs --bless ' + fEn);
  else if (marca[1] !== sha(aRaw))
    fail(fEn, `${fEs} cambio desde que se tradujo. Revisa la traduccion y despues: node tools/lint-i18n.mjs --bless ${fEn}`);
  // Regla 8. Sin sinMarca(): sacar la linea del sello correria un renglon todos
  // los numeros de linea del mensaje. El comentario lo borra soloProsa() igual.
  //
  // En un .html el umbral es UNO y no dos, porque la prosa de una landing es un
  // <li> de temario de cuatro palabras --"uvm_component y las fases"-- y el
  // umbral de dos no se alcanza nunca. Lo que hace que eso no sea ruido es que
  // soloProsa() ya borro el <script>, el <style>, el <pre> y el callout
  // lang="es", que es todo el castellano legitimo de esos dos archivos.
  castellanoSuelto(fEn, bRaw, fEn.endsWith('.md') ? 2 : 1);
  placeholderSinTraducir(fEn, bRaw);
  glosario(fEs, fEn, aRaw, sinMarca(bRaw));
  tipografia(fEs, aRaw, true);
  tipografia(fEn, bRaw, false);
  // La paridad de slides/{{code:}}/quiz solo tiene sentido entre dos slides.
  if (nombre.endsWith('.md') && !nombre.includes('README')) {
    const a = partes(aRaw), b = partes(sinMarca(bRaw));
    for (const [k, que] of CAMPOS) {
      const [x, y] = [a[k], b[k]].map(v => Array.isArray(v) ? v.join(' · ') : String(v));
      if (x !== y) fail(fEn, `no coincide ${que}:\n      es: ${x}\n      en: ${y}`);
    }
    // Las tres de abajo son de SLIDES y no de cualquier par .md: en un doc los
    // spans y los bloques son otra cosa --docs/en/setup.md nombra
    // `docs/en/verilator.md` donde el castellano nombra `docs/verilator.md`, y
    // eso lo mira la regla 12, no esta--.
    if (fEs.startsWith(ES + path.sep)) {
      comparaSpans(fEs, fEn, aRaw, sinMarca(bRaw));
      comparaBloques(fEs, fEn, aRaw, sinMarca(bRaw));
      await comandoDeEjercicio(fEs, fEn);
    }
  }
}

// --- 1. el arbol de slides ---------------------------------------------------
const esFiles = (await readdir(ES)).filter(f => f.endsWith('.md')).sort();

// --dia N: que secciones de ese dia faltan traducir. El curso se traduce de a un
// dia por vez, y el dia de una seccion no esta en su nombre -- sale del id="dayN"
// que declara la seccion donde empieza, y vale hasta el id siguiente.
if (process.argv.includes('--dia') || process.argv.includes('--pendientes')) {
  const pedido = Number(process.argv[process.argv.indexOf('--dia') + 1]);
  const enSet = new Set((await readdir(EN).catch(() => [])).filter(f => f.endsWith('.md')));
  let dia = 0;
  const porDia = new Map();
  for (const f of esFiles) {
    const md = await readFile(path.join(ES, f), 'utf8');
    const m = md.match(/id="day(\d)"/);
    if (m) dia = +m[1];
    const slides = 1 + (md.match(/^---$/gm) ?? []).length;
    if (!porDia.has(dia)) porDia.set(dia, []);
    porDia.get(dia).push({ f, slides, hecho: enSet.has(f) });
  }
  for (const [d, ss] of [...porDia].sort((a, b) => a[0] - b[0])) {
    if (Number.isFinite(pedido) && d !== pedido) continue;
    const faltan = ss.filter(s => !s.hecho);
    const sl = faltan.reduce((n, s) => n + s.slides, 0);
    // El dia 0 son la portada y el "como usar", que no cuelgan de ningun id="dayN".
    const nombre = d ? `dia ${d}` : 'portada';
    if (!faltan.length) { console.log(`${nombre}: completo (${ss.length} secciones)`); continue; }
    console.log(`${nombre}: faltan ${faltan.length} de ${ss.length} secciones, ${sl} slides`);
    if (Number.isFinite(pedido)) for (const s of ss) {
      console.log(`  ${s.hecho ? '✓' : ' '} ${path.join(ES, s.f).padEnd(46)} ${String(s.slides).padStart(3)} slides`);
    }
  }
  process.exit(0);
}
const enFiles = (await readdir(EN).catch(() => [])).filter(f => f.endsWith('.md')).sort();

for (const f of enFiles) {
  if (!esFiles.includes(f)) { fail(path.join(EN, f), `no existe ${path.join(ES, f)}: es la traduccion de una seccion que ya no esta`); continue; }
  await comparar(path.join(ES, f), path.join(EN, f), f);
}

// --- 2. los README de los ejercicios ----------------------------------------
let paresMd = 0;
for (const [raiz, base, hermano] of PARES_MD) {
  const dirs = (await readdir(raiz, { withFileTypes: true })).filter(e => e.isDirectory());
  for (const d of [{ name: '.' }, ...dirs]) {
    const es = path.join(raiz, d.name, base), en = path.join(raiz, d.name, hermano);
    if (!await readFile(en, 'utf8').then(() => true).catch(() => false)) continue;
    if (!await readFile(es, 'utf8').then(() => true).catch(() => false)) { fail(en, `no existe ${es}`); continue; }
    await comparar(es, en, hermano);
    paresMd++;
  }
}

// --- 3. la landing y cualquier otro par suelto --------------------------------
let sueltos = 0;
for (const [es, en] of PARES_SUELTOS) {
  if (!await readFile(en, 'utf8').then(() => true).catch(() => false)) continue;
  await comparar(es, en, path.basename(en));
  sueltos++;
}

// --- 4. las figuras, en el idioma del deck -----------------------------------
// El bug que motiva la regla: el commit que tradujo el curso tradujo los SVG EN
// EL MISMO ARCHIVO, y el deck en castellano paso a mostrarlas todas en ingles
// --incluida la anatomia del testbench de la slide 11--. Ninguna regla de
// arriba lo ve: una figura no es un .md, y la slide que la incluye es identica
// en los dos idiomas salvo la ruta.
//
// La convencion es la del resto del repo: res/<X>.svg en castellano, res/<X>/en/
// en ingles. Aca no se chequea la ruta sino lo que dice la figura, que es lo que
// el alumno ve.
//
// Se buscan palabras funcionales del OTRO idioma fuera del texto MONOESPACIADO
// --que es codigo, y `this`, `type_id::create` o `set()` no son ingles-- y se
// pide un minimo de dos por figura: una sola suele ser un nombre propio o una
// sigla, dos es una frase.
const INGLES = ['the', 'of', 'and', 'with', 'what', 'which', 'when', 'where', 'this', 'these',
  'those', 'each', 'every', 'from', 'until', 'between', 'about', 'also', 'more', 'never',
  'always', 'same', 'other', 'how', 'besides', 'although', 'then', 'now', 'after', 'before',
  'while', 'are', 'is', 'has', 'have', 'can', 'does', 'not', 'only', 'they', 'its', 'your', 'you'];
const RE_INGLES = new RegExp(String.raw`(?<![\w'-])(${INGLES.join('|')})(?![\w'-])`, 'gi');

// El texto que se LEE de una figura: los <text> y el <title>, sin lo que este en
// monoespaciado (un <text> mono entero, o un <tspan> mono adentro de uno sans).
const MONO = /IBM Plex Mono/;
function prosaDeFigura(svg) {
  const partes = [...svg.matchAll(/<title>([\s\S]*?)<\/title>/g)].map(m => m[1]);
  for (const m of svg.matchAll(/<text\b([^>]*)>([\s\S]*?)<\/text>/g)) {
    if (MONO.test(m[1])) continue;
    partes.push(m[2].replace(/<tspan\b([^>]*)>([\s\S]*?)<\/tspan>/g,
      (_, attr, txt) => (MONO.test(attr) ? ' ' : txt)));
  }
  return partes.join(' ').replace(/<[^>]+>/g, ' ');
}

// Las figuras que muestra un deck: las imagenes de las slides y las del machete
// (data-machete, que es una lista separada por comas).
async function figurasDe(dir) {
  const out = new Set();
  for (const f of (await readdir(dir).catch(() => [])).filter(f => f.endsWith('.md'))) {
    const md = await readFile(path.join(dir, f), 'utf8');
    for (const m of md.matchAll(/!\[[^\]]*\]\(([^)]+\.svg)\)/g)) out.add(m[1]);
    for (const m of md.matchAll(/data-machete="([^"]+)"/g))
      // La entrada es "ruta|alt" y el alt lleva comas: se corta donde arranca
      // una ruta, y despues se descarta el alt, que no es una figura.
      for (const r of m[1].split(/,(?=\s*res\/)/)) {
        const ruta = r.split('|')[0].trim();
        if (ruta.endsWith('.svg')) out.add(ruta);
      }
  }
  return [...out].sort();
}

let figuras = 0;
for (const [dir, re, otro] of [[ES, RE_INGLES, 'ingles'], [EN, RE_CASTELLANO, 'castellano']]) {
  for (const fig of await figurasDe(dir)) {
    const svg = await readFile(fig, 'utf8').catch(() => null);
    if (svg === null) { fail(fig, `la referencia ${dir}/ y el archivo no existe`); continue; }
    figuras++;
    const hits = [...prosaDeFigura(svg).matchAll(re)].map(m => m[0]);
    // La figura del otro idioma: la del ingles vive en un en/ al lado de la del
    // castellano, asi que el par se saca agregando o sacando ese segmento.
    const par = fig.includes('/en/') ? fig.replace('/en/', '/')
                                     : path.join(path.dirname(fig), 'en', path.basename(fig));
    if (hits.length >= 2)
      fail(fig, `la muestra el deck de ${dir.slice(-2)} y tiene texto en ${otro} ("${[...new Set(hits)].slice(0, 4).join(' ')}"...)`
        + ` — traducila; la del otro idioma es ${par}`);
  }
}

// --- 5. regla 12: los links de un arbol al otro ------------------------------
// El curso en ingles manda al lector a la version castellana de un doc que
// TIENE traduccion en docs/en/, y en tres de esos lugares encima la etiqueta
// "(in Spanish)", que hoy es falso. Y al reves: docs/instalar.md manda al
// lector castellano a code/README.md, que despues del rename es el ingles.
// Diecinueve lugares en total, y el mapa para verlos ya existe: es el par
// [fuente, traduccion] que este mismo linter acaba de sellar.
//
// La otra mitad, en AVISO: la convencion del repo --escrita arriba en este
// mismo archivo y en README.md-- es que una cita del arbol ingles a un doc que
// sigue SOLO en castellano lleve "(in Spanish)" al lado. Se cumple en once
// lugares y se olvida en ocho. Es aviso y no error porque lo que falta es una
// aclaracion, no un archivo, y porque la ventana de 200 caracteres es una
// heuristica.
//
// Se miran las rutas escritas como link, como href o adentro de backticks:
// lint-refs chequea que el archivo EXISTA --y existe--, asi que nadie lo ve.
const norma = p => path.normalize(p).split(path.sep).join('/');
const RE_RUTA = /`([^`\n]+)`|<code[^>]*>([^<]+)<\/code>|\]\(([^)\s]+)\)|href="([^"]+)"/g;
// La landing linkea con la URL completa de GitHub; el resto del repo con rutas
// relativas. Es la misma ruta con un prefijo, y lint-refs ya lo resuelve asi.
const RE_GH = /^https:\/\/github\.com\/[\w.-]+\/[\w.-]+\/(?:blob|raw|tree)\/(?:master|main)\//;
const traduccionDe = new Map(paresVistos);
const fuenteDe = new Map(paresVistos.map(([es, en]) => [en, es]));
const docsEn = new Set((await readdir(path.join('docs', 'en')).catch(() => [])));
// docs/README.md es el indice de docs/: su trabajo es nombrar las dos columnas
// del par, asi que nombrar el otro lado no es un error ahi.
const INDICE = 'docs/README.md';
// Y todo doc de docs/en/ que no este pareado --el banco de examen, que lo
// genera tools/i18n.mjs, y el indice-- entra igual del lado ingles.
const ladoEN = [...new Set([...paresVistos.map(([, en]) => en),
  ...[...docsEn].filter(f => f.endsWith('.md')).map(f => `docs/en/${f}`)])];
const ladoES = [...new Set(paresVistos.map(([es]) => es))];
const GENERADOS = { 'docs/en/exam-bank.md': 'tools/i18n.mjs' };

for (const [f, esIngles] of [...ladoEN.map(f => [f, true]), ...ladoES.map(f => [f, false])]) {
  if (f === INDICE) continue;
  const crudo = await readFile(f, 'utf8').catch(() => null);
  if (crudo === null) continue;
  const t = crudo.replace(/```[\s\S]*?```/g, enBlanco).replace(/<!--[\s\S]*?-->/g, enBlanco);
  const editar = GENERADOS[f] ? `${GENERADOS[f]} (${f} lo genera \`npm run build\`)` : f;
  const vistos = new Set();
  for (const m of t.matchAll(RE_RUTA)) {
    const tok = (m[1] ?? m[2] ?? m[3] ?? m[4]).trim().replace(RE_GH, '');
    if (!/\.(md|html)$/.test(tok) || /^https?:/.test(tok)) continue;
    const n = t.slice(0, m.index).split('\n').length;
    const linea = t.split('\n')[n - 1];
    // La linea de idioma que llevan los 42 README y las dos landings ("English
    // · Castellano") apunta al otro arbol a proposito: es el conmutador.
    if (/\[English\]|\*\*English\*\*|\[Castellano\]|\*\*Castellano\*\*|README (en castellano|in English)/.test(linea)) continue;
    for (const c of [norma(path.join(path.dirname(f), tok)), norma(tok)]) {
      // Un archivo que nombra a su PROPIO gemelo es el conmutador de idioma o
      // el parrafo que explica la convencion; no es un link cruzado.
      if (traduccionDe.get(c) === f || fuenteDe.get(c) === f) break;
      const clave = `${n}:${c}`;
      if (vistos.has(clave)) break;
      if (esIngles && traduccionDe.has(c)) {
        vistos.add(clave);
        fail(`${editar}:${n}`, `el material en ingles linkea ${c} teniendo la traduccion al lado: es ${traduccionDe.get(c)}`);
        break;
      }
      if (!esIngles && fuenteDe.has(c)) {
        vistos.add(clave);
        fail(`${editar}:${n}`, `el material en castellano linkea ${c}, que es la traduccion: la fuente es ${fuenteDe.get(c)}`);
        break;
      }
      // Sin gemelo: la cita tiene que decir que el doc esta en castellano.
      if (esIngles && /^docs\/[^/]+\.md$/.test(c) && !docsEn.has(path.basename(c))) {
        vistos.add(clave);
        if (!/in Spanish/i.test(t.slice(m.index, m.index + 200)))
          avisa(`${editar}:${n}`, `cita ${c}, que solo existe en castellano, y no aclara "(in Spanish)"`);
        break;
      }
    }
  }
}

// --- 6. regla 10: castellano adentro de code/ --------------------------------
// code/README.md:33-46 lo dice con todas las letras --"Everything in here is in
// English, and that is deliberate"-- y da la razon: hay UNA sola copia del
// codigo y las slides la incluyen, asi que es lo unico que hace que los dos
// decks muestren lo mismo. La regla se rompio en el peor lugar posible: seis
// comentarios en castellano salen proyectados adentro de un bloque del deck en
// INGLES, entre ellos "// Por Default Es Medium" en la slide de verbosidad.
//
// Y el corrector de d3b es el unico de los 19 que le habla al alumno en
// castellano, "EXERCISE OK: el mismo scoreboard, ahora legible" incluido: es la
// misma falla, en el texto que el alumno lee en vez del que lee el que estudia
// el ejemplo, asi que va en la misma regla.
//
// El umbral aca es UNO y no dos: en code/ no hay prosa castellana legitima, y
// "Por Default Es Medium" tiene una sola palabra que lo delata. Por lo mismo la
// lista es la de la regla 8 mas los verbos que aparecen en un comentario de
// codigo y nunca en prosa de slide.
//
// Lo que se saca antes de mirar: lo que va entre backticks o parece una ruta
// (`code/u3/clases` no es castellano, es un directorio), el TODO(exercise ...)
// --"todo" es una palabra de las dos listas-- y el texto entre comillas de un
// comentario, que suele ser una cita de una slide en castellano dentro de un
// comentario escrito en ingles.
const VERBOS_CODE = ['bloquea', 'vuelve', 'escribió', 'escribio', 'llamado', 'llamada', 'mandar',
  'poner', 'ponemos', 'pone', 'usa', 'usamos', 'sirve', 'falla', 'anda', 'queda', 'pasa', 'saca',
  'muestra', 'imprime', 'arranca', 'termina', 'corre', 'devuelve', 'agrega', 'borra', 'busca',
  'llega', 'llena', 'levanta', 'apaga', 'prende', 'elige', 'recorre', 'compara', 'chequea',
  'extendiendo', 'defecto', 'siguiente', 'acá', 'dentro', 'afuera', 'arriba',
  'abajo', 'recién', 'sólo', 'solo', 'nada', 'algo', 'alguna', 'ninguna', 'cuál', 'cuáles',
  'tenés', 'podés', 'mirá', 'fijate',
  // Morfologia y no vocabulario, para los sustantivos que una lista cerrada no
  // va a tener nunca: no hay palabra del ingles que termine en -ciones o en
  // -cion/-cion, asi que "randomizaciones" y "comparaciones" caen solas.
  String.raw`[a-záéíóúñ]+ci[oó]n(es)?`,
  // Y la referencia de distancia, que lint-coherencia prohibe en las slides y
  // que aca estaba escondida adentro de un comentario del codigo que la slide
  // proyecta: "// Connection Phase -> Detalles en next slide".
  'next slide', 'slide siguiente'];
// "todo" y "y" salen de la lista de la regla 8 para code/: el primero choca con
// los TODO(exercise ...) y el segundo con la senal `y` del VTALU ("y=1").
const RE_CODE = new RegExp(String.raw`(?<![\w'’-])(${[...CASTELLANO.filter(p => p !== 'todo' && p !== 'y'), ...VERBOS_CODE].join('|')})(?![\w'’-])`, 'gi');
const EXT_CODE = new Set(['.sv', '.svh', '.v', '.sh', '.py', '.c', '.cpp', '.h']);
// code/.uvm es la libreria de Accellera vendorizada: no es nuestra y no se toca.
const RE_CODE_IGNORAR = /(^|\/)(\.uvm|obj_dir|node_modules)(\/|$)/;

async function archivosDe(dir, out = []) {
  for (const e of await readdir(dir, { withFileTypes: true }).catch(() => [])) {
    const p = path.join(dir, e.name);
    if (RE_CODE_IGNORAR.test(p.split(path.sep).join('/'))) continue;
    if (e.isDirectory()) await archivosDe(p, out);
    else if (EXT_CODE.has(path.extname(e.name))) out.push(p);
  }
  return out;
}

let lineasCode = 0;
for (const f of await archivosDe('code')) {
  const crudo = await readFile(f, 'utf8');
  const lineas = crudo.split('\n');
  // Para los COMENTARIOS se mira una copia sin lo que va entre comillas, y el
  // blanqueo es de archivo entero y no de linea porque la cita se parte al
  // medio: repro-fork-automatic.sv abre en la linea 8 un comentario en ingles
  // que cita textual una frase de una slide en castellano y la cierra en la 9.
  // Los strings que SI se miran --el echo del corrector-- se sacan de la linea
  // original, abajo.
  const sinCitas = crudo.replace(/"[^"]*"/g, m => m.replace(/[^\n]/g, ' ')).split('\n');
  lineas.forEach((l, i) => {
    const trozos = [];
    const c = sinCitas[i].match(/\/\/(.*)$|\/\*([\s\S]*?)\*\/|(?<![:\w])#(?!\{|!)(.*)$/);
    if (c) trozos.push(c[1] ?? c[2] ?? c[3]);
    // Lo que el alumno LEE: el echo del corrector y el mensaje del report.
    for (const m of l.matchAll(/(?:echo|\$display|\$write|`uvm_info|`uvm_error|`uvm_warning|\$fatal)[^"\n]*"([^"]*)"/g))
      trozos.push(m[1]);
    for (const tr of trozos) {
      // Fuera de alcance: lo que va entre backticks, el TODO(exercise ...),
      // cualquier cosa con una barra (`code/u3/clases` es un directorio, no
      // castellano), los identificadores en MAYUSCULAS --SOLUCION, PSLVERR,
      // UVM_MEDIUM son nombres de variable y de macro, no prosa-- y las
      // variables de shell del corrector, que se llaman en castellano
      // ("FF=$unos%" es el porcentaje de unos, no la palabra "unos").
      const limpio = (tr ?? '').replace(/`[^`]*`/g, ' ').replace(/TODO\([^)]*\)/g, ' ')
        .replace(/[\w./-]*\/[\w./-]*/g, ' ')
        .replace(/\b[A-Z][A-Z0-9_]{2,}\b/g, ' ')
        .replace(/\$\{?\w+\}?/g, ' ');
      const hits = [...limpio.matchAll(RE_CODE)].map(x => x[0]);
      if (!hits.length) continue;
      lineasCode++;
      fail(`${f}:${i + 1}`, `castellano en code/ ("${hits.slice(0, 4).join(' ')}"...): el codigo y sus`
        + ` comentarios van en ingles en los dos cursos (code/README.md:33-46)`);
    }
  });
}

// --- el informe --------------------------------------------------------------
for (const a of avisos) console.log('  ! ' + a);
if (avisos.length) console.log(`${avisos.length} aviso(s)\n`);

if (errores.length) {
  console.error(`✗ ${errores.length} divergencia(s) entre las dos versiones del curso:`);
  for (const e of errores) console.error(`  - ${e}`);
  process.exit(1);
}

const pct = Math.round(enFiles.length / esFiles.length * 100);
const dias = new Set();
for (const f of enFiles) {
  const md = await readFile(path.join(EN, f), 'utf8');
  for (const m of md.matchAll(/id="day(\d)"/g)) dias.add(+m[1]);
}
const detalle = dias.size ? ` · dias ${[...dias].sort().join(', ')}` : '';
console.log(`✓ i18n: en/ no diverge de es/ — ${enFiles.length}/${esFiles.length} secciones (${pct}%)${detalle}`
  + `, ${paresMd} README, ${sueltos} pagina(s) pareadas y ${figuras} figuras en el idioma del deck`);
if (avisos.length && process.argv.includes('--avisos-fallan')) process.exit(1);
