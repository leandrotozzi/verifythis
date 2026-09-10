## Ejercicio · Día 8 · 1 de 2

#### *Modelar el mapa de registros*

`cd code/ejercicios/d8-ral && cat README.es.md`
<!-- .element: class="comando" -->

- Es **literalmente** lo primero que te piden en un proyecto con registros: te
  dan la tabla de la spec y devolvés el modelo
- El DUT y el testbench son los del capstone. El adapter, el predictor y los
  tests salen de la unidad. **Lo único que escribís es `apb_reg_block.svh`**
- Cuatro registros, seis campos, cuarenta líneas
- El corrector va por etapas: el **mapa** —impreso y comparado con la tabla, sin
  simular nada—, los **accesos** —las dos sequences de la librería— y **lo que el
  modelo no puede predecir**

Note:
Es el ejercicio más corto de los quince y el más parecido a una tarea real de
las primeras semanas de un proyecto. Cuarenta líneas, y la mitad son copiar y
pegar el patrón de `CTRL`.
La etapa que enseña es la 1, y por una razón de método: el modelo se **imprime**
—`+UVM_TESTNAME=mapa_test`— y se compara línea por línea contra la tabla de
registros del README del ejercicio, antes de simular nada. Es lo que hay que hacer con un modelo de
registros de verdad, donde el error típico no es de UVM sino un offset copiado
mal de una planilla de 200 filas.
La etapa 2 es donde cae `CLR`: el que lo declaró `RW` pasa la etapa 1 sin
problema y se entera acá, con el número del bit, gracias a un test que no
escribió. Vale dejar que caigan ahí — es el momento en que el argumento de RAL
deja de ser una opinión.
Y la etapa 3 es la que separa: pide **apagar** un chequeo, que es lo contrario de
lo que el curso viene pidiendo hace siete días. La justificación tiene que salir
de ellos: `STATUS.EN` cambió por una escritura a otra dirección, el modelo no
puede saberlo, y un falso positivo que se deja pasar termina en alguien apagando
el chequeo entero.
