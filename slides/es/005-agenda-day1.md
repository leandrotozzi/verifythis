<!-- .slide: id="day1" data-machete="res/diagrams/wave-dut.svg,res/TB.svg" -->

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

**Al final del día podés:**

- **Escribir** un plan de verificación de cinco columnas para un DUT que no
  viste antes
- **Leer** el número que sale de un `covergroup`, y decir qué mirar primero
  cuando da 0 %
- **Explicar** qué race evita un `clocking block` — y por qué igual son
  opcionales

Note:
Los tres verbos de abajo son el contrato del día, y conviene leerlos en voz alta
antes de empezar: en video son los diez segundos en los que alguien decide si
éste es el que buscaba. Son las tres primeras filas de la autoevaluación del
cierre, traídas al principio; el que las pueda contestar al terminar el día no
necesita mirar nada más.
Y una advertencia honesta para el que viene de VHDL o de Verilog-2001, que es la
audiencia declarada: el día 2 nivela la OOP, pero **nadie nivela SystemVerilog**,
y hoy aparecen `interface`, `logic`, `enum`, `package`, `covergroup`, `clocking`
y una `assert property`. Está todo en una carilla en
**`docs/systemverilog-para-el-que-viene-de-vhdl.md`**: media hora antes de
arrancar, y el día 1 deja de tener dos escalones a la vez.
