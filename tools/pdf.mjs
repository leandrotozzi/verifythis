// Deck -> PDF via Chrome headless sobre ?print-pdf. Usa el Chrome ya instalado:
// sin puppeteer, sin bajar 300 MB de navegador.
import { spawn } from 'node:child_process';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
import { chrome } from './chrome.mjs';

const OUT = 'dist/curso-uvm.pdf';

await mkdir('dist', { recursive: true });
const url = `file://${path.resolve('index.html')}?print-pdf`;
const args = [
  '--headless', '--disable-gpu', '--no-sandbox',
  '--allow-file-access-from-files',
  '--virtual-time-budget=60000',
  '--no-pdf-header-footer',
  `--print-to-pdf=${OUT}`,
  url,
];
console.log(`${chrome}\n  -> ${OUT}`);
spawn(chrome, args, { stdio: ['ignore', 'inherit', 'ignore'] })
  .on('close', c => { console.log(c === 0 ? `ok: ${OUT}` : `chrome salio con ${c}`); process.exit(c); });
