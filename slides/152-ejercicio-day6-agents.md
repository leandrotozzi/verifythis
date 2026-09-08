## Ejercicio · Día 6 · 1 de 4

#### *El agent que sólo mira*

`cd code/ejercicios/d6-agents && bash run.sh`
<!-- .element: class="comando" -->

- El `env` tiene un solo agent. Agregá el **pasivo** sobre la segunda VTALU
- Y hacé que `is_active` sirva de verdad: hoy el agent construye driver y
  sequencer siempre
- Se corrige con `+UVM_CONFIG_DB_TRACE`: el censo del árbol lo escribe UVM, no vos

Note:
El ejercicio junta las tres cosas de la sección que se pueden hacer mal sin que el
compilador diga nada: `is_active`, el ámbito jerárquico del `set()`, y el
`connect_phase` de los analysis ports.
La trampa que van a encontrar casi todos es el ámbito: con `"*"` en los dos
`set()`, el segundo pisa al primero y los dos agents arrancan activos. El
corrector lo caza cruzando las cuentas — el módulo manda 200 operaciones y la
sequence más de mil, así que si los dos agents ven números parecidos es que
están mirando la misma interface.
Y el atajo de poner los dos en `UVM_PASSIVE` para que "pase" tampoco funciona:
el corrector exige que `clase_agent_h` siga teniendo driver.
