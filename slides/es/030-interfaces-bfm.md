## Interfaces y BFM

#### *Primero: las señales dejan de estar sueltas*

{{code:code/u2/interfaces-bfm/vtalu_bfm.sv#signals-and-clock}}

- Una `interface` es un **bundle** de señales con nombre propio. Nueve cables que
  antes estaban declarados en el `top` ahora viven juntos
- El reloj se genera adentro: la interface no es un cable, es un modelo del bus
- Conectar el DUT pasa a ser `.A(bfm.A)`, `.clk(bfm.clk)`… y una señal nueva se
  declara **una vez**: los módulos que la usan la ven aparecer sin tocar sus puertos
- Lo que acá no hace falta y en un RTL ajeno vas a ver: el **`modport`**, que es
  la misma interface con las direcciones puestas para un lado del cable

Note:
Primer paso hacia UVM y no tiene una línea de UVM.
La ganancia inmediata es de mantenimiento y conviene medirla: con las señales
sueltas, partir el testbench en módulos obliga a pasar cada una por cada port
list, y una señal nueva se cablea en todos. Acá se declara en la interface, y el
único puerto que cambia es el del DUT.
Un detalle de tipos que se cobra: `op` es un `wire [2:0]` y `op_set` es el
`operation_t`. El `assign op = op_set` es el puente entre el enum del testbench y
los cables del DUT. Es el único lugar del curso donde se ve la costura entre los
dos mundos.
Y el `modport`, que no aparece en el resto del curso y sí en cualquier RTL ajeno:
es una vista de la interface con las direcciones declaradas —`modport dut (input
A, input B, output result)`—, y el módulo la pide en su port list
(`vtalu_bfm.dut bus`). Sirve para dos cosas, y las dos valen: que el compilador
frene al DUT si escribe una señal que para él era de entrada, y que el que lee la
interface sepa quién maneja qué sin abrir el RTL. Acá no está porque la BFM es
del testbench y maneja todo; en el trabajo la interface casi siempre viene con
dos o tres modports y lo que hay que saber es cuál pedir.

---

## Interfaces y BFM

#### *Después: el protocolo se esconde en una task*

{{code:code/u2/interfaces-bfm/vtalu_bfm.sv#send_op}}

- `send_op(A, B, op, result)` traduce *"hacé una suma"* al meneo de señales que
  el DUT espera. Eso es un **Bus Functional Model**
- Adentro está toda la letra chica de la spec: el pulso de `reset_n`, el
  `no_op` que no espera `done`, y el `do ... while (done == 0)` de las demás
- De acá en adelante **nadie mueve `bfm.start` a mano**. El que quiere una
  operación la pide

Note:
La frase que ordena la sección: el protocolo se escribe **una vez**. Si mañana
el DUT pide dos ciclos de `start`, se toca esta task y nada más.
El `#1` después del `@(posedge clk)` es la misma precaución del scoreboard del testbench convencional: mover las señales un delta después del flanco, no sobre el flanco.
Y el enganche del día 4: el `driver` de los put y get ports es exactamente esta task,
pero adentro de una clase y alimentada por un port. La operación —esconder el
cable— es la misma; lo que cambia es de dónde vienen los datos.

---

## Interfaces y BFM

#### *El top, con la BFM en el medio*

- El testbench sigue partido en las mismas tres piezas —tester, scoreboard y
  cobertura—, y ninguna cambió de nombre
- Lo que cambió es **cómo se conectan al DUT**: ya no hay señales sueltas
  viajando, hay una sola interface que las tres comparten

{{code:code/u2/interfaces-bfm/top.sv}}

Note:
Conviene leer este `top.sv` al lado del de la sección anterior, porque el diff es
la sección entera: donde había una lista de `logic` declarados en el top y
cableados a mano al DUT, ahora hay **una línea** que instancia la BFM y una que
la enchufa.
Lo que hay que hacer notar, porque es lo que se repite el resto del curso: el DUT
se conecta a `bfm.A`, `bfm.B`, `bfm.op`… La interface no es un objeto abstracto,
son los mismos cables de siempre agrupados bajo un nombre. Nada se volvió más
lento ni más raro — se volvió más difícil de conectar mal.
Y el detalle que paga solo el día que el DUT crezca: agregar una señal al
protocolo es tocar la interface, y todos los que la usan la ven aparecer. En la
versión anterior había que acordarse de cablearla en cada instancia.

---

## Interfaces y BFM

#### *Scoreboard: el mismo chequeo, ahora hablando con la BFM*

{{code:code/u2/interfaces-bfm/scoreboard.sv}}

- Es el `scoreboard` del testbench convencional sin una línea de lógica cambiada: predice y
  compara igual
- Lo único que cambió es de dónde saca las señales: antes eran variables del
  mismo módulo, ahora son `bfm.A`, `bfm.B`, `bfm.op_set`
- Y por eso ahora es un **módulo aparte**: puede vivir en su propio archivo
  porque no comparte nada con el tester salvo la interface

Note:
Lo que hay que hacer notar es lo que **no** cambió. La lógica de verificación es
idéntica; lo que se modularizó es el cableado. Ese es toda la sección.
El `bfm.` adelante de cada señal es la primera vez que el alumno ve una jerarquía
de interface, y vale escribirla en el pizarrón: `top.bfm.A`. En los tests esa
misma referencia va a llegar por el config_db a una clase, y ahí el prefijo va a
ser un handle en vez de un nombre de instancia.
La deuda que queda abierta: el scoreboard sigue mirando las señales
directamente. Recién en los analysis ports va a recibir *transactions* de un monitor y
dejar de saber que existe un `clk`.

---

## Interfaces y BFM

#### *Tester: pide operaciones, no mueve cables*

{{code:code/u2/interfaces-bfm/tester.sv#stimulus-loop}}

- El tester ya no toca `start` ni espera `done`: llama a `bfm.send_op(...)` y se
  olvida del protocolo
- El handshake quedó **escrito una sola vez**, adentro de la BFM. Si mañana el
  DUT pide dos ciclos de `start`, se toca un archivo
- Ésa es la definición de *Bus Functional Model*: la tarea traduce *"hacé una
  suma"* al meneo de señales que el DUT espera

Note:
La comparación con el testbench convencional es la slide: allá el `tester` levantaba `start`,
esperaba `done` y bajaba `start`, mezclado con la generación de estímulo. Acá
sólo genera estímulo.
Vale contar cuántos lugares del testbench convencional sabían del protocolo —el
tester y el scoreboard— y cuántos mueven `start` ahora: uno, el `send_op`. El
scoreboard sigue esperando `done` por su cuenta; esa deuda la paga el monitor de
los analysis ports.
Y el enganche del día 4: en los put y get ports este mismo tester va a ser una clase con
un `put_port`, y la BFM va a quedar del otro lado de un driver. La operación es
la misma que hicimos acá — esconder el cable— repetida un nivel más arriba.

---

## Interfaces y BFM

#### *La regla del protocolo, escrita en el idioma del simulador*

```sv
// INMEDIATA: una sentencia. Chequea el presente, donde el hilo pasa.
assert (op_set != no_op || done == 0)
   else $error("no_op no deberia levantar done");

// CONCURRENTE: una declaracion con reloj. Se enchufa una vez y
// chequea CADA flanco de la simulacion, sola, para siempre.
a_operandos_estables :
assert property (@(negedge clk) start |=> $stable(A) && $stable(B));
```

- La regla —*mientras `start` está arriba, los operandos no se tocan*— ya está
  escrita **dos veces**: en prosa en la spec, y encapsulada adentro de
  `send_op()` acá
- Una **assertion** es esa misma frase por tercera vez, pero **ejecutable**: no
  la respeta, la **chequea**
- Y la chequea donde ocurre —en la interface, en el flanco exacto— y no al final,
  comparando resultados

Note:
Esto es un anzuelo, no la sección: no hay que explicar la sintaxis acá, y menos
el `|=>` o el flanco. Lo único que tiene que quedar es que la regla del protocolo
se puede escribir de una forma que el simulador entienda.
Vale hacer notar la asimetría que se abre: el BFM **cumple** el protocolo, y eso
alcanza mientras todo el estímulo pase por el BFM. En cuanto aparezca un módulo
heredado, un VIP de otro equipo o un driver escrito con apuro, cumplirlo deja de
ser lo mismo que chequearlo.
Si alguien pregunta por qué una dice `negedge` y la otra no, la respuesta corta
es *"porque la BFM escribe en el negedge, y eso solo se ve entero en las assertions"*. Es la pregunta que se quiere sembrar.

---

## Interfaces y BFM

#### *Dónde se chequea cada cosa*

- El **scoreboard** del testbench convencional chequea el **resultado**: `A op B` contra lo
  que devolvió el DUT. Es la mitad que este curso desarrolla hasta el final
- Una **assertion** chequea el **protocolo**: quién se mueve, cuándo, y por
  cuántos ciclos. Es la otra mitad
- Un DUT que devuelve bien el `result` pero baja `done` un ciclo antes **pasa
  todos los tests** de los próximos seis días. Nadie lo está mirando
- Se ve entero en **la sección de assertions**, con el mismo VTALU y el mismo `run.sh`

Note:
La frase que conviene dejar escrita en el pizarrón todo el curso: *el scoreboard
chequea qué calcula el DUT; las assertions, cómo se habla con él.* Las tres
secciones que faltan del día 1 y los seis días que siguen son la primera mitad;
la segunda llega al final, y llega sobre este mismo ejemplo.
No hay que prometer más que eso. Las assertions vuelven con la property de esta
slide, la escribe de verdad, y muestra por qué el flanco que eligió no es un
detalle.

---

## Interfaces y BFM

#### *El agujero que deja la BFM: el temporizado*

{{code:code/u2/clocking/sin_clocking.sv#three-samples}}

- La BFM encapsuló **el protocolo**. Lo que **no** encapsuló es *cuándo* se
  maneja y *cuándo* se muestrea: eso sigue decidido task por task
- Tres formas de leer el mismo dato: `0`, `11` y `11`. Dos valores, pero **tres
  mecanismos**, y el del medio depende de un `#1` que no se ve en ningún lado
- El `@(negedge clk)` de nuestra BFM es la tercera. Anda — y le pide al que la
  lee que sepa por qué

Note:
Correr esto en vivo, que tarda dos segundos: `make u2/clocking`. Las tres líneas
que imprime son la slide entera.
La primera es la que sorprende y conviene explicarla despacio: muestrear **en**
el `posedge` da el valor **viejo**, porque el `always_ff` del DUT actualiza con
una asignación no bloqueante y ésa se aplica después de que este `initial` ya
corrió. No es un bug de Verilator ni una rareza: es el orden de regiones del
LRM, y es igual en Questa.
La segunda es la peor de las tres, y es la que hay que marcar como trampa muda:
funciona, y funciona **por accidente**. El `#1` no dice qué problema resuelve,
no está documentado, y el día que alguien lo borra porque "no hacía nada" el
testbench sigue compilando y empieza a mentir. Es el mismo `#1` del scoreboard
del testbench convencional, y la diferencia es una sola: allá la slide dice qué
carrera evita. Un `#1` explicado es un parche que se sabe parche; un `#1` suelto
es la trampa.
Y la tercera es la nuestra. Vale ser honesto con el grupo: el curso maneja en
`negedge` y muestrea en `posedge` porque es el truco que se entiende sin haber
visto clocking blocks, no porque sea lo que se escribe en un proyecto.

---

## Interfaces y BFM

#### *Por qué el flanco solo no alcanza: las regiones*

![Las regiones de un flanco: Preponed, Active y NBA, y los tres muestreos](res/diagrams/interfaces-bfm_regiones.svg)
<!-- .element: class="grande" -->

- Un flanco no es un instante indivisible: adentro hay **regiones**, en orden fijo
- El `<=` del `always_ff` **aterriza en NBA**: el que lee en *Active* lee el viejo
- El `#1` cruza el NBA, el flanco opuesto lo cruza sobrado, y SVA no necesita
  ninguno de los dos: muestrea en *preponed*, antes de todo

Note:
Esta figura es la que hay que dejar en pantalla mientras se leen las tres
lecturas de la slide anterior. Sin ella la explicación es *"el valor viejo"*,
que suena a rareza del simulador; con ella es una consecuencia del orden, y el
orden está en el LRM.
El scheduler tiene más regiones que las cuatro del dibujo —`docs/clocking-blocks.md`
las lista todas—, pero con éstas se explican los tres casos, y agregar las otras
no cambia ninguna respuesta.
La pregunta que conviene hacer al grupo antes de mostrar la respuesta: si el DUT
escribe en NBA y tu `initial` despierta en Active, ¿quién corre primero? Ahí se
ve solo por qué muestrear **en** el flanco da el valor de antes.
Y el enganche con el día 7: la barra ámbar de la izquierda es la región donde
muestrea SVA. Es la misma figura que explica por qué una assertion no chequea lo
que pasó sino lo que vio, y por qué el `@()` que se le pone cambia el resultado.

---

## Interfaces y BFM

#### *El clocking block: el flanco y el delta, declarados una vez*

{{code:code/u2/clocking/con_clocking.sv#reg_bfm}}

- `input #1step` — muestreá el valor **estable justo antes** del flanco, que es
  el que ve el hardware. Nunca el que la no bloqueante acaba de escribir
- `output #0` — manejá **en** el flanco, con las no bloqueantes, así el DUT no
  lo ve hasta el flanco siguiente
- Manejar pasa a ser `cb.d_in <= valor`; muestrear, leer `cb.d_out`; esperar,
  `@(cb)`. **Ningún `#1` en ninguna task**
- Y el dato leído es el mismo en cualquier momento del ciclo: la carrera se
  cerró por declaración, no por costumbre

Note:
Ésta es la slide que hay que poder repetir en una entrevista, porque
`clocking block` es de las primeras cosas que se preguntan y la respuesta buena
no es "sincroniza": es **declara el instante de muestreo y de manejo una sola
vez, en la interface, para que ninguna task lo vuelva a elegir**.
El detalle que confunde y conviene adelantar: en el ejemplo hacen falta **tres**
`@(cb)` para ver el 11, y no dos. Uno para que el `output #0` ponga el dato,
otro para que el DUT lo tome, y el tercero porque el `input #1step` muestrea lo
estable **antes** del flanco. La cuenta está a la vista en el código y no
depende del simulador — que es exactamente la diferencia con el `#1`.
Si alguien pregunta por qué el curso no lo usa desde el día 1: porque para
entender qué problema resuelve hay que haber tenido el problema. Recién ahora,
con la BFM escrita y las tres líneas corriendo, la pregunta tiene sentido.
Verilator lo soporta desde la 5.x y el ejemplo termina en `$fatal` si el
muestreo deja de dar 11: es la red que avisa si una versión cambia la semántica.

---

## Interfaces y BFM

#### *¿Son obligatorios? No — y conviene saber por qué*

| La pregunta | La respuesta |
| --- | --- |
| ¿Se puede escribir un TB correcto **sin** clocking blocks? | **Sí.** Con NBA en el driver y disciplina de scheduler, no hay race |
| ¿Qué conviene que use **un equipo**? | **Usalos** en interfaces síncronas — es lo que dice el style guide de lowRISC/OpenTitan |

- No son de UVM: son de **SystemVerilog**. UVM no los pide ni los conoce
- **Dave Rich** —la referencia de Verification Academy— sostiene desde 2014 que
  son *opcionales*: lo que evita la race es entender el scheduler, no el
  clocking block
- Las dos posturas contestan preguntas distintas: una es **corrección del
  lenguaje**, la otra es **política de equipo**. Las dos son correctas

Note:
Esta slide es la que evita que el curso mienta por simplificar, y conviene
decirla con todas las letras: *"usá siempre clocking blocks"* es una regla de
estilo, no un teorema. El que la repite como si fuera lo segundo se lleva una
discusión incómoda con el primer senior que se cruce.
La frase de Dave Rich que ordena el tema —y vale citarla textual— es de 2014:
*"If you are already familiar with Verilog testbenches, then you probably don't
need them."* La sostuvo en 2022 y en 2024. No dice que estén mal: dice que no
son una **condición necesaria**.
Y del otro lado está lowRISC, que en el DV Coding Style Guide de OpenTitan los
hace obligatorios para señales síncronas. No se contradicen: Dave contesta
*"¿puedo?"* y lowRISC contesta *"¿qué hacemos todos acá?"*. Es exactamente la
diferencia entre `malloc`/`free` bien usados y un style guide que impone
smart pointers — que un experto pueda manejar la memoria a mano no vuelve
inútil al RAII.
Dónde sí mueven la aguja de verdad, y es lo que hay que retener: agents y VIP
**reutilizables** —el que los escribe está lejos del que los usa—, gate-level
con SDF, y protocolos donde la spec define setup/hold. Ahí dejan de ser estilo.
El material largo, con las fuentes, está en `docs/clocking-blocks.md`.

---

## Interfaces y BFM

#### *El precio: dos nombres para el mismo cable*

{{code:code/u2/clocking/mezcla.sv#two-reads}}

- Con la señal adentro de un clocking block hay **dos** formas de leerla:
  `bfm.d_out` es el cable en vivo, `bfm.cb.d_out` es lo que se muestreó
  `#1step` antes del flanco
- En una señal que cambia cada ciclo **difieren en un ciclo**: el ejemplo
  imprime `3` y `4`, en el mismo instante y sobre el mismo cable
- Nadie avisa. Compila, corre, y el scoreboard falla **sólo cuando el dato
  cambia**
- La regla: si una señal entró al clocking block, **todo el protocolo la lee
  por ahí** — y se espera `@(bfm.cb)`, no `@(posedge bfm.clk)`

Note:
Ésta es la contracara de la slide anterior y la razón por la que el curso no
mete clocking blocks el día 1: mal usados son **peores** que no usarlos, porque
el modo de falla es intermitente y el waveform se ve bien.
El error de verdad, el que aparece en los foros, tiene dos formas y conviene
nombrar las dos. Una es mezclar el evento: `@(posedge vif.clk)` y después leer
`vif.cb.foo`. La otra es mezclar el acceso: el monitor lee `vif.cb.data` y el
scoreboard —o una assertion, o un `$display` de debug— lee `vif.data`. Las dos
terminan igual: dos vistas temporales del mismo cable, y un mismatch que
aparece una vez cada veinte corridas.
Vale correr el ejemplo y dejar el número a la vista: `3` y `4`. Nadie discute
un `3` y un `4` sobre el mismo cable.
Y la moraleja que engancha con el apéndice de las trampas mudas, donde ésta
está anotada: en verificación el error caro no es el que rompe, es el que
miente. Un clocking block a medias miente.

---

## Interfaces y BFM

#### *Resumen de la unidad*

- Una `interface` es un **bundle de señales con nombre**: agregar un cable deja
  de ser tocar seis port lists
- Un **BFM** es la interface **más el protocolo**: `send_op(A, B, op, result)`
  traduce *"hacé una suma"* al meneo de señales
- Toda la letra chica de la spec —el pulso de reset, esperar `done`, el
  `no_op` que no responde— queda escrita **una sola vez**
- Desde acá **nadie mueve `bfm.start` a mano**. El que quiere una operación, la
  pide
- El tester, el scoreboard y la cobertura pasan a ser **módulos aparte**, cada
  uno en su archivo, conectados por la BFM
- Y esto no se abandona: el driver del agent sigue llamando a
  **esta misma task**
- La regla que el BFM **cumple** se puede además **chequear**, con una assertion
  que vive en esta misma interface. Ésa es la sección de assertions
- Y el **`clocking block`** cierra el último agujero: el flanco y el delta
  dejan de decidirse task por task y se declaran **una vez**

Note:
Ésta es la sección más importante del día 1 y la que menos parece. Todo lo que
viene después —clases, factory, agents, sequences— reordena piezas **arriba** de
esta línea. La línea misma no se vuelve a tocar.
La forma corta de decirlo: de acá en adelante el testbench deja de hablar en
cables y empieza a hablar en operaciones. Ése es el primer paso hacia UVM, y ya
está dado, sin haber escrito una sola clase.
Si el grupo viene de RTL, la analogía cierra sola: la BFM es al testbench lo que
un driver de dispositivo es al sistema operativo.
