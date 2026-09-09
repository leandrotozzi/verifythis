# Los docs

Lo que no entra en una slide. Nada de esto hace falta para hacer el curso —el
curso son las slides y `code/`— pero cada uno resuelve algo concreto.

## Para el que está haciendo el curso

| | |
|---|---|
| [`instalar.md`](instalar.md) · [`en/setup.md`](en/setup.md) | **Cómo tener el curso corriendo.** Los cuatro caminos —Codespaces, Docker, Verilator de fuente, WSL 2— más las semillas, las ondas y qué corre el CI. El atajo es `make doctor`, que dice qué falta y con qué comando se instala |
| [`verilator.md`](verilator.md) | **La matriz.** Qué ejemplo corre con qué versión de Verilator, qué falla y por qué. Lo primero que hay que mirar cuando algo no compila. Generado por `make matrix`, y **caduca**: vale para la versión y la fecha que dice arriba |
| [`machete-uvm.pdf`](machete-uvm.pdf) | El machete de una carilla, A4, para imprimir. Sale de `res/machete.html` con `make machete`, que saca tambien la version en ingles (`en/uvm-cheatsheet.pdf`) |
| [`trampas-mudas.md`](trampas-mudas.md) · [`en/silent-traps.md`](en/silent-traps.md) | Las trampas que no dan error: compila, corre, pasa, y no verificó nada. Apéndice del día 7. **Generado desde `slides/`** |
| [`banco-de-examen.md`](banco-de-examen.md) · [`en/exam-bank.md`](en/exam-bank.md) | Todas las preguntas de repaso del curso juntas, con la respuesta. **Generado desde `slides/`** |
| [`uvm-en-la-entrevista.md`](uvm-en-la-entrevista.md) · [`en/uvm-interview.md`](en/uvm-interview.md) | Las preguntas que se hacen en una entrevista de verificación, con la respuesta corta y el link a la sección y al ejemplo que corre |

## Para el que va a dictarlo

| | |
|---|---|
| [`para-docentes.md`](para-docentes.md) · [`en/for-teachers.md`](en/for-teachers.md) | El reparto de horas por día, qué se puede cortar, qué no, y cómo se corrigen los ejercicios |
| [`plan-de-verificacion.md`](plan-de-verificacion.md) | El entregable más profesional de la disciplina y el más barato de escribir. El del VTALU, entero, como ejemplo |

## Para el que va a tocar el repo

| | |
|---|---|
| [`editar.md`](editar.md) | **Editar el curso.** El formato de una slide, los `{{code:}}`, las notas del presentador, los controles de maquetación, la exportación a PDF y PPTX, la tipografía, el árbol del repo y las decisiones de diseño |
| [`docker.md`](docker.md) | Correr los ejemplos sin compilar Verilator a mano. El `Dockerfile` y el devcontainer, y el único parámetro que hay que mirar (la RAM) |
| [`demo.tape`](demo.tape) + [`demo.sh`](demo.sh) | Cómo se regenera `demo.gif`, el GIF del README, con `vhs`. La salida es real y está replayeada |

## Fondo técnico

Dos textos largos que existen porque la pregunta se repite:

| | |
|---|---|
| [`clocking-blocks.md`](clocking-blocks.md) | ¿Los clocking blocks son buena práctica, opcionales o innecesarios? La postura de Dave Rich, evidencia de proyectos reales y un criterio para decidir |
| [`en-que-se-diferencia.md`](en-que-se-diferencia.md) | En qué se diferencia del *UVM Primer* de Ray Salemi, que es el libro del que salió la idea. La respuesta honesta, con la lista de lo que se cambió |

---

## El lado en inglés

[`en/`](en/README.md) tiene su propio índice. Son cinco: los dos apéndices
**generados** (`en/exam-bank.md`, `en/silent-traps.md`) y las tres traducciones
a mano —`en/setup.md`, `en/uvm-interview.md` y `en/for-teachers.md`—, que son
los tres docs que están en el camino del lector en inglés: instalar, la
entrevista, y el que decide una adopción. El nombre del archivo se traduce
también (`instalar.md` → `en/setup.md`), así que el par no se puede deducir: se
declara en `PARES_SUELTOS` de [`../tools/lint-i18n.mjs`](../tools/lint-i18n.mjs)
y se sella por sha. Si tocás el castellano, el lint pide revisar el inglés.

El resto de `docs/` sigue en castellano, y todo link desde el árbol en inglés lo
dice con un *(in Spanish)* al lado. Es honestidad, no deuda: el lector se entera
antes de hacer clic.

---

## Los generados no se editan

`banco-de-examen.md`, `trampas-mudas.md`, `en/exam-bank.md` y
`en/silent-traps.md` salen de `slides/` con `npm run build`, y `npm run check`
falla si quedaron viejos. La corrección va **en la slide**. Llevan un comentario
arriba que lo dice.

`verilator.md` es otro caso: lo escribe `make matrix` corriendo los ejemplos de
verdad, así que se regenera al cambiar de versión de Verilator, no en cada
build.

---

## El resto del árbol

Dónde vive cada cosa, para el que clona esto por primera vez:

```
slides/es/  slides/en/   LA FUENTE. Todo el curso, en markdown, una sección
                         por archivo. Si algo está mal en el deck o en el
                         libro, se arregla acá
code/                    Los ejemplos que corren de verdad, con Verilator
  vtalu_dut/               el DUT del curso: una ALU chica
  u2/ … u9/                un directorio por unidad, un run.sh por ejemplo
  ejercicios/              los ejercicios, cada uno con enunciado y solucion/
  verilator/               common.sh: los flags de Verilator, en un solo lugar
  .uvm/                    la UVM de Accellera. La baja `make uvm`, no se commitea
res/                     Los diagramas, en SVG hecho a mano
  print/                   los mismos en versión clara, para el PDF. Generado
tools/                   El build y los linters. Todo Node, sin framework
web/                     Las dos landings del sitio (ES e inglés)
docs/                    Acá
css/  js/  vendor/       El CSS del deck, y reveal.js vendorizado

index.html               EL DECK. Generado, y commiteado a propósito: abrirlo
libro/dia1..8.html       con doble clic tiene que andar, sin build y sin
en/index.html            internet. Los regenera `npm run build`; `npm run
en/libro/day1..8.html    check` falla si quedaron viejos
dist/                    PDF, PPTX y los reportes de regresión. No se commitea
```

Los comandos están en [`../README.es.md`](../README.es.md) —el README en
castellano; [`../README.md`](../README.md) es el mismo, en inglés, que es lo que
GitHub muestra por defecto— y en el [`Makefile`](../Makefile); las reglas para
tocar el repo, en [`../CONTRIBUTING.md`](../CONTRIBUTING.md).
