<!-- .slide: class="quiz" -->

## Repaso · Día 4

#### *1 de 5 · Observer Pattern*

**En el patrón Observer, ¿qué sabe el objeto observado sobre sus observadores?**

- [ ] Cuántos son y de qué tipo
- [ ] Sólo el primero que se suscribió
- [ ] Los conoce porque se los pasan en el constructor, uno por uno
- [x] Nada: ni cuántos son, ni quiénes son

> **No sabe nada** — y esa ignorancia es la gracia. Agregar un cuarto subscriber no obliga a tocar una línea del que publica.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 4

#### *2 de 5 · Analysis Ports*

**Un `uvm_subscriber` necesita datos de dos analysis ports distintos. ¿Cómo se resuelve?**

- [ ] Implementando dos veces el método `write()`
- [x] Con una `uvm_tlm_analysis_fifo` para el segundo puerto
- [ ] Registrando el componente dos veces en la factory, una por puerto
- [ ] Conectando los dos puertos al mismo `analysis_export`

> **Con una `uvm_tlm_analysis_fifo`** — un `uvm_subscriber` tiene un solo `write()`, así que sólo puede escuchar un puerto. La FIFO da un `analysis_export` de un lado y un `try_get()` del otro. Es lo que hace el scoreboard del VTALU.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 4

#### *3 de 5 · Intra vs. inter thread*

**Cuando el monitor publica y se ejecutan los `write()` de los subscribers, ¿cuántos threads intervienen?**

- [ ] Uno por subscriber
- [ ] Dos: el del publicador y el del suscriptor
- [x] Uno solo: `write()` es una llamada a función
- [ ] Uno por subscriber más el del monitor, y UVM los sincroniza al final del delta

> **Uno solo, y es comunicación intra-thread** — `write()` es una `function`, no una `task`: no consume tiempo y corre en el thread del que publica. Justamente por eso hace falta **otro** mecanismo (put/get + FIFO) para hablar entre threads.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 4

#### *4 de 5 · Put y get ports*

**El consumidor llama a `get()` y la `uvm_tlm_fifo` está vacía. ¿Qué pasa?**

- [x] Se bloquea hasta que el productor ponga un dato
- [ ] Devuelve 0 y sigue
- [ ] Error fatal de UVM
- [ ] Devuelve el último dato leído, que sigue en la FIFO hasta que lo pisen

> **Se bloquea** — `get()` es bloqueante, y por eso se declara `task` y no `function`. Esa es toda la sincronización: no hace falta un handshake de señales a mano.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 4

#### *5 de 5 · try_get()*

**¿Y `try_get()` con la FIFO vacía?**

- [ ] Se bloquea igual que `get()`
- [ ] Devuelve 1 con un dato basura
- [x] Devuelve 0 inmediatamente, sin bloquear
- [ ] Espera un ciclo de reloj y reintenta, hasta el timeout de la fase

> **Devuelve 0 y sigue** — es la versión no bloqueante, y por eso puede ser una `function`. Fijate que el scoreboard la usa en un `do ... while` para saltear los `no_op` y los `rst_op`.
