## La spec del VTALU

![ALU waveform](res/diagrams/wave-dut.svg)
<!-- .element: class="grande" -->

- *start* debe permanecer en 1 y los operandos estables hasta  
  que termina la operación
- *done* se levanta cuando termina la operación: en la multiplicación  
  es un pulso de un ciclo; en add/sub/and/xor es un **nivel**, y se queda  
  arriba mientras *start* siga arriba
- *reset_n* es asíncrono y activo bajo; el diagrama arranca con el DUT  
  ya fuera de reset
- *ovf* sale junto con *done*, y es el **borrow de la resta**: vale 1  
  cuando `A < B`. Para las otras operaciones vale siempre 0

Note:
El protocolo es todo lo que hay que respetar: start arriba y operandos estables
hasta done. Ojo con la letra chica: done es un pulso en la multiplicación (se
apaga solo) y un nivel en add/sub/and/xor, donde vale `start && (op != no_op)`. Es
la clase de detalle que aparece recién cuando el testbench se cuelga y nadie
sabe por qué.

---

## La spec del VTALU

| Operation | Opcode | Ciclos | `ovf` |
| --- | --- | :--: | --- |
| no_op | 3'b000 | — | 0 |
| add_op | 3'b001 | 1 | 0 |
| sub_op | 3'b010 | 1 | **`A < B`** |
| and_op | 3'b011 | 1 | 0 |
| xor_op | 3'b100 | 1 | 0 |
| mul_op | 3'b101 | 4 | 0 |
| *libre* | 3'b110 | — | — |
| rst_op | 3'b111 | — | — |

- **Ciclos** cuenta flancos de `clk` con `start` arriba, hasta el que levanta
  `done` inclusive: uno en las de un ciclo, cuatro en la multiplicación. El
  plan y las assertions del día 7 cuentan igual
- `rst_op` no lo decodifica el RTL — el DUT lo ve como *unused*.
  Es la convención del testbench para pulsar `reset_n`, y por eso
  está en el `operation_t` del testbench
- **`3'b110` está libre a propósito**: es el ejercicio de hoy

Note:
rst_op es del testbench, no del RTL: el DUT ve 3'b111 como unused. Está en el
enum porque el tester pide el reset como si fuera una operación más, y así el
reset entra en la cobertura funcional. Buen momento para adelantar que el plan
de cobertura incluye "cualquier operación después de un reset".
La columna del ovf es la que más discusión da, y está buena: con operandos de 8
bits y resultado de 16, ni la suma ni la multiplicación pueden desbordar — la
resta sí, y sólo cuando A < B. O sea que hay una salida del DUT que para cinco
de las seis operaciones vale siempre 0. Preguntar en voz alta: ¿cómo se verifica
una señal que casi nunca se mueve? La respuesta es la de mañana, y es un bin.
Y el opcode libre: 3'b110 no está ahí por casualidad ni por olvido. Es el
ejercicio de esta tarde, y conviene decirlo ahora para que nadie lo lea como un
descuido del diseño.

---

## La spec del VTALU

#### *Single Cycle: Add - Sub - AND - XOR*

{{code:code/vtalu_dut/vtalu_1c.sv|lines=20-42}}

- Dos `always_ff` y nada más: uno registra `A op B`, el otro levanta `done`
- Los resets **no son iguales**: el del resultado es **síncrono** —sólo `clk` en
  la lista de sensibilidad—, el del `done` es **asíncrono**
- `done <= start && (op != no_op)`: por eso en estas cuatro operaciones `done` es
  un **nivel** y se queda arriba mientras `start` lo esté

Note:
La asimetría de los dos resets no es un descuido: viene del VHDL original y está
copiada tal cual a propósito. Es exactamente el tipo de detalle que un testbench
tiene que exponer, y por eso el DUT no se "limpió" al traducirlo.
Que `done` sea un nivel acá y un pulso en la multiplicación es la letra chica que
va a colgar al primer testbench del curso. Conviene volver al diagrama de ondas
de la primera slide y señalarlo de nuevo.
El `default: ;` del case es lo que hace que `no_op` y los opcodes sin usar no
cambien el resultado: la ALU se queda con lo último que calculó.

---

## La spec del VTALU

#### *Multi Cycle: Multiplicación*

{{code:code/vtalu_dut/vtalu_mult.sv|lines=32-42}}

- Es un pipeline: los operandos se registran, se multiplican, y el producto
  atraviesa dos registros más antes de salir por `result_mult`: cuatro flancos
- El `done` viaja por **la misma cadena** —`done3`, `done2`, `done1`— así que
  llega exactamente con el dato y no antes
- El `& ~done_mult` de cada etapa es lo que apaga la cadena sola: por eso acá
  `done` es un **pulso de un ciclo**, aunque `start` siga arriba

Note:
La latencia de cuatro flancos es a propósito, y es la razón de ser del testbench convencional:
obliga al testbench a **esperar `done`** en vez de leer el resultado al ciclo
siguiente. Un DUT combinacional no enseñaría nada.
El `& ~done_mult` es sutil y conviene leerlo despacio: sin eso, mientras `start`
estuviera arriba la cadena se recargaría sola y `done` quedaría en 1. Está
copiado del VHDL original tal cual.
La pregunta que ordena la slide: ¿qué pasa si el testbench manda una
multiplicación y lee el resultado al ciclo siguiente? Lee el resultado anterior,
y el scoreboard reporta un error que no está en el DUT.

---

## La spec del VTALU

#### *Top Level*

{{code:code/vtalu_dut/vtalu.sv|lines=30-35}}

- El top no calcula nada: instancia los dos bloques y **decodifica** el opcode
- `es_mult = (op == mul_op)`. El `start` se rutea a uno solo, y `result`,
  `done` y `ovf` salen del mismo lado
- Por eso el protocolo del bus es uno solo aunque adentro haya dos latencias
  distintas: lo que el testbench ve es `start` → `done`

Note:
Que los dos bloques compartan `A`, `B` y `clk` y sólo se separen por el `start`
es lo que hace que el DUT tenga una sola interface. Vale señalarlo porque es la
forma que va a tener la `vtalu_bfm` de interfaces y BFM.
El archivo completo, con las dos instancias y sus conexiones, está en
`code/vtalu_dut/vtalu.sv`. Acá sólo están las cuatro líneas que deciden.
Vale señalar por qué es un decode y no un bit suelto: con un `op[2]` los
opcodes tendrían que quedar en mitades prolijas del espacio, y el diseño
perdería la libertad de asignarlos como convenga. Un decode cuesta una compuerta
y no ata la spec. Y de paso, el opcode libre 3'b110 cae del lado de un ciclo sin
que nadie tenga que hacer nada. El DUT no valida el
opcode; el que lo tiene que atajar es el plan de verificación.

---

## La spec del VTALU

#### *Cómo se corre*

- El DUT vive en `code/vtalu_dut/`, en **SystemVerilog**
- El simulador del curso es **Verilator** (libre, sin licencia):

```sh
make u4/tests          # un ejemplo con UVM:  ~1 min 30 la primera vez
make u4/tests          # la segunda, con ccache:      ~15 segundos
make               # los 38 ejemplos
```

- Los que usan UVM compilan **la librería entera** la primera vez. Instalá
  `ccache` antes de empezar: el curso lo detecta solo y no se recompila dos veces
- Cada ejemplo tiene su `run.sh`; los flags comunes están en
  `code/verilator/common.sh`

Note:
Acá conviene salir del deck y correrlo en vivo. Los números de la slide son
medidos en una laptop de 12 cores. En una máquina de 2 —un Codespaces gratis— la
primera son 4 minutos; la segunda sigue siendo 15 segundos, porque un hit de
ccache es copiar un archivo y eso no depende de cuántos cores tengas. O sea que
lo caro se paga **una vez**.
Lo que hay que explicar es de dónde sale la diferencia entre 1 min 30 y 15
segundos, porque no es magia: Verilator compila cada simulación a un binario
nativo, y para eso genera unos 2300 archivos C++ —casi todos de la librería UVM—.
`ccache` guarda el resultado de cada uno; la segunda vez no vuelve a compilar,
copia. Está en el Dockerfile y en el devcontainer, y afuera alcanza con tenerlo
instalado.
Y el que hay que remarcar igual: Verilator es libre — el alumno se lo lleva a
casa y sigue practicando sin pedirle licencia a nadie.

---

## La spec del VTALU

#### *Ver las ondas de verdad*

- El diagrama de la primera slide está **dibujado**. El de verdad lo generás vos,
  y es la herramienta con la que se hace el 47 % del trabajo: debuggear

```sh
cd code/u2/convencional
VLT_TRACE=1 bash run.sh      # compila con --trace y vuelca vtalu.vcd
gtkwave vtalu.vcd            # o surfer, o el visor que uses
```

- `VLT_TRACE=1` prende dos cosas a la vez: el `--trace` de Verilator y el
  `$dumpfile`/`$dumpvars` del top, que sin el flag no compilaría
- Sale gratis y es libre, igual que el simulador. Cuando el testbench se cuelgue
  en `while (done == 0)`, esto es lo que te va a decir por qué

Note:
Vale la pena abrirlo en vivo una vez, aunque sea treinta segundos: cargar
`op_set`, `start` y `done`, y mostrar el pulso de un ciclo de la multiplicación
al lado del nivel de las de un ciclo. Es la letra chica del protocolo de la
slide 1, pero vista.
Y decirlo explícito: el que hace el curso solo tiene acá su red de seguridad.
Cuando un ejercicio no da, la respuesta casi siempre está en las ondas antes
que en el código.

---

## La spec del VTALU

#### *Resumen de la unidad*

- El **protocolo** es una sola frase, y hay que respetarla: `start` en 1 y los
  operandos estables **hasta que sube `done`**
- La letra chica que va a colgar al primer testbench: `done` es un **pulso** de
  un ciclo en la multiplicación y un **nivel** en las de un ciclo
- Adentro hay **dos bloques** con latencias distintas —uno y cuatro ciclos— y el
  top **decodifica** el opcode. Afuera, el bus es uno solo
- `ovf` es una salida más, y es del `sub_op` y de nadie más
- `rst_op` **no existe para el RTL**: es una convención del testbench para
  pulsar `reset_n`, y por eso entra en la cobertura
- El DUT no valida el opcode: el que está libre no hace nada. Atajarlo es
  trabajo del **plan de verificación**, no del diseño
- Y la herramienta que se usa el 47 % del tiempo ya está instalada:
  `VLT_TRACE=1` y GTKWave

Note:
Cierre de la sección que parece de RTL y en realidad es de verificación. La
pregunta con la que conviene cerrar: ¿cuál de estos siete datos es el que más
caro sale olvidarse? El del `done`, y se va a ver hoy mismo, en el ejercicio de las ondas.
Vale dejar dicho por qué el DUT no se "limpió" al traducirlo del VHDL: la
asimetría de los resets y el opcode sin validar son **exactamente** el tipo de
cosa que un testbench tiene que exponer. Un DUT prolijo no enseña nada.
