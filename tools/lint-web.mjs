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
//   4. AVISO  archivo de res/ que no referencia ninguna pagina (peso muerto)
//   5. AVISO  pagina del sitio que no esta en el sitemap.xml
//   6. --red  links http/https muertos. NO corre en cada push: depende de que
//             el server del otro este vivo, y un CI que falla por eso enseña a
//             ignorar el CI. Va en la corrida nocturna.
//
// Uso: node tools/lint-web.mjs [--red] [--avisos-fallan]
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { MANIFIESTO, inventarioDelSitio, reescribir } from './sitio.mjs';

const RED = process.argv.includes('--red');
const AVISOS_FALLAN = process.argv.includes('--avisos-fallan');

// Deuda conocida: bugs REALES, en archivos que no son de este lint. Se listan
// aca para que `npm run check` no quede rojo para todo el mundo mientras el
// dueño los arregla -- y la lista se limpia sola: si una entrada deja de
// dispararse, este lint FALLA pidiendo que la saques. Un TODO que no se puede
// olvidar es la unica clase de TODO que sirve.
const DEUDA = [];

const errores = [], avisos = [];
const usados = new Set();     // rutas del sitio que alguien referencia
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
      usados.add(destino);
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

// --- deuda que ya no existe --------------------------------------------------
for (const d of DEUDA) {
  if (deudaVista.has(d)) continue;
  errores.push(`tools/lint-web.mjs — la deuda "${d[0]} -> ${d[1]}*" ya no se dispara: ${d[2]}.`
    + ' Se arreglo: borra esa entrada de DEUDA para que el lint la empiece a exigir');
}

// --- 3. huerfanos de res/ ----------------------------------------------------
// res/print/ NO cuenta: son las mismas figuras en paleta clara, las genera
// tools/figs-print.mjs y las elige el JS del deck en tiempo de impresion.
const cuerpos = [];
for (const dst of [...sitio.keys()].filter(d => /\.(html|css|svg)$/.test(d) && !d.startsWith('vendor/')))
  cuerpos.push(await contenido(dst));
const blob = cuerpos.join('\n');
for (const dst of sitio.keys()) {
  if (!dst.startsWith('res/') || dst.startsWith('res/print/')) continue;
  if (usados.has(dst) || blob.includes(path.posix.basename(dst))) continue;
  avisos.push(`${sitio.get(dst)} — no lo referencia ninguna pagina del sitio: borralo o usalo`);
}

// --- 4. paginas fuera del sitemap --------------------------------------------
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

// --- 5. --red: los links externos --------------------------------------------
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
