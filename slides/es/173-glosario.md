<!-- .slide: id="glosario" data-machete="res/uvm_class_diagram.svg|Jerarquía de clases base de UVM,res/diagrams/sequences_tb_completo.svg|El testbench completo: la nube de sequences · el agent con sequencer y driver · y la capa de análisis en el env" -->

## Glosario · ES → EN

#### *Lo que vas a tener que buscar en inglés*

| Lo que dijimos acá | Cómo se busca afuera |
| --- | --- |
| cobertura funcional / de código | *functional* / *code coverage* |
| plan de verificación | *verification plan*, *coverage plan* |
| cierre de cobertura | *coverage closure* |
| casos borde | *corner cases* |
| estímulo dirigido / al azar | *directed* / *constrained-random stimulus* |
| ondas | *waveforms* |
| semilla | *seed* |
| regresión | *regression* |
| primer silicio · rehacer las máscaras | *first silicon* · *respin* |
| aserción | *assertion* — y `assert property` no se traduce |
| muestreo | *sampling* — y el flanco en que ocurre, *sampling edge* |
| banco de pruebas | **testbench**, siempre — nadie dice otra cosa |

- El curso está en español, pero el LRM, el *User Guide* y cada respuesta que
  vayas a encontrar están en inglés. Esta tabla es el puente

Note:
Esta slide es lo único del curso que existe puramente porque es un curso en
español, y vale explicar para qué está: el alumno acaba de aprender los conceptos
con palabras en castellano y a partir de mañana todo lo que lea va a estar en
inglés. Sin este mapeo, sabe el concepto y no sabe googlearlo.
La última fila no es un chiste. "Banco de pruebas" aparece en algunos libros
traducidos y **no lo dice nadie**: en una entrevista o en un mail al equipo se
dice testbench. Lo mismo con *coverage*, *seed* y *tape-out*.
Regla práctica para el trabajo: los sustantivos técnicos se dejan en inglés, los
verbos se conjugan en español. "Randomizá la transaction", "corré la regresión",
"esto no cierra cobertura". Suena mal escrito y es como habla el ambiente.

---

## Glosario · Las piezas

#### *Una línea cada una, para tenerlas juntas*

| Palabra | Qué es |
| --- | --- |
| *handle* | el nombre de un objeto — **no** es el objeto |
| *factory* | el diccionario de tipos: pedís la clase base y te dan la derivada |
| *override* | cambiar el tipo que la factory entrega, sin tocar quien lo pide |
| *transaction* | un dato que viaja por el testbench: un `uvm_sequence_item` |
| *agent* | todo lo que sabe hablar una interface, en una caja |
| *sequence* / *sequencer* | el estímulo (objeto) y el árbitro que lo entrega (componente) |
| *virtual sequence* | la que no manda items propios: coordina **varios** sequencers |
| *driver* | convierte una transaction en señales |
| *monitor* | mira el bus y publica transactions |
| *scoreboard* | compara lo que salió contra lo que debía salir |
| *subscriber* | cualquiera que escucha un analysis port |
| *objection* | el *"todavía tengo trabajo"* que mantiene viva la fase |
| *assertion* | una regla del protocolo escrita para que el simulador la chequee |
| *property* | la regla en sí: reloj, antecedente, implicación, consecuente |
| *antecedent* / *consequent* | el *"si"* y el *"entonces"* de una property |
| *cover property* | cuenta **cuántas veces se cumplió** una property. El chequeo del chequeo |

Note:
Es la slide para tener abierta mientras se lee código ajeno, y también la que
sirve de repaso rápido antes de una entrevista.
Las dos filas que más se confunden son *sequence* y *sequencer*, y la forma de no
errarle es la del día 6: el que termina en **-er** es el **componente** —está en
el árbol, tiene fases—; el otro es el objeto que se crea, corre y se tira. Lo
mismo vale para *driver* y *monitor*. La regla es de las piezas del árbol y no
del sufijo: las *policies* de UVM —`uvm_printer`, `uvm_comparer`, `uvm_packer`,
`uvm_recorder`— y el `uvm_report_catcher` terminan igual y son objects.
Y la primera fila es la que más cuesta y la que más cara sale: *handle*. Si el
alumno se lleva una sola palabra de este glosario, que sea que un handle no es un
objeto.
La fila de *virtual sequence* trae de la mano dos palabras más que van a
aparecer en cualquier testbench de producción: el *virtual sequencer*, que es un
componente sin cola cuyo único contenido son los handles a los sequencers de
verdad, y `p_sequencer`, el handle ya casteado a ese tipo que
`` `uvm_declare_p_sequencer `` declara por vos.
Aviso sobre *sequence*, que ahora aparece dos veces en el curso con dos
significados: la de UVM es un objeto que genera estímulo; la de SVA
(`sequence ... endsequence`, las assertions) es una expresión temporal —*"esto, y tres
flancos después aquello"*— y no tiene nada que ver. El contexto las distingue
siempre, pero la primera vez confunde.

---

## Glosario · Tres palabras que engañan

- **`virtual`** — en SystemVerilog son **tres cosas sin relación**: un *virtual
  method* (se resuelve por el objeto), una *virtual class* (abstracta, no se
  instancia) y una *virtual interface* (un handle a una interface). Que compartan
  la palabra es un accidente del lenguaje
- **`assert`** — en SystemVerilog son **dos cosas**: la *inmediata*, una sentencia
  que corre donde el hilo pasa, y la *concurrente* (`assert property`), una
  declaración con reloj que se evalúa sola toda la simulación — las assertions. El
  `assert(randomize())` que se ve por todos lados es la primera, y es una forma
  pobre de chequear un valor de retorno: por eso el curso usa `` `uvm_fatal ``
- ***coverage*** — sin apellido no quiere decir nada. Si alguien te dice "estamos
  en 90 %", la pregunta es siempre *¿de código o funcional?*
- Y una de escala: un **test** en UVM es una **clase**, no un archivo ni una
  corrida. La corrida es un *run*; el conjunto de corridas, una *regression*

Note:
Las tres están puestas porque cada una ya causó una confusión en el curso, y
conviene cerrar nombrándolas.
`virtual` se avisó en polimorfismo y vuelve en el testbench en objetos con la
virtual interface. La
pregunta que lo ordena: ¿virtual de qué? Si es un método, mira el objeto. Si es
una clase, no se instancia. Si es una interface, es un handle.
El `assert` es la trampa de las transactions y vale repetir el porqué: reporta por
afuera de UVM, no entra en el Report Summary, y con las aserciones apagadas hay
simuladores que ni evalúan la expresión — o sea que `randomize()` no se llama.
Y la última fila parece una obviedad hasta la primera reunión de proyecto, donde
"cuántos tests tenés" y "cuántos tests corriste anoche" son dos preguntas
distintas con dos números muy distintos.
