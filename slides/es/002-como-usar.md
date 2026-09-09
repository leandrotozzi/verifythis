<!-- .slide: id="como-usar" -->

## Cómo usar este curso

#### *Sobre todo si lo estás haciendo solo*

- **Qué hay que saber antes:** Verilog o VHDL, y haber simulado algo. Programar
  orientado a objetos **no** hace falta — el día 2 es exactamente eso
- Son **siete días de clase**, de 4 a 5 horas y media — **≈ 30 h 30**, y cada
  agenda trae el suyo. Y un **día 8 opcional**, después del cierre. Solo,
  calculá el doble: la mitad se va en correr los ejemplos, y ésa es la que enseña
- <kbd>s</kbd> abre las **notas del presentador** en otra ventana ·
  <kbd>n</kbd> las muestra acá abajo, sin salir de la página. Ahí está lo que el
  instructor diría en voz alta: la trampa clásica, el porqué del número, el
  error que comete todo el mundo la primera vez. **No las saltees**
- Cada día cierra con un **repaso** de opciones clickeables y con un
  **ejercicio que se corrige solo**: `cd code/ejercicios/dN && bash run.sh`

Note:
Si estás dictando el curso, estas dos slides se saltean con la tecla 1.
Están acá porque la mayoría de la gente que abra esto no va a tener un
instructor al lado, y sin las notas del presentador se pierde la mitad del
material — que además es la mitad más difícil de reconstruir leyendo el código.

---

<!-- .slide: id="como-usar-correrlo" -->

## Cómo usar este curso

#### *Correrlo, navegarlo, y dónde buscar cuando algo no anda*

- **Corré los ejemplos**: `make u4/tests` corre uno, `make u4` la unidad entera. Un curso de verificación que sólo se lee
  no sirve para nada. Un ejemplo con UVM tarda **un minuto y medio la primera
  vez y quince segundos la segunda**, si tenés `ccache` instalado — y si no
  tenés Linux, el camino corto es GitHub Codespaces, que ya lo trae
- <kbd>0</kbd>–<kbd>8</kbd> saltan a la portada y a cada día ·
  <kbd>i</kbd> abre el índice · <kbd>Esc</kbd> muestra el deck entero · y el
  ribbon de la esquina despliega el machete del día
- **Si estás solo, leé el libro:** `libro/dia1.html` es este mismo curso de
  corrido, con las notas ya adentro del texto. Tené el deck al lado para los
  repasos
- **Cuando algo no ande, andá al final:** los apéndices *La caja de herramientas
  de debug* —qué mirar según el síntoma— y *Las 21 trampas mudas* —todo lo
  que compila, corre y miente—. Son las dos slides para imprimir

Note:
Las dos últimas son las que más rinden para el que estudia solo, y son las que
nadie lee hasta que ya se trabó: el libro trae estas mismas notas adentro del
texto, y los apéndices están escritos como tabla de síntomas, para buscar y no
para leer de corrido.
