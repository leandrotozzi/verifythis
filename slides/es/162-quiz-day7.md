<!-- .slide: class="quiz" -->

## Repaso · Día 7

#### *1 de 5 · Inmediatas y concurrentes*

**¿Cuál es la diferencia de fondo entre `assert(x.randomize())` y `assert property (@(posedge clk) …)`?**

- [ ] Ninguna: la segunda es azúcar sintáctico de la primera
- [ ] La primera se puede apagar por línea de comandos y la segunda no
- [x] La primera es una **sentencia** que corre cuando el hilo pasa por ahí; la segunda es una **declaración con reloj** que se evalúa en cada flanco, sola
- [ ] La primera sólo vale adentro de una clase y la segunda sólo adentro de un módulo

> **Sentencia contra declaración** — la inmediata es a un `if` lo que la concurrente es a un `always_ff`: una se ejecuta, la otra se instancia. Por eso sólo la concurrente puede describir algo que dura varios ciclos.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 7

#### *2 de 5 · `|->` contra `|=>`*

**El `done` del VTALU sale de un `always_ff`. ¿Qué implicación va en `start |?? done`?**

- [ ] `|->`, porque el antecedente y el consecuente son de la misma transacción
- [x] `|=>`, porque lo que se escribe con `<=` en el flanco *n* recién se lee en el *n+1*
- [ ] Cualquiera de las dos: la diferencia es de estilo
- [ ] Ninguna: para señales registradas hay que usar `$past()`

> **`|=>` cuando el consecuente sale de un `<=`** — porque `|=>` *es* `|-> ##1`, y lo que hay que preguntarse es cuántos flancos después lo promete la spec. Con `|->` contra una señal registrada la property no pasa en vacío: **falla en cada transacción**, porque compara contra el `done` viejo. La que sí pasa callada es aquella cuyo antecedente nunca ocurre — por eso va siempre con su `cover property`.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 7

#### *3 de 5 · El flanco de muestreo*

**Todas las properties del VTALU muestreadas en `@(posedge clk)` dan 145 errores sobre 1000 operaciones, y el DUT está sano. ¿Por qué?**

- [ ] Falta el `disable iff (!reset_n)`
- [ ] El `posedge` es demasiado rápido: hay que dividir el reloj
- [x] La BFM escribe el estímulo **en el `negedge`**, y en dos `no_op` seguidas `start` baja y vuelve a subir entre dos `posedge`: el muestreo no lo ve bajar
- [ ] Los covergroups y las assertions no pueden compartir el mismo reloj

> **Una assertion vale lo que vale su muestreo** — el estímulo se muestrea donde el estímulo se escribe. Estímulo en `negedge`, respuesta del DUT en `posedge`: cero errores. Con un solo reloj no hay forma.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 7

#### *4 de 5 · La assertion que no chequea nada*

**Una property `assert` reporta 0 fallas durante toda la regresión. ¿Qué se sabe?**

- [ ] Que la regla que describe se cumple
- [ ] Que el DUT está libre de bugs de protocolo
- [x] Nada todavía: puede que su antecedente no haya ocurrido nunca, o que falte `--assert` y ni siquiera se esté evaluando
- [ ] Que la property tiene un `disable iff` mal escrito

> **Cero fallas y cero evaluaciones se ven igual** — por eso toda assertion va con su `cover property`: es el único chequeo del chequeo. En la sección, `c_mult_3ciclos` se queda en 0 y delata que la latencia real son cuatro flancos, no tres.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 7

#### *5 de 5 · Assertion o scoreboard*

**El DUT devuelve el `result` correcto pero baja `done` un ciclo antes de lo que dice la especificación. ¿Quién lo caza?**

- [ ] El scoreboard, cuando compare el resultado
- [ ] La cobertura funcional, porque el bin de `done` queda vacío
- [x] Una assertion en la interface: es un bug de **protocolo**, y el monitor ya borró el tiempo antes de que la transaction llegue al scoreboard
- [ ] El `uvm_fatal` del `command_monitor`, que dejaría de ver comandos

> **Protocolo → assertion. Datos → scoreboard** — y no es una preferencia: para cuando la transaction llega al scoreboard, el protocolo ya no está. Escribir el chequeo ahí sería reconstruir a mano el tiempo que el monitor acaba de borrar.
