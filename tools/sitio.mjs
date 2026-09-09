// El sitio publicado: _site/, armado desde el repo.
//
// Esto vivia adentro de .github/workflows/build.yml, como veinte lineas de
// `cp` + `sed -i` + un `grep -q` suelto de red de seguridad. Tres problemas,
// los tres del mismo tipo -- nadie lo puede correr antes de pushear:
//
//   1. El `sed` es silencioso. Si el libro deja de escribir "../index.html#"
//      (porque cambio libro.mjs), la reescritura matchea CERO veces y no pasa
//      nada: el sitio sale con links al archivo equivocado y el workflow queda
//      en verde. El `grep -q` de abajo tapaba UN caso de UNA sola pagina.
//   2. `sed -i` de GNU no es el de macOS, asi que el bloque no se podia probar
//      local ni siquiera copiandolo a mano.
//   3. El layout del sitio NO es el del repo -- el deck se llama curso.html, la
//      landing es la raiz -- y ese mapa estaba escrito solo en el YAML, o sea
//      que ningun linter lo podia leer. tools/lint-web.mjs lo importa de aca.
//
// Ahora: el mapa es una tabla, cada reescritura declara en cuantos archivos
// TIENE que matchear, y al final se verifica que no haya quedado ninguna ruta
// del layout viejo. Si algo de eso no se cumple, el build se cae y dice cual.
//
//   npm run sitio                   arma _site/ (ya esta en el .gitignore)
//   node tools/sitio.mjs otro/      arma otro directorio
//   node tools/sitio.mjs --estricto exige tambien los PDF/PPTX de dist/
import { cp, mkdir, readFile, writeFile, readdir, rm, stat } from 'node:fs/promises';
import path from 'node:path';

// [origen en el repo, destino en el sitio, opcional?]
// Los assets (css, js, res, vendor) NO se duplican para el ingles: el deck y el
// libro en en/ ya salen del build con el ../ y el ../../ que hacen falta.
export const MANIFIESTO = [
  // La raiz del sitio es la LANDING, no el deck: reveal.js no le da a un
  // buscador una linea que indexar, y el que llega de Google necesita saber que
  // es esto antes de caer en la slide 1 de 400.
  ['web/index.html',      'index.html'],
  ['web/robots.txt',      'robots.txt'],
  ['web/sitemap.xml',     'sitemap.xml'],
  ['index.html',          'curso.html'],
  ['docs/portada.png',    'portada.png'],
  ['css',                 'css'],
  ['js',                  'js'],
  ['res',                 'res'],
  ['vendor',              'vendor'],
  ['libro',               'libro'],
  ['dist/curso-uvm.pdf',  'curso-uvm.pdf',  'opcional'],
  ['dist/curso-uvm.pptx', 'curso-uvm.pptx', 'opcional'],
  ['web/en/index.html',   'en/index.html'],
  ['en/index.html',       'en/curso.html'],
  ['en/libro',            'en/libro'],
  ['dist/uvm-course.pdf',  'uvm-course.pdf',  'opcional'],
  ['dist/uvm-course.pptx', 'uvm-course.pptx', 'opcional'],
];

// --- el <head> de SEO de las 18 paginas GENERADAS ----------------------------
// El deck (tools/template.html) y el libro (tools/libro.mjs) son 18 de las 20
// URLs del sitio y no tenian ni favicon, ni canonical, ni og:image, ni hreflang.
//
// El bloque se arma ACA y no en cada generador por una razon: la URL canonica de
// una pagina depende del layout PUBLICADO, no del repo -- el deck se llama
// curso.html y la landing es la raiz --, y ese mapa es justo lo que sabe este
// archivo (MANIFIESTO, arriba). Un canonical que apunte a index.html cuando la
// URL real es curso.html manda a Google a una pagina que no existe: es peor que
// no tener canonical. Con esto, si el layout cambia, se cambia en un solo lugar.
export const SITIO = 'https://leandrotozzi.github.io/verifythis/';

// docs/portada.png publicada en la raiz. Las medidas las fija tools/capturas.mjs
// (la constante PORTADA); si cambian alla, cambian aca.
const OG_IMG = { url: SITIO + 'portada.png', w: 1200, h: 630 };
const LOCALE = { es: 'es_AR', en: 'en_US' };

const attr = t => String(t).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');

// es, en   la ruta de ESTA pagina en el sitio, en cada idioma ('curso.html',
//          'en/libro/day3.html'). Si el otro idioma todavia no tiene la pagina,
//          se pasa null y no se escribe ese hreflang: un alternate a un 404 le
//          dice al buscador que la traduccion existe cuando no existe.
// lang     cual de los dos es esta pagina
// css      como se llega a css/ desde esta pagina ('css/', '../css/', ...).
//          Relativo y no absoluto a proposito: el deck tiene que abrir con doble
//          clic desde el repo, sin internet, y css/ se llama igual en el repo y
//          en el sitio.
//          El favicon vive en css/ y no en res/ porque tools/figs-print.mjs
//          toma TODO res/**.svg por una figura del curso y le genera una copia
//          en paleta clara para el PDF: un favicon ahi se cuenta como la figura
//          41 y rompe el numero que verifica lint-refs. css/ ya guarda assets
//          que no son CSS (close-button.png).
export function seo({ es, en, lang, css, titulo, desc, tipo = 'website' }) {
  const propia = lang === 'en' ? en : es;
  const url = SITIO + propia;
  const alt = [['es', es], ['en', en], ['x-default', es]]
    .filter(([, p]) => p != null)
    .map(([h, p]) => `  <link rel="alternate" hreflang="${h}" href="${SITIO}${p}">`);
  return [
    `  <link rel="canonical" href="${url}">`,
    ...alt,
    '  <meta name="theme-color" content="#111111">',
    `  <link rel="icon" type="image/svg+xml" href="${css}favicon.svg">`,
    `  <link rel="icon" type="image/png" sizes="32x32" href="${css}favicon-32.png">`,
    `  <meta property="og:type" content="${tipo}">`,
    '  <meta property="og:site_name" content="Verify This!">',
    `  <meta property="og:locale" content="${LOCALE[lang]}">`,
    `  <meta property="og:title" content="${attr(titulo)}">`,
    `  <meta property="og:description" content="${attr(desc)}">`,
    `  <meta property="og:url" content="${url}">`,
    `  <meta property="og:image" content="${OG_IMG.url}">`,
    `  <meta property="og:image:width" content="${OG_IMG.w}">`,
    `  <meta property="og:image:height" content="${OG_IMG.h}">`,
    `  <meta property="og:image:alt" content="${attr(titulo)}">`,
    '  <meta name="twitter:card" content="summary_large_image">',
    `  <meta name="twitter:title" content="${attr(titulo)}">`,
    `  <meta name="twitter:description" content="${attr(desc)}">`,
    `  <meta name="twitter:image" content="${OG_IMG.url}">`,
    `  <meta name="twitter:image:alt" content="${attr(titulo)}">`,
  ].join('\n');
}

// Las dos rutas que el libro NO puede escribir bien desde el repo, porque en el
// repo el deck se llama index.html y la landing vive en web/.
//   [prefijo del destino, patron, reemplazo, en cuantos archivos tiene que dar]
// El "minimo" es lo que reemplaza al `grep -q`: si manana libro.mjs cambia como
// escribe estos links, la cuenta baja y el build se cae en vez de publicar un
// sitio con los links al archivo equivocado.
export const REESCRITURAS = [
  ['libro/',    /"\.\.\/index\.html#/g,          '"../curso.html#', 8],
  ['libro/',    /"\.\.\/web\/index\.html"/g,     '"../index.html"', 8],
  ['en/libro/', /"\.\.\/index\.html#/g,          '"../curso.html#', 8],
  ['en/libro/', /"\.\.\/\.\.\/web\/index\.html"/g, '"../index.html"', 8],
];

// Despues de reescribir no puede quedar NADA del layout del repo. Es la misma
// idea que el `grep -q` viejo, pero al reves: en vez de confirmar un caso que
// esperamos, se prohibe el patron entero en todas las paginas.
const PROHIBIDO = [
  [/"\.{2,}\/(\.\.\/)?web\/index\.html"/, 'web/index.html no existe en el sitio: la landing es la raiz'],
  [/"\.\.\/index\.html#\//,               'el deck se llama curso.html en el sitio, no index.html'],
];

export function reescribir(destino, txt) {
  let out = txt, n = 0;
  for (const [pref, re, a] of REESCRITURAS) {
    if (!destino.startsWith(pref)) continue;
    const antes = out;
    out = out.replace(re, a);
    if (out !== antes) n++;
  }
  return { txt: out, aplicadas: n };
}

const existe = p => stat(p).then(() => true, () => false);

// Los archivos del sitio, sin copiar nada: [destino, origen]. Lo usa
// tools/lint-web.mjs para chequear los links del SITIO sin tener que armarlo.
export async function inventarioDelSitio() {
  const out = [];
  for (const [src, dst, opcional] of MANIFIESTO) {
    const st = await stat(src).catch(() => null);
    if (!st) {
      if (opcional) continue;
      throw new Error(`tools/sitio.mjs: falta ${src}, que el sitio necesita como ${dst}`);
    }
    if (!st.isDirectory()) { out.push([dst, src]); continue; }
    const pila = [''];
    while (pila.length) {
      const rel = pila.pop();
      for (const e of await readdir(path.join(src, rel), { withFileTypes: true })) {
        const r = path.join(rel, e.name);
        if (e.isDirectory()) pila.push(r);
        else out.push([path.posix.join(dst, r.split(path.sep).join('/')), path.join(src, r)]);
      }
    }
  }
  return out;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const args = process.argv.slice(2);
  const estricto = args.includes('--estricto');
  const DEST = args.find(a => !a.startsWith('--')) ?? '_site';

  await rm(DEST, { recursive: true, force: true });
  await mkdir(DEST, { recursive: true });

  const faltan = [];
  for (const [src, dst, opcional] of MANIFIESTO) {
    if (!await existe(src)) {
      if (opcional && !estricto) { faltan.push(src); continue; }
      console.error(`✗ falta ${src} — el sitio lo necesita como ${dst}`
        + (opcional ? ' (corre: npm run pdf && npm run pptx)' : ' (corre: npm run build)'));
      process.exit(1);
    }
    await mkdir(path.dirname(path.join(DEST, dst)), { recursive: true });
    await cp(src, path.join(DEST, dst), { recursive: true });
  }
  // "Opcional" es opcional para ARMAR el sitio, no para el sitio publicado: las
  // dos landings linkean el PDF y el PPTX sin condicion (el boton del hero y dos
  // items del footer, por idioma). Un _site/ armado sin ellos tiene esos links
  // muertos. El que se publica NO puede tenerlos: build.yml corre este script
  // con --estricto -- que falla si faltan -- y el job "humo" pide los dos PDF
  // con curl despues del deploy. Asi que el aviso dice exactamente eso, en vez
  // de "son opcionales", que sonaba a que no pasaba nada.
  if (faltan.length) console.log(`  ! sin ${faltan.join(', ')}: el sitio se arma igual, pero las landings`
    + ' los linkean y en ESTA copia esos links quedan muertos.'
    + '\n    Para una completa: npm run pdf && npm run pptx (el CI usa --estricto, que falla si faltan)');

  // --- las reescrituras, contadas ---------------------------------------------
  const cuentas = new Map(REESCRITURAS.map(r => [r, 0]));
  for (const [dst] of await inventarioDelSitio()) {
    if (!dst.endsWith('.html')) continue;
    const f = path.join(DEST, dst);
    const antes = await readFile(f, 'utf8');
    let txt = antes;
    for (const regla of REESCRITURAS) {
      const [pref, re, a] = regla;
      if (!dst.startsWith(pref)) continue;
      const nuevo = txt.replace(re, a);
      if (nuevo !== txt) cuentas.set(regla, cuentas.get(regla) + 1);
      txt = nuevo;
    }
    if (txt !== antes) await writeFile(f, txt);

    for (const [re, porque] of PROHIBIDO) {
      if (!re.test(txt)) continue;
      console.error(`✗ ${dst}: quedo "${txt.match(re)[0]}" — ${porque}`);
      console.error('  arreglalo en tools/sitio.mjs (tabla REESCRITURAS) o en tools/libro.mjs');
      process.exit(1);
    }
  }
  let mal = 0;
  for (const [regla, n] of cuentas) {
    const [pref, re, , minimo] = regla;
    if (n >= minimo) continue;
    console.error(`✗ la reescritura ${re} de ${pref} matcheo en ${n} archivo(s) y esperaba ${minimo}`);
    console.error('  o cambio como los genera tools/libro.mjs, o falta un dia: revisa la tabla REESCRITURAS');
    mal++;
  }
  if (mal) process.exit(1);

  const files = await inventarioDelSitio();
  console.log(`✓ ${DEST}/ armado: ${files.length} archivos`);
}
