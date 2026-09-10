<!-- .slide: id="apendice-debug" data-machete="res/machete-debug.svg" -->

## Apéndice · La caja de herramientas de debug

#### *Las herramientas que vimos, todas juntas*

| Herramienta | Para qué | Dónde salió |
| --- | --- | :-- |
| `VLT_TRACE=1` + GTKWave | ver las señales de verdad | La spec del VTALU |
| `+UVM_VERBOSITY=UVM_HIGH` | ver los mensajes de los monitores | Reporting |
| `+UVM_CONFIG_DB_TRACE` | quién puso qué en el `config_db`, y quién lo leyó | Agents |
| `+TOPOLOGY` → `print_topology()` | el árbol que UVM armó **de verdad** | Agents |
| `+UVM_OBJECTION_TRACE` | quién levantó y quién bajó la objection | Tests |
| `+UVM_TIMEOUT=N,NO` | un techo para el cuelgue, en vez de esperar | Tests |
| `+UVM_MAX_QUIT_COUNT=N` | matar la corrida al N-ésimo error | Reporting |

- Los seis de abajo son **plusargs**: no se toca código y no se recompila. En un
  testbench con UVM eso son minutos de diferencia por intento

Note:
Este apéndice existe porque las herramientas están repartidas en cuatro
secciones y se necesitan todas juntas, en el peor momento: cuando algo no anda y
el reloj corre. Es la slide que conviene imprimir — y de hecho ya está impresa:
`docs/machete-uvm.pdf` es esta tabla, la jerarquía de clases, las nueve fases y
el handshake del driver en una sola carilla A4. La fuente es `res/machete.html`,
se abre con doble clic y se imprime con Ctrl+P.
El punto que hay que decir en voz alta es el de los plusargs. Un `$display`
agregado a mano cuesta una recompilación de UVM —minutos— y encima hay que
acordarse de sacarlo. Seis de estas siete ya están puestas en el binario que compilaste: se prenden en
la línea de comandos y no dejan rastro. La séptima, `VLT_TRACE`, necesita además
el bloque `$dumpfile`/`$dumpvars` en el top — hoy lo tienen `u2/convencional` y
`ejercicios/d1b`.
Y un detalle del `+UVM_TIMEOUT` que muerde, porque no da error: el valor es un
entero en unidades de tiempo, no una expresión con unidad. UVM lo lee con
`$sscanf(…, "%d,%s")` (`uvm_root.svh:916`), así que `+UVM_TIMEOUT=5ms` no se
queja: agarra el `5` y corta la simulación a los 5 ns. Se escribe
`+UVM_TIMEOUT=5000000,NO`, y el `NO` es para que un `set_timeout()` escrito en el
testbench no pise lo que pediste en la línea de comandos.
`+TOPOLOGY` no es de UVM: es del `base_test` del curso, que lee el plusarg y
llama a `uvm_root::get().print_topology()`. Vale aclararlo para que nadie lo
busque en el LRM. Lo mismo `VLT_TRACE=1`, que es del `run.sh`.
Y una que no está en la tabla porque no es una herramienta sino un hábito:
correr con `SEED=N`. Un bug que aparece una vez cada diez corridas no se debuggea
hasta que no lo podés repetir a voluntad.

---

## Apéndice · La caja de herramientas de debug

#### *Cuál usar, según el síntoma*

| El síntoma | El primer sospechoso | Con qué se mira |
| --- | --- | --- |
| Termina en **t=0** y dice PASS | nadie levantó la objection | `+UVM_OBJECTION_TRACE` |
| **No termina nunca** | un `item_done()` que no se llamó, o una objection que no baja | `+UVM_TIMEOUT=5000000,NO` y después el trace |
| El scoreboard **grita en todas** | el monitor muestrea mal — el DUT casi nunca es | `+UVM_VERBOSITY=UVM_HIGH` |
| El `config_db` **no encuentra** | el ámbito del `set()`, no el `get()` | `+UVM_CONFIG_DB_TRACE` |
| La cobertura da **0 %** | falta el `new()` o el `sample()` del covergroup | leer el `.dat` con `verilator_coverage` |
| El árbol **no es el que dibujaste** | un `create()` sin factory, o un override tardío | `+TOPOLOGY` |

- La regla de oro está en la segunda columna: **el sospechoso número uno nunca es
  el DUT.** Es el testbench que lo mira

Note:
Esta slide es el índice de la anterior, y el orden de las filas no es casual: son
las seis cosas que efectivamente pasan, ordenadas por cuántas veces las vas a
ver.
La primera y la segunda son la misma moneda: la objection. Si nadie la levanta,
la sim termina en cero; si nadie la baja, no termina nunca. Por eso el trace de
objections es la primera herramienta que hay que prender cuando el tiempo de
simulación no tiene sentido.
La tercera es la del ejercicio del día 5, y la lección que deja es de oficio, no
de sintaxis: un monitor que muestrea en el flanco equivocado inventa fallas que
no existen y hace perder días. Antes de abrir el RTL, mirá lo que el monitor dice
que vio.
La cuarta tiene una trampa dentro de la trampa: `get(null, "*", ...)` no falla
—devuelve lo primero que encuentre— así que el síntoma no es "no encuentra", es
"encontró el de otro". El trace lo muestra; el `get` no.
Y para cerrar: la última columna es todo lo que hay. Si el síntoma no está acá,
el paso siguiente son las ondas, que es la herramienta con la que se hace el
47 % del trabajo.
