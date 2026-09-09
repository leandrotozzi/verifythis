<!-- .slide: id="day8" -->

## Ayer quedó…

#### *Dónde dejamos el testbench*

- El capstone entregado: un esclavo APB, su spec, y un testbench entero escrito
  desde una hoja en blanco — monitor, driver, scoreboard, cobertura y properties
- El scoreboard de ese testbench **predice a mano** el valor de cada registro, y
  la cobertura del bus se escribió fila por fila
- Y eso se hace igual en el trabajo… hasta que el DUT tiene sesenta registros.
  Ahí las dos cosas se modelan, y eso es todo el día 8

Note:
Este día es **opcional y va después del cierre**, y las dos cosas son a
propósito. El curso termina en el día 7: el que hizo hasta ahí escribió un
testbench de UVM completo desde una hoja en blanco y no le falta nada para
trabajar. Lo de acá es lo que se agrega cuando ya pasó eso.
La recap tiene una función concreta el día 8: las tres piezas de hoy sólo se
entienden como reemplazo de algo que el alumno **acaba de escribir a mano**. RAL
reemplaza la predicción registro por registro, el golden model en C reemplaza la
predicción entera, y el segundo capstone muestra dónde deja de servir el patrón
del primero. Sin el capstone hecho, las tres son abstracciones sin problema.

---

<!-- .slide: data-machete="res/uvm_class_diagram.svg,res/diagrams/sequences_tb_completo.svg" -->

## Agenda

#### *Día 8 · ≈ 4 h · opcional · lo que sigue después del capstone*

- RAL, la unidad 9 — el modelo de registros sobre el mismo APB
- El modelo de referencia en C, por DPI
- El segundo capstone: una FIFO con backpressure

**Al final del día podés:**

- **Leer y escribir** un registro por nombre, sin escribir un solo `PADDR`, y
  decir qué hacen el adapter y el predictor
- **Enchufar** un modelo de referencia escrito en C, y probarlo con una mutación
- **Escribir** un scoreboard para un DUT donde una tabla no alcanza

Note:
Para el que dicta: en una empresa esto es media jornada más, y suele darse
cuando el grupo tiene registros de verdad en el proyecto. En un cuatrimestre es
la unidad optativa, o el trabajo final de los que quieren nota alta.
Los tres objetivos son deliberadamente concretos y no "entender RAL": el día 8
no tiene autoevaluación propia, así que estos tres verbos son la única rúbrica
que el alumno se lleva. El tercero es el que más rinde de los tres y el que menos
se espera — una FIFO tiene orden y ocupación, y eso no entra en una tabla de
cuatro filas.
