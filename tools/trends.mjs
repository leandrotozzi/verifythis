// Genera res/trends/*.svg (castellano) y res/trends/en/*.svg (ingles) a partir
// de res/trends/data.json.
//
//   node tools/trends.mjs           (o: make figs)
//   node tools/trends.mjs --check   falla si las figuras quedaron viejas
//
// El --check es preventivo y por eso arranca en verde: hoy las ocho figuras
// estan al dia. Existe porque son las unicas del repo que salen de un JSON, y
// figs-print.mjs --check no las cubre: ese compara res/print/trends/ contra
// res/trends/, o sea la copia contra la copia. Si data.json cambia y nadie
// corre 'make figs', las dos coinciden entre si y las dos mienten sobre el
// dato -- la revision por clase de error lo dejo anotado como el unico agujero
// del pipeline de figuras.
//
// Por que existe: las figuras del estudio de Wilson son de Siemens y no se
// pueden redistribuir. Los porcentajes si: son datos. Esto los grafica de cero,
// con la fuente escrita en la propia figura.
//
// Y por que salen las dos versiones de una sola corrida: lo que se lee en la
// figura ({"es": ..., "en": ...}) esta en data.json al lado del numero, que es
// UNO SOLO. Dos data.json serian dos veces los porcentajes, y el dia que se
// actualiza el estudio uno de los dos queda con los del ano pasado.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';

const DIR = 'res/trends';
const CHECK = process.argv.includes('--check');
const { figures } = JSON.parse(readFileSync(path.join(DIR, 'data.json'), 'utf8'));

// Un string suelto vale para los dos idiomas; un objeto elige.
const idiomas = { es: { dir: DIR, pie: s => `Datos: ${s}. Gráfico propio.` },
                  en: { dir: path.join(DIR, 'en'), pie: s => `Data: ${s}. Own chart.` } };

// Paleta del deck (css/course.css): acento ambar, texto claro, fondo transparente.
const ACCENT = '#e7ad52', BAR = '#5b6b7a', TEXT = '#f0f0f0', MUTED = '#8d8d8d';
const W = 900, PAD = 40, LABEL_W = 330, ROW = 62, BAR_H = 30;

const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const leer = f => { try { return readFileSync(f, 'utf8'); } catch { return null; } };

const viejas = [];

for (const [lang, T] of Object.entries(idiomas)) {
  // En --check no se crea ni un directorio: un chequeo que escribe deja de ser
  // un chequeo.
  if (!CHECK) mkdirSync(T.dir, { recursive: true });
  for (const fig of figures) {
    const t = v => (typeof v === 'string' ? v : v[lang]);
    const rows = fig.bars.length;
    const top = 96;
    const plotW = W - PAD - LABEL_W - 90;
    const H = top + rows * ROW + (fig.note ? 90 : 50);
    const out = [];

    out.push(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" font-family="IBM Plex Sans, system-ui, sans-serif">`);
    out.push(`<title>${esc(t(fig.title))} (${fig.year})</title>`);
    out.push(`<text x="${PAD}" y="46" fill="${TEXT}" font-size="34" font-weight="600">${esc(t(fig.title))}</text>`);
    out.push(`<text x="${PAD}" y="76" fill="${MUTED}" font-size="21">${esc(fig.scope ? t(fig.scope) : "IC/ASIC")}, ${fig.year}</text>`);

    fig.bars.forEach((b, i) => {
      const y = top + i * ROW;
      const lines = t(b.label).split('\n');
      const dy = lines.length > 1 ? -8 : 6;
      lines.forEach((l, j) => {
        out.push(`<text x="${PAD + LABEL_W - 16}" y="${y + BAR_H / 2 + dy + j * 24}" fill="${TEXT}" font-size="22" text-anchor="end">${esc(l)}</text>`);
      });
      const w = Math.round((b.value / 100) * plotW);
      out.push(`<rect x="${PAD + LABEL_W}" y="${y}" width="${plotW}" height="${BAR_H}" fill="#ffffff" opacity="0.06" rx="3"/>`);
      out.push(`<rect x="${PAD + LABEL_W}" y="${y}" width="${w}" height="${BAR_H}" fill="${b.highlight ? ACCENT : BAR}" rx="3"/>`);
      out.push(`<text x="${PAD + LABEL_W + w + 12}" y="${y + BAR_H / 2 + 8}" fill="${b.highlight ? ACCENT : TEXT}" font-size="24" font-weight="600">${b.value}%</text>`);
    });

    let y = top + rows * ROW + 18;
    if (fig.note) {
      // El texto largo no entra en una linea: se corta a ojo por ancho de caracter.
      const words = t(fig.note).split(' ');
      const lines = [];
      let line = '';
      for (const w of words) {
        if ((line + ' ' + w).trim().length > 88) { lines.push(line.trim()); line = w; }
        else line += ' ' + w;
      }
      lines.push(line.trim());
      for (const l of lines) {
        out.push(`<text x="${PAD}" y="${y}" fill="${MUTED}" font-size="19">${esc(l)}</text>`);
        y += 24;
      }
      y += 6;
    }
    out.push(`<text x="${PAD}" y="${y}" fill="${MUTED}" font-size="16">${esc(T.pie(t(fig.source)))}</text>`);
    out.push('</svg>');

    const file = path.join(T.dir, fig.file);
    const svg = out.join('\n') + '\n';
    if (CHECK) {
      if (leer(file) !== svg) viejas.push(file);
      continue;
    }
    writeFileSync(file, svg);
    console.log(`${file}  (${rows} barras)`);
  }
}

if (CHECK) {
  if (viejas.length) {
    console.error(`✗ res/trends/ esta desactualizado (${viejas.length} figura(s)) — corre: make figs`);
    console.error('  el dato vive en res/trends/data.json; las figuras salen de ahi');
    viejas.forEach(f => console.error('  ' + f));
    process.exit(1);
  }
  console.log(`✓ res/trends/ al dia (${figures.length * 2} figuras, es + en)`);
}
