# En qué se diferencia del *UVM Primer*

Aprendí UVM con *The UVM Primer* de Ray Salemi. Es el mejor libro para empezar
que hay, y este curso no existiría sin él: de ahí salieron la idea de enseñar
UVM transformando un testbench convencional paso a paso, y varios de los
ejemplos de código, que su autor publicó bajo Apache-2.0 y que acá se usan y se
acreditan como corresponde (ver [`NOTICE`](../NOTICE)).

Dicho eso: **este curso no es el libro traducido, y tampoco lo sigue.** Esta
página dice exactamente en qué se apartó, para que nadie tenga que adivinarlo.

## Lo que el curso hace y el libro no

**Corre entero con herramientas libres.** El libro usa Questa. Acá todo —los
ejemplos, los ejercicios, las soluciones y el capstone— corre con **Verilator**,
que un estudiante puede instalar sin pedirle una licencia a nadie. Eso no es un
detalle de packaging: cambió el material. Hay decisiones de diseño del testbench
que se tomaron por lo que Verilator soporta y por lo que todavía no, y están
documentadas en [`docs/verilator.md`](verilator.md), con la matriz de los 38
ejemplos y su cobertura.

**La cobertura funcional aparece en el testbench convencional, no al final.** El libro llega a
la cobertura tarde. Acá se enseña *antes* que UVM, junto con el testbench
convencional, porque la pregunta *"¿cuándo terminás de verificar?"* es anterior a
la metodología y no depende de ella.

**El plan de verificación es la columna vertebral.** Cinco columnas —feature,
escenario, estímulo, chequeo, medida— escritas antes que el testbench. Cada
unidad dice qué fila del plan cierra, y el capstone lo llena desde cero. El libro
no usa el plan de verificación en ningún momento. Está en
[`docs/plan-de-verificacion.md`](plan-de-verificacion.md).

**Assertions.** El libro deja SVA afuera —es una decisión razonable en un primer
libro sobre UVM— y por eso el testbench que enseña chequea *qué* calcula el DUT y
nunca *cómo* se habla con él. Acá SVA es una unidad entera, con su ejercicio, y
el curso hace la distinción explícita: **el scoreboard chequea qué calcula el
DUT; las assertions chequean cómo se habla con él.** Un plan serio tiene las dos.

**Un capstone con un DUT distinto y una hoja en blanco.** El día 7 cierra con un
esclavo APB3 —spec propia, sin testbench de arranque— donde el alumno escribe el
env, el agent, el scoreboard y la cobertura de cero. Ese DUT no tiene nada que
ver con la ALU del curso, que es justo el punto: sirve para ver qué se aprendió y
qué se copió.

**Constrained random y sequences virtuales.** Dos temas que el libro no cubre.

**Se evalúa.** 45 preguntas de repaso con explicación, 15 ejercicios con solución
que compilan y corren, y un apéndice de **veinte trampas mudas** —todo lo que
compila, corre y miente— que sale de haber corregido esos ejercicios.

**Está en castellano, y con criterio.** No es una traducción: los sustantivos
técnicos se dejan en inglés y los verbos se conjugan en español, porque es como
habla el ambiente. Hay un glosario ES↔EN al final, porque todo lo que el alumno
lea después de este curso va a estar en inglés.

## Lo que el curso hace distinto

**Otra estructura.** El libro tiene 24 capítulos. El curso tiene **8 unidades
sobre 7 días —más un día 8 opcional—**, agrupadas por el problema que resuelven
y no por la feature de UVM que introducen. No hay correspondencia unidad-capítulo, y el orden tampoco es
el mismo: reporting se dicta antes que analysis ports porque el 47 % del tiempo
del verificador se va en debug y esperar cuatro días para saber leer un log no
tiene sentido.

**Otro DUT.** La ALU del libro está en VHDL y se llama TinyALU. La de acá está en
SystemVerilog, se llama **VTALU**, tiene una operación más, un flag de overflow y
otro encoding de opcodes, con un encoding libre reservado a propósito para el
ejercicio del día 1. Su spec está en la unidad 1 del curso y en el encabezado de
[`code/vtalu_dut/vtalu.sv`](../code/vtalu_dut/vtalu.sv).

**Otro lugar para el análisis.** El libro mete el scoreboard y el coverage
*adentro* del agent; acá van afuera, colgados del `env`. La razón es que **un
agent pasivo no debería arrastrar un scoreboard**: el día que el mismo agent se
instancia dos veces —una activa sobre el DUT y otra pasiva sobre un bus que
maneja otro— con el análisis adentro te llevás dos scoreboards y dos coberturas
que nadie pidió, y no hay forma de tener una sola cobertura de los dos buses. Con
el análisis en el `env`, el agent expone sus `analysis_port` y el `env` decide
cuántos oyentes cuelga y de cuáles. Se ve en
[`code/u7/agents/tb_classes/env.svh`](../code/u7/agents/tb_classes/env.svh).

**Y el agent nace completo.** En *The UVM Primer* el agent de esa sección todavía
tiene el `tester` y la `uvm_tlm_fifo` adentro, y el sequencer recién aparece con
las sequences —donde además el `tester` desaparece—. Acá el sequencer entra junto
con el agent, que es la forma en que se escribe hoy, y tiene una consecuencia
pedagógica: la sección de sequences queda siendo **sólo** sobre sequences, en vez
de mitad reestructuración del agent. Las dos decisiones las dice la slide *Lo que
esta sección hace distinto*, al final de la sección de agents.

## Cómo citarlo

> "Verify This! — Curso introductorio a UVM", por Leandro Tozzi ·
> https://github.com/leandrotozzi/verifythis · CC BY 4.0

Y si el curso te sirvió, comprá el libro: sigue siendo la mejor forma de
empezar, y el autor se lo ganó.
