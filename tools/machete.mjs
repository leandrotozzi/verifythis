// res/machete.html -> docs/machete-uvm.pdf, una carilla A4 apaisada.
//
//   npm run machete
//
// El HTML es la fuente y se abre con doble clic; el PDF es la version que se
// imprime y se comparte, y va commiteado porque el que lo quiere pegar al lado
// del monitor no tiene Chrome headless ni ganas. No entra en `npm run check`:
// necesita Chrome, igual que `npm run pdf`.
import { spawn } from 'node:child_process';
import path from 'node:path';
import { chrome } from './chrome.mjs';

const OUT = 'docs/machete-uvm.pdf';
const url = `file://${path.resolve('res/machete.html')}`;

console.log(`${chrome}\n  -> ${OUT}`);
spawn(chrome, [
  '--headless', '--disable-gpu', '--no-sandbox',
  '--allow-file-access-from-files',
  '--virtual-time-budget=10000',
  '--no-pdf-header-footer',
  `--print-to-pdf=${OUT}`,
  url,
], { stdio: ['ignore', 'inherit', 'ignore'] })
  .on('close', c => { console.log(c === 0 ? `ok: ${OUT}` : `chrome salio con ${c}`); process.exit(c); });
