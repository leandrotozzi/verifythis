# El plan de verificación

El entregable más profesional de la disciplina, y el más barato de escribir: una
tabla. Se escribe **antes** que el testbench —si se escribe después, describe lo
que el testbench ya hace en vez de lo que la spec pide— y se llena a medida que
el testbench crece.

Este archivo es tres cosas: qué son las cinco columnas, el plan del **VTALU**
lleno con el archivo donde vive cada fila, y una **plantilla vacía** para copiar
y llenar en el capstone del día 7.

## Las cinco columnas

| Columna | La pregunta que contesta | Qué **no** va |
|---|---|---|
| **Feature** | ¿de qué parte de la spec sale esta fila? | el nombre de un archivo del testbench |
| **Escenario** | ¿qué situación concreta hay que provocar? | *"probar la ALU"* — eso no es un escenario |
| **Estímulo** | ¿quién la provoca: el random o un caso dirigido? | *"a mano"* |
| **Chequeo** | ¿quién dice que estuvo bien? | *"se mira la onda"* |
| **Medida** | ¿qué bin o qué `cover` se llena cuando pasa? | *"se ve en el log"* |

Tres reglas que salen de esas columnas:

1. **Una fila por escenario, no por feature.** Una feature con tres casos borde
   son tres filas, y se cierran de a una.
2. **Si la columna de chequeo dice *"a ojo"*, el escenario no está verificado.**
   Está *simulado*, que es otra cosa. La diferencia es quién se entera cuando
   falla a las tres de la mañana en la regresión.
3. **Si la columna de medida está vacía, nadie va a saber que el escenario
   nunca pasó.** Un caso que el random no llegó a tocar y que no tiene bin es
   indistinguible de uno que pasó mil veces.

Y una distinción que el curso hace en el día 7 y que ordena la columna de
chequeo: **el scoreboard chequea *qué* calcula el DUT; las assertions chequean
*cómo* se habla con él.** Un plan serio tiene las dos.

## El plan del VTALU, lleno

Las doce filas del curso, con el archivo donde vive cada una. La columna de
chequeo dice *scoreboard* o *assertion* según de qué mitad sea la fila.

| # | Feature | Escenario | Estímulo | Chequeo | Medida | Dónde vive |
|:--:|---|---|---|---|---|---|
| 1 | ALU | las seis operaciones | random | scoreboard | `coverpoint op_set`, un bin por op | `u7/sequences/tb_classes/coverage.svh` |
| 2 | ALU | operandos en `00` y en `FF` | `dist` sesgado a los bordes | scoreboard | cross `op_00_FF` | `u7/sequences/tb_classes/command_transaction.svh` · `coverage.svh` |
| 3 | mult | producto máximo: `FF` × `FF` | **caso dirigido** | scoreboard, 16 bits | bin `mul_max` del cross | `u7/sequences/tb_classes/maxmult_sequence.svh` |
| 4 | reset | operar después de un reset | `rst_op` intercalado | scoreboard | bin de transición `rst_op => op` | `u7/sequences/tb_classes/reset_sequence.svh` |
| 5 | mult | una mult después de una de un ciclo | random | scoreboard | bin de transición `sngl_mul` | `u7/sequences/tb_classes/coverage.svh` |
| 6 | ALU | la misma operación dos veces seguidas | random | scoreboard | bin de repetición `twoops` `[* 2]` | `u7/sequences/tb_classes/coverage.svh` |
| 7 | sub | restar de menos: `A < B`, y el `ovf` sube | random | scoreboard, **dos salidas** | bin `hubo_borrow` | `u7/sequences/tb_classes/coverage.svh` |
| 8 | sub | `A == B`: el resultado es 0 y el `ovf` **no** sube | random | scoreboard, dos salidas | bin `sub_00`/`sub_FF` del cross | `u7/sequences/tb_classes/coverage.svh` |
| 9 | ovf | `ovf` no se levanta para ninguna otra operación | random | assertion `a_ovf_solo_en_sub` | `c_ovf`, `c_sub_sin_borrow` | `u8/assertions/vtalu_bfm.sv` |
| 10 | protocolo | los operandos no se tocan con `start` arriba | random | assertion `a_operandos_estables` | `cover property` | `u8/assertions/vtalu_bfm.sv` |
| 11 | protocolo | `done` llega, y antes de 5 ciclos | random | assertion `a_done_llega` | `c_mult_4ciclos`, `c_un_ciclo` | `u8/assertions/vtalu_bfm.sv` |
| 12 | protocolo | `no_op` es la única que no contesta | random | assertion `a_no_op_sin_done` | `cover property` | `u8/assertions/vtalu_bfm.sv` |

Seis cosas que esta tabla dice y que ninguna slide suelta dice:

- **La fila 3 es la única con estímulo dirigido**, y no es un capricho: `FF` × `FF`
  es una combinación entre 65 536 y el random no la visita en mil operaciones.
  El plan es lo que hace evidente **qué test hay que escribir**, y es exactamente
  el ejercicio [`d6-bins`](../code/ejercicios/d6-bins/), que cierra esta fila.
  Y ojo con el nombre: es el **producto máximo**, no un desborde. `FF` × `FF` da
  `FE01`, que entra exacto en los 16 bits de `result` —8 bits por 8 nunca pasan
  de 16—, y el DUT fuerza `ovf` a 0 en toda multiplicación. Por eso el bin se
  llama `mul_max`. El que desborda es el de la resta, y son las filas 7 y 8.
- **Las filas 4, 5 y 6 no se miden con Verilator.** Son bins de transición, y
  5.052 todavía no los compila: en el código están entre `` `ifndef VERILATOR ``.
  La fila queda igual —el escenario existe— con la limitación anotada. Ver
  [`verilator.md`](verilator.md).
- **Las filas 7 y 8 son la razón por la que el scoreboard mira DOS salidas.**
  `result` solo no alcanza: una resta que da bien con el `ovf` clavado en 0
  pasa el chequeo y está mal. Es la fila que obliga a que `result_transaction`
  tenga dos campos y no uno.
- **La fila 9 es de assertion y no de scoreboard, y la diferencia importa.** El
  scoreboard chequea el `ovf` de las operaciones que *ocurrieron*; la assertion
  chequea que no aparezca donde no corresponde. Son dos preguntas distintas
  sobre la misma señal.
- **Las filas 10, 11 y 12 no tienen scoreboard y no es un olvido.** Son reglas
  del protocolo: el scoreboard no las ve porque el resultado sale bien igual. Es
  el bug ciego de las assertions y del ejercicio
  [`d7-sva`](../code/ejercicios/d7-sva/).
- **La fila 11 tiene un cover que nunca se llena a propósito**: `c_mult_3ciclos`
  se queda en 0 porque la multiplicación "de tres ciclos" tarda cuatro flancos.
  Un cover en cero es información, no una falla.

## La plantilla, para el capstone

El capstone del día 7 —[`code/ejercicios/d7-final`](../code/ejercicios/d7-final/)—
se entrega con su plan lleno, que es exactamente lo que se entrega en un
proyecto. El del `apb_regs` ya está escrito, al final de su `spec.md`, y tiene
las mismas cinco columnas: **copiá esa tabla y agregale las filas que te falten**
a medida que encontrás letra chica.

```markdown
| # | Feature | Escenario | Estímulo | Chequeo | Medida |
|:--:|---|---|---|---|---|
| 1 |  |  |  |  |  |
| 2 |  |  |  |  |  |
```

Cómo se llena, en el orden que rinde:

1. **Leé la spec y escribí una fila por cada frase que empiece con "cuando".**
   Todavía sin pensar en el testbench: la columna de escenario sale de la spec,
   no del código.
2. **Marcá cuáles no van a salir del random.** Ésas son tus casos dirigidos, y
   son pocos — si son muchos, el random está mal sesgado.
3. **Completá la columna de chequeo.** Si una fila no tiene quién la chequee, o
   te falta una predicción en el scoreboard, o es una regla de protocolo y va
   una assertion.
4. **Completá la columna de medida al final**, y ahí escribí el `covergroup`.
   Sale copiado de esa columna: un bin por fila.
5. **Corré, mirá qué bin quedó en cero, y volvé al punto 2.** Eso es *coverage
   closure*, y es a lo que un verificador le dedica el día.

Un plan lleno, con las cinco columnas y los bins que se cierran, es algo que se
puede mostrar en una entrevista. Un testbench sin plan es un montón de tests que
alguien va a tener que leer para saber qué prueban.
