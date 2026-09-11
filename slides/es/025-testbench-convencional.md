## El testbench convencional

#### *El plan del VTALU, con tres columnas por llenar*

| Feature | Escenario | Estímulo | Chequeo | Medida |
| --- | --- | --- | --- | --- |
| ALU | las seis operaciones | | | |
| ALU | operandos en `00` y en `FF` | | | |
| reset | operar después de un reset | | | |
| mult | una mult después de una de un ciclo | | | |
| ALU | la misma operación dos veces seguidas | | | |
| sub | restar de menos: `A < B`, y el `ovf` sube | | | |

- Seis filas que salen de la spec, y todavía ninguna columna de la derecha.
  Esta sección llena **dos**: el estímulo las provoca y el scoreboard dice si
  el resultado estuvo bien
- La tercera —**qué bin se llena cuando pasa**— es la sección que sigue
- El testbench tiene tres partes porque el plan tiene tres columnas por llenar

Note:
El orden importa y es el de la unidad anterior: primero el plan, después el
testbench. Si escribís el testbench primero, terminás midiendo lo que el
testbench hace en vez de lo que la spec pide.
Vale leer las seis filas de a una y preguntar cuál falta. La respuesta que
suele aparecer —"probar valores intermedios"— es buena para discutir por qué
no está: 256 × 256 × 5 combinaciones no se simulan, y ahí es donde entra el
random.
La última es la que trae el tema del día: el DUT tiene DOS salidas, y una fila
del plan que sólo se cierra mirando las dos. Un scoreboard que compara
`result` y nada más pasa en verde con el `ovf` clavado en cero.
La tabla vuelve dos veces: en cobertura funcional con la columna de medida
llena, fila por fila, y al final de esa sección entera, con las doce filas y
las tres columnas. Conviene avisarlo ahora para que nadie la lea como
decoración: es la misma tabla, llenándose.

---

## El testbench convencional

#### *El estímulo: mil operaciones, y el protocolo a mano*

{{code:code/u2/convencional/vtalu_tb.sv#stimulus-loop}}

- Mil vueltas: elegir operación, elegir operandos, levantar `start`, esperar
  **un flanco con `done` arriba**, bajar `start`
- El `case` está ahí por la letra chica de la spec: `no_op` no levanta
  `done`, `rst_op` pulsa `reset_n`, y las demás esperan
- `get_op()` y `get_data()` sesgan el random hacia los bordes —00 y FF— para
  llegar a los casos que el plan pide. Es *constrained random* escrito a mano
- `enviadas` se cuenta acá y `chequeadas` en el scoreboard, y un `final` exige
  que sean iguales: es el testbench chequeándose a sí mismo
- Fijate quién sabe del protocolo acá: **el tester**. En interfaces y BFM eso se muda
  a la BFM y en el cuerpo del `repeat` se achica a una línea

Note:
Ésta es la slide del "antes" de todo el curso: el estímulo y el protocolo mezclados
en el mismo bucle. Vale marcarlo con el dedo, porque las próximas cinco unidades
son separaciones sucesivas de estas treinta líneas.
El `do … while (done == 0)` del `default` es el que se cuelga si el DUT no
responde, y es el lugar donde el alumno va a terminar la primera vez que rompa
algo. La red de seguridad es `VLT_TRACE=1` y las ondas.
Y por qué no es un `wait(done)`, que es lo primero que uno escribe: en las
operaciones de un ciclo `done` es un nivel, y en el `negedge` en que el tester
carga la operación siguiente **todavía está arriba por la anterior**. El
`wait(done)` no bloquea, `start` baja en el mismo instante y el DUT nunca ve esa
operación. No hay error: el scoreboard no dispara, y la cobertura —que muestrea
`op_set`— la cuenta igual. Este testbench la tuvo, y descartaba cuatro de cada diez
operaciones de un ciclo con el reporte en verde: en `d1`, 77 shifts chequeados
contra 130 con el arreglo. La atrapa el contador de
enviadas contra chequeadas, y es la trampa muda más barata de poner.
El sesgo de `get_data()` —un cuarto en 00, un cuarto en FF, la mitad en el
medio— es exactamente lo que las transactions van a escribir en una línea con `dist`
y `:/`. Conviene nombrarlo ahora para que después se vea el ahorro.

---

## El testbench convencional

#### *El self-checking: predecir y comparar*

{{code:code/u2/convencional/vtalu_tb.sv#scoreboard-block}}

- Un `always @(posedge done)`: cada vez que el DUT dice que terminó, el
  scoreboard predice el resultado y lo compara
- El `#1` no es un adorno: sin él se leen las señales en el mismo instante en que
  `done` sube y se puede comer una carrera de deltas
- `no_op` y `rst_op` no levantan `done`, así que este bloque no debería correr
  con ellas. El `if` es defensivo —sin predicción para esas dos compararía
  basura— y adentro va `chequeadas++`, la otra mitad del contador
- El covergroup —la tercera pata— es la sección que sigue

Note:
El modelo de referencia son cuatro líneas de `case` porque el DUT es una ALU. En
un proyecto de verdad puede ser un modelo en C o el RTL de la generación
anterior, pero la forma es siempre ésta: **predecir con algo que no sea el DUT, y
comparar**.
Que el scoreboard lea `A`, `B` y `op_set` del cable en el momento del resultado
funciona sólo porque el protocolo obliga a mantenerlos estables. Es frágil, y en
los analysis ports se va a reemplazar por una cola de comandos que manda el monitor.
Y el `$error` de acá va a ser un `` `uvm_error `` desde reporting: mismo
concepto, con un contador y una política de severidad detrás.

---

## El testbench convencional

#### *¿Cómo sabés que el scoreboard chequea algo?*

{{code:code/u2/convencional/mutante.txt}}

- Mil operaciones y ningún error. Ahora **el mismo testbench con el DUT roto a
  propósito**: `VTALU_BUG=1 bash run.sh` da vuelta el bit 0 del resultado
- Falla en la primera comparación. Eso —y no el `PASS` de antes— es lo que
  prueba que el scoreboard mira el resultado
- Un scoreboard que **nunca vio un error** no está probado: pudo haber comparado
  contra sí mismo, o no haber comparado nada
- `make mutante` hace esto con los tres testbenches de los días 1 y 2, y falla
  si alguno **no** falla. Es la primera respuesta a la pregunta del día

Note:
Correrlo en vivo, que son segundos porque no hay UVM: primero `bash run.sh`
—mil operaciones, silencio, y el resumen de cobertura—, y después
`VTALU_BUG=1 bash run.sh`, que termina en la línea de la slide y un `$stop`.
Lo que hay que decir con todas las letras es qué prueba esa línea y qué no. Prueba
que el scoreboard compara el bit que el bug tocó. No prueba que compare `ovf`:
un bug que sólo tocara `ovf` es otra corrida, y por eso el plan tiene una fila
para cada salida.
Ésta es la respuesta corta a la primera slide del día: la regresión que dijo
`PASS` y mandó el bug a fabricar nunca había visto un `FAILED`. No sabía si
chequeaba. Un `PASS` no dice nada hasta que sabés qué habría dicho `FAILED`.
Y no es un truco del día 1: es la práctica que atraviesa el curso. `+BUG=1` en
el capstone del día 7 y `+GOLDEN_BUG` en el modelo de referencia del día 8 son
esto mismo, y los correctores de los ejercicios lo exigen.

---

## El testbench convencional

#### *Resumen de la unidad*

- El testbench tiene **tres partes** porque el plan tiene tres columnas por
  llenar: estímulo, self-checking y medida. Hoy están sueltas en un archivo
- El estímulo **sesga el random hacia los bordes** —`00` y `FF`— porque el azar
  uniforme casi nunca los visita
- El `#1` antes de leer las señales no es adorno: sin él se lee en el mismo
  instante en que el DUT escribe, y el resultado es indefinido
- Un `PASS` no prueba nada hasta que viste el `FAILED`: **`VTALU_BUG=1`** es la
  forma de verlo, y `make mutante` la de no olvidarse
- Y lo que hay que mirar para interfaces y BFM: **el tester sabe del
  protocolo**. Mueve `start` y espera `done` con la mano

Note:
El último bullet es el que ordena el resto del día: este testbench funciona,
está probado, y está mal repartido. El tester sabe cómo se menea `start` y el
scoreboard sabe cuándo leer `done`: el protocolo vive en dos lugares del mismo
archivo, y el día que cambie hay que tocar los dos.
Ésa es toda la motivación de interfaces y BFM, y conviene dejarla como pregunta
abierta en vez de contestarla acá. Antes, la sección que sigue llena la tercera
columna.
