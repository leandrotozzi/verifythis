// dist/slides.md -> .pptx editable via pandoc. El texto queda seleccionable y
// editable; NO reproduce el tema de reveal (para eso esta el PDF).
import { spawn } from 'node:child_process';
import { access, mkdir } from 'node:fs/promises';
import { idiomaDeArgv, SALIDAS } from './i18n.mjs';

const OUT_LANG = SALIDAS[idiomaDeArgv()];
const IN = OUT_LANG.md;
const OUT = OUT_LANG.pptx;
const REF = 'tools/reference.pptx';

try { await access(IN); } catch { console.error(`falta ${IN} — corre primero: npm run build`); process.exit(1); }
await mkdir('dist', { recursive: true });

const args = ['-f', 'markdown', '-t', 'pptx', '--slide-level=0', IN, '-o', OUT];
// plantilla de estilo opcional. Para crear una base editable:
//   pandoc -o tools/reference.pptx --print-default-data-file reference.pptx
try { await access(REF); args.push(`--reference-doc=${REF}`); console.log(`usando ${REF}`); } catch {}

spawn('pandoc', args, { stdio: 'inherit' })
  .on('error', () => { console.error('pandoc no esta instalado: https://pandoc.org/installing.html'); process.exit(1); })
  .on('close', c => { console.log(c === 0 ? `ok: ${OUT}` : `pandoc salio con ${c}`); process.exit(c); });
