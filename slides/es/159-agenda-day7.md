<!-- .slide: id="day7" -->

## Ayer quedó…

#### *Dónde dejamos el testbench*

- El testbench quedó **completo y reutilizable**: agents con `is_active`, el
  análisis en el `env`, y el estímulo afuera del árbol, en sequences
- Ninguna línea del test nombra un componente de adentro del `env`: la última
  se fue con el `default_sequence` por `uvm_config_db`
- Y falta la otra mitad del plan de verificación: las filas que **ningún
  scoreboard puede cerrar**, porque no son sobre el resultado sino sobre el
  protocolo

Note:
La recap del día 7 hace de bisagra, y conviene decir las dos cosas que la
componen: hoy a la mañana se cierra UVM —la sequence virtual es la última pieza,
y con eso el testbench del curso está entero— y a la tarde se abre lo que UVM no
resuelve, que es la otra mitad del plan.
El tercer bullet es el arco que se plantó el día 1 con el plan de verificación y
se dejó abierto a propósito: el scoreboard chequea **qué**, la assertion chequea
**cómo**. Hoy se cierra.

---

<!-- .slide: data-machete="res/diagrams/assertions_property.svg,res/machete-debug.svg" -->

## Agenda

#### *Día 7 · ≈ 5 h 15 · unidad 8 · la otra mitad*

- Calentamiento: cinco semillas y un merge, con `make regresion`
- Sequences virtuales: la última pieza del testbench reutilizable
- Assertions (SVA)
- El capstone: un testbench de APB, desde cero
- De la VTALU a un bus real
- La caja de herramientas de debug · Las 21 trampas mudas
- Glosario, referencias y cierre

*Y después, el **día 8**: opcional, y para el que ya entregó el capstone*

**Al final del día podés:**

- **Escribir** una property que vea una violación de protocolo, y decir por qué
  `--assert` no es opcional
- **Coordinar** dos interfaces desde una sola sequence virtual
- **Entregar** un testbench entero para un DUT que no viste antes

Note:
La mañana tiene tres piezas y el orden importa: el calentamiento de semillas son
diez minutos sin SystemVerilog y engancha con el `make regresion` que el capstone
va a pedir; las sequences virtuales cierran UVM; y SVA abre la otra mitad del
plan. La tarde es el capstone.
El tercer objetivo es el que vale el curso, y es honesto ponerlo como objetivo
del día aunque la entrega sea después: en formato empresa el capstone se entrega
al día siguiente, y en un cuatrimestre va al período de exámenes. Lo que se hace
hoy a la tarde es arrancarlo con el instructor al lado, que es cuando más rinde.
