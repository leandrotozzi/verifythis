## Variables estáticas

#### *La variable global que sí podés defender*

- En un testbench siempre hay algo que es **uno solo**: el contador de errores,
  la lista de transacciones en vuelo, el handle a la configuración
- La respuesta fácil es una variable global, y es la que después nadie puede
  debuggear: no se sabe quién la escribió, ni desde dónde, ni cuándo
- `static` es la misma idea con apellido. La variable vive **en la clase**, no
  en el objeto, y para tocarla hay que nombrar la clase: `bandeja_de_fernet::vasos`
- Ese `::` es todo el argumento. El día que el valor sea raro, un grep te dice
  exactamente quién lo puso
- No es un tema suelto de OOP: la **factory** y el **`uvm_config_db`** son las
  dos variables estáticas más importantes de un testbench UVM

Note:
La pregunta que ordena la unidad: ¿de qué hay uno solo en un testbench? De la
factory, de la base de configuración, del contador de errores. Todo eso en UVM
es `static`, y por eso se escribe `uvm_config_db#(T)::set(...)` con dos puntos
dobles y sin instanciar nada.
Y la segunda mitad, que es la que se lleva al trabajo: `static` resuelve el
"dónde vive", no el "quién lo toca". Eso lo resuelve `protected` más los métodos
de acceso, que es la tercera slide. Una `static` pública es una variable global
con un prefijo más largo.

---

## Variables estáticas

- `bandeja_de_fernet` no tiene métodos ni constructor: es una clase que existe **sólo**
  para ser el lugar donde vive la cola
- Nadie la instancia. Se la nombra con el operador `::`, que le dice al
  compilador *"buscá esta variable en el namespace de esa clase"*
- Y ahí está la ventaja sobre la global: `bandeja_de_fernet::vasos` dice dónde está
  declarada. Un `vasos` suelto, no

{{code:code/u3/estaticas/01-variables/static_variables.sv#tray-and-top}}

Note:
Traducción rápida: static es la variable global que sí podés defender en un code
review. Vive en la clase, no en el objeto.
La segunda slide muestra por qué hay que encapsularla con métodos estáticos: si
la dejás pública, el día que cambies la queue por otra estructura tenés que
tocar todo el testbench.

---

## Variables estáticas

- Hay **una sola** copia en memoria, sin importar cuántos objetos se instancien
- Y existe aunque no se instancie ninguno: la `static` no espera al `new()`

{{code:code/u3/estaticas/01-variables/ejemplo2.sv}}

***¿Y el encapsulamiento?***
<!-- .element: class="fragment current-visible" -->

Note:
`pepe::cant` cuenta cuántos objetos se crearon, y el detalle que hay que hacer
notar es que **el contador existe aunque no haya ni un objeto**. Una `static` no
espera al `new()`: está desde que arranca la simulación. Por eso sirve para
contar instancias, y por eso no se puede inicializar con nada que dependa de un
objeto.
Buena pregunta para tirar: si `cant` se incrementa en el constructor, ¿qué pasa
si alguien extiende `pepe` y se olvida del `super.new()`? No cuenta. Es el mismo
tema de clases y extensiones visto desde otro lado.
La pregunta de la slide es a propósito: `cant` está pública, y cualquiera del
testbench puede escribirla. Dejar esa incomodidad en el aire un rato es lo que
hace que la slide siguiente tenga sentido.

---

## Variables estáticas

#### *Métodos estáticos*

- En los dos ejemplos anteriores la cola estaba a la vista, así que el día que se
  cambia por otra estructura hay que salir a corregir todo el testbench
- La versión que se defiende en un code review son dos palabras: la variable
  `protected`, y **métodos de acceso estáticos** que sean la única puerta
- Es lo mismo que hace UVM con la factory: nadie toca el diccionario de tipos, se
  le pide con `type_id::create()`

{{code:code/u3/estaticas/02-metodos/static_methods.sv#tray-and-top}}

Note:
La diferencia entre las dos versiones es de dos palabras —`protected` adelante
de la queue y `static function` en los accesos— y cambia quién puede romper qué.
En la primera, cualquier línea del testbench puede hacerle `push_back` a la
cola; en ésta, sólo `bandeja_fernet()`.
El argumento no es purismo: es que ahora `vasos` se puede cambiar por un array
asociativo, por una `uvm_tlm_fifo` o por lo que sea, sin salir a corregir el
testbench entero. Encapsular es poder cambiar de opinión después.
Un detalle de sintaxis que confunde: un método `static` **no puede** tocar
variables de instancia, sólo `static`. Tiene sentido —se lo llama sin objeto,
así que no hay `this`—, pero el mensaje de error del simulador no lo dice así.
Y el enganche: `type_id::create()` de UVM, que van a escribir cien veces a
partir del env, es exactamente esto — un método estático de acceso a una
estructura estática.

---

## Variables estáticas

#### *Resumen de la unidad*

- **Una sola copia** por más objetos que instancies, **existe aunque no
  instancies ninguno**, y para tocarla hay que nombrar la clase con `::`
- Ese `::` es todo el argumento: el día que el valor sea raro, un `grep` te dice
  quién lo puso. Pero `static` resuelve *dónde vive*, no *quién lo toca* — eso
  es `protected` más métodos de acceso estáticos
- Dónde reaparece: `uvm_config_db#(T)::set(...)` y `type_id::create()`, las dos
  estáticas más importantes de un testbench UVM

Note:
El enganche que conviene dejar servido: `uvm_config_db#(T)::set(...)` se escribe
con dos puntos dobles y sin instanciar nada, y ahora ya saben por qué. Lo mismo
`type_id::create()`, que van a escribir cien veces a partir del env — es
exactamente un método estático de acceso a una estructura estática.
La pregunta que ordena la unidad y sirve de repaso: ¿de qué hay uno solo en un
testbench? De la factory, de la base de configuración, del contador de errores.
Todo eso es `static`, y no por casualidad.
