// Lint de coherencia: que un mismo dato no diga dos cosas distintas segun donde
// lo leas, y que ninguna referencia dependa de contar slides.
//
// Sale de medir la revision de septiembre contra la de hoy. De ~80 hallazgos
// nuevos, la causa numero uno --unos 25-- fue siempre la misma: el dato esta
// escrito en N lugares (slide ES, slide EN, figura ES, figura EN, machete HTML,
// machete SVG, README, docs, comentario del codigo) y el arreglo entro en N-1.
// Ejemplos reales, todos del mismo dia:
//
//   - la figura EN del polimorfismo ya decia `mojito` y la ES seguia diciendo
//     `gancia`, una clase que no existe en el repo;
//   - la slide, su nota y el codigo decian que los dos agents arrancan PASIVOS,
//     y la figura que se proyecta en esa misma slide decia ACTIVOS;
//   - la slide del dia 3 decia bien que `final_phase` es top-down, y el machete
//     --el papel que el alumno se lleva-- decia bottom-up.
//
// Ninguna de las tres se puede pescar leyendo: hay que mirar los N lugares a la
// vez. Eso es lo que hace la regla 1.
//
//   1. HECHOS. Cada hecho declara una `fuente` --el archivo del repo o de la
//      libreria vendorizada que lo hace verdadero-- y los `lugares` que lo
//      repiten. Si la fuente deja de matchear, el hecho cambio y el lint pide
//      revisar los lugares (es lo que va a pasar el dia que se actualice UVM).
//      Si un lugar no dice lo que la fuente dice, ese lugar quedo viejo.
//
//   2. REFERENCIAS DE DISTANCIA. "dos slides mas adelante", "hace tres slides".
//      Se rompen solas cuando alguien inserta una slide en el medio, y no hay
//      forma de verificarlas leyendo la slide que las escribe. Medido: de las
//      referencias de distancia que habia, se rompieron 4 de 4 --una decia dos
//      y eran cuatro, otra tres y eran seis, otra dos y eran once--. Se
//      reemplazan nombrando la slide, que es lo que ya hacia bien 026.
//      Las de ±1 ("la slide anterior", "la slide siguiente") NO se prohiben: son
//      ~80, rompieron 3 veces, y son la forma natural de hablar apuntando a la
//      pantalla. Prohibirlas seria mucho ruido para poca senal.
//
//   3. CITAS A UN ARCHIVO Y LINEA. El curso cita la libreria por linea en ~34
//      lugares (`uvm_root.svh:1187`, `uvm_reg.svh:2782-2788`). Es lo que le da
//      autoridad, y es lo que nadie puede verificar leyendo la slide. Se chequea
//      que el archivo exista, que la linea exista y --lo que ataja el caso
//      real-- que NO este en blanco: `uvm_callback.svh:744` apuntaba a una linea
//      vacia y el `uvm_report_warning` estaba en la 745, y el rango
//      `uvm_reg_bit_bash_seq.svh:129-135` terminaba dos lineas despues del
//      `case` que dice cerrar. Las dos sobrevivieron dos revisiones.
//
//   4. EL ORDEN DE LAS NUEVE FASES contra uvm_common_phases.svh. Las tablas ya
//      salen de una fuente unica (tools/datos-machete.mjs -> tools/tablas.mjs),
//      pero el `orden` de cada fase sigue escrito a mano ahi; esto lo ata a la
//      clase de la que cada fase extiende, que es quien lo decide.
//
// Uso: node tools/lint-coherencia.mjs
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';

// [ruta, /debe aparecer/] o [ruta, /debe/, /nunca/] o [ruta, null, /nunca/]
const HECHOS = [
  {
    que: 'la tercera clase del ejemplo de polimorfismo se llama `mojito`',
    fuente: ['code/u3/polimorfismo/01-sin-virtual/not_virtual.sv', /class mojito extends trago/],
    lugares: [
      ['res/diagrams/uml-poli.svg', /mojito/, /gancia/i],
      ['res/diagrams/en/uml-poli.svg', /mojito/, /gancia/i],
      ['slides/es/047-polimorfismo.md', /mojito/, /gancia/i],
      ['slides/en/047-polimorfismo.md', /mojito/, /gancia/i],
    ],
  },
  {
    que: 'los dos agents del ejemplo arrancan PASIVOS (el `"*"` del config_db pisa la clave)',
    fuente: ['code/u7/agents/tb_classes/env.svh', /UVM_PASSIVE/],
    lugares: [
      ['res/diagrams/agents_config_scope.svg', /arrancan pasivos/, /arrancan activos/],
      ['res/diagrams/en/agents_config_scope.svg', /start passive/, /start active/],
      ['slides/es/145-agents.md', /los dos arrancan\s+pasivos/, /los dos arrancan\s+activos/],
      ['slides/en/145-agents.md', /both\s+start up passive/, /both\s+start up active/],
    ],
  },
  {
    que: 'el `uvm_error` del scoreboard de reporting esta en la linea 39',
    fuente: ['code/u4/reporting/tb_classes/scoreboard_error.txt', /scoreboard\.svh\(39\)/],
    lugares: [
      ['res/diagrams/UVM-hierarchy.svg', /scoreboard\.svh\(39\)/, /scoreboard\.svh\(3[0-8]\)/],
      ['res/diagrams/en/UVM-hierarchy.svg', /scoreboard\.svh\(39\)/, /scoreboard\.svh\(3[0-8]\)/],
    ],
  },
  {
    que: 'la clase que el ejercicio d3 pide escribir se llama `mult_tester`',
    fuente: ['code/ejercicios/d3/vtalu_pkg.sv', /mult_tester/],
    lugares: [
      ['res/diagrams/env_adaptable_sol.svg', /mult_tester/, /\bmul_tester\b/],
      ['res/diagrams/en/env_adaptable_sol.svg', /mult_tester/, /\bmul_tester\b/],
      ['slides/es/085-env.md', /mult_tester/, /\bmul_tester\b/],
    ],
  },
  {
    que: '`+TOPOLOGY` es un plusarg: seis de las siete perillas de debug lo son',
    fuente: ['code/u7/sequences/tb_classes/base_test.svh', /test\$plusargs\("TOPOLOGY"\)/],
    lugares: [
      ['slides/es/171-apendice-debug.md', /seis de abajo son \*\*plusargs\*\*/i],
      ['res/machete.html', /seis son plusargs/, /cinco son plusargs/],
      ['res/en/machete.html', /six are plusargs/, /five are plusargs/],
      ['res/machete-debug.svg', /\+TOPOLOGY/],
      ['res/en/machete-debug.svg', /\+TOPOLOGY/],
    ],
  },
  {
    que: 'las report actions de UVM son siete (la septima es `UVM_RM_RECORD`)',
    fuente: ['code/.uvm/src/base/uvm_object_globals.svh', /UVM_RM_RECORD\s*=\s*'b1000000/],
    lugares: [
      ['code/u4/reporting/tb_classes/UVM_report_actions.sv', /UVM_RM_RECORD/],
      ['slides/es/088-reporting.md', /siete cosas posibles/, /seis cosas posibles/],
      ['slides/en/088-reporting.md', /seven possible things/, /six possible things/],
    ],
  },
  {
    que: '`+UVM_TIMEOUT` lleva un entero y un `,NO`: `5ms` se lee como 5 ns',
    fuente: ['code/.uvm/src/base/uvm_root.svh', /\+UVM_TIMEOUT=/],
    lugares: [
      ['slides/es/171-apendice-debug.md', /\+UVM_TIMEOUT=5000000,NO/],
      ['slides/es/172-apendice-trampas.md', /\+UVM_TIMEOUT=5000000,NO/],
      ['res/machete-debug.svg', /\+UVM_TIMEOUT=5000000,NO/, /\+UVM_TIMEOUT=\d+ms/],
      ['res/en/machete-debug.svg', /\+UVM_TIMEOUT=5000000,NO/, /\+UVM_TIMEOUT=\d+ms/],
    ],
  },
  {
    que: 'la `uvm_tlm_analysis_fifo` es ilimitada por construccion',
    fuente: ['code/.uvm/src/tlm1/uvm_tlm_fifos.svh', /analysis fifo must be unbounded/],
    lugares: [
      ['slides/es/105-analysis-ports.md', /ilimitada por construcción/],
      ['slides/en/105-analysis-ports.md', /unbounded by construction/],
    ],
  },
  {
    que: "el opcode libre 3'b110 levanta `done` igual, con el result anterior",
    fuente: ['code/vtalu_dut/vtalu_1c.sv', /done_1c <= start && \(op != 3'b000\)/],
    lugares: [
      ['slides/es/020-spec-vtalu.md', /levanta `done` igual/, /el que está libre no hace nada/],
      ['slides/en/020-spec-vtalu.md', /raises `done` all the same/, /the free one does nothing/],
    ],
  },
];

// Referencias que dependen de contar slides. Las de ±1 quedan afuera a proposito
// (ver la cabecera): esto solo caza las que nadie puede verificar leyendo.
const DISTANCIA = [
  /\b(?:una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|\d+)\s+slides?\s+(?:m[áa]s\s+)?(?:adelante|atr[áa]s|despu[ée]s|antes)\b/gi,
  /\bhace\s+(?:una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|\d+)\s+slides?\b/gi,
  /\ben\s+(?:dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|\d+)\s+slides?\b/gi,
  /\b(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+slides?\s+(?:further\s+(?:on|back)|later|back|ago|earlier)\b/gi,
];

const leer = f => readFile(f, 'utf8').catch(() => null);
const errores = [];
const linea = (t, i) => t.slice(0, i).split('\n').length;

// code/.uvm es la libreria vendorizada: la baja `make uvm` y el job de docs del
// CI no la tiene. Sin ella no se puede PROBAR que el hecho siga siendo cierto,
// pero si se puede chequear que los N lugares digan lo mismo entre si -- que es
// la parte que ataja el defecto. Un fuente que falta y NO es de la libreria si
// es un error: alguien borro o movio el archivo que sostiene el hecho.
const VENDORIZADA = /^code\/\.uvm\//;
let sinFuente = 0;

// --- Regla 1: los hechos ---
for (const h of HECHOS) {
  const [rutaF, reF] = h.fuente;
  const fuente = await leer(rutaF);
  if (fuente === null) {
    if (!VENDORIZADA.test(rutaF)) { errores.push(`${rutaF} — la fuente de "${h.que}" no existe`); continue; }
    sinFuente++;
  } else if (!reF.test(fuente)) {
    errores.push(`${rutaF} — cambio el hecho "${h.que}". Revisa los ${h.lugares.length} lugares que lo repiten y actualiza este lint`);
    continue;
  }
  for (const [ruta, debe, nunca] of h.lugares) {
    const t = await leer(ruta);
    if (t === null) { errores.push(`${ruta} — no existe, y "${h.que}" lo nombra`); continue; }
    if (debe && !debe.test(t)) errores.push(`${ruta} — quedo viejo: "${h.que}" (no dice ${debe})`);
    if (nunca && nunca.test(t)) errores.push(`${ruta} — dice lo contrario de "${h.que}" (${nunca})`);
  }
}

// --- Regla 2: las referencias de distancia ---
for (const dir of ['slides/es', 'slides/en']) {
  const { readdir } = await import('node:fs/promises');
  for (const f of (await readdir(dir)).filter(f => f.endsWith('.md'))) {
    const t = await leer(`${dir}/${f}`);
    for (const re of DISTANCIA) {
      for (const m of t.matchAll(re)) {
        errores.push(`${dir}/${f}:${linea(t, m.index)} — referencia de distancia "${m[0].trim()}": nombra la slide, contar se pudre solo`);
      }
    }
  }
}

// --- Regla 3: las citas archivo:linea ---
// Se acepta con o sin backticks y con o sin parte de la ruta: la slide escribe
// `uvm_root.svh:1187` y tambien `seq/uvm_sequencer_base.svh:1258-1267`.
const RE_CITA = /(?:^|[\s`(\/])((?:[\w-]+\/)*[\w-]+\.svh?):(\d+)(?:-(\d+))?/g;
const hayUvm = await stat('code/.uvm').then(() => true, () => false);
let citasSinFuente = 0, citas = 0;

const indice = new Map();
async function* fuentes(dir) {
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (/(^|\/)obj_dir(\/|$)/.test(p)) continue;
    if (e.isDirectory()) yield* fuentes(p); else yield p;
  }
}
for await (const f of fuentes('code')) {
  const b = path.basename(f);
  if (!indice.has(b)) indice.set(b, []);
  indice.get(b).push(f);
}

for (const dir of ['slides/es', 'slides/en', 'docs', 'docs/en']) {
  for (const f of (await readdir(dir)).filter(x => x.endsWith('.md'))) {
    const ruta = `${dir}/${f}`;
    const texto = await leer(ruta);
    for (const m of texto.matchAll(RE_CITA)) {
      const [, ref, desde, hasta] = m;
      citas++;
      const cands = (indice.get(path.basename(ref)) || []).filter(p => p.endsWith(ref));
      if (!cands.length) {
        // Sin la libreria vendorizada no se puede resolver una cita a uvm_*.
        if (!hayUvm) { citasSinFuente++; continue; }
        errores.push(`${ruta}:${linea(texto, m.index)} — cita \`${ref}:${desde}\` y ese archivo no existe`);
        continue;
      }
      if (cands.length > 1) {
        errores.push(`${ruta}:${linea(texto, m.index)} — \`${ref}\` es ambiguo (${cands.length} archivos): agrega parte de la ruta`);
        continue;
      }
      const src = (await leer(cands[0])).split('\n');
      for (const n of [desde, hasta].filter(Boolean).map(Number)) {
        if (n > src.length) errores.push(`${ruta}:${linea(texto, m.index)} — cita ${ref}:${n} y el archivo tiene ${src.length} lineas`);
        else if (!src[n - 1].trim()) errores.push(`${ruta}:${linea(texto, m.index)} — ${ref}:${n} es una linea EN BLANCO: la cita esta corrida`);
      }
    }
  }
}

// --- Regla 4: el orden de las nueve fases, contra la libreria ---
// tools/datos-machete.mjs es la fuente unica de las tablas (tools/tablas.mjs las
// renderiza a los ocho destinos), pero el `orden` de cada fase sigue siendo un
// dato escrito a mano ahi. Esto lo ata a uvm_common_phases.svh, que es quien lo
// decide de verdad: `uvm_final_phase extends uvm_topdown_phase`. Es el hecho que
// el machete impreso tuvo mal durante dos revisiones.
const COMUNES = 'code/.uvm/src/base/uvm_common_phases.svh';
const src = await leer(COMUNES);
if (src === null) {
  sinFuente++;
} else {
  const { FASES } = await import('./datos-machete.mjs');
  const KIND = { topdown: 'top-down', bottomup: 'bottom-up', task: 'un thread c/u' };
  for (const f of FASES) {
    const m = src.match(new RegExp(`^class uvm_${f.fase}_phase extends uvm_(topdown|bottomup|task)_phase`, 'm'));
    if (!m) { errores.push(`${COMUNES} — no encontre \`uvm_${f.fase}_phase\`: cambio la libreria`); continue; }
    if (KIND[m[1]] !== f.orden) {
      errores.push(`tools/datos-machete.mjs — \`${f.fase}\` dice "${f.orden}" y la libreria dice "${KIND[m[1]]}" (${COMUNES})`);
    }
  }
}

if (errores.length) {
  console.error(`✗ ${errores.length} problema(s) de coherencia:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
const lugares = HECHOS.reduce((n, h) => n + h.lugares.length, 0);
console.log(`✓ lint de coherencia: ${HECHOS.length} hechos con ${lugares} lugares al dia, y ninguna referencia de distancia`);
console.log(`✓ lint de citas: ${citas} citas archivo:linea, todas a una linea que existe y no esta en blanco`);
if (sinFuente || citasSinFuente) console.log(`  (${sinFuente} hecho(s) y ${citasSinFuente} cita(s) sin verificar: code/.uvm no esta vendorizada — corre 'make uvm')`);
