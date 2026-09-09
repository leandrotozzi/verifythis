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
//   4. Numeros de inventario -- cuantos ejemplos, ejercicios, slides, secciones,
//      preguntas, dias, figuras, trampas y bloques de codigo tiene el curso --
//      contra lo que hay en el filesystem (tools/inventario.mjs). Un numero
//      escrito a mano envejece solo, y estos viven repartidos en ~25 lugares
//      entre el README, la landing, el CITATION.cff, los docs y las slides:
//      agregar una slide rompia media docena de frases sin que nada avisara.
//      Se controlan las dos formas, "37 ejemplos" y "catorce soluciones".
//
// Uso: node tools/lint-refs.mjs
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { inventario } from './inventario.mjs';
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
const SUELTOS = ['README.md', 'CONTRIBUTING.md', 'ROADMAP.md', 'Makefile', 'CITATION.cff'];
const EXT = new Set(['.md', '.html', '.sv', '.svh', '.sh', '.mjs', '.yml', '.xml']);
const IGNORAR = /(^|\/)(node_modules|vendor|\.git|\.uvm|obj_dir|dist|libro)(\/|$)/;

const RE_MAKE_CH = /\bmake\s+ch\d+/g;
// "24 capitulos" es el libro de Salemi, no el curso: esa referencia es correcta.
const RE_CAP = /\b(cap\.\s*\d|cap[ií]tulos?\s+\d)/gi;
const EXCEPCION_CAP = /24 cap[ií]tulos|tiene 24/i;
// Solo links relativos a archivos del repo: nada de http, anclas ni mailto.
const RE_LINK = /\]\(([^)#?:\s]+?)(?:#[^)]*)?\)/g;

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
  // "bloques" queda AFUERA a proposito: el deck tiene 191 bloques de codigo y
  // 151 de ellos vienen de code/, y la prosa usa las dos cuentas segun de que
  // este hablando. Una palabra con dos significados no se puede chequear sin
  // que el lint mienta la mitad de las veces.
};

// Los numeros escritos con letras. Solo de diez para arriba: por debajo, un
// "cuatro fases" o un "cinco slides mas adelante" es un conteo local y no el
// inventario del curso, y no hay forma barata de distinguirlos.
const PALABRAS = {
  diez: 10, once: 11, doce: 12, trece: 13, catorce: 14, quince: 15,
  dieciseis: 16, dieciséis: 16, diecisiete: 17, dieciocho: 18, diecinueve: 19,
  veinte: 20, treinta: 30, cuarenta: 40, cincuenta: 50,
  ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15,
  sixteen: 16, seventeen: 17, eighteen: 18, nineteen: 19,
  twenty: 20, thirty: 30, forty: 40, fifty: 50,
};

// Conteos legitimos que usan las mismas palabras y NO son el inventario.
//   "Dia 6 - 10 preguntas"        el repaso de un dia, no el banco entero
//   "Day 6 - 10 questions"        lo mismo en el banco en ingles
//   "1 de cada 257 soluciones"    el solver SMT, que resuelve otra cosa
//   "cinco slides mas adelante"   una referencia relativa
const LOCALES = /D(?:[ií]a|ay)\s+\d|solve|solver|constraint|randomize|z3|LRM|m[aá]s (adelante|atr[aá]s)/i;
// Y un caso aparte, porque solo se reconoce por lo que viene ANTES del numero:
// "los otros doce ejercicios" son los que no son el capstone, no los catorce.
const RELATIVO = /\b(otr[oa]s?|dem[aá]s|primer[oa]s?|[uú]ltim[oa]s?|siguientes|restantes|other|others|first|last|remaining|previous)\s+$/i;

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

// Un numero seguido de un sustantivo del inventario, en digitos o en letras.
const RE_INVENTARIO = new RegExp(
  String.raw`\b(\d+|${Object.keys(PALABRAS).join('|')})\s+([a-záéíóúñ]+)`, 'gi');

// En la landing los numeros van partidos por tags -- <b>400</b><span>slides</span> --
// y asi se le escapan a la regla 4, que es justo donde mas duele: el numero que
// ve el que llega de Google. Los tags se reemplazan por espacios del MISMO largo,
// para que los indices y por lo tanto los numeros de linea sigan valiendo.
const sinTags = s => s.replace(/<[^>]+>/g, m => ' '.repeat(m.length));

const lista = [...SUELTOS];
for (const r of RAICES) if (await existe(r)) lista.push(...await archivos(r));

for (const f of lista) {
  if (!(await existe(f))) continue;
  const txt = await readFile(f, 'utf8');
  const linea = i => txt.slice(0, i).split('\n').length;

  // Dos archivos hablan DE las referencias viejas, asi que las contienen a
  // proposito: este lint y el roadmap que anota los defectos a arreglar.
  if (['lint-refs.mjs', 'ROADMAP.md'].includes(path.basename(f))) continue;

  for (const m of txt.matchAll(RE_MAKE_CH)) {
    errores.push(`${f}:${linea(m.index)} — "${m[0]}" no es un target del Makefile (hoy: make u4/tests)`);
  }

  for (const m of txt.matchAll(RE_CAP)) {
    const ctx = txt.slice(Math.max(0, m.index - 40), m.index + 40);
    if (EXCEPCION_CAP.test(ctx)) continue;
    errores.push(`${f}:${linea(m.index)} — "${m[0].trim()}": el curso tiene unidades y secciones, no capitulos numerados`);
  }

  const plano = path.extname(f) === '.html' ? sinTags(txt) : txt;
  for (const m of plano.matchAll(RE_INVENTARIO)) {
    const n = PALABRAS[m[1].toLowerCase()] ?? Number(m[1]);
    const que = Object.keys(NOMBRES).find(k => NOMBRES[k].test(m[2].toLowerCase()));
    // De diez para abajo casi siempre es un conteo local ("cuatro fases"), y
    // un numero un orden de magnitud afuera no es una cuenta vieja: es otra
    // cosa que usa la misma palabra. "1 de cada 257 soluciones" es el solver
    // SMT, no los catorce ejercicios.
    if (!que || n < 10 || n > 10 * REAL[que] || n === REAL[que]) continue;
    if (LOCALES.test(plano.slice(Math.max(0, m.index - 45), m.index + 45))) continue;
    if (RELATIVO.test(plano.slice(Math.max(0, m.index - 25), m.index))) continue;
    errores.push(`${f}:${linea(m.index)} — dice "${m[0].replace(/\s+/g, ' ').trim()}" y hoy son ${REAL[que]}`);
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
      if (candidatos.some(c => c.startsWith('..'))) continue;
      if (!(await Promise.all(candidatos.map(existe))).some(Boolean)) {
        errores.push(`${f}:${linea(m.index)} — link roto: ${destino}`);
      }
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
