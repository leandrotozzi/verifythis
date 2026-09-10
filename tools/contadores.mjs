// La directiva {{count:}}: un numero que sale de contar el repo, no de la memoria
// del que escribio la slide.
//
//   {{count:super-build-phase}}   ->  15
//
// Sale de un defecto concreto. La nota de 080-components decia "grep -rn
// 'super.build_phase' code/ da once llamadas reales --mas tres comentarios--
// sobre 122 build_phase", y encima invitaba al alumno a verificarlo. Cuando se
// midio de nuevo eran quince, seis y 309. El numero no estaba mal cuando se
// escribio: envejecio, y como nadie lo vuelve a contar, envejece para siempre.
// Es el mismo mecanismo que ya resolvio tools/inventario.mjs para los numeros
// globales del curso (cuantos ejemplos, cuantas slides); esto lo extiende a los
// numeros que salen de un grep sobre code/.
//
// POR QUE UN REGISTRO Y NO UN COMANDO. La forma obvia seria {{count:grep -rn
// ...}}, y esta mal: pone shell arbitrario adentro de una slide, o sea que
// traducir un archivo o aceptar un PR de un alumno pasa a ser ejecutar codigo.
// Ademas un comando escrito dos veces --una en la slide ES y otra en la EN--
// vuelve a ser el mismo problema de siempre, el dato en dos lugares. Con nombre,
// los dos idiomas apuntan al MISMO contador y no pueden divergir.
//
// Para agregar uno: una entrada aca, con `que` (que cuenta, en una linea) y el
// filtro. Si la slide pide un nombre que no existe, el build muere.
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';

export const RE_COUNT = /\{\{count:([a-z0-9-]+)\}\}/g;

const FUENTES = { raiz: 'code', ext: ['.sv', '.svh'] };
// code/.uvm es la libreria vendorizada y obj_dir es salida del build: ninguno de
// los dos es "el codigo del curso", que es de lo que hablan las slides.
const IGNORAR = /(^|\/)(\.uvm|obj_dir)(\/|$)/;

const esComentario = l => /^\s*\/\//.test(l);

const CONTADORES = {
  'super-build-phase': {
    que: 'llamadas reales a super.build_phase() en el codigo del curso',
    linea: l => /super\.build_phase/.test(l) && !esComentario(l),
  },
  'super-build-phase-comentarios': {
    que: 'comentarios que hablan de super.build_phase()',
    linea: l => /super\.build_phase/.test(l) && esComentario(l),
  },
  'build-phase': {
    que: 'lineas que nombran build_phase en el codigo del curso',
    linea: l => /build_phase/.test(l),
  },
  'uvm-field-macros': {
    que: 'macros `uvm_field_* en el codigo del curso (la slide dice que no hay ninguna)',
    linea: l => /`uvm_field_/.test(l),
  },
};

async function* archivos(dir) {
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (IGNORAR.test(p)) continue;
    if (e.isDirectory()) yield* archivos(p);
    else if (FUENTES.ext.includes(path.extname(e.name))) yield p;
  }
}

// Se cachea la PROMESA y no el array: con Promise.all, cachear el array deja al
// segundo que entra leyendo uno todavia vacio, y el contador devuelve 0 sin que
// nada falle. Paso.
let cache = null;
function lineas() {
  cache ??= (async () => {
    const out = [];
    for await (const f of archivos(FUENTES.raiz)) out.push(...(await readFile(f, 'utf8')).split('\n'));
    return out;
  })();
  return cache;
}

const valores = new Map();
export async function contar(nombre) {
  if (!CONTADORES[nombre]) throw new Error(`{{count:${nombre}}} -> no existe ese contador (ver tools/contadores.mjs)`);
  if (!valores.has(nombre)) valores.set(nombre, (await lineas()).filter(CONTADORES[nombre].linea).length);
  return valores.get(nombre);
}

// Se llama antes de expandir {{code:}}: el resultado es un numero, no un bloque,
// asi que no interfiere con el fence ni con el separador de slides.
export async function expandirContadores(md) {
  const pedidos = [...new Set([...md.matchAll(RE_COUNT)].map(m => m[1]))];
  const n = Object.fromEntries(await Promise.all(pedidos.map(async p => [p, await contar(p)])));
  return md.replace(RE_COUNT, (_, nombre) => String(n[nombre]));
}

// node tools/contadores.mjs  -> la tabla, para escribir una slide nueva
if (import.meta.url === `file://${process.argv[1]}`) {
  for (const [nombre, c] of Object.entries(CONTADORES)) {
    console.log(String(await contar(nombre)).padStart(5), ' {{count:' + nombre + '}}  — ' + c.que);
  }
}
