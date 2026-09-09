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
//   node tools/lint-i18n.mjs                      chequea
//   node tools/lint-i18n.mjs --pendientes         cuanto falta, por dia
//   node tools/lint-i18n.mjs --dia 3              que secciones faltan de ese dia
//   node tools/lint-i18n.mjs --bless <archivo>    re-sella despues de traducir
import { readFile, writeFile, readdir } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import path from 'node:path';
import { SALIDAS } from './i18n.mjs';

const ES = SALIDAS.es.slides;
const EN = SALIDAS.en.slides;
// Los README de los ejercicios son el enunciado, no documentacion del codigo:
// se traducen con las slides y van como par, con el mismo sha.
// Y la spec del capstone, que es enunciado igual que el README: el ejercicio es
// leerla y desconfiar de ella, asi que en ingles tiene que estar en ingles.
const PARES_MD = [['code/ejercicios', 'README.md', 'README.en.md'],
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

const errores = [];
const fail = (f, msg) => errores.push(`${f}: ${msg}`);

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

// El archivo ES del que sale una traduccion: mismo nombre en el arbol es/, o el
// README.md hermano del .en.md.
async function origenDe(f) {
  const n = path.normalize(f);
  if (n.startsWith(EN + path.sep)) return path.join(ES, path.basename(n));
  if (n.endsWith('.en.md')) return n.replace(/\.en\.md$/, '.md');
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
  'del', 'las', 'los', 'una', 'unas', 'unos', 'con', 'por', 'sin', 'ya'];
const RE_CASTELLANO = new RegExp(String.raw`(?<![\w'’-])(${CASTELLANO.join('|')})(?![\w'’-])`, 'gi');

// Todo lo que NO es prosa: los bloques de codigo, el codigo inline, los
// {{code:}}, los comentarios, las URLs, el destino de un link y los tags. Se
// borran reemplazando por espacios del mismo largo, para no correr las lineas.
const enBlanco = m => m.replace(/[^\n]/g, ' ');
const soloProsa = md => md
  .replace(/```[\s\S]*?```/g, enBlanco)
  .replace(/`[^`\n]*`/g, enBlanco)
  .replace(/\{\{[^}]*\}\}/g, enBlanco)
  .replace(/<!--[\s\S]*?-->/g, enBlanco)
  .replace(/<[^>]+>/g, enBlanco)
  .replace(/\]\([^)]*\)/g, enBlanco)
  .replace(/https?:\/\/\S+/g, enBlanco);

function castellanoSuelto(f, md) {
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
    if (ps.length < 2) continue;
    fail(`${f}:${n}`, `quedo castellano sin traducir ("${ps.slice(0, 4).join(' ')}"...) — traducila`
      + ` y despues: node tools/lint-i18n.mjs --bless ${f}`);
  }
}

const CAMPOS = [
  ['slides', 'la cantidad de slides'],
  ['dias', 'los marcadores id="dayN"'],
  ['notas', 'la cantidad de Note:'],
  ['quiz', 'las opciones del quiz o cual esta marcada'],
  ['codigo', 'los {{code:}} que se incluyen'],
];

async function comparar(fEs, fEn, nombre) {
  const [aRaw, bRaw] = await Promise.all([readFile(fEs, 'utf8'), readFile(fEn, 'utf8')]);
  const marca = bRaw.match(MARCA);
  if (!marca) fail(fEn, 'le falta la linea "<!-- es-sha: ... -->" del principio — corre: node tools/lint-i18n.mjs --bless ' + fEn);
  else if (marca[1] !== sha(aRaw))
    fail(fEn, `${fEs} cambio desde que se tradujo. Revisa la traduccion y despues: node tools/lint-i18n.mjs --bless ${fEn}`);
  // Regla 8. Solo sobre .md: la landing en ingles nombra el otro idioma EN
  // castellano a proposito ("Español", "Ver este deck en castellano").
  // Sin sinMarca(): sacar la linea del sello correria un renglon todos los
  // numeros de linea del mensaje. El comentario lo borra soloProsa() igual.
  if (fEn.endsWith('.md')) castellanoSuelto(fEn, bRaw);
  // La paridad de slides/{{code:}}/quiz solo tiene sentido entre dos slides.
  if (nombre.endsWith('.md') && !nombre.includes('README')) {
    const a = partes(aRaw), b = partes(sinMarca(bRaw));
    for (const [k, que] of CAMPOS) {
      const [x, y] = [a[k], b[k]].map(v => Array.isArray(v) ? v.join(' · ') : String(v));
      if (x !== y) fail(fEn, `no coincide ${que}:\n      es: ${x}\n      en: ${y}`);
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
      for (const r of m[1].split(',')) if (r.trim().endsWith('.svg')) out.add(r.trim());
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

// --- el informe --------------------------------------------------------------
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
