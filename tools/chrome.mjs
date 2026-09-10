// Donde esta Chrome. Lo buscan tres herramientas -- el PDF del deck, el lint de
// overflow y el machete -- y la lista estaba copiada en dos de ellas.
//
//   import { chrome } from './chrome.mjs';
//
// Sale 1 con un mensaje util si no lo encuentra: las tres lo necesitan si o si,
// asi que no tiene sentido que cada una decida que hacer.
import { access } from 'node:fs/promises';

const CANDIDATOS = [
  process.env.CHROME,
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Chromium.app/Contents/MacOS/Chromium',
  '/usr/bin/google-chrome', '/usr/bin/google-chrome-stable',
  '/usr/bin/chromium', '/usr/bin/chromium-browser',
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
].filter(Boolean);

let encontrado;
for (const c of CANDIDATOS) {
  try { await access(c); encontrado = c; break; } catch {}
}
if (!encontrado) {
  console.error('No encuentro Chrome/Chromium. Instalalo o exporta CHROME=/ruta/al/binario');
  process.exit(1);
}

export const chrome = encontrado;

// Los flags que necesitan LOS CUATRO. --no-sandbox estaba en dos de ellos y
// faltaba en los otros dos: en Ubuntu 24.04 el CI no puede abrir el namespace
// del sandbox y Chrome se muere sin escribir nada, que es como se rompio el
// build. Va aca por la misma razon que la lista de arriba.
export const BASE = [
  '--headless', '--disable-gpu', '--no-sandbox', '--allow-file-access-from-files',
];
