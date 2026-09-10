// Las capturas del deck que usan el README, la landing y las tarjetas de
// Twitter/OpenGraph: la portada en los dos idiomas y una slide de codigo. Existian a mano, y por eso envejecieron: la portada seguia
// anunciando seis dias, y un contador de slides de varias fases atras.
// Una imagen no la mira ningun --check, asi que la unica defensa es que se
// regenere con el resto del build.
//
// El deck es markdown que reveal renderiza en el navegador -- index.html no
// tiene ni un <pre> --, asi que no alcanza con leer el HTML: hay que abrirlo.
// Va en dos pasos por eso mismo:
//   1. una sonda navega el deck y dice en que indice cae cada captura
//   2. una corrida de Chrome por imagen, sobre una copia que se posiciona sola
// El paso 2 NO usa el hash de la URL: al cargar con #/16 Chrome dispara la
// captura antes de que reveal termine de renderizar el markdown de esa seccion,
// y sale un PNG en blanco de 449 bytes.
//
//   node tools/capturas.mjs           regenera las dos (necesita Chrome)
//   node tools/capturas.mjs --check    falla si quedaron viejas (NO necesita Chrome)
//
// El --check no compara pixeles: el mismo deck renderizado en macOS y en el Linux
// del CI no da el mismo PNG, asi que eso seria rojo permanente. Compara los
// NUMEROS QUE LA IMAGEN MUESTRA -- "DIA 1..8" y "1 / 400" salen del deck --
// contra tools/inventario.mjs, que los cuenta del filesystem. Es exactamente el
// caso que se escapo: la portada anunciaba seis dias y un total de slides de tres
// fases atras. (El numero viejo no se escribe aca: lint-refs no distingue una
// cita historica de un dato vivo, y con razon.)
import { spawn } from 'node:child_process';
import { writeFile, unlink, readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { chrome, BASE } from './chrome.mjs';
import { SALIDAS } from './i18n.mjs';
import { inventario } from './inventario.mjs';

const CHECK = process.argv.includes('--check');
const DECK = SALIDAS.es.html;

// 1200x630 es lo que piden summary_large_image y OpenGraph. El deck es 1100x700,
// asi que reveal centra y quedan dos bandas del fondo del tema: es lo que hay que
// hacer igual, recortar una slide para llenar el ancho le come el titulo.
const PORTADA = { out: 'docs/portada.png', w: 1200, h: 630, i: 0, limpia: true };
// La misma, del deck en ingles. El README en ingles la pone de hero y la landing
// en ingles la declara como og:image: hasta que existio esta, el lector en
// ingles abria el repo y lo primero que veia era una portada que decia
// "Introduccion a UVM" y "DIA 1..8".
const PORTADA_EN = { ...PORTADA, out: 'docs/en/portada.png', deck: SALIDAS.en.html };

// La portada es la og:image: la que sale en Twitter, LinkedIn, Slack y el rich
// result de Google. Ahi el chrome del deck -- la hamburguesa, el toggle ES/EN,
// la cinta "Machete UVM" y la flecha de siguiente -- no es informacion, es
// mugre: son controles de una pagina que el que mira la tarjeta todavia no
// abrio, y la cinta amarilla se come la esquina superior derecha. Se esconden
// SOLO en la copia temporal que se captura; el deck de verdad no se toca.
//
// El numero de slide ("1 / 400") se deja a proposito: no es un control, es el
// tamano del curso, y es uno de los dos numeros que el --check de aca abajo
// promete que la imagen muestra.
//
// docs/slide-codigo.png va CON el chrome, y es deliberado: esa imagen no es una
// tarjeta social, es la captura que el README y la landing usan para contestar
// "¿que es esto?". El indice, el selector de idioma y la cinta del machete son
// justamente las tres cosas que dicen que es un deck navegable y bilingue con
// una chuleta adentro, y no un PDF. Ademas ahi no tapan nada: el bloque de
// codigo y las viñetas quedan enteros debajo.
const SIN_CHROME = `
<style>
  #indice-btn, #idioma, .forkit, .forkit-curtain, .reveal .controls { display: none !important; }
</style>`;
// La de codigo muestra de que se trata el curso mejor que cualquier parrafo.
// El indice NO se hardcodea: se busca la primera slide con codigo resaltado.
// 1400x891 es 1100x700 escalado: la relacion de diseno del deck, que es la unica
// que tools/overflow.mjs garantiza sin recortes. Con 1400x900 el bloque de
// codigo se cortaba en la ultima linea.
const CODIGO  = { out: 'docs/slide-codigo.png', w: 1400, h: Math.round(1400 * 700 / 1100) };

const SONDA = `
<pre id="sonda" style="display:none">PENDING</pre>
<script>
(function () {
  var wait = function (ms) { return new Promise(function (r) { setTimeout(r, ms); }); };
  var start = function () {
    if (typeof Reveal === 'undefined' || !Reveal.isReady || !Reveal.isReady()) return setTimeout(start, 50);
    (async function () {
      var total = Reveal.getTotalSlides(), found = null;
      for (var i = 0; i < total && found === null; i++) {
        Reveal.slide(i);
        await wait(30);
        var s = Reveal.getCurrentSlide();
        if (!s) continue;
        var pre = s.querySelector('pre code.hljs, pre code');
        // Una slide de codigo de verdad: resaltada y con cuerpo, no un \`inline\`
        // suelto ni un bloque de tres lineas de shell. Y que ENTRE: los bloques
        // largos tienen scroll propio, que overflow.mjs no mide porque mira la
        // seccion y no el <pre> -- en una captura eso sale como una linea cortada
        // al medio, que parece un bug del deck.
        // El que recorta es el <code>, no el <pre> que lo envuelve.
        var entra = pre && pre.scrollHeight - pre.clientHeight <= 2;
        if (pre && entra && pre.textContent.split('\\n').length >= 8) {
          var idx = Reveal.getIndices();
          found = { i: i, h: idx.h, v: idx.v || 0 };
        }
      }
      document.getElementById('sonda').textContent = 'REPORT:' + JSON.stringify({ total: total, code: found });
    })();
  };
  start();
})();
</script>`;

function chromeRun(args) {
  return new Promise((res, rej) => {
    let buf = '';
    const p = spawn(chrome, [...BASE, '--hide-scrollbars', ...args],
      { stdio: ['ignore', 'pipe', 'ignore'] });
    p.stdout.on('data', d => (buf += d));
    p.on('error', rej);
    p.on('close', () => res(buf));
  });
}

// El sello: que tenia el curso cuando se sacaron estas capturas.
const SELLO = 'docs/.capturas.json';
const hoy = await inventario();

if (CHECK) {
  const previo = await readFile(SELLO, 'utf8').then(JSON.parse).catch(() => null);
  if (!previo) {
    console.error(`✗ falta ${SELLO}: corre node tools/capturas.mjs`);
    process.exit(1);
  }
  const distinto = ['slides', 'dias'].filter(k => previo[k] !== hoy[k]);
  if (distinto.length) {
    for (const k of distinto) {
      console.error(`✗ docs/portada.png dice ${previo[k]} ${k} y el curso tiene ${hoy[k]}: corre node tools/capturas.mjs`);
    }
    process.exit(1);
  }
  console.log(`✓ capturas al dia (${hoy.dias} dias, ${hoy.slides} slides)`);
  process.exit(0);
}

// --- 1. donde cae la slide de codigo -----------------------------------------
const tmp = path.join(path.dirname(DECK) || '.', '_capturas.html');
await writeFile(tmp, (await readFile(DECK, 'utf8')).replace('</body>', SONDA + '\n</body>'));
let reporte;
try {
  // La sonda mide con la MISMA ventana con la que se va a capturar: si mide a otra
  // escala, elige una slide cuyo bloque entra a 1600x1000 y se corta a 1400x891.
  const out = await chromeRun([`--window-size=${CODIGO.w},${CODIGO.h}`, '--virtual-time-budget=180000',
    '--dump-dom', `file://${path.resolve(tmp)}`]);
  const m = out.match(/REPORT:(\{.*?\})<\/pre>/s);
  if (!m) throw new Error('no pude leer la sonda (¿Reveal no inicializo?)');
  reporte = JSON.parse(m[1]);
} finally { await unlink(tmp).catch(() => {}); }

if (!reporte.total) { console.error('✗ capturas: el deck no tiene slides'); process.exit(1); }
if (!reporte.code) { console.error('✗ capturas: no encontre ninguna slide con un bloque de codigo'); process.exit(1); }
// Solo el indice lineal: `h` y `v` de reveal no se guardan aca porque `h` ya es
// el alto de la ventana en este objeto, y pisarlo daba --window-size=1400,16.
CODIGO.i = reporte.code.i;

// --- 2. una corrida por imagen -----------------------------------------------
const NAV = n => `
<script>
(function () {
  var start = function () {
    if (typeof Reveal === 'undefined' || !Reveal.isReady || !Reveal.isReady()) return setTimeout(start, 50);
    Reveal.slide(${n});
  };
  start();
})();
</script>`;

for (const c of [PORTADA, PORTADA_EN, CODIGO]) {
  const destino = c.out;
  // Cada captura sale de SU deck: la portada en ingles, del deck en ingles.
  const deck = c.deck ?? DECK;
  const copia = path.join(path.dirname(deck) || '.', `_captura_${path.basename(c.out, '.png')}.html`);
  await writeFile(copia, (await readFile(deck, 'utf8'))
    .replace('</body>', NAV(c.i ?? 0) + (c.limpia ? SIN_CHROME : '') + '\n</body>'));
  try {
    await chromeRun([`--window-size=${c.w},${c.h}`, '--virtual-time-budget=60000',
      `--screenshot=${path.resolve(destino)}`, `file://${path.resolve(copia)}`]);
  } finally { await unlink(copia).catch(() => {}); }
  const s = await stat(destino).catch(() => null);
  // Una captura en blanco pesa ~450 B. Si sale eso, reveal no llego a renderizar.
  if (!s || s.size < 5000) { console.error(`✗ ${c.out}: Chrome no devolvio una imagen usable (${s ? s.size : 0} B)`); process.exit(1); }
}

await writeFile(SELLO, JSON.stringify({ slides: hoy.slides, dias: hoy.dias }, null, 2) + '\n');
console.log(`✓ docs/portada.png  ${PORTADA.w}x${PORTADA.h}  (slide 0 de ${reporte.total})`);
console.log(`✓ ${PORTADA_EN.out}  ${PORTADA_EN.w}x${PORTADA_EN.h}  (la misma, del deck en ingles)`);
console.log(`✓ docs/slide-codigo.png  ${CODIGO.w}x${CODIGO.h}  (slide ${CODIGO.i} de ${reporte.total})`);
