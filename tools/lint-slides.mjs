// Lint de slides/<idioma>/*.md: que ninguna slide de concepto quede muda.
//
// Cuatro reglas. Las dos primeras son sobre la misma idea -- una slide con
// codigo y sin una linea de texto es una slide que solo se entiende si el
// instructor esta al lado, y la mitad de la gente que abre este curso no lo
// tiene. Las dos ultimas son de forma: el deck tenia dos voces conviviendo, y
// la de 2019 se reconocia por el nivel de heading y por el subtitulo sin
// italica.
//
//   1. ERROR  slide con {{code:}} y sin ningun bullet ni Note:
//   2. AVISO  {{code:}} sin lines= de mas de MAX_LINEAS lineas
//   3. ERROR  un "### " en una slide -- la convencion es "## titulo" + "#### *sub*",
//             y un h3 se dibuja mas grande que un h4 (unica excepcion: la portada)
//   4. AVISO  un "#### " sin italica -- el subtitulo del curso va en italica ambar
//   5. AVISO  un {{code:}} recortado con lines=. El numero de linea se pudre en
//             silencio cuando el ejemplo crece arriba del bloque; #nombre y los
//             marcadores // cb: no. Exentas las salidas capturadas, que se
//             regeneran y no pueden llevar un marcador adentro.
//
// Los archivos de quiz, agenda y ejercicio estan exentos de la regla 1: ahi el
// texto es la pregunta, y el codigo es el enunciado.
//
// Corre sobre los DOS arboles: una slide muda en ingles es igual de muda.
//
// Uso: node tools/lint-slides.mjs [--avisos-fallan]
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { IDIOMAS, SALIDAS } from './i18n.mjs';
const MAX_LINEAS = 35;
const EXENTOS = /quiz|agenda|ejercicio/;
// La portada es la unica slide con un h1: ahi el subtitulo va en h3 a proposito.
const PORTADA = '000-verify-this.md';
const RE_CODE = /\{\{code:([^}|#]+?)(?:#([\w.-]+))?(?:\|lines=(\d+)-(\d+))?\}\}/g;
// Salidas capturadas: tools/regen-outputs.sh las reescribe enteras, asi que un
// marcador adentro duraria hasta la proxima corrida. Ahi lines= es lo correcto.
const GENERADO = /\.(txt|log|questa)$/;

const errores = [], avisos = [];
const sinNota = new Map();

const ARBOLES = [];
for (const l of IDIOMAS) {
  const dir = SALIDAS[l].slides;
  const fs = await readdir(dir).catch(() => []);
  for (const f of fs.filter(f => f.endsWith('.md')).sort()) ARBOLES.push([dir, f]);
}
for (const [SLIDES_DIR, f] of ARBOLES) {
  const md = await readFile(path.join(SLIDES_DIR, f), 'utf8');
  const exento = EXENTOS.test(f);

  if (f !== PORTADA) {
    for (const m of md.matchAll(/^### +(.+)$/gm)) {
      const n = md.slice(0, m.index).split('\n').length;
      errores.push(`${f}:${n} — "### ${m[1]}": el subtitulo va en #### y en italica`);
    }
  }
  for (const m of md.matchAll(/^#### +(?!\*)(.+)$/gm)) {
    const n = md.slice(0, m.index).split('\n').length;
    avisos.push(`${f}:${n} — "#### ${m[1]}" sin italica`);
  }

  const slides = md.split(/^---$/m);

  for (const [i, s] of slides.entries()) {
    // El subtitulo (#### *...*) es lo que distingue dos slides del mismo
    // seccion, asi que el nombre util es el ultimo heading, no el primero.
    const hs = [...s.matchAll(/^#{1,4} +(.+?)\s*$/gm)].map(m => m[1].replace(/\*/g, ''));
    const titulo = hs.at(-1) ?? `slide ${i + 1}`;
    const donde = `${f}  «${titulo}»`;
    const tieneCodigo = /\{\{code:/.test(s);
    const tieneBullet = /^\s*[-*] /m.test(s);
    const tieneNota = /^Note:$/m.test(s);
    const tieneTabla = /^\|/m.test(s);

    if (tieneCodigo && !exento && !tieneBullet && !tieneNota) {
      errores.push(`${donde} — codigo sin un solo bullet ni Note:`);
    }
    // Dos "Note:" en la misma slide: reveal se queda con todo lo que sigue al
    // primero, asi que la segunda nota no se pierde -- se pega abajo de la
    // primera y nadie se entera. Pasa al reescribir una slide y dejar la vieja.
    if ((s.match(/^Note:$/gm) ?? []).length > 1) {
      errores.push(`${donde} — dos "Note:" en la misma slide`);
    }
    // El conteo por seccion mira TODA slide de concepto, tenga codigo o no:
    // una slide de bullets copiados del libro tampoco se explica sola.
    if (!exento && !tieneNota && (tieneCodigo || tieneBullet || tieneTabla)) {
      sinNota.set(f, (sinNota.get(f) ?? 0) + 1);
    }

    for (const [, r, simbolo, desde, hasta] of s.matchAll(RE_CODE)) {
      const ruta = r.trim();
      // #nombre ya es un recorte, y uno que no se pudre: no aplica ninguna de
      // las dos reglas de abajo.
      if (simbolo) continue;
      if (desde) {
        if (!GENERADO.test(ruta)) avisos.push(`${donde} — ${ruta}|lines=${desde}-${hasta}: los numeros se pudren, usa #nombre o un marcador // cb:`);
        continue;
      }
      const lineas = (await readFile(ruta, 'utf8').catch(() => '')).split('\n');
      if (lineas.length > MAX_LINEAS) avisos.push(`${donde} — ${ruta} entero: ${lineas.length} lineas (max ${MAX_LINEAS} sin recortar)`);
    }
  }
}

for (const a of avisos) console.log('  ! ' + a);
if (avisos.length) console.log(`${avisos.length} aviso(s)\n`);

if (sinNota.size) {
  console.log('slides de concepto sin Note:, por seccion:');
  for (const [f, n] of [...sinNota].sort((a, b) => b[1] - a[1])) console.log(`  ${String(n).padStart(3)}  ${f}`);
  console.log('');
}

if (errores.length) {
  console.error(`✗ ${errores.length} slide(s) de codigo sin texto:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
console.log(`✓ lint de slides: ninguna slide de codigo quedo sin texto`);
if (avisos.length && process.argv.includes('--avisos-fallan')) process.exit(1);
