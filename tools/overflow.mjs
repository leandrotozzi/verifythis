// Verifica que ninguna slide se vea recortada, en las dos maquetaciones:
//   - pantalla: canvas de 1100x700, una slide a la vez
//   - impresion (?print-pdf): reveal asigna N paginas por slide y .pdf-page
//     tiene overflow:hidden, asi que lo que sobra se PIERDE en el PDF
// Corre sobre los DOS decks: una traduccion mas larga que el original recorta
// una slide que en castellano entraba, y eso no se ve hasta el proyector.
//
// Uso: node tools/overflow.mjs
import { spawn } from 'node:child_process';
import { writeFile, unlink, readFile } from 'node:fs/promises';
import path from 'node:path';
import { chrome } from './chrome.mjs';
import { IDIOMAS, SALIDAS } from './i18n.mjs';

const PROBE = `
<pre id="overflow-report" style="display:none">PENDING</pre>
<script>
(function () {
  var printing = /print-pdf/gi.test(window.location.search);

  var screenRun = async function () {
    var wait = function (ms) { return new Promise(function (r) { setTimeout(r, ms); }); };
    var total = Reveal.getTotalSlides(), bad = [];
    for (var i = 0; i < total; i++) {
      Reveal.slide(i);
      await wait(40);
      var s = Reveal.getCurrentSlide();
      if (!s) continue;
      var over = s.scrollHeight - s.clientHeight, wide = s.scrollWidth - s.clientWidth;
      if (over > 2 || wide > 2) bad.push({ i: i, over: over, wide: wide, t: title(s) });
    }
    return { total: total, bad: bad };
  };

  var printRun = function () {
    var pages = [].slice.call(document.querySelectorAll('.pdf-page')), bad = [];
    pages.forEach(function (p, i) {
      var pr = p.getBoundingClientRect();
      [].forEach.call(p.querySelectorAll('section'), function (s) {
        var sr = s.getBoundingClientRect();
        var over = Math.round(sr.bottom - pr.bottom), wide = Math.round(sr.right - pr.right);
        if (over > 2 || wide > 2) bad.push({ i: i, over: over, wide: wide, t: title(s) });
      });
    });
    return { total: pages.length, bad: bad };
  };

  function title(s) {
    var h = s.querySelector('h1,h2,h3,h4');
    return (h ? h.textContent : '?').replace(/\\s+/g, ' ').trim().slice(0, 46);
  }

  var start = function () {
    if (typeof Reveal === 'undefined' || !Reveal.isReady || !Reveal.isReady()) return setTimeout(start, 50);
    // en print-pdf se espera la senal del template (data-print-layout-ready),
    // no un timeout: el recalculo depende de que carguen las imagenes.
    var when = function (cb) {
      if (!printing) return cb();
      if (document.documentElement.dataset.printLayoutReady) return setTimeout(cb, 100);
      setTimeout(function () { when(cb); }, 100);
    };
    when(function () {
      Promise.resolve(printing ? printRun() : screenRun()).then(function (r) {
        document.getElementById('overflow-report').textContent = 'REPORT:' + JSON.stringify(r);
      });
    });
  };
  start();
})();
</script>`;

async function run(mode, deck) {
  // La copia con la sonda va AL LADO del deck, no en la raiz: el deck en ingles
  // esta en en/ y sus rutas a css/, res/ y vendor/ llevan un ../ adelante.
  const tmp = path.join(path.dirname(deck), `_overflow_${mode}.html`);
  const html = (await readFile(deck, 'utf8')).replace('</body>', PROBE + '\n</body>');
  await writeFile(tmp, html);
  const url = `file://${path.resolve(tmp)}` + (mode === 'print' ? '?print-pdf' : '');
  const out = await new Promise(res => {
    let buf = '';
    const p = spawn(chrome, ['--headless', '--disable-gpu', `--window-size=${process.env.WINDOW || '1600,1000'}`,
      '--virtual-time-budget=180000', '--dump-dom', '--allow-file-access-from-files', url],
      { stdio: ['ignore', 'pipe', 'ignore'] });
    p.stdout.on('data', d => (buf += d));
    p.on('close', () => res(buf));
  });
  await unlink(tmp);
  const m = out.match(/REPORT:(\{.*?\})<\/pre>/s);
  if (!m) throw new Error(`${mode}: no pude leer el reporte (¿Reveal no inicializo?)`);
  return JSON.parse(m[1]);
}

const decks = [];
for (const l of IDIOMAS) {
  const f = SALIDAS[l].html;
  if (await readFile(f, 'utf8').then(() => true).catch(() => false)) decks.push([l, f]);
}

let failed = false;
for (const [lang, deck] of decks)
for (const mode of ['screen', 'print']) {
  const { total, bad } = await run(mode, deck);
  const label = `${lang} ${mode === 'screen' ? 'pantalla ' : 'impresion'}`;
  // 0 paginas no es "todo bien": es que no se midio nada.
  if (!total) { console.error(`✗ ${label}  no encontre slides que medir`); failed = true; continue; }
  if (!bad.length) {
    console.log(`✓ ${label}  ${total} slides, ninguna recortada`);
    continue;
  }
  failed = true;
  console.error(`✗ ${label}  ${bad.length} de ${total} se recortan:`);
  for (const b of bad) {
    const d = [b.over > 2 && `${b.over}px alto`, b.wide > 2 && `${b.wide}px ancho`].filter(Boolean).join(', ');
    console.error(`    slide ${String(b.i).padStart(3)}  ${b.t.padEnd(48)} +${d}`);
  }
}
process.exit(failed ? 1 : 0);
