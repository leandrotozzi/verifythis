## Constrained random

#### *La otra mitad de la pinza*

- La cobertura funcional del testbench convencional te dice **qué falta**. No te dice cómo
  llegar: eso es el estímulo
- Escribir un test dirigido por cada bin no escala — son 76 en el VTALU, y un
  chip de verdad tiene miles
- La receta de la industria es al revés: **random para el grueso, dirigido para
  los agujeros**. Y el random tiene que ser *legal*, o el DUT se queja de cosas
  que nunca van a pasar en silicio
- *Constrained random* es escribir las reglas del estímulo **una vez, en la
  transaction**, y dejar que el solver arme los casos

Note:
Es el par que faltaba: hasta acá el curso midió cobertura y armó las
transactions, pero el estímulo seguía saliendo de un `get_op()` con
un `case` escrito a mano.
La frase que ordena la sección: **una constraint no elige un valor, describe el
conjunto de valores legales.** El que elige es el solver, y elige distinto de lo
que uno espera más seguido de lo que a uno le gustaría. Toda la sección es
medir eso en vez de suponerlo.

---

## Constrained random

#### *`rand` y `randomize()`: lo que ya viste*

```systemverilog
class command_transaction extends uvm_sequence_item;
   rand byte unsigned A;      // rand  -> entra en el sorteo
   rand byte unsigned B;
   rand operation_t   op;     // un enum se randomiza sobre sus valores

   constraint data { ... }    // las reglas, en un bloque aparte
endclass
```

- `randomize()` viene de SystemVerilog, no de UVM: **toda** clase lo tiene
- Elige valores para los campos `rand` que **cumplan todas las constraints
  activas a la vez**
- Un `constraint` **no es código secuencial**: no se ejecuta de arriba abajo, no
  tiene orden. Es un conjunto de relaciones que el solver satisface junto
- Por eso dos constraints que se contradicen no dan error de compilación: dan un
  `randomize()` que devuelve 0

Note:
El bullet que hay que decir despacio es el tercero, porque es el modelo mental
equivocado que trae todo el mundo: un `constraint` **no se ejecuta**. No es un
`if` largo, no corre de arriba hacia abajo, y da lo mismo el orden en que estén
escritas. Es un sistema de ecuaciones, y `randomize()` se lo pasa a un solver
—en este curso, z3— para que le devuelva una solución al azar entre todas las
que lo satisfacen.
De ahí sale la consecuencia del último bullet, y es la trampa más cara de la
sección: dos constraints incompatibles compilan perfecto. El error aparece en
tiempo de simulación, `randomize()` devuelve 0, y **si nadie chequea el valor de
retorno la clase queda con los valores que tenía**. El testbench sigue andando y
manda basura.
La regla que se lleva de acá, y que el curso cumple en todo `code/`: un
`randomize()` va siempre adentro de un `if` que chequee el retorno. Nunca suelto.

---

## Constrained random

#### *Las otras tres palabras: `randc` y los dos ganchos*

```systemverilog
class command_transaction extends uvm_sequence_item;
   rand  byte unsigned A;       // puede repetir: 3 3 6 1 3 4 6 2 ...
   randc bit [2:0]     indice;  // recorre los 8 y recién ahí repite

   function void pre_randomize();   // corre ANTES del sorteo
      if (!primera) A = A_anterior; // …con los valores todavía viejos
   endfunction

   function void post_randomize();  // corre DESPUÉS, con los valores nuevos
      checksum = A ^ B;             // lo que no se sortea, se calcula acá
   endfunction
endclass
```

- `randc` es **cíclico**: agota todos los valores antes de repetir uno. Medido en
  Verilator 5.052: `4 2 1 7 5 6 3 0` y recién entonces vuelve a empezar
- Sirve para recorrer un espacio chico —un opcode, un índice de registro— sin
  esperar a que el azar lo cubra. Sólo en tipos integrales **chicos**: el LRM
  garantiza 8 bits y los simuladores suelen cortar en 16
- `pre_randomize()` / `post_randomize()` son los dos ganchos que el `randomize()`
  llama solo. El campo **derivado** —un checksum, una paridad— se calcula en el
  segundo, no se sortea
- Y una advertencia: lo que se calcule en `post_randomize()` **no** participa del
  solver. Si tiene que cumplir una constraint, es un campo `rand`

Note:
Son las tres palabras del lenguaje que faltan para que el alumno lea cualquier
transaction ajena sin frenar. Ninguna es difícil; lo que hace falta es saber
cuándo se usa cada una.
`randc` es la respuesta a *"quiero pasar por todos los opcodes"*, y el argumento
es de eficiencia: con `rand` sobre ocho valores hacen falta unos veintidós
sorteos para ver los ocho —el problema del coleccionista de figuritas—, y con
`randc` alcanzan ocho. Y la limitación de ancho tiene una razón concreta: el
solver tiene que llevarse la lista de lo que ya salió, así que un `randc` de 32
bits sería una tabla de cuatro mil millones de entradas.
Los dos ganchos se explican mejor por lo que resuelven. `post_randomize()` es
para el campo que **se deriva** de los sorteados: un CRC, una paridad, la
longitud de un payload que ya se sorteó. Ponerlo como `rand` con una constraint
que lo ate al resto es pedirle al solver que resuelva un problema que se hace con
un XOR.
`pre_randomize()` se usa menos y tiene una trampa que vale nombrar: corre **antes**
del sorteo, o sea que los campos todavía tienen los valores de la transacción
anterior. Eso lo hace útil para lo que depende del pasado —guardar la dirección
previa para pedir un acceso contiguo— y peligroso si uno cree que ya están los
nuevos.
Y el aviso de fondo, que es el mismo de toda la sección: un campo calculado en
`post_randomize()` está **fuera** del sistema de ecuaciones. El solver no lo ve,
las constraints no lo restringen, y `randomize()` nunca va a devolver 0 por él.


---

## Constrained random

#### *`dist`: `:=` no es lo mismo que `:/`*

```systemverilog
A dist {8'h00 := 1, [8'h01 : 8'hFE] := 1, 8'hFF := 1};   // el peso va a CADA valor
A dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};   // el peso se REPARTE
```

- `dist` pone **pesos**: no cambia qué valores son legales, cambia con qué
  frecuencia salen
- Con `:=` el peso se aplica **a cada valor del rango**: el rango del medio pesa
  254 y los bordes 1 cada uno. Sale `A=00` **1 vez cada 256**
- Con `:/` el peso es **del rango entero**: 1 – 2 – 1 da 25 % en `00`, 50 % en el
  medio, 25 % en `FF`. Que es exactamente el sesgo que el `get_data()` del testbench convencional hacía a mano
- Las dos líneas compilan, las dos corren, y **una de las dos no llena los bins
  de borde nunca**

Note:
La cuenta hay que hacerla en el pizarrón, porque leída no entra: con `:=` los
pesos son 1, 1 y 1, pero el del medio se le aplica a **cada uno** de sus 254
valores. Total 256 partes iguales, y `A=00` sale una de cada 256. Con `:/` las
partes son tres —1, 2 y 1— y `A=00` sale una de cada cuatro. Sesenta y cuatro
veces más seguido, por dos caracteres.
Y ahora la parte que la hace peligrosa: **las dos versiones andan**. Ninguna da
warning, ninguna falla, el testbench corre las mil transacciones igual. Lo único
que cambia es que con `:=` el bin `a_00` del covergroup tarda una eternidad en
llenarse, y el que mira el reporte concluye que le falta un test.
Es exactamente el tipo de bug que el curso llama trampa muda, y por eso la slide
siguiente no explica: **mide**. La regla práctica que hay que bajar: si escribís
un `dist`, corré un histograma antes de creerle.

---

## Constrained random

#### *No lo supongas: medilo*

{{code:code/u6/transactions/constraints/01_dist.sv#both-spellings}}

```sh
$ cd code/u6/transactions/constraints && bash run.sh
400 randomizations of each version
  :=   A=00   0.2%   A=FF   0.2%   the weight goes to each value
  :/   A=00  23.2%   A=FF  27.0%   the weight gets split
```

![Histograma medido: con := los bins de borde salen 0,2 %; con :/ salen 23 % y 27 %](res/diagrams/constrained-random_dist.svg)
<!-- .element: class="grande" -->

Note:
Este experimento salió de un bug de este mismo curso: `command_transaction`
tenía el `dist` escrito con `:=`, o sea que el sesgo a los casos borde que las transactions decía tener **no existía**. La distribución era prácticamente uniforme
y nadie se enteraba, porque el testbench pasaba igual.
Ése es el punto de fondo de la sección, y conviene decirlo así de crudo: una
constraint mal escrita **no falla, miente**. No hay warning, no hay error de
compilación, no hay un test en rojo. Lo único que lo delata es la cobertura que
no sube — y eso recién se nota semanas después.
Regla práctica para llevarse: cada vez que escribas un `dist`, corré unas
cuantas miles de randomizaciones e imprimí el histograma **una vez**. Cuesta
diez minutos y es la diferencia entre creer y saber.

---

## Constrained random

#### *`inside` y `randomize() with {}`*

{{code:code/u6/transactions/constraints/02_with.sv#comando}}

{{code:code/u6/transactions/constraints/02_with.sv#workaround}}

- `inside {a, b, c}` es el conjunto de valores legales: sin él, el random también
  pide `no_op` y `rst_op`, que no calculan nada. Acá además deja afuera a `sub_op`,
  para que el sorteo quede uniforme entre cuatro
- `randomize() with { ... }` agrega constraints **sólo para esa llamada**: el
  caso dirigido se pide en el punto de uso, sin tocar la clase ni escribir un
  tester nuevo. Es la herramienta del *coverage closure*

Note:
El número que sale de correr `02_with.sv` es el argumento entero de la sección: 400 intentos al
azar llenan `mul_max` un puñado de veces —6 con la semilla por defecto, entre 2 y
8 según cuál uses— **porque el `dist` sesga a los bordes**. La cuenta conviene
hacerla en voz alta: `op` sale uniforme entre cuatro y cada pata cae en `FF` una
de cada cuatro, o sea 1/4 × 1/4 × 1/4 = **1 de cada 64**, que en 400 intentos son
seis y pico. Con el `dist` mal escrito de la slide anterior, la probabilidad de
que las dos patas caigan en `FF` es 1/65536 por operación: no lo tocás nunca.
La secuencia mental es siempre la misma: corro random, miro qué bin quedó vacío,
escribo un `with {}` de tres líneas, vuelvo a correr. Nunca "escribo 76 tests".
La limitación de Verilator que la sección enuncia está puesta a propósito, y
conviene enunciarla bien porque no es "anda o no anda". Verilator resuelve el
`dist` **eligiendo un valor concreto primero** y recién después chequea el resto:
si el sorteado no cumple el `with`, devuelve 0 en vez de buscar otro. La tasa de
éxito es entonces la probabilidad del bin. Medido: `with {A == 8'hFF}` resuelve
el 25 % de las veces —el peso de ese bin—, `with {A inside {[1:10]}}` el 2 %, y
un campo sin `dist` el 100 %.
Por qué importa más de lo que parece: el síntoma es **un caso dirigido
intermitente**, que anda cuando lo probás y falla en la regresión de la noche.
Los números están en `code/verilator/repro-dist-with.sv`, y el rodeo —apagar la
constraint— es el mismo `constraint_mode()` que ves más adelante.

---

## Constrained random

#### *`soft`: el default que un `with {}` puede pisar*

```systemverilog
class command_transaction extends uvm_sequence_item;
   rand byte unsigned A;
   constraint por_defecto { soft A == 8'h00; }   // "cero, salvo que me pidan otra cosa"
endclass

t.randomize();                          // A = 00
t.randomize() with { A inside {[1:10]}; };   // A entre 1 y 10: el soft se cae solo
```

- Una constraint `soft` es un **deseo**, no una regla: si choca con otra, el
  solver la **descarta** en vez de devolver 0
- Es la forma moderna de escribir un valor por defecto en la transaction sin
  obligar a nadie a llamar `constraint_mode(0)` para pisarlo
- Gana la constraint **dura**, y entre dos `soft` que chocan gana la declarada
  **después** — el orden sí importa acá, y sólo acá
- Medido en Verilator 5.052: con el `with {}` sale entre 1 y 10; sin él, `00`

Note:
Ésta es la pieza que hace que la slide anterior escale a un testbench de verdad.
El `randomize() with {}` sirve para pedir un caso dirigido, pero si la clase ya
tiene una constraint dura que dice otra cosa, el `with` no la pisa: la contradice,
y `randomize()` devuelve 0. La salida vieja era `constraint_mode(0)` — que obliga
al que escribe el test a saber cómo se llama la constraint de una clase que no
escribió.
La regla de diseño que hay que dejar, porque es la que se usa en todo VIP
moderno: **lo que es una regla del protocolo va duro; lo que es una preferencia
del estímulo va `soft`**. Una dirección alineada a 4 es dura, porque el DUT no
acepta otra cosa. Que el `burst_len` sea 1 por defecto es `soft`, porque el test
que quiere ráfagas largas tiene derecho a pedirlas sin permiso.
El desempate entre dos `soft` conviene decirlo y no usarlo: gana la última
declarada, y si eso te importa para algo, la constraint estaba mal escrita.
Entraron en IEEE 1800-2012, así que cualquier simulador de la última década las
tiene — y Verilator también, medido acá arriba.


---

## Constrained random

#### *El orden de resolución sesga sin avisar*

```systemverilog
rand bit           es_reset;
rand byte unsigned A;
constraint c {es_reset -> A == 8'h00;}   // "si pido reset, los operandos en cero"
```

- Parece inofensiva. **No lo es**: el solver elige entre las *soluciones*, no
  entre los valores de cada campo
- Con `es_reset = 1` hay **una**; con `es_reset = 0`, **256**. Pediste reset la
  mitad de las veces y lo vas a ver **1 de cada 257**
- El bin *"cualquier operación después de un reset"* del plan no se llena, y el
  reporte no te dice por qué
- La respuesta del lenguaje es `solve es_reset before A`: elegí el campo de
  control primero

![Una celda contra un bloque de 16 por 16: las 257 soluciones, y una sola tiene el reset](res/diagrams/constrained-random_solve.svg)
<!-- .element: class="grande" -->

Note:
La frase que desarma la intuición es la del primer bullet, y conviene repetirla
tal cual: **el solver elige uniformemente entre las soluciones, no entre los
valores de cada campo**. Nadie escribió que `es_reset` fuera a salir 1 la mitad
de las veces; salió de suponer que cada campo se sortea por separado, y no es así.
Vale contar las 257 soluciones en voz alta, porque el número convence más que el
argumento: `es_reset=1` obliga a `A=00`, o sea una sola combinación; `es_reset=0`
deja `A` libre, o sea 256. El sorteo es sobre las 257, y el reset se lleva una.
La conexión con el plan de verificación es lo que hace que esta slide valga: la
fila *"cualquier operación después de un reset"* no se llena, la cobertura queda
clavada, y el reporte no dice **por qué**. Un alumno sin esta slide agrega tests
al azar durante una tarde.
Y la advertencia sobre la cura, para que no se use de más: `solve ... before` no
cambia qué soluciones son legales, sólo el orden en que el solver elige. Es una
perilla de distribución, no de corrección — y cuesta tiempo de solver, así que
va donde hace falta y no por costumbre.

---

## Constrained random

#### *Medido, con el rodeo que Verilator sí respeta*

{{code:code/u6/transactions/constraints/03_solve.sv#both-classes}}

```sh
2000 randomizations of each version
  as written             es_reset=1 in   0.3%   (1 in 257)
  with dist on es_reset  es_reset=1 in  51.7%
```

- Verilator 5.052 **acepta `solve ... before` y no lo respeta**: deja el campo
  clavado en 0, que es peor que ignorarlo. Repro en
  `code/verilator/repro-solve-before.sv`
- El rodeo portable: pedir el reparto del campo de control con un `dist`. Dice lo
  mismo y no depende de que el solver ordene bien

Note:
Es el segundo agujero de Verilator del curso, junto con los bins de transición, y
se trata igual: se dice de frente, con repro mínimo y con un rodeo que funciona.
El concepto es del lenguaje, no del simulador.
Lo que sí hay que remarcar es la asimetría: la constraint **sesgada** da 0,3 %,
que es exactamente lo que predice la teoría — o sea que el solver de Verilator
está bien; lo que falta es la directiva de orden.
Y la moraleja general, que vale para cualquier herramienta: si el estímulo tiene
un campo de control (un modo, un tipo de operación, un "inyectar error"), no
confíes en que salga parejo. Medilo.

---

## Constrained random

#### *Cuando no hay solución*

{{code:code/u6/transactions/constraints/04_falla.sv#the-unsolvable}}

```sh
1. randomize() returned 0: the constraints do not close
2. with 'grande' turned off: A=06, and it honours 'chico'
3. with A out of the draw: A=06, the same as before
```

- `constraint_mode(0)` apaga **una constraint** en tiempo de ejecución;
  `rand_mode(0)` saca **un campo** del sorteo y le deja el valor que tenía — y si ese
  valor no cumple las constraints que lo nombran, `randomize()` devuelve 0
- Sirven para el test que necesita romper una regla a propósito — inyectar un
  opcode ilegal, por ejemplo — sin tocar la clase que todos los demás usan

Note:
Acá se cierra el círculo con la slide de `assert(randomize())`: el caso 1 es
precisamente lo que pasa cuando dos constraints se contradicen, y sin el `else`
el testbench sigue mandando la transaction anterior.
Y la pareja con la slide de `soft`, que conviene cerrar acá: una constraint
`soft` es la que el solver descarta **sola** cuando estorba. `constraint_mode(0)`
es lo mismo pedido **a mano y desde afuera**, y es lo que queda cuando la
constraint que estorba es dura y la clase no es tuya.

---

## Constrained random

#### *Cómo se debuggea una constraint que no cierra*

```systemverilog
// 1. Que el testbench lo diga. Sin esto no hay bug: hay silencio
if (!t.randomize()) `uvm_fatal("RAND", "la constraint no cerró")

// 2. Bisección: apagar de a una hasta que cierre. La última que apagaste es
foreach (nombres[i]) begin
   t.chico.constraint_mode(0);
   if (t.randomize()) `uvm_info("RAND", "cierra sin 'chico'", UVM_LOW)
   t.chico.constraint_mode(1);
end

// 3. Sacar el campo del sorteo y ver qué valor lo estaba trabando
t.A.rand_mode(0);
```

- El síntoma nunca es *"no cierra"*: es un `randomize()` que devuelve 0 y una
  transaction con **los valores de la anterior**. Primero hay que hacerlo ruidoso
- El método es **bisección**, igual que con `git bisect`: `constraint_mode(0)` de
  a una hasta que cierre. La que faltaba apagar es la culpable
- El otro corte es por campo: `rand_mode(0)` deja el valor que tenía y muestra si
  el conflicto era ése
- La causa es casi siempre la misma: una constraint de la clase **base** que el
  `with {}` del test contradice. Ahí la respuesta de diseño es `soft`

Note:
Es la media hora que todo el mundo pierde una vez, y hay una forma de perderla
una sola vez. Conviene decir el orden en voz alta porque es el que sirve.
Paso cero, y es el que la gente se saltea: **hacerlo ruidoso**. Un `randomize()`
sin `if` no produce un bug visible, produce estímulo viejo. El curso lo pide en
todo `code/` y el apéndice de trampas lo tiene catalogado; acá es donde se cobra.
Paso uno: bisección. Un simulador comercial imprime el conjunto de constraints en
conflicto —Questa dice `Constraint solver failed` y lista los bloques—, pero
Verilator devuelve 0 y se calla, así que la bisección a mano es la herramienta
que hay. Es aburrida y toma dos minutos, que es exactamente por qué conviene
tener el reflejo en vez de mirar el código fijo.
Paso dos, cuando la bisección no alcanza: el conflicto no está entre dos
constraints sino entre una constraint y un campo que ya tiene valor. Ahí
`rand_mode(0)` sobre el sospechoso lo congela y el mensaje cambia.
Y la moraleja de diseño, que es la que evita el problema en vez de resolverlo: si
una clase base define constraints duras que un test razonable va a querer pisar,
esas constraints tenían que ser `soft`. Una constraint dura es una regla del
DUT, no una preferencia del que escribió la clase primero.


---

## Constrained random

#### *Así se cierra la cobertura*

![El ciclo de closure: randomizar, mirar el reporte, llenar el bin que falta, otra semilla](res/diagrams/constrained-random_closure.svg)
<!-- .element: class="grande" -->

- Ningún paso pide una clase nueva: `dist` e `inside` en la transaction, tres
  líneas de `with {}`, y `rand_mode(0)` o `constraint_mode(0)` para romper una regla
- Eso es *coverage closure*, y es a lo que un verificador le dedica el día
- Lo que **no** es: escribir un test por bin. Ni mirar el porcentaje total
- El estímulo todavía sale de un `tester` que escribiste vos. En UVM moderno eso
  es una `uvm_sequence` — y es el día 6

Note:
Cerrar volviendo al testbench convencional: el 86,8 % de `u2/convencional` sale de 1000 operaciones al
azar con el sesgo a los bordes puesto a mano. Ahora el alumno sabe escribir ese
mismo sesgo en una constraint, medirlo, y agregarle el `with {}` de los casos que
faltan.
Y dejar tirada la pregunta del día 6: si el estímulo son constraints y no código,
¿para qué sigue existiendo una clase `tester` con un `run_phase`? No sigue
existiendo. Se llama sequence.

---

## Constrained random

#### *«Otra semilla, y de nuevo»: qué mueve y qué no*

```sh
$ SEED=7 bash run.sh    # u6/transactions/constraints, 400 randomizaciones
    seed: 7
  :/   A=00  25.0%   A=FF  22.0%   # con SEED=8: 20.8% y 27.0%
$ SEED=7 bash run.sh    # u2/convencional, y de nuevo con SEED=8
  covergroup : 86.8% (66/76)       # las dos veces. Y el merge, igual
```

- `SEED=N` pasa `+verilator+seed+N`, y `run_sim` **imprime la que usó**: un fallo
  que sale una vez cada diez corridas no se debuggea, se repite
- **Sí** mueve los porcentajes de un `dist` medido con pocas muestras: 400
  randomizaciones dan 25 % o 21 % según el sorteo. Es una muestra, no la
  distribución
- **No** mueve los 10 bins que faltan. Con 1000 operaciones el random ya llegó
  hasta donde puede, y otra semilla es tirar la moneda esperando otro resultado
- Por eso *"otra semilla"* es el **último** paso del ciclo anterior y no el
  primero: primero el `with {}`

Note:
Esta slide existe para desactivar un malentendido que el ciclo anterior invita:
*"si no cierro, corro otra semilla"*. Se midió, y no: `code/u2/convencional` da 66 de 76 con
la semilla por defecto, con la 7 y con la 8, y el merge de las tres da 66. Los 10
que faltan no faltan por suerte — faltan porque Verilator genera los bins
automáticos del enum sobre el **tipo base**: `3'b110` no existe en `operation_t`,
así que `auto_5` queda en 0 para siempre, con sus nueve cruces. Ninguna semilla
los va a tocar.
La semilla sirve para otras dos cosas, y las dos son de oficio. Primera:
**reproducir**. Un bug intermitente no se debuggea, se repite; y para repetirlo
hay que saber con qué semilla salió, que es exactamente por qué `run_sim` la
imprime en cada corrida.
Segunda: **acumular**, cuando el estímulo todavía no saturó. Una regresión de
verdad es el mismo test por cien semillas de noche, y la cobertura se mergea —
`verilator_coverage --write` hace en Verilator lo que el merge de ucdb en Questa.
Acá no se nota porque el ejemplo es chico; en un chip es la mitad del trabajo.
Y el `+verilator+rand+reset+2` que aparece en la documentación es otra cosa y
conviene no mezclarlas: no toca `randomize()`, decide con qué arrancan las
señales **sin inicializar** del DUT. Con `2` arrancan al azar en vez de en cero,
que es la forma de descubrir el registro que nadie reseteó y que en silicio no
arranca en cero.

---

## Constrained random

#### *Resumen de la unidad*

- La cobertura te dice **qué falta**; constrained random es **cómo llegar**. Son
  las dos mitades de la misma pinza
- Escribir un test dirigido por bin no escala: son **76 bins** en el VTALU. La
  receta es al revés — **random para el grueso, dirigido para lo que queda**
- Un `constraint` **no es código secuencial**: no se ejecuta de arriba abajo. Es
  un sistema de ecuaciones que el solver resuelve todo junto
- Por eso dos constraints que se contradicen **no dan error de compilación**:
  dan un `randomize()` que devuelve 0
- `dist` pone **pesos**, no legalidad. Y `:=` no es `:/`: el primero pesa **cada
  valor** del rango, el segundo **el rango entero**
- `randomize()` devuelve 0 y sigue. Por eso va **siempre** adentro de un `if`
  con `` `uvm_fatal `` — es la trampa muda más cara del curso

Note:
El último bullet es el que hay que dejar grabado y el que conecta con el
apéndice de las trampas. Un `randomize()` sin chequear no rompe: deja los campos
con el valor anterior y el testbench sigue mandando estímulo que no es el que
creés. La cobertura te lo va a decir tres días después.
Y el aviso de herramienta que hace falta desde hoy: sin `z3` instalado,
Verilator resuelve `randomize()` devolviendo 0 **en silencio**. Está en
`docs/verilator.md`, y es la razón por la que el día 5 pide el solver.
