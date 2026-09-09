## Copiar un objeto que contiene otro

#### *El handle no es el objeto*

- Desde las transactions los datos del testbench dejan de ser una `struct` y pasan a
  ser **objetos que viajan**: el monitor los crea, el scoreboard los compara
- Y ahí aparece un problema que una `struct` no tenía. Una `struct` se copia al
  asignarla; un objeto **no**: `obj1_h = obj2_h` copia el handle, no los datos
- O sea que dos partes del testbench pueden estar mirando el mismo objeto sin
  saberlo. Si una lo modifica, la otra ve el cambio a mitad de camino
- Copiarlo de verdad hay que escribirlo, y escribirlo **en cada nivel de la
  jerarquía**, o los campos de arriba se pierden en silencio
- Esta sección es la OOP que falta para que las transactions se
  puedan copiar, comparar e imprimir sin mentir

Note:
Es una sección de OOP en el medio de UVM, y conviene decir por qué está acá y no
en el día 2: porque recién ahora hace falta. Hasta reporting —el cierre del día
3— los datos eran una `struct` y se copiaban solos.
El bug del segundo bullet lo escribe todo el mundo una vez, y el síntoma es
horrible: mandás una transaction al scoreboard, seguís usando el mismo handle para
la siguiente, la modificás, y el scoreboard compara contra datos que cambiaron
después de que él los recibió. No falla siempre, y cuando falla parece un bug del
DUT.
La otra mitad —el `super` en cada nivel— tiene un síntoma distinto y más
traicionero: el día que alguien mete una clase nueva en el medio de la jerarquía,
el `convert2string()` deja de imprimir la mitad de los campos y **nadie se
entera**, porque sigue imprimiendo algo.
La pregunta para arrancar: si `handle_a = handle_b`, ¿cuántos objetos hay? Uno. Es
la misma pregunta de clases y extensiones, ahora con consecuencias.

---

## Copiar un objeto que contiene otro

#### *Nunca dupliques código*

> “Si nos encontramos copiando código y haciéndole pequeñas modificaciones dentro de nuestro programa, estamos haciendo las cosas mal. Nunca hay que duplicar código.”

En OOP en vez de copiar código...
<!-- .element: class="fragment grow" -->

***extendemos clases***
<!-- .element: class="fragment current-visible" -->

---

## Copiar un objeto que contiene otro

#### *`convert2string()`: el problema*

![Los cuatro niveles de la jerarquía](res/diagrams/jerarquias_convert2string.svg)
<!-- .element: class="grande" -->

- La jerarquía va de lo general a lo particular, y cada clase agrega campos
  propios
- Queremos dos cosas de ella: poder **copiar** un objeto entero e **imprimirlo**
  entero, sin que se pierda nada de los niveles de arriba
- Esta primera versión funciona. Contá cuántas veces aparece el nombre de un campo
  de la clase base

{{code:code/u6/jerarquias/pre_convert2string.sv}}

Note:
Esta versión funciona, y ése es el problema: se ve bien y está mal. Cada
`convert2string()` imprime a mano todos los campos, incluidos los que heredó.
Andá al `$sformatf` de la clase de más abajo y contá cuántas veces se repite el
nombre de un campo de la clase de arriba. Cada una de esas repeticiones es una
línea que hay que acordarse de tocar el día que se agregue un campo.
La pregunta que arma la slide siguiente: ¿qué pasa si mañana alguien mete una
clase nueva **en el medio** de la jerarquía? Los de abajo siguen imprimiendo lo
que sabían, la del medio no aparece, y no hay error. El método sigue devolviendo
un string.

---

## Copiar un objeto que contiene otro

#### *`convert2string()`: la versión deep*

![La copia profunda, nivel por nivel](res/diagrams/jerarquias_convert2string_deep.svg)
<!-- .element: class="grande" -->

- El día que alguien mete una clase **en el medio**, los de abajo siguen
  imprimiendo lo que sabían y la del medio no aparece. Y no hay error: el método
  sigue devolviendo un string
- La regla que lo arregla: cada clase imprime **sólo lo suyo** y le pide el resto a
  `super`
- Nadie sabe qué hay más arriba, así que insertar un nivel no rompe nada

{{code:code/u6/jerarquias/pre_convert2string_ok.sv}}

Note:
La regla, corta: **cada método de la jerarquía se ocupa sólo de sus propios
campos y le pide el resto a `super`.** Nadie sabe qué hay más arriba, y por eso
insertar una clase en el medio no rompe nada.
El patrón se repite igual en los tres métodos de la sección —`convert2string()`,
`do_copy()`, `do_compare()`— y también en los tres de UVM. Si te acostumbrás a
escribir la llamada a `super` **primero**, antes de tocar tus campos, no te la
olvidás nunca.
Vale la pena señalar el paralelo con algo que ya vieron: es exactamente el mismo
argumento que el `super.new()` de clases y extensiones. La parte de arriba del objeto
también hay que construirla — y también hay que imprimirla, copiarla y
compararla.

---

## Copiar un objeto que contiene otro

#### *El signo igual no copia nada*

- `obj1_h = obj2_h` **no copia nada**: deja dos handles apuntando al mismo objeto
- Si lo modificás por uno, el otro lo ve. No hay aviso, no hay warning
- Con una `struct` eso no pasaba: se copia al asignarla. Es la diferencia que hay
  que tener presente desde acá hasta el final del curso

Note:
Copia el handle, no el objeto. Es el bug que todos escriben una vez: modificás
la transaction que ya mandaste al scoreboard y el scoreboard ve el cambio a
mitad de camino. De acá sale el clone() de las transactions.

---

## Copiar un objeto que contiene otro

#### *Copiar de verdad son dos pasos*

Copiar de verdad son dos pasos, y hay que escribirlos: **instanciar** un objeto
nuevo y **pasarle los datos** campo por campo

{{code:code/u6/jerarquias/pre_copy.sv}}

- El `new()` es el primer paso y no es opcional: sin un objeto nuevo del otro
  lado, no hay adónde copiar
- El segundo paso es a mano, campo por campo. SystemVerilog no tiene una copia
  profunda incorporada
- Y campo por campo quiere decir **también los de las clases de arriba**, que es
  justo lo que se olvida

Note:
Vale hacer la comparación con la asignación de la slide anterior en voz alta:
`a = b` es una línea y no copia nada; copiar de verdad son dos pasos y hay que
acordarse de los dos.
Que el lenguaje no traiga la copia profunda no es un olvido del comité: no
existe una respuesta general. Si la clase tiene un handle a otro objeto,
¿copiás el handle o el objeto? Depende, y por eso lo tenés que decidir vos en
cada `do_copy()`.
Es exactamente el mismo dilema que van a tener las transactions
si algún día llevan un array de objetos adentro. En este curso no pasa, pero
conviene que la pregunta quede planteada.

---

## Copiar un objeto que contiene otro

#### *`do_copy()`: cada clase toca lo suyo*

*do_copy():* Cada clase en la jerarquía, debe llamar a su clase superior, por lo tanto, todos los métodos do_copy() necesitan el mismo tipo de argumento. Pero tenemos clases distintas... Usamos *polimorfismo*

{{code:code/u6/jerarquias/pre_copy2.sv|lines=24-45}}

Note:
Acá está el detalle que parece burocrático y no lo es: **todos** los `do_copy()`
de la jerarquía reciben un argumento de la clase **base**, no de la suya. Si cada
uno recibiera su propio tipo, la llamada a `super.do_copy(rhs)` no compilaría —
los tipos no coincidirían.
El precio es que adentro de cada método hay que hacer `$cast` para poder leer los
campos propios. Y como vimos en la factory, ese `$cast` chequea en runtime: si
alguien intenta copiar un `mojito` sobre un `fernet`, devuelve 0 y hay que
atajarlo.
Es la primera vez que se ve una convención de firma que existe sólo para que el
polimorfismo funcione. En UVM va a ser lo mismo y con más reglas: el argumento se
tiene que llamar `rhs`, `do_compare()` recibe además un `uvm_comparer`, y así.
Cuando en las transactions aparezcan esas firmas, la respuesta a "¿por qué así?" es
esta slide.

---

## Copiar un objeto que contiene otro

#### *Resumen: la solución pésima*

{{code:code/u6/jerarquias/wrong.sv|lines=69-79}}

- Es el `convert2string()` de `fernet_con_hielo`, la clase de más abajo: imprime
  **los cuatro campos a mano**, incluidos los tres que heredó
- Funciona, y por eso es peligroso. El día que `fernet` gane un campo, este método
  sigue compilando y sigue imprimiendo — de menos
- El archivo entero está en `code/u6/jerarquias/wrong.sv`, y los `do_copy()` tienen el
  mismo vicio: cada uno toca campos que no son suyos

Note:
La regla que hay que dejar: **una clase sólo escribe sobre sus propios campos.**
Todo lo demás se lo pide a `super`.
Conviene contar en pantalla: `hielos` y `con_coca` aparecen en cuatro
`convert2string()` distintos de este archivo. Cuatro lugares para acordarse, y
ninguno falla si te olvidás de uno.
Hay una `bad_copy()` un poco más abajo en el archivo que vale la pena abrir si
sobra tiempo: toma un `fernet_con_hielo` como argumento en vez de un `trago`. Compila
y anda... hasta que alguien la llama por un handle de la clase base, y ahí no hay
polimorfismo que valga.

---

## Copiar un objeto que contiene otro

#### *Resumen: la solución deep*

{{code:code/u6/jerarquias/deep.sv|lines=47-58}}

- Los mismos dos métodos, escritos como corresponde: cada uno llama a `super` y
  después toca **un solo campo**, el suyo
- `convert2string()` **concatena** lo que devolvió el de arriba;
  `do_copy()` **llama primero** al de arriba y después copia lo propio
- Con esa forma, meter una clase nueva en el medio de la jerarquía funciona sola:
  la cadena de `super` la incluye sin que nadie edite nada

Note:
Cierre de la sección, y conviene decir adónde va todo esto: los tres métodos que
acaban de escribir a mano son **exactamente** los tres que UVM pide en una
transaction. `do_copy()`, `do_compare()` y `convert2string()`, con las mismas
reglas de `super` y de `$cast`.
La diferencia es que en UVM no se los llama directo: uno escribe `do_copy()` y el
testbench llama a `copy()`, que es la que está en `uvm_object` y se encarga del
resto. Misma idea que las fases — vos escribís la parte de abajo, la librería
maneja el protocolo.
Y la pregunta con la que hay que salir del día: si escribir esto bien cuesta tres
métodos por clase, ¿por qué no lo genera alguien? Lo genera: son las macros
`` `uvm_field_* ``. El curso no las usa, y el porqué está en la slide de
`super.build_phase()` de los components — generan cientos de líneas que nadie lee y
que aparecen en el stack cuando algo falla. Leerlas sí, escribirlas no.

---

## Copiar un objeto que contiene otro

#### *Resumen de la unidad*

- `obj1_h = obj2_h` **no copia nada**: deja dos handles apuntando al mismo
  objeto. Si lo tocás por uno, el otro lo ve, y no hay ni un warning
- Con una `struct` eso no pasaba —se copia al asignarla—, y ésa es la diferencia
  que hay que tener presente hasta el final del curso
- **Copiar de verdad son dos pasos**: instanciar un objeto nuevo y pasarle los
  datos. De ahí sale el `clone()` de las transactions
- En una jerarquía, cada clase debe tocar **un solo campo, el suyo**, y llamar a
  `super`. Escribir los cuatro campos a mano es la solución pésima
- Para que eso funcione, los `do_copy()` / `do_compare()` toman todos **el mismo
  tipo de argumento**, la clase base. Es polimorfismo, otra vez
- El día que alguien mete una clase **en el medio** de la jerarquía, la versión
  deep sigue andando sola. La otra hay que salir a corregirla

Note:
El bug del handle es el que todos escriben una vez: modificás la transaction que
ya mandaste al scoreboard, y el scoreboard ve el cambio a mitad de camino. No
falla en el momento; falla después, y en otro lado.
La forma corta de cerrar: **el `=` copia el papelito con la dirección, no la
casa.** Y por eso UVM trae `copy()`, `clone()` y `compare()` hechos — que es
exactamente la unidad que sigue.
