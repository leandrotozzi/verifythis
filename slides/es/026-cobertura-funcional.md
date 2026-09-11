## Cobertura funcional

#### *¿Cuándo terminás de verificar?*

- *Cobertura de código* —líneas, ramas, toggle— la da el simulador gratis.
  Dice qué RTL se **ejecutó**
- *Cobertura funcional* la escribís vos. Dice qué **escenarios de la spec**
  pasaron por el DUT
- No son lo mismo, y la primera engaña: un test que manda siempre `add_op`
  con `A=B=8'h01` ejecuta casi todas las líneas del sumador y no verificó nada
- La cobertura funcional es el *contrato* entre la spec y el testbench: si un
  caso de la spec no tiene un bin, nadie se va a enterar de que falta

Note:
La pregunta de la slide es la que le hacen a un verificador en la reunión de
tape-out, y no se contesta con "corrí muchos tests".
Si alguien pregunta por qué no alcanza la cobertura de código: porque mide el
DUT, no la spec. Un DUT al que le falta una feature entera puede dar 100 % de
líneas — las líneas que no escribió nadie no aparecen en el reporte.

---

## Cobertura funcional

#### *Del plan de verificación al covergroup*

Las seis filas del plan de la sección anterior, traducidas:

| Del plan | Cómo se mide |
| --- | --- |
| las seis operaciones | `coverpoint op_set` con un bin por operación |
| operandos en `00` y en `FF` | `cross` de A, B y la operación |
| operar después de un reset | bin de transición `rst_op => op` |
| una mult después de una de un ciclo | bin de transición |
| la misma operación dos veces seguidas | bin de repetición `[* 2]` |
| restar de menos: `A < B`, y el `ovf` sube | `coverpoint borrow` con el bin `hubo_borrow` |

- Las seis filas dejan de ser buenas intenciones: cada una es una línea de
  código, y el simulador te dice cuáles todavía no pasaron

Note:
Vale la pena volver al plan de la sección anterior y leerlo en voz alta antes de
mostrar esta tabla: la gracia es que no hay ni un punto del plan que se quede
sin traducir.
El orden importa — el plan primero, el covergroup después. Al revés terminás
midiendo lo que el testbench hace, no lo que la spec pide.

---

## Cobertura funcional

#### *Anatomía: son tres pasos, no uno*

```systemverilog
covergroup op_cov;                     // 1. QUE se mide
   coverpoint op_set;
endgroup

op_cov oc;                             // 2. se INSTANCIA: es un tipo, como una clase
initial oc = new();

always @(posedge clk) oc.sample();     // 3. CUANDO se cuenta
```

- Un `covergroup` es un **tipo**: declararlo no mide nada, hay que hacerle `new()`
- `sample()` es el que cuenta. Sin `sample()` el reporte da **0 %** y el código
  compila igual
- *Dónde* muestrear es una decisión de diseño. Acá, el flanco en el que **lee el
  DUT**, nunca el mismo en el que escribe el tester; cuando el TB tenga
  monitores va a ser *"cada vez que el monitor ve un comando"*

Note:
El error de todos la primera vez es declarar el covergroup y olvidarse del
`new()` o del `sample()`. No hay warning: el reporte simplemente dice 0 % y uno
se pasa media hora buscando el bug en los bins.
El tercer punto es el que vale para el resto del curso: el momento del sample
define qué estás midiendo. Muestrear por reloj cuenta ciclos; muestrear por
transacción cuenta operaciones. En los analysis ports el `coverage` pasa a ser un
subscriber y muestrea cuando llega un comando — que es lo correcto.
Y el flanco no es capricho: muestrear en el mismo `negedge` en el que el tester
escribe `op_set` es una carrera que el LRM no define —Verilator la resuelve
siempre igual; otro simulador puede no—. Es la misma regla de las assertions
del día 7: se lee en el flanco opuesto al que escribe.

---

## Cobertura funcional

#### *bins: los casilleros que hay que llenar*

```systemverilog
coverpoint op_set;                   // bins automaticos: uno por valor del enum

coverpoint op_set {
   bins single_cycle[] = {[add_op : xor_op], rst_op, no_op};  // [] -> uno por valor
   bins multi_cycle    = {mul_op};                            // sin [] -> uno solo
}
```

- Sin `{ }`, SystemVerilog crea un bin por valor. Anda para un `enum`; para un
  `int` la herramienta corta el rango en **64** casilleros —`auto_bin_max`— que
  no corresponden a ninguna fila del plan
- Los corchetes `[]` **reparten**: un casillero por valor del rango. Sin ellos,
  todos los valores caen en el mismo casillero
- Un coverpoint está cubierto cuando **todos** sus bins tienen al menos un hit.
  Un bin que no se puede llenar te clava el número para siempre

Note:
Los corchetes son el detalle que más se copia mal, y conviene mostrarlo con los
dos casos al lado: `bins x[] = {[0:3]}` son **cuatro** casilleros, y
`bins x = {[0:3]}` es **uno solo** que se llena con que caiga cualquiera de los
cuatro valores. La sintaxis se diferencia en dos caracteres y el número que
reporta la herramienta cambia por completo.
La consecuencia práctica hay que decirla fuerte porque es una trampa muda: un
bin sin `[]` sobre un rango grande **siempre da 100 %**. Cubriste un valor de
mil y la herramienta te dice que está listo. Nadie te avisa.
Y el último bullet es la advertencia que ordena lo que viene: un bin que
no se puede llenar no es un problema de la herramienta, es una decisión que
alguien no escribió. La forma de escribirla se llama `ignore_bins`, y tiene su
propia slide en esta sección.

---

## Cobertura funcional

#### *El covergroup del VTALU*

{{code:code/u2/convencional/vtalu_tb.sv#op_cov}}

- `single_cycle[]` genera seis bins —uno por operación—, `multi_cycle` uno solo
- Lo que está entre `` `ifndef VERILATOR `` son los bins de transición, que
  vienen más adelante en esta misma sección

Note:
Éste es el primer covergroup real del curso, y conviene leerlo de arriba hacia
abajo contestando las tres preguntas de la slide anterior: **qué** se mide (los
coverpoints), **en qué casilleros** (los bins) y **cuándo** se cuenta (el
`sample()`, que está más abajo en el mismo archivo).
Que `multi_cycle` sea un bin solo y `single_cycle[]` sean seis no es simetría
rota: es el plan de verificación. Las seis que no son la multiplicación interesan
una por una; la multiplicación interesa como caso aparte porque es la única que
tarda más de un ciclo. La forma del covergroup **es** la tabla del plan, y por eso el
plan se escribe primero.
El `` `ifndef VERILATOR `` vale nombrarlo ahora y no esconderlo: esos bins son
tema del curso, están escritos, y hoy Verilator no los compila. Está en
`docs/verilator.md` con la versión y la fecha. Un curso que tapa lo que su
herramienta no hace es un curso que miente.

---

## Cobertura funcional

#### *ignore_bins: decir en voz alta lo que no se cubre*

{{code:code/u2/convencional/vtalu_tb.sv#legs-and-ops}}

- `all_ops` **ignora** `rst_op` y `no_op`: no tiene sentido pedir "una suma con
  los operandos en 0x00" cuando la operación es un reset
- `a_leg` y `b_leg` bajan 256 valores a los tres casilleros que importan:
  todo ceros, el medio, todo unos
- Un bin imposible que dejás puesto te deja la cobertura clavada abajo del 100 %
  y nadie sabe por qué. `ignore_bins` lo vuelve una decisión escrita

Note:
Hay un pariente que conviene nombrar: `illegal_bins`. `ignore_bins` saca el bin
de la cuenta; `illegal_bins` lo saca de la cuenta *y además* reporta un error si
alguna vez pasa. Sirve para los casos que la spec prohíbe — un opcode reservado,
un handshake ilegal.
La regla práctica: si no se puede cubrir, `ignore_bins`; si no debe pasar,
`illegal_bins`; si simplemente todavía no pasó, dejalo y escribí el test.

---

## Cobertura funcional

#### *cross: las combinaciones, y cómo no ahogarse*

```systemverilog
op_00_FF : cross a_leg, b_leg, all_ops;    // 3 x 3 x 5 = 45 bins, casi todos sin sentido
```

- Un `cross` es el **producto cartesiano** de sus coverpoints: crece rápido y la
  mayoría de las combinaciones no está en ninguna spec
- `binsof(x) intersect {v}` se lee *"los bins de `x` que contienen `v`"*
- Se combinan con `&&` y `||`, y lo que sobra se tira con `ignore_bins`
- Así los 45 bins quedan en los 11 que el plan pidió de verdad

Note:
La cuenta del comentario es lo que hay que hacer en voz alta, porque el número
asusta y tiene que asustar: tres bins de A por tres de B por cinco operaciones
son **45**, y de esos 45 el plan pedía once. Los otros 34 no están mal — están
de más, y un bin de más es tan caro como uno que falta: te clava la cobertura
abajo del 100 % y nadie sabe si es un agujero real.
`binsof(x) intersect {v}` conviene leerlo siempre en castellano antes de
escribirlo, porque la sintaxis no ayuda: *"los bins de `x` que contienen `v`"*.
Después se combinan con `&&` y `||` como cualquier condición.
El error de escala que hay que anticipar: en un DUT real un cross de tres
coverpoints con bins automáticos son miles de casilleros, y una regresión no los
llena nunca. Cuando alguien dice "la cobertura no sube", en la mitad de los casos
el problema es un cross sin filtrar, no un test que falta.
Y el número que hay que tener a mano para la slide "Leer el número": los 45 son
la cuenta del LRM, un bin por miembro del enum. **Verilator mide 54**, porque
reparte los bins automáticos por el tipo base (`bit [2:0]`, 8 valores menos los
2 de `ignore_bins`, o sea 3 × 3 × 6). Los 9 de más son el `3'b110` cruzado, y son
exactamente los 9 que quedan en cero.

---

## Cobertura funcional

#### *El cross del VTALU*

{{code:code/u2/convencional/vtalu_tb.sv#cross-mul-bins}}

- `mul_00` se lee de corrido: *una multiplicación en la que A **o** B valgan
  0x00*. Los otros ocho bins del cross son estas dos líneas con otro `op`
- `mul_max` es el único con `&&`: pide las **dos** patas en 0xFF: el **producto
  máximo**, `FF` × `FF` = `FE01`. No desborda — 8 bits por 8 entran en 16
- Verilator 5.052 **ignora** `binsof` / `intersect` (`%Warning-COVERIGN`) y mide
  el cross completo: por eso el número no es el de una herramienta comercial

Note:
Vale leer `mul_00` y `mul_max` en castellano, uno detrás del otro, porque la
diferencia entre `||` y `&&` es la que se copia mal, y acá los dos bins son de la
misma operación: *"una multiplicación en la que A **o** B valgan 0x00"* contra
*"una multiplicación con A **y** B en 0xFF"*. El primero
son dos casos, el segundo es uno solo — el **producto máximo**, la esquina de
arriba del espacio de entrada. Y acá conviene matar el malentendido que viene
solo, porque es caro: `FF` × `FF` **no desborda nada**. Da `FE01`, que entra
exacto en los 16 bits de `result` —8 bits por 8 nunca pasan de 16— y por eso el
DUT fuerza `ovf` a 0 en toda multiplicación: `assign ovf = es_mult ? 1'b0 :
ovf_1c;`. El bin se llama `mul_max` y no `mul_ovf` justamente por eso: el caso
vale por ser el máximo del espacio de entrada, no por desbordar. La única
operación que desborda es la resta, y sólo cuando A < B.
La honestidad de esta slide es parte del curso, así que conviene decirla y no
pasarla rápido: el 86,8 % que reporta el ejemplo **no es** el número que daría
Questa. Verilator ignora el filtro y mide el cross entero, y además le suma un
valor que el enum no tiene: donde el LRM cuenta 45, Verilator cuenta **54** (los
9 de más son el `3'b110` cruzado, y son los 9 que quedan en cero). Por eso el
porcentaje sale más bajo, y por un motivo que no es del testbench. Está
escrito, fechado y con versión en `docs/verilator.md`.
La pregunta útil para el aula: ¿eso invalida el ejercicio? No. Lo que se aprende
—escribir el cross, filtrarlo, y saber qué bin corresponde a qué fila del plan—
es idéntico. Lo único que no se puede hacer con esta herramienta es firmar el
cierre de cobertura, y ése no es el objetivo del curso.

---

## Cobertura funcional

#### *Bins de transición: cuando importa el orden*

```systemverilog
bins opn_rst[] = ([add_op:mul_op] => rst_op);   // A y despues B
bins sngl_mul[] = ([add_op:xor_op], no_op => mul_op);
bins twoops[]  = ([add_op:mul_op] [* 2]);       // dos veces seguidas
bins manymult  = (mul_op [* 3:5]);              // entre 3 y 5 veces seguidas
```

- Tres filas del plan no son valores, son **secuencias**: "después
  de un reset", "una mult después de una de un ciclo"
- Verilator 5.052 todavía **no los compila** (Internal Error). En el código
  están entre `` `ifndef VERILATOR ``: son parte del tema y se leen igual
- Repro mínimo en `code/verilator/repro-cg-transition.sv`. El día que Verilator
  los soporte, se borra el `ifndef` y nada más

Note:
Es el único lugar del curso donde la herramienta libre no llega, y conviene
decirlo de frente en vez de esconderlo: el concepto es del lenguaje, no del
simulador, y en Questa o VCS estos bins corren.
Hay dos primos más que vale nombrar: `[-> n]` (goto, n veces no necesariamente
seguidas) y `[= n]` (non-consecutive). Están en `coverage.svh` de los analysis ports.

---

## Cobertura funcional

#### *Las perillas: cuándo un bin cuenta como cubierto*

```systemverilog
coverpoint op_set {
   option.at_least = 10;                  // un bin cuenta recien con 10 hits
   bins single[] = {[add_op:xor_op]};
}
coverpoint A { option.auto_bin_max = 8; } // 8 casilleros automaticos, no 64
```

- **`option.at_least`** es la que más importa: por defecto vale **1**, así que un
  bin que pasó **una sola vez** ya figura cubierto. El caso borde que salió una
  vez en mil corridas no está verificado, y el 100 % dice que sí
- **`option.auto_bin_max`** acota los bins automáticos. Sin `{ }` y sin esta
  perilla, un coverpoint de 8 bits no da 256 casilleros: da **64**, repartidos
  por la herramienta y no por la spec
- **`option.weight`** cambia cuánto pesa un coverpoint en el total, y
  **`type_option.merge_instances`** suma todas las instancias en un solo número
  en vez de reportarlas por separado
- Verilator 5.052 respeta `auto_bin_max`, y `at_least` **sólo escrito en el
  coverpoint**: en el covergroup lo ignora sin avisar. Está en `docs/verilator.md`

Note:
Ésta es la slide que le pone un asterisco a todos los porcentajes de la unidad, y
por eso llega recién ahora: `at_least = 1` quiere decir que la herramienta te
dice **cubierto** con un solo hit. Para un bin que representa un valor de un enum
está perfecto —o pasó o no pasó—. Para el bin que representa el producto máximo
del multiplicador, un hit es una anécdota, no una verificación.
La regla de campo, y conviene darla porque la pregunta viene sola: `at_least`
alto en los bins que representan un caso raro, default en los que representan un
valor. Subirlo para todo el covergroup no es rigor, es una regresión que no
cierra nunca y un número que nadie mira.
`auto_bin_max` es la contracara de la trampa de los corchetes, la de la slide de
los bins. Ahí el problema era un bin de más; acá es al revés: si el coverpoint es
un `int` y no le escribís bins, la herramienta inventa 64 rangos que no
corresponden a ninguna fila del plan. El número que sale es real y no significa
nada.
Y la honestidad de siempre: las cuatro perillas son del LRM, no de Verilator. Lo
que esta herramienta hace con cada una está medido, fechado y con repro en
`code/verilator/repro-cg-options.sv`. La de `at_least` es la peor de las cuatro
porque es muda: en el covergroup se escribe, compila, y no hace nada.

---

## Cobertura funcional

#### *Leer el número*

```sh
$ make u2/convencional
Coverage Summary:
  covergroup : 86.8% (66/76)
```

- 66 de 76 bins llenos, con **1000 randomizaciones** y **615 operaciones al bus**
  —el `no_op` y el `rst_op` se sortean y no se envían, y el testbench lo imprime
  justo antes del reporte de Verilator—. Las otras filas salen `0/0`:
  `--coverage-user` deja afuera la cobertura de código
- Los 10 que faltan son **un solo valor**: `all_ops.auto_5` y sus nueve cruces.
  Es `3'b110`, que el enum **no tiene** — Verilator reparte los bins
  automáticos por el tipo de base, `bit [2:0]`, y no por miembro del enum
- O sea que ninguna fila del plan quedó sin cubrir, y en Questa esto da 100 %.
  El número no es la meta: la pregunta que sirve es **cuál** bin falta, y eso
  sólo lo dice el reporte por bin, `obj_dir/top/coverage.dat`
- Correr → mirar qué falta → escribir el test dirigido → volver a correr. Eso se
  llama *coverage closure*, y es a lo que un verificador le dedica el día

Note:
Acá es donde conviene correrlo en vivo y abrir el `coverage.dat`: el alumno
tiene que ver que los diez ceros tienen el mismo nombre, y que ese nombre no
está en el `operation_t`. La lección es leer el reporte y no el número: el
número dice 86,8 % y el reporte dice "no falta nada, la herramienta inventó un
casillero". En una herramienta comercial el bin automático de un enum es uno
por miembro (IEEE 1800, 19.5) y esto da 100 % de entrada; está anotado en
`docs/verilator.md`.
Y el remate: el ejercicio del día usa justamente `3'b110` para el shift, así
que la operación nueva llena el casillero fantasma y la cobertura pasa de
86,8 % a 100 % — 77 de 77, con el bin propio del shift sumado. El que la sube
es el mismo que escribió el test, y el corrector cuenta bins y no porcentaje,
porque el porcentaje ya vimos que no sabe leer.

---

## Cobertura funcional

#### *El plan de verificación, entero y en una tabla*

| # | Feature | Escenario | Estímulo | Chequeo | Medida |
|:--:| --- | --- | --- | --- | --- |
| 1 | ALU | las seis operaciones | random | scoreboard | `coverpoint op_set` |
| 2 | ALU | operandos en `00` y en `FF` | `dist` sesgado a los bordes | scoreboard | cross `op_00_FF` |
| 3 | mult | producto máximo: `FF` × `FF` | caso dirigido | scoreboard, 16 bits | bin `mul_max` |
| 4 | reset | operar después de un reset | `rst_op` intercalado | scoreboard | bin `rst_op => op` |
| 5 | mult | una mult después de una de un ciclo | random | scoreboard | bin de transición |
| 6 | ALU | la misma operación dos veces seguidas | random | scoreboard | bin `[* 2]` |
| 7 | sub | restar de menos: `A < B`, y el `ovf` sube | random | scoreboard, **dos salidas** | bin `hubo_borrow` |
| 8 | sub | `A == B`: el resultado es 0 y el `ovf` **no** sube | random | scoreboard, dos salidas | bin `sub_00`/`sub_FF` |
| 9 | ovf | `ovf` no se levanta para ninguna otra operación | random | assertion | `c_ovf` |
| 10 | protocolo | los operandos no se tocan con `start` arriba | random | assertion | `cover property` |
| 11 | protocolo | `done` llega, y antes de 5 ciclos | random | assertion | `cover property` |
| 12 | protocolo | `no_op` es la única que no contesta | random | assertion | `cover property` |

- Las tres columnas de la derecha son **las tres partes del testbench** de esta
  sección. Lo que las ata es el plan, y hasta ahora no lo habías visto junto
- Las dos filas de la resta son las que obligan al scoreboard a mirar **dos
  salidas**: si sólo compara `result`, pasa en verde con el `ovf` clavado en cero
- Las **cuatro últimas** no las chequea ningún scoreboard: son reglas de `ovf` y
  de **protocolo**, y se chequean donde ocurren —las assertions
- Las doce filas van numeradas igual que en **`docs/plan-de-verificacion.md`**,
  que además dice en qué archivo vive cada una y trae la plantilla del capstone

Note:
Ésta es la slide que contesta *"¿y esto para qué?"* del resto del día 1, y
conviene decir de frente por qué llega recién ahora: las tres columnas de la
derecha son estímulo, self-checking y cobertura — las tres partes que la unidad
anterior mostró **sueltas**. El plan es la tabla que las hace una sola cosa.
La fila que más discusión da es la del producto máximo, y está buena: `FF` × `FF`
es el caso que un test **corto** no llena, y por eso su columna de estímulo dice
*caso dirigido*: el plan se decide antes de saber cuánto va a correr el random.
Ahí se ve que el plan no sólo mide, y también decide qué test hay que escribir.
Es el ejercicio `d5c`, el último de la tarde del día 5, con esta misma fila.
Las tres filas de protocolo conviene nombrarlas y seguir: son la mitad que el
curso no toca hasta el día 7, y sirven para dejar sembrado que un scoreboard no
chequea todo. Un plan de verificación serio tiene las dos columnas.
Y el uso que se lleva el alumno: `docs/plan-de-verificacion.md` es la misma tabla
como artefacto, con una plantilla vacía. El capstone del día 7 se entrega con el
plan lleno — que es exactamente lo que se entrega en un proyecto.

---

## Cobertura funcional

#### *Resumen de la unidad*

- **Cobertura de código ≠ cobertura funcional.** La primera mide qué RTL se
  ejecutó; la segunda, qué escenarios de la spec pasaron
- Un `covergroup` es un **tipo**: hay que instanciarlo con `new()` y **alguien
  tiene que llamar a `sample()`**. Sin eso el reporte da 0 % sin una advertencia
- Los **bins** son los casilleros. `[]` reparte uno por valor; sin corchetes,
  todo el rango entra en uno solo
- **`ignore_bins` es documentación ejecutable**: dice en voz alta qué no se
  cubre y por qué. Un bin imposible que dejás puesto te clava el número abajo
- Un **`cross`** es el producto cartesiano y crece rapidísimo: sin acotarlo, la
  cobertura no cierra nunca
- **`option.at_least` vale 1 por defecto**: un bin que pasó una sola vez ya
  figura cubierto, y un caso raro con un hit no está verificado
- El número no es la meta. La meta es el **plan**; la cobertura sólo dice cuánto
  del plan se cumplió

Note:
Cierre del concepto que más se malinterpreta del curso. La frase para llevarse:
**la cobertura no te dice que el diseño está bien, te dice que lo probaste**.
Un DUT al que le falta una feature entera da 100 % de cobertura de código y 0 %
de la funcional que nadie escribió.
Y el error operativo que más se repite, para dejarlo grabado: el `sample()` que
falta. Compila, corre, y el reporte da cero.
