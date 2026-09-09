// Que el PDF diga lo mismo que el deck.
//
// El caso real: el PDF se comia el ultimo bullet de "Como usar este curso" -- y
// en ingles los dos ultimos, porque la traduccion es mas larga. Una slide mas
// alta que una hoja ocupa varias, el template le agranda la .pdf-page para que
// entre, y al paginar Chrome corre el contenido lo suficiente como para que la
// cola quede afuera del alto fijado. La recorta el overflow:hidden y no avisa
// nadie: el PDF se abre, tiene la cantidad de hojas esperada, y le falta texto.
//
// Por que este lint mide el PDF y no la maquetacion: tools/overflow.mjs ya mide
// la maquetacion, y decia que estaba todo bien mientras el PDF perdia bullets.
// Simular la paginacion en el navegador tampoco sirvio -- da falsos positivos,
// probado sobre tres slides que estaban completas. Asi que se controla la
// SALIDA, que es lo unico que no puede mentir. Es la misma leccion que el curso
// da sobre los scoreboards: se verifica lo que sale, no el modelo de lo que
// deberia salir.
//
// Necesita pdftotext (poppler). Sin el se saltea con un aviso, para no romperle
// el build al que no lo tiene; en el CI se instala y ahi si es obligatorio.
//
//   node tools/lint-pdf.mjs              el PDF en castellano
//   node tools/lint-pdf.mjs --lang=en    el PDF en ingles
//   node tools/lint-pdf.mjs --exigir     falla si falta pdftotext (para el CI)
import { readFile, readdir, access } from 'node:fs/promises';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';
import { idiomaDeArgv, SALIDAS } from './i18n.mjs';

const ejecutar = promisify(execFile);
const EXIGIR = process.argv.includes('--exigir');
const LANG = idiomaDeArgv();
const PDF = SALIDAS[LANG].pdf;
const SLIDES = SALIDAS[LANG].slides;

try { await ejecutar('pdftotext', ['-v']); } catch {
  const msg = 'pdftotext no esta instalado (brew install poppler / apt install poppler-utils)';
  if (EXIGIR) { console.error(`✗ lint del PDF: ${msg}`); process.exit(1); }
  console.log(`- lint del PDF: salteado, ${msg}`);
  process.exit(0);
}
try { await access(PDF); } catch {
  console.log(`- lint del PDF: salteado, ${PDF} no existe (corre: node tools/pdf.mjs${LANG === 'en' ? ' --lang=en' : ''})`);
  process.exit(0);
}

// El texto del PDF, normalizado: sin puntuacion y en minusculas. La puntuacion
// se va porque pdftotext no la reproduce igual que el markdown -- las comillas,
// los guiones largos y los separadores de una tabla salen distinto -- y comparar
// eso daba falsos positivos.
// Se comparan solo las letras y los numeros, PEGADOS: pdftotext parte un
// `super`s en "super s" porque el code span termina antes de la ese, y eso daba
// un falso positivo. Sin espacios, las dos formas son la misma cadena. Con
// agujas de ocho palabras el riesgo de que dos bullets distintos coincidan por
// casualidad es nulo.
const normalizar = s => s.toLowerCase().replace(/[^\p{L}\p{N}]+/gu, '');

const { stdout } = await ejecutar('pdftotext', [PDF, '-'], { maxBuffer: 64 * 1024 * 1024 });
const texto = normalizar(stdout);

// Del markdown a la frase que el alumno lee: se sacan las directivas del build,
// el marcado, y los links (queda el texto, que es lo que se imprime).
const aTexto = s => s
  .replace(/\{\{[^}]*\}\}/g, '')
  .replace(/<!--[\s\S]*?-->/g, '')
  .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
  .replace(/<[^>]+>/g, ' ')
  // Se sacan las comillas de codigo y los asteriscos de enfasis, pero NO el
  // guion bajo: es parte de los identificadores (always_ff, uvm_config_db) y
  // sacarlo pegaba las palabras de un lado y no del otro. 185 falsos positivos.
  .replace(/[`*]/g, '');

// Cuantas palabras seguidas tiene que encontrar para dar el bullet por presente.
// Con menos, un fragmento corto matchea texto de OTRA slide y el lint no ve la
// perdida; con mas, cualquier diferencia de guionado lo rompe. Ocho anduvo.
const PALABRAS = 8;

const faltan = [];
let revisados = 0;
for (const f of (await readdir(SLIDES)).filter(f => f.endsWith('.md')).sort()) {
  const md = await readFile(path.join(SLIDES, f), 'utf8');
  md.split('\n---\n').forEach((bloque, i) => {
    const cuerpo = bloque.split('\nNote:')[0];   // las notas del orador no se imprimen
    for (const linea of cuerpo.split('\n')) {
      if (!linea.startsWith('- ')) continue;
      const pal = aTexto(linea.slice(2)).split(/\s+/).filter(Boolean);
      if (pal.length < PALABRAS + 2) continue;   // muy corto para una aguja confiable
      revisados++;
      // Del medio del bullet: el arranque suele repetirse entre slides.
      const aguja = normalizar(pal.slice(1, 1 + PALABRAS).join(''));
      if (!aguja) continue;
      if (!texto.includes(aguja)) faltan.push({ f, i, t: pal.slice(0, 12).join(' ') });
    }
  });
}

if (faltan.length) {
  console.error(`✗ ${path.basename(PDF)}: ${faltan.length} bullet(s) del deck no llegaron al PDF:`);
  for (const x of faltan) {
    console.error(`  ✗ ${SLIDES}/${x.f} (slide ${x.i + 1} del archivo) — "${x.t}…"`);
  }
  console.error('  Una slide que necesita mas de una hoja puede perder la cola al paginar.');
  console.error('  El arreglo es partirla en dos, no agrandarla.');
  process.exit(1);
}
console.log(`✓ lint del PDF: ${path.basename(PDF)} tiene los ${revisados} bullets del deck`);
