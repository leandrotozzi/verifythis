## Un testbench sin un solo módulo

#### *El mismo testbench, sin un solo módulo*

- Esta sección **no agrega ninguna funcionalidad**:
  verifica lo mismo que el testbench de interfaces y BFM
- Lo que cambia es de qué está hecho. Los tres módulos —tester, scoreboard,
  coverage— pasan a ser tres **clases**, y el `initial` pasa a ser un método
- Aparece la pieza que los une: una clase `testbench` que instancia a las otras,
  les pasa la BFM y lanza sus threads. Nadie la instancia por vos
- Es la **última versión sin UVM**, y por eso vale mirarla con atención: todo lo
  que hace a mano esta clase, desde los tests lo va a hacer la librería
- La pregunta con la que hay que salir de la sección: *¿qué parte reemplaza a qué?*

Note:
El objetivo real de la sección no es enseñar nada nuevo, es dejar un punto de
comparación. Si el alumno puede mirar `testbench.svh` y decir "esto es el env,
esto es el build_phase, esto es el run_phase", el día 3 arranca cuesta abajo.
Vale escribir la tabla en el pizarrón antes de mostrar el código, y volver a ella
al final del día 3:

| Acá, a mano | Desde los tests |
| `testbench.execute()` que hace `new()` de los tres | `build_phase` del env |
| pasar la BFM por el constructor | `uvm_config_db` |
| `fork ... join_none` | UVM corre un `run_phase` por componente |
| `$finish` adentro del tester | objections |

Y decir en voz alta lo que se ve solo: no hay un solo `module` en las clases del
testbench. Los módulos quedaron para el DUT, el reloj y la interface — que es
justamente lo que se sintetiza.

---

## Un testbench sin un solo módulo

- Un testbench de módulos funciona hasta que hay que reusarlo: para cambiar el
  estímulo hay que editar el módulo, y para tener dos versiones hay que copiarlo
- Con clases, cambiar el estímulo es **extender una clase**, y las dos versiones
  conviven. Eso es todo lo que compra la OOP acá

#### *El VTALU TB, pieza por pieza*

- top: Instancia la clase testbench
- testbench: Top-Level Class
- tester: Genera los estímulos
- scoreboard: Chequea que la VTALU está funcionando
- coverage: Captura la información de cobertura funcional

![El árbol de objetos: el top elabora, y adentro viven la clase testbench y sus tres piezas](res/diagrams/tb-en-objetos_arbol.svg)
<!-- .element: class="grande" -->

Note:
Es el mismo testbench de interfaces y BFM, pero en objetos: cambia la forma, no lo
que hace. Si se puede, mostrarlos lado a lado.
El dibujo es el que hay que poder redibujar de memoria al final del día, y la
línea que lo parte al medio es la que importa: arriba lo que se **elabora** —el
módulo, el DUT, la interface—, abajo lo que alguien tiene que **crear**. Un
objeto que nadie crea es un handle nulo, y ése es el error de la primera tarde.
Es la última versión sin UVM. Desde los tests lo mismo lo arma UVM, y el
alumno tiene que poder decir qué parte reemplaza a qué.

---

## Un testbench sin un solo módulo

#### *El top: lo único que sigue siendo un módulo*

- El `top` sigue siendo un módulo, y va a seguir siéndolo hasta el final del
  curso: las clases no se elaboran, alguien tiene que existir antes del tiempo 0
- Importa el package con las clases, instancia el DUT y la BFM, y declara el
  handle al `testbench`
- Adentro del `initial`, dos líneas: `new(bfm)` y `execute()`

{{code:code/u3/tb-en-objetos/top.sv}}

Note:
El `top` sigue siendo un módulo y va a seguir siéndolo hasta el final del curso,
incluso con UVM. La razón es que **las clases no se elaboran**: alguien tiene que
existir antes del tiempo 0 para instanciar el DUT, la interface y el reloj.
El detalle que hay que señalar con el dedo es el pasaje de la BFM: acá se la
pasan al constructor, `new(bfm)`, y funciona porque el `top` conoce a la clase.
En UVM esa línea no va a existir — el test lo crea la factory y nadie le puede
pasar argumentos. Por eso aparece el `uvm_config_db` en los tests.
Buena pregunta para dejar picando: ¿por qué el `import` del package está antes de
todo? Porque las clases viven en un package y el módulo tiene que verlas. Es la
primera vez que el orden de compilación importa, y no va a ser la última.

---

## Un testbench sin un solo módulo

#### *La clase `testbench`: quien arma y arranca*

- Hay **un** objeto arriba de todo que instancia a los demás, les pasa lo que
  necesitan y lanza sus threads. Todo testbench OOP tiene uno
- Acá lo escribimos a mano: tres `new()` y un `fork ... join_none`
- Desde el `env` esa clase se va a llamar `uvm_env`, los `new()` van a ser
  `type_id::create()` en el `build_phase`, y el `fork` lo va a hacer UVM sola

{{code:code/u3/tb-en-objetos/tb_classes/testbench.svh}}

Note:
Ésta es la clase que UVM se va a llevar puesta, así que conviene leerla línea por
línea: `new()` de los tres objetos, `fork ... join_none` para arrancarlos, y
listo. Eso es un `env` escrito a mano.
Dos cosas para marcar. La primera es el `virtual vtalu_bfm bfm`: la palabra
`virtual` acá **no tiene nada que ver** con los métodos virtuales de polimorfismo.
Una virtual interface es un handle a una interface que se va a asignar más
adelante — es el equivalente, en el mundo de los objetos, a la port list de un
módulo. Es la tercera acepción de `virtual` en SystemVerilog y por eso conviene
nombrarla en voz alta.
La segunda es el `join_none`: los tres objetos corren en threads separados y
`execute()` vuelve enseguida. Si fuera `join`, el testbench esperaría a que los
tres terminen y el scoreboard no termina nunca. Es la misma decisión que UVM
toma sola cuando corre un `run_phase` por componente.
Y una que se pregunta siempre: ¿quién termina la simulación? El `$finish` del
tester, adentro de `execute()`. Es feo y se nota: un objeto decide por todos. En
los tests eso pasa a ser un objection, que es la forma prolija de lo mismo.

---

## Un testbench sin un solo módulo

#### *La clase `tester`: el estímulo, sin cables*

- Manda mil operaciones al azar, con el mismo sesgo a los bordes del testbench convencional:
  el objetivo sigue siendo llenar los bins del covergroup
- Contra la versión modular cambian dos cosas y nada más:
  - la BFM llega por una **variable** —una *virtual interface*— en vez de por una
    port list
  - el `initial` es ahora un método, `execute()`, que alguien tiene que llamar

{{code:code/u3/tb-en-objetos/tb_classes/tester.svh#execute}}

Note:
Acá hay una trampa **puesta a propósito** y conviene no delatarla ahora: mirá la
declaración de `get_op()`. Dice `protected function`, no `protected virtual
function`. Sin `virtual`, `execute()` va a llamar siempre a la de esta clase,
aunque el objeto sea de una clase derivada — que es exactamente lo que vieron en
polimorfismo con `servir()`.
Eso es el ejercicio del día 2, y está bueno que se lo coman: la herencia no se
nota hasta que alguien escribe `virtual`, y eso se entiende mucho mejor
sufriéndolo que leyéndolo.
Lo otro que hay que señalar es lo que **no** está en esta clase: el protocolo.
`reset_alu()` y `send_op()` siguen viviendo en la BFM, igual que en interfaces y BFM,
y el tester los llama con `bfm.send_op(...)`. Esa es toda la gracia del BFM y por
eso se sostiene sin cambios hasta el final del curso: la clase de arriba pide una
operación, y ni sabe que existe un `done`.
Y el detalle que se ve al principio del `execute()`: las cuatro operaciones
dirigidas antes del `repeat (1000)` no están de adorno. Son el reset, la
multiplicación después del reset y la mult repetida — o sea, tres puntos del plan
de verificación del testbench convencional que al random no le conviene esperar.

---

## Un testbench sin un solo módulo

#### *El scoreboard: el `always` se volvió una task*

- La lista de sensibilidad no existe en una clase. Lo que la reemplaza es un
  `forever` con la espera adentro — misma semántica, escrita como código
  secuencial

{{code:code/u3/tb-en-objetos/tb_classes/scoreboard.svh#execute}}

Note:
La traducción que hay que señalar: el `always @(posedge done)` del testbench
modular acá es un `forever begin @(posedge bfm.done) ... end`. Es la misma
espera, escrita como código secuencial adentro de un método. Un objeto no tiene
lista de sensibilidad; tiene una task que se bloquea.
El `#1` de la primera línea es de esos detalles que se pagan caro: sin él, el
scoreboard lee las señales en el mismo instante en que `done` sube y se puede
comer una carrera de deltas. Con él, lee cuando ya está todo asentado. Es la
razón de que en verificación se muestree en el flanco que **no** usa el diseño.
Y lo que este scoreboard todavía hace mal, para dejarlo picando: lee la operación
del **cable** (`bfm.op_set`) en el momento del resultado. Funciona porque el
protocolo obliga a mantener los operandos estables, pero es frágil — el día que
el DUT tenga varias operaciones en vuelo, se rompe. En los analysis ports el scoreboard
va a comparar contra una cola de comandos que le manda el monitor, y eso sí
escala.

---

## Un testbench sin un solo módulo

#### *La clase `coverage`: el covergroup adentro de un objeto*

{{code:code/u3/tb-en-objetos/tb_classes/coverage.svh#sampling}}

- El covergroup es **el mismo** del testbench convencional, línea por línea. Lo que cambió es
  dónde vive
- En un módulo, declarar el covergroup alcanzaba. En una clase hay que
  construirlo: el `new()` de la clase hace `op_cov = new()`
- El `execute()` es el `always @(negedge clk)` de antes, escrito como `forever`:
  copia las señales de la BFM y llama a `sample()`

Note:
El `op_cov = new()` adentro del constructor es la trampa de la slide: en un
módulo el covergroup se instancia solo, en una clase **no**. Si te lo olvidás, el
código compila, corre, y el reporte dice 0 %. Es la misma trampa muda del testbench convencional, con una vuelta de tuerca más.
Los bins de transición siguen entre `` `ifndef VERILATOR ``, igual que en el testbench convencional, y por la misma razón: Verilator 5.052 todavía no los compila.
Lo que hay que dejar dicho antes de los analysis ports: acá se muestrea en el **flanco
del reloj**, o sea que se cuentan ciclos. Cuando el `coverage` sea un subscriber
va a muestrear cuando **llega un comando**, y ahí se van a contar operaciones —
que es lo que el plan de verificación pedía desde el testbench convencional.

---

## Un testbench sin un solo módulo

#### *El mapa del día 3: qué reemplaza a qué*

| Acá, a mano | Desde los tests |
| --- | --- |
| `testbench.execute()` con tres `new()` | el `build_phase` del `env` |
| pasar la BFM por el constructor | `uvm_config_db` |
| `fork ... join_none` | UVM corre un `run_phase` por componente |
| `$finish` adentro del tester | objections |
| elegir el tester editando el código | `set_type_override` de la factory |
| `$display` que se pone y se borra | `` `uvm_info `` y el techo de verbosidad |

- Éste es el testbench **completo**, sin UVM y sin nada que falte. Funciona
- Todo lo que viene en el día 3 reemplaza una fila de esta tabla, **y nada más**
- Volvemos a esta slide al cerrar el día, para tacharlas

Note:
Ésta es la slide que conviene dejar anotada, porque es el mapa entero del día 3.
La afirmación fuerte hay que hacerla explícita: **UVM no agrega funcionalidad
acá**. El testbench de esta unidad hace todo lo que va a hacer el del env. Lo que agrega es convención — que la columna de la izquierda esté resuelta
igual en todos los testbenches del mundo.
Y la pregunta honesta que va a aparecer: "¿entonces para qué?". Para que el que
llega al proyecto sepa dónde mirar sin leer el testbench entero, y para que el
tester nuevo cueste cuatro líneas en vez de una clase. Los dos beneficios son de
escala, y por eso en un ejemplo de cien líneas UVM parece de más — hay que
decirlo así, en vez de vender humo.
Al cerrar el día 3, con el `env` y el override ya vistos, se vuelve acá y se lee
la columna de la derecha de corrido. Ahí el día cierra solo.

---

## Un testbench sin un solo módulo

#### *Resumen de la unidad*

- El testbench del día 1 **sin un solo módulo**: las mismas tres piezas, más la
  clase que las une —`testbench`—, que es el antepasado directo del `uvm_env`
- El `top` sigue siendo un **módulo** y lo va a ser hasta el final, y la BFM
  llega por una **virtual interface**: es la única forma que tiene una clase de
  tocar señales
- Es la **última versión sin UVM**. De acá en adelante, cada pieza que
  escribimos a mano tiene una clase de la librería que la reemplaza —
  `execute()` va a ser el `run_phase`

Note:
La slide con la que conviene cerrar el día 2 entero, porque deja el puente
armado. La pregunta que hay que dejar planteada: *¿qué parte reemplaza a qué?*
El día 3 la contesta pieza por pieza, y arranca cuesta abajo si el alumno sale
de acá pudiendo dibujar el árbol de objetos en el pizarrón.
Y el argumento de por qué valió la pena todo el día: con módulos, cambiar el
estímulo es editar el archivo. Con clases es extender una clase, y las dos
versiones conviven. Eso es el ejercicio que sigue.
