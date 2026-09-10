// Lint de slides/<idioma>/*.md: que ninguna slide de concepto quede muda.
//
// Las dos primeras reglas son sobre la misma idea -- una slide con codigo y
// sin una linea de texto es una slide que solo se entiende si el instructor
// esta al lado, y la mitad de la gente que abre este curso no lo tiene. La 3 y
// la 4 son de forma: el deck tenia dos voces conviviendo, y la de 2019 se
// reconocia por el nivel de heading y por el subtitulo sin italica. De la 5 en
// adelante son las de la revision por clase de error de septiembre 2026, y
// cada una cuenta abajo el caso que la motivo.
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
//   6. ERROR  el sesgo de longitud del banco: la correcta no puede ser la
//             opcion mas larga en mas de 1 de cada 4 preguntas del idioma.
//  6b. ERROR  el sesgo de POSICION del banco: la correcta no puede estar en el
//             medio -- ni primera ni ultima -- en mas de la mitad + dos sigmas.
//   7. ERROR  un recorte que ARRANCA en un token de cierre -- "end else begin",
//             ")", "endcase". Se lee como un pedazo cortado al medio, y el que
//             mira la slide no tiene el archivo al lado para reponerlo. El
//             marcador va ADENTRO del bloque, no arriba. Es la regla que la
//             etapa 2 dio de baja al migrar de lines= a marcadores, y en la
//             revision de septiembre 2026 habia dos recortes asi.
//   8. ERROR  un recorte que ABRE un function/task/covergroup y no muestra su
//             end*. Es la regla 7 por el otro extremo, acotada a los tres
//             bloques que el lenguaje nombra y cierra.
//   9. AVISO  un recorte que arranca ADENTRO de un always que no se ve: el
//             clock y el reset quedan del otro lado del marcador.
//  10. AVISO  un {{code:}} a una extension que la tabla LANG de codigo.mjs no
//             tiene -- sale gris --, y los ```sv / ```bash pegados a mano, que
//             son el mismo lenguaje escrito de dos formas.
//  11. AVISO  un marcador "// cb:" con el comentario que explica el bloque
//             pegado ARRIBA: el comentario queda afuera del recorte.
//  12. AVISO  una seccion de contenido que ninguna agenda nombra.
//  13. ERROR  assert(x.randomize()) adentro de un bloque de codigo, que es la
//             trampa muda nro 8 del propio curso.
//
// Los archivos de quiz, agenda y ejercicio estan exentos de la regla 1: ahi el
// texto es la pregunta, y el codigo es el enunciado. La 6 y la 6b son al reves:
// corren SOLO sobre los quiz. La 12 usa esos mismos exentos como la lista de
// secciones que no van en la agenda (Repaso, Ejercicio, Capstone). Las 7, 8, 9
// y 10 miran bloques de codigo y corren sobre TODOS los archivos, exentos
// incluidos: un recorte colgado en la slide de un ejercicio se lee igual de
// mal. La 11 y la 13 no miran slides: recorren code/ (y la 13, ademas, docs/ y
// res/), porque el bloque que se ve en la slide sale de ahi.
//
// Por que la 6 es un error y no un aviso: en la revision de septiembre 2026 la
// correcta era la mas larga en 37 de las 45 de entonces (82 %), y el banco se publica
// como parcial. Un alumno que no sabe UVM y marca siempre la mas larga sacaba
// 82 %, o sea que el instrumento media longitud de renglon. El sesgo entra sin
// que nadie lo elija: la correcta es la que lleva la matizacion ("Muy poco:
// dice que RTL se ejecuto, no que escenarios de la spec pasaron") y los
// distractores salen cortos y planos. El arreglo es mover la matizacion al "> "
// de la explicacion y darle a un distractor una justificacion plausible y
// falsa. El techo es 1 de cada 4, que es lo que da el azar con cuatro opciones.
//
// La 6b es el mismo instrumento medido por el otro eje, y en la revision de
// septiembre 2026 daba peor que el largo: la correcta estaba en b o en c en 41
// de las 58 (a=8 b=20 c=21 d=9). El que descarta la primera y la ultima y tira
// una moneda entre las dos del medio saca 35 % sin saber UVM, y en el dia 8 --
// las ocho preguntas en b o c -- saca 50 %. Las de los dias 7 y 8, trece,
// las dos tandas mas nuevas, no tienen NI UNA en a ni en d: bajo azar eso es 1
// en 8192, o sea que no es azar, es la mano de quien las escribio escondiendo
// la correcta en el medio. El techo es la mitad mas dos sigmas (36 sobre 58) y
// es global, no por archivo: con entre cinco y diez por dia una posicion vacia
// pasa por azar, y un techo por dia daria falsos positivos. Se arregla dando
// vuelta el orden de los cuatro renglones, sin tocar el contenido.
//
// La 8 es la regla 7 mirada por el final. La 7 dice, con razon, que un recorte
// que termina antes de cerrar se lee como "sigue" -- pero eso vale para el
// codigo suelto, no para un bloque que el lenguaje abre CON NOMBRE y cierra con
// su propio keyword. Los dos casos de la revision: #legs-and-ops abria
// "covergroup zeros_or_ones_on_ops;" y cortaba una linea antes del "coverpoint
// borrow" que seis lugares del curso declaran que existe, sin llegar nunca al
// endgroup; y #hooking-the-cb abria la function end_of_elaboration_phase y
// cortaba justo antes del $display del +CALLBACK_TRACE que la propia slide
// anuncia tres renglones mas abajo. Acotada a function/task/covergroup y
// exceptuando las tres formas que abren sin cerrar nunca -- "pure virtual
// function", 'import "DPI-C" function' y "cover property" -- da 3 hits y los 3
// son recortes cortos. Con class adentro da 24, de los cuales 17 son a
// proposito (una clase abierta para mostrar solo el build_phase), asi que class
// queda afuera.
//
// La 9 es la 7 por el caso simetrico y mas frecuente: el recorte no arranca en
// un "end", arranca en una asignacion suelta que estaba adentro de un always
// que no se ve. #the-pipeline de vtalu_mult.sv son nueve "<=" pelados: en
// pantalla no hay clock, no hay if, no hay reset, y el bullet de la slide habla
// de "cuatro flancos". Solo mira always: adentro de un initial un pedazo se lee
// bien -- es para lo que estan los marcadores -- y exigirlo ahi daba 6 avisos
// sobre recortes correctos (#stimulus-loop, #the-calls, #casting...). Adentro
// de un always no: el encabezado es lo que le da sentido a cada linea de abajo.
//
// La 10 sale de dos {{code:}} que salian grises: el run.sh de la slide de tests
// y el vtalu_golden.c de la de DPI. LANG no tiene .sh ni .c, asi que caen en
// plaintext -- y en la slide de DPI eso es peor que feo: la declaracion
// SystemVerilog va coloreada arriba, el C gris abajo, y el bullet pide
// compararlas letra por letra. Que es un olvido y no una decision lo prueba la
// tabla COMENTARIO de al lado, que si contempla .sh. La segunda mitad de la
// regla es cosmetica y de la misma familia: en las slides conviven ```sv (14) y
// ```systemverilog (76), ```bash (2) y ```sh (18). Las cuatro pintan igual
// porque son alias; se unifica hacia la forma que ya es mayoria.
//
// La 11 es el agujero que la 7 no ve, porque mira el recorte ya expandido y no
// lo que quedo AFUERA. resolver() de codigo.mjs sube por los comentarios
// pegados arriba de una declaracion -- "explican lo que la slide va a mostrar",
// dice el comentario de ahi -- pero la rama del marcador arranca en la linea
// siguiente y nada mas. Resultado: 22 marcadores con el comentario que explica
// el bloque justo arriba, y en siete de esos casos el comentario ES el bullet
// de la slide (el "end_of_elaboration y no build: el driver es nieto del env"
// de inject_test.svh es, palabra por palabra, el bullet 2 de 146-callbacks).
// Acotada a los comentarios que NO arrancan en la linea 1 del archivo quedan
// 12; sin acotar son 22 y entran los encabezados de archivo, que no van adentro
// de ningun recorte. Se cierra moviendo el marcador arriba del comentario, o
// dejando una linea en blanco en el medio si el comentario no es del bloque.
//
// La 12 es la que ataja de raiz una clase entera de error: una seccion que se
// movio de dia y la agenda que se quedo donde estaba. El caso: 190-the-end --
// "El lunes", la despedida, las dos paginas que hay que guardar -- quedo
// adentro del dia 8, que el propio curso declara opcional y posterior al
// cierre, asi que el que hace los siete dias no la ve nunca; y la agenda del
// dia 8 lista tres bloques para un dia de cuatro secciones. Se pide poco: que
// alguna palabra del nombre de la seccion aparezca en algun bullet de la agenda
// de su dia. Se mide sobre los dos arboles y se avisa solo si falla en TODOS:
// la agenda nombra la seccion en prosa traducida ("cierre" es "wrap-up"), y
// exigir el match idioma por idioma daba dos falsos positivos que no son un
// problema de agenda sino de traduccion. Es un aviso y no un error porque el
// match es una heuristica de palabras.
//
// La 13 no es de forma, es la unica que mira lo que el codigo DICE, y esta aca
// porque el caso lo pedia a gritos: el machete -- la carilla que el curso manda
// imprimir y pegar al lado del monitor, en los dos idiomas y en los dos PDF --
// enseñaba "assert(req.randomize());", que es exactamente la trampa muda nro 8
// del propio curso (172-apendice-trampas: "el randomize() no corre con las
// asserts apagadas"), la misma linea que 135-transactions marca con un "// NO"
// al lado de la forma correcta y que el glosario llama "una forma pobre de
// chequear un valor de retorno". En todo code/ no hay uno solo: el machete era
// el unico lugar del repo que lo escribia como si fuera la forma buena. Corre
// sobre bloques de codigo (``` en los .md, <pre> en los .html) y no sobre
// prosa, porque el curso nombra el antipatron a proposito en seis lugares.
//
// Corre sobre los DOS arboles: una slide muda en ingles es igual de muda.
//
// Uso: node tools/lint-slides.mjs [--avisos-fallan]
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { IDIOMAS, SALIDAS } from './i18n.mjs';
import { recortar, LANG } from './codigo.mjs';
const MAX_LINEAS = 35;
const EXENTOS = /quiz|agenda|ejercicio/;
// La portada es la unica slide con un h1: ahi el subtitulo va en h3 a proposito.
const PORTADA = '000-verify-this.md';
const RE_CODE = /\{\{code:([^}|#]+?)(?:#([\w.-]+))?(?:\|lines=(\d+)-(\d+))?\}\}/g;
// Salidas capturadas: tools/regen-outputs.sh las reescribe enteras, asi que un
// marcador adentro duraria hasta la proxima corrida. Ahi lines= es lo correcto.
const GENERADO = /\.(txt|log|questa)$/;
// Regla 7: con que arranque asi ya se lee colgado. No se mira el final: un
// recorte que termina antes de cerrar se lee como "sigue", que es lo normal en
// una slide; uno que EMPIEZA cerrando se lee como un error de recorte.
const COLGADO = /^\s*(end\b|else\b|join|join_any|join_none|\)|\}|`endif|`else|endcase|endgroup|endproperty|endsequence|endfunction|endtask|endclass|endmodule|endinterface|endpackage)/;
// Regla 8. codigo.mjs tiene la tabla entera y no la exporta; aca no hace falta:
// son los tres bloques con nombre en los que un recorte corto se lee como un
// bloque roto. class, module e interface quedan afuera a proposito -- abrirlos
// y mostrar solo un metodo es la forma normal de una slide.
const CIERRA = { function: 'endfunction', task: 'endtask', covergroup: 'endgroup' };
// Las tres formas que escriben el keyword sin abrir bloque. Se miran sobre la
// linea CRUDA: pelar() se come el "DPI-C" junto con el resto de los strings.
const NO_ABRE = /\bpure\s+virtual\b|\bimport\s+"DPI-C"|\bcover\s+property\b/;
// Regla 10. El alias -> la forma que ya es mayoria en las slides.
const ALIAS = { sv: 'systemverilog', bash: 'sh' };
// Un fence de verdad abre linea y no lleva nada mas: el ```ifndef VERILATOR```
// de docs/verilator.md:80 es un codigo inline en el medio de una oracion, y
// contarlo como fence deja el resto del archivo "adentro" de un bloque.
const FENCE = /^```([\w-]*)[ \t]*$/;
const FENCES = new RegExp(FENCE.source, 'gm');
// Regla 11. El comentario de linea por extension, igual que codigo.mjs.
const COMENTARIO = { '.py': '#', '.sh': '#', '.vhd': '--', '.vhdl': '--' };
// Regla 12. Los dos exentos, con su porque:
//   007-el-gancho    -- el gancho de apertura. Nombrarlo en la agenda lo
//                       arruina: la slide vive de que nadie sepa que viene.
//   015-introduccion -- la agenda la llama por el subtitulo ("Que es UVM"), que
//                       es como se la nombra en el curso entero.
const EN_AGENDA = new Set(['007-el-gancho.md', '015-introduccion.md']);
// Regla 13. La forma exacta del antipatron. El "// NO" es como 135-transactions
// lo muestra a proposito, al lado de la forma correcta.
const RANDOMIZE = /assert\s*\(\s*[\w.]*\.?randomize\s*\(/;
const A_PROPOSITO = /\/\/ *NO\b/;
// code/.uvm es la libreria vendorizada y obj_dir es salida de Verilator: no los
// escribe nadie de este repo.
const IGNORAR = /^(obj_dir|\.uvm|node_modules)$/;

const errores = [], avisos = [];
// Sin comentarios de linea ni strings, que es donde viven los keywords de
// mentira. Es lo mismo que hace codigo.mjs antes de contar pares.
const pelar = ls => ls.map(l => l.replace(/\/\/.*$/, '').replace(/"[^"]*"/g, '""'));
const cuantos = (l, re) => (l.match(re) ?? []).length;
const escapar = s => s.replace(/[.*+?^${}()|[\]\\-]/g, '\\$&');
const sinNota = new Map();
// Regla 6, por arbol de idioma: la traduccion tiene sus propios largos.
const sesgo = new Map();
const RE_OPCION = /^- \[([ x])\] (.+?)\s*$/gm;
// Se mide lo que el alumno LEE, no lo que dice el .md: los asteriscos de la
// negrita y los backticks del codigo inline no se ven en la slide.
const largo = t => t.replace(/[`*]/g, '').length;
// Regla 12: archivo -> cuantos arboles lo tienen y en cuantos quedo muda. Se
// avisa solo si falla en todos, asi que un arbol a medio traducir no lo apaga.
const secciones = new Map();
// Sin acentos y sin puntuacion: la agenda escribe "Variables y metodos
// estaticos" y la seccion se llama "Variables estaticas".
const slug = t => t.normalize('NFD').replace(/\p{Diacritic}/gu, '')
  .toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();

const ARBOLES = [];
for (const l of IDIOMAS) {
  const dir = SALIDAS[l].slides;
  const fs = await readdir(dir).catch(() => []);
  for (const f of fs.filter(f => f.endsWith('.md')).sort()) ARBOLES.push([dir, f]);
}
// Regla 12: la agenda vigente mientras se recorre el arbol. Los grupos del
// indice arrancan donde una slide declara id="dayN" (build.mjs:126), y de ahi
// para abajo todo cae en ese dia hasta el proximo id. Se reinicia por arbol:
// el dia 8 del castellano no es la agenda de la portada del ingles.
let agenda = null, elDia = null, arbol = null;
for (const [SLIDES_DIR, f] of ARBOLES) {
  const md = await readFile(path.join(SLIDES_DIR, f), 'utf8');
  const exento = EXENTOS.test(f);

  if (arbol !== SLIDES_DIR) { arbol = SLIDES_DIR; agenda = null; elDia = null; }
  const dia = md.match(/id="(day\d)"/)?.[1];
  if (dia) {
    // Solo los bullets, y sin las Note:. El nombre de la seccion se anuncia en
    // la lista de la agenda; en la nota del instructor no cuenta.
    const visible = md.split(/^---$/m).map(x => x.split(/^Note:$/m)[0]).join('\n');
    agenda = [...visible.matchAll(/^[-*] +(.+)$/gm)].map(m => slug(m[1]));
    elDia = dia;
  } else if (agenda && !exento && !EN_AGENDA.has(f)) {
    // Tres candidatos, porque la agenda nombra a la seccion por cualquiera de
    // los tres: el nombre del archivo (175-cierre -> "cierre"), el "## " y el
    // subtitulo. Los "·" se parten: 171 se llama "Apendice · La caja de
    // herramientas de debug" y la agenda dice solo la segunda mitad.
    const primera = md.split(/^---$/m)[0];
    const candidatos = [
      f.replace(/^\d+[a-z]?-/, '').replace(/\.md$/, ''),
      ...(primera.match(/^## +(.+?)\s*$/m)?.[1] ?? '').split('·'),
      ...(primera.match(/^#### +(.+?)\s*$/m)?.[1] ?? '').split('·'),
    ].map(t => slug(t).split(' ').filter(p => p.length >= 3)).filter(p => p.length);
    // Las palabras del nombre, en orden, adentro de UN bullet.
    const nombrada = candidatos.some(ps => agenda.some(b => new RegExp(ps.map(escapar).join('.*')).test(b)));
    const acc = secciones.get(f) ?? { arboles: 0, mudas: 0, dia: elDia };
    acc.arboles++;
    if (!nombrada) acc.mudas++;
    secciones.set(f, acc);
  }

  // Regla 10, segunda mitad: los fences pegados a mano.
  for (const m of md.matchAll(FENCES)) {
    if (!ALIAS[m[1]]) continue;
    const n = md.slice(0, m.index).split('\n').length;
    avisos.push(`${SLIDES_DIR}/${f}:${n} — \`\`\`${m[1]}: el deck escribe ese lenguaje \`\`\`${ALIAS[m[1]]} (son alias, pintan igual)`);
  }

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

    if (/quiz/.test(f)) {
      const ops = [...s.matchAll(RE_OPCION)];
      if (ops.length) {
        const largos = ops.map(o => largo(o[2]));
        const max = Math.max(...largos);
        const correcta = ops.findIndex(o => o[1] === 'x');
        // La mas larga, y una sola: si dos empatan arriba, elegir por longitud
        // ya no resuelve la pregunta y el tell no paga.
        const esLaMasLarga = largos[correcta] === max && largos.filter(l => l === max).length === 1;
        const acc = sesgo.get(SLIDES_DIR) ?? { total: 0, largas: [], medio: 0, pos: new Map() };
        acc.total++;
        if (esLaMasLarga) acc.largas.push(`${donde} — la correcta mide ${max} y la que le sigue, ${Math.max(...largos.filter((_, i) => i !== correcta))}`);
        // Regla 6b. "En el medio" es ni la primera ni la ultima, asi que la
        // cuenta no depende de que todas las preguntas tengan cuatro opciones.
        // Se guarda ademas el reparto por archivo, que es lo que se mira para
        // arreglarlo: el dia 8 tenia las ocho en b o en c.
        if (correcta > 0 && correcta < ops.length - 1) acc.medio++;
        const p = acc.pos.get(f) ?? [];
        p[correcta] = (p[correcta] ?? 0) + 1;
        acc.pos.set(f, p);
        sesgo.set(SLIDES_DIR, acc);
      }
    }

    for (const [, r, simbolo, desde, hasta] of s.matchAll(RE_CODE)) {
      const ruta = r.trim();
      const cita = ruta + (simbolo ? `#${simbolo}` : '');
      // Regla 10, primera mitad. La tabla LANG es la que decide el lenguaje del
      // bloque, y lo que no esta ahi sale plaintext -- gris, sin avisar.
      if (!LANG[path.extname(ruta).toLowerCase()]) {
        avisos.push(`${donde} — ${ruta} sale gris: ${path.extname(ruta)} no esta en la tabla LANG de tools/codigo.mjs`);
      }
      // Reglas 7, 8 y 9. Corren sobre el recorte expandido, asi que van antes
      // de los dos `continue` de abajo: el caso tipico es justamente un #nombre.
      if (!GENERADO.test(ruta)) {
        const { recorte } = await recortar(ruta, simbolo, desde, hasta).catch(() => ({ recorte: [] }));
        const primera = recorte.find(l => l.trim()) ?? '';
        if (COLGADO.test(primera)) {
          errores.push(`${donde} — ${cita} arranca en "${primera.trim()}": el recorte empieza colgado.`
            + ' El marcador va adentro del bloque, no arriba');
        }
        // Regla 8: el par abre/cierra, contado sobre el recorte pelado.
        const pelado = pelar(recorte);
        for (const [kw, fin] of Object.entries(CIERRA)) {
          const abre = new RegExp(`\\b${kw}\\b`, 'g'), cierra = new RegExp(`\\b${fin}\\b`, 'g');
          const hondo = pelado.reduce((n, l, i) =>
            n + (NO_ABRE.test(recorte[i]) ? 0 : cuantos(l, abre)) - cuantos(l, cierra), 0);
          if (hondo > 0) {
            errores.push(`${donde} — ${cita} abre un ${kw} y no muestra su ${fin}: el bloque se lee sin cerrar.`
              + ` El "// cb: end" va despues del ${fin}`);
          }
        }
        // Regla 9: que hay abierto ARRIBA del marcador y no se ve. Solo aplica
        // a los marcadores; un #nombre arranca en la declaracion, que es
        // justamente lo que se quiere mostrar.
        if (simbolo) {
          const lineas = (await readFile(ruta, 'utf8').catch(() => '')).split('\n');
          const marca = new RegExp(`^\\s*//\\s*cb:\\s*${escapar(simbolo)}\\s*$`);
          const n = lineas.findIndex(l => marca.test(l));
          const pila = [];
          if (n > 0) for (const l of pelar(lineas.slice(0, n))) {
            const kw = l.match(/^\s*(always\w*|initial|final|task|function)\b/)?.[1] ?? 'begin';
            for (const t of l.match(/\bbegin\b|\bend\b/g) ?? []) t === 'begin' ? pila.push(kw) : pila.pop();
          }
          const abierto = pila.find(k => k.startsWith('always'));
          if (abierto) {
            avisos.push(`${donde} — ${cita} arranca adentro de un ${abierto} que el recorte no muestra:`
              + ` el clock y el reset quedan afuera. El marcador va arriba del ${abierto}`);
          }
        }
      }
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

// --- Reglas 11 y 13: lo que pasa del otro lado de la directiva -------------
// Las dos miran los fuentes, no las slides: el bloque que el alumno ve sale de
// code/ y del machete, y ahi es donde se edita.
async function archivos(dir, out = []) {
  for (const e of await readdir(dir, { withFileTypes: true }).catch(() => [])) {
    if (IGNORAR.test(e.name)) continue;
    const p = path.join(dir, e.name);
    if (e.isDirectory()) await archivos(p, out); else out.push(p);
  }
  return out;
}
const FUENTES = await archivos('code');

for (const p of FUENTES) {
  const esc = (COMENTARIO[path.extname(p).toLowerCase()] ?? '//').replace(/[-/]/g, '\\$&');
  const marca = new RegExp(`^\\s*${esc}\\s*cb:\\s*(\\S+)\\s*$`);
  const com = new RegExp(`^\\s*${esc}`);
  const ls = (await readFile(p, 'utf8').catch(() => '')).split('\n');
  ls.forEach((l, i) => {
    const m = marca.exec(l);
    if (!m || m[1] === 'end') return;
    if (i === 0 || !com.test(ls[i - 1]) || marca.test(ls[i - 1])) return;
    let ini = i - 1;
    while (ini > 0 && com.test(ls[ini - 1]) && !marca.test(ls[ini - 1])) ini--;
    // El comentario que arranca en la linea 1 es el encabezado del archivo --
    // que hace el ejemplo, como se corre -- y no tiene por que entrar al
    // recorte. Sin esta excepcion la regla da el doble de hits y la mitad ruido.
    if (ini === 0) return;
    avisos.push(`${p}:${i + 1} — el marcador "cb: ${m[1]}" esta abajo del comentario de ${ini + 1}-${i},`
      + ' que queda afuera del recorte. O el marcador va arriba del comentario, o hay que separarlos con una linea en blanco');
  });
}

// Regla 13. En los .md cuenta lo que esta adentro de un fence y en los .html lo
// que esta adentro de un <pre>; en code/ cuenta el archivo entero.
for (const p of [...ARBOLES.map(([d, f]) => path.join(d, f)),
  ...(await archivos('docs')).filter(x => x.endsWith('.md')),
  ...(await archivos('res')).filter(x => x.endsWith('.html')),
  ...FUENTES]) {
  const md = p.endsWith('.md'), html = p.endsWith('.html');
  let dentro = !md && !html;
  (await readFile(p, 'utf8').catch(() => '')).split('\n').forEach((l, i) => {
    if (md && FENCE.test(l)) { dentro = !dentro; return; }
    // El <pre> abre linea: el "un <pre> es mas fiel que una tabla" del
    // comentario de CSS de machete.html:60 no abre ningun bloque.
    if (html && /^\s*<pre[\s>]/.test(l)) dentro = true;
    if (dentro && RANDOMIZE.test(l) && !A_PROPOSITO.test(l)) {
      errores.push(`${p}:${i + 1} — "${l.trim()}": es la trampa muda nro 8 del propio curso, y el material la ensena como buena.`
        + ' Va "if (!x.randomize()) `uvm_fatal(...)", o un "// NO" al final de la linea si se muestra a proposito');
    }
    if (html && /<\/pre>/.test(l)) dentro = false;
  });
}

for (const [dir, { total, largas, medio, pos }] of sesgo) {
  // 1 de cada 4 es lo que sale por azar con cuatro opciones: por debajo de ahi,
  // la longitud no dice nada y el banco mide lo que dice medir.
  const techo = Math.floor(total / 4);
  console.log(`sesgo de longitud en ${dir}: la correcta es la mas larga en ${largas.length} de ${total} (techo ${techo})`);
  // Regla 6b: la mitad sale por azar (dos posiciones del medio de cuatro) y el
  // sigma de una binomial de p=1/2 es la raiz de n/4, asi que dos sigmas es la
  // raiz de n. Sobre 58 da 36, que es el numero del informe.
  const techoMedio = Math.floor(total / 2 + Math.sqrt(total));
  console.log(`sesgo de posicion en ${dir}: la correcta esta en el medio en ${medio} de ${total} (techo ${techoMedio})`);
  if (largas.length > techo) {
    errores.push(`${dir} — la correcta es la opcion mas larga en ${largas.length} de ${total} preguntas (el techo es ${techo}):`);
    errores.push(...largas.map(l => '  ' + l));
  }
  if (medio > techoMedio) {
    // El reparto por archivo y no la lista de las 41: lo que se arregla es un
    // dia entero, y el archivo con a=0 y d=0 salta a la vista.
    errores.push(`${dir} — la correcta esta escondida en el medio en ${medio} de ${total} preguntas (el techo es ${techoMedio}).`
      + ' Se da vuelta el orden de las opciones en las slides de quiz, no en el banco generado:');
    for (const [f, p] of pos) {
      errores.push(`  ${f.padEnd(20)} ${[...'abcd'].map((L, i) => `${L}=${p[i] ?? 0}`).join(' ')}`);
    }
  }
}

// Regla 12. Muda es la que no aparece en NINGUNA agenda: si el castellano la
// nombra y el ingles no, el problema es de traduccion y lo mira lint-i18n.
for (const [f, { arboles, mudas, dia }] of secciones) {
  if (mudas < arboles) continue;
  avisos.push(`${f} — ninguna agenda nombra esta seccion, y cae adentro del ${dia}.`
    + ' O va como bullet a la agenda de su dia, o la seccion esta en el dia que no es');
}
console.log('');

for (const a of avisos) console.log('  ! ' + a);
if (avisos.length) console.log(`${avisos.length} aviso(s)\n`);

if (sinNota.size) {
  console.log('slides de concepto sin Note:, por seccion:');
  for (const [f, n] of [...sinNota].sort((a, b) => b[1] - a[1])) console.log(`  ${String(n).padStart(3)}  ${f}`);
  console.log('');
}

if (errores.length) {
  console.error(`✗ el lint de slides encontro esto:`);
  errores.forEach(e => console.error('  ✗ ' + e));
  process.exit(1);
}
console.log(`✓ lint de slides: ninguna slide de codigo quedo sin texto, ningun recorte quedo abierto, y el banco no premia ni la opcion mas larga ni la del medio`);
if (avisos.length && process.argv.includes('--avisos-fallan')) process.exit(1);
