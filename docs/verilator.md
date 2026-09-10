# Matriz de Verilator

Generada por `sh tools/verilator-matrix.sh` (o `make matrix`). **Esto
caduca**: vale para la version y la fecha de abajo, no en general.

- **Verilator**: `Verilator 5.052 2026-09-05 rev v5.052`
- **UVM**: 2020.3.1 (Accellera uvm-core, IEEE 1800.2-2020) — `make uvm`
- **Fecha**: 2026-09-08
- **Resultado**: 38 pasan, 0 fallan

Verilator es el unico simulador del curso. No hay flujo Questa: los `run.do`
se borraron y el DUT en VHDL tambien.

```sh
make              # los 38 ejemplos
make u4/tests         # uno solo
make matrix       # todos, y regenera este archivo
```

Los ejemplos con UVM tardan **minutos** en compilar (100-121 s cada uno en el CI,
15 s con ccache caliente). La corrida
completa es de casi una hora. Los flags compartidos estan en
`code/verilator/common.sh`.

## Requisitos: con Verilator solo no alcanza

| | Para que | Si no esta |
|---|---|---|
| `z3` | `randomize()` con constraints: Verilator llama a un solver SMT externo | compila, corre, y **`randomize()` devuelve 0**. Afecta `u5/varios-objetos`, `u6/transactions`, `u7/agents`, `u7/sequences` y los ejercicios de los dias 5, 6 y 7 |
| `ccache` | opcional: baja la segunda compilacion de un ejemplo con UVM de 92 s a 15 s | nada, se recompila entero cada vez |

El de `z3` es el peor modo de falla que tiene el curso, porque es mudo: no hay
error de compilacion, hay una linea suelta en la salida —`Tried: $ z3 --in`— y
despues cada `randomize()` devuelve 0. `apt install z3` / `brew install z3`. La
imagen de Docker y el devcontainer ya lo traen.

## Cobertura funcional: anda, con agujeros

Los covergroups entraron en **Verilator 5.050** (2026-07-01) y se ampliaron en
5.052. La columna *Cobertura* de la matriz es el numero real que reporta
`verilator_coverage`, no un placeholder.

El flujo es: compilar con `--coverage-user` y llamar a `cov_report` despues
del run. El `.dat` queda en `obj_dir/<top>/coverage.dat`.

```
Coverage Summary:
  covergroup : 86.8% (66/76)
```

Lo que **si** mide: coverpoints, bins de valor y de rango, `ignore_bins`
—con la salvedad de la tabla de abajo—,
cross implicito, y de las opciones del covergroup estas dos:

| Anda | Detalle |
|---|---|
| `option.auto_bin_max` | en el covergroup y en el coverpoint. El default es 64 |
| `option.at_least` | **solo escrito en el coverpoint** |

Lo que **no** (5.052), y por eso los numeros de arriba no son los de una
herramienta comercial:

| Falta | Que pasa |
|---|---|
| bins de transicion (`=>`, `[* n]`) | Internal Error, no compila |
| `binsof` / `intersect` / bins explicitos de cross | `%Warning-COVERIGN`, los ignora y sigue |
| bins automaticos de un `enum` | uno por valor del **tipo base** y no por miembro: `operation_t` es `bit [2:0]`, y el `3'b110` que el enum no tiene sale como `auto_5` y queda en 0 para siempre. De ahi el 86.8 % de arriba: los 10 bins que faltan son ese valor y sus 9 cruces |
| `option.at_least` en el **covergroup** | lo ignora **sin avisar**: los coverpoints siguen contando con un hit |
| `option.weight` | `%Warning-COVERIGN`, lo ignora y sigue |
| `ignore_bins` | los respeta al filtrar, pero **emite un bin por cada uno y lo cuenta como cubierto**: en `u2/convencional` son `all_ops.null_ops` (664 hits) y `borrow.resto` (2156). Una herramienta compatible no los reportaria |
| `type_option.merge_instances` | sin efecto observable, porque la cobertura type-wide da 0 igual |
| `get_coverage()` type-wide | devuelve siempre 0 — hay que usar `get_inst_coverage()` |
| `$stop` | aborta antes de escribir el `.dat` — hay que terminar con `$finish` |

El de `at_least` es el peor de la tabla porque es mudo: la misma linea vale en
un lugar y no vale en el otro, sin un warning. Un covergroup que pide diez hits
por bin reporta como si pidiera uno.

Los bins de transicion del curso quedaron en el codigo, entre
```ifndef VERILATOR```: son parte del tema y se leen igual. Repro minimo de
los cuatro puntos: `code/verilator/repro-cg-transition.sv`, y de las opciones:
`code/verilator/repro-cg-options.sv`, que termina en `$fatal` si alguno de los
seis numeros cambia.

## Assertions (SVA): andan, y hay que pedirlas

Los tres ejemplos de SVA compilan con `--assert` (`u8/assertions`, `ejercicios/d7-sva`
y la etapa 5 de `ejercicios/d7-final`). **Sin ese flag las
properties concurrentes se compilan y no se evaluan**: no hay warning, la
corrida da 0 errores y el bloque entero de la interface queda de adorno. Es el
peor modo de falla despues del de `z3`, y por la misma razon: es mudo.

```sh
verilator --binary --timing --assert --coverage-user ...
```

Medido en 5.052, con el bloque de `code/u8/assertions/vtalu_bfm.sv`:

| Anda | Detalle |
|---|---|
| `assert property` / `cover property` | tambien **dentro de una `interface`**, con UVM enlazada |
| `\|->` `\|=>` `##n` `##[a:b]` | la ventana `##[1:5]` de la unidad 8 |
| `$rose` `$fell` `$stable` `$past(x, n)` | |
| `throughout`, `b[->1]` | |
| `property` / `sequence` con nombre y argumentos | argumentos de **senal** |
| `default clocking`, `default disable iff` | |
| el `else` de la assertion, con `` `uvm_error `` | cuenta en el **Report Summary**, y `uvm_summary_ok` lo detecta sin tocar nada |
| `%m` en el mensaje | dice **que instancia** de la interface fallo |
| `cover property` en el mismo `coverage.dat` | sale como `user:` junto al `covergroup:` |

| Falta | Que pasa |
|---|---|
| un formal de `sequence` usado como **retardo** (`sig ##n !sig`) | `Delay value is not a non-negative elaboration-time constant`, no compila. Con el retardo literal anda |

La accion por defecto de una assertion sin `else` es `$stop`, y eso en este
flujo es lo que **no** se quiere: aborta antes de escribir el `.dat` de
cobertura y antes de que UVM imprima el resumen. Siempre `else` con
`` `uvm_error ``.

## Clocking blocks: andan, y hay una race que NO se ve aca

Los `clocking block` de la unidad 2 funcionan en 5.052: `default input #1step
output #0`, `@(cb)` como evento, y el muestreo del valor estable previo al
flanco. `code/u2/clocking/` los ejercita, y `con_clocking.sv` termina en
`$fatal` si el muestreo deja de dar el valor esperado — o sea que si una version
futura cambia la semantica, el CI avisa.

Lo que **no** se puede mostrar con Verilator es la race del lado del *manejo*.
Medido en 5.052:

```systemverilog
@(posedge clk); d_in  = 8'd10;   // blocking
@(posedge clk); d_in <= 8'd10;   // no bloqueante
```

Las dos dan **el mismo resultado**. La race con `=` depende del orden en que el
simulador corre los procesos de la region Active, y ese orden no esta definido
por el LRM: Verilator elige uno y es consistente consigo mismo. En otro
simulador puede dar lo contrario.

Es el peor tipo de bug que existe —pasa en tu simulador y falla en el del
cliente— y por eso el curso lo cuenta pero no lo demuestra: no hay forma honesta
de demostrarlo con una sola herramienta. La regla se sostiene igual: **el driver
maneja con `<=`**.

Lo que si se demuestra, y es la trampa que agrega el clocking block, es la
mezcla de dominios: `code/u2/clocking/mezcla.sv` imprime `3` y `4` para el mismo
cable en el mismo instante, segun se lea `bfm.cb.d_out` o `bfm.d_out`. La
discusion completa, con las fuentes, en [`clocking-blocks.md`](clocking-blocks.md).

## RAL: anda entero, y es la novedad

El registro es la parte de UVM de la que nadie decia si funcionaba en Verilator,
asi que **se probo antes de escribir una sola slide**. Anda todo lo que usa la
unidad 9. Medido en 5.052, con `code/u9/ral/`:

| Anda | Detalle |
|---|---|
| `uvm_reg_block` / `uvm_reg` / `uvm_reg_field` | `configure()`, `create_map`, `add_reg`, `lock_model` |
| `uvm_reg_adapter` | incluido el `const ref uvm_reg_bus_op` de la firma de `reg2bus` |
| frontdoor `write()` / `read()` | por el sequencer y el driver del capstone, sin tocarlos |
| `mirror(UVM_CHECK)` | reporta el mismatch, y respeta `set_compare(UVM_NO_CHECK)` |
| prediccion automatica **y** explicita | `set_auto_predict(0)` + `uvm_reg_predictor` colgado del monitor |
| `uvm_reg_hw_reset_seq`, `uvm_reg_bit_bash_seq` | las dos generan estimulo del modelo y cazan un acceso mal declarado |
| `get_offset`, `get_fields`, `get_access` | la introspeccion con la que `mapa_test` imprime el mapa |

Sin flags nuevos: los mismos de `vlt_uvm`, mas `-Wno-WIDTHEXPAND`, que solo
saca ruido — `uvm_reg_data_t` son 64 bits y cualquier literal de 32 se ensancha.

Lo que el curso **no** probo, y por eso no esta en la unidad: el **backdoor**
(`add_hdl_path` y `uvm_reg_backdoor`), que depende del acceso jerarquico del
simulador, y con el las sequences que lo necesitan — `uvm_reg_access_seq` entre
ellas.

## El agujero que se cerro: tasks de interface via virtual interface

**Arreglado en Verilator 5.052** (2026-09-05). Queda documentado porque el curso
soporta desde 5.050, y en 5.050 y 5.051 el problema esta presente.

Hasta 5.051, una task declarada **dentro de una interface** e invocada **a traves
de una virtual interface** escribia las senales, pero no despertaba la logica
combinacional que dependia de ellas. Verilator no avisaba: compilaba limpio y
simulaba mal. En el VTALU se veia asi — `op_set` cambia, `op` no:

```
[t=310] op_set=001  op=000  start=1  start_single=0  done=0
```

Con `op` clavado en `no_op`, `done` nunca subia y el testbench se quedaba en
`while (done == 0)` para siempre. Era el caso peligroso: no un error de
compilacion, sino una simulacion que miente.

Repro minimo: `code/verilator/repro-vif-task.sv`. Medido, tres corridas,
determinista:

| | `op_set` | `op` | `y` |
|---|---|---|---|
| Esperado (IEEE 1800-2017) | 101 | 101 | 1 |
| Verilator 5.048 | 101 | **000** | **0** |
| **Verilator 5.052** | 101 | **101** | **1** |

Mientras el bug estuvo abierto, el curso movio el protocolo (`reset_alu`,
`send_op`) de la interface a la clase que lo usaba. **Con el bug cerrado se
volvio atras**: el protocolo vive de nuevo en `vtalu_bfm.sv`, que es donde lo
pone la unidad 3 y donde lo pone el libro de Salemi. El driver de un agent quedo
en tres lineas: pedir el item, `bfm.send_op(...)`, `item_done()`.

Los `vcs_base_tester.svh` se borraron, junto con `u4/reporting/vtalu_tlm_bfm.sv`,
`u4/reporting/vtalu_driver_c.svh` y `u4/tests/tb_classes/selfcheck.svh`. Ningun flujo los
compilaba y ninguna slide los mostraba.

## Y dos mas, del lado de las constraints

Salieron de escribir la unidad de Constrained Random. Los dos compilan limpio y
simulan mal, que es la clase peligrosa.

| Falta | Que pasa | Repro |
|---|---|---|
| `solve ... before` | se acepta y NO se respeta: deja el campo de control clavado en 0, peor que ignorarlo | `code/verilator/repro-solve-before.sv` |
| `randomize() with {}` sobre un campo con `dist` | el `dist` se resuelve eligiendo un valor ANTES de chequear el resto: si no cumple, devuelve 0 en vez de reintentar | `code/verilator/repro-dist-with.sv` |

Los dos tienen rodeo portable, y los dos estan en las slides:

- en vez de `solve es_reset before A`, pedir el reparto del campo de control
  con un `dist` — Verilator si lo respeta (51,7 % medido contra 0,3 % sin nada);
- antes del `with {}` dirigido, apagar la constraint de reparto con
  `constraint_mode(0)`, que para un caso dirigido no tiene sentido igual.

El segundo no falla siempre ni nunca: falla **con la probabilidad de que el
valor sorteado no cumpla el `with`**. Con
`A dist {8'h00 :/ 1, [8'h01:8'hFE] :/ 2, 8'hFF :/ 1}`, medido sobre 400
randomizaciones:

| `with {}` | exito | por que |
|---|--:|---|
| `A == 8'hFF` | ~25 % | el peso del bin `FF` |
| `A inside {[1:10]}` | ~2 % | 10 valores de los 254 del bin del medio, x 50 % |
| `A != 8'h00` | ~75 % | falla solo cuando sortea el bin `00` |
| `B == 8'hFF` | 100 % | `B` no tiene `dist` |

Un campo sin `dist` no se ve afectado. El sintoma tipico es el peor de todos:
**un caso dirigido intermitente**, que anda en la maquina de uno y falla en la
regresion.
Desde 5.052 la falla al menos **avisa**: cada `randomize()` que no encuentra
solucion emite un `%Warning-UNSATCONSTR` con la constraint exacta que no se pudo
satisfacer. Sigue devolviendo 0 y sigue haciendo falta el `assert(randomize())`
—el warning va al log, no al Report Summary—, pero ya no es una trampa muda del
todo.


Lo mismo pasa con una constraint **de la clase** sobre un campo que tiene
`dist`, sin `with {}` de por medio: `addr dist {...}` junto a
`addr[1:0] == 2'b00` sale con dos `%Warning-UNSATCONSTR` y `randomize()` en 0.
La salida es escribir el `dist` con los valores ya buenos, uno por uno, en vez de
un rango mas una constraint que lo recorte -- que es lo que hace
`code/ejercicios/d7-final/solucion/tb_classes/apb_transaction.svh`.

Lo que **si** anda de constraints: `dist` con `:=` y `:/`, `inside`,
implicaciones (`->`), `constraint_mode()`, `rand_mode()`, y
`randomize() with {}` mientras no restrinja un campo que tenga `dist`.

## Trampa al editar: un comentario que empieza con "verilator"

Un `//` cuyo primer token es `verilator` **no es un comentario**: Verilator lo
lee como pragma y el build muere con `%Error-BADVLTPRAGMA`. No importa la
mayuscula ni cuantos espacios haya en el medio.

```systemverilog
// verilator --binary ... repro.sv     <- rompe el build
// Verilator 5.052 devuelve 0 ...      <- rompe el build
//   $ verilator --binary ... repro.sv  <- ok, el primer token es "$"
// En 5.052 devuelve 0 ...             <- ok
```

Los tres `code/verilator/repro-*.sv` cayeron en esto: la linea que documentaba
como correrlos empezaba con `verilator`, asi que ninguno de los tres compilaba
—incluido el que cita la slide de bins de transicion—. Si vas a escribir el
comando en un comentario, ponele un `$` de prompt adelante.

## Que un ejemplo "pase" no alcanza

PASA quiere decir que compilo, corrio, salio con codigo 0 y que el Report
Summary de UVM cerro en 0 UVM_ERROR / 0 UVM_FATAL — `run_sim` lo parsea, porque
UVM no cambia el codigo de salida por un `uvm_error`. El unico opt-out es u4/reporting,
que rompe el scoreboard a proposito. El chequeo que le da
peso es u4/tests: termina con **0 UVM_ERROR / 0 UVM_FATAL** y con el `$finish` en
**41 ns**, el mismo punto en que terminaba con UVM 1.2 — que a su vez marcaba
`TEST_DONE @ 40540`, exactamente el numero de la corrida de referencia guardada
en `code/u4/tests/output.questa`.

Ese `TEST_DONE` ya no aparece: en IEEE 1800.2 el objection no emite ese
UVM_INFO. La cadena de comparacion sigue cerrada igual (Questa 1.1d -> Verilator
+ UVM 1.2 -> Verilator + UVM 2020.3.1), pero el ancla ahora es el tiempo de
`$finish`, no el mensaje. `output.questa` queda como testigo, no como flujo.

## Matriz

| Ejemplo | Verilator | Cobertura | Nota |
|---|---|:--:|---|
| `u2/clocking` | PASA | — |  |
| `u2/convencional` | PASA | 86.8% (66/76) |  |
| `u2/interfaces-bfm` | PASA | 86.8% (66/76) |  |
| `u3/clases (run_class)` | PASA | — |  |
| `u3/clases (run_rectangle)` | PASA | — |  |
| `u3/clases (run_struct)` | PASA | — |  |
| `u3/estaticas/01-variables` | PASA | — |  |
| `u3/estaticas/01-variables (run_ejemplo2)` | PASA | — |  |
| `u3/estaticas/02-metodos` | PASA | — |  |
| `u3/factory` | PASA | — |  |
| `u3/parametricas/01-memoria` | PASA | — |  |
| `u3/parametricas/02-estatica` | PASA | — |  |
| `u3/parametricas/03-instanciada` | PASA | — |  |
| `u3/polimorfismo/01-sin-virtual` | PASA | — |  |
| `u3/polimorfismo/02-virtual` | PASA | — |  |
| `u3/polimorfismo/03-virtual-pura` | PASA | — |  |
| `u3/tb-en-objetos` | PASA | 85.5% (65/76) |  |
| `u4/components` | PASA | 86.8% (66/76) |  |
| `u4/env` | PASA | 86.8% (66/76) |  |
| `u4/reporting` | PASA | 28.9% (22/76) |  |
| `u4/tests` | PASA | 86.8% (66/76) |  |
| `u5/analysis-ports` | PASA | 86.8% (66/76) |  |
| `u5/put-get` | PASA | 86.8% (66/76) |  |
| `u5/threads/01-modulos` | PASA | — |  |
| `u5/threads/02-bloqueante` | PASA | — |  |
| `u5/threads/03-no-bloqueante` | PASA | — |  |
| `u5/varios-objetos/01-sin-analysis-port` | PASA | 81.8% ( 9/11) |  |
| `u5/varios-objetos/02-con-analysis-port` | PASA | 100.0% (11/11) |  |
| `u6/jerarquias` | PASA | — |  |
| `u6/transactions/constraints` | PASA | — |  |
| `u6/transactions` | PASA | 86.8% (66/76) |  |
| `u7/agents` | PASA | 86.8% (66/76) |  |
| `u7/callbacks` | PASA | 86.8% (66/76) |  |
| `u7/sequences` | PASA | 86.8% (66/76) |  |
| `u7/sequences/virtual` | PASA | 86.8% (66/76) |  |
| `u8/assertions` | PASA | 86.8% (66/76) |  |
| `u8/dpi` | PASA | 86.8% (66/76) |  |
| `u9/ral` | PASA | — |  |

