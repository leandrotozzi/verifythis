// Los textos que NO salen de slides/: el titulo, el indice, los nombres de los
// dias y la interfaz del deck y del libro. Estan aca y en un solo lugar porque
// build.mjs y libro.mjs los necesitan iguales: si el indice dice "Día 3" y el
// libro dice "Day 3", el mismo curso se llama de dos formas.
//
// Todo lo demas -- el contenido -- vive en slides/<idioma>/ y no pasa por aca.

export const IDIOMAS = ['es', 'en'];

// --lang=xx, con es por defecto: todo lo que ya existia sigue andando sin flags.
export function idiomaDeArgv(argv = process.argv) {
  const a = argv.find(x => x.startsWith('--lang='));
  const l = a ? a.slice('--lang='.length) : 'es';
  if (!IDIOMAS.includes(l)) throw new Error(`idioma desconocido: ${l} (hay ${IDIOMAS.join(', ')})`);
  return l;
}

// Un titulo por dia. El dia 1 lleva dos unidades cortas; del 2 al 7 hay una
// unidad por dia y el titulo del dia es el de la unidad. El 8 es el opcional.
const TITULOS = {
  es: [
    'Por qué se verifica, y el testbench sin UVM',
    'La OOP que UVM da por sabida',
    'Entra UVM',
    'Cómo hablan los componentes',
    'El dato',
    'El testbench reutilizable',
    'La otra mitad, y el cierre',
    'RAL, el golden model y el segundo capstone',
  ],
  en: [
    'Why we verify, and the testbench without UVM',
    'The OOP UVM takes for granted',
    'UVM walks in',
    'How the components talk',
    'The data',
    'The reusable testbench',
    'The other half, and the wrap-up',
    'RAL, the golden model and the second capstone',
  ],
};

export const UI = {
  es: {
    html: 'es',
    titulo: 'Verify This! — Introducción a UVM',
    descripcion: 'Curso introductorio a UVM en español, que corre entero con Verilator. Sin licencias de EDA.',
    cerrarIndice: 'Cerrar el índice',
    abrirIndice: 'Abrir el índice',
    irAlDia: 'Ir al Día',
    // El shell del deck (tools/template.html) es UNO para los dos idiomas, asi
    // que todo lo que se lee ahi tiene que salir de aca. Estaba escrito en
    // castellano adentro del template, y el deck en ingles decia "Índice".
    indiceAria: 'Índice del curso',
    indiceTitulo: 'Índice (tecla I)',
    indiceH: 'Índice',
    macheteTag: 'Machete UVM',
    macheteVisto: 'Ya lo vi >',
    // El selector de idioma. Cada idioma se nombra EN SU PROPIO IDIOMA
    // ("Español", no "Spanish"): el que busca la version en castellano no
    // tiene por que leer ingles. Por lo mismo no hay banderas -- una bandera
    // es un pais, no un idioma, y el ingles no es de ninguno en particular.
    idiomaAria: 'Idioma del curso',
    idiomaCorto: 'ES',
    idiomaNombre: 'Español',
    idiomaTecla: 'Ver el deck en el otro idioma',
    idiomaFalta: 'Esa sección todavía no está en inglés. Te dejamos al principio del deck.',
    otroLang: 'en',
    otroCorto: 'EN',
    otroNombre: 'English',
    otroHref: 'en/index.html',
    otroTitulo: 'See this deck in English (key L)',
    dia: n => `Día ${n}`,
    inicio: 'Inicio',
    opcional: 'opcional',
    titulos: TITULOS.es,
    libroTitulo: n => `Día ${n} · ${TITULOS.es[n - 1]} — Verify This! · Curso de UVM en español`,
    libroDescripcion: n => `Día ${n} del curso de UVM en español, para leer de corrido: las slides con las notas del instructor adentro del texto y el código completo.`,
    libroMarca: '· el curso para leer',
    libroBajada: `Las mismas slides del deck, con <strong>las notas del
  instructor adentro del texto</strong> y el código completo. Si estás haciendo
  el curso solo, empezá por acá y tené el deck al lado para los repasos.`,
    libroAlDeck: 'ver esta slide en el deck &rsaquo;',
    libroSitio: 'Sitio del curso',
    libroGithub: 'Código en GitHub',
    quizAyuda: 'Elegí una opción para ver la respuesta',
    archivoDia: n => `dia${n}.html`,
    // El encabezado del banco de examen, que build.mjs genera desde los quizzes.
    bancoTitulo: 'Banco de examen',
    bancoIntro: (n, docentes) => `Las **${n} preguntas de repaso** del curso, sin la respuesta
marcada — que es lo único que separa un repaso en clase de un parcial. Salen de
las mismas \`slides/*quiz*.md\` que el deck, así que no hay dos versiones de una
pregunta.

La **clave está al final**, con el porqué de cada una: es lo que se necesita
para corregir sin volver a buscar la slide.

Cómo se usa, y qué evaluar en cada parcial: **[\`para-docentes.md\`](${docentes})**.

> El curso es **CC BY 4.0**: se puede imprimir, cortar, reordenar y tomar como
> examen propio. Lo único que se pide es citar la fuente.`,
    bancoDia: (d, n) => `## Día ${d} · ${n} preguntas`,
    bancoClave: 'Clave',
    bancoCols: '| # | Día | Tema | Correcta | Por qué |',
    // El apendice de trampas, que build.mjs arma con las filas de la slide.
    // La primera celda de trampasCols es ademas la que el parser usa para
    // saltear el encabezado de cada tabla, asi que las dos tienen que decir lo
    // mismo que la slide.
    trampasTitulo: n => `Las ${n} trampas mudas de UVM`,
    trampasIntro: `Todo lo que **compila, corre y miente**: los errores de un testbench UVM que no
dan un warning, no dejan la regresión en rojo, y se descubren semanas después —
o no se descubren.

Es el apéndice del día 7 de [*Verify This!*](https://leandrotozzi.github.io/verifythis/),
un curso de UVM en español que corre entero con **Verilator**, sin licencias de
EDA. Está acá afuera del deck porque es la página que uno busca a las tres de la
mañana, y una diapositiva no se puede googlear.

> **En verificación el error caro no es el que rompe, es el que miente.** Un
> error de compilación cuesta dos minutos; un testbench que pasa midiendo lo que
> no es cuesta un tape-out.`,
    trampasCols: '| El síntoma | La causa | Cómo se ataja | Sección |',
    trampasPerillas: `## Las siete perillas de debug

Cuál mirar según el síntoma está en el otro apéndice del curso, *La caja de
herramientas de debug*: se lee en
[\`libro/dia7.html\`](https://leandrotozzi.github.io/verifythis/libro/dia7.html#cuál-usar-según-el-síntoma).

| Flag | Para qué |
| --- | --- |
| \`+UVM_VERBOSITY=UVM_HIGH\` | prender los mensajes de debug que ya están escritos |
| \`+UVM_CONFIG_DB_TRACE\` | quién puso y quién leyó cada entrada del \`config_db\` |
| \`+UVM_OBJECTION_TRACE\` | quién levantó y quién bajó cada objection |
| \`+UVM_TIMEOUT=5ms\` | cortar una simulación colgada y ver dónde quedó |
| \`print_topology()\` | el árbol de componentes que UVM armó **de verdad** |
| \`--assert\` | sin este flag las properties concurrentes no se evalúan |
| \`--trace\` + GTKWave | cuando ninguna de las seis anteriores alcanza |`,
    trampasCierre: `El curso es **CC BY 4.0**. Código, ejemplos y el capstone:
**[github.com/leandrotozzi/verifythis](https://github.com/leandrotozzi/verifythis)**`,
  },
  en: {
    html: 'en',
    titulo: 'Verify This! — Introduction to UVM',
    descripcion: 'An introductory UVM course that runs end to end on Verilator. No EDA licences.',
    cerrarIndice: 'Close the index',
    abrirIndice: 'Open the index',
    irAlDia: 'Go to Day',
    indiceAria: 'Course index',
    indiceTitulo: 'Index (key I)',
    indiceH: 'Index',
    macheteTag: 'UVM cheat sheet',
    macheteVisto: 'Got it >',
    idiomaAria: 'Course language',
    idiomaCorto: 'EN',
    idiomaNombre: 'English',
    idiomaTecla: 'See the deck in the other language',
    idiomaFalta: 'That section is not in Spanish yet. We left you at the start of the deck.',
    otroLang: 'es',
    otroCorto: 'ES',
    otroNombre: 'Español',
    otroHref: '../index.html',
    otroTitulo: 'Ver este deck en castellano (tecla L)',
    dia: n => `Day ${n}`,
    inicio: 'Start',
    opcional: 'optional',
    titulos: TITULOS.en,
    libroTitulo: n => `Day ${n} · ${TITULOS.en[n - 1]} — Verify This! · A UVM course`,
    libroDescripcion: n => `Day ${n} of the UVM course, to read straight through: the slides with the instructor notes inside the text and the complete code.`,
    libroMarca: '· the course to read',
    libroBajada: `The same slides as the deck, with <strong>the instructor notes
  inside the text</strong> and the complete code. If you are taking the course on
  your own, start here and keep the deck alongside for the reviews.`,
    libroAlDeck: 'see this slide in the deck &rsaquo;',
    libroSitio: 'Course site',
    libroGithub: 'Code on GitHub',
    quizAyuda: 'Pick an option to see the answer',
    archivoDia: n => `day${n}.html`,
    bancoTitulo: 'Exam bank',
    bancoIntro: (n, docentes) => `The **${n} review questions** of the course, without the answer
marked — which is the only thing that separates an in-class review from an exam. They come from
the same \`slides/*quiz*.md\` as the deck, so there are never two versions of one
question.

The **key is at the end**, with the reason for each one: it is what you need
in order to grade without going back to look for the slide.

How to use it, and what to assess in each midterm: **[\`para-docentes.md\`](${docentes})** (in Spanish).

> The course is **CC BY 4.0**: it can be printed, cut up, reordered and given as
> your own exam. The only thing asked is that you cite the source.`,
    bancoDia: (d, n) => `## Day ${d} · ${n} questions`,
    bancoClave: 'Key',
    bancoCols: '| # | Day | Topic | Correct | Why |',
    trampasTitulo: n => `The ${n} silent traps of UVM`,
    trampasIntro: `Everything that **compiles, runs and lies**: the mistakes of a UVM testbench that
give no warning, do not leave the regression in red, and get discovered weeks later —
or do not get discovered at all.

It is the day 7 appendix of [*Verify This!*](https://leandrotozzi.github.io/verifythis/en/),
a UVM course that runs end to end on **Verilator**, with no EDA
licences. It is out here outside the deck because it is the page you look for at three in the
morning, and a slide cannot be googled.

> **In verification the expensive mistake is not the one that breaks, it is the one that lies.** A
> compilation error costs two minutes; a testbench that passes measuring the wrong
> thing costs a tape-out.`,
    trampasCols: '| The symptom | The cause | How to head it off | Section |',
    trampasPerillas: `## The seven debug knobs

Which one to look at according to the symptom is in the other appendix of the course, *The debug
toolbox*: it is read in
[\`en/libro/day7.html\`](https://leandrotozzi.github.io/verifythis/en/libro/day7.html#which-one-to-use-according-to-the-symptom).

| Flag | What for |
| --- | --- |
| \`+UVM_VERBOSITY=UVM_HIGH\` | switch on the debug messages that are already written |
| \`+UVM_CONFIG_DB_TRACE\` | who put and who read every entry of the \`config_db\` |
| \`+UVM_OBJECTION_TRACE\` | who raised and who dropped every objection |
| \`+UVM_TIMEOUT=5ms\` | cut off a hung simulation and see where it got stuck |
| \`print_topology()\` | the component tree UVM **actually** built |
| \`--assert\` | without this flag the concurrent properties do not get evaluated |
| \`--trace\` + GTKWave | when none of the six above is enough |`,
    trampasCierre: `The course is **CC BY 4.0**. Code, examples and the capstone:
**[github.com/leandrotozzi/verifythis](https://github.com/leandrotozzi/verifythis)**`,
  },
};

// El indice del deck se agrupa por estos ids, que las slides declaran. Sale de
// UI para que "Día 8 · opcional" y "Day 8 · optional" no se escriban dos veces.
export function grupos(lang) {
  const t = UI[lang];
  const g = { portada: t.inicio };
  for (let n = 1; n <= 8; n++) g[`day${n}`] = n === 8 ? `${t.dia(8)} · ${t.opcional}` : t.dia(n);
  return g;
}

// Los generados del ES viven en la raiz -- se abren con doble clic y estan
// commiteados. Los del EN cuelgan de en/, un nivel mas abajo, asi que sus rutas
// a css/, js/, res/ y vendor/ necesitan un ../ adelante.
export const SALIDAS = {
  es: { slides: 'slides/es', html: 'index.html', md: 'dist/slides.md',
        banco: 'docs/banco-de-examen.md', trampas: 'docs/trampas-mudas.md',
        libro: 'libro', pdf: 'dist/curso-uvm.pdf', pptx: 'dist/curso-uvm.pptx', base: '' },
  en: { slides: 'slides/en', html: 'en/index.html', md: 'dist/slides.en.md',
        banco: 'docs/en/exam-bank.md', trampas: 'docs/en/silent-traps.md',
        libro: 'en/libro', pdf: 'dist/uvm-course.pdf', pptx: 'dist/uvm-course.pptx', base: '../' },
};
