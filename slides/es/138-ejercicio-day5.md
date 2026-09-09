## Ejercicio · Día 5 · 1 de 3

#### *El scoreboard grita y el DUT está sano*

`cd code/ejercicios/d5 && bash run.sh`
<!-- .element: class="comando" -->

- El TB de las transactions reporta `FAIL` en casi todas las operaciones
- El DUT es el mismo que viene pasando desde la spec. El bug es del TB
- Los mensajes que lo delatan son `UVM_HIGH`: subí la verbosidad
- Si te trabás, el apéndice **caja de debug** tiene la fila de este síntoma; el
  de **trampas mudas**, la causa

Note:
Es el ejercicio que más se parece a un día de trabajo: el scoreboard grita y hay
que decidir a quién creerle.
Dejalos arrancar sin la pista. Casi todos van a mirar el RTL primero — eso ya es
la mitad de la lección. Cuando se traben, la pista es la verbosidad: los
`uvm_info` del monitor son UVM_HIGH y muestran lo que el monitor dice que vio,
que no coincide con lo que el scoreboard compara.
El bug es una sola línea de `command_monitor.svh`: el monitor copia mal uno
de los dos operandos.
