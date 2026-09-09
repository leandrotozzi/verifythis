<!-- .slide: id="day6" -->

## Ayer quedó…

#### *Dónde dejamos el testbench*

- El dato es un **objeto**: `command_transaction` con `do_copy`, `do_compare` y
  `convert2string`, y el scoreboard compara objetos, no campos
- El estímulo se pide en vez de escribirse: `randomize()`, `constraint`, `dist`,
  y el histograma que dice si la distribución hace lo que promete
- Y quedan **dos** cosas pegadas que no van juntas: el `tester` es estructura y
  estímulo a la vez, y el `env` nombra al monitor y al driver de a uno

Note:
La recap del día 6 tiene que nombrar las dos separaciones que la unidad hace,
porque son dos y se confunden: el **agent** separa la estructura y la
**sequence** separa el estímulo. Las dos son la misma operación —sacar algo del
árbol de componentes— aplicada a cosas distintas.
El tercer bullet es el que hay que dejar dicho con las palabras del alumno: hoy,
para probar tres estímulos y sus combinaciones, hacen falta seis clases de test.
Eso crece factorial, y es el motivo de que exista la unidad.

---

<!-- .slide: data-machete="res/machete-debug.svg,res/diagrams/agents_agent.svg,res/diagrams/sequences_tb_completo.svg" -->

## Agenda

#### *Día 6 · ≈ 4 h 15 · unidad 7 · el testbench reutilizable*

- Agents
- Callbacks
- Sequences

**Al final del día podés:**

- **Decir** qué construye y qué **no** un agent con `is_active = UVM_PASSIVE`
- **Explicar** por qué una `uvm_sequence` **no aparece** en `print_topology()`
- **Sacar** la última línea cableada de un test, con `default_sequence` por
  `uvm_config_db`

Note:
Los dos primeros son las filas 13 y 14 de la autoevaluación del cierre. La 14 es
la pregunta que se tiró el día 3, cuando apareció el diagrama de clases de UVM,
y se contesta hoy: `uvm_object` son los **datos** y `uvm_component` es la
**estructura**.
El tercero es el que cierra la unidad y el día: cuando esa línea se va, ninguna
del test nombra un componente de adentro del `env`, y recién ahí el testbench es
reutilizable de verdad.
