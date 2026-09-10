// res/machete.html -> docs/machete-uvm.pdf, una carilla A4 apaisada. Y la
// version en ingles, res/en/machete.html -> docs/en/uvm-cheatsheet.pdf.
//
//   npm run machete
//
// El HTML es la fuente y se abre con doble clic; el PDF es la version que se
// imprime y se comparte, y va commiteado porque el que lo quiere pegar al lado
// del monitor no tiene Chrome headless ni ganas. No entra en `npm run check`:
// necesita Chrome, igual que `npm run pdf`.
//
// Las dos salen de la misma corrida por lo mismo que las figuras: era la unica
// fila de la tabla del README en ingles sin gemela en ingles, y el que la abria
// se encontraba una carilla en castellano.
import { spawn } from 'node:child_process';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
import { chrome, BASE } from './chrome.mjs';

const CARILLAS = [
  ['res/machete.html',    'docs/machete-uvm.pdf'],
  ['res/en/machete.html', 'docs/en/uvm-cheatsheet.pdf'],
];

const pdf = (src, out) => new Promise((res, rej) => spawn(chrome, [
  ...BASE,
  '--virtual-time-budget=10000',
  '--no-pdf-header-footer',
  `--print-to-pdf=${out}`,
  `file://${path.resolve(src)}`,
], { stdio: ['ignore', 'inherit', 'ignore'] })
  .on('close', c => (c === 0 ? res() : rej(new Error(`chrome salio con ${c} en ${src}`)))));

console.log(chrome);
for (const [src, out] of CARILLAS) {
  await mkdir(path.dirname(out), { recursive: true });
  await pdf(src, out);
  console.log(`ok: ${src}  ->  ${out}`);
}
