// slides/*.md (+ code/) -> libro/dia1.html ... dia7.html
//
// El deck no se lee de corrido, y el que estudia solo lee. El libro es el mismo
// contenido con dos cambios que lo hacen legible sin instructor al lado:
//
//   1. la NOTA del presentador va inline, como prosa. Ahi vive la mitad del
//      curso -- la trampa, el porque del numero, lo que se copia mal -- y en el
//      deck esta escondida detras de la tecla S.
//   2. el codigo va COMPLETO: la slide muestra el recorte, y abajo hay un
//      <details> con el archivo entero.
//
// Sale estatico: HTML ya resaltado, sin fetch ni render en runtime. Lo unico
// que necesita JS son los quizzes y el enlace al deck.
//
//   node tools/libro.mjs           genera los seis
//   node tools/libro.mjs --check   no escribe: falla si quedaron viejos
import { readFile, writeFile, mkdir, readdir } from 'node:fs/promises';
import path from 'node:path';
import vm from 'node:vm';
import hljs from './hljs-slim.mjs';

const SLIDES_DIR = 'slides';
const OUT_DIR = 'libro';
const CHECK = process.argv.includes('--check');

// La misma tabla que build.mjs: extension -> lenguaje de hljs.
const LANG = {
  '.sv': 'sv', '.svh': 'sv', '.vhd': 'vhdl', '.vhdl': 'vhdl',
  '.do': 'tcl', '.py': 'python',
  '.f': 'plaintext', '.txt': 'plaintext', '.questa': 'plaintext', '.log': 'plaintext',
};
const RE_CODE = /^[ \t]*\{\{code:([^}|]+?)(?:\|lines=(\d+)-(\d+))?\}\}[ \t]*$/gm;

// marked sale del bundle de reveal que ya esta vendorizado. Es EXACTAMENTE el
// mismo renderer que usa el deck, asi que el libro no puede divergir del deck en
// como interpreta el markdown -- y no agrega una dependencia al package.json.
// El bundle es UMD y espera un CommonJS: se le arma uno de mentira.
async function cargarMarked() {
  const src = await readFile('vendor/reveal/plugin/markdown/markdown.js', 'utf8');
  const mod = { exports: {} };
  vm.runInContext(src, vm.createContext({ module: mod, exports: mod.exports, self: {} }));
  const { marked } = mod.exports();
  if (!marked) throw new Error('vendor/reveal/plugin/markdown/markdown.js no expone marked');
  return marked;
}
const marked = await cargarMarked();

// Que figuras tienen version clara en res/print/. Se listan una vez.
async function figurasClaras(dir = 'res/print', base = 'res/print') {
  const out = new Set();
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) for (const x of await figurasClaras(p, base)) out.add(x);
    else if (e.name.endsWith('.svg')) out.add('res/' + path.relative(base, p));
  }
  return out;
}
const clara = await figurasClaras();

const esc = t => t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const pintar = (texto, lang) =>
  hljs.getLanguage(lang) ? hljs.highlight(texto, { language: lang }).value : esc(texto);

// --- 1. Leer las slides ------------------------------------------------------
// Mismo troceo que el deck: un archivo por seccion, "---" entre slides. El
// indice global de slide es el que usa el enlace "ver en el deck", asi que se
// cuenta igual que en build.mjs.
const files = (await readdir(SLIDES_DIR)).filter(f => f.endsWith('.md')).sort();
const slides = [];
let pos = 0;
for (const f of files) {
  const raw = await readFile(path.join(SLIDES_DIR, f), 'utf8');
  for (const md of raw.split(/^---$/m)) {
    slides.push({ f, md: md.trim(), h: pos++ });
  }
}

// --- 2. Repartir en dias -----------------------------------------------------
// El deck marca el arranque de cada dia con id="dayN". Lo que viene antes del
// dia 1 (portada, "como usar", tendencias) abre el dia 1, y lo que viene despues
// del ultimo id="dayN" cierra ese dia.
//
// Son OCHO: siete de curso y un octavo OPCIONAL. El octavo va despues del
// cierre a proposito -- RAL, el golden model por DPI y el segundo capstone
// necesitan los tres que el capstone del dia 7 ya este hecho, asi que el curso
// termina en el 7 y esto se agrega. Los apendices, el glosario y el cierre
// quedan en el dia 7, que es donde se dictan.
const DIAS = 8;
const dias = Array.from({ length: DIAS }, () => []);
let dia = 0;
for (const s of slides) {
  const m = s.md.match(/id="day(\d)"/);
  if (m) dia = +m[1] - 1;
  dias[dia].push(s);
}

// --- 3. Render de una slide --------------------------------------------------
const RE_SLIDE_ATTR = /<!--\s*\.slide:([^>]*?)-->/g;
const RE_ELEM_ATTR = /^[ \t]*<!--\s*\.element:[^>]*?-->[ \t]*$\n?/gm;

async function bloqueDeCodigo(rel, from, to) {
  const texto = await readFile(rel, 'utf8');
  const lineas = texto.replace(/\s+$/, '').split('\n');
  const lang = LANG[path.extname(rel).toLowerCase()] ?? 'plaintext';
  const recorte = from ? lineas.slice(+from - 1, +to) : lineas;

  const pre = ls => `<pre><code class="hljs">${pintar(ls.join('\n'), lang)}</code></pre>`;
  // El <details> solo tiene sentido cuando hubo recorte: si la slide ya mostraba
  // el archivo entero, repetirlo abajo es ruido.
  const completo = from
    ? `<details><summary>el archivo entero, ${lineas.length} líneas</summary>${pre(lineas)}</details>`
    : '';
  const donde = from ? ` · líneas ${from}-${to} de ${lineas.length}` : '';
  return `<figure class="codigo"><figcaption><code>${esc(rel)}</code>${donde}</figcaption>`
       + pre(recorte) + completo + '</figure>';
}

async function renderSlide(s) {
  let md = s.md;

  // Los atributos de reveal no son contenido: el id sirve para el ancla, el
  // resto (transiciones, machete, clases de layout) es del deck.
  const clases = new Set();
  md = md.replace(RE_SLIDE_ATTR, (_, attrs) => {
    const c = attrs.match(/class="([^"]*)"/);
    if (c) for (const k of c[1].split(/\s+/)) clases.add(k);
    return '';
  }).replace(RE_ELEM_ATTR, '');

  // La nota del presentador: en el deck se esconde detras de la tecla S; aca es
  // la mitad del texto.
  let nota = '';
  const iNota = md.search(/^Note:$/m);
  if (iNota >= 0) {
    nota = md.slice(iNota).replace(/^Note:\n?/, '').trim();
    md = md.slice(0, iNota).trim();
  }

  // El codigo se saca del markdown antes de renderizar y se repone despues:
  // marked deja pasar el HTML crudo, asi que el placeholder sobrevive intacto.
  const bloques = [];
  const jobs = [...md.matchAll(RE_CODE)];
  for (const [, rel, from, to] of jobs) {
    bloques.push(await bloqueDeCodigo(rel.trim(), from, to));
  }
  let i = 0;
  md = md.replace(RE_CODE, () => `<!--CODIGO:${i++}-->`);

  let html = marked.parse(md);
  html = html.replace(/<!--CODIGO:(\d+)-->/g, (_, n) => bloques[+n]);
  // Dos correcciones a las rutas de las imagenes:
  //   1. las slides las escriben desde la raiz del repo, y el libro esta un
  //      nivel mas abajo;
  //   2. el libro va en tema CLARO, y las figuras del deck son texto claro
  //      sobre #111: sobre papel blanco no se ven. La version clara ya existe
  //      -- la genera tools/figs-print.mjs para el PDF, por la misma razon --
  //      asi que se usa esa cuando esta.
  html = html.replace(/(<img[^>]+src=")(res\/[^"]+)/g,
    (_, pre, rel) => pre + '../' + (clara.has(rel) ? rel.replace('res/', 'res/print/') : rel));

  // Los quizzes conservan la lista de tareas: el JS de abajo la convierte en
  // opciones clickeables, con el mismo markup y las mismas clases del deck.
  if (/quiz/.test(s.f)) clases.add('quiz');

  // id por seccion: en un dia de decenas de secciones, poder enlazar una sola
  // es la diferencia entre "leelo" y "leete esto".
  return `<section id="s${s.h}" class="slide${clases.size ? ' ' + [...clases].join(' ') : ''}">
${html}${nota ? `<div class="nota">\n${marked.parse(nota)}</div>\n` : ''}<p class="al-deck"><a href="../index.html#/${s.h}">ver esta slide en el deck &rsaquo;</a></p>
</section>`;
}

// --- 4. La pagina ------------------------------------------------------------
// Las rutas del HTML son las del REPO: ../css/, ../res/, ../index.html (el deck)
// y ../web/index.html (la landing). Asi el libro anda abierto con doble clic y
// con un http.server local. Al publicar, el paso "Preparar sitio" de
// .github/workflows/build.yml reescribe las dos ultimas -- el deck alla se llama
// curso.html y la landing es la raiz. css/ y res/ quedan en ../ en los dos.
// Un titulo por dia. El dia 1 lleva dos unidades cortas; del 2 al 7 hay una
// unidad por dia, y el titulo del dia es el de la unidad.
const TITULOS = [
  'Por qué se verifica, y el testbench sin UVM',
  'La OOP que UVM da por sabida',
  'Entra UVM',
  'Cómo hablan los componentes',
  'El dato',
  'El testbench reutilizable',
  'La otra mitad, y el cierre',
];

const NAV = n => Array.from({ length: DIAS }, (_, i) =>
  i === n ? `<b>Día ${i + 1}</b>` : `<a href="dia${i + 1}.html">Día ${i + 1}</a>`).join('\n      ');

// El mismo conversor de quizzes que tools/template.html, sin la tecla V (aca no
// hay clicker ni proyector: se lee con el mouse o con el teclado sobre la opcion).
const JS_QUIZ = `
    const LETRAS = 'abcdefgh';
    document.querySelectorAll('section.quiz').forEach(sec => {
      const lista = sec.querySelector('ul');
      if (!lista) return;
      lista.classList.add('opciones');
      sec.querySelector('blockquote')?.classList.add('respuesta');
      sec.querySelector(':is(h1, h2, h3, h4) ~ p')?.classList.add('pregunta');
      [...lista.children].forEach((li, i) => {
        const box = li.querySelector('input[type=checkbox]');
        li.classList.add('opcion');
        li.classList.toggle('es-correcta', !!box?.checked);
        box?.remove();
        li.tabIndex = 0;
        li.setAttribute('role', 'button');
        const texto = document.createElement('span');
        while (li.firstChild) texto.append(li.firstChild);
        li.append(texto);
        li.insertAdjacentHTML('afterbegin', \`<b class="letra">\${LETRAS[i]}</b>\`);
        const responder = () => {
          if (sec.classList.contains('respondida')) return;
          li.classList.add('elegida');
          sec.classList.add('respondida');
        };
        li.addEventListener('click', responder);
        li.addEventListener('keydown', e => {
          if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); responder(); }
        });
      });
      lista.insertAdjacentHTML('afterend',
        '<p class="ayuda">Elegí una opción para ver la respuesta</p>');
    });`;

function pagina(n, cuerpo) {
  const t = `Día ${n + 1} · ${TITULOS[n]}`;
  return `<!DOCTYPE html>
<html lang="es" class="libro">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${t} — Verify This! · Curso de UVM en español</title>
<meta name="description" content="Día ${n + 1} del curso de UVM en español, para leer de corrido: las slides con las notas del instructor adentro del texto y el código completo.">
<link rel="stylesheet" href="../css/fonts.css">
<link rel="stylesheet" href="../css/course.css">
<link rel="stylesheet" href="../css/code.css">
<link rel="stylesheet" href="../css/libro.css">
</head>
<body class="reveal">
<header class="cabecera">
  <div class="wrap">
    <p class="marca"><a href="../web/index.html">Verify This!</a> · el curso para leer</p>
    <nav class="nav-dias">
      ${NAV(n)}
    </nav>
  </div>
</header>

<main class="wrap">
  <h1 class="titulo-dia"><span>Día ${n + 1}</span>${TITULOS[n]}</h1>
  <p class="bajada">Las mismas slides del deck, con <strong>las notas del
  instructor adentro del texto</strong> y el código completo. Si estás haciendo
  el curso solo, empezá por acá y tené el deck al lado para los repasos.</p>

${cuerpo}
</main>

<footer class="pie">
  <div class="wrap">
    <nav class="nav-dias">
      ${NAV(-1)}
    </nav>
    <p><a href="../web/index.html">Sitio del curso</a> ·
       <a href="https://github.com/leandrotozzi/verifythis">Código en GitHub</a> ·
       CC BY 4.0</p>
  </div>
</footer>

<script>${JS_QUIZ}
</script>
</body>
</html>
`;
}

// --- 5. Escribir -------------------------------------------------------------
const paginas = [];
for (const [n, ss] of dias.entries()) {
  const cuerpo = (await Promise.all(ss.map(renderSlide))).join('\n\n');
  paginas.push([path.join(OUT_DIR, `dia${n + 1}.html`), pagina(n, cuerpo)]);
}

if (CHECK) {
  for (const [f, html] of paginas) {
    if (await readFile(f, 'utf8').catch(() => null) !== html) {
      console.error(`✗ ${f} esta desactualizado respecto de ${SLIDES_DIR}/ — corre: npm run libro`);
      process.exit(1);
    }
  }
  console.log(`✓ libro/ al dia (${paginas.length} dias)`);
  process.exit(0);
}

await mkdir(OUT_DIR, { recursive: true });
for (const [f, html] of paginas) await writeFile(f, html);
console.log(`${OUT_DIR}/  ${paginas.length} dias, ${slides.length} secciones`);
for (const [n, ss] of dias.entries()) console.log(`  dia${n + 1}.html  ${ss.length} secciones`);
