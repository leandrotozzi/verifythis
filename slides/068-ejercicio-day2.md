## Ejercicio · Día 2

#### *Un tester que sólo multiplica*

`cd code/ejercicios/d2 && bash run.sh`
<!-- .element: class="comando" -->

- Extendé `tester`, redefiní `get_op()`, y que el testbench lo instancie
- Va a seguir mandando operaciones al azar. **Ahí empieza el ejercicio**
- Pista: polimorfismo

Note:
El ejercicio está armado para que fallen: `get_op()` en el testbench en objetos no es
virtual, así que `execute()` llama siempre a la de la clase base aunque el
objeto sea un `mult_tester`. Hasta que no agreguen `virtual`, la herencia no se
nota — y eso se entiende mucho mejor cuando lo sufrís que cuando lo leés.
Es a propósito el mismo problema del ejercicio del día 3: ahí lo van a resolver
con la factory, y recién entonces se ve para qué sirve.
