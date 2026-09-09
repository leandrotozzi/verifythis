// Reporte HTML de una regresion: que bins quedaron abiertos, y que semilla los
// llenaria. Lo llama tools/regresion.sh (o 'make regresion'), que es quien corre
// las semillas y hace el merge.
//
//   node tools/regresion.mjs <dir> <ejemplo>
//
// <dir> tiene que tener regresion.dat (el merge) y un seed.<N>.dat por semilla,
// que es exactamente lo que deja el ejercicio d7-semillas -- este archivo es ese
// ejercicio convertido en herramienta.
//
// El .dat de Verilator es una linea por punto de cobertura:
//
//   C '\x01t\x02covergroup\x01f\x02cov.svh\x01l\x0216\x01bin\x02ctrl\x01h\x02cg.p.ctrl' 3
//
// o sea pares clave/valor separados por \x01 y \x02, y el contador al final. Se
// parsea aca en vez de llamar a `verilator_coverage --report hier` porque lo que
// hace falta es el contador exacto de cada bin, no el porcentaje del padre.
import { readFile, readdir, writeFile } from 'node:fs/promises';
import path from 'node:path';

const [dir, ejemplo = '?'] = process.argv.slice(2);
if (!dir) throw new Error('uso: node tools/regresion.mjs <dir> <ejemplo>');

async function puntos(f) {
  const m = new Map();
  for (const linea of (await readFile(f, 'utf8')).split('\n')) {
    if (!linea.startsWith("C '")) continue;
    const cierre = linea.lastIndexOf("' ");
    const r = Object.fromEntries(
      linea.slice(3, cierre).split('\x01').filter(Boolean).map(p => p.split('\x02')));
    if (r.t !== 'covergroup') continue;
    m.set(r.h, { bin: r.bin ?? r.h, src: `${r.f}:${r.l}`, veces: +linea.slice(cierre + 2) });
  }
  return m;
}

const semillas = (await readdir(dir)).filter(f => /^seed\.\d+\.dat$/.test(f))
  .sort((a, b) => +a.match(/\d+/) - +b.match(/\d+/));
const porSemilla = new Map();
for (const f of semillas) porSemilla.set(+f.match(/\d+/), await puntos(path.join(dir, f)));

const merge = await puntos(path.join(dir, 'regresion.dat'));
const total = merge.size;
const abiertos = [...merge].filter(([, p]) => p.veces === 0);
const cubiertos = total - abiertos.length;

// El aporte de una semilla: los bins que llena ELLA y ninguna otra. Es el numero
// que decide si conviene una semilla mas o un test dirigido -- si todas aportan
// 0, mas semillas no van a mover la aguja y falta estimulo, no suerte.
const filasSemilla = [...porSemilla].map(([s, pts]) => {
  const llena = h => (pts.get(h)?.veces ?? 0) > 0;
  const propios = [...merge.keys()].filter(h =>
    llena(h) && [...porSemilla].every(([o, p]) => o === s || (p.get(h)?.veces ?? 0) === 0));
  return { s, cubre: [...merge.keys()].filter(llena).length, propios: propios.length };
});
const mejor = Math.max(...filasSemilla.map(f => f.cubre));

const esc = t => String(t).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const pct = n => (total ? (100 * n / total).toFixed(1) : '0.0') + ' %';

const html = `<!doctype html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Regresión · ${esc(ejemplo)}</title>
<style>
 :root { color-scheme: light dark; --acc:#c07a10; --ok:#2f8f4e; --off:#b23b3b; }
 body { font:15px/1.55 system-ui,sans-serif; margin:0 auto; padding:2rem 1.2rem; max-width:60rem; }
 h1 { font-size:1.5rem; margin:0 0 .2rem; } h2 { font-size:1.1rem; margin:2rem 0 .6rem; }
 .sub { opacity:.7; margin:0 0 1.5rem; }
 .big { font-size:2.4rem; font-weight:700; color:var(--acc); }
 table { border-collapse:collapse; width:100%; font-size:.92rem; }
 th,td { text-align:left; padding:.35rem .6rem; border-bottom:1px solid rgba(128,128,128,.3); }
 th { font-weight:600; opacity:.75; } td.n { text-align:right; font-variant-numeric:tabular-nums; }
 code { font-family:ui-monospace,monospace; font-size:.9em; }
 .abierto { color:var(--off); } .lleno { color:var(--ok); }
 .nota { opacity:.75; font-size:.9rem; }
 .wrap { overflow-x:auto; }
</style></head><body>

<h1>Regresión · <code>${esc(ejemplo)}</code></h1>
<p class="sub">${semillas.length} semillas · ${new Date().toISOString().slice(0, 10)}</p>

<p><span class="big">${pct(cubiertos)}</span> de cobertura funcional mergeada —
<strong>${cubiertos}</strong> de ${total} bins.
La mejor semilla sola llega a ${pct(mejor)}.</p>
${mejor === cubiertos && filasSemilla.length > 1 ? `<p class="nota"><strong>Las ${filasSemilla.length} semillas cubren exactamente lo mismo.</strong>
No está roto: el estímulo al azar ya llegó a su techo, y a partir de ahí una
semilla más no agrega un bin. Lo que falta es un caso <em>dirigido</em>, o un
<code>ignore_bins</code> para lo que nunca se va a poder llenar. Es la lección
del ejercicio <code>d7-semillas</code>, medida acá.</p>` : ''}

<h2>Bins abiertos · ${abiertos.length}</h2>
${abiertos.length === 0
    ? '<p class="nota">Ninguno: las semillas llenaron todos los bins del plan. Lo que falta ahora no son semillas, son <em>bins</em> — si el covergroup no pregunta algo, la regresión no lo puede contestar.</p>'
    : `<p class="nota">Cada fila es una fila del plan de verificación que nadie ejercitó. Con más semillas no se llenan las que dependen de un caso dirigido.</p>
<div class="wrap"><table>
<tr><th>Bin</th><th>Dónde se declara</th></tr>
${abiertos.map(([h, p]) => `<tr class="abierto"><td><code>${esc(h)}</code></td><td class="nota"><code>${esc(p.src)}</code></td></tr>`).join('\n')}
</table></div>`}

<h2>Qué aportó cada semilla</h2>
<div class="wrap"><table>
<tr><th>Semilla</th><th class="n">Bins que llena</th><th class="n">Sólo ella</th></tr>
${filasSemilla.map(f => `<tr><td><code>SEED=${f.s}</code></td><td class="n">${f.cubre}</td><td class="n">${f.propios || '—'}</td></tr>`).join('\n')}
<tr><td><strong>mergeadas</strong></td><td class="n"><strong>${cubiertos}</strong></td><td class="n">—</td></tr>
</table></div>
<p class="nota">La columna <em>sólo ella</em> es la que decide si conviene una
semilla más: en cero para todas, el estímulo ya llegó hasta donde puede y lo que
falta es un test dirigido.</p>

<h2>Cómo se reproduce</h2>
<pre><code>make regresion EJEMPLO=${esc(ejemplo)} N=${semillas.length}
SEED=${filasSemilla[0]?.s ?? 1} make ${esc(ejemplo)}   <span class="nota"># una sola, para debuggear</span></code></pre>
</body></html>
`;

const out = path.join(dir, 'regresion.html');
await writeFile(out, html);
console.log(`${out}  ${cubiertos}/${total} bins (${abiertos.length} abiertos), ${semillas.length} semillas`);
