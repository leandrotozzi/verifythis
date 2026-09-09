## Introducción

#### *¿Qué es UVM?*

- **U**niversal **V**erification **M**ethodology: una **librería de clases**
  escrita en SystemVerilog, más un montón de **convenciones** sobre cómo usarla
- No es un lenguaje y no es un simulador. Todo lo que vamos a ver en el curso se
  puede escribir a mano — y en los días 1 y 2 lo vamos a escribir a mano
- La hace **Accellera**, el mismo consorcio que estandarizó SystemVerilog, y es
  **IEEE 1800.2**. El curso usa la implementación de referencia, `uvm-core
  2020.3.1`
- Viene de OVM (Cadence + Mentor), con ideas de VMM (Synopsys) y de eRM
  (Verisity): las metodologías de tres vendors que competían, hasta que la
  industria se cansó de traducir testbenches entre herramientas
- Y ahí está el objetivo, que es uno solo: **que el testbench del de al lado se
  parezca al tuyo**

Note:
La frase que ordena la sección es la del segundo bullet, y conviene decirla
fuerte porque baja la ansiedad del que llega asustado: **UVM no hace nada que no
puedas hacer vos**. No hay magia adentro. Hay una fábrica, unos puertos, unas
fases y mucho acuerdo sobre nombres.
Si alguien pregunta por qué entonces molestarse: por el último bullet. Un
verificador que cambia de proyecto —o de empresa— abre el testbench y reconoce
la estructura el primer día. Eso es lo que se compra. No es velocidad de
simulación ni menos líneas: es que la estructura sea la misma en todos lados.
El dato histórico sirve para el que viene de la industria: hasta 2011 cada
vendor tenía la suya, y portar un testbench de VMM a OVM era reescribirlo. UVM
existe porque eso era insostenible, no porque alguien tuviera una idea mejor.
Y una aclaración que evita un malentendido clásico: *Open Source* acá significa
que la **librería** es libre (Apache 2.0). El **simulador** que la corre casi
siempre no lo es — salvo en este curso, que es de lo que se trata todo esto.

---

## Introducción

#### *De dónde viene*

![De eRM, VMM, AVM y OVM a UVM](res/originUVM.svg)
<!-- .element: class="grande" -->

Note:
El diagrama en una frase: seis siglas de cuatro vendors que convergen. eRM era
de Verisity (lenguaje `e`), RVM y después VMM de Synopsys, AVM de Mentor y URM
de Cadence; OVM fusionó AVM con URM, y es la base de la que salió UVM.
Lo que hay que señalar es la fecha de abajo y el salto que significa: UVM 1.0 es
de 2011, o sea que esto es **joven**. El que hoy tiene quince años de carrera
empezó antes de que existiera.
Y la moraleja que se usa el resto del curso: cuando encuentren código con
`ovm_component` en vez de `uvm_component`, no es un error de tipeo — es un
testbench anterior a 2011 que nadie migró. Pasa más de lo que parece.

---

## Introducción

#### *Un testbench de SystemVerilog, por dentro*

![Anatomia de un testbench SystemVerilog](res/TB.svg)
<!-- .element: class="grande" -->

Note:
Éste es el testbench que vamos a escribir **nosotros**, a mano, en los días 1 y
2. Conviene decirlo así: las cajas de este diagrama no son teoría, son los
archivos que van a estar abiertos hoy mismo.
Señalar el tester, el driver, el monitor y el scoreboard, y hacer notar que
ninguno de esos nombres es de UVM: son los nombres que cualquiera le pone a las
piezas de un testbench, en cualquier lenguaje. UVM no los inventó; los
estandarizó.

---

## Introducción

#### *El mismo testbench, con estructura UVM*

![El mismo testbench con estructura UVM](res/TB_UVM.svg)
<!-- .element: class="grande" -->

Note:
Vale la pena quedarse un rato acá: este diagrama es el mapa del resto del curso.
Señalar driver, monitor, scoreboard y sequencer, y decir que cada uno va a ser
una sección. Al final del día 5 el alumno va a tener todo menos el sequencer,
que es el día 6.
La comparación que conviene hacer en vivo es contra el diagrama anterior: **son
las mismas cajas**. Lo que agrega UVM es el árbol que las contiene, los puertos
por los que se hablan y las fases que las construyen en orden. Nada más, y no es
poco.

---

## Introducción

#### *El árbol de clases*

![Arbol de clases base de UVM](res/uvm_class_diagram.svg)
<!-- .element: class="grande" -->

Note:
Este diagrama asusta y por eso conviene desactivarlo de entrada: **de todo esto
vamos a usar siete clases**. `uvm_object`, `uvm_component`, `uvm_test`,
`uvm_env`, `uvm_agent`, `uvm_driver`, `uvm_monitor` y `uvm_sequence` — bueno,
ocho.
Lo que sí hay que dejar marcado es la división de más arriba, porque explica
medio curso: de `uvm_object` cuelgan los **datos** —las transactions, las
sequences, los configs— y de `uvm_component` cuelga la **estructura** —todo lo
que vive en el árbol y tiene fases—. Un objeto se crea y se tira; un componente
se construye una vez y dura toda la simulación.
La pregunta para tirar al grupo cuando lleguemos a los agents: ¿una
`uvm_sequence` es un object o un component? Object. Y por eso no aparece en
`print_topology()`.
Es el mismo diagrama que está en el machete, arriba a la derecha, para volver a
mirarlo cuando haga falta.

---

## Introducción

#### *Correr más tests escribiendo menos código*

- Ésa es la promesa, y tiene una condición: **el env y los componentes casi no
  cambian** de un test a otro. Lo que cambia es el estímulo
- Para que eso funcione, el testbench tiene que dejar **ganchos**: métodos
  virtuales, la factory y los callbacks. Un test engancha ahí y no toca la
  estructura
- Un test nuevo entonces es una de estas tres cosas, y ninguna toca el env:
  - agregar **constraints** para llegar a un caso de borde
  - hacer un **override** de la factory para cambiar una clase por otra
  - inyectar errores o delays con **callbacks**
- Y arriba de todo eso, la palanca que más rinde: **el mismo test con cientos de
  semillas** distintas

Note:
Ésta es la slide que hay que poder repetir al final del curso, porque es la tesis
entera. Y conviene ser honesto: *"run more tests, write less code"* es un eslogan
de vendor, pero la parte verificable es cierta y se puede señalar con el dedo el
día 6 — el `add_test` de las sequences es de **dos líneas**, y cambia todo el
estímulo sin tocar una sola clase del env.
El orden de los tres ganchos no es casual, es de menor a mayor: una constraint
cambia valores, un override cambia una clase, un callback cambia comportamiento
en un punto de la que ya existe. Los tres son una sección del curso —*Constrained
random* el día 5, *El patrón factory* el día 2 y *Callbacks* el día 6—, así que
esta slide se puede volver a poner tres veces.
Y la última línea es la que más se subestima. Un test con mil semillas no es
"el mismo test mil veces": es mil escenarios distintos por el precio de escribir
uno. Es literalmente el ejercicio `d6-semillas` del día 6.
