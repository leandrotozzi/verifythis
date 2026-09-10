// Lint de los binarios que el sitio ofrece para bajar: el PDF y el PPTX.
//
// Los genera Chrome headless y pandoc adentro del CI, y despues se suben a
// Pages sin que nadie los abra. Un PDF que salio cortado --Chrome se quedo sin
// memoria a la mitad, el step tuvo timeout, el disco del runner se lleno-- pesa
// megas igual, se sube igual, y el `if-no-files-found: warn` del upload no lo
// mira: para el workflow "el archivo esta" y listo. Se descubre cuando alguien
// se baja el curso y ve 90 paginas de 440.
//
// Cinco chequeos, ninguno con un numero magico:
//
//   1. el encabezado (%PDF- / PK\x03\x04): que sea el formato que dice ser
//   2. el cierre (%%EOF / la EOCD del zip): un archivo cortado no lo tiene
//   3. el offset de startxref cae ADENTRO del archivo -- la forma exacta de
//      detectar un PDF truncado, sin heuristicas de tamaño
//   4. tantas paginas como slides tiene el deck (tools/inventario.mjs), y las
//      slides del pptx numeradas 1..N sin agujeros
//   5. las paginas que promete la PROSA son las que tiene el PDF
//
// El 5 salio de un colmo. El boton de descarga de las dos landings dice "440
// pag." y "440 pp.", docs/editar.md dice 440 en la tabla de maquetacion, y el
// PDF tiene 564 en castellano y 557 en ingles -- ademas de que los dos idiomas
// no pueden decir el mismo numero, porque no son el mismo largo. Este lint YA
// contaba el numero bien y lo imprimia en la linea de arriba: solo chequeaba
// que fuera >= slides. El numero estaba a un `if` de distancia.
//
// Se lee con readFile y regex sobre los bytes a proposito: meter una libreria
// de PDF para contar paginas seria mas codigo que el que valida.
//
// Uso: node tools/lint-dist.mjs [--lang=en]
import { readFile, stat } from 'node:fs/promises';
import { inventario } from './inventario.mjs';
import { idiomaDeArgv, SALIDAS } from './i18n.mjs';

const LANG = idiomaDeArgv();
const OUT = SALIDAS[LANG];
const errores = [];
const fail = (f, msg) => errores.push(`${f} — ${msg}`);

const REGENERAR = { pdf: 'npm run pdf', pptx: 'npm run pptx' };

async function leer(f, tipo) {
  const st = await stat(f).catch(() => null);
  if (!st) { fail(f, `no existe: corre \`${REGENERAR[tipo]}\``); return null; }
  if (!st.size) { fail(f, `esta vacio (0 bytes): corre \`${REGENERAR[tipo]}\``); return null; }
  return readFile(f);
}

// --- el PDF ------------------------------------------------------------------
const pdf = await leer(OUT.pdf, 'pdf');
if (pdf) {
  const antes = errores.length;
  const cola = pdf.subarray(-2048).toString('latin1');
  if (!pdf.subarray(0, 5).toString('latin1').startsWith('%PDF-'))
    fail(OUT.pdf, 'no arranca con %PDF-: no es un PDF, o quedo a medio escribir');
  if (!/%%EOF\s*$/.test(cola))
    fail(OUT.pdf, `no termina en %%EOF: quedo truncado (${pdf.length} bytes). Corre \`${REGENERAR.pdf}\` de nuevo`);
  const xref = cola.match(/startxref\s+(\d+)\s+%%EOF/);
  if (xref && +xref[1] >= pdf.length)
    fail(OUT.pdf, `la tabla xref dice estar en el byte ${xref[1]} y el archivo tiene ${pdf.length}: truncado`);

  const crudo = pdf.toString('latin1');
  const paginas = (crudo.match(/\/Type\s*\/Page[^s]/g) ?? []).length;
  const { slides } = await inventario();
  if (paginas < slides)
    fail(OUT.pdf, `${paginas} paginas para ${slides} slides. Cada slide da una pagina o mas`
      + ` (los fragmentos dan varias), asi que menos = la exportacion se corto a la mitad`);
  // --- 5. lo que promete la prosa ---------------------------------------------
  // Los archivos donde ese numero esta escrito a mano, por idioma. docs/editar.md
  // es del arbol castellano (no tiene gemelo en ingles), asi que va con el es.
  // Los otros dos lugares que lo repiten --tools/inventario.mjs y el workflow--
  // son comentarios de codigo y no los lee un alumno.
  //
  // Ojo con como se mide: el numero sale del PDF que hay en dist/, y dist/ esta
  // gitignoreado. Medirlo sin regenerar da el valor del PDF anterior -- asi
  // nacio el "564" que rompio el CI, que era el conteo de un dist/ de tres horas
  // antes. Antes de tocar este numero: `npm run pdf && node tools/pdf.mjs --lang=en`.
  const PROSA = { es: ['web/index.html', 'docs/editar.md'], en: ['web/en/index.html'] };
  // "440 pag." y "440 pp." en el boton del hero; "| **Paginas** | 440 |" en la
  // tabla de docs/editar.md, que escribe el numero DESPUES del sustantivo.
  const RE = /(\d{2,5})\s*(?:pág\.|páginas|pp\.)|[Pp]áginas\s*\**\s*\|\s*(\d{2,5})/g;
  for (const f of PROSA[LANG]) {
    const txt = await readFile(f, 'utf8');
    for (const m of txt.matchAll(RE)) {
      const dice = +(m[1] ?? m[2]);
      if (dice === paginas) continue;
      fail(`${f}:${txt.slice(0, m.index).split('\n').length}`,
        `dice ${dice} paginas y el PDF tiene ${paginas}. Es el numero que el alumno ve antes de`
        + ` bajarse ${(pdf.length / 1e6).toFixed(1)} MB, y cada idioma tiene el suyo`
        + ` (el otro deck no mide lo mismo): editalo a mano ahi, no hay quien lo genere`);
    }
  }

  if (errores.length === antes)
    console.log(`✓ ${OUT.pdf}  ${paginas} paginas para ${slides} slides, ${(pdf.length / 1e6).toFixed(1)} MB`);
}

// --- el PPTX (un zip) --------------------------------------------------------
const pptx = await leer(OUT.pptx, 'pptx');
if (pptx) {
  const antes = errores.length;
  if (pptx.subarray(0, 4).toString('latin1') !== 'PK\x03\x04')
    fail(OUT.pptx, 'no arranca con la firma de un zip (PK): no es un .pptx');
  // La EOCD ("end of central directory") es lo ultimo del zip. Si no esta, el
  // archivo se corto: cualquier lector va a decir "archivo dañado".
  if (!pptx.subarray(-65557).includes(Buffer.from('PK\x05\x06', 'latin1')))
    fail(OUT.pptx, `le falta la EOCD del zip: quedo truncado (${pptx.length} bytes). Corre \`${REGENERAR.pptx}\` de nuevo`);
  const crudo = pptx.toString('latin1');
  if (!crudo.includes('ppt/presentation.xml'))
    fail(OUT.pptx, 'no tiene ppt/presentation.xml: es un zip, pero no una presentacion');
  const ns = [...new Set([...crudo.matchAll(/ppt\/slides\/slide(\d+)\.xml/g)].map(m => +m[1]))].sort((a, b) => a - b);
  if (!ns.length) fail(OUT.pptx, 'no tiene ni una slide adentro');
  // Numeradas 1..N sin agujeros: un zip cortado pierde las ultimas entradas del
  // directorio central y la cuenta se rompe sin que el encabezado cambie.
  else if (ns[0] !== 1 || ns.at(-1) !== ns.length)
    fail(OUT.pptx, `las slides van 1..${ns.at(-1)} pero hay ${ns.length}: faltan del medio, el zip esta incompleto`);
  if (errores.length === antes)
    console.log(`✓ ${OUT.pptx}  ${ns.length} slides, ${(pptx.length / 1e6).toFixed(1)} MB`);
}

if (errores.length) {
  console.error(`✗ ${errores.length} problema(s) en los archivos de dist/:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
