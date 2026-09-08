// Copia un subset curado de reveal.js (node_modules) a vendor/reveal/.
// vendor/ se commitea: por eso un clon fresco anda sin npm install.
// Solo el build UMD -- los modulos ESM los bloquea Chrome sobre file://.
import { cp, mkdir, readFile, writeFile, rm, stat } from 'node:fs/promises';
import path from 'node:path';
import * as esbuild from 'esbuild';

const SRC = 'node_modules/reveal.js';
const OUT = 'vendor/reveal';

// plugin/highlight/highlight.js NO se copia: se rebundlea mas abajo. El de
// reveal trae highlight.js entero (~190 lenguajes, 940 KB) y el deck usa seis.
const FILES = [
  'dist/reveal.js',
  'dist/reveal.css',
  'dist/reset.css',
  'dist/theme/night.css',
  'plugin/markdown/markdown.js',
  'plugin/notes/notes.js',
  'plugin/notes/speaker-view.html',
  'plugin/search/search.js',
  'plugin/zoom/zoom.js',
];

await rm(OUT, { recursive: true, force: true });
for (const f of FILES) {
  await mkdir(`${OUT}/${f}`.replace(/\/[^/]+$/, ''), { recursive: true });
  await cp(`${SRC}/${f}`, `${OUT}/${f}`);
}

// night.css importa Montserrat/Open Sans desde el CDN de Google -> rompe el modo
// offline. Se strippea; course.css redefine --r-main-font/--r-heading-font con un
// stack de sistema.
const theme = `${OUT}/dist/theme/night.css`;
const css = await readFile(theme, 'utf8');
const stripped = css.replace(/^@import url\(https:\/\/fonts\.googleapis[^)]*\);\s*$/gm, '');
if (stripped === css) console.warn('! night.css: no se encontro el @import de Google Fonts');
await writeFile(theme, stripped);

// El plugin de highlight, con hljs-slim.mjs en lugar del paquete completo.
// Va onResolve con filtro exacto y no la opcion `alias` de esbuild: alias
// reescribe tambien los subpaths y se comeria los 'highlight.js/lib/...' que
// importa el propio shim.
const HLJS = path.resolve('tools/hljs-slim.mjs');
await esbuild.build({
  entryPoints: ['tools/hljs-entry.mjs'],
  outfile: `${OUT}/plugin/highlight/highlight.js`,
  bundle: true,
  minify: true,
  format: 'iife',
  plugins: [{
    name: 'hljs-slim',
    setup: b => b.onResolve({ filter: /^highlight\.js$/ }, () => ({ path: HLJS })),
  }],
});

// Si algun lenguaje dejara de resolver, el deck se quedaria sin colores en
// silencio. Se verifica aca contra la tabla LANG de build.mjs -- 'sv' es el
// alias de la gramatica propia (tools/hljs-sv.mjs), la etiqueta que build.mjs
// le pone a todos los fences de .sv/.svh.
const { default: hljs } = await import('./hljs-slim.mjs');
const faltan = ['sv', 'vhdl', 'tcl', 'python', 'bash', 'plaintext'].filter(l => !hljs.getLanguage(l));
if (faltan.length) throw new Error(`hljs-slim.mjs no resuelve: ${faltan.join(', ')}`);

const kb = Math.round((await stat(`${OUT}/plugin/highlight/highlight.js`)).size / 1024);
console.log(`${OUT}/plugin/highlight/highlight.js <- hljs slim, 6 lenguajes (${kb} KB)`);

const { version } = JSON.parse(await readFile(`${SRC}/package.json`, 'utf8'));
await writeFile(`${OUT}/VERSION`, `reveal.js ${version}\ngenerado por tools/vendor.mjs -- no editar a mano\n`);
console.log(`vendor/reveal <- reveal.js ${version} (${FILES.length} archivos)`);
