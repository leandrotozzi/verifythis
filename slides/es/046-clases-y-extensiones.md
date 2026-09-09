## Clases y extensiones

#### *¿Por qué OOP en un testbench?*

- El testbench convencional es un **módulo**: se elabora una vez, existe desde
  el `time 0` hasta el `$finish`, y siempre es el mismo
- Un estímulo no se parece en nada a eso: aparece, viaja por el testbench, se
  compara y se tira. Eso no es un módulo, es un **objeto**
- Módulos = *estructura*, se elaboran. Clases = *datos y comportamiento*, se
  crean y se destruyen mientras la simulación corre
- Y no es opcional: **UVM es una librería de clases**. `uvm_test`,
  `uvm_component`, `uvm_object`. Sin esto, el resto del curso no se puede leer

Note:
Acá está el muro real del curso, y no es UVM: es OOP. El que llega de RTL nunca
escribió una clase, y a partir de los tests todo son clases.
Si el grupo viene de software, esta unidad se pasa rápido y se gana tiempo para
el día 3. Si viene de RTL, es la unidad donde hay que gastar el tiempo que
sobre, aunque haya que sacarlo de otro lado.
La pregunta que ordena todo: ¿esto existe todo el tiempo o aparece y se va? Lo
primero es un módulo; lo segundo, un objeto.

---

## Clases y extensiones

#### *Lo que una `struct` no puede hacer*

{{code:code/u3/clases/structs.sv}}

- La `struct` guarda datos y **nada más**: la cuenta del área hay que escribirla
  afuera, y de nuevo en cada lugar donde se necesite
- `square_struct` no tiene ninguna relación con `rectangle_struct`, aunque un
  cuadrado sea un caso particular de un rectángulo
- No se randomiza sola, no se compara sola, no se imprime sola

Note:
Conviene arrancar preguntando qué tiene de malo la `struct`, porque la respuesta
espontánea es "nada" — y tienen razón: para guardar tres campos anda perfecto. El
curso no viene a decir que la `struct` esté mal, viene a decir dónde se queda
corta.
Los tres bullets son tres cosas distintas y conviene separarlas. La primera es
**cohesión**: el dato está acá y la operación sobre el dato está en otro archivo,
así que nada obliga a que estén de acuerdo. La segunda es **herencia**: un
cuadrado *es* un rectángulo y el lenguaje no tiene forma de decirlo, así que se
copia y pega. La tercera es la que se va a cobrar el día 5: un `command_s` no
sabe randomizarse ni compararse consigo mismo, y todo eso hay que escribirlo
afuera, una vez por cada lugar que lo use.
El remate honesto, para que nadie se lleve una idea religiosa: el `command_s` del
testbench convencional **es** una struct, funciona, y estuvo bien mientras el
testbench era un módulo. Lo que cambia es la escala.

---

## Clases y extensiones

#### *La primera clase: datos, métodos y constructor*

{{code:code/u3/clases/rectangle_only.sv}}

- La clase junta los **datos** (`length`, `width`) con **lo que se hace con
  ellos** (`area()`). El área se calcula en un solo lugar
- `new()` es el *constructor*: corre una vez, cuando se crea el objeto
- `.l(50)` es pasaje de argumentos **por nombre**. UVM lo usa todo el tiempo

Note:
La comparación con la slide anterior es la clase entera: los mismos dos campos,
más una función que antes vivía suelta. Vale señalar `area()` y decir que ésa es
toda la diferencia — el dato y lo que se hace con el dato viajan juntos.
`new()` conviene presentarlo sin misterio: es una función común, con un nombre
reservado, que el simulador llama sola cuando se crea el objeto. Devuelve el
handle. No hace nada mágico y no hay un destructor del otro lado.
El pasaje por nombre parece cosmético y no lo es: cuando el constructor tenga
cinco argumentos —y el de `uvm_component` tiene dos que **siempre** son los
mismos— `.l(50)` es lo que hace que la llamada se lea sin ir a buscar la firma.
Todo `code/` del curso está escrito así.
Y la pregunta para dejar picando, que se contesta en la slide siguiente: si
declaro `rectangle r;` y no llamo a `new()`, ¿cuántos objetos hay?

---

## Clases y extensiones

#### *Handle y objeto no son la misma cosa*

```systemverilog
rectangle rectangle_h;               // 1. un HANDLE. Todavia no hay objeto: vale null
rectangle_h = new(.l(50), .w(20));   // 2. new() crea el OBJETO y devuelve su handle
```

- Declarar un handle **no crea nada**. Hasta el `new()` vale `null`, y usarlo
  ahí revienta en tiempo de simulación, no de compilación
- El handle se parece a un puntero, pero no admite aritmética: no hay `h + 1`
- La memoria de una `struct` la reserva el simulador apenas la ve; la de un
  objeto, recién en el `new()`
- Y no hay `free()`: cuando no queda ningún handle apuntándolo, el objeto se
  recolecta solo

Note:
El null pointer es EL error de la primera semana, y el mensaje de Verilator no
ayuda: te dice que dereferenciaste null, no dónde te faltó el `new()`.
Vale la pena escribir las dos líneas en el pizarrón y preguntar cuántos objetos
hay después de cada una. La respuesta es cero y uno.
Esto vuelve dos veces más en el curso: en las jerarquías de clases, cuando `obj1_h = obj2_h`
copia el handle y no el objeto; y en los tests, cuando la virtual interface que no
se leyó del config_db queda en null.

---

## Clases y extensiones

#### *Extender: `extends` y `super`*

{{code:code/u3/clases/classes.sv|lines=6-29}}

- `square extends rectangle` hereda `length`, `width` y `area()` **sin copiar
  una línea**. Un cuadrado es un rectángulo con una restricción, y el código lo
  dice así
- El constructor del hijo llama a `super.new()`: la parte de arriba del objeto
  también hay que construirla, y va **primero**
- Extender no es copiar: si mañana `area()` cambia, cambia para los dos

Note:
El orden del constructor es lo primero que hay que fijar, porque es obligatorio y
falla feo: `super.new()` va **antes** que cualquier otra cosa del hijo. La razón
es física — el objeto es uno solo, y la parte que aporta la clase base tiene que
estar construida antes de tocar nada. Si te lo olvidás, SystemVerilog lo llama
solo cuando el constructor de la base no lleva argumentos, y no compila cuando sí
los lleva. El día 3, `uvm_component` los lleva.
El último bullet es el argumento entero de la unidad y vale decirlo con un
ejemplo: si `area()` cambia mañana, en la versión con `struct` hay que acordarse
de los dos lugares; acá cambia en uno y el otro se entera solo. Ese "se entera
solo" es lo que se compra con la herencia, y es la misma promesa que el día 6
hace el `env` con los tests.
Y el aviso de hacia dónde va, para que la palabra no aparezca fría en la slide
siguiente: heredar deja al hijo *usar* lo del padre. Lo que todavía no se puede
es que el padre llame a la versión del hijo — eso es polimorfismo, y es la sección
que sigue.

---

## Clases y extensiones

#### *Dónde reaparece todo esto*

| Lo que acabás de ver | Cómo se llama en UVM |
| --- | --- |
| clase con datos y métodos | `uvm_object` — las *transactions* del día 5 |
| clase que además vive en el árbol del TB | `uvm_component` — driver, monitor, scoreboard |
| `new()` | el constructor, con `name` (y `parent` si es un component) |
| `extends` | cada test, cada tester, cada agent del curso |
| `super.new()` | la primera línea obligatoria de todo constructor de UVM |

- Falta una pieza: guardar un objeto `square` en una variable `rectangle`.
  Eso es la unidad que sigue

Note:
Cerrar con la tabla y no con el ejemplo: el alumno tiene que irse sabiendo que
esto no era un rodeo de programación, era el vocabulario del resto del curso.
El último bullet deja la puerta abierta al polimorfismo, que es lo único que
falta para poder leer una factory.

---

## Clases y extensiones

#### *Resumen de la unidad*

- **Módulos = estructura**, se elaboran una vez y viven para siempre.
  **Clases = datos y comportamiento**, se crean y se tiran en simulación
- Un estímulo se parece a lo segundo, no a lo primero. Por eso el testbench se
  muda a clases — y por eso **UVM es una librería de clases**
- Una `struct` guarda datos y nada más. Una clase junta los datos **con lo que
  se hace con ellos**, y además se puede extender
- **Declarar un handle no crea nada.** Hasta el `new()` vale `null`, y usarlo
  ahí es el error que más se repite en toda la semana
- No hay `free()`: cuando no queda ningún handle apuntando al objeto, se lo
  lleva el garbage collector
- **Extender** una clase es agregarle o redefinirle cosas sin tocar la original.
  Es la base de todo lo que viene

Note:
Cierre de la unidad que abre el día más abstracto del curso. Conviene anclar con
la promesa concreta: todo esto existe para que en el testbench en objetos el testbench del
día 1 se pueda escribir sin un solo módulo, y en el `env` se pueda cambiar el
estímulo sin tocar el env.
El `null` merece una vuelta más porque vuelve tres veces: acá, en los tests
con la virtual interface que no se leyó del `config_db`, y en las jerarquías de clases cuando
`obj1_h = obj2_h` copia el handle y no el objeto.
