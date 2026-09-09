## El testbench convencional

#### *Coverage First Methodology*

- Definimos qué queremos cubrir y luego creamos el TB
- El objetivo es testear toda la funcionalidad de la ALU y  
  simular *TODAS* las líneas del código RTL
- El TB tiene 3 partes: stimulus, self-checking y coverage

Note:
El orden importa: primero el plan de cobertura, después el testbench. Si
escribís el TB primero, terminás midiendo lo que el TB hace en vez de lo que la
spec pide. Los seis bullets de la slide siguiente son el plan de verificación
del VTALU entero: leerlos de a uno y preguntar cuál falta.

---

## El testbench convencional

#### *El plan de verificación del VTALU*

- Testear todas las operaciones
- Casos Border: entradas todas en 0/1 para todas las operaciones
- Ejecutar todas las ops luego de un reset
- Ejecutar una multiplicación luego de una single cycle op y viceversa
- Simular todas las operaciones ejecutadas 2 veces seguidas
- **Restar de menos** —`A < B`— y ver que el `ovf` sube

- Seis frases en castellano. Toda la sección es traducirlas a código: el
  **estímulo** las produce, el **covergroup** las cuenta, el **scoreboard** dice
  si el resultado estuvo bien

Note:
Vale leer los seis puntos de a uno y preguntar cuál falta. La respuesta que
suele aparecer —"probar valores intermedios"— es buena para discutir por qué no
está: 256×256×5 combinaciones no se simulan, y ahí es donde entra el random.
El plan escrito antes que el testbench es la disciplina entera de la unidad. Si
lo escribís después, terminás describiendo lo que el testbench ya hace.
Los seis puntos vuelven en la sección siguiente convertidos en bins, uno por
uno. Conviene avisarlo ahora para que nadie los lea como decoración.
El último es el que trae el tema del día: el DUT tiene DOS salidas, y una fila
del plan que sólo se cierra mirando las dos. Un scoreboard que compara `result`
y nada más pasa en verde con el `ovf` clavado en cero.

---

## El testbench convencional

#### *El estímulo: mil operaciones, y el protocolo a mano*

{{code:code/u2/convencional/vtalu_tb.sv|lines=186-216}}

- Mil vueltas: elegir operación, elegir operandos, levantar `start`, esperar
  `done`, bajar `start`
- El `case` está ahí por la letra chica de la spec: `no_op` no levanta
  `done`, `rst_op` pulsa `reset_n`, y las demás esperan
- `get_op()` y `get_data()` sesgan el random hacia los bordes —00 y FF— para
  llegar a los casos que el plan pide. Es *constrained random* escrito a mano
- Fijate quién sabe del protocolo acá: **el tester**. En interfaces y BFM eso se muda
  a la BFM y esta task se achica a una línea

Note:
Ésta es la slide del "antes" de todo el curso: el estímulo y el protocolo mezclados
en el mismo bucle. Vale marcarlo con el dedo, porque las próximas cinco unidades
son separaciones sucesivas de estas treinta líneas.
El `wait(done)` del `default` es el que se cuelga si el DUT no responde, y es el
lugar donde el alumno va a terminar la primera vez que rompa algo. La red de
seguridad es `VLT_TRACE=1` y las ondas.
El sesgo de `get_data()` —un cuarto en 00, un cuarto en FF, la mitad en el
medio— es exactamente lo que las transactions van a escribir en una línea con `dist`
y `:/`. Conviene nombrarlo ahora para que después se vea el ahorro.

---

## El testbench convencional

#### *El self-checking: predecir y comparar*

{{code:code/u2/convencional/vtalu_tb.sv|lines=165-181}}

- Un `always @(posedge done)`: cada vez que el DUT dice que terminó, el
  scoreboard predice el resultado y lo compara
- El `#1` no es un adorno: sin él se leen las señales en el mismo instante en que
  `done` sube y se puede comer una carrera de deltas
- `no_op` y `rst_op` se descartan porque no producen resultado. Olvidarse de ese
  `if` hace fallar todo el test sin que el DUT tenga nada
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

#### *Resumen de la unidad*

- El orden es **cobertura primero**: se escribe qué hay que cubrir, y recién
  después el testbench que lo cubre
- El plan de verificación del VTALU son **seis frases en castellano**. Todo el
  día 1 es traducirlas a código
- Un testbench tiene **tres partes**, y en esta sección las tres están sueltas:
  estímulo, self-checking y cobertura
- El estímulo **sesga el random hacia los bordes** —`00` y `FF`— porque el azar
  uniforme casi nunca los visita
- El `#1` antes de leer las señales no es adorno: sin él se lee en el mismo
  instante en que el DUT escribe, y el resultado es indefinido
- Y lo que hay que mirar para la sección que sigue: **el tester sabe del
  protocolo**. Mueve `start` y espera `done` con la mano

Note:
El último bullet es el que ordena el día: este testbench funciona y está mal
repartido. Tres archivos distintos saben cómo se menea `start`, y el día que
cambie el protocolo hay que tocar los tres.
Ésa es toda la motivación de interfaces y BFM, y conviene dejarla como pregunta
abierta en vez de contestarla acá.
