<!-- .slide: class="quiz" -->

## Repaso · Día 3

#### *1 de 7 · `uvm_test`*

**¿Qué te permite hacer `+UVM_TESTNAME=add_test` que antes no podías?**

- [x] Elegir el test sobre un testbench ya compilado, sin recompilar
- [ ] Correr más rápido la simulación
- [ ] Cambiar el DUT sin recompilar
- [ ] Bajar la verbosidad de los mensajes

> **Elegir el test sin recompilar** — UVM lee ese plusarg y le pide el test a la **factory** por nombre. Es la diferencia entre 1000 tests × 5 minutos de compilación y una sola compilación.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 3

#### *2 de 7 · UVM Phases*

**¿En qué orden recorre UVM la jerarquía en `build_phase` y en `connect_phase`?**

- [ ] Las dos de arriba hacia abajo
- [ ] Las dos de abajo hacia arriba
- [x] `build_phase` top-down, `connect_phase` bottom-up
- [ ] En el orden en que se declararon los componentes

> **Build top-down, connect bottom-up** — y tiene sentido: no podés conectar un componente que todavía no existe, así que primero se construye toda la jerarquía y recién después se conecta.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 3

#### *3 de 7 · Objections*

**¿Para qué sirve `raise_objection()` / `drop_objection()` en el `run_phase`?**

- [ ] Para reportar errores del scoreboard
- [x] Para mantener viva la simulación mientras el componente tiene trabajo
- [ ] Para sincronizar dos threads
- [ ] Para registrar la clase en la factory

> **Para que la fase no termine antes** — todos los `run_phase` corren en paralelo, cada uno en su thread, y la fase termina cuando **cae la última objection**. Sin levantarla, la simulación se te termina en el tiempo 0.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 3

#### *4 de 7 · El env*

**¿Qué le toca a cada uno: `uvm_env` y `uvm_test`?**

- [ ] `env` genera el estímulo; `test` arma la estructura
- [ ] Los dos hacen lo mismo, `env` es opcional
- [ ] `env` corre el DUT; `test` corre el scoreboard
- [x] `env` arma la estructura del TB; `test` define qué estímulo se aplica

> **Estructura vs. estímulo** — cada clase hace **una sola cosa bien**. Por eso el `env` casi siempre tiene sólo `build_phase` y `connect_phase`, y el test casi siempre tiene sólo un override de la factory.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 3

#### *5 de 7 · Factory override*

**`set_type_override()` reemplaza `base_tester` por `add_tester`. ¿Cuándo hay que llamarlo?**

- [x] Antes de que corra el `build_phase` que crea el objeto
- [ ] En cualquier momento: la factory lo aplica retroactivamente
- [ ] Después del `connect_phase`
- [ ] Dentro del `run_phase` del tester

> **Antes del `build_phase`** — la factory decide qué construir **en el momento del `create()`**. Si el override llega tarde, el `env` ya instanció la clase base y no hace nada.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 3

#### *6 de 7 · Verbosidad*

**El techo de verbosidad (`+UVM_VERBOSITY=UVM_HIGH`), ¿sobre qué macros actúa?**

- [ ] Sobre las cuatro: info, warning, error y fatal
- [x] Sólo sobre `` `uvm_info ``
- [ ] Sobre error y fatal solamente
- [ ] Sobre ninguna: sólo cambia el formato del mensaje

> **Sólo sobre `` `uvm_info ``** — warnings, errores y fatales son **inmunes** al techo de verbosidad, y está bien que así sea: nadie quiere apagar un error sin querer. Para esos hace falta el mecanismo de *actions*.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 3

#### *7 de 7 · Report actions*

**Querés silenciar los `` `uvm_error `` de un scoreboard que otra persona está arreglando. ¿Dónde va el `set_report_severity_action_hier()`?**

- [ ] En el `build_phase` del `env`
- [ ] En el `run_phase` del test
- [ ] En el constructor del scoreboard
- [x] En el `end_of_elaboration_phase` del `env`

> **En `end_of_elaboration_phase`** — tiene que ser **después** de que la jerarquía esté construida (si no, el componente todavía no existe) y **antes** de que arranque la simulación. Esa fase es exactamente esa ventana.
