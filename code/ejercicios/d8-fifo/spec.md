# FIFO sincrónica de 8 lugares · especificación

> Este archivo es **la spec**. Es lo único que hay que leer para verificar el
> DUT, y es lo único que hay que creerle. Si algo no está acá, no está
> especificado; si el RTL hace algo que acá no dice, el que está mal es el RTL.

## Para qué sirve

Un buffer entre dos dominios que no van al mismo ritmo: uno escribe, otro lee,
y la FIFO absorbe la diferencia. Cuando no puede absorber más, **avisa** — eso
es *backpressure*, y es la mitad de la spec.

## Pines

| Señal | Dir | Ancho | Qué es |
|---|:--:|:--:|---|
| `clk` | in | 1 | todo pasa en el flanco de **subida** |
| `rst_n` | in | 1 | asincrónico, activo bajo |
| `wr_en` | in | 1 | *"quiero escribir `wr_data` en este ciclo"* |
| `wr_data` | in | 8 | el dato a escribir |
| `rd_en` | in | 1 | *"quiero leer en este ciclo"* |
| `rd_data` | out | 8 | el dato leído |
| `full` | out | 1 | no entra nada más |
| `almost_full` | out | 1 | quedan pocos lugares |
| `empty` | out | 1 | no hay nada para leer |
| `almost_empty` | out | 1 | quedan pocos datos |
| `count` | out | 4 | cuántos datos hay adentro, de 0 a 8 |

## Los tres números

| | Valor | Significa |
|---|:--:|---|
| `DEPTH` | **8** | lugares |
| `AF` | **6** | `almost_full` está en 1 con **6 o más** datos adentro |
| `AE` | **2** | `almost_empty` está en 1 con **2 o menos** datos adentro |

## Cómo se comporta

1. **No hay handshake.** La FIFO atiende siempre: no hay una señal que diga
   *"esperá"*. El que pide tiene que mirar las banderas **antes**.
2. Una escritura entra si hay lugar. Una lectura saca si hay algo.
3. Los datos salen **en el mismo orden** en que entraron. Siempre.
4. Después del reset la FIFO está vacía: `count = 0`, `empty = 1`, `full = 0`.

## La letra chica

Cuatro cosas que están acá, sueltas y sin subrayar, como estarían en una spec
de verdad. Las cuatro cuelgan al primer testbench.

- **Las banderas describen el estado *antes* del flanco.** Son combinacionales
  sobre `count`: lo que ves en un ciclo es la ocupación con la que la FIFO va a
  atender **ese** ciclo, no el resultado de atenderlo.

- **`rd_data` está registrado.** El dato aparece en el ciclo **siguiente** al
  que se pidió la lectura. Un monitor que lo lea en el mismo flanco que `rd_en`
  reporta el dato anterior, y todas las comparaciones se corren en uno.

- **Escribir con la FIFO llena no es un error.** El dato se **descarta en
  silencio**: no hay bandera de overflow, no hay señal de error, y `count` no
  se mueve. Lo mismo al revés: leer con la FIFO vacía no saca nada y `rd_data`
  no cambia.

- **Una escritura y una lectura en el mismo ciclo, con la FIFO llena, entra.**
  La lectura libera el lugar en el mismo flanco. Al revés **no** funciona: leer
  de una FIFO vacía en el mismo ciclo en que se escribe no devuelve ese dato —
  el dato entra por atrás, y la lectura sale por adelante.

## El plan de verificación

Siete filas. Es la tabla que se llena antes de escribir el testbench, y es de
donde sale el `covergroup` — no al revés.

| Feature | Escenario | Estímulo | Chequeo | Medida |
|---|---|---|---|---|
| orden | lo que entra sale en orden | random | scoreboard, cola | `pedido` |
| llenado | llenar hasta `full` y pasarse | dirigido | scoreboard: el dato de más se descarta | cross `escribe_llena` |
| vaciado | vaciar hasta `empty` y pasarse | dirigido | scoreboard: no sale nada | cross `lee_vacia` |
| banderas | `full`, `empty` y las dos *almost* en cada ciclo | random | scoreboard: predicción contra observación | `lleno`, `vacio`, `casi_lleno`, `casi_vacio` |
| `count` | coincide con la ocupación del modelo | random | scoreboard | `ocupacion` |
| simultáneo | leer y escribir en el mismo ciclo | random + dirigido | scoreboard | bin `simultaneo` |
| simultáneo en el borde | leer y escribir con la FIFO llena, y con la vacía | dirigido | scoreboard | cross `pedido_x_ocupacion` |

> La fila de las **banderas** es la que hace distinto a este ejercicio. Un
> scoreboard que sólo compara lo que sale por `rd_data` cierra las otras seis
> filas y deja ésta sin verificar — y es la fila donde vive el bug de `+BUG=1`.
