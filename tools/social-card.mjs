// Los dos PNG de la marca, los dos con el tilde del favicon:
//
//   docs/social-card.png  1280x640  la tarjeta al compartir el link del repo
//                                   (Settings > General > Social preview)
//   docs/avatar.png        500x500  el avatar de una cuenta u organizacion
//
//   node tools/social-card.mjs
//
// GitHub NO expone ninguna de las dos por API: se suben a mano, una vez. Esto
// existe para que el dia que cambien los numeros o el hook no haya que
// redibujarlas en un editor -- se edita el HTML y se vuelve a rendir.
import { spawn } from 'node:child_process';
import path from 'node:path';
import { chrome, BASE } from './chrome.mjs';

// 1280x640 es lo que pide GitHub para la tarjeta; 500x500 para el avatar. Sin
// --window-size el screenshot sale del viewport por defecto y quedan cortados.
const PIEZAS = [
  ['tools/social-card.html', 'docs/social-card.png', '1280,640'],
  ['tools/avatar.html',      'docs/avatar.png',      '500,500'],
];
// El stderr se guarda y solo se imprime si falla: en macOS Chrome escupe una
// docena de warnings de CVDisplayLink en cada corrida buena.
const rendir = (src, out, tam) => new Promise((res, rej) => {
  let err = '';
  const p = spawn(chrome, [...BASE, `--window-size=${tam}`, '--hide-scrollbars',
    '--virtual-time-budget=30000', `--screenshot=${path.resolve(out)}`,
    `file://${path.resolve(src)}`], { stdio: ['ignore', 'ignore', 'pipe'] });
  p.stderr.on('data', d => (err += d));
  p.on('close', c => (c === 0
    ? res(console.log(`ok: ${out}  ${tam.replace(',', 'x')}`))
    : rej(new Error(`chrome salio con ${c} en ${src}:\n${err.trim() || '(nada)'}`))));
});

// De a una: dos Chrome headless a la vez en un runner de 2 cores se pelean.
for (const [src, out, tam] of PIEZAS) await rendir(src, out, tam);
