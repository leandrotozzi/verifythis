// Lint de lo que se PUBLICA: los links, las anclas y las imagenes del sitio.
//
// tools/lint-refs.mjs ya revisa los links relativos de los .md. Eso deja afuera
// justo lo que ve el alumno: el HTML. Y el HTML tiene un problema que el .md no
// tiene -- el sitio publicado NO tiene el layout del repo. El deck se llama
// curso.html, la landing es la raiz, y el libro se reescribe al copiarse
// (tools/sitio.mjs). Un link puede estar bien en el repo y roto en el sitio, y
// al reves. Por eso este lint no mira el repo: arma el mapa del SITIO con el
// manifiesto de sitio.mjs y chequea ahi.
//
// El bug que lo motivo: slides/es/175b-autoevaluacion.md escribe la tabla de
// autoevaluacion con links "libro/dia1.html#tendencias". Desde el deck, que
// vive en la raiz, eso resuelve perfecto. Pero la MISMA slide termina adentro
// de libro/dia7.html, y desde ahi "libro/dia1.html" es "libro/libro/dia1.html".
// Son 15 links muertos en el libro en castellano y otros 15 en el ingles, en la
// pagina de cierre del curso, y ningun lint los veia.
//
//   1. ERROR  link o src relativo a un archivo que el sitio no tiene
//   2. ERROR  ancla "#loquesea" a un id que no existe en la pagina de destino
//   3. ERROR  un <img> sin alt, o una pagina sin <title>. Es el minimo de
//             accesibilidad que se puede chequear sin meter axe ni pa11y (y sin
//             pagar los dos minutos que tardan): una figura sin alt es una
//             figura que el lector de pantalla saltea, y en un curso donde el
//             diagrama ES la explicacion eso es la slide entera perdida.
//   4. AVISO  archivo de res/ que no referencia ninguna pagina (peso muerto),
//             medido contra el DOM RENDERIZADO y no contra el HTML fuente
//   5. AVISO  pagina del sitio que no esta en el sitemap.xml
//   6. --red  links http/https muertos. NO corre en cada push: depende de que
//             el server del otro este vivo, y un CI que falla por eso enseña a
//             ignorar el CI. Va en la corrida nocturna.
//   7. ERROR  figura de res/ con un <text> que se sale del viewBox
//   8. ERROR  SVG de res/ sin <title>, y figura del machete sin alt
//   9. AVISO  el alt de una figura no dice lo que dice su <title>
//  10. ERROR  flecha TLM dibujada del circulo al cuadrado
//
// Las cuatro reglas nuevas (7 a 10) salen de la revision por clase de error de
// las 50 figuras (revision/clases/a-imagenes.md), y cada una tiene su bug:
//
//   7. tres figuras tienen el pie CORTADO en los dos idiomas y nadie lo vio:
//      res/diagrams/agents_agent.svg pierde 168 px ("El scoreboard y el
//      coverage viven en el..."), su gemela inglesa 221, y
//      jerarquias_convert2string.svg se queda en "...mientras nadie toque la".
//      Un SVG adentro de un <img> recorta lo que sale del viewBox sin avisar, y
//      ningun linter del repo media texto: tools/overflow.mjs mira slides.
//   8. las figuras del machete, quince, se inyectan con alt="" (tools/template.html
//      :280), que en HTML significa "decorativa, ignorala" -- y
//      res/diagrams/assertions_property.svg SOLO aparece ahi, asi que la
//      anatomia de una property no tiene texto alternativo en ningun lado del
//      sitio. Y res/TB.svg, res/TB_UVM.svg y res/originUVM.svg (mas sus tres
//      gemelas de res/en/) no tienen <title>, que es el nombre accesible de la
//      figura y lo unico que queda cuando se abre suelta: el machete las
//      muestra sin contexto y en el PDF no sobrevive el alt del <img>.
//   9. la descripcion de cada figura esta escrita TRES veces -- el <title> del
//      SVG, el alt de la slide y el subtitulo #### -- y se pudrio: diez alt
//      perdieron las tildes y cinco no describen nada ("Diagrama UML de los
//      tragos" contra el <title> "trago, fernet y mojito: que servir() vive en
//      que clase"). Es aviso y no error porque hoy son dos textos distintos a
//      proposito; se apaga sola el dia que tools/build.mjs genere el alt desde
//      el <title>, que es la fuente unica que falta.
//  10. la slide del dia 4 enuncia la regla que hace legible cualquier diagrama
//      TLM -- "la punta cuadrada siempre apunta al circulo" -- y las dos
//      figuras de esa misma seccion la rompen: en threads_fig124.svg:46 y en
//      put-get_fig125.svg:41 la flecha get() sale del circulo (el export) y
//      entra al cuadrado (el port). Las figuras del dia 6 dibujan el mismo par
//      put/get al reves, que es lo que dice la regla.
//
// LO QUE NO ESTA, y por que. a-imagenes.md propone una quinta regla: texto
// tachado por el trazo de una caja (el borde inferior de result_monitor_h cruza
// por la mitad los nombres de los dos agents en agents_active_passive.svg).
// Medida sobre las figuras de los dos arboles da 21 hits y solo 4 son el bug: las otras 17 son
// etiquetas apoyadas a proposito sobre el borde de su caja, que es un idioma de
// diagrama, no un defecto. 81 % de ruido enseña a ignorar el CI, asi que afuera.
//
// Uso: node tools/lint-web.mjs [--red] [--avisos-fallan]
import { spawn } from 'node:child_process';
import { readFile, readdir, writeFile, unlink } from 'node:fs/promises';
import path from 'node:path';
import { MANIFIESTO, inventarioDelSitio, reescribir } from './sitio.mjs';
import { chrome, BASE } from './chrome.mjs';
import { IDIOMAS, SALIDAS } from './i18n.mjs';

const RED = process.argv.includes('--red');
const AVISOS_FALLAN = process.argv.includes('--avisos-fallan');

// Deuda conocida: bugs REALES, en archivos que no son de este lint. Se listan
// aca para que `npm run check` no quede rojo para todo el mundo mientras el
// dueño los arregla -- y la lista se limpia sola: si una entrada deja de
// dispararse, este lint FALLA pidiendo que la saques. Un TODO que no se puede
// olvidar es la unica clase de TODO que sirve.
const DEUDA = [];

const errores = [], avisos = [];
const externos = new Map();   // url -> primer "archivo:linea" que la escribe
const deudaVista = new Set();

// El sitio, como mapa destino -> archivo del repo que lo origina. Los mensajes
// citan el ORIGEN, que es el archivo que se edita; decir "_site/libro/dia7.html"
// no le sirve a nadie.
const sitio = new Map(await inventarioDelSitio());
// El PDF y el PPTX los arma el CI (`npm run pdf`), no viven en el repo: para el
// mapa del sitio existen igual. Que esten de verdad al publicar lo exige
// `node tools/sitio.mjs --estricto`, que es lo que corre el workflow.
for (const [src, dst, opcional] of MANIFIESTO) if (opcional && !sitio.has(dst)) sitio.set(dst, src);

const cache = new Map();
async function contenido(dst) {
  if (!cache.has(dst)) {
    const crudo = await readFile(sitio.get(dst), 'utf8');
    cache.set(dst, reescribir(dst, crudo).txt);
  }
  return cache.get(dst);
}
const idsCache = new Map();
async function ids(dst) {
  if (!idsCache.has(dst)) {
    const t = await contenido(dst);
    idsCache.set(dst, new Set([...t.matchAll(/\b(?:id|name)="([^"]+)"/g)].map(m => m[1])));
  }
  return idsCache.get(dst);
}

// El JS del deck arma rutas con template literals (`../${src.trim()}`) y el CSS
// tiene url(...) de fuentes que ya viven en su propio directorio: ninguno de los
// dos es un link de la pagina.
const sinScripts = t => t.replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, m => '\n'.repeat((m.match(/\n/g) ?? []).length))
                         .replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, m => '\n'.repeat((m.match(/\n/g) ?? []).length));

const RE_ATTR = /\b(?:href|src|poster)="([^"]+)"/g;
const paginas = [...sitio.keys()].filter(d => d.endsWith('.html') && !d.startsWith('vendor/'));

// De donde sale el texto que se corrige. El deck y el libro son GENERADOS: un
// mensaje que diga "libro/dia5.html:212" manda a editar un archivo que el
// proximo `npm run build` pisa. El alt de una figura y el data-machete se
// escriben en slides/<idioma>/*.md, asi que el mensaje los busca ahi. Es un
// find sobre 25.000 lineas en memoria: no se nota al lado de los tres Chrome.
const LINEAS = [];
for (const l of IDIOMAS) {
  const dir = SALIDAS[l].slides;
  for (const f of (await readdir(dir)).filter(x => x.endsWith('.md')))
    (await readFile(path.join(dir, f), 'utf8')).split('\n')
      .forEach((linea, i) => LINEAS.push([`${dir}/${f}:${i + 1}`, linea]));
}
const enSlides = (frag, sino) => LINEAS.find(([, l]) => l.includes(frag))?.[0] ?? sino;

// --- Chrome: lo que solo se ve DESPUES de que corre el JS ---------------------
// Dos de las reglas nuevas necesitan el navegador, y las dos por el mismo
// motivo -- el archivo fuente miente:
//
//   - el DOM renderizado del deck (regla 4). res/ribbon-machete.png esta
//     escrito en tools/template.html:95 y no se ve NUNCA: js/forkit.js:79
//     arranca con dom.ribbon.innerHTML = '<span class="string">...' y le borra
//     el <img> al <a> antes de que se pinte. El PNG viaja al sitio y no lo mira
//     nadie, y este lint lo daba por usado justo porque leia el fuente.
//   - el getBBox() de cada <text> de cada figura (regla 7): el ancho real de un
//     texto no esta escrito en ningun lado, se mide.
//
// Los tres Chrome arrancan juntos y se esperan al final: son ~5 s de reloj y no
// 15. El binario ya es requisito de `npm run pdf` y de tools/overflow.mjs, y no
// hace falta red, asi que la regla entra igual en `npm run check`.

// Las figuras que se miden: los SVG de res/, sin res/print/. Son las MISMAS en
// paleta clara, las genera tools/figs-print.mjs, y se arreglan editando el
// original: medir las 200 seria el doble de tiempo para decir dos veces lo
// mismo, la segunda con el nombre de un archivo generado.
const FIGURAS = [...sitio.keys()]
  .filter(d => d.startsWith('res/') && d.endsWith('.svg') && !d.startsWith('res/print/'));

const SONDA = '_lint-figuras.html';
const PROBE = figs => `<link rel="stylesheet" href="css/fonts.css">
<pre id="rep">PENDING</pre>
<div id="caja" style="position:absolute; visibility:hidden"></div>
<script>
const FIGS = ${JSON.stringify(figs)};
(async () => {
  // Los 100 fetch juntos, y las fuentes cargadas a mano: con font-display:swap
  // Chrome no baja una IBM Plex hasta que algo la usa, y una figura medida con
  // la tipografia del sistema da otro ancho.
  const bajados = await Promise.all(FIGS.map(f => fetch(f).then(r => r.text())));
  await Promise.all([...document.fonts].map(f => f.load().catch(() => {})));
  const caja = document.getElementById('caja'), out = [];
  for (let i = 0; i < FIGS.length; i++) {
    const doc = new DOMParser().parseFromString(bajados[i], 'image/svg+xml');
    caja.replaceChildren(document.importNode(doc.documentElement, true));
    const svg = caja.firstElementChild;
    const vb = (svg.getAttribute('viewBox') || '').split(/[\\s,]+/).map(Number);
    if (vb.length !== 4 || vb.some(Number.isNaN)) continue;
    for (const t of svg.querySelectorAll('text')) {
      const b = t.getBBox();
      const fuera = Math.max(vb[0] - b.x, (b.x + b.width) - (vb[0] + vb[2]),
                             vb[1] - b.y, (b.y + b.height) - (vb[1] + vb[3]));
      // 1 px de tolerancia: el redondeo subpixel de Chrome, no un desborde.
      if (fuera > 1) out.push([FIGS[i], Math.round(fuera * 10) / 10,
                               t.textContent.trim().slice(0, 44), vb.join(' ')]);
    }
  }
  document.getElementById('rep').textContent = 'REPORT:' + JSON.stringify(out);
})();
</script>`;

const dom = url => new Promise((ok, mal) => {
  let out = '', err = '';
  const p = spawn(chrome, [...BASE, '--virtual-time-budget=60000', '--dump-dom', url],
    { stdio: ['ignore', 'pipe', 'pipe'] });
  p.stdout.on('data', d => (out += d));
  p.stderr.on('data', d => (err += d));
  // Sin el stderr, un Chrome que ni arranco se lee como "la pagina no cargo" y
  // manda a buscar el problema al deck.
  p.on('close', () => out.includes('</html>') ? ok(out)
    : mal(new Error(`no pude renderizar ${url}. Chrome dijo:\n${err.trim() || '(nada)'}`)));
});

// Cual es el deck sale del manifiesto y no de una lista escrita aca: si mañana
// el sitio publica un tercero, entra solo.
const decks = paginas.filter(d => /(^|\/)curso\.html$/.test(d));

const enChrome = (async () => {
  await writeFile(SONDA, PROBE(FIGURAS.map(d => sitio.get(d))));
  try {
    const [sonda, ...doms] = await Promise.all([
      dom(`file://${path.resolve(SONDA)}`),
      ...decks.map(d => dom(`file://${path.resolve(sitio.get(d))}`)),
    ]);
    const m = sonda.match(/REPORT:(\[.*?\])<\/pre>/s);
    if (!m) throw new Error('la sonda de figuras no dejo reporte: Chrome tiene que poder'
      + ' leer file:// (tools/chrome.mjs pasa --allow-file-access-from-files)');
    return { desbordes: JSON.parse(m[1]), renderizado: new Map(decks.map((d, i) => [d, doms[i]])) };
  } finally { await unlink(SONDA).catch(() => {}); }
})().catch(e => { console.error('✗ ' + e.message); process.exit(1); });

for (const dst of paginas) {
  const origen = sitio.get(dst);
  const txt = sinScripts(await contenido(dst));
  const linea = i => txt.slice(0, i).split('\n').length;
  const dir = path.posix.dirname(dst);

  for (const m of txt.matchAll(RE_ATTR)) {
    const crudo = m[1].trim();
    const donde = `${origen}:${linea(m.index)}`;
    if (/^(mailto:|data:|javascript:|tel:)/i.test(crudo)) continue;
    if (/^(https?:)?\/\//i.test(crudo)) { if (!externos.has(crudo)) externos.set(crudo, donde); continue; }

    const [ruta, ...resto] = crudo.split('#');
    const hash = resto.join('#');
    // "#/12" es navegacion de reveal (indice de slide), no un id del documento.
    if (hash.startsWith('/')) { if (!ruta) continue; }

    let destino = dst;
    if (ruta) {
      destino = path.posix.normalize(path.posix.join(dir, decodeURIComponent(ruta)));
      // Un link a un directorio ("en/") lo sirve GitHub Pages como su index.html.
      if (ruta.endsWith('/') || (!path.posix.extname(destino) && sitio.has(destino + '/index.html')))
        destino = path.posix.join(destino, 'index.html');
      if (!sitio.has(destino)) {
        const deuda = DEUDA.find(([f, pref]) => f === dst && ruta.startsWith(pref));
        if (deuda) { deudaVista.add(deuda); continue; }
        errores.push(`${donde} — link roto en el sitio: "${crudo}" -> ${destino} no existe.`
          + ` El sitio no es el repo (ver tools/sitio.mjs): la ruta se escribe relativa a ${dir || 'la raiz'}/`);
        continue;
      }
    }
    if (!hash || hash.startsWith('/') || !destino.endsWith('.html')) continue;
    const id = decodeURIComponent(hash);
    if (!(await ids(destino)).has(id)) {
      errores.push(`${donde} — ancla rota: "#${hash}" no es ningun id de ${destino}.`
        + ` Los ids del libro salen del titulo de la slide: si le cambiaste el texto, cambio el id`);
    }
  }
}

// --- 3. el minimo de accesibilidad -------------------------------------------
// res/machete.html es una carilla para imprimir, no una pagina del sitio: no
// tiene <html> ni se navega, se abre y se manda a la impresora.
for (const dst of paginas) {
  if (dst.startsWith('res/')) continue;
  const origen = sitio.get(dst);
  const txt = sinScripts(await contenido(dst));
  for (const m of txt.matchAll(/<img\b[^>]*>/g)) {
    if (/\balt=/.test(m[0])) continue;
    errores.push(`${origen}:${txt.slice(0, m.index).split('\n').length} — <img> sin alt.`
      + ' Un lector de pantalla lo saltea entero: ponele alt="" si es decorativa, o describila');
  }
  if (!/<title>[^<]/.test(txt))
    errores.push(`${origen} — sin <title>: es lo que muestran la pestaña, el buscador y el historial`);
  if (!/<html[^>]*\slang=/.test(txt))
    errores.push(`${origen} — al <html> le falta lang=: el lector de pantalla lo lee con el acento equivocado`);
}

// Los tres Chrome de arriba, que esperan las reglas 4 y 7.
const { desbordes, renderizado } = await enChrome;

// --- deuda que ya no existe --------------------------------------------------
for (const d of DEUDA) {
  if (deudaVista.has(d)) continue;
  errores.push(`tools/lint-web.mjs — la deuda "${d[0]} -> ${d[1]}*" ya no se dispara: ${d[2]}.`
    + ' Se arreglo: borra esa entrada de DEUDA para que el lint la empiece a exigir');
}

// --- 4. huerfanos de res/, contra el DOM RENDERIZADO -------------------------
// res/print/ NO cuenta: son las mismas figuras en paleta clara, las genera
// tools/figs-print.mjs y las elige el JS del deck en tiempo de impresion.
//
// El deck entra por lo que Chrome dejo en el DOM y no por su HTML fuente: un
// archivo nombrado en el fuente cuenta como usado aunque el JS lo tire, que es
// exactamente lo que le pasa a res/ribbon-machete.png con js/forkit.js:79.
const cuerpos = [];
for (const dst of [...sitio.keys()].filter(d => /\.(html|css|svg)$/.test(d) && !d.startsWith('vendor/')))
  cuerpos.push(renderizado.get(dst) ?? await contenido(dst));
const blob = cuerpos.join('\n');
for (const dst of sitio.keys()) {
  if (!dst.startsWith('res/') || dst.startsWith('res/print/')) continue;
  if (blob.includes(path.posix.basename(dst))) continue;
  avisos.push(`${sitio.get(dst)} — no queda referenciado en ninguna pagina del sitio DESPUES de`
    + ' correr el JS: borralo, o fijate quien le pisa el nodo');
}

// --- 5. paginas fuera del sitemap --------------------------------------------
// El sitemap es lo unico que le dice a un buscador que el libro existe: el deck
// no le da una linea de texto que indexar. Una pagina nueva que no entra ahi es
// una pagina que no encuentra nadie.
const sitemap = await contenido('sitemap.xml').catch(() => '');
for (const dst of paginas) {
  if (dst.startsWith('res/')) continue;
  const url = dst.replace(/(^|\/)index\.html$/, '$1');
  if (!sitemap.includes(`/${url}<`) && !sitemap.includes(`/${url}`)) {
    avisos.push(`web/sitemap.xml — falta ${url}: la publica el sitio y ningun buscador la ve`);
  }
}

// --- 7. el texto que se sale del viewBox -------------------------------------
for (const [fig, fuera, txt, vb] of desbordes) {
  errores.push(`${fig} — "${txt}…" se sale ${fuera} px del viewBox="${vb}":`
    + ' un SVG adentro de un <img> recorta lo que sobra y no avisa.'
    + ' Movelo o agranda el viewBox, y despues `node tools/figs-print.mjs` para la copia de res/print/');
}

// --- 8. el <title> del SVG, y el alt del machete -----------------------------
for (const fig of FIGURAS) {
  if (/<title>[^<]/.test(await contenido(fig))) continue;
  errores.push(`${sitio.get(fig)} — SVG sin <title>: es el nombre accesible de la figura, y lo unico`
    + ' que queda cuando se abre suelta (el machete la muestra sin contexto, y en el PDF no'
    + ' sobrevive el alt del <img>). Sacalo del ![alt](...) de la slide que la proyecta');
}
// data-machete es una lista de rutas separadas por comas, y tools/template.html
// las inyecta con alt="" fijo. Que el alt se declare al lado de la ruta
// ("ruta|alt") es lo que hace falta ademas de tocar el template.
for (const dst of decks) {
  const txt = await contenido(dst);
  for (const m of txt.matchAll(/data-machete="([^"]*)"/g)) {
    // Mismo corte que tools/template.html: la coma separa entradas solo cuando
    // abre una ruta. El alt lleva comas y si no, sus pedazos parecen rutas sin alt.
    const sinAlt = m[1].split(/,(?=\s*res\/)/).map(s => s.trim()).filter(f => f && !f.includes('|'));
    if (!sinAlt.length) continue;
    errores.push(`${enSlides(m[0], sitio.get(dst))} — el machete inyecta ${sinAlt.join(', ')} con`
      + ' alt="" (tools/template.html:280), que en HTML significa "decorativa, ignorala".'
      + ' Declaralo en el data-machete con la sintaxis ruta|alt');
  }
}

// --- 9. el alt contra el <title> de la figura --------------------------------
// Las entidades vuelven a texto de una pasada (&amp; sin re-escanear) para
// comparar con el <title>, que en el SVG esta escrito crudo.
const ENTIDAD = { quot: '"', apos: "'", '#39': "'", lt: '<', gt: '>', amp: '&' };
const texto = s => s.replace(/&(quot|apos|#39|lt|gt|amp);/g, (_, e) => ENTIDAD[e]);
const corto = s => s.length > 52 ? s.slice(0, 52) + '…' : s;
for (const dst of paginas) {
  const txt = await contenido(dst);
  for (const m of txt.matchAll(/<img\b[^>]*>/g)) {
    const src = m[0].match(/\bsrc="([^"]+)"/)?.[1];
    if (!src?.endsWith('.svg')) continue;
    const destino = path.posix.normalize(path.posix.join(path.posix.dirname(dst), src));
    if (!sitio.has(destino)) continue;                    // ya lo dijo la regla 1
    const titulo = (await contenido(destino)).match(/<title>([^<]*)<\/title>/)?.[1].trim() ?? '';
    if (!titulo) continue;                                // ya lo dijo la regla 8
    const alt = texto(m[0].match(/\balt="([^"]*)"/)?.[1] ?? '');
    if (alt === titulo) continue;
    avisos.push(`${enSlides(`![${alt}](`, sitio.get(dst))} — el alt de ${path.posix.basename(destino)}`
      + ` no dice lo que su <title>: "${corto(alt)}" contra "${corto(titulo)}"`);
  }
}

// --- 10. la convencion TLM, medida en la geometria ---------------------------
// Un port es un <rect 22x22> y un export un <circle r="9">: las dos primitivas
// no se usan para ninguna otra cosa en estas figuras, asi que alcanza con mirar
// donde empieza y donde termina cada flecha. La punta (marker-end) va SIEMPRE
// al circulo, porque el que tiene el cuadrado es el que llama.
const CERCA = 15;                                     // px del centro de la primitiva
const puntas = d => {                                 // [inicio, fin] de un path M/L/H/V
  let x = 0, y = 0, ini = null;
  for (const t of d.match(/[MLHV][^MLHV]*/g) ?? []) {
    const n = (t.slice(1).match(/-?[\d.]+/g) ?? []).map(Number);
    if (t[0] === 'M' || t[0] === 'L') [x, y] = n;
    else if (t[0] === 'H') x = n[0];
    else y = n[0];
    ini ??= [x, y];
  }
  return ini && [ini, [x, y]];
};
const atributo = (tag, a) => +(tag.match(new RegExp(`\\b${a}="(-?[\\d.]+)"`))?.[1] ?? NaN);
for (const fig of FIGURAS) {
  const t = await contenido(fig);
  const centros = re => [...t.matchAll(re)].map(m => m[0]);
  const exportes = centros(/<circle\b[^>]*\br="9"[^>]*>/g).map(c => [atributo(c, 'cx'), atributo(c, 'cy')]);
  const puertos = centros(/<rect\b[^>]*>/g).filter(r => atributo(r, 'width') === 22 && atributo(r, 'height') === 22)
    .map(r => [atributo(r, 'x') + 11, atributo(r, 'y') + 11]);
  if (!exportes.length || !puertos.length) continue;
  const pegado = (p, lista) => lista.some(q => Math.hypot(p[0] - q[0], p[1] - q[1]) <= CERCA);
  for (const m of t.matchAll(/<path\b[^>]*>/g)) {
    if (!/marker-end=/.test(m[0])) continue;
    const p = puntas(m[0].match(/\bd="([^"]+)"/)?.[1] ?? '');
    if (!p || !pegado(p[0], exportes) || !pegado(p[1], puertos)) continue;
    errores.push(`${sitio.get(fig)}:${t.slice(0, m.index).split('\n').length} — la flecha va del`
      + ' <circle> al <rect>, o sea del export al port: al reves de la convencion que enuncia'
      + ' slides/es/110-threads.md ("la punta cuadrada siempre apunta al circulo").'
      + ' Da vuelta el path, y despues `node tools/figs-print.mjs`');
  }
}

// --- 6. --red: los links externos --------------------------------------------
if (RED) {
  const urls = [...externos].map(([u, d]) => [u.startsWith('//') ? 'https:' + u : u, d]);
  const tanda = 8;
  for (let i = 0; i < urls.length; i += tanda) {
    await Promise.all(urls.slice(i, i + tanda).map(async ([u, donde]) => {
      const probar = m => fetch(u, { method: m, redirect: 'follow', signal: AbortSignal.timeout(15000) });
      let r;
      try { r = await probar('HEAD'); if (r.status === 405 || r.status === 403) r = await probar('GET'); }
      catch (e) { errores.push(`${donde} — ${u} no responde: ${e.message}`); return; }
      if (!r.ok) errores.push(`${donde} — ${u} devuelve ${r.status}: cambiala o sacala`);
    }));
  }
  console.log(`  (${urls.length} links externos probados)`);
}

// --- el informe --------------------------------------------------------------
for (const a of avisos) console.log('  ! ' + a);
if (avisos.length) console.log(`${avisos.length} aviso(s)\n`);

if (errores.length) {
  console.error(`✗ ${errores.length} problema(s) en el sitio publicado:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
console.log(`✓ lint del sitio: ${paginas.length} paginas, ${sitio.size} archivos, ${externos.size} links externos`
  + `${RED ? ' (probados)' : ' (sin probar: --red)'}${DEUDA.length ? ` · ${DEUDA.length} deuda(s) conocida(s)` : ''}`);
if (avisos.length && AVISOS_FALLAN) process.exit(1);
