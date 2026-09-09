<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *1 de 8 · Handle y objeto*

**`rectangle rectangle_h;` — después de esa línea, ¿cuántos objetos hay?**

- [x] Ninguno: `rectangle_h` vale `null` hasta que alguien llame a `new()`
- [ ] Uno, con `length` y `width` en 0
- [ ] Uno a medio construir: los campos existen pero el constructor no corrió
- [ ] Depende de si la clase tiene constructor

> **Ninguno** — declarar un handle no reserva nada. Ahí está la diferencia con una `struct`, que el simulador reserva apenas la ve. Y usar el handle antes del `new()` no falla al compilar: revienta en medio de la simulación.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *2 de 8 · Polimorfismo*

**Una variable de tipo `trago` guarda un objeto `fernet`. Si `servir()` no es `virtual`, ¿qué se ejecuta?**

- [ ] El `servir()` de `fernet`
- [ ] Error de compilación
- [x] El `servir()` de `trago`
- [ ] Los dos, primero el de la clase base

> **El de `trago`** — sin `virtual`, SystemVerilog mira el **tipo de la variable**, no el del objeto. Es literal lo que imprime `code/u3/polimorfismo/01-sin-virtual`: *"A generic trago cannot be served"*.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *3 de 8 · Clases abstractas*

**¿Qué gano usando una clase abstracta con métodos `pure virtual` en vez de una clase base cuyo método hace `$fatal`?**

- [ ] Nada, es cuestión de estilo
- [x] Que el error pasa de la simulación al compilador
- [ ] Que se puede instanciar la clase base
- [ ] Que el simulador puede elegir el override más específico en tiempo de ejecución

> **El error pasa al compilador** — con `$fatal` te enterás a mitad de la simulación de que faltaba un override. Con `pure virtual` no compila. Atajar antes siempre es más barato.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *4 de 8 · Variables estáticas*

**Instancio 10 objetos de una clase que tiene una variable `static`. ¿Cuántas copias hay en memoria?**

- [ ] 10, una por objeto
- [ ] 0 hasta que alguien la escribe: la memoria se reserva en el primer acceso
- [x] 1, compartida por todas las instancias
- [ ] Depende del simulador

> **Una sola** — y existe aunque no instancies ningún objeto. Eso es lo que la hace útil para datos globales del TB, y lo que la hace peligrosa si la dejás pública.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *5 de 8 · Métodos estáticos*

**¿Por qué conviene declarar `protected` la variable estática y exponerla con métodos estáticos?**

- [x] Para poder cambiar la estructura de datos sin tocar a quien la usa
- [ ] Porque una `static` sin `protected` se reserva una vez por instancia
- [ ] Para que ocupe menos memoria
- [ ] Porque UVM lo exige

> **Para poder cambiarla después** — si la cola está a la vista, el día que la cambiás por otra estructura tenés que salir a corregir todos los lugares que la tocaban. Encapsular es poder cambiar de opinión.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *6 de 8 · Clases paramétricas*

**`bandeja#(fernet)` y `bandeja#(mojito)` tienen adentro una queue `static`. ¿Comparten la queue?**

- [ ] Sí, `static` es una sola para todos
- [ ] Sí: el parámetro cambia el tipo de los métodos, no el almacenamiento estático
- [ ] Depende de si se instancian o no
- [x] No: cada especialización es una clase distinta, con su propia queue

> **No la comparten** — SystemVerilog genera **una clase por combinación de parámetros**. `static` es único dentro de cada una de esas clases, no entre todas. UVM se apoya en esto todo el tiempo.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *7 de 8 · El patrón factory*

**¿Qué problema resuelve el patrón factory?**

- [ ] Crear objetos más rápido
- [x] Decidir en tiempo de ejecución qué subtipo construir
- [ ] Evitar tener que declarar clases
- [ ] Centralizar los `new()` en una sola clase, para poder contarlos y liberarlos

> **Decidir el subtipo en runtime** — sin hardcodear el `new`: le pedís un objeto a la fábrica y ella decide cuál. Es la pieza que después te va a dejar cambiar el estímulo de un test entero sin tocar el código del `env`.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 2

#### *8 de 8 · $cast*

**¿Cuándo tiene éxito un `$cast(destino, origen)`?**

- [ ] Siempre: convierte cualquier clase en cualquier otra
- [ ] Sólo entre clases sin herencia
- [ ] Cuando las dos clases tienen los mismos campos, aunque no estén emparentadas
- [x] Sólo si el objeto de `origen` es de la clase de `destino` o de una derivada

> **Sólo si el objeto lo permite** — `$cast` chequea **en runtime** y devuelve 0 si no da. Por eso la factory de UVM es más cómoda que la `cantina` de la sección: el `type_id::create()` devuelve el tipo correcto y te ahorra el casteo.
