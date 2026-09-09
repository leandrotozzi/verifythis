// slides/<idioma>/*.md (+ code/) -> index.html (reveal, autocontenido) y
// dist/slides.md (pandoc).
//
// Un solo mecanismo, {{code:ruta}}, alimenta las tres salidas: deck, PDF y PPTX.
// index.html se genera con todo inlineado: sin fetch en runtime, por eso anda
// abriendolo con doble clic (file://), offline y sin servidor.
//
//   node tools/build.mjs             el deck en castellano, en la raiz
//   node tools/build.mjs --lang=en   el deck en ingles, en en/
import { readFile, writeFile, mkdir, readdir } from 'node:fs/promises';
import path from 'node:path';
import { UI, grupos as gruposDelIndice, idiomaDeArgv, SALIDAS } from './i18n.mjs';

// El idioma del curso. code/ y res/ NO se duplican: estan en ingles y los
// comparten las dos versiones. Lo unico que cambia de idioma es slides/.
const IDIOMA = idiomaDeArgv();
const OUT = SALIDAS[IDIOMA];
const T = UI[IDIOMA];

const SLIDES_DIR = OUT.slides;
const TEMPLATE = 'tools/template.html';
const OUT_HTML = OUT.html;
// --check: no escribe nada, solo verifica que index.html este al dia con slides/.
// Sirve para CI y para no commitear un index.html viejo.
const CHECK = process.argv.includes('--check');
const OUT_MD = OUT.md;
// El banco de examen se commitea, como index.html: un profesor lo tiene que
// poder leer en GitHub sin clonar ni buildear nada.
const OUT_BANCO = OUT.banco;
// Las trampas del apendice, como pagina suelta. El deck no le da a un buscador
// una sola linea que indexar, y esta es justo la tabla que alguien googlea a las
// tres de la manana ("randomize devuelve 0 verilator"). Sale del MISMO apendice.
const OUT_TRAMPAS = OUT.trampas;
// para-docentes.md vive en docs/; el banco del ingles esta en docs/en/.
const DOCENTES = path.relative(path.dirname(OUT_BANCO), 'docs/para-docentes.md');

const LANG = {
  '.sv': 'sv', '.svh': 'sv', '.vhd': 'vhdl', '.vhdl': 'vhdl',
  '.do': 'tcl', '.py': 'python',
  '.f': 'plaintext', '.txt': 'plaintext', '.questa': 'plaintext', '.log': 'plaintext',
};

const errors = [];
const fail = (file, msg) => errors.push(`${file}: ${msg}`);
// Contadores para el resumen del final: los numeros del README y de la landing
// salen de aca, para no volver a desactualizarlos a mano.
const stats = { includes: 0, recortados: 0 };

// {{code:ruta}} o {{code:ruta|lines=12-24}}
const RE_CODE = /^([ \t]*)\{\{code:([^}|]+?)(?:\|lines=(\d+)-(\d+))?\}\}[ \t]*$/gm;

async function expand(md, src) {
  const jobs = [];
  md.replace(RE_CODE, (...m) => { jobs.push(m); return ''; });

  const done = new Map();
  for (const [full, , file, from, to] of jobs) {
    const rel = file.trim();
    let text;
    try {
      text = await readFile(rel, 'utf8');
    } catch {
      fail(src, `{{code:${rel}}} -> el archivo no existe`);
      continue;
    }
    if (from) {
      const lines = text.split('\n');
      if (+to > lines.length) fail(src, `{{code:${rel}|lines=${from}-${to}}} -> solo tiene ${lines.length} lineas`);
      text = lines.slice(+from - 1, +to).join('\n');
    }
    text = text.replace(/\s+$/, '');
    // Un ``` o un --- suelto dentro del codigo romperia el fence o el separador
    // de slides. Mejor romper el build que emitir un deck corrupto en silencio.
    if (/^\s*```/m.test(text)) fail(src, `${rel} contiene \`\`\` — rompe el bloque de codigo`);
    if (/^\s*---\s*$/m.test(text)) fail(src, `${rel} contiene una linea "---" — rompe el separador de slides`);
    if (/<\/textarea/i.test(text)) fail(src, `${rel} contiene </textarea — rompe el inline en index.html`);

    stats.includes++;
    if (from) stats.recortados++;
    const lang = LANG[path.extname(rel).toLowerCase()] ?? 'plaintext';
    done.set(full, '```' + lang + '\n' + text + '\n```');
  }
  return md.replace(RE_CODE, (full) => done.get(full) ?? full);
}

const files = (await readdir(SLIDES_DIR).catch(() => [])).filter(f => f.endsWith('.md')).sort();
// El arbol en ingles se llena de a un dia por vez, y arranca vacio: eso no es un
// error, es el estado normal antes de traducir el dia 1. El castellano SI tiene
// que estar -- si no esta, algo se rompio.
if (!files.length) {
  if (IDIOMA === 'es') throw new Error(`no hay .md en ${SLIDES_DIR}/`);
  console.log(`${SLIDES_DIR}/ vacio: no hay nada que generar todavia`);
  process.exit(0);
}

const chapters = [];
for (const f of files) {
  const raw = await readFile(path.join(SLIDES_DIR, f), 'utf8');
  chapters.push({ f, md: (await expand(raw, f)).trim() });
}

if (errors.length) {
  console.error(`\nbuild abortado — ${errors.length} error(es):`);
  errors.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}

// --- index.html: cada seccion como un <section data-markdown> inlineado ---
// Sin data-separator-vertical: el deck es plano, 0 stacks verticales.
const sections = chapters.map(c => `      <section data-markdown data-separator="\\r?\\n---\\r?\\n" data-separator-notes="^Note:">
        <textarea data-template>
${c.md}
        </textarea>
      </section>
      <!-- ${c.f} -->`).join('\n\n');

// --- Indice: un item por seccion -------------------------------------------
// El deck es plano (cero stacks verticales), asi que el indice horizontal de la
// primera slide de cada seccion alcanza para linkearlo con href="#/N" -- que
// es navegacion nativa de reveal, sin un solo handler de click.
//
// Los grupos arrancan donde una slide declara uno de estos ids. Agregar un dia
// es agregar una linea; una seccion nueva entra sola, en el grupo que le toca.
// Los apendices, el glosario y el cierre no tienen grupo propio: viven entre el
// id="day7" y el id="day8", y por eso caen adentro del dia 7, que es donde se
// dictan. El dia 8 arranca DESPUES del cierre a proposito: es opcional.
const GRUPOS = gruposDelIndice(IDIOMA);
const esc = t => t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

let pos = 0, grupo = '';
const items = chapters.map(c => {
  // Sin los bloques de codigo: un "# comentario" adentro de un fence no es titulo.
  const titulo = c.md.replace(/^```[\s\S]*?\n```/gm, '').match(/^#{1,4} +(.+?)\s*$/m)?.[1];
  const id = c.md.match(/id="([a-z0-9-]+)"/)?.[1];
  if (GRUPOS[id]) grupo = GRUPOS[id];
  const item = { grupo, titulo: titulo ?? c.f, h: pos };
  pos += 1 + (c.md.match(/^---$/gm) || []).length;
  return item;
});

const indice = items.map((it, i) => {
  const nuevo = it.grupo !== items[i - 1]?.grupo;
  return (nuevo && i ? '        </ul>\n' : '')
    + (nuevo ? `        <h3 class="ind-grupo">${esc(it.grupo)}</h3>\n        <ul>\n` : '')
    + `          <li><a href="#/${it.h}" data-h="${it.h}"><span>${esc(it.titulo)}</span><span class="ind-n">${it.h + 1}</span></a></li>`;
}).join('\n') + '\n        </ul>';

const tpl = await readFile(TEMPLATE, 'utf8');
// El mapa que usa el selector de idioma: [archivo, cuantas slides tiene]. El
// nombre del archivo es el MISMO en los dos arboles -- es lo que chequea
// tools/lint-i18n.mjs --, asi que alcanza como coordenada compartida.
const seccionesJs = '[' + items.map((it, i) =>
  `["${chapters[i].f.replace(/\.md$/, '')}",${(items[i + 1]?.h ?? pos) - it.h}]`).join(',') + ']';

for (const marca of ['<!--SLIDES-->', '<!--INDICE-->', '<!--SECCIONES-->']) {
  if (!tpl.includes(marca)) throw new Error(`tools/template.html no tiene el marcador ${marca}`);
}
// Los textos de la interfaz salen de tools/i18n.mjs, no de un segundo template:
// un {{ui:clave}} que no exista es un error, no un hueco silencioso.
const conUI = tpl.replace(/\{\{ui:([a-zA-Z]+)\}\}/g, (_, k) => {
  if (!(k in T)) throw new Error(`tools/template.html pide {{ui:${k}}} y no esta en i18n.mjs`);
  return T[k];
}).replace(/\{\{base\}\}/g, OUT.base);
let html = conUI.replace('<!--SLIDES-->', sections).replace('<!--INDICE-->', indice)
  .replace('<!--SECCIONES-->', seccionesJs);
// El deck en ingles vive en en/, y css/, js/, res/ y vendor/ NO se duplican:
// quedan en la raiz y las rutas necesitan un ../ adelante.
// ponytail: un regex sobre el HTML ya armado en vez de reescribir cada ruta en
// su origen (el template, y las slides que referencian res/). Si algun dia un
// bloque de codigo del curso contiene literalmente src="res/, sale mal.
// Y no alcanza a data-machete, que es una lista separada por comas: ese lo
// prefija el paint() del template con el {{base}} de arriba.
if (OUT.base) html = html.replace(/(src|href)="(css|js|res|vendor)\//g, `$1="${OUT.base}$2/`);
// Pandoc no entiende el "Note:" de reveal: sin esto las notas del presentador
// saldrian como texto en el cuerpo de la slide del .pptx. El fenced div
// ::: notes es lo que pandoc manda a las notas del orador.
// Sin la flag /m a proposito: con ella el $ del lookahead corta en el primer
// fin de linea y la nota queda partida al medio.
const notas = md => md.replace(/\nNote:\n([\s\S]*?)(?=\n---\n|$)/g,
  (_, body) => `\n::: notes\n${body.trimEnd()}\n:::\n`);
const md = chapters.map(c => notas(c.md)).join('\n\n---\n\n') + '\n';

// --- docs/banco-de-examen.md: las mismas preguntas, sin la respuesta ---------
// Un profesor no puede tomar examen con el deck: ahi la correcta ya esta
// marcada. El banco sale de las MISMAS slides -- el [x] que el deck pinta de
// verde es el que aca se guarda aparte, en la clave del final. Una pregunta
// nueva en slides/ entra sola, y no hay un segundo archivo que se desincronice.
const LETRA = 'abcdefgh';
const preguntas = [];
for (const c of chapters.filter(c => /quiz/.test(c.f))) {
  const dia = +(c.f.match(/day(\d+)/)?.[1] ?? 0);
  for (const slide of c.md.split(/^---$/m)) {
    const opciones = [...slide.matchAll(/^- \[([ x])\] (.+?)\s*$/gm)];
    if (!opciones.length) continue;
    const correcta = opciones.findIndex(o => o[1] === 'x');
    if (opciones.filter(o => o[1] === 'x').length !== 1)
      fail(c.f, `una slide de repaso tiene ${opciones.filter(o => o[1] === 'x').length} opciones marcadas con [x], y tiene que haber exactamente una`);
    preguntas.push({
      dia, correcta,
      // "1 de 8" en castellano, "1 of 8" en la traduccion: el banco en ingles
      // salia con el tema vacio en la clave, que es la columna con la que un
      // docente corrige sin volver a la slide.
      tema: slide.match(/^#{2,4} \*\d+ (?:de|of) \d+ · (.+?)\*\s*$/m)?.[1] ?? '',
      enunciado: slide.match(/^\*\*(.+)\*\*\s*$/m)?.[1] ?? '',
      opciones: opciones.map(o => o[2]),
      // El "> **gist** — por que" del deck: es la justificacion que el docente
      // necesita para corregir sin volver a la slide.
      gist: slide.match(/^> (.+?)\s*$/m)?.[1] ?? '',
    });
  }
}
if (errors.length) {
  console.error(`\nbuild abortado — ${errors.length} error(es):`);
  errors.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}

// --- docs/trampas-mudas.md: el apendice, fuera del deck -----------------------
// Las filas se copian tal cual de las tablas de slides/172-apendice-trampas.md,
// con el subtitulo de cada slide como encabezado de grupo. Una trampa nueva en
// la slide entra sola.
const apendice = chapters.find(c => /apendice-trampas/.test(c.f));
if (!apendice) fail('slides/', 'falta 172-apendice-trampas.md, de donde sale docs/trampas-mudas.md');
const grupos = [];
// El encabezado de la tabla no es una fila: se saltea por su primera celda,
// que sale de T.trampasCols para que el ingles saltee la suya y no la nuestra.
const CABECERA = T.trampasCols.split('|')[1].trim();
const RE_FILA = new RegExp(String.raw`^\| (?!---|${CABECERA})(.+?) \|\s*$`, 'gm');
for (const slide of (apendice?.md ?? '').split(/^---$/m)) {
  const titulo = slide.match(/^#### \*(.+?)\*\s*$/m)?.[1];
  const filas = [...slide.matchAll(RE_FILA)].map(m => m[1]);
  if (titulo && filas.length) grupos.push({ titulo, filas });
}
const nTrampas = grupos.reduce((n, g) => n + g.filas.length, 0);

const trampas = `<!-- Generado por tools/build.mjs desde slides/172-apendice-trampas.md.
     NO editar a mano: la fila se corrige en la slide y esto se regenera con
     \`npm run build\`. \`npm run check\` falla si quedo viejo. -->

# ${T.trampasTitulo(nTrampas)}

${T.trampasIntro}

${grupos.map(g => `## ${g.titulo}\n\n${T.trampasCols}\n| --- | --- | --- | :-- |\n${g.filas.map(f => `| ${f} |`).join('\n')}\n`).join('\n')}
---

${T.trampasPerillas}

---

${T.trampasCierre}
`;

const banco = `<!-- Generado por tools/build.mjs desde slides/*quiz*.md. NO editar a mano:
     la pregunta se corrige en la slide y esto se regenera con \`npm run build\`.
     \`npm run check\` falla si quedo viejo. -->

# ${T.bancoTitulo}

${T.bancoIntro(preguntas.length, DOCENTES)}
${[1, 2, 3, 4, 5, 6, 7].map(d => {
  const delDia = preguntas.filter(p => p.dia === d);
  if (!delDia.length) return '';
  return `\n---\n\n${T.bancoDia(d, delDia.length)}\n\n` + delDia.map(p => {
    const n = preguntas.indexOf(p) + 1;
    return `**${n}. ${p.tema}**\n\n${p.enunciado}\n\n`
      + p.opciones.map((o, i) => `- **${LETRA[i]})** ${o}`).join('\n') + '\n';
  }).join('\n');
}).join('')}
---

## ${T.bancoClave}

${T.bancoCols}
|--:|:--:|:--|:--:|:--|
${preguntas.map((p, i) => {
  // Un `|=>` de SVA adentro de una celda parte la tabla en dos columnas mudas.
  const celda = t => t.replace(/\|/g, '\\|');
  return `| ${i + 1} | ${p.dia} | ${celda(p.tema)} | **${LETRA[p.correcta]}** | ${celda(p.gist)} |`;
}).join('\n')}
`;

if (CHECK) {
  const actual = await readFile(OUT_HTML, 'utf8').catch(() => null);
  if (actual !== html) {
    console.error(`✗ ${OUT_HTML} esta desactualizado respecto de ${SLIDES_DIR}/ — corre: npm run build`);
    process.exit(1);
  }
  if (preguntas.length && await readFile(OUT_BANCO, 'utf8').catch(() => null) !== banco) {
    console.error(`✗ ${OUT_BANCO} esta desactualizado respecto de ${SLIDES_DIR}/ — corre: npm run build`);
    process.exit(1);
  }
  if (nTrampas && await readFile(OUT_TRAMPAS, 'utf8').catch(() => null) !== trampas) {
    console.error(`✗ ${OUT_TRAMPAS} esta desactualizado respecto de ${SLIDES_DIR}/ — corre: npm run build`);
    process.exit(1);
  }
  console.log(`✓ ${OUT_HTML} al dia (${chapters.length} secciones)`);
  if (preguntas.length) console.log(`✓ ${OUT_BANCO} al dia (${preguntas.length} preguntas)`);
  if (nTrampas) console.log(`✓ ${OUT_TRAMPAS} al dia (${nTrampas} trampas)`);
  process.exit(0);
}

// Los generados del ingles cuelgan de en/ y docs/en/, que pueden no existir.
for (const f of [OUT_BANCO, OUT_TRAMPAS, OUT_HTML, OUT_MD]) {
  await mkdir(path.dirname(f), { recursive: true });
}
// Un banco de examen sin preguntas o una tabla de trampas vacia no son un
// archivo mas corto: son un archivo que miente. No se escriben.
if (preguntas.length) await writeFile(OUT_BANCO, banco);
if (nTrampas) await writeFile(OUT_TRAMPAS, trampas);
await writeFile(OUT_HTML, html);
await writeFile(OUT_MD, md);

const slides = chapters.reduce((n, c) => n + 1 + (c.md.match(/^---$/gm) || []).length, 0);
const blocks = chapters.reduce((n, c) => n + (c.md.match(/^```/gm) || []).length / 2, 0);
console.log(`${OUT_HTML}  ${chapters.length} secciones, ${slides} slides, ${blocks} bloques de codigo`);
console.log(`            ${stats.includes} vienen de code/ (${stats.recortados} recortados con lines=)`);
console.log(`${OUT_MD}  para pandoc`);
if (preguntas.length) console.log(`${OUT_BANCO}  ${preguntas.length} preguntas de repaso, sin la respuesta marcada`);
if (nTrampas) console.log(`${OUT_TRAMPAS}  ${nTrampas} trampas mudas, fuera del deck`);
