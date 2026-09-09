// Lint de referencias: que el curso no le diga al alumno algo que ya no existe.
//
// Tres reglas, las tres sobre el mismo problema -- una referencia que envejece
// sin que nada la contradiga. Todas se descubrieron el mismo dia: la landing
// mostraba `make ch11`, que dejo de existir cuando los capitulos pasaron a ser
// ocho unidades.
//
//   1. Comandos `make chNN`, que ya no son targets del Makefile.
//   2. Vocabulario viejo: "capitulo N" / "cap. N" en material del alumno.
//      El curso tiene ocho unidades con secciones adentro, sin numeracion.
//   3. Links relativos rotos en los .md (el ROADMAP.md borrado seguia linkeado
//      desde docs/en-que-se-diferencia.md).
//   3b. La generalizacion de la 1: CUALQUIER `make loquesea` escrito como
//      comando (adentro de backticks o de un <code>) que no sea un target del
//      Makefile. La regla 1 solo cachaba `make chNN`, o sea el unico caso que
//      ya habia pasado; esta cacha el proximo -- renombrar code/u7/agents deja
//      muerto el `make u7/agents` que citan los docs, y hasta hoy no avisaba
//      nada. Los targets no se listan a mano: los literales salen del Makefile
//      y los de ejemplo se deducen de los run*.sh, igual que el wildcard.
//   3c. Los links a github.com/<repo>/blob/master/<ruta>: la ruta tiene que
//      existir en el repo. La landing linkea siete docs asi, y renombrar uno da
//      un 404 que solo se ve en produccion. Es lo mismo que la regla 3 pero
//      para links que parecen externos y en realidad apuntan a este repo, o
//      sea los que un link-checker de red tampoco puede validar antes de
//      publicar.
//   4. Numeros de inventario -- cuantos ejemplos, ejercicios, slides, secciones,
//      preguntas, dias, figuras, trampas y bloques de codigo tiene el curso --
//      contra lo que hay en el filesystem (tools/inventario.mjs). Un numero
//      escrito a mano envejece solo, y estos viven repartidos en ~25 lugares
//      entre el README, la landing, el CITATION.cff, los docs y las slides:
//      agregar una slide rompia media docena de frases sin que nada avisara.
//      Se controlan las dos formas, "37 ejemplos" y "catorce soluciones".
//
// Uso: node tools/lint-refs.mjs
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { inventario } from './inventario.mjs';
import { SALIDAS } from './i18n.mjs';

// Las slides de cada idioma se sirven desde donde vive su index.html: las de
// slides/es/ desde la raiz, las de slides/en/ desde en/. Una ruta relativa a
// esa raiz es valida aunque no lo sea desde el .md que la escribe.
const RAIZ_SERVIDA = Object.fromEntries(Object.values(SALIDAS)
  .map(s => [path.normalize(s.slides), path.dirname(s.html)]));

// Se revisa lo que lee el alumno. code/.uvm es la libreria vendorizada y
// node_modules/vendor no son nuestros.
const RAICES = ['slides', 'docs', 'code', 'web', 'tools', '.github'];
// CITATION.cff entra aca y no por extension: es el archivo que cita un
// profesor en un programa de materia, o sea el peor lugar para un numero
// viejo, y era el unico de la fase 12.1 que este lint no miraba.
// README.es.md entra porque es la FUENTE del README: cuando el README pasó a
// ingles, el castellano -- el que se escribe primero -- se quedaba sin chequeo
// de numeros, de links y de targets. El rename abrio el agujero en silencio.
// NOTICE y LICENSE, porque no estaban y por eso el "13 ejercicios" del NOTICE
// sobrevivio la fase 12.1 entera.
const SUELTOS = ['README.md', 'README.es.md', 'CONTRIBUTING.md',
                 'Makefile', 'CITATION.cff', 'NOTICE', 'LICENSE'];
const EXT = new Set(['.md', '.html', '.sv', '.svh', '.sh', '.mjs', '.yml', '.xml']);
const IGNORAR = /(^|\/)(node_modules|vendor|\.git|\.uvm|obj_dir|dist|libro)(\/|$)/;

const RE_MAKE_CH = /\bmake\s+ch\d+/g;
// "24 capitulos" es el libro de Salemi, no el curso: esa referencia es correcta.
const RE_CAP = /\b(cap\.\s*\d|cap[ií]tulos?\s+\d)/gi;
const EXCEPCION_CAP = /24 cap[ií]tulos|tiene 24/i;
// Solo links relativos a archivos del repo: nada de http, anclas ni mailto.
const RE_LINK = /\]\(([^)#?:\s]+?)(?:#[^)]*)?\)/g;
// Un <img> que declara un alto que no es el de la imagen la deforma, y el
// navegador reserva el hueco equivocado. Paso dos veces el mismo dia: la
// og:image de las dos landings decia 1400x875 sobre un archivo de 1200x630, y
// los README declaraban la relacion de la portada anterior. Nadie lo ve en el
// diff -- hay que abrir el PNG.
const RE_IMG = /<img\b[^>]*>/gi;
const ATTR = (t, k) => (t.match(new RegExp(`${k}\\s*=\\s*["']([^"']+)["']`, 'i')) ?? [])[1];

// Un `make X` escrito como COMANDO. El scope importa: en prosa en ingles
// "make sure", "make sense" y "make them" son media docena de falsos positivos
// por archivo, y `sudo apt install git make g++` es otro. Adentro de backticks
// o de un <code>, y en el arranque del comando (o despues de un ; && | $), no
// queda ninguno.
const RE_MAKE = /`([^`\n]+)`|<code[^>]*>([^<]+)<\/code>/g;
const RE_MAKE_CMD = /(?:^|[;&|$]\s*)make\s+([A-Za-z0-9_][A-Za-z0-9_/.-]*)/;
// Los links a ESTE repo, que apuntan a un archivo que tenemos al lado. El slug
// sale del CITATION.cff y no de una constante: es el unico lugar donde ya
// estaba escrito. Los links a repos AJENOS (lowRISC/style-guides, por decir)
// no se pueden chequear asi -- esos son trabajo de `lint-web.mjs --red`.
const REPO = (await readFile('CITATION.cff', 'utf8').catch(() => ''))
  .match(/repository-code:\s*"?https:\/\/github\.com\/([\w.-]+\/[\w.-]+)/)?.[1];
const RE_GH = REPO && new RegExp(String.raw`https://github\.com/${REPO}/(?:blob|raw|tree)/(?:master|main)/([^)"'\`\s>]+)`, 'g');

// Regla 4: los numeros que el curso repite en prosa. El valor real lo cuenta
// tools/inventario.mjs desde el filesystem, no una constante -- una slide nueva
// se cuenta sola. La palabra que sigue al numero es la que lo hace inequivoco.
//
// El sustantivo puede venir separado por un salto de linea (la prosa del repo
// va a 80 columnas), por eso \s+ y no un espacio.
// Los sustantivos van en los dos idiomas: la landing y el README en ingles son
// justo donde un numero viejo no lo ve nadie, porque el que lo escribio lee la
// version en castellano.
const NOMBRES = {
  ejemplos:   /ejemplos|examples/,
  ejercicios: /ejercicios|soluciones|exercises|solutions/,
  slides:     /slides|diapositivas/,
  secciones:  /secciones|sections/,
  preguntas:  /preguntas|questions/,
  // "dias" queda AFUERA por lo mismo que "unidades": no es un numero solo.
  // Son siete de curso mas un octavo OPCIONAL, y la prosa dice las dos cosas
  // segun de que este hablando -- "siete dias de clase" y "ocho dias en el
  // libro" son las dos ciertas. Se sigue contando en el inventario.
  figuras:    /figuras|figures/,
  trampas:    /trampas|traps/,
  // "bloques" queda AFUERA a proposito: el deck tiene 191 bloques de codigo y
  // 151 de ellos vienen de code/, y la prosa usa las dos cuentas segun de que
  // este hablando. Una palabra con dos significados no se puede chequear sin
  // que el lint mienta la mitad de las veces.
};

// Los numeros escritos con letras. Solo de diez para arriba: por debajo, un
// "cuatro fases" o un "cinco slides mas adelante" es un conteo local y no el
// inventario del curso, y no hay forma barata de distinguirlos.
const PALABRAS = {
  diez: 10, once: 11, doce: 12, trece: 13, catorce: 14, quince: 15,
  dieciseis: 16, dieciséis: 16, diecisiete: 17, dieciocho: 18, diecinueve: 19,
  veinte: 20, treinta: 30, cuarenta: 40, cincuenta: 50,
  ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15,
  sixteen: 16, seventeen: 17, eighteen: 18, nineteen: 19,
  twenty: 20, thirty: 30, forty: 40, fifty: 50,
};

// Conteos legitimos que usan las mismas palabras y NO son el inventario.
//   "Dia 6 - 10 preguntas"        el repaso de un dia, no el banco entero
//   "Day 6 - 10 questions"        lo mismo en el banco en ingles
//   "1 de cada 257 soluciones"    el solver SMT, que resuelve otra cosa
//   "cinco slides mas adelante"   una referencia relativa
const LOCALES = /solve|solver|constraint|randomize|z3|LRM|m[aá]s (adelante|atr[aá]s)/i;
// El marcador de dia iba adentro de LOCALES, que mira 45 caracteres a CADA lado.
// Demasiado: la linea del hero del README —"...un dia 8 opcional— · 400 slides ·
// **38 ejemplos**"— tiene un "dia 8" a 35 caracteres, asi que el numero mas
// importante del repo quedaba exento y podia envejecer sin que nadie avisara.
// Lo que hay que proteger es "## Dia 6 · 10 preguntas", donde el marcador va
// PEGADO adelante. Nueve caracteres, no cuarenta y cinco.
// Y un caso aparte, porque solo se reconoce por lo que viene ANTES del numero:
// "los otros doce ejercicios" son los que no son el capstone, no los catorce.
const RELATIVO = /\b(otr[oa]s?|dem[aá]s|primer[oa]s?|[uú]ltim[oa]s?|siguientes|restantes|other|others|first|last|remaining|previous)\s+$/i;
// "Dia 6 · 10 preguntas": el conteo es de ESE dia, no del curso. Solo cuenta si
// el marcador esta inmediatamente antes del numero.
const DIA_ANTES = /\bD(?:[ií]a|ay)\s+\d+\s*[·\-—:|]?\s*$/i;

const errores = [];

async function archivos(dir) {
  const out = [];
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (IGNORAR.test(p)) continue;
    if (e.isDirectory()) out.push(...await archivos(p));
    else if (EXT.has(path.extname(e.name))) out.push(p);
  }
  return out;
}

const existe = async p => stat(p).then(() => true, () => false);

const REAL = await inventario();

// Los targets que el Makefile sabe hacer HOY. Ninguno escrito a mano: los
// literales salen del propio Makefile y los de ejemplo de los run*.sh, que es
// de donde los saca el wildcard. Un ejemplo nuevo entra solo; uno renombrado
// deja en rojo a todos los docs que lo citan, que es el punto.
const makefile = await readFile('Makefile', 'utf8');
const TARGETS = new Set([...makefile.matchAll(/^([a-zA-Z][A-Za-z0-9_-]*):(?!=)/gm)].map(m => m[1]));
for (const f of await archivos('code')) {
  const p = f.split(path.sep).join('/');
  const m = p.match(/^code\/(u\d+\/.+)\/run[^/]*\.sh$/);
  if (!m) continue;
  TARGETS.add(m[1]);                     // make u7/agents
  TARGETS.add(m[1].split('/')[0]);       // make u7
}

// Un numero seguido de un sustantivo del inventario, en digitos o en letras.
// La segunda palabra tambien se prueba: en ingles el adjetivo se mete en el
// medio -- "19 silent traps", "38 running examples" -- y la regla, escrita para
// el castellano, solo miraba la palabra pegada al numero. Se le escapo un
// "19 silent traps" en el README en ingles cuando ya eran 20, con la fila espejo
// en castellano ("20 trampas mudas") correcta al lado.
const RE_INVENTARIO = new RegExp(
  String.raw`\b(\d+|${Object.keys(PALABRAS).join('|')})\s+([a-záéíóúñ]+)(?:\s+([a-záéíóúñ]+))?`, 'gi');

// En la landing los numeros van partidos por tags -- <b>400</b><span>slides</span> --
// y asi se le escapan a la regla 4, que es justo donde mas duele: el numero que
// ve el que llega de Google. Los tags se reemplazan por espacios del MISMO largo,
// para que los indices y por lo tanto los numeros de linea sigan valiendo.
const sinTags = s => s.replace(/<[^>]+>/g, m => ' '.repeat(m.length));

// El tamaño real, leido de la cabecera. PNG y GIF alcanzan: son los dos formatos
// rasterizados del repo. Un SVG no tiene tamaño intrinseco obligatorio, asi que
// no se controla.
async function tamano(f) {
  const b = await readFile(f).catch(() => null);
  if (!b) return null;
  if (b.length > 24 && b.toString('ascii', 1, 4) === 'PNG')
    return [b.readUInt32BE(16), b.readUInt32BE(20)];
  if (b.length > 10 && b.toString('ascii', 0, 3) === 'GIF')
    return [b.readUInt16LE(6), b.readUInt16LE(8)];
  return null;
}

const lista = [...SUELTOS];
for (const r of RAICES) if (await existe(r)) lista.push(...await archivos(r));

for (const f of lista) {
  if (!(await existe(f))) continue;
  const txt = await readFile(f, 'utf8');
  const linea = i => txt.slice(0, i).split('\n').length;

  // Un archivo habla DE las referencias viejas, asi que las contiene a
  // proposito: este lint.
  if (path.basename(f) === 'lint-refs.mjs') continue;

  for (const m of txt.matchAll(RE_MAKE_CH)) {
    errores.push(`${f}:${linea(m.index)} — "${m[0]}" no es un target del Makefile (hoy: make u4/tests)`);
  }

  for (const m of txt.matchAll(RE_MAKE)) {
    const cmd = (m[1] ?? m[2]).match(RE_MAKE_CMD);
    if (!cmd || TARGETS.has(cmd[1])) continue;
    // Las variables del propio Makefile (make regresion EJEMPLO=...) no son targets.
    if (cmd[1].includes('=')) continue;
    // `make chNN` ya lo dice la regla 1, con un mensaje que nombra el cambio.
    if (/^ch\d+$/.test(cmd[1])) continue;
    errores.push(`${f}:${linea(m.index)} — "make ${cmd[1]}" no es un target del Makefile.`
      + ` Hay: ${[...TARGETS].filter(t => !t.includes('/')).sort().join(', ')} y los ejemplos code/uN/<nombre>`);
  }

  for (const m of txt.matchAll(RE_GH)) {
    const ruta = decodeURIComponent(m[1]);
    if (await existe(ruta)) continue;
    errores.push(`${f}:${linea(m.index)} — el link a GitHub apunta a "${ruta}", que no esta en el repo.`
      + ' Un 404 que solo se ve publicado: corregi la ruta o borra el link');
  }

  for (const m of txt.matchAll(RE_CAP)) {
    const ctx = txt.slice(Math.max(0, m.index - 40), m.index + 40);
    if (EXCEPCION_CAP.test(ctx)) continue;
    errores.push(`${f}:${linea(m.index)} — "${m[0].trim()}": el curso tiene unidades y secciones, no capitulos numerados`);
  }

  const plano = path.extname(f) === '.html' ? sinTags(txt) : txt;
  for (const m of plano.matchAll(RE_INVENTARIO)) {
    const n = PALABRAS[m[1].toLowerCase()] ?? Number(m[1]);
    const que = Object.keys(NOMBRES).find(k => NOMBRES[k].test(m[2].toLowerCase()))
             ?? (m[3] && Object.keys(NOMBRES).find(k => NOMBRES[k].test(m[3].toLowerCase())));
    // De diez para abajo casi siempre es un conteo local ("cuatro fases"), y
    // un numero un orden de magnitud afuera no es una cuenta vieja: es otra
    // cosa que usa la misma palabra. "1 de cada 257 soluciones" es el solver
    // SMT, no los catorce ejercicios.
    if (!que || n < 10 || n > 10 * REAL[que] || n === REAL[que]) continue;
    if (LOCALES.test(plano.slice(Math.max(0, m.index - 45), m.index + 45))) continue;
    if (RELATIVO.test(plano.slice(Math.max(0, m.index - 25), m.index))) continue;
    if (DIA_ANTES.test(plano.slice(Math.max(0, m.index - 15), m.index))) continue;
    errores.push(`${f}:${linea(m.index)} — dice "${m[0].replace(/\s+/g, ' ').trim()}" y hoy son ${REAL[que]}`);
  }

  for (const m of txt.matchAll(RE_IMG)) {
    const src = ATTR(m[0], 'src'), w = +ATTR(m[0], 'width'), h = +ATTR(m[0], 'height');
    if (!src || !w || !h || /^(https?:|data:|\/\/)/.test(src)) continue;
    const abs = path.normalize(path.join(path.dirname(f), src));
    const real = await tamano(abs) ?? await tamano(path.normalize(src));
    if (!real) continue;
    // Se compara la RELACION, no los pixeles: escalar una imagen esta bien,
    // deformarla no. Medio punto porcentual de tolerancia por el redondeo.
    const dec = w / h, nat = real[0] / real[1];
    if (Math.abs(dec - nat) / nat > 0.005) {
      errores.push(`${f}:${linea(m.index)} — <img ${src}> declara ${w}x${h} y la imagen es `
        + `${real[0]}x${real[1]}: sale deformada. A ${w} de ancho el alto es ${Math.round(w * real[1] / real[0])}`);
    }
  }

  if (path.extname(f) === '.md') {
    for (const m of txt.matchAll(RE_LINK)) {
      const destino = m[1];
      if (/^(https?:|mailto:|\/\/)/.test(destino)) continue;
      // Las slides se sirven desde la raiz del repo, asi que sus rutas son
      // relativas a la raiz; los docs las escriben relativas a si mismos. Vale
      // cualquiera de las dos. Y un `../../algo` que se escapa del repo es un
      // link relativo de GitHub (../../discussions), no un archivo.
      const servida = RAIZ_SERVIDA[path.normalize(path.dirname(f))];
      const candidatos = [
        path.normalize(path.join(path.dirname(f), destino)),
        path.normalize(destino),
        ...(servida ? [path.normalize(path.join(servida, destino))] : []),
      ];
      // Se descartan los candidatos que se ESCAPAN del repo, no el link entero.
      // Con `.some()` alcanzaba con que UNO se escapara para no chequear nada, y
      // `../algo` siempre genera uno: normalize('../algo') se escapa aunque
      // join('docs/en', '../algo') caiga justo adentro. Resultado: los 55 links
      // `../` de docs/en/ no los miraba nadie -- todo el arbol de docs en ingles.
      // Si NINGUN candidato cae adentro es un link relativo de GitHub
      // (../../discussions), que no es un archivo y no se chequea.
      const dentro = candidatos.filter(c => !c.startsWith('..'));
      if (!dentro.length) continue;
      if (!(await Promise.all(dentro.map(existe))).some(Boolean)) {
        errores.push(`${f}:${linea(m.index)} — link roto: ${destino}`);
      }
    }
  }
}

if (errores.length) {
  console.error(`✗ ${errores.length} referencia(s) que ya no existen:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
console.log('✓ lint de referencias: sin comandos, capitulos ni links colgados');
console.log(`✓ inventario al dia: ${Object.entries(REAL).map(([k, v]) => `${v} ${k}`).join(', ')}`);
