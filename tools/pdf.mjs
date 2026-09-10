// Deck -> PDF via Chrome headless sobre ?print-pdf. Usa el Chrome ya instalado:
// sin puppeteer, sin bajar 300 MB de navegador.
import { spawn } from 'node:child_process';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
import { chrome, BASE } from './chrome.mjs';
import { idiomaDeArgv, SALIDAS } from './i18n.mjs';

const OUT_LANG = SALIDAS[idiomaDeArgv()];
const OUT = OUT_LANG.pdf;

await mkdir('dist', { recursive: true });
const url = `file://${path.resolve(OUT_LANG.html)}?print-pdf`;
const args = [
  ...BASE,
  '--virtual-time-budget=60000',
  '--no-pdf-header-footer',
  `--print-to-pdf=${OUT}`,
  url,
];
console.log(`${chrome}\n  -> ${OUT}`);
spawn(chrome, args, { stdio: ['ignore', 'inherit', 'ignore'] })
  .on('close', c => { console.log(c === 0 ? `ok: ${OUT}` : `chrome salio con ${c}`); process.exit(c); });
