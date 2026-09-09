## Transactions

#### *El testbench está bien repartido, y el dato no*

- El testbench ya está bien repartido, pero **los datos siguen siendo una
  `struct`**: `command_s` para los comandos y una `shortint` pelada para los
  resultados
- Una `struct` no hace nada por sí sola. Imprimir un comando es un `$sformatf`
  escrito a mano, y está escrito **cuatro veces**: tester, driver, coverage y
  scoreboard
- Lo mismo con randomizar y con comparar: cada componente se arma el suyo, y el
  día que la `struct` gana un campo hay que acordarse de los cuatro
- Y el resultado ni siquiera es una `struct`: es un `shortint` **pelado**, así
  que el `ovf` del VTALU —la segunda salida— no tiene dónde viajar
- Una clase, en cambio, tiene métodos: los datos y lo que se hace con ellos viven
  juntos, y el resto del testbench se achica

Note:
La pregunta honesta del alumno es "¿y por qué no una struct?". La respuesta: la
struct no se randomiza sola, no se compara sola y no se imprime sola. Todo lo
que el testbench hacía a mano con command_s pasa a ser un método de la clase, y
el resto del testbench se achica.
El cuarto bullet es el argumento más concreto y conviene apoyarse en él: hasta
acá el analysis port del resultado lleva un `shortint`, o sea **un número**. El
VTALU tiene dos salidas —`result` y `ovf`— y por eso el scoreboard de las
unidades anteriores chequea la mitad del DUT y la otra mitad la deja pasar. Con
un `result_transaction` con dos campos, el chequeo del `ovf` aparece solo. Es la
primera vez en el curso que la clase no es prolijidad: es la única forma.

---

## Transactions

#### *Una transaction es un dato con los métodos que operan sobre ese dato*

- Es la palabra que usa la industria, y no hay ninguna clase mágica atrás: una
  **transaction** es eso y nada más
- Los métodos son cuatro, y son siempre los mismos:
  - `randomize()` — se llena sola, respetando sus `constraint`
  - `convert2string()` — se imprime sola
  - `do_copy()` — se copia sola
  - `do_compare()` — se compara sola
- Lo que cambia no es el dato: es **quién sabe cosas sobre él**. El `tester`
  dejaba de saber qué valores son legales; ahora sólo dice *"randomizate"*
- Y el resto del testbench se achica: los cuatro `$sformatf` escritos a mano se
  vuelven una llamada a `convert2string()`

Note:
La frase de la slide es la definición que hay que dejar escrita en el pizarrón:
**un dato con los métodos que operan sobre ese dato**.
El tercer bullet es el cambio de reparto de responsabilidades de la sección:
hasta hoy el `tester` sabía qué valores eran legales —tenía un `get_data()` con
el sesgo escrito a mano—. Desde hoy eso vive en la transaction, en una
`constraint`.
La pregunta para tirar: si mañana el DUT acepta operandos de 16 bits, ¿cuántas
clases hay que tocar? Una.


---

## Transactions

#### *Definir una transaction: de qué clase se extiende*

- Las transactions se definen extendiendo la clase base *uvm_sequence_item* y escribiendo los siguientes métodos:
  - do_copy()
  - do_compare()
  - convert2string()
- Lo que sigue es transformar la vieja estructura `command_s` en una clase,
  `command_transaction`, método por método

{{code:code/u6/transactions/command_s.sv}}

Note:
Ojo con la clase base, porque el material viejo dice otra cosa. La cadena es
`uvm_sequence_item` → `uvm_transaction` → `uvm_object`, y se extiende siempre
la primera.
Dos razones. La chica: en IEEE 1800.2 `uvm_transaction` es una *virtual class*,
no se puede instanciar sola. La grande: una `uvm_sequence` sólo sabe mandar
`uvm_sequence_item`. Si la transaction extiende `uvm_transaction` a secas,
todo lo del día 6 —`start_item` / `finish_item`— no compila.
O sea que la clase base que elegimos hoy es la que nos deja seguir mañana.

---

## Transactions

#### *Los campos randomizados: el "antes"*

- Hoy el estímulo se arma con dos funciones escritas a mano, `get_op()` y
  `get_data()`, que sortean los valores con `$random` y `$urandom_range`
- El rango legal de `A` y `B` y el sesgo a los bordes son propiedades **del
  dato**, no del test — y sin embargo viven en el tester
- SystemVerilog ya trae esto hecho, y no hace falta escribir ni un `$urandom`

{{code:code/u6/transactions/prev-random.sv}}

Note:
Conviene leer este código como el "antes" y hacer la pregunta antes de dar la
respuesta: ¿qué parte de esto es *del test* y qué parte es *del dato*? El rango
legal de A y B, y el sesgo a los bordes, son propiedades del dato — no tienen
nada que ver con qué querés probar.
El `$random` y el `$urandom_range` escritos a mano son el síntoma: cada
componente que quiera un comando válido tiene que repetirlos. Y si el DUT cambia,
hay que acordarse de todos.
El remate para la slide siguiente: SystemVerilog ya trae esto hecho, y no hace
falta escribir ni un `$urandom`.

---

## Transactions

#### *Los campos randomizados: el "después"*

- Toda clase de SystemVerilog trae un `randomize()` implícito, que elige valores
  para los campos marcados `rand`
- `get_op()` desaparece: un `enum` se randomiza solo sobre sus valores legales
- `get_data()` también, y lo reemplaza una `constraint` con `dist`, que es donde
  se declara el sesgo a los bordes

{{code:code/u6/transactions/tb_classes/command_transaction.svh|lines=1-24}}

Note:
Tres cosas de este código, en orden de lo que se olvida.
`rand` adelante de cada campo: sin eso el campo no entra en el sorteo y
`randomize()` lo deja como estaba, **sin avisar**. Es el primer lugar donde
mirar cuando un valor sale siempre igual.
El `dist` con `:/` y no `:=`: reproduce el sesgo a los bordes que el `get_data()`
del testbench convencional hacía a mano. La diferencia entre los dos operadores es una unidad
entera del curso, y no es un detalle de estilo — con `:=` el bin `00` sale 1 vez
cada 256 y los casos borde no se llenan nunca.
Y el `op` sin constraint: un `enum` se randomiza sobre sus valores, así que
también van a salir `no_op` y `rst_op`. Eso es a propósito — el plan de
verificación pide operaciones después de un reset.


---

## Transactions

#### *El constructor: un `uvm_object` no tiene padre*

- *uvm_sequence_item* extiende *uvm_transaction*, y ésta *uvm_object* — o sea que una transaction **no** es un *uvm_component*. Por lo tanto, tiene un constructor más simple
- Una transaction **no vive en el árbol del testbench**: ese árbol lo forman los
  *uvm_components*, y es el que UVM recorre en `build_phase`. Sin lugar en el
  árbol no hay padre, y por eso el constructor sólo pide un `name`
- Los objetos se crean y se destruyen todo el tiempo mientras la simulación
  corre; los componentes se construyen una vez, antes de arrancar, y se quedan
- Igual conviene darles nombre: es el que aparece en los mensajes de UVM

{{code:code/u6/transactions/tb_classes/command_transaction_constructor.svh}}

Note:
Es la distinción que hay que dejar clara: *component* es estructura —está en el
árbol, tiene padre, tiene fases—; *object* es dato —se crea, viaja por el
testbench y se tira—. Las dos cosas son clases de UVM, pero sólo una arma la
jerarquía.
Truco para acordarse: si lo podés dibujar en el diagrama de bloques del
testbench, es un component. Si viaja por una flecha del diagrama, es un object.

---

## Transactions

#### *`do_copy()`: copiar el objeto, no el handle*

- `uvm_object` trae dos métodos hechos: `copy()`, que vuelca los datos sobre otro
  objeto **que ya existe**, y `clone()`, que además crea el objeto nuevo
- Los dos funcionan sólo si la clase implementa `do_copy()`: la librería sabe
  copiar, pero no sabe **qué campos** tiene tu transaction
- Es el mismo patrón que el resto de la sección: `copy()` es el que se llama,
  `do_copy()` es el que se escribe
- La única diferencia es el argumento: tiene que ser un `uvm_object` —de ahí el `$cast`—. UVM lo llama *rhs* (*right hand side*) por convención, no por requisito

{{code:code/u6/transactions/tb_classes/command_transaction_do_copy.svh}}

Note:
El patrón es el de las jerarquías de clases, con dos reglas de UVM encima.
La primera, la que hace que compile: el argumento tiene que ser de tipo
`uvm_object` —la clase base de todo—, porque lo que SystemVerilog exige para que
el override virtual funcione es que coincidan el tipo y la dirección, no el
nombre. `rhs` es el identificador que usa la firma de `uvm_object::do_copy` y por
eso lo copia todo el mundo, pero podés llamarlo como quieras. Lo primero que hay
que hacer es
castear. Y como el `$cast` chequea en runtime, va con su `uvm_fatal`: si alguien
intenta copiar un `result_transaction` sobre un `command_transaction`, querés
enterarte ahí y no tres componentes más adelante.
La segunda: el `super.do_copy(rhs)` va **antes** de tocar los campos propios. Es
la misma disciplina de las jerarquías de clases y acá importa más, porque `uvm_object` tiene
campos propios que uno no ve.
Y el detalle que confunde a todos: vos escribís `do_copy()`, pero **nunca lo
llamás**. El testbench llama a `copy()`, que está en `uvm_object`, y ésa se
encarga de invocar tu `do_copy()`. Es el mismo reparto que las fases — vos ponés
la parte de abajo, la librería maneja el protocolo.


---

## Transactions

#### *La regla MOOCOW: compartir sí, modificar no*

- Varios componentes pueden ver el mismo dato si tienen handles al mismo objeto.
  Es barato y funciona — mientras nadie lo modifique
- La regla que lo sostiene se llama **MOOCOW** —*Manual Obligatory Object Copy On
  Write*—, y así la bautiza *The UVM Primer*, de Ray Salemi
- Dice esto: compartir un handle está bien **siempre que no toques el objeto**.
  El que quiere modificar, copia primero
- Es una disciplina del equipo, no algo que el lenguaje imponga. UVM sólo pone la
  herramienta: `clone()`, que devuelve un `uvm_object` y hay que castear

Note:
El nombre es una joda del *UVM Primer*, pero la regla es la que evita el
bug más caro de las jerarquías de clases: mandaste la transaction al scoreboard, seguís
teniendo el handle, la modificás para la siguiente, y el scoreboard termina
comparando contra datos que cambiaron después de que él los recibió. No falla
siempre — falla cuando hay carga, que es cuando peor viene.
La versión práctica, sin siglas: **el que produce el dato no lo vuelve a tocar
después de publicarlo.** Si necesitás cambiarlo, cloná.
Fijate cómo lo cumple el `tester` de esta sección: no reusa el handle. Cada
vuelta del `repeat` hace un `create()` nuevo. Es más barato que clonar y evita
la discusión.
Y hay una excepción documentada que van a ver en el día 6: el driver escribe el
resultado adentro del item que le prestó la sequence. Está acordado entre las dos
partes y es el único lugar del testbench donde se hace.


---

## Transactions

#### *`clone_me()`: el `$cast` escrito una sola vez*

- Como `clone()` devuelve un `uvm_object`, cada componente que lo use termina
  escribiendo su propio `$cast` — el mismo, repetido
- La convención del *UVM Primer* es agregarle a la transaction un
  `clone_me()` que haga las dos cosas y devuelva ya el tipo correcto
- No lo trae UVM: es cuatro líneas escritas una vez en el dato, para que ninguno
  de los que lo usan tenga que acordarse del cast

{{code:code/u6/transactions/tb_classes/command_transaction_do_clone.svh}}

Note:
Es un método de tres líneas y existe por una sola razón: `clone()` devuelve un
`uvm_object`, así que todo el que lo use tiene que castear. Escribir el `$cast`
una vez adentro de la clase es mejor que escribirlo cincuenta veces afuera.
El nombre no está en el estándar: `clone_me()` es una convención del *UVM
Primer*. En un proyecto ajeno puede llamarse distinto o no existir — y ahí vas a
ver el `$cast` repetido en cada llamador.
Y la trampa que hay que nombrar: `clone()` llama a `create()` y después a
`copy()`, que termina en tu `do_copy()`. Si `do_copy()` se olvida un campo, el
clon sale incompleto y **nadie avisa**. Es el mismo agujero de las jerarquías de clases, con
otro nombre.

---

## Transactions

#### *`do_compare()`: comparar dos objetos sin escribir un `if` por campo*

- `compare()` lo trae `uvm_object` y devuelve 1 si los dos objetos son iguales.
  Es el que se llama; el que se **escribe** es `do_compare()`
- Toma dos argumentos: el `rhs` —el otro objeto— y un `uvm_comparer`, que es la
  política de comparación: cuántas diferencias reportar y con qué verbosidad
- Casi nadie toca el comparer, pero hay que declararlo porque la firma lo pide

{{code:code/u6/transactions/tb_classes/command_transaction_do_comparer.svh}}

Note:
Dos cosas que se copian mal.
El `$cast` acá **no** va con `uvm_fatal`: si el tipo no da, la respuesta correcta
es `same = 0` —son distintos, obvio, si ni siquiera son de la misma clase—, no
matar la simulación. Es la diferencia con `do_copy()`, donde un tipo equivocado
sí es un bug del testbench. Vale mostrarlo al lado.
Y el `super.do_compare()` va **encadenado con `&&`**, no llamado y descartado. El
error clásico es escribir `super.do_compare(rhs, comparer);` en una línea suelta y
después `same = (A == rhs.A) && ...`: compila, corre, y silenciosamente deja de
comparar todo lo de la clase de arriba.
El `uvm_comparer` del segundo argumento es la política —cuántas diferencias
reportar, con qué verbosidad—. Casi nadie lo toca, pero hay que declararlo porque
la firma lo pide.


---

## Transactions

#### *`convert2string()`: la transaction se imprime sola*

- Es el método que devuelve el objeto como texto. Se escribe **una vez**, y lo
  usan el scoreboard, el monitor y cualquiera que tenga que reportar
- `$sformatf()` arma el string con los mismos especificadores de formato de
  siempre
- Y el detalle que hace legible un log: un `enum` tiene `name()`, que devuelve
  `add_op` en vez de `3'b001`. Sin eso el error dice un número y nadie lo lee

{{code:code/u6/transactions/tb_classes/command_transaction_convert2string.svh}}

Note:
Es el método que más se usa de los tres, y el que menos atención recibe: cada
mensaje del scoreboard y de los monitores del resto del curso sale de acá.
El `.name()` del `enum` es el detalle que cambia el día: sin él, el log dice
`op: 4` y hay que ir a buscar el `typedef`; con él dice `op: mul_op`. La regla
para llevarse: **si un campo es un enum, en el log va su nombre, nunca su valor.**
Vale nombrar el pariente que UVM trae y el curso no usa: `print()` y `sprint()`,
que imprimen la transaction sola si registraste los campos con las macros
`` `uvm_field_* `` — o si escribís `do_print()`, que es el equivalente manual de
`convert2string()` y no aparece en ninguna slide del curso. Ojo con eso: sin las
macros y sin `do_print()`, un `t.print()` de las transactions de acá imprime sólo
el encabezado. El formato **sí** se cambia: por defecto es el `uvm_table_printer`
—una fila por campo, con tipo y radix— y hay un `uvm_line_printer` que mete el
objeto entero en un renglón. La razón para preferir `convert2string()` es más
sencilla y hay que decirla así: escrito a mano entra en un renglón que dice lo
que a vos te importa, y en un archivo de cien mil líneas eso importa.


---

## Transactions

#### *Los siete pasos, y por qué son siete*

Lo que cuesta cambiarle el tipo de dato a un TB que ya existe. Vemos **2, 3, 6
y 7**; **1, 4 y 5** son traducción directa y están en el repo:

| # | Qué | Dónde |
| --: | --- | --- |
| 1 | una `result_transaction` para la vuelta | `result_transaction.svh` |
| 2 | una `add_transaction`, sólo sumas | `add_transaction.svh` |
| 3 | los dos testers se funden en uno | `tester.svh` |
| 4 | el `command_monitor` publica objetos | `command_monitor.svh` |
| 5 | el `result_monitor`, lo mismo | `result_monitor.svh` |
| 6 | el `scoreboard` usa `compare()` | `scoreboard.svh` |
| 7 | `add_test` overridea el **dato** | `add_test.svh` |

Note:
Los siete pasos son la parte más aburrida de la sección y también la más honesta,
así que conviene enmarcarla en vez de correrla: **esto es lo que cuesta cambiar
el tipo de dato de un testbench que ya existe.** El consejo real es hacerlo
desde el principio.
El que hay que mirar de reojo es el 3, porque es el único que **borra** una
clase: `add_tester` desaparece. Ahí está el resultado de la sección, y vale
adelantarlo — mover la decisión al dato hizo sobrar una clase entera de
estructura.
Si el grupo va rápido, los pasos 4 y 5 se abren en el editor y se comparan con
los de los analysis ports: la diferencia es que en vez de llenar una `struct` se hace
un `create()` y se llenan campos. Nada más.


---

## Transactions

#### *Paso 2 · una `add_transaction` que sólo suma*

- `add_transaction` extiende `command_transaction` y le agrega **una sola**
  constraint: `op == add_op`
- Con eso alcanza para cambiar el estímulo, y el `tester_h` no se entera: usa la
  clase hija exactamente igual que a la madre
- Las constraints **se heredan y se acumulan**: el sesgo a los bordes de `A` y
  `B` sigue estando, porque la de la clase base no desaparece

{{code:code/u6/transactions/tb_classes/add_transaction.svh}}

Note:
Ocho líneas, y de esas una sola hace algo: `constraint add_only {op == add_op;}`.
Vale ponerla al lado del `add_tester` del env, que hacía lo mismo
redefiniendo un método. Dos formas de decir "sólo sumas", y la de hoy no toca
código de comportamiento — sólo describe qué valores son legales.
El punto conceptual, que es el que ordena el día: **las constraints se heredan y
se acumulan.** `add_transaction` no reemplaza a `data`, se le suma. El solver
tiene que satisfacer las dos a la vez, así que sigue habiendo sesgo a los bordes
en `A` y `B` — y eso es exactamente lo que queremos.
De ahí sale la advertencia: dos constraints heredadas que se contradicen no dan
error de compilación, dan un `randomize()` que devuelve 0. Es el caso 1 del
experimento de Constrained Random.


---

## Transactions

#### *Paso 3 · dos testers se vuelven uno*

{{code:code/u6/transactions/tb_classes/tester.svh|lines=14-34}}

- El testbench del env tenía `base_tester` y `add_tester`: dos clases
  para dos tipos de estímulo
- Ahora hay **una sola**. El `repeat` crea una transaction y le dice
  `randomize()`; qué sale de ahí lo decide el **dato**, no el tester
- Ésa es la línea que borra una clase: la decisión se mudó de la estructura al
  tipo de la transaction

Note:
Es el resultado de la sección, medido en archivos: `add_tester.svh` deja de
existir. Vale decirlo en voz alta, porque el env había gastado un rato en
justificar esa jerarquía y ahora sobra la mitad.
Y no es que el env estuviera mal: era la respuesta correcta mientras el
dato fuera una `struct` muda. Cuando el dato sabe randomizarse, el escalón de la
jerarquía deja de tener trabajo. Es un buen ejemplo de que las abstracciones se
justifican contra el problema del momento, no para siempre.
El `if (!command.randomize()) uvm_fatal` es la línea que hay que copiar bien:
`randomize()` devuelve 0 si las constraints no tienen solución y no aborta nada.
Hay una slide entera sobre eso más adelante.

---

## Transactions

#### *Paso 6 · el scoreboard compara objetos, no números*

- Los dos lados de la comparación son ahora `result_transaction`: el que llega
  del `result_monitor` y el que arma el predictor
- El `write()` toma el resultado `t`, busca el comando que le corresponde en la
  cola del `command_monitor`, y le pide a `predict_result()` la predicción
- La comparación queda en una línea —`predicted.compare(t)`— y el mensaje de
  error se arma solo con los `convert2string()` de las tres transactions

{{code:code/u6/transactions/tb_classes/scoreboard.svh|lines=30-53}}

Note:
Comparar el `write()` con el de los analysis ports es la mejor forma de cerrar la
sección: allá había un `case` con la predicción escrita adentro y una comparación
a mano; acá hay un `predict_result()` que devuelve un objeto y un
`predicted.compare(t)`.
Lo que se ganó es concreto: el mensaje de error ahora se arma con
`convert2string()` de las tres transactions, así que dice qué se mandó, qué salió
y qué se esperaba, todo con los enums por nombre. Y el día que la transaction gane
un campo, el log lo muestra solo.
Un detalle que hay que señalar porque es la regla de la sección aplicada: el
`predicted` sale de `type_id::create()`, no de `new()`. Es una transaction que
viaja —aunque sólo viaje hasta el `compare()` de la línea siguiente—, así que sale
de la factory como todas.
Y el `do ... while` que saltea `no_op` y `rst_op` sigue igual que en los analysis ports: esas
operaciones no producen resultado, y si no se descartan la comparación se corre un
lugar y falla todo. Es el ejercicio del día 5.


---

## Transactions

#### *Paso 7 · el override, ahora sobre el dato*

{{code:code/u6/transactions/tb_classes/add_test.svh}}

- El test entero son **dos líneas**: el override y el `super.build_phase()`
- Y el override ya no cambia un **component** —el tester— sino un **dato** —la
  transaction—. La estructura del testbench dejó de tener opinión sobre el test
- `super.build_phase(phase)` va **después** del override, y ese orden no es
  negociable: el env se construye ahí adentro

Note:
Vale poner esta slide al lado del `add_test` del env y contar líneas: la
misma idea, un nivel más abajo. Antes se sustituía el que genera; ahora se
sustituye lo generado.
El orden del `super` es la trampa de la slide, y es hermana de la del env: la factory decide qué construir en el momento del `create()`. Si el override
llega después, no hay error — el testbench corre con `command_transaction` y el
test "de sumas" manda operaciones al azar. No rompe, miente.
Y una pregunta que sale siempre: ¿por qué acá `add_test` sí llama a
`super.build_phase()` si el curso dice que no hace falta? Porque su base es
`random_test`, una clase **nuestra** que tiene un `build_phase` con trabajo real.
La regla de los components hablaba de `uvm_component`, que no lo tiene.

---

## Transactions

#### *El `new()` que se come el override*

```systemverilog
command = new("command");                                   // NO
command.op = rst_op;

command = command_transaction::type_id::create("command");  // SI
command.op = rst_op;
```

- `set_type_override()` le habla **a la factory**, y la factory sólo se entera de
  lo que pasa por `type_id::create()`
- Un `new()` construye el tipo que dice esa línea y nada más: el override **no lo
  alcanza**. Compila, corre, y no falla — ese objeto simplemente se quedó afuera
- Es la peor clase de bug: no rompe, **miente**. Con un test y una transaction no
  se nota nunca; el día que el override sí importaba, ya es tarde
- La regla, corta: **todo `uvm_object` que viaje por el testbench sale de
  `type_id::create()`** — las transactions del tester, y también las que arman los
  monitores y el `predicted` del scoreboard
- Los *ports*, los *exports* y las *TLM FIFO* son la excepción: no están en la
  factory y se instancian con `new()`, como vimos en hablar con varios objetos

Note:
Esta slide sale de un bug que tenía el código de este mismo curso: el tester
creaba las dos operaciones dirigidas —el reset y la multiplicación FF x FF— con
`new()`, así que bajo `add_test` esas dos NO eran `add_transaction`. Nadie se
daba cuenta porque el testbench funciona igual.
La pregunta para tirar al grupo, que es la que ordena todo: si ahora el reset
sale de la factory y bajo `add_test` es un `add_transaction`, ¿por qué la
constraint `op == add_op` no lo convierte en una suma? Porque no lo randomizamos.
**La factory elige el tipo; las constraints sólo actúan en `randomize()`.**

---

## Transactions

#### *Y `randomize()` nunca va solo*

```systemverilog
assert (command.randomize());                                  // NO
if (!command.randomize()) `uvm_fatal("TESTER", "randomize() fallo")  // SI
```

- `randomize()` devuelve **0** cuando las constraints no tienen solución. No
  aborta, no imprime nada por su cuenta: devuelve 0 y sigue
- Un `assert()` pelado reporta por afuera de UVM: no entra en el *Report Summary*
  —el mismo que aprendimos a leer en reporting— y en muchos simuladores la
  ejecución continúa con la transaction **sin randomizar**
- Y si el proyecto compila con las aserciones apagadas, hay simuladores que ni
  evalúan la expresión: `randomize()` directamente **no se llama**
- Con `` `uvm_fatal `` el error trae componente, tiempo y archivo, y frena la
  corrida ahí mismo

Note:
Es una línea de más que se paga sola la primera vez que alguien agrega una
constraint contradictoria. Sin el `else`, el síntoma es un scoreboard que falla
en transacciones con valores absurdos y media tarde buscándolo en el DUT.
El `` `uvm_fatal `` no es exageración: una transaction sin randomizar no es un
estímulo malo, es un estímulo que no elegiste. Mejor que la corrida muera con un
mensaje que decirle a alguien que la regresión de anoche no significaba nada.

---

## Transactions

#### *Resumen de la unidad*

- Vimos cómo utilizar *transactions* para mover datos por el TB
- Esto nos permite simplificar los componentes del TB y hasta remover una clase de nuestro TB inicial (add_tester)
- La unidad que sigue agrupa las clases que hablan con una misma interface en un
  solo bloque reutilizable: el `uvm_agent`

Note:
Cierre del día 5, y conviene decir qué falta: hoy el estímulo lo genera un
tester que escribiste vos; en UVM moderno eso es una uvm_sequence corriendo
sobre un sequencer, y el conjunto driver + monitor + sequencer se empaqueta en
un agent. Eso es el día 6.
