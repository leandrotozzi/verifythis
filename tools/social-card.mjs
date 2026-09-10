// Los dos PNG de la marca, los dos con el tilde del favicon:
//
//   docs/social-card.png  1280x640  la tarjeta al compartir el link del repo
//                                   (Settings > General > Social preview)
//   docs/avatar.png        500x500  el avatar de una cuenta u organizacion
//
//   node tools/social-card.mjs
//   node tools/social-card.mjs --check   falla si la tarjeta quedo vieja
//
// GitHub NO expone ninguna de las dos por API: se suben a mano, una vez. Esto
// existe para que el dia que cambien los numeros o el hook no haya que
// redibujarlas en un editor -- se edita el HTML y se vuelve a rendir.
//
// El --check, y por que hacia falta. Estos dos PNG eran las UNICAS imagenes
// generadas del repo sin ningun chequeo: docs/portada.png tiene el de
// capturas.mjs, las figuras tienen el de figs-print.mjs, y estas no tenian
// nada. Y la tarjeta dibuja tres numeros escritos a mano en
// tools/social-card.html ("8 units - 444 slides - 38 runnable examples"), que
// es exactamente la forma en que envejecio la portada: la slide 0 anunciaba
// seis dias cuando el curso ya tenia ocho, y nadie se entero hasta que
// capturas.mjs empezo a mirarlo.
//
// Chequea dos cosas distintas, y por eso son dos mensajes distintos:
//
//   1. el HTML contra tools/inventario.mjs -- si el curso crecio, el numero
//      escrito a mano quedo viejo y se edita tools/social-card.html;
//   2. el sello docs/.social-card.json contra el HTML -- si alguien edito el
//      HTML y no volvio a rendir, el PNG que se sube a GitHub no dice lo que
//      dice el HTML, y hay que correr este script (necesita Chrome).
//
// No compara pixeles, por lo mismo que capturas.mjs: el PNG de una Mac y el del
// Linux del CI no son byte a byte iguales y eso seria rojo permanente.
//
// "8 units" no se chequea contra nada: inventario.mjs no cuenta unidades a
// proposito -- son 8 en los siete dias mas una novena opcional, y la prosa dice
// las dos cosas. Lo dice su propio comentario final.
import { spawn } from 'node:child_process';
import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { chrome, BASE } from './chrome.mjs';
import { inventario } from './inventario.mjs';

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

// Los numeros que la tarjeta dibuja, leidos del HTML que se rinde. Son la
// fuente de la imagen: si esto no matchea, el que cambio de forma es el HTML y
// el chequeo tiene que fallar ruidoso en vez de mirar para otro lado.
const TARJETA = 'tools/social-card.html';
const SELLO = 'docs/.social-card.json';

async function numerosDelHtml() {
  const html = await readFile(TARJETA, 'utf8');
  const m = html.match(/(\d+)\s+units.*?(\d+)\s+slides.*?(\d+)\s+runnable examples/s);
  if (!m) {
    console.error(`✗ no encontre la linea de numeros en ${TARJETA} (¿cambio la redaccion?)`);
    process.exit(1);
  }
  return { slides: +m[2], ejemplos: +m[3] };
}

if (process.argv.includes('--check')) {
  const dice = await numerosDelHtml();
  const hoy = await inventario();
  let mal = 0;

  for (const k of ['slides', 'ejemplos']) {
    if (dice[k] !== hoy[k]) {
      console.error(`✗ ${TARJETA} dice ${dice[k]} ${k} y el curso tiene ${hoy[k]}: edita ${TARJETA} y corre node tools/social-card.mjs`);
      mal++;
    }
  }

  const sello = await readFile(SELLO, 'utf8').then(JSON.parse).catch(() => null);
  if (!sello) {
    console.error(`✗ falta ${SELLO}: docs/social-card.png no tiene sello, asi que no hay forma de saber de que version del HTML salio — corre node tools/social-card.mjs`);
    mal++;
  } else {
    for (const k of ['slides', 'ejemplos']) {
      if (sello[k] !== dice[k]) {
        console.error(`✗ docs/social-card.png se rindio con ${sello[k]} ${k} y ${TARJETA} dice ${dice[k]}: corre node tools/social-card.mjs`);
        mal++;
      }
    }
  }

  if (mal) process.exit(1);
  console.log(`✓ social-card al dia (${dice.slides} slides, ${dice.ejemplos} ejemplos)`);
  process.exit(0);
}

// De a una: dos Chrome headless a la vez en un runner de 2 cores se pelean.
for (const [src, out, tam] of PIEZAS) await rendir(src, out, tam);

// El sello: con que numeros se rindio la tarjeta que se sube a GitHub.
await writeFile(SELLO, JSON.stringify(await numerosDelHtml(), null, 2) + '\n');
