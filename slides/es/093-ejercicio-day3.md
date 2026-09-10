## Ejercicio · Día 3 · 1 de 2

#### *Un test nuevo sin tocar la estructura*

`cd code/ejercicios/d3 && bash run.sh`
<!-- .element: class="comando" -->

- Escribí `mult_tester` y `mult_test`, con `set_type_override`
- **Sin tocar `env.svh`**: la estructura no se entera de que cambió el estímulo
- El `env` trae un componente `chequeo` que corrige el ejercicio solo

Note:
Antes de largarlos al ejercicio, volver a la slide *"El mapa del día 3: qué
reemplaza a qué"* del testbench en objetos y leer la columna derecha de corrido: el
`build_phase` del env, el config_db, los `run_phase`, las objections y el
`set_type_override` y el `$display` que pasó a `uvm_info`. Las seis filas están
tachadas, y el día cierra ahí.
Es el ejercicio del día 2 otra vez, pero con la factory. Vale ponerlos a
comparar los dos: en el día 2 el tipo se elegía en el código del testbench, acá
lo elige la factory y el testbench no cambia una línea.
Y que miren la cobertura al final: con puras multiplicaciones baja a 26 %. Un
test enfocado cubre menos, y ésa es la razón de que hagan falta muchos — y de
que agregar uno tenga que ser barato.
