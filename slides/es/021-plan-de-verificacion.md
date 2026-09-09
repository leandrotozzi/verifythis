## El plan de verificación

#### *El entregable más profesional de la disciplina, y el más barato*

- Es una **tabla**. Se escribe **antes** que el testbench — si se escribe
  después, describe lo que el testbench ya hace en vez de lo que la spec pide
- Sale de la spec que acabás de leer, no del testbench que todavía no existe
- Y es lo que se entrega: el capstone del día 7 se entrega con el plan lleno,
  que es exactamente lo que se entrega en un proyecto

Note:
Ésta es la slide que ordena el curso entero, y por eso llega antes que la primera
línea de testbench. Todo lo que viene después —el estímulo, el scoreboard, los
covergroups, las assertions— son columnas de esta tabla.
Conviene decirlo de frente: el plan no es burocracia. Es la única respuesta
seria a *"¿ya terminaste de verificar?"*, y es lo primero que pide un líder
técnico cuando pregunta cómo va el bloque.
La plantilla vacía está en `docs/plan-de-verificacion.md`, y se usa dos veces en
el curso: acá para leerla, y el día 7 para llenarla de cero.

---

## El plan de verificación

#### *Las cinco columnas*

| Columna | La pregunta que contesta | Qué **no** va |
|---|---|---|
| **Feature** | ¿de qué parte de la spec sale esta fila? | el nombre de un archivo del testbench |
| **Escenario** | ¿qué situación concreta hay que provocar? | *"probar la ALU"* |
| **Estímulo** | ¿quién la provoca: el random o un caso dirigido? | *"a mano"* |
| **Chequeo** | ¿quién dice que estuvo bien? | *"se mira la onda"* |
| **Medida** | ¿qué bin se llena cuando pasa? | *"se ve en el log"* |

- Una fila por **escenario**, no por feature: una feature con tres casos borde
  son tres filas, y se cierran de a una

Note:
Vale leer la columna de la derecha en voz alta: son los cuatro errores que se
cometen la primera vez, y los cuatro suenan razonables cuando uno los escribe.
La columna que más cuesta es la de medida, porque obliga a decidir *antes* qué
se va a contar. Es la que el día 1 todavía no se puede llenar —los bins no
existen hasta la unidad que viene— y por eso el plan se llena a medida que el
testbench crece.

---

## El plan de verificación

#### *Dos reglas que salen de las columnas*

- **Si la columna de chequeo dice *"a ojo"*, el escenario no está verificado.**
  Está *simulado*, que es otra cosa
- **Si la columna de medida está vacía, nadie se va a enterar de que el
  escenario nunca pasó.** Un caso que el random no tocó y que no tiene bin es
  indistinguible de uno que pasó mil veces
- Y una distinción que ordena la columna de chequeo: **el scoreboard chequea
  *qué* calcula el DUT; las assertions chequean *cómo* se habla con él**

Note:
La diferencia entre verificado y simulado es quién se entera cuando falla a las
tres de la mañana en la regresión. Si el chequeo es un par de ojos, no se entera
nadie: la regresión pasa en verde con el bug adentro.
El tercer bullet es una promesa que el curso cumple el día 7: hasta entonces
todos los chequeos son de scoreboard, y la mitad del protocolo queda sin
chequear. Vale dejarlo dicho ahora para que el día 7 no parezca un agregado.
Un plan serio tiene las dos columnas, y la tabla del VTALU —que se ve entera en
la unidad que viene, ya con los bins— tiene siete filas de scoreboard y tres de
assertion.
