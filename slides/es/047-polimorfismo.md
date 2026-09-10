## Polimorfismo

#### *Una variable `trago`, un objeto `fernet`: ¿cuál `servir()` corre?*

![Diagrama UML de los tragos](res/diagrams/uml-poli.svg)
<!-- .element: class="grande" -->

- Un `fernet` **es** un `trago`, así que guardarlo en una variable `trago`
  compila y es legal
- La pregunta es la otra: cuando llamás al método por esa variable, ¿SystemVerilog
  mira el **tipo de la variable** o el **tipo del objeto**?
- La respuesta por defecto es la que no querés, y la palabra que la cambia es
  una sola

Note:
Es el concepto que sostiene todo lo que viene: la factory, los overrides, las
transactions. El que se pierde acá se pierde el resto del curso, así que no
conviene avanzar hasta que todos vean por qué la variable puede ser de la clase
base.
Conviene hacer votar antes de mostrar el código: "¿qué imprime?". La mitad del
aula dice *"Fernet"*, y ver que se equivocan es lo que fija el concepto.
Y avisarlo antes de que lo pregunten: en SystemVerilog `virtual` está
sobrecargado — virtual method, virtual class y virtual interface son tres cosas
distintas. Acá es la primera.

---

## Polimorfismo

#### *Las tres clases: un `trago` que no se sabe servir*

{{code:code/u3/polimorfismo/01-sin-virtual/not_virtual.sv#three-classes}}

- `trago` define `servir()` con un `$fatal`: la clase base no sabe con qué
  se sirve, y lo dice fuerte
- `fernet` y `mojito` extienden `trago` y **redefinen** `servir()`, cada uno
  con el suyo
- `mojito` —que no entra en pantalla— es igual que `fernet`, con otro `$display`

Note:
El `$fatal` en la clase base es un patrón que se ve mucho y que en esta misma sección
vamos a reemplazar por algo mejor: si el método no se puede implementar acá, lo
correcto no es explotar en simulación, es no dejar compilar.
Que las tres clases tengan un método con el mismo nombre y la misma firma es lo
que hace posible todo lo que sigue. Ahora falta decidir **cuál corre**, y eso
todavía no está dicho en ningún lado del código.
El archivo entero está en `code/u3/polimorfismo/01-sin-virtual/not_virtual.sv`.

---

## Polimorfismo

#### *Sin `virtual` manda la variable, y eso rompe*

{{code:code/u3/polimorfismo/01-sin-virtual/not_virtual.sv#the-calls}}

- Las dos primeras llamadas andan: la variable `fernet_h` es de tipo `fernet` y el
  objeto también
- La tercera **explota**. `trago_h` apunta a un `fernet`, pero como el método no
  es virtual, SystemVerilog resuelve en **compilación** por el tipo de la
  variable, y llama al `servir()` de `trago`
- Se llama *static binding*: la decisión de qué código correr ya está tomada
  antes de que exista el objeto

Note:
Acá conviene correrlo: `bash code/u3/polimorfismo/01-sin-virtual/run.sh`. El ejemplo
termina en `$fatal` a propósito, y el `run.sh` da PASS justamente cuando ese
mensaje aparece.
La pregunta que siempre sale: "¿y `hielos` por qué sí sale bien?". Porque los
campos no son virtuales nunca: la variable ve los campos de su propio tipo, y
`hielos` está en `trago`. Los métodos son lo único que se puede resolver por
objeto, y sólo si se lo pedís.

---

## Polimorfismo

#### *Métodos virtuales: una palabra, y ahora manda el objeto*

{{code:code/u3/polimorfismo/02-virtual/virtual.sv#trago.servir}}

- Es la **única** diferencia entre `01-sin-virtual` y `02-virtual`: la keyword
  `virtual` en el método de la clase base
- Con eso la llamada se resuelve en **simulación**, mirando el objeto que hay
  adentro de la variable — *dynamic binding*
- `trago_h.servir()` ahora sirve un fernet o un mojito, sin que el que escribe
  esa línea sepa cuál le va a tocar
- Ésa es toda la idea: **el que usa el objeto deja de ser el que elige el tipo**

Note:
Vale correr los dos ejemplos seguidos y mostrar el diff: una palabra.
Un detalle que se pregunta siempre: `fernet` y `mojito` **no** escriben `virtual`
en su `servir()`, y sin embargo lo son. Una vez que el método es virtual en
la base, lo es para toda la descendencia. Escribirlo igual no molesta y mucha
gente lo hace por prolijidad.
La regla práctica para el resto del curso: en verificación, **todo método que
puedas querer redefinir va virtual**. UVM lo hace así — `build_phase`,
`run_phase`, `do_copy`, `do_compare` son todos virtuales, y por eso el override
del env funciona.
El costo existe y es real —una tabla de métodos y un salto indirecto— pero en un
testbench no lo vas a medir nunca. En RTL sintetizable no hay clases, así que la
discusión no aplica.

---

## Polimorfismo

#### *Clases abstractas: mover el error a la compilación*

- El `$fatal` de `trago` se entera **tarde**: compila, corre, y explota en el
  medio de la simulación. En una regresión de la noche eso es una corrida perdida
- SystemVerilog permite declarar una **abstract class** —`virtual class`—: sólo
  sirve como base, **no se puede instanciar**
- Adentro puede declarar **pure virtual methods**: métodos sin cuerpo
- Extender la clase **obliga** a redefinirlos. Si no, es un **error de
  compilación**
- El error no desapareció: se mudó a un momento en el que sale barato

Note:
Ésta es la slide que hay que dejar clara, porque el criterio se repite todo el
curso: *cuanto antes falle, mejor*. Compilación mejor que simulación,
simulación mejor que silicio.
En verificación un error de compilación es una **buena noticia**: la regresión
de la noche no se pierde, y el que rompió algo se entera en un minuto.
Dónde se va a volver a ver: `uvm_object` y `uvm_component` están declaradas
`virtual class` en la librería, así que son abstractas de derecho. Lo que **no**
hace `` `uvm_component_utils `` es obligarte a implementar nada: al revés, te
*provee* el `get_type_name()` y el `type_id` del registro. El `pure virtual` de
verdad en UVM es `uvm_subscriber::write()`, que vas a tener que escribir sí o sí
en el día 4. Y en el ejercicio del día 3, la `virtual class base_tester`.

---

## Polimorfismo

#### *`pure virtual`: el mismo ejemplo, sin `$fatal` posible*

{{code:code/u3/polimorfismo/03-virtual-pura/pure_virtual.sv#trago}}

- `virtual class trago` ya no tiene un `servir()` que explote: **no tiene
  cuerpo**, y por eso no hay nada que pueda correr mal
- La línea comentada del `top` —`trago_h = new(3)`— no compila: una clase
  abstracta no se instancia
- Si a `mojito` le borrás el override, el compilador dice *"Class 'mojito'
  extends 'trago' but is missing implementation for 'servir'"* y ahí termina el
  asunto

Note:
El punto no es el `$fatal`, es **cuándo te enterás**: sin clase abstracta
explota en el medio de la simulación, con pure virtual no compila.
Vale hacerlo en vivo: comentar el `servir()` de `mojito` y compilar. El
mensaje del compilador es el que enseña.
Y el enganche hacia adelante: la factory usa esto para crear, y el `env` para
los overrides. Lo que hoy es un fernet y un mojito, mañana va a ser un
`base_tester` y los testers que lo extienden — misma mecánica, otro vocabulario.

---

## Polimorfismo

#### *Resumen de la unidad*

- **Sin `virtual` manda la variable**, y se decide al compilar. **Con `virtual`
  manda el objeto**, y se resuelve en simulación. Una palabra, y cambia todo
- La idea de fondo, que vuelve en cada sección que sigue: **el que usa el
  objeto deja de ser el que elige el tipo**
- En SystemVerilog `virtual` está **sobrecargado**: virtual method, virtual
  class y virtual interface son tres cosas distintas — y en UVM vas a escribir
  las tres

Note:
Es la unidad que habilita a la siguiente mitad del curso, y conviene decirlo:
sin polimorfismo no hay factory, no hay `uvm_component` que sirva de base, y no
hay override. Todo lo demás es plomería.
El olvido de `virtual` es además la trampa del ejercicio del día 2 —`get_op()`
está declarada sin `virtual` a propósito—, así que si alguien lo pregunta acá,
no delatarlo: se entiende mucho mejor sufriéndolo.
