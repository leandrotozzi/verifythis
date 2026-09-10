// La tarjeta que GitHub muestra al compartir el link del repo
// (Settings > General > Social preview) y el og:image de respaldo.
//
//   node tools/social-card.mjs      tools/social-card.html -> docs/social-card.png
//
// GitHub NO expone esa imagen por API: el PNG se sube a mano, una vez. Esto
// existe para que el dia que cambien los numeros o el hook no haya que
// redibujarla en un editor -- se edita el HTML y se vuelve a rendir.
import { spawn } from 'node:child_process';
import path from 'node:path';
import { chrome, BASE } from './chrome.mjs';

const SRC = path.resolve('tools/social-card.html');
const OUT = path.resolve('docs/social-card.png');

// 1280x640 es lo que pide GitHub. Sin --window-size el screenshot sale del
// tamano del viewport por defecto y la tarjeta queda cortada.
// El stderr se guarda y solo se imprime si falla: en macOS Chrome escupe una
// docena de warnings de CVDisplayLink en cada corrida buena.
let err = '';
const p = spawn(chrome, [...BASE, '--window-size=1280,640', '--hide-scrollbars',
  '--virtual-time-budget=30000', `--screenshot=${OUT}`, `file://${SRC}`],
  { stdio: ['ignore', 'ignore', 'pipe'] });
p.stderr.on('data', d => (err += d));
p.on('close', c => {
  if (c === 0) console.log(`ok: ${OUT}  1280x640`);
  else console.error(`chrome salio con ${c}:\n${err.trim() || '(nada)'}`);
  process.exit(c);
});
