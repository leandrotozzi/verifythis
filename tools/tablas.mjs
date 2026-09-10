// tools/datos-machete.mjs -> las tablas de las slides y de los dos machetes.
//
// Una tabla escrita a mano en cuatro lugares se arregla en tres. Paso con las
// nueve fases: la slide del dia 3 decia que `final` es top-down --lo correcto--
// y el machete impreso decia bottom-up. Nadie lo vio en dos revisiones porque
// para verlo hay que abrir los cuatro archivos a la vez.
//
// Cada destino declara donde va su tabla con dos comentarios HTML, que son
// invisibles en markdown y en el HTML del machete:
//
//   <!-- tabla: fases -->
//   ...lo que este aca adentro se REGENERA...
//   <!-- tabla: end -->
//
// Uso:
//   node tools/tablas.mjs            reescribe los destinos
//   node tools/tablas.mjs --check    falla si alguno quedo viejo (lo corre el CI)
import { readFile, writeFile } from 'node:fs/promises';
import { FASES, PERILLAS, PLUSARGS } from './datos-machete.mjs';

const CHECK = process.argv.includes('--check');

// La slide escribe el nombre completo del metodo; el machete, que es una carilla
// A4, escribe el nombre corto.
const md = (h, filas) => [`| ${h.join(' | ')} |`, `| ${h.map(() => '---').join(' | ')} |`, ...filas].join('\n');

const RENDER = {
  'fases-es': () => md(['Fase', 'Para qué', 'Orden'], FASES.map(f =>
    `| \`${f.fase}_phase\` | ${f.es} | ${f.orden === 'top-down' ? '**top-down**' : f.orden} |`)),
  'fases-en': () => md(['Phase', 'What for', 'Order'], FASES.map(f =>
    `| \`${f.fase}_phase\` | ${f.en} | ${f.orden === 'top-down' ? '**top-down**' : (f.ordenEn ?? f.orden)} |`)),
  'fases-machete-es': () => FASES.map(f =>
    `        <tr><td class="${f.fuerte ? 'm-strong' : 'm'}">${f.fase}</td><td>${neg(f.es)}</td><td>${f.orden === 'top-down' ? `<b>${f.orden}</b>` : f.orden}</td></tr>`).join('\n'),
  'fases-machete-en': () => FASES.map(f =>
    `        <tr><td class="${f.fuerte ? 'm-strong' : 'm'}">${f.fase}</td><td>${neg(f.en)}</td><td>${f.orden === 'top-down' ? `<b>${f.orden}</b>` : (f.ordenEn ?? f.orden)}</td></tr>`).join('\n'),

  'perillas-es': () => md(['Herramienta', 'Para qué', 'Dónde salió'], PERILLAS.map(p =>
    `| ${p.perilla} | ${p.es} | ${p.dondeEs} |`)),
  'perillas-en': () => md(['Tool', 'What for', 'Where it came up'], PERILLAS.map(p =>
    `| ${p.perilla} | ${p.en} | ${p.dondeEn} |`)),
  'perillas-machete-es': () => PERILLAS.map(p =>
    `        <tr><td class="m">${p.machete}</td><td>${neg(p.es)}</td><td>${p.sintomaEs}</td></tr>`).join('\n'),
  'perillas-machete-en': () => PERILLAS.map(p =>
    `        <tr><td class="m">${p.machete}</td><td>${neg(p.en)}</td><td>${p.sintomaEn}</td></tr>`).join('\n'),
};

// El markdown de las slides usa **negrita** y `codigo`; el machete es HTML.
function neg(s) {
  return s.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>').replace(/`(.+?)`/g, '<span class="m">$1</span>');
}

const DESTINOS = [
  ['slides/es/080-components.md', 'fases', 'fases-es'],
  ['slides/en/080-components.md', 'fases', 'fases-en'],
  ['res/machete.html', 'fases', 'fases-machete-es'],
  ['res/en/machete.html', 'fases', 'fases-machete-en'],
  ['slides/es/171-apendice-debug.md', 'perillas', 'perillas-es'],
  ['slides/en/171-apendice-debug.md', 'perillas', 'perillas-en'],
  ['res/machete.html', 'perillas', 'perillas-machete-es'],
  ['res/en/machete.html', 'perillas', 'perillas-machete-en'],
];

const viejos = [];
const porArchivo = new Map();
for (const [ruta, marca, render] of DESTINOS) {
  if (!porArchivo.has(ruta)) porArchivo.set(ruta, await readFile(ruta, 'utf8'));
  const t = porArchivo.get(ruta);
  const re = new RegExp(`(<!-- tabla: ${marca} -->\\n)[\\s\\S]*?(\\n<!-- tabla: end -->)`);
  if (!re.test(t)) {
    console.error(`✗ ${ruta} — le falta el bloque <!-- tabla: ${marca} --> ... <!-- tabla: end -->`);
    process.exit(1);
  }
  const nuevo = t.replace(re, (_, a, b) => a + RENDER[render]() + b);
  if (nuevo !== t) viejos.push(`${ruta} (${marca})`);
  porArchivo.set(ruta, nuevo);
}

if (CHECK) {
  if (viejos.length) {
    console.error(`✗ ${viejos.length} tabla(s) desactualizada(s) respecto de tools/datos-machete.mjs — corre: npm run build`);
    viejos.forEach(v => console.error('  ✗ ' + v));
    process.exit(1);
  }
  console.log(`✓ tablas al dia: ${FASES.length} fases y ${PERILLAS.length} perillas (${PLUSARGS} plusargs) en ${DESTINOS.length} destinos`);
} else {
  for (const [ruta, t] of porArchivo) await writeFile(ruta, t);
  console.log(`${DESTINOS.length} tablas generadas desde tools/datos-machete.mjs`);
}
