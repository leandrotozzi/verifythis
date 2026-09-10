# Para docentes

*Verify This!* está escrito como **siete días de clase** —más un **día 8
opcional**, después del cierre— que es como se dicta un curso de empresa, y no es
como se dicta una materia. Esta página lo pasa a un
**cuatrimestre de 15 semanas**, dice qué se puede sacar, y qué evaluar en cada
parcial.

Todo lo que hace falta ya está en el repo y se corrige solo: las **19
soluciones** (`make ejercicios`), el **banco de 58 preguntas**
([`banco-de-examen.md`](banco-de-examen.md)), el capstone con su corrector por
etapas, y la **rúbrica de autoevaluación** del final del día 7.

## Cómo citarlo

El repo trae [`CITATION.cff`](../CITATION.cff), así que el botón *Cite this
repository* de GitHub genera la cita sola, en APA o BibTeX. Está bajo **CC BY
4.0** el material y **MIT / Apache-2.0** el código: se puede imprimir, cortar,
reordenar, traducir y dictar —también cobrando— con la única condición de citar
la fuente. Ver [`../LICENSING.md`](../LICENSING.md).

## El número que hay que mirar primero

Los siete días son **≈ 30 h 30 de clase**; con el día 8 opcional, ≈ 34 h 30. Un cuatrimestre de 15 semanas con 2 h de
teoría son **30 h**: entra, pero justo, y sólo si el laboratorio va aparte. El
mapa de abajo asume el formato normal de una materia con práctica:

> **2 h de teoría + 2 h de laboratorio por semana, 15 semanas.**

Con menos horas hay que sacar algo, y la sección [*Qué se puede
saltear*](#qué-se-puede-saltear) dice qué, en qué orden, y qué cuesta cada
recorte.

## Las 15 semanas

Cada fila es una clase. La columna *Laboratorio* es el ejercicio que se corrige
solo: el alumno lo termina cuando `bash run.sh` imprime `EXERCISE OK`, así que
el docente no corrige código a mano hasta el capstone.

| # | Teoría (2 h) | Laboratorio (2 h) |
|:--:|---|---|
| 1 | **U1** · Tendencias · Qué es UVM | Entorno andando: Codespaces, o Verilator ≥ 5.050 + `z3` |
| 2 | **U1** · La spec del VTALU · El plan de verificación | El plan del VTALU sobre la plantilla de [`plan-de-verificacion.md`](plan-de-verificacion.md) |
| 3 | **U2** · El testbench convencional · Cobertura funcional | [`d1`](../code/ejercicios/d1/) — una operación nueva de punta a punta |
| 4 | **U2** · Interfaces y BFM · `clocking block` | [`d1b`](../code/ejercicios/d1b/) — el bug que sólo se ve en el `.vcd` |
| 5 | **U3** · Clases y extensiones · Polimorfismo | [`d2`](../code/ejercicios/d2/) — extender sin copiar la clase entera |
| 6 | **U3** · Variables y métodos estáticos · Clases paramétricas | `d2` (cierre) |
| 7 | **U3** · El patrón factory · Un testbench sin un solo módulo | Repaso: preguntas **8–15** del banco, en clase |
| 8 | **Parcial 1** (1 h) + **U4** · Tests | — |
| 9 | **U4** · Components y fases · El env | [`d3`](../code/ejercicios/d3/) — factory override sin tocar el `env` |
| 10 | **U4** · Reporting · **U5** · Un productor, muchos oyentes · Un solo lugar que mira el cable | [`d3b`](../code/ejercicios/d3b/) — el `uvm_error` que no dice nada · [`d4`](../code/ejercicios/d4/) — un subscriber más |
| 10b | **U5** · Quién espera a quién · Cuando alguien tiene que esperar (`put`/`get` y la FIFO) | [`d4b`](../code/ejercicios/d4b/) — el `#500` es un parche |
| 11 | **U6** · Repaso de U5 y arranque de jerarquías | [`d5`](../code/ejercicios/d5/) — el scoreboard grita y el DUT está sano |
| 12 | **U6** · Copiar un objeto que contiene otro · Transactions | [`d5b`](../code/ejercicios/d5b/) — medí tu `dist` |
| 13 | **U6** · Constrained random + **Parcial 2** (1 h) | [`d5c`](../code/ejercicios/d5c/) — cerrar un bin dirigido |
| 14 | **U7** · Agents · Sequences — y *Callbacks* si entra, que es el primero de la lista de recortes | [`d6-agents`](../code/ejercicios/d6-agents/) · [`d6-sequences`](../code/ejercicios/d6-sequences/) · [`d6-debug`](../code/ejercicios/d6-debug/) — tres bugs plantados |
| 15 | **U7** · Sequences virtuales · **U8** · Assertions (SVA) | [`d7-semillas`](../code/ejercicios/d7-semillas/) con `make regresion`, de calentamiento · [`d7-sva`](../code/ejercicios/d7-sva/) · **arranque del capstone** |
| — | *(período de exámenes)* | **Capstone**: [`d7-final`](../code/ejercicios/d7-final/) |
| + | **Día 8** *(opcional)* · **U9** · RAL · DPI · el segundo capstone — no entra en las 15 semanas | [`d8-ral`](../code/ejercicios/d8-ral/) — el mapa de registros · [`d8-dpi`](../code/ejercicios/d8-dpi/) — el modelo en C · [`d8-fifo`](../code/ejercicios/d8-fifo/) — el segundo capstone |

El **día 8** es la fila que sobra a propósito. No entra en un cuatrimestre de 15
semanas y el curso no lo necesita para cerrar: está para el grupo que llega con
tiempo, para un seminario de posgrado, o como trabajo práctico optativo con nota.
Las tres piezas dependen de que el capstone esté hecho, así que sólo funcionan
**después**:

- **U9 · RAL** — 45 min de teoría y un laboratorio de una hora. Reusa el DUT y el
  testbench del capstone. El argumento que hay que asegurarse de que quede es el
  de la última sección: RAL modela almacenamiento direccionable, no comportamiento.
- **El modelo de referencia en C, por DPI** — 30 min, sin laboratorio propio: el
  ejemplo `code/u8/dpi/` corre y se lee. Es la técnica de la industria para un
  DUT con aritmética seria, y ningún curso atado a una licencia la puede mostrar
  corriendo.
- **El segundo capstone** ([`d8-fifo`](../code/ejercicios/d8-fifo/)) — dos horas.
  Es el mejor trabajo práctico optativo con nota que tiene el repo, y por un
  motivo concreto: el bug que hay que cazar está en una **bandera**, no en los
  datos, así que un scoreboard que sólo compara lo que sale pasa en verde. Separa
  al que entendió del que copió el patrón del primer capstone.

Los cuatro **apéndices** del día 7 —de la VTALU a un bus real, la caja de
herramientas de debug, las 21 trampas mudas y el glosario— no ocupan hora
de clase: se dan como **lectura**, porque el curso tiene libro. `libro/dia7.html`
es el mismo material para leer de corrido, con las notas del instructor adentro
del texto. Los apéndices de debug y de trampas se leen antes del capstone; se
nota cuál grupo lo hizo.

## Qué se puede saltear

En este orden. Cada recorte es honesto: dice qué se pierde, no promete que sea
gratis.

| Se saca | Se gana | Qué cuesta |
|---|--:|---|
| **Sequences virtuales** (U7) | 30 min | Nada de lo que sigue depende de eso. Es la sección que el alumno va a necesitar el día que tenga dos agents, no antes. Se dicta a la mañana del día 7 justamente para que sea la primera que se cae si el capstone necesita la hora |
| **Callbacks** (U7) | 15 min | El tercer gancho de la unidad 1 queda prometido y no entregado. Si se saca, sacarlo también de la slide *Correr más tests escribiendo menos código* |
| **Clases paramétricas** (U3) | 30 min | Se puede contar en 5 min como "esto es lo que hace `uvm_driver #(T)`" y seguir. Es la sección más lejos de UVM de todo el curso |
| **`put`/`get` ports** (U5) | 30 min | Analysis ports —que son los que UVM usa todo el tiempo— quedan igual. `put`/`get` aparece en el TLM de verdad, no en un testbench típico |
| **El repaso en clase** (los 8 quizzes) | 1 h 30 total | Se pasan a tarea con el [banco de examen](banco-de-examen.md). Pero perdés el mejor momento del curso para detectar al que no entendió, y eso se paga en el parcial |

Lo que **no** conviene sacar, aunque tiente:

- **El plan de verificación** (U1). Es media hora y es lo que convierte el
  covergroup del día 1 en algo que se deduce en vez de inventarse. Sin él, la
  etapa 4 del capstone no tiene de dónde salir.
- **Reporting** (U4). Parece accesorio y es el 47 % del trabajo real. El curso
  entero apunta a esa cifra desde la primera slide.
- **El capstone**. Es la diferencia entre *"hice el curso"* y *"sé hacerlo"*.
  Si no hay tiempo para el capstone entero, pedir **sólo la etapa 1** —el
  monitor sobre el esclavo APB pasivo—: se hace en media hora y ya deja algo
  entregable.

## Los dos parciales

El [banco de examen](banco-de-examen.md) trae las 58 preguntas sin la respuesta
marcada, y la clave al final con el porqué de cada una. Salen de las mismas
slides que el deck, así que no hay dos versiones de una pregunta que se puedan
desincronizar.

| | Cubre | Preguntas del banco | Parte práctica sugerida |
|---|---|:--:|---|
| **Parcial 1** | U1–U3: por qué se verifica, el testbench sin UVM, la OOP que UVM da por sabida | **1–15** | Extender una clase del curso y hacer un `set_type_override` — el enunciado de [`d2`](../code/ejercicios/d2/) o [`d3`](../code/ejercicios/d3/) con otra operación |
| **Parcial 2** | U4–U6: fases, env, reporting, cómo hablan los componentes, transactions y constrained random | **16–35** | Colgar un subscriber del analysis port y contar algo — [`d4`](../code/ejercicios/d4/) con otra métrica |
| **Final / capstone** | U7–U8 y todo lo anterior | **36–50** | El capstone, abajo |

Las **51–58** son las del día 8 y quedan afuera del cuatrimestre, como el día:
sirven para el que curse la unidad optativa.

Las 50 del cuatrimestre alcanzan para dos parciales y un recuperatorio sin
repetir, si se toman 10 por parcial. Para tomar dos filas del mismo tema —una en
el parcial y otra en el recuperatorio— la columna *Tema* de la clave las agrupa.

**Qué mirar al corregir el multiple choice.** Las opciones incorrectas de este
banco no son de relleno: casi todas son el error que la gente comete de verdad.
Un alumno que marca *"el covergroup da 0 % porque los bins están mal"* en vez de
*"nadie llama a `sample()`"* no se equivocó de detalle, tiene mal el modelo
mental — y ese error va a volver en el capstone.

## Corregir el capstone

El capstone ([`d7-final`](../code/ejercicios/d7-final/)) es un esclavo **APB3**
de cuatro registros, su especificación, y una hoja en blanco. No hay archivo con
un agujero: el testbench se escribe entero.

**El corrector va por etapas y cada una imprime su `STAGE N OK`**, así que la
nota sale de correr `bash run.sh` y leer hasta dónde llegó:

| Etapa | Qué probó el alumno | Peso sugerido |
|:--:|---|--:|
| **1** · Monitor | Un agent pasivo que reconstruye transferencias mirando el bus, sin driver | 20 % |
| **2** · Driver | El protocolo adentro de la interface, con su *wait state*, y una sequence dirigida | 25 % |
| **3** · Scoreboard | El DUT modelado en software. Se corre dos veces: contra el DUT sano tiene que callarse, y con `+BUG=1` tiene que **gritar** | 25 % |
| **4** · Cobertura | El covergroup sale de las nueve filas del plan de verificación de la spec: > 20 puntos, 90 % cubierto, y los bins `back_to_back` y `unaligned` llenos | 15 % |
| **5** · Properties | El protocolo del APB adentro de `apb_if.sv`, compilado con `--assert`. Con `+BUG=2` el módulo de siempre mueve `PADDR` en el medio de ACCESS: el monitor ve ocho transferencias impecables y la única que se entera es la assertion | 10 % |
| — | **Las dos filas del plan que faltan**, escritas por el alumno | 5 % |

Las **filas 8 y 9 del plan vienen vacías** en `spec.md` y las escribe el alumno:
son las dos cosas que la spec promete en una línea suelta —`PSEL` puede quedar
alto entre dos transferencias, y `PADDR[1:0]` se ignora— y que ninguna de las
siete filas de arriba mide. La 9 además cuelga al scoreboard que decodifica con
la dirección entera.

La etapa 3 es la que separa. Un scoreboard que nunca vio un error no está
probado: `+BUG=1` le saca al DUT el gate de `CTRL.EN`, y un modelo que no haya
modelado `EN` pasa las dos corridas. El corrector lo caza — es un test de
mutación, y es exactamente lo que haría una regresión de verdad.

Las cuatro trampas de la spec están puestas a propósito, y las cuatro son de
**spec mal leída**, no de UVM: el wait state de la lectura, el `CLR` que nunca se
lee en 1, el registro de sólo lectura que se escribe sin dar error, y el
acumulador que sólo corre con `EN=1`. Si un grupo entero cae en la misma, casi
seguro se salteó *La letra chica* de `spec.md`.

**Defensa oral, tres preguntas que rinden:** por qué el monitor mira el cable y
no lo que el driver mandó; qué bin quedó abierto y por qué; y qué pasaría si el
`PREADY` tardara dos ciclos en vez de uno.

## La rúbrica de autoevaluación

El día 7 cierra con **15 afirmaciones** del tipo *"puedo explicar por qué una
sequence no aparece en `print_topology()`"*, cada una con la sección donde está
la respuesta. Es para el alumno, no para el docente: sirve como guía de estudio
antes del final, y como diagnóstico honesto para el que hace el curso solo.

Da bien también como **primera diapositiva de la clase de consulta**: se
proyecta, y las tres que más manos levantan son las que hay que repasar.

## Lo que se corrige solo

```sh
make ejercicios     # corre las 19 SOLUCIONES: verifica que sigan siendo resolubles
make regresion      # N semillas + merge de cobertura + reporte HTML de bins abiertos
npm run check       # el banco de examen y el deck, al día con slides/
```

`make ejercicios` **no** comprueba que un alumno haya resuelto algo: comprueba
que los diecinueve sigan siendo resolubles cuando se toca el código del curso. Es
la red que hay que correr después de adaptar un ejercicio.

`make regresion` es el ejercicio [`d7-semillas`](../code/ejercicios/d7-semillas/)
convertido en herramienta: corre el mismo test con N semillas, mergea la
cobertura y deja en `dist/regresion/regresion.html` la lista de **bins
abiertos**, que es la única pregunta útil después de una regresión. Sirve como
demostración en clase —los alumnos ven que la décima semilla no agrega nada— y
como corrector de un trabajo de cierre de cobertura.

## El laboratorio

| | Para qué | Si no está |
|---|---|---|
| **Verilator ≥ 5.050** | El simulador. Los covergroups entraron ahí | no hay cobertura funcional, que es medio curso |
| **`z3`** | `randomize()` con constraints | compila, corre, y `randomize()` devuelve **0 en silencio** desde el día 5 |
| **`ccache`** | opcional | la segunda compilación de un ejemplo con UVM tarda 1 min 30 en vez de 15 s |

**La recomendación para una materia es Codespaces**: `.devcontainer/` trae
Verilator, UVM, `z3` y `ccache` adentro, la cuenta gratuita da 60 horas-core por
mes —de sobra— y evita la media tarde por alumno que cuesta instalar Verilator
en macOS o Windows. La alternativa sin cuenta es la imagen de Docker; ver
[`docker.md`](docker.md).

Lo que anda y lo que no, con el número de cobertura de cada ejemplo, está medido
en [`verilator.md`](verilator.md). Vale la pena leer las dos secciones sobre
fallas mudas —`z3` y las assertions sin `--assert`— **antes** de la primera
clase de laboratorio: son las dos formas que tiene este entorno de mentir sin
dar un error.

## Si encontrás un problema

Un ejemplo que no corre, una explicación que no se entiende o una pregunta del
banco mal formulada son **issues del curso**, no problemas del que lo dicta:
[Discussions](https://github.com/leandrotozzi/verifythis/discussions), con una
categoría por día. Si ya lo arreglaste, mejor:
[`../CONTRIBUTING.md`](../CONTRIBUTING.md).
