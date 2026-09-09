## Ejercicio · Día 4 · 1 de 2

#### *Un observador más, sin tocar a los que ya miran*

`cd code/ejercicios/d4 && bash run.sh`
<!-- .element: class="comando" -->

- Un `uvm_subscriber #(command_s)` que cuente los comandos
- Instancialo y conectalo en el `env`, sin tocar las conexiones que ya están
- Se corrige cruzado: tu cuenta tiene que dar igual que la del `command_monitor`

Note:
El ejercicio corto del curso: veinte minutos. Lo que se está practicando no es
escribir la clase —son diez líneas— sino el `connect_phase`: si se olvidan del
connect, la clase compila, corre, y cuenta cero.
Por eso la corrección es cruzada contra las líneas que imprime el
`command_monitor`: no alcanza con que el número exista, tiene que coincidir con
lo que otro componente vio.
