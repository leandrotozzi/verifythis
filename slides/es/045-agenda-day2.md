<!-- .slide: id="day2" -->

## Ayer quedó…

#### *Dónde dejamos el testbench*

- Un testbench que **anda**: manda estímulo, chequea el resultado y mide
  cobertura funcional. El plan de verificación dice qué fila cierra cada cosa
- La BFM se llevó las señales adentro de una `interface`, y el testbench pasó a
  llamar `send_op()` en vez de mover cables
- Y quedó un problema abierto: **cambiar el estímulo es editar el archivo**. Un
  tester que sólo multiplica es copiar el que ya está y borrarle cinco líneas

Note:
Treinta segundos, y no son de relleno: el día 2 es el más abstracto del curso y
arranca sin tocar el VTALU en toda la mañana. El alumno tiene que entrar sabiendo
que esto es la respuesta a algo que ya le pasó ayer.
El bullet que hay que subrayar es el tercero, porque es el problema que la unidad
entera resuelve. Si el grupo viene de una clase anterior, alcanza con preguntar
*"¿cómo hacían ayer un tester que sólo multiplica?"* y esperar la respuesta
—copiar y borrar— antes de pasar a la agenda.
Si se dicta en video, ésta es la slide que reemplaza a la semana de distancia
entre un capítulo y el siguiente.

---

<!-- .slide: data-machete="res/diagrams/uml-poli.svg|trago, fernet y mojito: qué servir() vive en qué clase,res/diagrams/factory_diagram.svg|cantina fabrica fernet y mojito, y devuelve un handle trago" -->

<!-- .slide: data-transition="concave" -->

## Agenda

#### *Día 2 · ≈ 4 h · unidad 3 · la OOP que UVM da por sabida*

- Clases y extensiones
- Polimorfismo
- Variables y métodos estáticos
- Clases paramétricas
- El patrón factory
- Un testbench sin un solo módulo

**Al final del día podés:**

- **Extender** una clase y cambiarle el comportamiento **sin copiarla**, y decir
  qué hace `super`
- **Cambiar** la clase que usa un testbench **sin tocar** el código que la usa,
  con una factory
- **Escribir** el testbench del día 1 sin un solo módulo

Note:
El día 2 es el único que no toca el VTALU en toda la mañana, y por eso conviene
poner los tres verbos adelante: son la respuesta a *"¿esto para qué me sirve?"*,
que es la pregunta que aparece a la media hora.
El tercero es el que cierra el día y el que se practica en el ejercicio. Los dos
primeros son las filas 6 y 7 de la autoevaluación del cierre.
