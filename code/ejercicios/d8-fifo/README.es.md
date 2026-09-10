[English](README.md) · **Castellano**

# Capstone 2 · una FIFO con backpressure

> **Esto se hace después del `d7-final`.** No porque sea más difícil de
> escribir —el protocolo es más simple, no hay direcciones ni wait states—
> sino porque el que ya hizo el APB llega acá con un patrón en la cabeza, y
> **el patrón no alcanza.**

```sh
cd code/ejercicios/d8-fifo
cat spec.md
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

## Por qué existe este segundo final

El DUT del capstone del APB es un **esclavo sin memoria útil**: escribís una
dirección, leés esa dirección, y el scoreboard puede ser una tabla de cuatro
filas. Eso es la mayoría de los DUTs que uno se cruza el primer año, y por eso
va primero.

Éste no. Una FIFO no tiene direcciones: tiene **orden** y tiene **ocupación**.
El modelo de referencia es una cola con estado, y las banderas que hay que
predecir dependen de todo lo que pasó antes. No hay tabla que sirva.

La diferencia se ve en una línea del corrector:

```
with +BUG=1 almost_full goes up one place late, and your scoreboard said nothing.
The data still comes out right.
```

Un scoreboard que compara sólo lo que sale por `rd_data` cierra seis de las
siete filas del plan y **pasa en verde con el DUT roto**. Ése es el ejercicio.

## Lo que se da hecho, y no se toca

| Archivo | Qué es |
|---|---|
| `rtl/sync_fifo.sv` | el DUT. Con `+BUG=1` corre `almost_full` un lugar |
| `top.sv` | dos FIFOs: la tuya y la del módulo de siempre |
| `fifo_stim_module.sv` | el módulo de siempre: doce ciclos, sin una línea de UVM |
| `spec.md` | la spec, la letra chica y el plan de verificación |
| `run.sh` | el corrector, por etapas |

## Lo que escribís vos

En este orden, que es el del corrector y el del apéndice *De la VTALU a un bus
real*:

1. **`fifo_if.sv`** — los pines, el reloj, `reset()`, `ciclo()` y el enganche
   del monitor.
2. **`fifo_pkg.sv`** — el package que incluye tus clases, con `DEPTH`, `AF` y
   `AE` escritos **una sola vez**.
3. **`tb_classes/`** — la transaction, el monitor, el driver, el agent, el env,
   el scoreboard, la cobertura, las sequences y los tests.

## Las cuatro etapas

- **1 · El monitor.** Un agent **pasivo** sobre la FIFO del módulo de siempre,
  a ver los doce ciclos con actividad. Sin driver. Ojo con `rd_data`, que llega
  un ciclo tarde.
- **2 · El driver.** Una sequence dirigida que **llene hasta el tope y se pase**,
  y después vacíe y se pase. Los dos bordes en un solo test.
- **3 · El scoreboard.** El modelo de referencia con estado. El corrector lo
  corre dos veces: contra el DUT sano tiene que callarse, y con **`+BUG=1`**
  tiene que gritar.
- **4 · La cobertura.** El `covergroup` con las siete filas del plan: más de
  20 puntos, 90 % cubierto.

Listo cuando `bash run.sh` imprime las cuatro etapas y termina con
`EXERCISE OK`.

## El contrato con el corrector

Igual que en el `d7-final`, el corrector no lee tu código: lee el log. Cuatro
cosas tienen que ser así:

- Los **tests** se llaman `monitor_test`, `smoke_test` y `random_test`.
- El **monitor** imprime una línea por ciclo con actividad, con el id `MONITOR`
  y con las banderas adentro:

  ```
  wr=1 data=a3 rd=0 | count=3 full=0 af=0 empty=0 ae=0
  ```

  Las etapas 1 y 2 se corrigen contando esas líneas y buscando `full=1` y
  `empty=1`: si tu formato no las escribe, la etapa 2 no pasa aunque la
  sequence esté bien.
- El **scoreboard** reporta con `` `uvm_error("SCOREBOARD", ...) ``.
- La sequence dirigida del `smoke_test` tiene que llegar a `full=1` **y** a
  `empty=1` en la misma corrida.

## Cuánto tarda

Compila UVM entera, igual que el `d7-final`: ~2 min la primera vez, y ~15 s las
siguientes con `ccache`. Necesita **`z3`**: el `random_test` randomiza con
constraints, y sin el solver `randomize()` devuelve 0 en silencio.

## Pistas, en orden de utilidad

- **El scoreboard son dos colas, no una.** Una es lo que la FIFO tiene adentro;
  la otra, lo que ya se leyó y todavía no salió por `rd_data`. Con una sola no
  se puede modelar la latencia de un ciclo.
- **Chequeá las banderas antes de aplicar el ciclo.** Describen el estado
  previo al flanco. Si primero aplicás y después comparás, te vas a comer un
  error por ciclo y vas a culpar al DUT.
- **El orden de la actualización es la letra chica.** Primero mirá si la
  lectura saca —eso libera un lugar—, y recién entonces si la escritura entra.
  Al revés, la simultánea con la FIFO llena te va a dar un dato perdido que el
  DUT no perdió.
- **El driver no mira las banderas.** Manda lo que la sequence pidió, aunque
  esté llena. Un driver que se autocensura tapa justo el caso que hay que
  verificar — y deja el bin `escribe_llena` en cero para siempre.
- Si el `check_phase` te dice *"quedaron N datos que nunca salieron"*, casi
  siempre es que el test terminó un ciclo antes de tiempo. El dato de la última
  lectura sale **después**: hace falta un colchón, que es el `drain_time` del
  día 3.
- Si la cobertura no llega, no agregues ciclos: **sesgá el `dist`** de la
  transaction para que escriba más de lo que lee. Con 50/50 la FIFO se queda
  rondando la mitad y no toca ningún borde. Es la lección del día 5.

## Y después

`ci/regresion.yml` del `d7-final` sirve igual para éste: cambiale el `DIR` y
tenés la regresión de esta FIFO corriendo sola, con la cobertura acumulada de N
semillas.

## Lo que practica

Todo lo del primer capstone —interface, agent activo y pasivo, `config_db`,
sequences, tests, covergroup— más lo que el primero no podía pedir: un
**modelo de referencia con estado**, la predicción de **salidas de control** y
no sólo de datos, y una latencia de un ciclo entre el pedido y la respuesta.
Y una cosa más, que tampoco es de UVM: **saber cuándo tu scoreboard no está
chequeando lo que creés que chequea**.
