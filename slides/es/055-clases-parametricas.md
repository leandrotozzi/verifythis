## Clases paramétricas

#### *No es una clase: es un molde*

- La `bandeja_de_fernet` de la sección anterior sirve para fernets. Para mojitos hay que
  escribir otra igual, con una palabra cambiada
- Eso ya lo resolviste en RTL y no le decís OOP: una FIFO no se copia por cada
  ancho de dato, se parametriza. `#(.awidth(8), .dwidth(16))`
- Una clase paramétrica es lo mismo, con **tipos** en vez de números:
  `bandeja #(fernet)` y `bandeja #(mojito)`
- Y hay una consecuencia que sorprende: cada `#(...)` distinto es una **clase
  distinta**, generada en compilación. No comparten nada, ni siquiera lo `static`
- Por qué importa: cada `#(...)` que veas en el resto del curso es esto.
  `uvm_analysis_port #(T)`, `uvm_subscriber #(T)`, `uvm_sequence #(T)`

Note:
Empezar por el `parameter` de Verilog es deliberado: el alumno de RTL ya sabe
parametrizar, sólo que con anchos. Acá el parámetro es un tipo, y el resto es
igual.
Lo que hay que dejar clarísimo antes de seguir es lo del tercer bullet, porque
es la pregunta 6 del repaso y porque es la base de todo UVM:
`bandeja#(fernet)` y `bandeja#(mojito)` **no son la misma clase con un
campo distinto**. SystemVerilog genera una clase entera por cada combinación de
parámetros, en tiempo de compilación. Por eso cada una tiene su propia queue
`static`.
La forma corta de decirlo: la clase paramétrica no es una clase, es la receta
para fabricar clases. La clase aparece cuando escribís el `#(...)`.
Y un límite que conviene nombrar ahora para que no los sorprenda: como se
resuelve en compilación, el tipo tiene que conocerse ahí. No podés elegir el
parámetro en runtime. Elegir en runtime es lo que resuelve la factory, que es la
unidad que sigue.

---

## Clases paramétricas

- Antes de la sintaxis nueva, el parámetro que ya conocés: una RAM que no se
  copia por cada ancho, se instancia con `#(.awidth(8), .dwidth(16))`
- Cada instanciación con parámetros distintos produce **hardware distinto**, y
  nadie lo discute
- Las *parameterized class definitions* son eso mismo del lado del software, con
  una diferencia: el parámetro puede ser un **tipo**

{{code:code/u3/parametricas/01-memoria/pres-ch8.sv}}

Note:
Conviene decir para qué las vamos a usar, si no parece un tema de OOP suelto:
`uvm_analysis_port#(T)`, `uvm_subscriber#(T)`, `uvm_tlm_fifo#(T)`. Cada `#(...)`
que aparezca en el resto del curso es esto.

---

## Clases paramétricas

- Versión con métodos estáticos: la bandeja no se instancia, se le pide con `::`
- La cola es `static` y aun así hay **dos**: `bandeja#(fernet)` y
  `bandeja#(mojito)` son dos clases distintas, cada una con la suya

{{code:code/u3/parametricas/02-estatica/bandejas.sv|lines=51-89}}

Note:
Esta es la slide donde se demuestra lo del molde, y conviene hacerlo corriendo
el ejemplo: dos fernets y dos mojitos entran, y cada `lista_tragos()` imprime
sólo los suyos. La queue es `static` y aun así hay dos.
La pregunta para el pizarrón: ¿cuántas queues hay en memoria? Dos. ¿Y cuántas
habría con tres tragos? Tres. Cada `bandeja#(X)` que el compilador ve en
el código genera su clase, con su `static` propio. Las que nadie usa no existen.
Un detalle que se pregunta siempre: `T` no está declarado en ningún lado como
"trago o derivados". SystemVerilog no tiene esa restricción — el chequeo es
por uso. Si metés un tipo que no tiene `get_name()`, el error aparece al
compilar la especialización, no al declarar la clase, y el mensaje señala
adentro de `bandeja`. Es confuso la primera vez.

---

## Clases paramétricas

#### *Variables con parámetros*

- Acá la bandeja se instancia como cualquier objeto y hay que tener el handle para
  usarla — deja de verse desde todo el testbench
- Hace exactamente lo mismo que la versión anterior. Lo que cambia es el alcance,
  y ésa es la decisión: **`static` cuando de verdad hay uno solo, instanciado
  cuando puede haber más de uno**

{{code:code/u3/parametricas/03-instanciada/bandejas.sv|from=module top;|to=endmodule : top}}

Note:
Las dos versiones hacen exactamente lo mismo y la diferencia es de diseño, no de
sintaxis: en la anterior la bandeja es global —cualquiera del testbench la ve—; en
ésta hay que tener el handle para poder usarla.
La regla que se lleva al trabajo: **estático cuando de verdad hay uno solo en
todo el testbench, instanciado cuando puede haber más de uno**. Y cuando dudes,
instanciado: es más fácil agregar un segundo objeto que sacarle el `static` a
algo que ya usa medio testbench.
Con eso en la mano, ubicar UVM: el `uvm_config_db` es estático porque hay uno
solo. Un `uvm_analysis_port#(command_transaction)` es instanciado porque cada
monitor tiene el suyo. El alumno ya tiene el criterio para leer los dos.

---

## Clases paramétricas

#### *Resumen de la unidad*

- Es el `parameter` de RTL que ya conocés, pero el parámetro puede ser un
  **tipo**: `bandeja #(fernet)` en vez de `#(.dwidth(16))`
- Una clase paramétrica **no es una clase**: es la receta para fabricar clases.
  La clase aparece cuando escribís el `#(...)`
- Y cada `#(...)` distinto es una **clase distinta**, generada en compilación.
  No comparten nada — **ni siquiera lo `static`**
- El criterio que se lleva al trabajo: **`static` cuando de verdad hay uno solo,
  instanciado cuando puede haber más de uno**. Ante la duda, instanciado
- El límite: se resuelve **al compilar**, así que el tipo tiene que conocerse
  ahí. Elegir en runtime es la unidad que sigue
- Cada `#(...)` del resto del curso es esto: `uvm_analysis_port #(T)`,
  `uvm_subscriber #(T)`, `uvm_sequence #(T)`

Note:
El bullet de las clases distintas es el que hay que dejar clavado, porque es la
pregunta del repaso y porque es la base de todo UVM. `bandeja#(fernet)` y
`bandeja#(mojito)` no son la misma clase con un campo distinto: son dos
clases enteras, cada una con su `static` propio.
Y el último bullet ubica la sección: el `uvm_config_db` es estático porque hay
uno solo; un `uvm_analysis_port#(command_transaction)` es instanciado porque
cada monitor tiene el suyo. Con eso ya pueden leer los dos.
