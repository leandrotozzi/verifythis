## Cuando alguien tiene que esperar

#### *Esto ya lo hacías, con módulos*

- El nombre asusta y el mecanismo lo venís usando desde siempre: dos módulos con
  puertos, cada uno con su `always`, pasándose datos

{{code:code/u5/threads/01-modulos/modules.sv#producer-and-consumer}}

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
`build_phase` como cualquier otro componente, con `new("nombre", this)`. No es un
campo de datos: lleva padre, y por eso aparece en `print_topology()`. Pero
tampoco es un `uvm_component` — `uvm_put_port` extiende `uvm_port_base #(IF)`, y
el que se cuelga del árbol es un `uvm_port_component` interno que el port se
arma solo (`uvm_port_base.svh:137`). La FIFO de la slide siguiente sí es un
component de verdad.
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
la FIFO en el `connect_phase` en vez del `build_phase`. UVM lo ataja con un fatal
`ILLCRT` —*"It is illegal to create a component ('x' under 'y') after the build
phase has ended"* (`uvm_component.svh:1721`)—, y por lo menos avisa con el nombre.
Olvidarse del `connect()` de un port de `put`/`get` **también** avisa, y bien:
`resolve_bindings()` reporta un `UVM_ERROR [Connection Error] connection count of
0 does not meet required minimum of 1` con el nombre del port, en
`end_of_elaboration` y antes de que corra un solo ciclo (`uvm_port_base.svh:886`).
El que se calla es el **analysis port**, porque su mínimo es 0: un `write()` a un
port sin conectar es legal y no imprime nada. Es la misma asimetría de la sección
anterior, y es la que hay que recordar.
Y una que conviene señalar de paso: acá el productor y el consumidor son hijos
del **test**, no de un env. Es a propósito, porque la sección es sobre el
mecanismo. En el testbench real esto va adentro del agent, con el sequencer de un
lado y el driver del otro.

---

## Cuando alguien tiene que esperar

#### *Conectarlos: `put_export` y `get_export`*

- Es el mismo `connect()` de los analysis ports: de un lado el **port**, del otro
  el **export** que provee la FIFO
- `uvm_tlm_fifo` expone doce handles; los dos que se usan son `put_export` para el
  que pone y `get_export` para el que saca —que es un alias de `get_peek_export`,
  que es el nombre que vas a ver en `print_topology()`—
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
  - *Rombo:* analysis port — el de las dos secciones anteriores

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

#### *`fork`: las tres formas de arrancar en paralelo*

```systemverilog
fork  wait_done();  count_cycles();  join        // sigue cuando terminaron LAS DOS
fork  wait_done();  count_cycles();  join_any    // sigue con LA PRIMERA; la otra sigue viva
fork  wait_done();  count_cycles();  join_none   // sigue YA; las dos quedan corriendo
```

| Variante | El padre sigue… | Para qué se usa |
| --- | --- | --- |
| `join` | cuando terminan **todas** | dos chequeos que tienen que cerrar los dos |
| `join_any` | cuando termina **la primera** | respuesta contra timeout |
| `join_none` | **enseguida** | lanzar threads que viven todo el test |

- La diferencia entre las tres no es cómo arrancan —las tres arrancan todo a la
  vez— sino **cuándo sigue el que las arrancó**
- `join_none` ya lo usaron: es el `fork` de la clase `testbench` del día 2, y es
  lo que UVM hace sola con un `run_phase()` por componente
- La rama que quedó viva después de un `join_any` **no se muere sola**. Sigue
  hasta que termine — o hasta que alguien la mate, que es la slide siguiente

Note:
Es la unidad que se llama *threads* y hasta acá los threads los puso UVM. Esta
slide y las dos siguientes son las tres palabras del lenguaje con las que se
escribe cualquier monitor o driver de producción, y las tres entran en una tabla.
El punto que conviene repetir, porque es donde todo el mundo se confunde la
primera vez: **las tres arrancan igual**. Los procesos del `fork` se lanzan todos
en el mismo instante en las tres variantes. Lo único que cambia es qué hace el
proceso padre inmediatamente después, y por eso la columna del medio es la que
hay que leer.
Un ejemplo por variante alcanza para que se fije. `join`: mandar el estímulo y
contar los ciclos, y no seguir hasta que las dos terminen. `join_any`: esperar la
respuesta del DUT **o** que venza un timeout, lo que pase primero. `join_none`:
el `run_phase` del monitor, que arranca y se queda mirando para siempre mientras
el resto del testbench sigue.
Y el enganche con el día 2, que conviene hacer explícito: la clase `testbench`
escrita a mano usaba `fork ... join_none` para arrancar los tres objetos. No era
una casualidad ni un truco — es exactamente lo que hace UVM cuando corre la
`run_phase` de cien componentes a la vez.


---

## Cuando alguien tiene que esperar

#### *`disable fork` y `wait fork`: apagar lo que quedó prendido*

```systemverilog
// El idiom de la respuesta contra el timeout. El fork de afuera AÍSLA
fork begin
   fork
      begin  wait_done();          `uvm_info("BFM", "llegó", UVM_LOW)  end
      begin  repeat (100) @(posedge clk);  `uvm_error("BFM", "timeout")   end
   join_any
   disable fork;      // mata a la hermana que perdió, y a nadie más
end join

wait fork;            // no mata a nadie: espera a TODOS los hijos de este thread
```

- `disable fork` mata **todos los procesos hijos del thread que lo ejecuta**. Por
  eso el `fork begin ... end join` de afuera: sin él, se lleva puesto también lo
  que ya estaba corriendo
- `wait fork` es lo contrario: no mata nada, **espera** a que terminen los hijos.
  Es lo que usa un test para no cerrar con transacciones en vuelo
- El par `join_any` + `disable fork` es el timeout de todo BFM de producción. Se
  escribe una vez y se copia siempre
- Gana la que termine primero: si `done` llega antes de los 100 flancos, el
  `uvm_error` del timeout no se imprime; si no, el `uvm_info` del `"llegó"` no se
  imprime. El `disable fork` mata a la que perdió

Note:
El `disable fork` sin el `fork ... join` de aislamiento es el bug clásico de esta
construcción y vale dibujarlo: mata a **todos** los hijos del thread actual, no a
los del `fork` de al lado. Si el `run_phase` ya había lanzado un monitor con
`join_none` y después hace un `disable fork` suelto, el monitor se muere y el
testbench sigue corriendo ciego. No hay error, no hay warning: hay un log que
deja de tener líneas.
La forma de acordarse es pensar en el alcance: `disable fork` no dice *cuál*
fork. Dice "los hijos de este proceso". El `fork begin ... end join` de afuera
crea un proceso nuevo cuyos únicos hijos son los dos del `join_any`, y por eso el
`disable` no puede llegar más lejos.
`wait fork` es la pareja tranquila y se usa mucho menos de lo que se debería: es
lo que hace falta al final de una sequence o de un `run_phase` que lanzó cosas
con `join_none` y no quiere que la fase termine con la mitad del estímulo en el
aire. En UVM el mismo problema se resuelve con objections — pero adentro de una
task, `wait fork` es la respuesta.


---

## Cuando alguien tiene que esperar

#### *⚠ La trampa: el índice del `for` adentro del `fork`*

```systemverilog
int i;                                  // declarado AFUERA del for: uno solo
for (i = 0; i < 3; i++)
   fork  $display("i = %0d", i);  join_none      //  i = 3   i = 3   i = 3

for (int j = 0; j < 3; j++)             // declarado EN el for: uno por vuelta
   fork  $display("j = %0d", j);  join_none      //  j = 0   j = 1   j = 2

for (i = 0; i < 3; i++)
   fork  begin
      automatic int k = i;              // la copia se hace AL EJECUTARSE el fork
      $display("k = %0d", k);
   end join_none                                 //  k = 0   k = 1   k = 2
```

- Un `join_none` **no ejecuta nada todavía**: deja el thread listo y sigue. Para
  cuando el thread corre, el `for` ya terminó y la variable vale lo último
- Si la variable se declara **adentro** del `for`, cada vuelta tiene la suya y no
  hay problema. Es lo que dice el LRM y lo que Verilator hace
- Si viene de afuera —un `int` del `run_phase`, un campo de la clase— hay que
  **copiarla** con un `automatic` como primera línea del bloque
- Medido en Verilator 5.052: las tres líneas de arriba imprimen `3 3 3`,
  `0 1 2` y `0 1 2`

Note:
Es el bug de threads que más caro sale y el que menos se ve leyendo el código,
porque las tres versiones se parecen muchísimo. Conviene hacer la pregunta antes
de mostrar la respuesta: *"¿qué imprime la primera?"*. Casi todo el mundo dice
`0 1 2`.
La explicación que hay que dejar es una sola frase: **`join_none` no corre el
thread, lo agenda**. El `for` sigue de largo hasta el final, y recién ahí el
scheduler le da lugar a los tres threads — que leen la variable *ahora*, no
cuando se los lanzó. Con `i` afuera hay una sola variable, y ahora vale 3.
La versión con `for (int j …)` funciona y conviene decir por qué, para que no
parezca magia: el LRM declara automática la variable de un `for` que la declara,
así que cada vuelta tiene su copia. Está medido acá, no es teoría.
El caso donde igual hace falta el `automatic` es el que aparece en la vida real:
el índice no es del `for`, es un campo de la clase o un argumento de la task.
Ahí no hay copia por vuelta y hay que hacerla a mano. La regla práctica para
llevarse: **si un thread lanzado con `join_none` lee una variable de afuera,
copiala en un `automatic` en su primera línea.**

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
- Y abajo de todo está `fork`: `join` espera a todos, `join_any` a la primera,
  `join_none` a ninguno. `disable fork` mata a los hijos y `wait fork` los espera
- Ahora tenemos que usar esto para conectar nuestro TB: vamos a separar la
  generación de estímulo del driver de la DUT

Note:
Vale cerrar con la tabla de dos columnas con que abrió hablar con varios objetos, porque
es la que ordena las cuatro unidades del día:
Intra-thread — `uvm_analysis_port` + `uvm_subscriber`, `write()` es `function`, no
consume tiempo, un solo thread, y sirve para el *analysis layer*.
Inter-thread — `uvm_put_port` / `uvm_get_port` + `uvm_tlm_fifo`, `put()` y `get()`
son `task`, bloquean, dos threads, y sirven para pasarle estímulo a un driver.
La forma corta de distinguirlas, y es la pregunta 3 del repaso: **si es una
`function`, es intra-thread.** Una función no puede tener un `@` ni un `#`, así
que no puede esperar a nadie. La palabra `task` es la que delata que hay dos
threads.
