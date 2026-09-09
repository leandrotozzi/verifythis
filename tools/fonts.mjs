// Vendoriza las fuentes del deck desde Google Fonts a css/fonts/.
// Se corre una vez (o al cambiar de tipografia); css/fonts/ se commitea.
//
// El deck tiene que funcionar offline abriendo index.html con doble clic, asi
// que NO puede haber @import a fonts.googleapis.com: los .woff2 viven en el repo.
// Se baja solo el subset latino (U+0000-00FF), que cubre el castellano
// (acentos, ñ, ¿, ¡) -- el resto de los subsets serian peso muerto.
//
// font-display: swap, no block. `block` es FOIT: hasta 3 s con el texto
// INVISIBLE, y eso pega en las 20 paginas del sitio -- la landing que compite
// por el clic y las 16 del libro, que son prosa larga. Con `swap` el texto se
// lee desde el primer paint con la fuente de sistema y cambia cuando llega la
// woff2. Se descarto `optional` (que ademas evita el reflow) porque en la
// primera visita fria simplemente NO usa la fuente, y la tipografia del deck es
// la identidad del curso proyectada en un aula: preferimos el reflow. En el
// deck abierto con doble clic no se nota ninguno de los dos: las woff2 estan
// en disco al lado del HTML. Las dos landings ademas preloadean las dos caras
// del above-the-fold, asi que ahi el swap casi nunca llega a verse.
import { mkdir, writeFile, rm } from 'node:fs/promises';

const OUT = 'css/fonts';
const UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36';

const FAMILIES = [
  { name: 'Chakra Petch',  spec: 'Chakra+Petch:ital,wght@0,600;0,700;1,600' },
  { name: 'IBM Plex Sans', spec: 'IBM+Plex+Sans:ital,wght@0,400;0,600;1,400' },
  { name: 'IBM Plex Mono', spec: 'IBM+Plex+Mono:wght@400;600' },
];

const LATIN = 'U+0000-00FF';
const slug = s => s.toLowerCase().replace(/[^a-z0-9]+/g, '-');

await rm(OUT, { recursive: true, force: true });
await mkdir(OUT, { recursive: true });

const faces = [];
for (const { name, spec } of FAMILIES) {
  const css = await (await fetch(`https://fonts.googleapis.com/css2?family=${spec}&display=swap`,
    { headers: { 'User-Agent': UA } })).text();

  for (const block of css.split('@font-face').slice(1)) {
    if (!block.includes(LATIN)) continue;              // solo el subset latino
    const get = re => (block.match(re) || [])[1];
    const family = get(/font-family: '([^']+)'/);
    if (family !== name) continue;
    const style = get(/font-style: (\w+)/) || 'normal';
    const weight = get(/font-weight: (\d+)/) || '400';
    const url = get(/src: url\((https:[^)]+\.woff2)\)/);
    if (!url) continue;

    const file = `${slug(name)}-${weight}${style === 'italic' ? 'i' : ''}.woff2`;
    const buf = Buffer.from(await (await fetch(url, { headers: { 'User-Agent': UA } })).arrayBuffer());
    await writeFile(`${OUT}/${file}`, buf);
    faces.push({ family: name, style, weight, file, size: buf.length });
  }
}

if (!faces.length) throw new Error('no baje ninguna fuente');

const css = `/* GENERADO POR tools/fonts.mjs -- no editar a mano.
   Fuentes vendorizadas: el deck abre con doble clic (file://) y sin internet,
   asi que no puede depender del CDN de Google. Solo subset latino.

   Chakra Petch (SIL OFL 1.1) -- titulos
   IBM Plex Sans / IBM Plex Mono (SIL OFL 1.1) -- cuerpo y codigo */

${faces.map(f => `@font-face {
  font-family: '${f.family}';
  font-style: ${f.style};
  font-weight: ${f.weight};
  font-display: swap;
  src: url(fonts/${f.file}) format('woff2');
}`).join('\n\n')}
`;
await writeFile('css/fonts.css', css);

const total = faces.reduce((n, f) => n + f.size, 0);
for (const f of faces) console.log(`  ${f.file.padEnd(28)} ${(f.size / 1024).toFixed(0)} KB`);
console.log(`css/fonts.css  ${faces.length} faces, ${(total / 1024).toFixed(0)} KB`);
