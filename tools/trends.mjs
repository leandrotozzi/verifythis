// Genera res/trends/*.svg (castellano) y res/trends/en/*.svg (ingles) a partir
// de res/trends/data.json.
//
//   node tools/trends.mjs        (o: make figs)
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
const { figures } = JSON.parse(readFileSync(path.join(DIR, 'data.json'), 'utf8'));

// Un string suelto vale para los dos idiomas; un objeto elige.
const idiomas = { es: { dir: DIR, pie: s => `Datos: ${s}. Gráfico propio.` },
                  en: { dir: path.join(DIR, 'en'), pie: s => `Data: ${s}. Own chart.` } };

// Paleta del deck (css/course.css): acento ambar, texto claro, fondo transparente.
const ACCENT = '#e7ad52', BAR = '#5b6b7a', TEXT = '#f0f0f0', MUTED = '#8d8d8d';
const W = 900, PAD = 40, LABEL_W = 330, ROW = 62, BAR_H = 30;

const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

for (const [lang, T] of Object.entries(idiomas)) {
  mkdirSync(T.dir, { recursive: true });
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
    writeFileSync(file, out.join('\n') + '\n');
    console.log(`${file}  (${rows} barras)`);
  }
}
