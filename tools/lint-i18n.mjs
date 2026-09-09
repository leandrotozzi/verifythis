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
// Y la landing, que es prosa a mano en los dos idiomas.
const PARES_SUELTOS = [['web/index.html', 'web/en/index.html']];
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
  + `, ${paresMd} README y ${sueltos} pagina(s) pareadas`);
