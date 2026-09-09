## Un productor, muchos oyentes

#### *Dos formas de hablar entre objetos*

- El paradigma estructural pregunta *qué pasos seguir*. La OOP pregunta **qué
  objetos hay y cómo se hablan** — y ahí se acaba el testbench de un solo
  `initial`
- Y hablarse, entre objetos, es exactamente dos cosas. La diferencia está en si
  los dos corren en **el mismo thread** o no
- **Mismo thread:** uno llama al método del otro y vuelve enseguida. Es el
  `write()` de un `uvm_analysis_port` — las dos primeras secciones del día
- **Threads distintos:** los dos corren a la vez y hay que **coordinarlos**, o
  sea que alguien va a tener que esperar. Es `put` / `get` y las TLM FIFOs —
  las dos últimas
- El día 4 entero son esas dos columnas. Arrancamos por la de la izquierda

Note:
Esta slide es el mapa del día: las cuatro secciones que vienen son las dos
columnas de abajo, en orden.
Vale escribir las dos columnas en el pizarrón y volver a ellas cada vez que
aparezca un puerto nuevo, porque la pregunta que hay que hacerse frente a
cualquier port de UVM es siempre la misma: **¿esto puede bloquear?** Si corre en
mi thread, no; si corre en otro, sí, y entonces tiene que ser una `task`.
Ése es también el criterio que ordena el vocabulario del día: `write()` es una
`function` —no consume tiempo—, `put()` y `get()` son `task`. La firma te dice de
qué lado de la división estás antes de leer una línea de la implementación.

---

## Un productor, muchos oyentes

#### *El que publica no sabe quién lo lee*

- Un dato del testbench casi nunca tiene **un** destinatario: cada comando que ve
  el monitor lo quieren el scoreboard, la cobertura y, mañana, el log
- La solución obvia es que el productor guarde un handle a cada consumidor y les
  llame el método. Funciona, y agregar un consumidor obliga a **tocar el
  productor**
- Es el mismo problema que resolvió el BFM en interfaces y BFM, un nivel más arriba:
  ahí escondimos el cable, acá queremos esconder **la lista de destinatarios**
- La respuesta es un patrón viejo: el productor publica en un puerto y no sabe
  —ni le importa— quién está del otro lado
- La sección lo arma primero a mano con dados, y recién después lo reemplaza por
  `uvm_analysis_port`. El ejemplo es ajeno al hardware a propósito

Note:
El ejemplo de los dados es deliberado y conviene defenderlo si alguien pregunta
por qué no arrancamos con el VTALU: se ve el patrón sin el ruido del protocolo.
Cuando en los analysis ports aparezca sobre el DUT, el alumno ya no está aprendiendo
dos cosas a la vez.
La pregunta que ordena la sección: ¿cuál es la única línea que hay que escribir
para agregar un cuarto observador? Un `connect()`. Ninguna en el productor. Ese es
el criterio con el que hay que mirar todo el código de acá en adelante.
Y conviene anticipar el límite, porque es la comunicación entre threads: esto es comunicación
dentro de **un solo thread**. `write()` es una `function`, no consume tiempo, y
corre en el thread del que publica. Para hablar entre threads hace falta otra
cosa.

---

## Un productor, muchos oyentes

#### *El problema: dos dados, tres cosas que hay que contar*

- Escribir un programa que simule la ejecución de tirar dos dados (2d6) 20 veces e informe lo siguiente
  - El promedio de los valores que dieron los dados
  - Un histograma con la frecuencia de valores
  - Un reporte de cobertura que muestre si salieron todos los posibles valores de 2 a 12

![Dos d6 y el histograma de sus sumas](res/funs/dados.svg)
<!-- .element: class="grande" -->

Note:
Vale plantearlo como problema de programación antes de mostrar una línea: son
tres consumidores del mismo dato, y cada uno hace algo distinto con él. Nadie
piensa en hardware acá, que es exactamente la idea.
Los tres informes tienen algo en común que conviene hacer notar ahora: ninguno
se puede calcular con una sola tirada. Los tres acumulan y recién informan al
final, y por eso los tres van a necesitar dos métodos, no uno.
Y una pregunta rápida para el aula, que después se cobra: si mañana piden un
cuarto informe —la tirada más repetida, digamos—, ¿qué archivos hay que tocar?

---

## Un productor, muchos oyentes

#### *Los tres observadores: la misma forma, tres cuerpos*

{{code:code/u5/varios-objetos/01-sin-analysis-port/average.svh}}

- `average` es el más simple: un `write(int t)` que acumula, y un
  `report_phase()` que divide e informa al final
- Ésa es la **forma** que van a tener los tres: reciben una tirada de a una, y
  el resultado recién existe cuando terminó todo

Note:
Vale mostrar la clase entera una sola vez —ésta— y después sólo los `write()`,
porque lo que interesa es que la forma se repita.
Dos detalles que se cobran después: el `report_phase` corre **cuando cae la
última objection**, no al final del `run_phase`, y por eso el promedio sale
completo. Y `dice_total` y `count` son `protected`: el que publica no puede
tocarlos, sólo llamar a `write()`.
Cuando esto sea el VTALU, en los analysis ports, `average` va a ser el scoreboard y el
`report_phase` el veredicto de la corrida. Misma forma.

---

## Un productor, muchos oyentes

#### *Los otros dos: cambia el cuerpo, no la forma*

{{code:code/u5/varios-objetos/01-sin-analysis-port/histogram.svh|lines=11-13}}

{{code:code/u5/varios-objetos/01-sin-analysis-port/coverage.svh|lines=14-17}}

- `histogram` guarda las tiradas en un array asociativo y dibuja las barras en
  el `report_phase`
- `coverage` copia la tirada a `the_roll` y llama a `sample()`: es el covergroup
  del testbench convencional, con el muestreo atado al dato en vez de al reloj
- Los tres `write()` son distintos por dentro y **idénticos por fuera**: mismo
  nombre, mismo argumento. Eso es lo que va a permitir tratarlos igual

Note:
El punto de la slide es el último bullet: tres clases que no se parecen en nada
exponen la misma puerta. Cuando aparezca `uvm_subscriber`, esa puerta va a ser
un contrato del lenguaje en vez de una convención.
El `coverage` de acá es la respuesta a una pregunta que quedó abierta en el testbench convencional: *¿dónde muestreo?* Acá el `sample()` no está atado a un flanco de
reloj, está atado a que **llegó un dato**. Eso es lo correcto, y es lo que hace
el `coverage` de todos los testbenches del curso de acá en adelante.
El archivo entero de cada uno está en `code/u5/varios-objetos/01-sin-analysis-port/`: lo que
no se muestra es el `report_phase`, que sólo formatea.

---

## Un productor, muchos oyentes

#### *El productor: tira los dados y devuelve un número*

{{code:code/u5/varios-objetos/01-sin-analysis-port/dice_roller.svh|lines=1-23}}

- `dice_roller` randomiza dos bytes con un `constraint` que los deja entre 1 y 6,
  y devuelve la suma
- Es todo lo que hace, y está bien que sea todo: **produce el dato y no sabe
  nada de quién lo usa**
- Fijate lo que **no** tiene: ni un handle a `coverage_h`, ni a `histogram_h`,
  ni a `average_h`. Esa lista está en otro lado, y ahí está el problema

Note:
Conviene detenerse en la ausencia: el productor ya está bien escrito. No hay que
arreglarlo, y de hecho en la versión con analysis port casi no cambia.
El `void'(randomize())` merece un comentario al pasar: descarta el valor de
retorno a propósito. En las transactions vamos a ver por qué eso es una mala
costumbre —un `randomize()` que falla y nadie se entera— y cómo se escribe bien.
La pregunta para dejar picando: si el productor no tiene la lista, ¿quién la
tiene? La slide que sigue.

---

## Un productor, muchos oyentes

#### *El que reparte: el test, y no debería*

- El `dice_test` extiende `uvm_test`, instancia los cuatro componentes y arranca
- Funciona. Pero mirá el `run_phase`, y en particular qué hay adentro del
  `repeat (20)`

{{code:code/u5/varios-objetos/01-sin-analysis-port/dice_test.svh|lines=16-32}}

Note:
Esta slide es el "antes", y hay que dejar que se vea feo. Mirá el `repeat (20)`:
tres `write()` escritos a mano, uno por observador. Agregar un cuarto es tocar
esta clase; sacar uno, también.
Peor todavía, y es lo que conviene señalar: el que quedó a cargo de repartir el
dato es **el test**. O sea que el `dice_roller` produce y el test distribuye —
dos responsabilidades que no tienen por qué estar juntas, y la de distribuir es
la que va a cambiar todo el tiempo.
La pregunta para tirar antes de pasar a la siguiente: si esto fuera el VTALU,
¿quién sería el `dice_roller` y quiénes los tres `write()`? El monitor, y el
scoreboard más la cobertura. Los analysis ports son literalmente esta slide con otros
nombres.

---

## Un productor, muchos oyentes

#### *Observer Design Pattern*

- El que publica un tweet no sabe quién lo lee ni qué hace con él, y sin embargo
  llega a todos. Eso es el **Observer**
- Un objeto produce un dato y lo publica. Los que necesitan ese dato se
  suscriben. El productor **no lleva la lista**
- Acá el observado es `dice_roller_h`; los observadores —*subscribers*— son
  `coverage_h`, `histogram_h` y `average_h`
- La propiedad que compra todo: agregar un cuarto observador **no toca una línea**
  del que produce

![Un emisor publica y N observadores reciben](res/funs/observer-broadcast.svg)
<!-- .element: class="grande" -->

Note:
La analogía funciona mejor dada vuelta: el que publica no sabe quién lo lee, y
ésa es justo la propiedad que querés en un monitor. Agregar un subscriber nuevo
—otra cobertura, un log— no toca una línea del que produce el dato.
El ejemplo de los dados es a propósito ajeno al hardware: se ve el patrón sin el
ruido del protocolo.

---

## Un productor, muchos oyentes

#### *El patrón, ya hecho: las dos puntas del cable*

- UVM trae el patrón hecho, en dos clases que son las dos puntas del cable:
  - *uvm_analysis_port:* Envía data a un conjunto de subscribers (observadores)
  - *uvm_subscriber:* Extensión de uvm_component que permite al componente suscribirse a un uvm_analysis_port

![Un uvm_analysis_port publicando hacia varios uvm_subscriber](res/diagrams/varios-objetos_ports.svg)
<!-- .element: class="grande" -->

Note:
Los nombres cuestan un minuto y ahorran media hora después: **port** es la punta
del que produce, **export** la del que consume, y el `connect()` siempre se
llama sobre el port.
`uvm_analysis_port` es un *broadcast*: no le importa si tiene cero, uno o diez
subscribers, y escribir en un port sin conectar no es un error — el dato se
pierde en silencio. Es una de las trampas mudas del curso, y el síntoma es un
scoreboard que nunca reporta nada.
`uvm_subscriber` es la otra punta y es una clase parametrizada: `#(int)` acá,
`#(command_transaction)` en los analysis ports. La conexión queda **tipada** por el
compilador, no por un string.

---

## Un productor, muchos oyentes

#### *uvm_analysis_port*

- Declaramos una variable del tipo *uvm_analysis_port* que defina el tipo de datos que va a transportar
- Instanciamos el analysis port en *build_phase*
- Escribimos datos en el puerto mediante el método *.write()*
- Una vez que escribimos datos en el puerto, este va a todos sus subscribers
- Utilizamos el método *connect()* para conectar los subscribers al puerto. Este método tiene un único argumento: un analysis_port

{{code:code/u5/varios-objetos/02-con-analysis-port/con-analysis-port.sv}}

Note:
Tres pasos y ninguno más: declarar el port, instanciarlo en build_phase,
escribir con write(). Del otro lado el subscriber implementa write() y se
conecta en connect_phase.
El detalle que sorprende: los ports no se crean con la factory, se instancian
con new().

---

## Un productor, muchos oyentes

#### *uvm_subscriber*

- Extendemos la clase *uvm_subscriber* paramétricamente, para saber qué tipo de datos va a leer
- La clase nos da un objeto llamado *analysis_export*
- La clase requiere que creemos un método llamado *write()* que tiene un único argumento *t*, que es del mismo tipo que la extensión de la clase
- En nuestro ejemplo, tenemos 3 subscribers (average, coverage y histogram)

{{code:code/u5/varios-objetos/02-con-analysis-port/coverage.svh}}

Note:
`uvm_subscriber` es un trato en dos partes y conviene enunciarlo así: **te doy un
`analysis_export`, me devolvés un `write()`**. Nada más. El `analysis_export` no
se declara ni se instancia — viene con la clase.
El `#(int)` del `extends` es las clases paramétricas cobrando otra vez: define de qué tipo es
el `t` del `write()`, y el compilador se encarga de que un puerto de `int` no se
pueda conectar a un subscriber de otra cosa. La conexión está **tipada**, no es
un string.
Comparar con la versión anterior de esta misma clase vale la pena: el `write()`
es idéntico. Lo único que cambió es de quién hereda y quién lo llama. Ese es el
punto entero de la sección — el observador no se entera de que ahora es un
observador.
Y un detalle que aparece en la salida: acá la cobertura se lee con
`get_inst_coverage()`, no con `get_coverage()`. Es una limitación de Verilator
—la type-wide devuelve siempre 0— y está en `docs/verilator.md`.

---

## Un productor, muchos oyentes

#### *El productor, ahora publicando*

{{code:code/u5/varios-objetos/02-con-analysis-port/dice_roller.svh|lines=20-39}}

- Los tres pasos numerados son todo lo que cambió respecto de la versión
  anterior: declarar el port, instanciarlo en `build_phase`, escribir con
  `write()`
- `roll_ap = new(...)`: los ports **no** se crean con la factory. Son el cableado
  del testbench, no piezas intercambiables
- El `two_dice()` que devolvía un número desapareció: ahora la tirada se publica
  y el productor sigue de largo

Note:
La comparación con la versión anterior es la slide entera: el `dice_roller` no
ganó ningún handle a nadie. Ganó **un** port.
Por qué los ports van con `new()` y no con `type_id::create()`: la factory está
para sustituir tipos, y un port no se sustituye nunca. Es una pregunta que sale
siempre y la respuesta corta es ésa.
Y el `write()` de acá conviene mirarlo con la comunicación entre threads en mente: es una
`function`, así que **no consume tiempo** y corre en el thread del productor.
Cuando el que consume necesite hacer esperar al que produce, esto no alcanza.

---

## Un productor, muchos oyentes

#### *connect_phase(): dónde se arma el cableado*

- Necesitamos vincular al productor con el consumidor
- UVM provee un phase method (*connect_phase()*) para conectar los objetos
- UVM llama al método build_phase de manera TOPDOWN, una vez terminado con todos los objetos en la jerarquía, UVM llama al método connect_phase de manera BottomUP
- El proceso de conexión tiene 2 partes fundamentales
  - Los uvm_subscribers contienen un objeto llamado analysis_export, que no debemos instanciarlo ya que viene cuando extendemos la clase uvm_subscriber
  - La clase uvm_analysis_port provee un método llamado connect()

Note:
El orden de las dos fases no es un detalle de implementación, es lo que hace que
esto funcione: no se puede conectar lo que todavía no existe. Por eso
`build_phase` es top-down y termina **entera** antes de que arranque el primer
`connect_phase`.
Que `connect_phase` sea bottom-up importa menos en la práctica, pero tiene su
razón: un componente compuesto conecta sus hijos entre sí recién cuando cada
hijo ya conectó lo suyo. En los agents, cuando el agent conecte driver y
sequencer adentro suyo y el env conecte el agent hacia afuera, se va a ver.
El `analysis_export` que aparece solo es de las pocas cosas de UVM que son
gratis: viene con la clase, y olvidarse de instanciarlo no es un error porque no
hay nada que instanciar.

---

## Un productor, muchos oyentes

#### *connect_phase(): dónde se arma el cableado*

- Una sola línea de `connect_phase()` engancha al subscriber con el analysis
  port: `ap.connect(sub_h.analysis_export)`

{{code:code/u5/varios-objetos/02-con-analysis-port/dice_test.svh|lines=15-28}}

Note:
Éste es el "después", y hay que ponerlo al lado del "antes" de cinco slides
atrás. El `run_phase` del test se quedó sin los tres `write()`: ahora sólo levanta
el objection y arranca al productor. La distribución se mudó al
`connect_phase`, que es donde va la estructura.
La línea que hay que leer despacio es
`dice_roller_h.roll_ap.connect(coverage_h.analysis_export)`, y la dirección
importa: **el port se conecta al export, nunca al revés**. Es el mantra que vuelve
en threads, en put y get y en agents, y el compilador no siempre te ataja.
Regla de bolsillo para acordarse de la dirección: conecta el que **produce**. El
que consume pone la oreja y no hace nada.
Y la prueba de fuego de la sección: para agregar un cuarto observador hay que
escribir la clase y **una** línea acá. Ni una en `dice_roller`.

---

## Un productor, muchos oyentes

#### *La solución, cableada*

- En el diagrama de conexionado podemos ver que la clase dice_roller tiene un objeto uvm_analysis_port llamado roll_app
- Cada subscriber tiene un objeto analysis_export
- La conexión entre ambos se realiza mediante el método connect()

![El ejemplo de los dados cableado con analysis ports](res/diagrams/varios-objetos_spicy.svg)
<!-- .element: class="grande" -->

Note:
Es el primer diagrama TLM del curso y conviene enseñar a leerlo ahora, porque los
del resto del día y el de los agents usan la misma convención: **rombo** es analysis
port, **cuadrado** es put/get port, **círculo** es export. La flecha va del que
produce al que consume.
Lo que hay que hacer notar del dibujo es que del `roll_ap` salen tres flechas y
del `dice_roller` sale **una sola línea de código**: el `write()`. La
multiplicidad no está en el productor, está en el cableado.
Y el cierre de la sección, que enlaza con el siguiente: todo esto pasó adentro de
un solo thread. `write()` es una `function`, no puede tener un `@` ni un `#`, y
volvió antes de que avanzara el tiempo. Cuando el que produce y el que consume
tengan que esperarse, esto no alcanza — y eso es la comunicación entre threads.

---

## Un productor, muchos oyentes

#### *Resumen de la unidad*

- Dos objetos se hablan de **exactamente dos formas**, y la diferencia es si
  corren en el mismo thread o no
- **Mismo thread**: uno llama al método del otro y vuelve enseguida. Es una
  `function`, **no puede bloquear**. Es el `write()` de un analysis port
- **Threads distintos**: hay que coordinarlos y alguien va a esperar. Es una
  `task`, **puede bloquear**. Es `put`/`get`, y son las dos últimas secciones
- La pregunta frente a cualquier port de UVM es siempre la misma: **¿esto puede
  bloquear?** La firma te lo dice antes de leer la implementación
- El **analysis port** resuelve el problema de fondo: el que publica **no sabe
  quién lo lee**, y agregar un lector no le toca una línea
- Es el patrón *observer* de siempre, y es el mismo movimiento que hizo la BFM
  en interfaces y BFM: un nivel más arriba

Note:
La slide con la que conviene abrir y cerrar el día 4, porque es el mapa. Escribir
las dos columnas en el pizarrón y volver a ellas cada vez que aparezca un puerto
nuevo.
Y el criterio que ordena el vocabulario entero: `write()` es una `function` —no
consume tiempo—, `put()` y `get()` son `task`. En SystemVerilog eso no es una
convención de nombres, es el lenguaje diciéndote de qué lado estás.
