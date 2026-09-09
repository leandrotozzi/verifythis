# APB_REGS — especificación

Un esclavo **APB3** con cuatro registros de 32 bits. Es todo lo que hay: no hay
testbench, no hay ejemplo del que copiar. Esto es lo que te entregan el lunes.

## Los pines

| Señal | Dir | Ancho | Qué es |
|---|:--:|:--:|---|
| `PCLK` | in | 1 | reloj. Todo es síncrono al **flanco de subida** |
| `PRESETn` | in | 1 | reset **asíncrono**, activo en bajo |
| `PSEL` | in | 1 | el maestro eligió a este esclavo |
| `PENABLE` | in | 1 | segundo ciclo en adelante de la transferencia |
| `PWRITE` | in | 1 | 1 = escritura, 0 = lectura |
| `PADDR` | in | 8 | dirección de byte. `PADDR[1:0]` se ignora |
| `PWDATA` | in | 32 | dato a escribir |
| `PRDATA` | out | 32 | dato leído. Válido en el flanco en que `PREADY` está alto |
| `PREADY` | out | 1 | el esclavo terminó |
| `PSLVERR` | out | 1 | error. Válido junto con `PREADY` |

## El protocolo

Una transferencia son **dos fases**, y ésa es la diferencia con el handshake de
la VTALU:

```
         __    __    __    __    __    __
PCLK   _|  |__|  |__|  |__|  |__|  |__|  |__
        IDLE | SETUP  |    ACCESS    | IDLE
             ______________________
PSEL   _____|                      |________
                   ________________
PENABLE __________|                |_________
             ______________________
PADDR  -----<  dirección válida    >---------
                          _________
PREADY -__________________|        |_________   (lectura: un wait state)
```

- **SETUP** — un ciclo. `PSEL=1`, `PENABLE=0`, y `PADDR` / `PWRITE` / `PWDATA`
  ya válidos.
- **ACCESS** — `PENABLE=1`. Se mantiene hasta que el maestro **muestrea
  `PREADY` alto** en un flanco de subida. Ahí termina la transferencia.
- Las **escrituras no esperan**: `PREADY` está alto desde el primer ciclo de
  ACCESS. Las **lecturas meten un wait state**: `PREADY` sube en el segundo.
- `PRDATA` y `PSLVERR` son válidos **en el flanco en que `PREADY` está alto**, y
  sólo ahí.
- Entre dos transferencias `PSEL` puede quedar alto (*back to back*) o bajar.

## El mapa de registros

| Dir | Nombre | Acceso | Contenido |
|---|---|:--:|---|
| `0x00` | `CTRL` | RW | bit 0 = `EN` · bit 1 = `CLR` |
| `0x04` | `SCRATCH` | RW | 32 bits libres |
| `0x08` | `ACC` | RO | acumulador |
| `0x0C` | `STATUS` | RO | bit 0 = `EN` · bit 1 = `OVF` |

**`CTRL`**
- `EN` es un bit común: se escribe, se lee, y queda.
- `CLR` es **autoclear**: escribir un 1 pone `ACC` y `OVF` en cero **en ese
  mismo flanco**, y el bit siempre se lee **0**. No hay forma de leerlo en 1.

**`SCRATCH`**
- Se escribe y se lee. Y además: **cada escritura a `SCRATCH`, con `EN=1`, suma
  el dato escrito a `ACC`**. Con `EN=0` se escribe `SCRATCH` y `ACC` no se mueve.

**`ACC`** — de sólo lectura. Escribirlo **no hace nada y tampoco da error**: la
transferencia termina normal, con `PSLVERR=0`, y el registro no cambia.

**`STATUS`** — de sólo lectura, misma regla. `OVF` se prende cuando la suma de
`ACC` desborda los 32 bits, y es **pegajoso**: queda en 1 hasta el próximo `CLR`.

## Errores

- Cualquier dirección **de `0x10` para arriba** contesta con `PSLVERR=1`. En una
  lectura, `PRDATA` vale 0.
- Escribir un registro de sólo lectura **no** es un error: `PSLVERR=0`.

## Reset

`PRESETn` es asíncrono y activo en bajo. Después del reset: `EN=0`, `OVF=0`,
`SCRATCH=0`, `ACC=0`.

## La letra chica

Todo lo de arriba está dicho una vez y en una línea. Éstas son las cuatro que
cuelgan al primer testbench, juntas y en un solo lugar — porque en la spec de
verdad no van a estar juntas ni en un solo lugar:

1. La lectura tiene **un wait state**. Un driver que dé por hecho que ACCESS
   dura un ciclo lee `PRDATA` un ciclo antes de tiempo y no falla siempre.
2. `CTRL.CLR` **nunca se lee en 1**. Un scoreboard que prediga *"escribí 2, leo
   2"* falla en la primera lectura de `CTRL`.
3. Escribir `ACC` o `STATUS` **no da error**. Es la trampa al revés: el
   scoreboard que espera `PSLVERR=1` ahí, falla.
4. `ACC` sólo suma con `EN=1`. Modelar el acumulador **sin** modelar `EN` es el
   bug que `+BUG=1` mete a propósito en el DUT.

## El plan de verificación

Lo que hay que cubrir, que es lo que el `covergroup` tiene que medir. Las cinco
columnas son las de siempre — están explicadas, con el plan del VTALU como
ejemplo, en [`docs/plan-de-verificacion.md`](../../../docs/plan-de-verificacion.md):

| # | Feature | Escenario | Estímulo | Chequeo | Medida |
|:--:|---|---|---|---|---|
| 1 | registros | escribir y leer los cuatro | sequence dirigida | scoreboard | cross `addr` × `write` |
| 2 | registros | escribir uno de sólo lectura | random | scoreboard: no cambia, `PSLVERR=0` | bin `acc`/`status` × `wr` |
| 3 | errores | dirección no mapeada | random | scoreboard: `PSLVERR=1` | bin `unmapped` |
| 4 | acumulador | sumar con `EN=1` | random | scoreboard: `ACC` predicho | bin `scratch` × `wr` |
| 5 | acumulador | **no** sumar con `EN=0` | random | scoreboard: `ACC` no se mueve | bin `ctrl` × `wr` |
| 6 | acumulador | desborde de `ACC` | random | scoreboard: `STATUS[1]` | bin `ovf` |
| 7 | control | `CLR` | random | scoreboard: `ACC=0`, `OVF=0` | bin `clr` |
| 8 | protocolo | | | | bin `back_to_back` |
| 9 | direcciones | | | | bin `unaligned` |

Nueve filas, y ninguna dice *"probar el APB"*: una fila es un escenario que se
puede provocar, chequear y medir. Si tu covergroup tiene un bin que no está en
esta tabla, o te falta una fila o te sobra un bin.

**Las filas 8 y 9 vienen vacías, y ésa es la última parte del ejercicio.** Las
dos cosas que miden están prometidas más arriba, cada una en una línea suelta:
*"entre dos transferencias `PSEL` puede quedar alto"* y *"`PADDR[1:0]` se
ignora"*. Ninguna de las siete filas de arriba las mide, y el scoreboard que
decodifica con la dirección entera falla en la primera dirección no alineada.
Completá el escenario, el estímulo y el chequeo. Los nombres de los bins son los
que están puestos, porque el corrector lee la base de cobertura: son contrato,
igual que los nombres de los tests.
