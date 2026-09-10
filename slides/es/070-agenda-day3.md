<!-- .slide: id="day3" -->

## Ayer quedó…

#### *Dónde dejamos el testbench*

- El testbench del día 1 **sin un solo módulo**: tres clases, una que las une, y
  un `top` que sólo instancia el DUT y la BFM
- La BFM entra a las clases por una **virtual interface**, que es la única forma
  que tiene una clase de tocar señales
- Y la factory ya está escrita **a mano**: un `case` que hay que editar cada vez
  que aparece un tipo nuevo. Hoy aparece la que no hay que editar

Note:
El día 3 es donde entra UVM, así que la recap tiene una función extra: dejar
claro que lo que viene **reemplaza** piezas que el alumno ya escribió, no
piezas nuevas que hay que aprender de cero. Toda la unidad se puede leer como
"esto que hiciste a mano, la librería lo trae".
El tercer bullet es el gancho: el `case` del `060` es exactamente lo que
`` `uvm_component_utils `` hace solo, y decirlo acá hace que el macro deje de
ser una fórmula mágica.

---

<!-- .slide: data-machete="res/TB_UVM.svg|El mismo testbench con estructura UVM: test, env, tester, scoreboard y coverage,res/diagrams/env_uvm_incantation.svg|Anatomía de la línea tipo::type_id::create(nombre, this),res/diagrams/UVM-hierarchy.svg|Jerarquía de instancias que UVM arma en build_phase,res/machete-debug.svg|Machete de debug: las siete perillas del curso y qué mirar según el síntoma" -->

<!-- .slide: data-transition="convex" -->

## Agenda

#### *Día 3 · ≈ 4 h 30 · unidad 4 · entra UVM*

- Tests
- Components y fases
- El env: estructura y estímulo
- Reporting: verbosidad y *actions*

**Al final del día podés:**

- **Explicar** por qué una simulación de UVM termina en `t=0` si nadie levanta
  un objection
- **Decir** por qué `build_phase` corre de arriba hacia abajo y `connect_phase`
  al revés
- **Hacer** que un scoreboard que falla diga **algo más** que "falló"

Note:
El tercero es el que más rinde a largo plazo y el que más se subestima: es la
fila 10 de la autoevaluación del cierre y el que apunta al 47 % del día 1. Un
`uvm_error` que imprime *"FAIL"* deja al que debuggea donde estaba; uno que
imprime la transaction, la predicción y el tiempo le ahorra media mañana.
Los dos primeros son mecánica de la librería y son los que más se contestan con
un *"me suena"*. El segundo ejercicio del día existe para que dejen de sonar y
pasen a haberse sufrido.
