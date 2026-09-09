<!-- .slide: id="cierre" -->

## Hasta acá llegamos

#### *Qué te llevás*

- Sabés **por qué** existe la verificación como disciplina, y qué dicen los
  números de la industria
- Escribiste un testbench convencional, lo medís con **cobertura funcional**, y
  sabés leer el número que sale
- Podés leer y escribir **OOP en SystemVerilog**: clases, herencia,
  polimorfismo, clases paramétricas, la factory
- Armaste un testbench **UVM completo** —test, env, componentes, monitores,
  driver, scoreboard, transactions— pieza por pieza, entendiendo qué reemplaza
  a qué
- Y todo eso corre en tu máquina, con **herramientas libres**, sin pedirle
  licencia a nadie

Note:
Vale leer la lista en voz alta y despacio, porque después de siete días nadie
tiene dimensión de cuánto vio. Son cinco bullets y cada uno era un curso entero
hace una semana.
El que hay que subrayar es el último, y no por militancia: **todo esto corre en
la máquina del alumno**. No hay una parte del curso que quede en modo demo
porque falte una licencia, y eso significa que el día que quiera repetir un
ejemplo, probar una idea o mostrarle algo a alguien, puede. La mayoría del
material de UVM que va a encontrar de acá en adelante no tiene esa propiedad.
Y la aclaración honesta antes de la slide de lo que quedó afuera, para que nadie
se vaya con la idea equivocada: esto es un curso **introductorio**, y lo que
sigue es una lista de lo que no se vio. Terminarlo no es saber UVM — es poder
leer un testbench ajeno, escribir uno propio, y entender la próxima cosa que
aprendan sin que les suene a chino.

---

## Lo que quedó afuera

#### *y dónde seguir*

| Tema | Por qué te lo vas a cruzar |
| --- | --- |
| `uvm_event`, `uvm_barrier` | La sincronización que queda cuando la objection no alcanza |
| `uvm_heartbeat` | El que avisa que un componente dejó de dar señales de vida en una regresión de horas |
| `uvm_sequence_library` | Una bolsa de sequences que el sequencer elige al azar: el test de estrés sin escribirlo |
| `uvm_pool`, `uvm_queue` | Las colecciones de UVM. Un array asociativo alcanza hasta que hay que compartirlo |
| **TLM2, phase jumps** | El límite del curso, y es explícito |
| UPF, gate-level, PSS | Tres mundos aparte: bajo consumo, la netlist con retardos, y generar los tests desde un modelo |

- Los tres lugares donde seguir: el **LRM IEEE 1800-2017**, el *UVM User Guide*
  de **Accellera**, y **Verification Academy**
- Y uno que casi nadie usa: el **código de `uvm-core`**. Está en tu disco, en
  `code/.uvm/src/`, y a esta altura lo podés leer
- Y si te trabás: **[Discussions](https://github.com/leandrotozzi/verifythis/discussions)**,
  con una categoría por día. Un ejemplo que no corre o una explicación que no se
  entiende son **issues del curso**, no problemas tuyos
- Y si querés seguir acá mismo: el **día 8** es opcional y arranca en la slide
  que sigue — RAL, el modelo de referencia en C, y un segundo capstone

Note:
**RAL salió de esta tabla y ahora es la unidad 9**, opcional, con el ejemplo que
corre en `code/u9/ral/` y el ejercicio `d8-ral`. Está en el **día 8**, después de
esta slide y no en el medio, porque se entiende recién cuando el alumno ya
escribió el scoreboard que RAL reemplaza — y porque hasta donde sabemos es el primer curso que la muestra
corriendo sobre un simulador libre. Lo que quedó afuera de RAL, y está dicho en
la unidad: el backdoor y la generación del modelo desde IP-XACT.
El **`clocking block`** también salió de esta tabla: es media sección de la
unidad 2, con su ejemplo que corre en `code/u2/clocking/`.
Los **callbacks** salieron por lo mismo: son media sección de la unidad 7, con
el `code/u7/callbacks/` que inyecta el error en el driver — el tercer gancho que
la unidad 1 promete. Y **regresión y seeds** también: el ejercicio `d6-semillas`
es el ciclo entero, y `make regresion` lo dejó como herramienta, con reporte de
los bins que quedaron abiertos.
**SVA salió de esta tabla y ahora es una unidad entera**, y es de lo más propio
que tiene el curso: ningún libro introductorio de UVM la trae. Las **sequences virtuales**
también salieron: están al final de las sequences, con un ejemplo que corre en
`code/u7/sequences/virtual/`.
Las tres últimas filas conviene leerlas en voz alta con esta frase adelante: un
curso introductorio que enumera lo que no cubre vale más que uno que finge
cubrir todo. `uvm_heartbeat`, la sequence library y las colecciones se entienden
en una tarde cuando hagan falta; UPF, gate-level y PSS son otra carrera.
La última línea no es un chiste. Después de este curso el alumno puede abrir
`uvm_component.svh` y entender qué hace `build_phase`, porque vio construir a
mano cada pieza que la librería le da hecha.
Si hay tiempo, abrirlo en vivo y buscar juntos el `m_set_full_name()` que hace
que el config_db encuentre las cosas. Es la mejor forma de cerrar el curso: la
librería deja de ser magia.
