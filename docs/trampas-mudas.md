<!-- Generado por tools/build.mjs desde slides/172-apendice-trampas.md.
     NO editar a mano: la fila se corrige en la slide y esto se regenera con
     `npm run build`. `npm run check` falla si quedo viejo. -->

# Las 20 trampas mudas de UVM

Todo lo que **compila, corre y miente**: los errores de un testbench UVM que no
dan un warning, no dejan la regresión en rojo, y se descubren semanas después —
o no se descubren.

Es el apéndice del día 7 de [*Verify This!*](https://leandrotozzi.github.io/verifythis/),
un curso de UVM en español que corre entero con **Verilator**, sin licencias de
EDA. Está acá afuera del deck porque es la página que uno busca a las tres de la
mañana, y una diapositiva no se puede googlear.

> **En verificación el error caro no es el que rompe, es el que miente.** Un
> error de compilación cuesta dos minutos; un testbench que pasa midiendo lo que
> no es cuesta un tape-out.

## Compila, corre, y miente

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| La cobertura da **0 %** | falta el `new()` o el `sample()` del covergroup | un `sample()` por transacción, en el subscriber | Cobertura funcional |
| La hija corre el método de **la madre** | sin `virtual`, SV resuelve por el **tipo de la variable**, en compilación | `virtual` en todo método que alguien vaya a extender | Polimorfismo |
| El component lee **la config de otro** | `get(null, "*", …)` devuelve lo primero que matchee | `get(this, "", …)`, y `+UVM_CONFIG_DB_TRACE` | Tests |
| El test pasa con **el estímulo equivocado** | el `set_type_override()` llegó **después** del `create()` del env | el override primero, siempre. `+TOPOLOGY` lo delata | El env |

## El que publica y el que escucha

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| El subscriber cuenta **0** y el monitor imprime 1000 | falta el `connect()` en el `connect_phase` | corregir cruzado: contra lo que dice el que ya andaba | Analysis ports · d4 |
| El monitor **no publica nunca**, y grita el scoreboard | falta `bfm.command_monitor_h = this` en el `build_phase` | el `uvm_fatal` aparece en la clase que **no** tiene la culpa | Analysis ports |
| La copia **pierde los campos de la madre** | un `do_copy()` que no llama a `super.do_copy(rhs)` | todos los `do_copy()` llaman primero al de arriba | Jerarquías |
| Dos transactions distintas **comparan iguales** | `super.do_compare()` llamado en una línea suelta y descartado | encadenado con `&&`, nunca suelto | Transactions |

## Estímulo, ámbito y objections

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| Los bins de borde **no se llenan nunca** | `dist` con `:=`: el peso va a **cada** valor del rango | medir el histograma **una vez**, con `:/` | Constrained random |
| El `randomize()` **no corre** con las asserts apagadas | `assert(x.randomize())` — `assert` es una directiva de simulación | `if (!x.randomize()) uvm_fatal(…)` | Constrained random |
| Bajo el override, **algunas** transactions son del tipo viejo | un `new()` donde iba `type_id::create()` | por la factory pasa lo que se crea con `create()` | Transactions |
| Los **dos agents** arrancan iguales | dos `set()` con ámbito `"*"`: el segundo pisa al primero | el ámbito es la **ruta** del que lee, con `*` al final | Agents · d6 |
| El agent arranca **activo** aunque pusiste `is_active` en el `config_db` | falta el `super.build_phase()`: el que lo lee es `uvm_agent` | o config object, o `super` — nunca media de cada una | Agents |
| La simulación **no termina nunca** | un `item_done()` que no se llamó | `+UVM_TIMEOUT=5ms` primero, el trace después | Agents |
| Termina en **t=0** y dice PASS | nadie levantó la objection alrededor de la sequence | `+UVM_OBJECTION_TRACE` | Sequences |

## Las cuatro de las assertions

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| El log dice **PASS** y las properties no corrieron | falta `--assert` al compilar | el `cover property` en 0 es el único que avisa | Assertions |
| La property **pasa siempre** | el antecedente nunca ocurre, o la implicación es la que no va | un `cover property` por cada `assert property` | Assertions |
| **185 falsos positivos** y el DUT está sano | la muestreás con el flanco en el que se escribe | estímulo en `negedge`, respuesta del DUT en `posedge` | Assertions · d7 |
| Falsos positivos **al arrancar** cada test | falta el `disable iff (!reset_n)` | `default disable iff`, una vez, arriba de todo | Assertions |

## Y la que trae el clocking block

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| El scoreboard falla **una vez cada veinte** y el waveform se ve bien | media señal se lee por `cb.sig` y la otra media por `sig` | si entró al clocking block, **todo** el protocolo la lee por ahí | Interfaces y BFM |

---

## Las siete perillas de debug

Cuál mirar según el síntoma está en el otro apéndice del curso, *La caja de
herramientas de debug*: se lee en
[`libro/dia7.html`](https://leandrotozzi.github.io/verifythis/libro/dia7.html#cuál-usar-según-el-síntoma).

| Flag | Para qué |
| --- | --- |
| `+UVM_VERBOSITY=UVM_HIGH` | prender los mensajes de debug que ya están escritos |
| `+UVM_CONFIG_DB_TRACE` | quién puso y quién leyó cada entrada del `config_db` |
| `+UVM_OBJECTION_TRACE` | quién levantó y quién bajó cada objection |
| `+UVM_TIMEOUT=5ms` | cortar una simulación colgada y ver dónde quedó |
| `print_topology()` | el árbol de componentes que UVM armó **de verdad** |
| `--assert` | sin este flag las properties concurrentes no se evalúan |
| `--trace` + GTKWave | cuando ninguna de las seis anteriores alcanza |

---

El curso es **CC BY 4.0**. Código, ejemplos y el capstone:
**[github.com/leandrotozzi/verifythis](https://github.com/leandrotozzi/verifythis)**
