[English](README.md) · **Castellano**

# Día 7 — el capstone: verificá el `apb_regs`

Los otros trece ejercicios con enunciado te daban un archivo con un agujero.
Éste te da un DUT, una spec y nada más. **El testbench lo escribís vos,
entero**, y ésa es la única diferencia entre *"hice el curso"* y
*"sé hacerlo"*.

El DUT es un esclavo **APB3** de cuatro registros. No es una ALU: tiene
direcciones, dos fases por transferencia, un wait state y respuesta de error. Es
lo que te vas a encontrar el lunes, y es exactamente el salto que promete el
apéndice *De la VTALU a un bus real*.

## Lo que te dan, y no se toca

| | |
|---|---|
| [`spec.md`](spec.md) | **la especificación**: pines, protocolo, mapa de registros, la letra chica y el plan de verificación |
| `rtl/apb_regs.sv` | el DUT |
| `top.sv` | los **dos** esclavos, cada uno con su interface, y el `config_db` |
| `apb_stim_module.sv` | el módulo de siempre, sin una línea de UVM, que maneja el segundo bus |
| `run.sh` | el corrector, por etapas |

El segundo bus está para que puedas escribir el **monitor antes que el driver**,
que es el consejo de campo del apéndice: si no podés *ver* el bus, no podés
verificar nada — ni siquiera el estímulo de otro.

## Lo que escribís vos

En este directorio, empezando por una hoja en blanco:

```
apb_if.sv           la interface: pines, reloj, el protocolo y el enganche del monitor
apb_pkg.sv          el package que incluye todo lo de abajo, en orden
tb_classes/*.svh    transaction, config, driver, monitor, agent, scoreboard,
                    covergroup, env, sequences y tests
```

## Los entregables, en orden

El corrector va por etapas y cada una imprime su `STAGE N OK`. Se puede
terminar de a una, y conviene: cada etapa se apoya en la anterior.

**1 · El monitor.** `apb_if.sv` con los pines de la spec, la `apb_transaction`,
el `apb_monitor`, un `apb_agent` **pasivo** sobre `stim_bfm`, el `env` y un
`monitor_test` que levante la objection y espere. Sin driver y sin scoreboard.
El módulo de siempre hace **ocho** transferencias: hay que ver las ocho, y
ninguna de más.

**2 · El driver.** Las tasks del protocolo adentro de `apb_if.sv`, el
`apb_driver`, el sequencer, el agent **activo** sobre `bfm`, una sequence
dirigida y un `smoke_test`. Tiene que escribir y leer los cuatro registros: es
la fila 1 del plan de verificación.

**3 · El scoreboard.** El `apb_scoreboard`, que es el DUT modelado en software:
los mismos cuatro registros, las mismas reglas, ninguna señal. Y un
`random_test` con una sequence al azar. El corrector lo corre **dos veces**: una
contra el DUT sano —tiene que cerrar en 0 `UVM_ERROR`— y otra con `+BUG=1`, que
le saca al DUT el gate de `CTRL.EN`. Ahí **tiene que gritar**: un scoreboard que
nunca vio un error no está probado.

**4 · La cobertura.** El `covergroup` con las nueve filas del plan de
verificación de `spec.md`. El corrector pide **al menos 20 puntos** y **90 %**
cubierto con el `random_test`. Las filas **8 y 9 vienen vacías**: las escribís
vos, y los bins se llaman `back_to_back` y `unaligned` porque el corrector los
busca por nombre. Cómo se llena una tabla de éstas, en
[`docs/plan-de-verificacion.md`](../../../docs/plan-de-verificacion.md).

**5 · Las properties.** El protocolo del APB chequeado **donde ocurre**, adentro
de `apb_if.sv`: SETUP dura un ciclo, el payload no se mueve hasta que termina la
transferencia, ACCESS se sostiene hasta el handshake. Se compilan con `--assert`
—el `run.sh` ya lo pasa— y reportan con `` `uvm_error("SVA", ...) `` en el `else`.
El corrector corre el módulo de siempre con **`+BUG=2`**, que le mueve `PADDR` en
el medio de ACCESS: el DUT contesta en la dirección nueva, el monitor reconstruye
ocho transferencias impecables, el scoreboard no tiene nada que decir, y la única
que se entera es la assertion. Ése es el argumento del día 7, ahora sobre un bus
de verdad.

Listo cuando `bash run.sh` imprime las cinco etapas y termina con
`EXERCISE OK`.

## El contrato con el corrector

El corrector no lee tu código: lee el log. Cuatro cosas tienen que ser así:

- Los **tests** se llaman `monitor_test`, `smoke_test` y `random_test`.
- El **monitor** imprime una línea por transferencia completa, con este formato
  exacto y con el id `MONITOR`:

  ```
  `uvm_info("MONITOR", t.convert2string(), UVM_MEDIUM)
  ```
  ```
  WR @0x04 = 0x10000000  slverr=0
  RD @0x08 = 0x00000030  slverr=1
  ```
  En una escritura el valor es `PWDATA`; en una lectura, `PRDATA`.
- El **scoreboard** reporta con `` `uvm_error("SCOREBOARD", ...) ``, y las
  **properties** de la etapa 5 con `` `uvm_error("SVA", ...) ``.
- Los dos bins de las filas 8 y 9 del plan se llaman **`back_to_back`** y
  **`unaligned`**: el corrector los busca por nombre en la base de cobertura.

No es burocracia: un formato de log acordado es lo que hace que el que llega
mañana al proyecto pueda grepear tu testbench sin leerlo.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

`solucion/` tiene el testbench completo: diecisiete archivos, que son los mismos
tipos de clase del `code/u7/sequences` más la interface y el package. Mirala
**después**, o el ejercicio no sirve para nada.

## Cuánto tarda

Compila UVM entera, como los otros del día 6 y 7:

| | |
|---|---|
| la primera vez | ~2 min |
| las siguientes, sin tocar nada | ~6 s |
| las siguientes, con `ccache` y un archivo tocado | ~15 s |

De esos segundos, cuatro se los lleva el solver: el `random_test` son 400
transacciones con `dist`, y cada `randomize()` es una llamada a **z3**. Sin z3
instalado, `randomize()` devuelve 0 en silencio — ver
[`docs/verilator.md`](../../../docs/verilator.md).

## Pistas, en orden de utilidad

- **Empezá por el monitor, no por el driver.** Es el orden del apéndice y es el
  orden del corrector. Con el monitor andando tenés ojos; sin él estás
  manejando a ciegas.
- Una transferencia termina **en el flanco de subida en que `PREADY` está
  alto**, no cuando baja `PENABLE`. Un monitor que muestree cualquier otro
  flanco reporta de más o de menos, y en la etapa 1 el número te lo dice.
- La lectura tiene **un wait state**. No lo cuentes en ciclos: esperá el
  handshake (`do @(posedge PCLK); while (!PREADY);`). El día que el esclavo meta
  tres wait states, tu driver no se entera.
- Si el scoreboard falla en la primera lectura de `CTRL`, leé otra vez la letra
  chica: `CLR` es autoclear y **nunca se lee en 1**.
- Si falla escribiendo `ACC` o `STATUS`, la trampa es al revés: escribir un
  registro de sólo lectura **no** da `PSLVERR`.
- Si `+BUG=1` no te dispara nada, tu modelo no está mirando `CTRL.EN` — o tu
  estímulo no lee `ACC` nunca. Las dos cosas se arreglan mirando la fila 5 del
  plan de verificación.
- El `covergroup` no lo inventes: la tabla del final de `spec.md` tiene las
  filas, y la columna de la derecha dice qué bin es cada una. Las dos últimas
  están vacías a propósito.
- Si el scoreboard falla en una dirección rara —`0x06`, `0x0D`— es la fila 9:
  `PADDR[1:0]` se ignora, así que `0x06` **es** el `SCRATCH`. Un `case` sobre la
  dirección entera manda esas transferencias al `default`.
- Para la fila 8 el que decide es el driver: si deja `PSEL` alto al final de una
  transferencia, la siguiente arranca pegada. Ojo con la última de la sequence —
  si queda encadenada y no viene nadie, el bus se queda en ACCESS para siempre.
- Las properties de la etapa 5 van **en la interface**, no en el testbench: ahí
  ven las señales sin que nadie se las pase, y las heredan las dos instancias del
  `top.sv`. Y cada una con su `cover property`: una assertion cuyo antecedente
  nunca pasa está en verde sin haber chequeado nada.
- La lectura obvia de *"`PSLVERR` es válido junto con `PREADY`"* —
  `PSLVERR |-> PREADY` — es **falsa** en este DUT: `PSLVERR` es combinacional y
  ya está alto durante el wait state de la lectura. Esa regla es un `cover`, no
  un `assert`.
- Manejá en el flanco de **bajada** y muestreá en el de **subida**, como toda la
  BFM del curso. Es la misma lección de los dos relojes de las assertions.
- **O mejor: usá un `clocking block`** en `apb_if.sv`, que es lo que se escribe
  en un proyecto. `default input #1step output #0`, y el driver deja de elegir
  flanco: `cb.PADDR <= …` para manejar, `cb.PRDATA` para muestrear. La sección
  de la unidad 2 tiene el ejemplo corriendo en `code/u2/clocking/`. El corrector
  no mira cómo lo hiciste — mira el log —, así que las dos formas pasan; ésta es
  la que vas a tener que saber defender.

## Y después: la regresión, en tu repo

Cuando el corrector te dé las cuatro etapas, el paso siguiente no es otro
ejercicio: es **poner esto a correr solo**. `ci/regresion.yml` es un workflow de
GitHub Actions listo para copiar a `.github/workflows/` de **tu** repo. Corre el
mismo test con N semillas, mergea la cobertura, y deja el número en el resumen
del job:

```
cobertura de la regresión: 118/131 bins (90.1 %)
bins que ninguna semilla llenó: unmapped_x_wr, status_x_wr, ...
```

Hay que tocarle tres variables —dónde está tu `run.sh`, con qué test, cuántas
semillas— y nada más. Compila Verilator de fuente y lo cachea, porque el paquete
de la distro es viejo y los covergroups entraron en 5.050.

Ese número subiendo commit a commit es **coverage closure**, que es lo que hace
un equipo de verificación todos los días. Y que un alumno pueda tenerlo gratis
en un runner público es consecuencia directa de que el simulador sea libre: no
hay licencia flotante que pedirle a nadie.

Si trabajás adentro de un fork del curso, `make regresion EJEMPLO=... N=...` hace
lo mismo en tu máquina y además escribe un reporte HTML con los bins abiertos.

## Lo que practica

Todo. Es el único ejercicio del curso donde no hay estructura previa: la
transaction, la interface con el protocolo adentro, el agent activo y el pasivo,
el `config_db` con dos ámbitos, el scoreboard como modelo de referencia, el
covergroup como plan de verificación medido, las sequences, los tests y las
properties del protocolo. Y dos cosas más, que no son de UVM: **leer una spec y
desconfiar de ella**, y **escribir dos filas del plan** que la spec promete en una
línea suelta y que nadie había medido.
