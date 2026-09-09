## Cuando alguien tiene que esperar

#### *Esto ya lo hacías, con módulos*

- El nombre asusta y el mecanismo lo venís usando desde siempre: dos módulos con
  puertos, cada uno con su `always`, pasándose datos

{{code:code/u5/threads/01-modulos/modules.sv|lines=6-33}}

- Eso **es** comunicación entre threads. Lo único que falta es hacerlo entre
  objetos, que no tienen puertos

Note:
La slide existe para desactivar el susto antes de que aparezca la palabra TLM.
Conviene señalar el código y decirlo así de crudo: acá hay dos procesos que
corren a la vez y se pasan datos por un cable, y nadie llamó a eso "comunicación
inter-thread" en veinte años de Verilog. Es lo mismo.
Lo único que cambia en el resto de la sección es **dónde vive cada proceso**: en
vez de dos `always` en dos módulos, dos `run_phase()` en dos objetos. Y como un
objeto no tiene port list, hace falta reemplazar el cable por algo.
La pregunta para dejar picando, que es exactamente la de la slide siguiente:
¿con qué se reemplaza el cable? Las respuestas que van a salir —una variable
compartida, un semáforo, un mailbox— son todas correctas, y ése es justamente el
problema que UVM viene a resolver.

---

## Cuando alguien tiene que esperar

#### *Un objeto no tiene port list*

- Lo que sí hay en SystemVerilog son handles compartidos, semáforos y mailboxes
- Con eso alcanza para resolverlo, y ése es el problema: **cada uno lo resuelve
  distinto**, y después nadie puede leer el testbench del de al lado
- UVM estandariza una sola forma, en dos piezas:
  - *Ports*: se instancian en un `uvm_component` para que su `run_phase()`
    hable con otro thread. *Put port* para mandar, *get port* para recibir
  - *TLM FIFO*: el objeto que une un put port con un get port. `new()` la crea
    con **tamaño 1** por defecto —`new(name, parent, size = 1)`—, y con `0`
    sería ilimitada. La del ejemplo usa el default
- Con tamaño 1 la FIFO no es un buffer, es un **punto de encuentro**: el que
  pone espera a que el otro saque

Note:
Lo que hay que sacarle a la slide es que el tamaño 1 no es una limitación de la
clase: es el argumento por defecto del constructor. Con `new("f", this, 0)` la
FIFO es ilimitada, y ahí el que pone nunca se bloquea.
El tamaño 1 es el que sincroniza: bloquea al productor hasta que el consumidor
saca, y eso reemplaza al semáforo y a la bandera que cada uno se escribía a
mano. Es el mismo handshake del `start`/`done` del BFM, pero entre objetos.

---

## Cuando alguien tiene que esperar

#### *Productor como un objeto*

- El productor declara un `uvm_put_port` y llama a `put()`. Eso es todo: ni
  handshake de señales, ni bandera compartida, ni semáforo

{{code:code/u5/threads/02-bloqueante/producer.svh}}

Note:
Lo que hay que hacer notar es lo que **no** está en esta clase: no hay
`@(posedge algo)`, no hay `wait`, no hay una variable que diga "listo". El
productor pone y sigue; si el otro no sacó todavía, el `put()` lo frena solo.
El detalle de forma, que es el que se copia mal: el port se **instancia** en el
`build_phase` como cualquier otro componente, con `new("nombre", this)`. Un port
es un `uvm_component`, no un campo de datos — por eso lleva padre, y por eso
aparece en `print_topology()`.
Y el parámetro: `uvm_put_port #(T)`. Ese `T` tiene que ser el mismo en el port,
en el get port y en la FIFO. Si no coinciden no compila, que es la buena noticia
—es de los pocos errores de conexión de UVM que se ven en compilación y no a las
tres de la mañana—.

---

## Cuando alguien tiene que esperar

#### *Consumidor como un objeto*

- Del otro lado, `uvm_get_port` y un `get()`. Con la FIFO vacía, `get()`
  **bloquea** y el thread se queda ahí
- Cuando el productor pone un dato, el `get()` se desbloquea y sigue con el dato
  ya leído. La sincronización no la escribió nadie: la da la FIFO

{{code:code/u5/threads/02-bloqueante/consumer.svh}}

Note:
`get()` es una **task**, y esa palabra es toda la sección. Una `function` no
puede tener un `@` ni un `#`, así que no puede esperar a nadie; una `task` sí. Si
alguien se pregunta por qué los analysis ports de la sección anterior no
bloqueaban, la respuesta está ahí: `write()` es una `function`.
El argumento por referencia también vale nombrarlo: `get(t)` no devuelve el dato,
lo **escribe** en la variable que le pasás. Es la convención de TLM y sorprende
la primera vez, porque uno espera un `t = get()`.
Y la advertencia práctica: un `get()` sobre una FIFO que nunca se llena es un
thread colgado para siempre. No hay error ni warning — la simulación termina
cuando se baja el objection y ese consumidor simplemente nunca corrió. Es
hermano del `item_done()` olvidado del día 6.

---

## Cuando alguien tiene que esperar

#### *Instanciar los tres: dos componentes y una FIFO*

- La `uvm_tlm_fifo` lleva **el mismo parámetro** que los dos ports: si no
  coinciden, no compila
- Los tres se instancian en el `build_phase` del test, como cualquier component.
  La FIFO también es un `uvm_component`
- Y el orden es el de siempre: UVM llama todos los `build_phase` de arriba hacia
  abajo, y recién cuando terminó arranca los `connect_phase` de abajo hacia
  arriba

{{code:code/u5/threads/02-bloqueante/communication_test.svh}}

Note:
Vale volver a decir por qué el orden es ése, porque acá se ve para qué sirve: el
`connect_phase` conecta un port con un export, y para eso los dos objetos tienen
que existir. Si `connect` fuera top-down, el test intentaría conectar hijos que
todavía no se construyeron.
El error clásico de esta slide, que compila y falla en tiempo de ejecución: crear
la FIFO en el `connect_phase` en vez del `build_phase`. UVM tira un fatal —
`Cannot create a component during connect` — y por lo menos avisa. Peor es
olvidarse del `connect()`: ahí el port queda sin conectar y el fatal aparece en
el primer `put()`, mucho más tarde y sin decir cuál port fue.
Y una que conviene señalar de paso: acá el productor y el consumidor son hijos
del **test**, no de un env. Es a propósito, porque la sección es sobre el
mecanismo. En el testbench real esto va adentro del agent, con el sequencer de un
lado y el driver del otro.

---

## Cuando alguien tiene que esperar

#### *Conectarlos: `put_export` y `get_export`*

- Es el mismo `connect()` de los analysis ports: de un lado el **port**, del otro
  el **export** que provee la FIFO
- `uvm_tlm_fifo` expone dos: `put_export` para el que pone y `get_export` para el
  que saca
- La regla que vale para todo TLM: **el port se conecta al export**, nunca dos
  ports entre sí

{{code:code/u5/threads/02-bloqueante/connect_phase.sv}}

{{code:code/u5/threads/02-bloqueante/result.txt}}

Note:
Dos cosas de la salida, que no son de esta sección pero se ven acá primero.
Los mensajes salen con `` `uvm_info ``, no con `$display`: por eso cada línea
trae sola el tiempo, la ruta jerárquica del componente y el archivo. Eso es
gratis, y es reporting, que ya vieron cerrando el día 3.
Y la otra: todos los `@` dicen 0. En este ejemplo no hay ni un `#delay` —el
handshake bloqueante suspende y reanuda dentro del mismo instante—, así que la
sincronización de los dos threads no la da el reloj: la da la FIFO de un solo
elemento. En el ejemplo que sigue aparecen los relojes y los números dejan de
ser 0.

---

## Cuando alguien tiene que esperar

#### *Comunicación NO bloqueante*

- Bloquear está bien mientras el que espera no tenga nada mejor que hacer. Con un
  reloj de por medio, quedarse esperando es perder un flanco
- Para eso están las versiones no bloqueantes: `try_put()` y `try_get()`
- Devuelven 1 si pudieron y **0 si no**, y siguen. Por eso son `function` y no
  `task`: no consumen tiempo

{{code:code/u5/threads/03-no-bloqueante/consumer.svh}}

{{code:code/u5/threads/03-no-bloqueante/results.txt}}

Note:
try_get() devuelve 0 y sigue: no espera. Es la diferencia entre un consumidor
que se cuelga hasta que haya dato y uno que puede hacer otra cosa mientras
tanto. Ojo que en `results.txt` los ceros no se ven —el consumer sólo imprime
cuando le toca dato—: están en la línea de tiempo de la slide que sigue.
El tiempo de cada línea no lo imprime el mensaje: lo pone UVM en el `@`, y por
eso acá se puede leer la carrera entre los dos relojes sin haber escrito una
sola línea de formateo.

---

## Cuando alguien tiene que esperar

#### *Comunicación NO bloqueante: la línea de tiempo*

![try_get() devuelve 0 cuando la FIFO está vacía](res/diagrams/threads_nonblocking.svg)
<!-- .element: class="grande" -->

- El producer pone un dato cada 17 ns y el consumer mira cada 14 ns: los relojes
  corren distinto, y en dos flancos la FIFO está vacía
- Ahí `try_get()` devuelve 0 y el consumer sigue. Con `get()` se quedaba esperando

Note:
Los números no son de un dibujo: son los `@` de los `Sent` y `Received` de
`results.txt`, la slide anterior.
El flanco que hay que hacer ver es el de 49 ns. El dato 3 recién se pone a los
51, así que el consumer llega un poquito antes, se va con las manos vacías y
vuelve 14 ns después. Con `get()` ese thread quedaba bloqueado justo ahí, y en
un testbench con reloj eso es un flanco perdido.

---

## Cuando alguien tiene que esperar

#### *Cómo se leen los diagramas TLM*

![Put port, TLM FIFO y get port entre dos threads](res/diagrams/threads_fig124.svg)
<!-- .element: class="grande" -->

- La convención vale para todo el material de UVM que vayas a leer después:
  - *Cuadrado:* put port / get port — el que **inicia** la llamada
  - *Círculo:* export — el que la **recibe** e implementa
  - *Rombo:* analysis port — el de los dos secciones anteriores

Note:
Vale la pena que el alumno se lleve la convención, porque es la misma en el *UVM
User Guide*, en la Verification Academy y en cualquier diagrama de testbench que
le pasen en el trabajo. No es de este curso.
La regla que ordena las tres figuras, y la que hace que un diagrama TLM se pueda
leer sin leyenda: **la punta cuadrada siempre apunta al círculo**. El que tiene
el cuadrado es el que llama; el que tiene el círculo es el que tiene el método
escrito. Por eso un port se conecta a un export y nunca a otro port.
El rombo es el caso especial que ya vieron: un analysis port puede apuntar a
muchos círculos a la vez, y por eso se dibuja distinto. Los otros dos son uno a
uno.

---

## Cuando alguien tiene que esperar

#### *Resumen de la unidad*

- La comunicación **inter**-thread entre objetos es el equivalente de lo que entre
  módulos hacen los puertos: pasar data de un thread a otro
- UVM la provee con *uvm_put_port*, *uvm_get_port* y *uvm_tlm_fifo*
- Cualquier objeto que quiera comunicarse con otro thread debe instanciar un port
  y conectarlo a una FIFO
- Ojo con el par de nombres: los *analysis port* de las dos secciones anteriores son
  **intra**-thread —`write()` es una `function` y corre en el thread del que
  publica—; esto es **inter**-thread, y por eso `put()` y `get()` son `task`
- Ahora tenemos que usar esto para conectar nuestro TB: vamos a separar la
  generación de estímulo del driver de la DUT

Note:
Vale cerrar con la tabla de dos columnas con que abrio hablar con varios objetos, porque
es la que ordena las cuatro unidades del día:
Intra-thread — `uvm_analysis_port` + `uvm_subscriber`, `write()` es `function`, no
consume tiempo, un solo thread, y sirve para el *analysis layer*.
Inter-thread — `uvm_put_port` / `uvm_get_port` + `uvm_tlm_fifo`, `put()` y `get()`
son `task`, bloquean, dos threads, y sirven para pasarle estímulo a un driver.
La forma corta de distinguirlas, y es la pregunta 3 del repaso: **si es una
`function`, es intra-thread.** Una función no puede tener un `@` ni un `#`, así
que no puede esperar a nadie. La palabra `task` es la que delata que hay dos
threads.
