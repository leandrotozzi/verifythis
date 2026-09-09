## Assertions (SVA)

#### *El agujero que dejó el scoreboard*

- El scoreboard de este curso chequea **el resultado**: `A op B` contra lo que
  devolvió el DUT. Mil operaciones, mil comparaciones, cero errores
- Nadie chequea **el protocolo**. Un DUT que devuelve bien el `result` pero baja
  `done` un ciclo antes, o lo levanta con `no_op`, **pasa todos los tests del
  curso**
- La regla del protocolo está escrita en tres lugares: en prosa en la spec,
  adentro del BFM, y en la cabeza del que lo escribió. En **ninguno** de los
  tres se chequea
- Una **assertion** es esa misma frase, en forma ejecutable, corriendo sola toda
  la simulación

Note:
Vale abrir la sección con la pregunta y dejarla flotando medio minuto: *¿qué
parte del testbench se daría cuenta si el DUT levantara `done` dos ciclos antes?*
La respuesta honesta es ninguna, y sorprende, porque a esta altura el testbench
ya tiene scoreboard, cobertura, dos agents y sequences.
La razón es estructural, no un descuido: el scoreboard recibe *transactions*, que
es justamente lo que queda **después** de borrar el protocolo. El monitor lo
borra en los analysis ports y hace bien: eso es lo que hace que el scoreboard no sepa
que existe un `clk`. El precio es que la capa que ve los cables —la interface— es
la única que puede chequearlos, y hasta hoy sólo los movía.
Ésta es también la respuesta a *"¿por qué SVA es la otra mitad de la
verificación?"*: no es otra técnica para hacer lo mismo, es la mitad que este
testbench no cubre.

---

## Assertions (SVA)

#### *Inmediatas y concurrentes: la que ya conocen y la nueva*

```sv
// INMEDIATA: es una SENTENCIA. Corre cuando el hilo pasa por ahí,
// una vez, y nada más. La de las transactions es de esta familia.
assert (cmd.op inside {add_op, and_op, xor_op, mul_op})
   else `uvm_error("SEQ", "operacion invalida");

// CONCURRENTE — la novedad. Es una DECLARACION con reloj: se enchufa
// al arrancar la simulacion y se evalua en cada flanco, para siempre.
a_done : assert property (@(posedge clk) start |=> ##[0:4] done);
```

- La **inmediata** vive adentro de un `begin/end`, es procedural, y sólo existe
  mientras el hilo está parado ahí
- La **concurrente** no vive en ningún hilo: es una declaración, como un
  `always`. Se escribe una vez y chequea cada flanco de la simulación entera
- Por eso una concurrente puede describir algo que **dura varios ciclos**, y una
  inmediata no

Note:
La distinción cuesta al principio y conviene anclarla con la analogía del RTL:
una inmediata es a un `if` lo que una concurrente es a un `always_ff`. La
primera se ejecuta; la segunda se **instancia**.
La consecuencia práctica es la que importa: la inmediata sólo puede mirar el
presente —el valor de una variable en ese instante—, mientras que la concurrente
tiene un eje de tiempo propio y puede decir *"si pasa esto, tres ciclos después
tiene que pasar aquello"*. Ninguna cantidad de `if` escribe esa frase sin
inventar máquinas de estado a mano.
Y el enganche con las transactions: `assert(x.randomize())` es una inmediata, y ahí
está la trampa muda de aquella sección —`assert` es una directiva de simulación, y
con las asserts apagadas el argumento no se ejecuta. Acá se ve por qué: son la
misma palabra clave para dos cosas distintas.

---

## Assertions (SVA)

#### *Anatomía de una property*

```sv
a_done_llega :                      // <- el label: NO es opcional
assert property (
   @(posedge clk)                   // <- el reloj: cuando se muestrea
   disable iff (!reset_n)           // <- cuando NO chequear
   start && (op_set != no_op)       // <- el antecedente
   |->                              // <- la implicacion
   ##[1:5] done                     // <- el consecuente
) else `uvm_error("SVA", "...");    // <- que hacer si falla
```

- Se lee como una frase: *"en cada flanco de `clk`, mientras no haya reset, si
  `start` está arriba con una operación real, entonces `done` llega dentro de
  cinco ciclos"*
- El **label** sale en el mensaje de error y en el reporte de cobertura. Una
  property sin label es un error anónimo a las tres de la mañana
- Las siete partes son siempre las mismas. El resto de la sección es aprender qué
  se puede poner en cada una

Note:
Conviene escribir esta slide en el pizarrón como plantilla y volver a ella cada
vez que aparezca una property nueva: el alumno que se pierde en SVA casi siempre
se pierde porque no distingue el antecedente del consecuente.
El label merece un párrafo propio. Sin él, el simulador inventa uno
(`__unnamed$$_0`), y ese nombre es el que va a aparecer en el log de la regresión
nocturna y en el reporte de cobertura de assertions. Es exactamente el mismo
argumento del `begin : nombre` que el curso viene usando desde interfaces y BFM.
El `disable iff` se ve en detalle más adelante, pero vale adelantar por qué está
tan arriba en la plantilla: es la parte que más se olvida y la que más falsos
positivos genera.

---

## Assertions (SVA)

#### *`|->` contra `|=>`, el error número uno*

```sv
// |->  overlapping: el consecuente empieza en EL MISMO flanco
a : assert property (@(posedge clk) start |-> !done);

// |=>  non-overlapping: el consecuente empieza en el flanco SIGUIENTE
b : assert property (@(posedge clk) start |=> !done);
```

- `a |=> b` es exactamente `a |-> ##1 b`. No hay más misterio que ése
- ¿Cuál va? Depende de si la respuesta es **combinacional** (el mismo flanco) o
  **registrada** (el siguiente). En el VTALU, `done` sale de un `always_ff`:
  siempre es el siguiente
- Equivocarse no da un síntoma solo: `start |-> done` con `done` registrado
  **falla en cada transacción** —ve el `done` viejo—, y una property cuyo
  antecedente nunca ocurre pasa en vacío. Por eso va siempre con su `cover`

Note:
Ésta es la primera pregunta de toda entrevista sobre SVA y conviene practicarla
con el DUT en la mano: `done_1c <= start && (op != 3'b000)` es un NBA, así que
lo que se escribe en el flanco *n* recién se lee en el *n+1*. Con `|->` la
property compararía `start` contra el `done` **viejo**.
La regla operativa, que es más útil que la teoría: `|=>` **es** `|-> ##1`, así que
la pregunta no es cuál de los dos operadores va sino **cuántos flancos después** lo
promete la spec. Un `assign` contesta en el mismo flanco y un `<=` en el
siguiente, pero eso es el caso fácil: la property estrella de esta misma sección
—`start && op_set != no_op |-> ##[1:5] done`— usa `|->` para un `done` que sale de
un `always_ff`, porque la spec promete una ventana de uno a cinco flancos y no
uno solo.
Y la trampa que hay que nombrar en voz alta, sin exagerarla: equivocarse a veces
grita —`|->` contra una señal registrada falla en cada transacción— y a veces se
calla, cuando el antecedente que escribiste no ocurre nunca y la property se
satisface por vacío. Ese segundo caso es el que el reporte final da por bueno, y
es la razón por la que la slide del `cover property` no es un extra: es el único
chequeo del chequeo.

---

## Assertions (SVA)

#### *Mirar el pasado: `$rose`, `$fell`, `$stable`, `$past`*

```sv
$rose(start)      // 0 -> 1 entre el flanco anterior y este
$fell(done)       // 1 -> 0
$stable(A)        // el valor es el mismo que en el flanco anterior
$past(result, 3)  // el valor que tenia hace 3 flancos
```

- Las cuatro comparan **contra el muestreo anterior**, no contra el instante
  anterior. En SVA el tiempo se cuenta en flancos del reloj de la property, no en
  nanosegundos
- `$stable` es la que escribe *"no se tocó"*, que es media biblioteca de reglas
  de protocolo
- `$past(x, n)` es una línea de retardo gratis: sirve para chequear una latencia
  fija sin escribir una máquina de estados

Note:
Ojo con `$rose` en una señal que se mueve **en el mismo flanco** que la property
muestrea: no la va a ver subir en ese flanco, la va a ver subir en el siguiente.
Ese es exactamente el tema de la slide que viene, y conviene sembrarlo acá.
`$past` con el segundo argumento es la que más se subestima: chequear *"el
resultado de ahora corresponde a los operandos de hace cuatro flancos"* es una
línea, y a mano son un shift register y tres bugs.
Vale también decir dónde se pueden usar, porque hay una media verdad que circula:
sí se pueden llamar desde código procedural —un `always @(posedge clk) if
($rose(req)) …` es legal (1800-2017 §16.9.3) y Verilator 5.052 lo acepta—, porque
de ahí infieren el reloj. Lo que necesitan siempre es **un** reloj: en un
`initial` sin evento de reloj no significan nada. Y el límite práctico de este
flujo: `$past` con el argumento de reloj explícito no lo soporta Verilator
(*Unsupported: $past expr2 and/or clock arguments*).

---

## Assertions (SVA)

#### *La property que vale la sección*

{{code:code/u8/assertions/vtalu_bfm.sv#stable-operands}}

- Es **la regla de la slide 1 del día 1**: mientras `start` está arriba, los
  operandos no se tocan. Estuvo escrita en prosa seis días
- Once líneas, y chequean cada transacción de cada test, en los dos agents, sin
  que nadie las conecte a nada
- El scoreboard **no puede** escribir esta regla: para cuando la transaction le
  llega, el protocolo ya se borró

Note:
Éste es el momento para volver a la slide de la spec y leerla textualmente.
La distancia entre *"los operandos deben permanecer estables mientras `start`
está activo"* y la línea de SVA que está en pantalla es casi cero — y ése es todo
el argumento de por qué las assertions se escriben temprano y no al final: la
especificación **ya está escrita**, sólo hay que traducirla.
El `$stable(op_set)` del final es el que suele faltar y es el que caza el bug más
feo: cambiar la operación a mitad de transacción es legal para el compilador,
ilegal para el DUT y transparente para el scoreboard.
Vale mostrar el `@(negedge clk)` y **no** explicarlo todavía: dejarlo como una
rareza que se aclara en la slide siguiente. Alguien va a preguntar antes.

---

## Assertions (SVA)

#### *⚠ Dos relojes: una assertion vale lo que vale su muestreo*

{{code:code/u8/assertions/vtalu_bfm.sv#two-clocks}}

| Con un solo reloj | Sobre 1000 operaciones |
| --- | --- |
| todo en `posedge` | **145 falsos positivos** en la estabilidad de operandos |
| todo en `negedge` | falsos positivos en las properties de `done` |
| **estímulo en `negedge`, respuesta en `posedge`** | **0 errores** ✅ |

- La BFM maneja en `negedge` y el DUT registra en `posedge`. **No existe un
  flanco único que haga correctas a las cuatro properties**
- El muestreo de SVA es la región *preponed*: una señal escrita **en** el flanco
  no se ve en ese flanco, se ve en el siguiente

Note:
Ésta es la lección más valiosa de la sección y no está en los tutoriales, así que
vale contarla con la traza en la mano: en dos `no_op` consecutivas, `start` baja
en `t=111` y vuelve a subir en `t=120` — **entre dos `posedge`**. El muestreo no
lo ve bajar. Las dos transacciones se leen como una sola, con los operandos
cambiando en el medio, y la property grita 145 veces por algo que nunca pasó.
La forma corta de decirlo: *una assertion no chequea lo que pasó, chequea lo que
vio*. Y lo que ve depende de un solo carácter en el `@()`.
Es otra **trampa muda**, y de las peores: compila, corre, y te tira 145 errores
que no existen. El reflejo del principiante es aflojar la property hasta que
calle —y ahí se quedó sin chequeo. El reflejo correcto es mirar en qué flanco
escribe el que estimula.
La salida industrial de fondo es el **clocking block**, que declara el muestreo
una vez para toda la interface en vez de repetirlo property por property. Está en
el día 1 —`030-interfaces-bfm.md` y `docs/clocking-blocks.md`— y vale volver a
nombrarlo acá, porque recién ahora se ve el problema completo que resuelve.

---

## Assertions (SVA)

#### *La latencia variable, en una línea*

{{code:code/u8/assertions/vtalu_bfm.sv#done-arrives}}

- `##[1:5] done` dice *"entre uno y cinco flancos después"*. La VTALU tarda **uno**
  en `add`/`and`/`xor` y **cuatro** en la multiplicación: una property las cubre a
  las dos
- `##n` es un retardo exacto, `##[a:b]` una ventana, `##[1:$]` *"en algún
  momento"* — que casi nunca es lo que se quiere: una property sin cota superior
  no puede fallar nunca por timeout
- El antecedente **excluye `no_op`** a propósito: es la única operación que no
  contesta, y meterla adentro convertiría la property en un generador de falsos
  positivos

Note:
La cota superior es lo que separa una assertion útil de una decorativa.
`##[1:$] done` es cierta también para un DUT que contesta el martes que viene:
compila, pasa, y no chequea nada. El número que va ahí sale de la especificación,
no de lo que el DUT hace hoy — y si no está en la especificación, ése es el
hallazgo de la sección.
El 5 de este ejemplo tiene un margen deliberado sobre los 4 flancos reales de la
multiplicación. Vale preguntar al grupo si preferirían `##[1:4]`, y por qué. La
respuesta honesta es que depende de si la especificación dice *"cuatro"* o dice
*"hasta cinco"*: una assertion es un contrato, y apretarla más que el contrato la
convierte en una fuente de falsos positivos cuando alguien cambie el pipeline.
La `p_no_op_sin_done` de abajo es el complemento y usa `|=>` justamente por lo de
la slide anterior: `done` sale de un `always_ff`.

---

## Assertions (SVA)

#### *`disable iff` y el reset*

```sv
default disable iff (!reset_n);   // una vez, para toda la interface

property p;
   @(posedge clk) disable iff (!reset_n)   // o property por property
   start |=> done;
endproperty
```

- Durante un reset **todo está mal a propósito**: `done` se cae, `start` se cae,
  las transacciones a mitad de camino se abandonan. Sin `disable iff`, cada reset
  es una tanda de falsos positivos
- `disable iff` **aborta** las evaluaciones en vuelo, no las hace fallar. La
  property se olvida de lo que estaba esperando y arranca de cero
- El `default disable iff` al principio de la interface lo aplica a todas: es una
  línea contra veinte repeticiones

Note:
El segundo error clásico, después del `|->`/`|=>`. Y el síntoma engaña: la
regresión se llena de errores **al principio de cada test**, que es justo cuando
uno menos mira, porque "todavía se está inicializando".
Vale nombrar el error inverso, que es más peligroso: un `disable iff` con la
condición al revés —`disable iff (reset_n)`— apaga la property durante la
operación normal y la deja activa sólo en el reset. Pasa siempre, no chequea
nunca, y no hay forma de darse cuenta mirando el log. Es la segunda trampa muda
de la sección y también se ataja con `cover property`.
La diferencia entre *abortar* y *fallar* importa cuando el reset llega a mitad de
una transacción larga. En este DUT es de un ciclo; en un bus real, con
transacciones de decenas, es la diferencia entre una property usable y una que
hay que apagar.

---

## Assertions (SVA)

#### *Dónde viven: adentro de la interface*

- Van **con las señales**, en la `interface`, no en el testbench de clases. Ahí
  ven `clk`, `start`, `A`, `B` y `done` sin que nadie se las pase
- No hay que conectarlas, ni instanciarlas, ni construirlas en un `build_phase`.
  Existen porque la interface existe
- El `top` de los agents instancia **dos** BFM: las mismas properties chequean
  las dos VTALU, incluida la que maneja el módulo heredado que nadie escribió
- Un **agent pasivo** se las lleva de regalo: mirar una interface ahora también
  es chequearla

Note:
Ésta es la slide que conecta la sección con toda la arquitectura del curso. La
interface venía siendo el lugar donde el testbench *mueve* cables; a partir de
acá es también donde los *vigila*, y las dos cosas por el mismo motivo: es la
única capa que los ve.
El argumento de reuso es el que convence a un equipo: las properties viajan con
la interface. Quien instancie esta BFM en otro proyecto se lleva el chequeo de
protocolo puesto, sin leer una línea de UVM. Es exactamente lo que no pasa con un
scoreboard, que hay que construir, conectar y configurar.
Y la vuelta de tuerca de los agents vale decirla despacio: el módulo heredado
—el "tester del jefe", sin una línea de UVM— también está siendo chequeado. Nadie
le pidió permiso. Ése es el ejercicio del día.
---

## Assertions (SVA)

#### *`bind`: cuando la interface no es tuya*

```systemverilog
// El checker vive afuera. El RTL no se toca — muchas veces no se puede.
module apb_checks (input bit PCLK, PSEL, PENABLE, PREADY);
   a_setup : assert property (@(posedge PCLK) PSEL && !PENABLE |=> PENABLE);
   c_setup : cover  property (@(posedge PCLK) PSEL && !PENABLE);
endmodule

// Y en el top, una línea por cada módulo que se quiera vigilar:
bind apb_regs apb_checks chk (.*);
```

- La slide anterior vale cuando la interface **es tuya**. El RTL ajeno, el IP
  comprado y el módulo heredado no se editan
- `bind` mete una instancia **adentro** de otro módulo desde afuera: el checker
  ve las señales internas del DUT como si estuviera escrito ahí
- El `.*` conecta por nombre. Un `bind` alcanza para **todas** las instancias de
  ese módulo — o `bind top.dut ...` para una sola
- También se puede bindear a una `interface`, y Verilator soporta las dos formas

Note:
Ésta es la pregunta de entrevista que sigue a la slide anterior, y conviene
plantearla así: *"muy lindo poner las properties en la interface — ¿y cuando la
interface no es tuya?"*. La respuesta es `bind`, y es la forma en que las
assertions se usan en la industria: un archivo de checkers por bloque, todos
bindeados desde el top, y el RTL sin una línea de verificación adentro.
El motivo de fondo no es estético: en un flujo de síntesis el RTL que se entrega
es el que se sintetiza, y meterle `assert property` adentro obliga a todo el
mundo a llevar la verificación puesta. Con `bind`, el que sintetiza no compila
el archivo de checkers y listo.
La ventaja concreta, y la que hace que valga la pena: el checker bindeado ve las
**señales internas** del DUT — el estado de la FSM, el contador de wait states —,
que es justamente lo que la interface no ve. Ahí es donde las assertions dejan
de chequear el protocolo y pasan a chequear la implementación.
Y el aviso: un `bind` mal escrito no falla, no conecta nada y la property queda
sin correr. Igual que siempre, el antídoto es el `cover property` — si el cover
está en cero, el `bind` no llegó.


---

## Assertions (SVA)

#### *La integración con UVM: el `else` que hace que cuente*

```sv
// El default de SystemVerilog: MATA la simulacion en la primera falla
a : assert property (p);

// Lo que se quiere en UVM: la falla cuenta y la simulacion sigue
a : assert property (p)
    else `uvm_error("SVA", $sformatf("%m: operando cambiado"));
```

- Sin `else`, la acción por defecto de una assertion que falla es `$error` —y en
  varios simuladores, `$stop`. La simulación se corta y el *Report Summary*
  **no se imprime**
- Con un `else` que llama a `` `uvm_error ``, la falla entra por el mismo canal
  que todo lo demás: cuenta en el resumen, respeta `+UVM_MAX_QUIT_COUNT`, y el
  `run.sh` la detecta sin cambiar una línea
- El `%m` del mensaje imprime **qué instancia** de la interface falló:
  `top.clase_bfm` o `top.modulo_bfm`

Note:
Es el puente entre las dos mitades del curso y hay que hacerlo explícito: la
assertion no es un mundo aparte con su propio reporte. Es un `uvm_error` más, y
por eso `uvm_summary_ok` de `common.sh` lo detecta sin que hubiera que tocar
nada.
La razón por la que el default no sirve es práctica: una regresión nocturna que
se corta en la primera falla informa **una** falla. La misma corrida con
`uvm_error` informa las 154, y eso es la diferencia entre *"algo anda mal"* y
*"anda mal en todas las multiplicaciones"*.
El `%m` parece un detalle y no lo es: con dos instancias de la misma interface,
un mensaje sin `%m` no dice cuál de las dos ALU se rompió. Es el mismo problema
que resolvía `get_full_name()` en reporting, con la herramienta del lenguaje
en vez de la de la librería.

---

## Assertions (SVA)

#### *Toda assertion va con su `cover property`*

{{code:code/u8/assertions/vtalu_bfm.sv#the-covers}}

{{code:code/u8/assertions/cover.txt}}

- Una property cuyo **antecedente no ocurre nunca** pasa. Sin cobertura de
  assertions, un chequeo apagado se ve igual que un chequeo verde
- `c_mult_3ciclos` se queda en **cero para siempre**: la cadena del multiplicador
  es `done3 → done2 → done1 → done_mult`, o sea **cuatro** flancos, no tres. El
  cover en 0 avisa de que el modelo mental de la latencia estaba mal
- En Verilator los `cover property` caen en el **mismo `coverage.dat`** que los
  covergroups del testbench convencional: cobertura de código, funcional y de assertions, un
  solo reporte

Note:
Esta slide cierra el círculo que abrió el testbench convencional y conviene decirlo así: la
pregunta *"¿cómo sé que medí?"* tuvo tres respuestas en el curso, y ésta es la
tercera. La cobertura funcional dice qué estímulo se generó; la cobertura de
assertions dice qué **chequeos se evaluaron de verdad**.
El caso de `c_mult_3ciclos` es un regalo pedagógico y salió de escribir la
sección, no de inventarlo: la cuenta intuitiva era tres —el módulo se llama
`vtalu_mult`— y el hardware tarda cuatro, porque el `done` viaja por un pipeline
propio. La property con `##3` habría pasado igual si hubiera sido un `assert`
mal escrito, y el `cover` en cero es lo único que lo delata.
La regla para llevarse: por cada `assert property` que escribas, escribí el
`cover property` del antecedente. Son dos líneas y es la diferencia entre un
testbench que chequea y uno que dice que chequea.

---

## Assertions (SVA)

#### *Assertion o scoreboard: la misma regla, dos lugares*

| | Assertion | Scoreboard |
| --- | --- | --- |
| Qué chequea | el **protocolo**: quién se mueve, cuándo | la **transformación**: `A op B` |
| Dónde vive | en la `interface`, con los cables | en el testbench, con las transactions |
| Cuándo grita | en el flanco exacto en que se rompe | cuando llega el resultado |
| Qué necesita | nada: se enchufa sola | monitor, analysis port, `connect_phase` |

- Regla corta: **protocolo → assertion. Datos → scoreboard.** Escribir un
  chequeo de protocolo en el scoreboard es reconstruir el tiempo que el monitor
  se acaba de encargar de borrar
- Y al revés: escribir el modelo de referencia de un multiplicador en SVA es
  posible y es una mala idea

Note:
La pregunta que siempre aparece: *¿por qué no chequear todo en un solo lugar?* La
respuesta es que las dos capas ven cosas distintas y ninguna puede ver la de la
otra sin deshacer el trabajo del monitor.
La ventaja del *"grita en el flanco exacto"* es la que más tiempo ahorra en la
vida real, y vale ponerla en números: un mismatch del scoreboard te da un
resultado equivocado y hay que rastrear hacia atrás hasta encontrar el ciclo
donde empezó. Una assertion te da el ciclo. En un bus con transacciones
solapadas, ésa es la diferencia entre media hora y dos días.
La otra mitad de la regla también importa: SVA no reemplaza al scoreboard. Nadie
quiere leer un modelo de referencia escrito en properties, y el que lo intentó lo
cuenta como anécdota.

---

## Assertions (SVA)

#### *El ejemplo de la sección: el bug que el scoreboard no ve*

{{code:code/u8/assertions/vtalu_bfm.sv#the-planted-bug}}

{{code:code/u8/assertions/sva.txt}}

- `+BUG=1` cambia `B` **a mitad de la multiplicación**. El multiplicador ya
  latcheó los operandos en el primer flanco: **el resultado sale bien igual**
- El scoreboard compara 1000 operaciones y no encuentra una sola diferencia: en
  el resumen **no hay un solo `[SELF CHECKER]`**. Está haciendo bien su trabajo —
  este bug no es de datos
- La assertion lo caza 154 veces, en el flanco exacto. Es el mismo ejemplo de reporting, dado vuelta: allá se rompía el scoreboard para enseñar reporting;
  acá se rompe el protocolo para mostrar quién lo ve

Note:
Correr las dos corridas en vivo si hay tiempo: `bash code/u8/assertions/run.sh` hace la
limpia y la del bug, una atrás de la otra, y la comparación de los dos *Report
Summary* es la slide.
Vale hacer notar por qué el bug es invisible, porque no es obvio: el pipeline
hace `a_int <= A` en el primer flanco y `mult1 <= a_int * b_int` en el segundo.
Todo lo que pase con `A` y `B` después del primer flanco se descarta. Un
diseñador diría que el DUT es *robusto*; un verificador diría que el testbench
está mintiendo — el estímulo violó el contrato y nadie se enteró.
Y el remate: este bug no es hipotético. Es exactamente lo que hace el módulo
heredado del ejercicio, y es exactamente el tipo de cosa que sobrevive años en un
bloque que "anda".

---

## Assertions (SVA)

#### *Las trampas de esta sección*

| El síntoma | La causa | Cómo se ataja |
| --- | --- | --- |
| La property **pasa siempre** | el antecedente no ocurre nunca | un `cover property` por assertion |
| **Falsos positivos** en cada transacción | la muestreás con el flanco en que se escribe | estímulo y respuesta van en flancos distintos |
| Falsos positivos **al arrancar** cada test | falta el `disable iff (!reset)` | `default disable iff` una vez, arriba |
| El log dice **PASS** y las properties no corrieron | falta `--assert` al compilar | el `cover` en 0 es el que avisa |

- Las cuatro comparten la forma del apéndice: **compilan, corren, y mienten**
- La cuarta es la más barata de cometer y la más cara: sin `--assert`, Verilator
  compila las properties y no las evalúa. Todo verde, cero chequeo

Note:
La cuarta fila merece un minuto porque es específica del flujo de este curso y
sorprende: `--assert` no es un flag de "más warnings", es el interruptor que
convierte una declaración en un chequeo. Sin él, el bloque entero de la interface
es documentación cara.
Y el antídoto es el mismo para las cuatro, que es lo elegante: el `cover
property`. Si el cover está en cero, o la property no corre, o su antecedente no
ocurre. En los dos casos hay que ir a mirar, y en los dos casos el `assert` solo
habría dicho que todo está bien.
Estas cuatro se suman al apéndice de las trampas mudas, que a partir de esta
sección son veinte.

---

## Assertions (SVA)

#### *Resumen de la unidad*

- Una **assertion concurrente** es una declaración con reloj: se escribe una vez
  y chequea cada flanco de la simulación, sola
- La anatomía no cambia nunca: `label : assert property (@(reloj) disable iff
  (reset) antecedente |-> consecuente) else acción;`
- `|->` es el mismo flanco y `|=>` **es** `|-> ##1`. La pregunta no es cuál de los
  dos, es cuántos flancos después lo promete la spec
- Las properties viven **en la `interface`**, con las señales. No se conectan, no
  se construyen, y viajan con ella
- En UVM la acción es `` `uvm_error ``, para que la falla **cuente** en el
  *Report Summary* en vez de matar la simulación
- **Toda assertion va con su `cover property`**: es el único chequeo del chequeo
- Y la que se lleva la sección: **una assertion vale lo que vale su muestreo**.
  El estímulo se muestrea donde el estímulo se escribe

Note:
Si el grupo se lleva una sola frase, que sea la última. Todo lo demás de esta
sección es sintaxis y se busca; el muestreo es criterio, y es lo que separa una
property que chequea de una que hace ruido o de una que calla.
La segunda para llevarse es la del `cover property`, por una razón cultural: es
la única defensa contra el testbench que se siente seguro. Un equipo con
trescientas assertions y sin cobertura de assertions no sabe cuántas está
corriendo.
Y vale cerrar con la ubicación en el mapa: esto es la mitad que faltaba. El
scoreboard chequea qué calcula el DUT; las assertions, cómo se habla con él. Un
plan de verificación serio tiene las dos columnas.

---

## Assertions (SVA)

#### *Lo que esta sección hace distinto*

- **El *UVM Primer* no tiene SVA.** Enseña el testbench de
  clases de punta a punta y deja las assertions afuera: son de la otra mitad de
  SystemVerilog
- Esta sección existe porque la pregunta llega igual —en la entrevista, y en el
  primer bloque real que a uno le toca verificar
- Los dos relojes, la tabla de los 145 falsos positivos y el `cover property` que
  nunca se cubre **no salieron de un tutorial**: salieron de escribir esta
  sección sobre el VTALU del curso y mirar por qué no daba
- Todo lo de acá corre en Verilator, sin licencias, con el mismo `run.sh` de los
  otros treinta y siete ejemplos

Note:
Vale ser explícito con el grupo sobre de dónde sale cada cosa, porque es parte de
lo que el curso enseña: la diferencia entre leer sobre SVA y escribir SVA es
exactamente la slide de los dos relojes. Ningún tutorial la tiene porque los
tutoriales usan un DUT donde el estímulo y la respuesta comparten flanco.
Es también la respuesta a *"¿por qué un curso más de UVM?"*. Éste corre. Y cuando
algo no da, la sección cuenta por qué no daba en vez de cambiar el ejemplo.
Lo que queda afuera y conviene nombrar para que nadie lo descubra tarde:
assertions formales, `expect`, y las properties de bus prefabricadas que vienen
con los VIP comerciales. Con lo de esta sección se leen sin ayuda.
