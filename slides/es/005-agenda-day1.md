<!-- .slide: id="day1" data-machete="res/diagrams/wave-dut.svg|Protocolo del VTALU: start y operandos estables hasta done,res/TB.svg|Anatomía de un testbench SystemVerilog: el DUT, el tester, el scoreboard y la interface" -->

<!-- .slide: data-transition="concave" -->

## Agenda

#### *Día 1 · ≈ 4 h · unidades 1 y 2*

**Unidad 1 · Por qué se verifica**

- Tendencias
- Qué es UVM
- La spec del VTALU
- El plan de verificación

**Unidad 2 · El testbench sin UVM**

- El testbench convencional
- Cobertura funcional
- Interfaces y BFM · el `clocking block`

**Dos ejercicios**, y el segundo se resuelve con el visor de ondas

- **Y el cierre del día**, que vuelve a la primera slide

**Al final del día podés:**

- **Escribir** un plan de verificación de cinco columnas para un DUT que no
  viste antes
- **Probar** que tu scoreboard chequea algo: meterle un bug al DUT a propósito
  y verlo fallar
- **Leer** el número que sale de un `covergroup`, decir qué fila del plan falta,
  y qué mirar primero cuando da 0 %
- **Explicar** qué race evita un `clocking block` — y por qué igual son
  opcionales

Note:
Los cuatro verbos de abajo son el contrato del día, y conviene leerlos en voz
alta antes de empezar: en video son los diez segundos en los que alguien decide
si éste es el que buscaba. Tres son las filas 2, 4 y 5 de la autoevaluación del
cierre, traídas al principio; el del bug a propósito es la práctica que
atraviesa el curso entero, de `make mutante` hoy a `+BUG=1` en el capstone. El
que los pueda contestar al terminar el día no necesita mirar nada más.
Y una advertencia honesta para el que viene de VHDL o de Verilog-2001, que es la
audiencia declarada: el día 2 nivela la OOP, pero **nadie nivela SystemVerilog**,
y hoy aparecen `interface`, `logic`, `enum`, `package`, `covergroup`, `clocking`
y una `assert property`. Está todo en una carilla en
**`docs/systemverilog-para-el-que-viene-de-vhdl.md`**: media hora antes de
arrancar, y el día 1 deja de tener dos escalones a la vez.
