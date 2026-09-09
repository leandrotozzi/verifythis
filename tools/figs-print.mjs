// res/**/*.svg -> res/print/**/*.svg, la misma figura en paleta clara.
//
// Las figuras estan pensadas para el deck: texto claro sobre fondo #111. En el
// PDF, que tiene que poder imprimirse en papel blanco, eso desaparece.
//
// Se generan copias en vez de tematizarlas con CSS porque las slides las
// referencian con <img src>: un SVG externo es un documento aparte, no lo
// alcanza ni una regla del CSS de la pagina. Y se mapean los colores uno por
// uno en vez de invertirlas con un filter: invert() sube los tonos claros pero
// tambien aplasta los medios -- los trazos de #5b6b7a quedarian en 2:1 contra
// el papel, ilegibles justo donde vive el dibujo.
//
// El deck usa una paleta chica y consistente (12 colores en 50 figuras), asi
// que la tabla es corta y el mapeo es exacto, no una heuristica.
import { readdir, readFile, writeFile, mkdir } from 'node:fs/promises';
import path from 'node:path';

const SRC = 'res';
const OUT = 'res/print';
const CHECK = process.argv.includes('--check');

// Que significa cada color en el deck, y en que se convierte sobre papel.
const PALETA = {
  '#f0f0f0': '#16181d',   // texto principal
  '#8d8d8d': '#5a6068',   // texto secundario  -- 5.9:1 sobre blanco
  '#5f5f5f': '#6b7078',   // texto terciario
  '#ffffff': '#16181d',   // relleno de panel: siempre va con opacity 0.06, asi
                          //   que del lado claro queda un gris tenue (#f2f2f3)
  '#e7ad52': '#b0761d',   // ambar: el color-senal del curso -- 4.6:1
  '#74e685': '#1f8b45',   // verde: el otro color-senal      -- 4.8:1
  // Grises oscuros: separadores que del lado claro tienen que ser claros.
  '#444444': '#d0d3d8',
  '#444': '#d0d3d8',
  '#333333': '#d9dce1',
  '#333': '#d9dce1',
  '#3f3f3f': '#d4d7dc',
  '#2e2e2e': '#dfe2e6',
  // #5b6b7a (los trazos de las cajas) no esta: es un medio que ya rinde en los
  // dos fondos, 4.6:1 contra el papel. Cambiarlo seria redibujar el trazo.
};

const RE_COLOR = /(fill|stroke|stop-color|flood-color|color)="([^"]*)"/g;

const convertir = svg => svg.replace(RE_COLOR, (full, prop, valor) => {
  const mapeado = PALETA[valor.trim().toLowerCase()];
  return mapeado ? `${prop}="${mapeado}"` : full;
});

// Todos los .svg de res/, menos los que ya son la salida.
async function svgs(dir) {
  const out = [];
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (p === OUT) continue;
    if (e.isDirectory()) out.push(...await svgs(p));
    else if (e.name.endsWith('.svg')) out.push(p);
  }
  return out;
}

const viejas = [];
for (const src of (await svgs(SRC)).sort()) {
  const destino = path.join(OUT, path.relative(SRC, src));
  const claro = convertir(await readFile(src, 'utf8'));
  if (CHECK) {
    if (await readFile(destino, 'utf8').catch(() => null) !== claro) viejas.push(destino);
    continue;
  }
  await mkdir(path.dirname(destino), { recursive: true });
  await writeFile(destino, claro);
}

if (CHECK) {
  if (viejas.length) {
    console.error(`✗ ${OUT}/ esta desactualizado (${viejas.length} figura(s)) — corre: npm run build`);
    viejas.forEach(f => console.error('  ' + f));
    process.exit(1);
  }
  console.log(`✓ ${OUT}/ al dia`);
} else {
  console.log(`${OUT}/  ${(await svgs(SRC)).length} figuras en paleta clara`);
}
