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
import { UI, idiomaDeArgv, SALIDAS } from './i18n.mjs';
import { seo } from './sitio.mjs';
import { RE_CODE, recortar } from './codigo.mjs';
import { expandirContadores } from './contadores.mjs';

const IDIOMA = idiomaDeArgv();
const OUT = SALIDAS[IDIOMA];
const T = UI[IDIOMA];
const SLIDES_DIR = OUT.slides;
const OUT_DIR = OUT.libro;
// Las rutas relativas del libro: libro/ esta un nivel bajo la raiz y en/libro/
// esta dos. css/ y res/ no se duplican, asi que el prefijo cambia y nada mas.
const UP = OUT.base ? '../..' : '..';
const CHECK = process.argv.includes('--check');

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
const files = (await readdir(SLIDES_DIR).catch(() => [])).filter(f => f.endsWith('.md')).sort();
if (!files.length) {
  if (IDIOMA === 'es') throw new Error(`no hay .md en ${SLIDES_DIR}/`);
  console.log(`${SLIDES_DIR}/ vacio: no hay libro que generar todavia`);
  process.exit(0);
}
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

async function bloqueDeCodigo(rel, simbolo, from, to) {
  const { lineas, recorte, recortado, donde, lang } = await recortar(rel, simbolo, from, to);

  const pre = ls => `<pre><code class="hljs">${pintar(ls.join('\n'), lang)}</code></pre>`;
  // El <details> solo tiene sentido cuando hubo recorte: si la slide ya mostraba
  // el archivo entero, repetirlo abajo es ruido.
  const completo = recortado
    ? `<details><summary>el archivo entero, ${lineas.length} líneas</summary>${pre(lineas)}</details>`
    : '';
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

  // Antes de partir la nota: los contadores viven sobre todo en las notas del
  // presentador, que a partir de la linea de abajo dejan de estar en `md`.
  md = await expandirContadores(md);

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
  for (const [, , rel, simbolo, from, to] of jobs) {
    bloques.push(await bloqueDeCodigo(rel.trim(), simbolo, from, to));
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
    (_, pre, rel) => `${pre}${UP}/` + (clara.has(rel) ? rel.replace('res/', 'res/print/') : rel));

  // Lo mismo que arriba pero para los enlaces AL PROPIO LIBRO. Las slides los
  // escriben desde la raiz del repo -- `libro/dia1.html`, que es lo correcto
  // desde el deck --, y aca esa slide ya esta ADENTRO de libro/: quedaba
  // `libro/libro/dia1.html`. Eran los 30 enlaces de la autoevaluacion, o sea
  // la ultima pantalla del curso, en los dos idiomas.
  html = html.replace(/(<a[^>]+href=")libro\//g, '$1');

  // Los quizzes conservan la lista de tareas: el JS de abajo la convierte en
  // opciones clickeables, con el mismo markup y las mismas clases del deck.
  if (/quiz/.test(s.f)) clases.add('quiz');

  // id por seccion: en un dia de decenas de secciones, poder enlazar una sola
  // es la diferencia entre "leelo" y "leete esto".
  return `<section id="s${s.h}" class="slide${clases.size ? ' ' + [...clases].join(' ') : ''}">
${html}${nota ? `<div class="nota">\n${marked.parse(nota)}</div>\n` : ''}<p class="al-deck"><a href="../index.html#/${s.h}">${T.libroAlDeck}</a></p>
</section>`;
}

// --- 4. La pagina ------------------------------------------------------------
// Las rutas del HTML son las del REPO, con $UP adelante: ../ para libro/ y
// ../../ para en/libro/. css/, res/ y el deck no se duplican. Asi el libro anda
// abierto con doble clic y con un http.server local. Al publicar, el paso
// "Preparar sitio" de .github/workflows/build.yml reescribe el deck y la landing
// -- alla el deck se llama curso.html y la landing es la raiz.
// Los titulos de dia salen de tools/i18n.mjs, que es el unico lugar que los sabe.
const TITULOS = T.titulos;

// Solo los dias que existen: en el arbol en ingles todavia hay huecos, y un
// enlace a un dia que no se genero es un 404.
const HAY = dias.map(ss => ss.length > 0);

// Los dias que existen en el OTRO idioma. El hreflang reciproco tiene que
// apuntar a una pagina que exista: un alternate a un 404 le dice al buscador que
// la traduccion esta cuando no esta. Se lee de slides/, que es la fuente y esta
// commiteada, y NO del arbol generado: si dependiera de que day3.html ya se
// escribio, la salida cambiaria segun el orden en que corrio el build y
// --check quedaria rojo una corrida si y otra no.
const OTRO = IDIOMA === 'es' ? 'en' : 'es';
const dirOtro = SALIDAS[OTRO].slides;
const mdOtro = (await Promise.all((await readdir(dirOtro).catch(() => []))
  .filter(f => f.endsWith('.md'))
  .map(f => readFile(path.join(dirOtro, f), 'utf8')))).join('\n');
// id="dayN" presente <=> ese dia tiene al menos la slide que lo abre, que es
// exactamente la condicion de HAY.
const HAY_OTRO = new Set([...mdOtro.matchAll(/id="day(\d)"/g)].map(m => +m[1]));

// La misma pagina, en el sitio publicado, en cada idioma. libro/ y en/libro/ se
// copian tal cual (tools/sitio.mjs), asi que la ruta del sitio es la del repo.
const RUTAS = { es: UI.es.archivoDia, en: UI.en.archivoDia };
const ruta = (l, n) => `${l === 'en' ? 'en/' : ''}libro/${RUTAS[l](n)}`;
const NAV = n => Array.from({ length: DIAS }, (_, i) => !HAY[i] ? ''
  : i === n ? `<b>${T.dia(i + 1)}</b>` : `<a href="${T.archivoDia(i + 1)}">${T.dia(i + 1)}</a>`)
  .filter(Boolean).join('\n      ');

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
        '<p class="ayuda">${T.quizAyuda}</p>');
    });`;

// El <title> ya era propio de cada dia (T.libroTitulo mete el titulo del dia);
// la description NO: era la misma frase en las ocho paginas, y ocho paginas con
// la misma description compiten entre si en el mismo indice. El tema del dia sale
// de T.titulos (tools/i18n.mjs), que es el unico lugar que lo sabe.
const DESC = n => `${TITULOS[n]} — ${T.libroDescripcion(n + 1)}`;

// n es el indice (0..7); HAY/HAY_OTRO estan en la misma base.
const HAY_ES = n => IDIOMA === 'es' ? HAY[n] : HAY_OTRO.has(n + 1);
const HAY_EN = n => IDIOMA === 'en' ? HAY[n] : HAY_OTRO.has(n + 1);

function pagina(n, cuerpo) {
  return `<!DOCTYPE html>
<html lang="${T.html}" class="libro">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${T.libroTitulo(n + 1)}</title>
<meta name="description" content="${DESC(n)}">
${seo({
  es: HAY_ES(n) ? ruta('es', n + 1) : null,
  en: HAY_EN(n) ? ruta('en', n + 1) : null,
  lang: IDIOMA, css: `${UP}/css/`, tipo: 'article',
  titulo: T.libroTitulo(n + 1), desc: DESC(n),
})}
<link rel="stylesheet" href="${UP}/css/fonts.css">
<link rel="stylesheet" href="${UP}/css/course.css">
<link rel="stylesheet" href="${UP}/css/code.css">
<link rel="stylesheet" href="${UP}/css/libro.css">
</head>
<body class="reveal">
<header class="cabecera">
  <div class="wrap">
    <p class="marca"><a href="${UP}/web/index.html">Verify This!</a> ${T.libroMarca}</p>
    <nav class="nav-dias">
      ${NAV(n)}
    </nav>
  </div>
</header>

<main class="wrap">
  <h1 class="titulo-dia"><span>${T.dia(n + 1)}</span>${TITULOS[n]}</h1>
  <p class="bajada">${T.libroBajada}</p>

${cuerpo}
</main>

<footer class="pie">
  <div class="wrap">
    <nav class="nav-dias">
      ${NAV(-1)}
    </nav>
    <p><a href="${UP}/web/index.html">${T.libroSitio}</a> ·
       <a href="https://github.com/leandrotozzi/verifythis">${T.libroGithub}</a> ·
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
// Un dia sin secciones no se escribe: mientras el arbol en ingles se llena de a
// un dia por vez, un dia7.html vacio es peor que no tenerlo.
for (const [n, ss] of dias.entries()) {
  if (!ss.length) continue;
  const cuerpo = (await Promise.all(ss.map(renderSlide))).join('\n\n');
  paginas.push([path.join(OUT_DIR, T.archivoDia(n + 1)), pagina(n, cuerpo)]);
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
for (const [n, ss] of dias.entries())
  if (ss.length) console.log(`  ${T.archivoDia(n + 1)}  ${ss.length} secciones`);
