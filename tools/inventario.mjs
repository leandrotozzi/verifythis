// El inventario del curso: cuantos ejemplos, ejercicios, slides, secciones,
// preguntas, dias, figuras, trampas, bloques de codigo, apendices y recortes
// hay.
//
// UN solo lugar que sabe contar, y ningun lugar que lo escriba a mano. Todo
// sale del filesystem, asi que un ejemplo nuevo, una slide nueva o una pregunta
// nueva se cuentan solas.
//
// Lo usan dos:
//   tools/lint-refs.mjs   verifica que la prosa del repo diga estos numeros
//   npm run inventario    los imprime, para copiar y pegar
//
// Por que verificar y no centralizar: la alternativa era poner {{n:slides}} en
// la prosa y expandirlo en el build, pero README.md, web/index.html,
// CITATION.cff, el Makefile y los workflows NO son generados -- habria que
// generarlos todos, y un README que no se puede leer en crudo es peor que el
// problema que resuelve. Asi la prosa sigue siendo prosa y el que miente falla
// en `npm run check`.
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';

async function archivos(dir, out = []) {
  for (const e of await readdir(dir, { withFileTypes: true })) {
    if (/^(obj_dir|\.uvm|node_modules)$/.test(e.name)) continue;
    const p = path.join(dir, e.name);
    if (e.isDirectory()) await archivos(p, out);
    else out.push(p);
  }
  return out;
}

export async function inventario() {
  // --- ejemplos: un run*.sh es un ejemplo, igual que la lista del Makefile ---
  let ejemplos = 0;
  for (const u of await readdir('code')) {
    if (!/^u\d+$/.test(u)) continue;
    for (const f of await archivos(path.join('code', u)))
      if (/\/run[^/]*\.sh$/.test(f)) ejemplos++;
  }

  // --- ejercicios: un directorio de code/ejercicios/, cada uno con su solucion
  const ejercicios = (await readdir('code/ejercicios', { withFileTypes: true }))
    .filter(e => e.isDirectory()).length;

  // --- slides y secciones: un archivo de slides/ es una seccion, y adentro
  // cada `---` entre lineas en blanco separa una slide de la siguiente ---
  // El inventario cuenta el arbol CANONICO, el castellano: sus numeros son los
  // que la prosa cita. Que tan traducido esta el ingles lo dice lint-i18n.
  const secciones = (await readdir('slides/es')).filter(f => f.endsWith('.md'));
  let slides = 0, preguntas = 0, trampas = 0, apendices = 0;
  for (const f of secciones) {
    const md = await readFile(path.join('slides/es', f), 'utf8');
    slides += 1 + (md.match(/^---$/gm) ?? []).length;
    if (/quiz/.test(f)) {
      preguntas += (md.match(/^- \[x\]/gm) ?? []).length;
    }
    // Las trampas son las filas de las tablas del apendice, sin encabezados.
    if (/apendice-trampas/.test(f))
      trampas += [...md.matchAll(/^\| (?!---|El síntoma)(.+?) \|\s*$/gm)].length;
    // --- apendices: la seccion que se ROTULA como apendice, no la que esta al
    // final. El deck rotula tres y la prosa del repo cuenta una mas en ocho
    // lugares, porque a veces le suma el glosario y a veces no.
    if (/^## (Apéndice|Appendix) ·/.test(md.match(/^## .*$/m)?.[0] ?? '')) apendices++;
  }

  // --- dias: un HTML del libro es un dia del curso ---
  const dias = (await readdir('libro')).filter(f => /^dia\d+\.html$/.test(f)).length;

  // --- figuras: las que figs-print.mjs regenera en paleta clara para el PDF ---
  // Sin las de res/**/en/: son las MISMAS figuras con el texto traducido, no
  // figuras nuevas. Se cuentan una vez, como las slides -- que tambien salen
  // del arbol ES y no se cuentan dos veces por estar traducidas.
  const figuras = (await archivos('res/print'))
    .filter(f => f.endsWith('.svg') && !f.includes('/en/')).length;

  // --- bloques de codigo del deck: los ```...``` de las slides, contando
  // tambien los que build.mjs expande desde {{code:}} ---
  // Y los RECORTES aparte: los {{code:}} solos. "Bloques" tiene dos
  // significados en la prosa --los 216 del deck y los 157 que vienen de code/--
  // y por eso lint-refs no lo puede chequear; con el numero de los recortes
  // expuesto, el que escribe la frase tiene el que necesita.
  let bloques = 0, recortes = 0;
  for (const f of secciones) {
    const md = await readFile(path.join('slides/es', f), 'utf8');
    recortes += (md.match(/\{\{code:/g) ?? []).length;
    bloques += (md.match(/^```/gm) ?? []).length / 2 + (md.match(/\{\{code:/g) ?? []).length;
  }

  return {
    ejemplos, ejercicios, slides, secciones: secciones.length,
    preguntas, dias, figuras, trampas, bloques, apendices, recortes,
  };
}

// El desglose del repaso, dia por dia. Va aparte y no adentro de inventario():
// no es UN numero, asi que no entra en la linea que imprime lint-refs ni se
// puede comparar contra la prosa como los otros once. Lo consume
// tools/contadores.mjs, que lo expone como {{count:preguntas-diaN}}.
export async function preguntasPorDia() {
  const out = {};
  for (const f of (await readdir('slides/es')).filter(f => /quiz/.test(f))) {
    const md = await readFile(path.join('slides/es', f), 'utf8');
    out[Number(f.match(/day(\d+)/)?.[1])] = (md.match(/^- \[x\]/gm) ?? []).length;
  }
  return out;
}

// Lo que NO esta aca, y por que:
//
//   unidades   no es un numero solo: son 8 en los siete dias mas una novena
//              opcional, y la prosa dice las dos cosas. Cambia una vez por
//              decada; que lo cuente una persona.
//   horas      las ~32 salen de una estimacion de 4 min por slide mas los
//              ejercicios, no de contar archivos.
//   paginas    las 440 del PDF solo se saben despues de `npm run pdf`, que
//              tarda minutos y necesita Chrome. Si alguna vez molesta, el lugar
//              de donde sacarlas es tools/pdf.mjs.

if (import.meta.url === `file://${process.argv[1]}`) {
  const inv = await inventario();
  const ancho = Math.max(...Object.keys(inv).map(k => k.length));
  for (const [k, v] of Object.entries(inv))
    console.log(`  ${k.padEnd(ancho)}  ${v}`);
}
