## El patrón factory

#### *¿Quién decide el tipo?*

- Cada `new()` que escribís es una decisión **hardcodeada**: esa línea siempre va
  a construir esa clase, y para cambiarla hay que editarla y recompilar
- En un testbench eso no escala. Querés el mismo `env` mandando sumas hoy y
  multiplicaciones mañana, elegido por línea de comandos
- Las clases paramétricas de la unidad anterior tampoco alcanzan: el `#(...)` se
  resuelve al compilar, y acá hay que decidir **en runtime**
- La factory es la respuesta: en vez de construir vos, le **pedís** el objeto a
  alguien que sabe qué tipo entregar
- Es el patrón más visible de UVM, y con él se entienden `type_id::create()` y
  `set_type_override()`, que van a estar en cada archivo del resto del curso

Note:
La frase que ordena la unidad: **el que usa el objeto deja de ser el que elige
el tipo**. Todo lo demás son detalles de implementación.
Conviene decir de entrada dónde termina esto, porque si no parece un rodeo de
programación: el `+UVM_TESTNAME=add_test` de los tests, mañana, va a ser una
factory — UVM lee un string de la línea de comandos y construye la clase que
corresponde. Acá se ve el mecanismo por dentro.
Y para el que viene de software: sí, es el Factory Method del GoF, y no
inventamos nada. La versión en Python que cierra la sección está justamente para
eso.

---

## El patrón factory

- Un patrón de diseño, no una feature del lenguaje: una clase cuyo único trabajo
  es **construir objetos por vos**
- Le pedís un objeto describiendo cuál querés —un string, un enum— y te lo
  devuelve ya construido, del subtipo que corresponda
- Antes de la solución, el problema. Mirá qué pasa cuando el `new()` está
  escrito en el lugar donde se usa el objeto:

{{code:code/u3/factory/without-factory.sv}}

> *La idea es crear datos de tipos aleatorios sin cambiar el código.*

Note:
El problema primero, el patrón después: quiero cambiar el tipo de objeto que se
crea sin tocar el código que lo crea. Con eso en la cabeza, la factory de UVM
—el env— es la misma idea envuelta en macros.
La versión en Python está al lado a propósito: al que viene de software le
muestra que no inventamos nada.

---

## El patrón factory

![La cantina fabrica fernet y mojito, y devuelve un handle trago](res/diagrams/factory_diagram.svg)
<!-- .element: class="grande" -->

<br>

- **La factory** es el método de arriba: recibe un argumento y devuelve un objeto
  del tipo que ese argumento pide
- **El polimorfismo** es lo que la hace posible: `fernet` y `mojito` extienden
  `trago`, así que los dos entran en una variable `trago`
- Sin lo segundo no hay dónde poner lo que devuelve lo primero. Son las dos
  mitades de la misma herramienta

Note:
La factory **no funciona sin polimorfismo**, y vale decirlo
así: si `hacer_trago()` no pudiera devolver un `fernet` guardado en una variable
`trago`, no habría nada que fabricar. Son las dos mitades de la misma cosa.
La pregunta útil sobre el diagrama: ¿de qué tipo es lo que devuelve
`hacer_trago()`? De `trago`, siempre. Lo que cambia es qué objeto viene
adentro. El que llama nunca se entera, y ése es exactamente el punto.
Y el límite que se ve enseguida: si el que llama necesita algo que sólo tiene
`fernet` —el `sin_hielo` del ejemplo— se acabó la comodidad y hay que castear.
Eso es la slide que sigue, y es la razón de que la factory de UVM sea mejor que
ésta.

---

## El patrón factory

- `virtual` alcanza mientras uses métodos que la clase base ya declara. Pero
  `fernet` agrega un campo propio —`sin_hielo`— que `trago` no conoce
- Para llegar a él hay que bajar el handle a su tipo real, y eso es `$cast`:
  convierte la variable del segundo argumento a la clase del primero
- Chequea **en runtime** y devuelve 0 si no da, así que nunca va solo: siempre
  adentro de un `if` con su `$fatal`

{{code:code/u3/factory/factory.sv#cantina}}

- Y el `$cast` en uso, en el `top`: la factory siempre devuelve un `trago`, y
  para llegar a `sin_hielo` hay que bajarlo a `fernet`

{{code:code/u3/factory/factory.sv#casting}}

Note:
Dos cosas de este código, y las dos vuelven en UVM.
La primera: `$cast` **chequea en runtime y devuelve 0**, no aborta. Por eso en el
ejemplo cada llamada va adentro de un `if (!$cast(...)) $fatal(...)`. Un `$cast`
sin chequear es el `assert(randomize())` de las transactions con otro disfraz: si
falla, seguís con un handle en `null` y el error aparece tres líneas después, en
otro lado.
La segunda: mirá el `case (pedido)` de `hacer_trago()`. Para agregar un trago
nuevo hay que **editar la factory**. O sea que sacamos el hardcodeo del que usa
y lo pusimos en un solo lugar — mejor, pero sigue estando.
Ahí está lo que UVM resuelve, y conviene dejarlo dicho: `` `uvm_component_utils ``
registra la clase **sola**, así que la factory de UVM no tiene ningún `case` que
mantener, y `type_id::create()` devuelve el tipo correcto sin que nadie castee.
Las dos molestias de esta slide desaparecen en el env.

---

## El patrón factory

#### *Python Style*

{{code:code/u3/factory/factory.py#factory-class}}

- La misma fábrica, en un lenguaje que no tiene nada que ver con hardware: un
  método estático con un `if` por tipo y un `raise` para lo que no existe
- Y la misma molestia: agregar un trago obliga a **editar la fábrica**
- El archivo completo está en `code/u3/factory/factory.py` y se corre con `python3`:
  genera veinte tragos al azar y los sirve a todos igual

Note:
Está a propósito y la moraleja es corta: esto no es una rareza de verificación,
es un patrón de diseño de 1994 que en Python ocupa diez líneas.
La parte de abajo del archivo vale abrirla si sobra tiempo: `Trago.__subclasses__()`
le pregunta al lenguaje qué clases heredan de `Trago`, y con eso el generador ya
no necesita una lista escrita a mano. Es exactamente lo que hace el registro de
la factory de UVM con `` `uvm_component_utils ``, pero de arriba abajo en vez de
que cada clase se anote sola.
El remate: el bucle final trata a los veinte tragos igual, sin preguntar de qué
tipo son. Eso es polimorfismo, y es lo que hace que una factory
sirva de algo.
La slide sirve para dos públicos opuestos. Al que viene de software le baja la
desconfianza —"ah, es el factory de siempre"—. Al que viene de RTL le muestra
que lo que está aprendiendo no es "cosas raras de SystemVerilog": es
programación, y se puede ir a leer sobre el tema afuera del mundo EDA.

---

## El patrón factory

#### *Resumen de la unidad*

- Cada `new()` es una **decisión hardcodeada**. La factory la mueve a runtime:
  en vez de construir, **pedís** el objeto a alguien que sabe qué tipo entregar
- **No funciona sin polimorfismo** —hacen falta alguien que fabrique y una
  variable base donde guardarlo— y el **`$cast` devuelve 0** en vez de abortar,
  así que nunca va solo: siempre adentro de un `if` con su `$fatal`
- Dónde reaparece: `` `uvm_component_utils `` **registra la clase sola** —el
  `case` que acabás de escribir a mano— y `+UVM_TESTNAME` la elige desde la
  línea de comandos

Note:
Cierre de la sección más abstracta del día 2, y conviene aterrizarlo con lo que
viene: el `+UVM_TESTNAME=add_test` de los tests **es una factory** —
UVM lee un string de la línea de comandos y construye la clase que corresponde.
Acá vieron el mecanismo por dentro, un día antes.
La frase que resume la sección entera: **el que usa el objeto deja de ser el
que elige el tipo.** Todo lo demás son detalles de implementación.
Y para el que viene de software: es el Factory Method del GoF, de 1994, y en
Python ocupa diez líneas. No inventamos nada, y eso es una buena noticia.
