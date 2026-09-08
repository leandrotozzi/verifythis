# Clocking Blocks en UVM: ¿buena práctica, opcionales o innecesarios?

> Análisis técnico sobre el uso real de **SystemVerilog clocking blocks** en testbenches UVM, la postura de Dave Rich, evidencia de proyectos reales y criterios prácticos para decidir cuándo usarlos.

**Este documento es el material de fondo de la sección de clocking blocks de la
unidad 2.** El curso se queda con la conclusión —son opcionales, y conviene
usarlos en agents reutilizables— y con la trampa de mezclar dominios; acá está
la discusión entera, con las citas y los links. Lo que se ejecuta está en
[`code/u2/clocking/`](../code/u2/clocking/): `sin_clocking.sv`,
`con_clocking.sv` y `mezcla.sv`, los tres con `make u2/clocking`.

Y una nota de herramienta, que sale de haberlo corrido: la race del lado del
manejo (`=` contra `<=`) **no se observa con Verilator**, porque depende de un
orden de procesos que el LRM no define. Está medido en
[`verilator.md`](verilator.md).

---

## 1. Resumen ejecutivo

Los **clocking blocks** son una construcción de SystemVerilog para definir explícitamente la relación temporal entre un testbench y una interfaz síncrona del DUT: cuándo se samplean las entradas, cuándo se manejan las salidas y respecto de qué evento de clock.

La conclusión principal es:

> **No son estrictamente necesarios para escribir un testbench UVM correcto y libre de races, pero siguen siendo una abstracción útil y una práctica real en entornos industriales y proyectos grandes.**

La discusión existe porque hay dos afirmaciones distintas que muchas veces se mezclan:

1. **¿Son necesarios para evitar race conditions?**  
   No, si el testbench y el RTL están escritos con una disciplina correcta del scheduler de SystemVerilog.

2. **¿Son útiles como abstracción de timing y para robustez/reutilización?**  
   Sí, especialmente en BFMs/VIP reutilizables, interfaces complejas, gate-level simulation, clocks con skew/delta delay y proyectos donde muchos ingenieros trabajan sobre el mismo entorno.

La postura de **Dave Rich (`dave_59`)**, una de las referencias históricas de SystemVerilog/UVM en Verification Academy, es consistente durante más de una década:

- Los clocking blocks son **opcionales**.
- Un testbench puede funcionar correctamente usando NBAs y una disciplina correcta de scheduling.
- Los clocking blocks agregan aislamiento frente a distintas prácticas de coding, delays y problemas de sincronización.
- Si se usan, deben usarse correctamente; mezclar eventos del clocking block con `@(posedge clk)` puede volver a introducir races.

Por otro lado, proyectos grandes y públicos como **OpenTitan / lowRISC** los adoptan explícitamente como parte de su style guide de DV.

Por lo tanto, la respuesta industrial razonable no es:

> "Clocking blocks están de más."

ni tampoco:

> "Todo testbench UVM debe usarlos."

Una formulación más precisa sería:

> **Son una herramienta opcional del lenguaje que puede mejorar la robustez y reutilización del boundary TB↔DUT, pero no reemplazan la necesidad de entender el scheduler de SystemVerilog.**

---

# 2. El post que probablemente originó el recuerdo

## Verification Academy — 2014

**Thread:** *Clocking block usage in UVM*

Dave Rich responde:

> “If you are already familiar with Verilog testbenches, then you probably don’t need them.”

Contexto: explica que los clocking blocks fueron diseñados para simplificar la conexión entre testbench y DUT.

Link:

- https://verificationacademy.com/forums/t/clocking-block-usage-in-uvm/29900

Este es probablemente el post más cercano al recuerdo de que una figura muy reconocida de DV decía que los clocking blocks **no eran necesarios si uno entendía bien qué estaba haciendo**.

Pero es importante leer la frase completa dentro de su contexto: Dave no dice que sean incorrectos ni inútiles; dice que **no son una condición necesaria para construir correctamente un testbench**.

---

# 3. Dave Rich mantiene la misma postura años después

## 3.1. “Clocking blocks are certainly optional” — 2022

**Thread:** *What are clocking blocks?*

Dave Rich:

> “Clocking blocks are certainly optional.”

Agrega que pueden ser más útiles cuando:

- el RTL está escrito incorrectamente y usa blocking assignments en lógica secuencial;
- se hace gate-level simulation;
- existen delays que complican la relación temporal TB↔DUT.

Link:

- https://verificationacademy.com/forums/t/what-are-clocking-blocks/40479

Esto es muy importante porque separa:

```text
clocking blocks = mecanismo obligatorio para eliminar races
```

de:

```text
clocking blocks = capa adicional de aislamiento temporal
```

Dave sostiene la segunda interpretación.

---

## 3.2. UVM scheduling y cuándo se pueden evitar — 2022

**Thread:** *UVM scheduling and the need for Clocking Blocks*

Este hilo es especialmente interesante porque plantea exactamente el argumento del scheduler.

Link:

- https://verificationacademy.com/forums/t/uvm-scheduling-and-the-need-for-clocking-blocks/40325

El ejemplo conceptual es:

```systemverilog
// DUT
always @(posedge clk)
    out_a <= new_val;

// Monitor
forever begin
    @(posedge clk);
    if (out_a != old_val) begin
        // error
    end
end
```

La duda es:

> Si el DUT usa una non-blocking assignment, ¿no debería el monitor observar siempre el valor anterior?

Dave responde que **sí**, bajo ciertas condiciones:

- `clk` usado por DUT y TB representa realmente el mismo evento;
- no existen delta delays entre ambas versiones del clock;
- no hay delays adicionales introducidos por gate-level simulation;
- el testbench arranca desde un `module`, no desde un `program`.

En ese escenario el monitor observa el valor previo porque la actualización mediante NBA ocurre más tarde en el mismo time slot.

Dave concluye que, si:

```text
- no se hará gate-level simulation
- los clocks sincronizados no tienen delta delays
```

entonces se puede **evitar el clocking block**.

### Pero aparece un contraejemplo industrial interesante

Otro participante comenta que trabajando con **commercial Verification IP** había tenido problemas al no usar clocking blocks porque no controlaba completamente cómo el VIP manejaba internamente los clocks.

Incluso menciona que algunos VIPs incluían switches para habilitar el uso de clocking blocks.

No es un estudio estadístico, pero sí es una observación muy representativa del mundo real:

> cuanto menos control tenés sobre toda la cadena temporal TB↔DUT, mayor valor empieza a tener una abstracción explícita de sampling/driving.

---

# 4. Dave Rich en 2024: siguen siendo opcionales

**Thread:** *Use of clocking blocks in different types of testbench*

Link:

- https://verificationacademy.com/forums/t/use-of-clocking-blocks-in-different-types-of-testbench/47652

Dave dice:

> “They are not strictly necessary.”

Y explica que un testbench puede manejar señales siguiendo básicamente la misma disciplina que el RTL:

- usar non-blocking assignments para drivear;
- asegurarse de que las señales sampleadas son manejadas correctamente;
- conocer el orden del scheduler.

También da una formulación muy buena:

> Clocking blocks provide a layer of isolation from different coding styles.

Éste probablemente sea el mejor resumen de su postura.

No son magia.

No son obligatorios.

Son una **capa de aislamiento**.

---

# 5. El paper de Dave Rich: *The Missing Link: The Testbench to DUT Connection*

Paper de Siemens / Mentor Graphics:

- https://static.sw.cdn.siemens.com/siemens-disw-assets/public/78349/en-US/Siemens-SW-The-missing-link-The-testbench-to-DUT-connection-WP-78349-C4.pdf

La sección particularmente relevante es:

```text
Special design considerations
B. Race conditions and clocking blocks
```

Dave establece primero una regla fundamental:

> Si dos procesos sincronizados por el mismo clock escriben y leen una señal, el drive debe hacerse mediante NBA.

Luego explica que un clocking block puede ir más lejos:

- samplear señales antes/después del clock edge;
- drivearlas con un skew definido;
- aislar al TB del edge exacto;
- ayudar con nets y continuous assignments.

También agrega una advertencia extremadamente importante:

> Si un proceso usa variables de un clocking block, debe sincronizarse con el evento del clocking block.

Es decir:

```systemverilog
@(cb);
```

y no mezclar alegremente:

```systemverilog
@(posedge clk);
x = cb.foo;
```

porque esa mezcla puede volver a introducir race conditions.

---

# 6. La postura opuesta: “para señales síncronas son un MUST”

Hay también expertos que recomiendan el extremo opuesto.

**Thread:** *Are using SystemVerilog program and clocking blocks poor coding practices?*

Link:

- https://verificationacademy.com/forums/t/are-using-systemverilog-program-and-clocking-blocks-poor-coding-practices/27840

Ajeetha Kumari responde sobre clocking blocks:

> “it is a MUST to use IMHO”

para señales síncronas.

Esto demuestra algo importante:

> **Incluso entre expertos reconocidos de SystemVerilog/DV no existe consenso absoluto sobre si deben adoptarse siempre.**

La diferencia suele ser metodológica, no semántica:

- una escuela prefiere que el engineer controle explícitamente el scheduler;
- otra prefiere encapsular esa política de timing en la interface.

---

# 7. Evidencia real: OpenTitan / lowRISC

Una de las mejores fuentes públicas para observar prácticas de DV de escala grande es **OpenTitan**.

## lowRISC DV Coding Style Guide

Link:

- https://github.com/lowRISC/style-guides/blob/master/DVCodingStyle.md

En la sección:

```text
SystemVerilog Language Features
→ Interfaces, Clocking Blocks, Modports
```

el guide establece:

> “Use clocking blocks in a SystemVerilog interface to sample and drive synchronous DUT interfaces.”

Además recomienda interfaces reutilizables entre:

```text
block-level
integration-level
system-level
```

Esto es evidencia fuerte de que los clocking blocks **no son solamente una construcción académica o heredada**.

En un entorno UVM grande, reusable y moderno, se adoptan explícitamente como política.

---

## Common Interfaces de OpenTitan

Link:

- https://opentitan.org/book/hw/dv/sv/common_ifs/index.html

Por ejemplo, `clk_if` implementa dos clocking blocks:

```text
cb   → positive edge
cbn  → negative edge
```

y `clk_rst_if` utiliza el mismo concepto.

Por lo tanto:

```text
OpenTitan / lowRISC
        │
        ├── UVM
        ├── reusable interfaces
        ├── block + integration + system DV
        └── clocking blocks
```

Es un contraejemplo claro frente a cualquier afirmación absoluta del tipo:

> “En UVM real ya nadie usa clocking blocks.”

Eso simplemente no es cierto.

---

# 8. ¿Qué problema resuelve realmente un clocking block?

Es útil pensarlo como un **timing contract**.

Supongamos:

```systemverilog
interface bus_if(input logic clk);

    logic        valid;
    logic        ready;
    logic [31:0] data;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;

        output valid;
        output data;
        input  ready;
    endclocking

endinterface
```

El clocking block define:

```text
                  clock edge
                      │
                      ▼
              ┌──────────────┐
 input         │ sampling     │
 output        │ driving      │
              └──────────────┘
```

pero cada dirección puede tener su propio skew.

Por ejemplo:

```systemverilog
default input #1step output #0;
```

conceptualmente expresa:

```text
inputs  → observar el valor inmediatamente anterior al edge
outputs → manejar respecto del edge según la semántica del clocking block
```

La interface deja de ser solamente:

```text
un conjunto de wires
```

y pasa a describir también:

```text
cuándo se deben observar
cuándo se deben manejar
```

---

# 9. Testbench sin clocking blocks

Consideremos:

```systemverilog
always_ff @(posedge clk)
    q <= d;
```

y un monitor:

```systemverilog
forever begin
    @(posedge vif.clk);
    sample = vif.q;
end
```

El `always_ff` se activa en el edge.

Pero:

```systemverilog
q <= d;
```

no actualiza `q` inmediatamente.

La actualización queda programada en la región NBA.

Por eso, en una configuración simple y correctamente escrita, el monitor observa el valor previo.

Esto es perfectamente válido.

---

# 10. Driver sin clocking block

Un estilo muy común es:

```systemverilog
@(posedge vif.clk);

vif.valid <= tr.valid;
vif.data  <= tr.data;
```

Usar:

```systemverilog
<=
```

es crucial.

El DUT que evalúa sus flops en ese mismo edge ve el valor anterior.

Los nuevos valores quedan preparados para el ciclo siguiente.

Por lo tanto:

```text
TB drive mediante NBA
        +
DUT secuencial mediante NBA
        +
mismo clock
        +
sin delta-skews extraños
```

puede ser totalmente determinista.

---

# 11. El problema con blocking assignment

Ahora:

```systemverilog
@(posedge vif.clk);

vif.valid = tr.valid;
```

es diferente.

TB y DUT pueden ejecutar en regiones donde el orden relativo de procesos activos no debe asumirse.

Podemos terminar con algo conceptualmente parecido a:

```text
posedge clk
   │
   ├── DUT lee valid
   │
   └── TB escribe valid
```

pero el orden entre esos procesos puede no ser el que uno esperaba.

Ahí aparece una race.

Ésta es una de las razones por las que muchos engineers aprendieron la regla:

> “Use clocking blocks para evitar races.”

La regla es conservadora y suele funcionar.

Pero el mecanismo fundamental no es el clocking block:

> **el mecanismo fundamental es entender la semántica temporal del scheduler.**

---

# 12. El scheduler es el verdadero tema

Para entender clocking blocks de verdad hay que entender al menos conceptualmente:

```text
Preponed
   │
Active
   │
Inactive
   │
NBA
   │
Observed
   │
Reactive
   │
Postponed
```

No hace falta memorizar cada región para hacer UVM cotidiano, pero sí entender:

1. qué procesos reaccionan al clock;
2. cuándo ocurre una blocking assignment;
3. cuándo ocurre una NBA;
4. qué valor está observando un monitor;
5. qué significa samplear “antes” del clock;
6. qué diferencia introduce `#1step`.

Un clocking block **no elimina la semántica del scheduler**.

La encapsula.

---

# 13. `#1step`: uno de los conceptos más importantes

Un input skew:

```systemverilog
input #1step signal;
```

no significa simplemente:

```text
restar 1 ps
```

o:

```text
restar el timeprecision del módulo
```

La idea de `1step` es samplear en el time step inmediatamente anterior al evento de clock según la semántica de SystemVerilog.

Conceptualmente:

```text
                  posedge clk
                      │
         sample       │
           ▲          │
           │          │
        #1step        │
───────────┼──────────┼──────────── time
```

Esto permite capturar un valor estable previo al edge.

Es especialmente útil para monitores y BFMs que quieren representar exactamente:

> “qué valor vio el DUT en este clock edge”.

---

# 14. Driver + monitor con clocking blocks

Una interface podría separar ambas perspectivas:

```systemverilog
interface bus_if(input logic clk);

    logic        valid;
    logic        ready;
    logic [31:0] data;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output valid;
        output data;
        input  ready;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input valid;
        input ready;
        input data;
    endclocking

endinterface
```

Driver:

```systemverilog
forever begin
    seq_item_port.get_next_item(req);

    @(vif.drv_cb);

    vif.drv_cb.valid <= req.valid;
    vif.drv_cb.data  <= req.data;

    seq_item_port.item_done();
end
```

Monitor:

```systemverilog
forever begin
    @(vif.mon_cb);

    tr.valid = vif.mon_cb.valid;
    tr.ready = vif.mon_cb.ready;
    tr.data  = vif.mon_cb.data;

    ap.write(tr);
end
```

El beneficio no es solamente evitar una race.

La interface está expresando:

```text
Driver view
Monitor view
Timing relationship
Signal directions
Clock event
Sampling policy
Driving policy
```

---

# 15. La ventaja arquitectónica: encapsular el timing

Supongamos un agent reusable.

Sin clocking block, distintos componentes pueden terminar haciendo:

```systemverilog
@(posedge vif.clk);
```

```systemverilog
@(negedge vif.clk);
```

```systemverilog
#1ns;
```

```systemverilog
##1;
```

```systemverilog
vif.signal <= x;
```

```systemverilog
vif.signal = x;
```

El timing contract queda distribuido por todo el testbench.

Con clocking blocks:

```text
               bus_if
                  │
        ┌─────────┴─────────┐
        │                   │
     drv_cb               mon_cb
        │                   │
    UVM driver          UVM monitor
```

la política temporal queda más centralizada.

Desde una perspectiva de arquitectura de software, esto es atractivo.

---

# 16. Entonces, ¿qué tanto se usan en industria?

No parece existir un survey público serio que permita afirmar algo como:

```text
“el 72 % de los equipos UVM usa clocking blocks”
```

Por lo tanto, dar un porcentaje sería inventar precisión.

Pero sí podemos decir razonablemente:

### Se encuentran en:

- VIPs comerciales;
- BFMs reutilizables;
- flows UVM grandes;
- proyectos open-source industriales como OpenTitan;
- interfaces con protocolos síncronos;
- entornos donde existen diferentes niveles de simulación;
- equipos con style guides estrictos.

### También existen muchos testbenches reales que no los utilizan.

Especialmente cuando:

- el DUT es RTL;
- todos usan el mismo clock;
- se controla completamente la generación del clock;
- los drivers usan NBAs;
- el equipo conoce bien el scheduler;
- no se hace gate-level simulation;
- no existe necesidad de skews explícitos.

Por eso la práctica industrial parece mejor modelada así:

```text
                   Clocking blocks
                         │
          ┌──────────────┴──────────────┐
          │                             │
        useful                       optional
          │                             │
Reusable VIP                    Simple RTL TB
Gate-level                      Controlled clocks
Timing skew                     NBA discipline
Large teams                     Small environment
```

---

# 17. Matriz práctica

| Contexto | Valor de usar clocking blocks |
|---|---|
| TB pequeño RTL-only | Opcional |
| UVM block-level simple | Opcional / útil |
| Agent reusable | Recomendable |
| VIP reutilizable | Muy recomendable |
| VIP comercial | Frecuente / muy útil |
| Gate-level + SDF | Muy útil |
| Clock trees con delays | Muy útil |
| Protocolos síncronos complejos | Recomendable |
| Muchos developers | Recomendable |
| RTL limpio + mismo clock + NBA | Fácilmente prescindible |
| Asynchronous monitoring | Generalmente no aporta |
| Señales internas observadas con bind | Depende del caso |

---

# 18. Cuándo yo los usaría

## Los usaría casi seguro

### 1. Agent destinado a ser reusable

Por ejemplo:

```text
APB agent
AXI-lite agent
SPI agent
I2C agent
custom sensor interface
```

Porque quiero que el timing contract quede encapsulado.

### 2. VIP utilizado por más de un equipo

Cuanto más lejos esté el autor del VIP del usuario final, menos conviene depender de supuestos implícitos sobre scheduling.

### 3. Gate-level simulation

Especialmente si:

```text
clk_DUT != clk_TB en términos de delta/time
```

aunque conceptualmente representen el mismo clock.

### 4. Interfaz donde el protocolo define setup/hold explícitamente

Un clocking block expresa naturalmente esos offsets.

### 5. Entorno grande con muchos developers

Reduce grados de libertad en la forma de manejar señales.

---

# 19. Cuándo probablemente no los usaría

### 1. Unit test pequeño

Si tengo:

```systemverilog
@(posedge clk);
req <= next_req;
```

y controlo completamente DUT y TB, el clocking block puede agregar más sintaxis que valor.

### 2. Probe de señales internas

Para observación puramente asíncrona o debug:

```systemverilog
@(signal);
```

un clocking block puede no tener sentido.

### 3. TB educativo inicial

Antes de enseñar clocking blocks conviene enseñar:

```text
event scheduler
blocking assignment
non-blocking assignment
race condition
sampling
driving
```

Si el alumno aprende primero:

```systemverilog
clocking cb ...
```

como un conjuro mágico para “evitar races”, probablemente no entienda realmente qué está ocurriendo.

---

# 20. El mayor peligro: usar clocking blocks sin entenderlos

Algo que puede ser peor que no usarlos es mezclarlos incorrectamente.

Por ejemplo:

```systemverilog
clocking cb @(posedge clk);
    input foo;
endclocking
```

y luego:

```systemverilog
@(posedge vif.clk);
x = vif.cb.foo;
```

Esto mezcla dos dominios conceptuales:

```text
raw clock event
clocking block sampled value
```

La recomendación de Dave Rich es clara:

```systemverilog
@(vif.cb);
x = vif.cb.foo;
```

Es decir:

> si se adopta un clocking block, adoptar también su evento como parte del contrato.

---

# 21. Otro error frecuente: mezclar acceso raw y acceso vía clocking block

Ejemplo:

```systemverilog
a = vif.foo;
b = vif.cb.foo;
```

Aunque ambos nombres terminen conectando físicamente a la misma señal, pueden representar **distintas vistas temporales**.

Esto puede provocar un bug particularmente desagradable:

```text
waveform parece correcta
DUT parece correcto
monitor parece correcto
scoreboard falla intermitentemente
```

La causa termina siendo que una parte del TB observa la señal directamente y otra usa el valor sampleado por el clocking block.

Una buena regla es:

> Si una señal pertenece al timing contract de un clocking block, los componentes asociados al protocolo deberían accederla consistentemente a través de ese clocking block.

---

# 22. Clocking blocks no son “UVM”

Otro punto conceptual importante.

```text
SystemVerilog
│
├── interface
├── clocking block
├── class
├── randomization
├── assertions
└── ...
```

Mientras que:

```text
UVM
│
├── uvm_driver
├── uvm_monitor
├── uvm_agent
├── uvm_sequence
├── uvm_scoreboard
└── ...
```

UVM es una metodología/librería escrita sobre SystemVerilog.

Por eso:

> no existe realmente “clocking blocks en UVM” como mecanismo específico de UVM.

Son una feature de SystemVerilog que un entorno UVM puede decidir utilizar o no.

---

# 23. Mi interpretación de la discusión Dave Rich vs. “best practice”

La aparente contradicción desaparece si se formula de esta manera:

### Dave Rich está respondiendo:

> ¿Puedo escribir un TB correcto sin clocking blocks?

**Sí.**

### Un style guide como lowRISC está respondiendo:

> ¿Qué convención queremos que siga todo nuestro equipo?

**Use clocking blocks para interfaces síncronas.**

Ambas posiciones pueden ser correctas simultáneamente.

Es la diferencia entre:

```text
language correctness
```

y:

```text
engineering policy
```

---

# 24. Analogía de software

Un programador C/C++ excelente puede manejar manualmente:

```text
malloc
free
ownership
lifetimes
```

Eso no demuestra que:

```text
RAII / smart pointers
```

sean inútiles.

Simplemente significa que:

> la abstracción no es una condición necesaria para escribir código correcto.

Los clocking blocks cumplen un papel parecido:

```text
Scheduler knowledge
        ↓
manual timing discipline
```

versus:

```text
Clocking block
        ↓
encoded timing policy
```

El segundo reduce la cantidad de decisiones temporales dispersas por el código.

---

# 25. Recomendación para un curso introductorio de UVM

Para un curso de UVM orientado a designers/DV, yo **no presentaría clocking blocks como una obligación desde el principio**.

Usaría una progresión como ésta.

## Etapa 1 — scheduler básico

DUT:

```systemverilog
always_ff @(posedge clk)
    q <= d;
```

TB:

```systemverilog
@(posedge clk);
d <= next_d;
```

Explicar:

```text
¿Por qué el DUT ve el valor anterior?
¿Por qué usamos <=?
¿Qué pasaría con =?
```

---

## Etapa 2 — race intencional

Cambiar:

```systemverilog
d <= next_d;
```

por:

```systemverilog
d = next_d;
```

y analizar qué ocurre.

Objetivo:

> que el alumno entienda el problema antes de conocer la solución de mayor nivel.

---

## Etapa 3 — interface

Introducir:

```systemverilog
interface dut_if(input logic clk);
    logic d;
    logic q;
endinterface
```

---

## Etapa 4 — virtual interface

El UVM driver obtiene:

```systemverilog
virtual dut_if vif;
```

y maneja:

```systemverilog
@(posedge vif.clk);
vif.d <= req.d;
```

---

## Etapa 5 — clocking block

Finalmente:

```systemverilog
clocking drv_cb @(posedge clk);
    output d;
    input  q;
endclocking
```

Y cambiar el driver:

```systemverilog
@(vif.drv_cb);
vif.drv_cb.d <= req.d;
```

Ahora el alumno puede responder:

> “¿Qué problema está encapsulando esto?”

en lugar de simplemente memorizar sintaxis.

---

# 26. Cómo lo explicaría en una slide

## Clocking blocks are not mandatory UVM constructs

**Without clocking block**

```systemverilog
@(posedge vif.clk);
vif.req <= req.req;
```

Works correctly if:

```text
✓ same clock event
✓ RTL uses NBA correctly
✓ TB drives with NBA
✓ no unexpected clock delta delays
✓ timing assumptions are controlled
```

---

**With clocking block**

```systemverilog
@(vif.cb);
vif.cb.req <= req.req;
```

Adds:

```text
✓ explicit sampling semantics
✓ explicit driving semantics
✓ skew control
✓ timing encapsulation
✓ stronger interface contract
```

### Takeaway

> Clocking blocks are optional, but they can improve robustness and reuse.

---

# 27. Buena pregunta de entrevista

Una pregunta mucho más interesante que pedir la sintaxis sería:

> **Do we actually need clocking blocks in a UVM testbench?**

Una buena respuesta debería mencionar:

1. No son una feature de UVM sino de SystemVerilog.
2. No son estrictamente necesarios.
3. Un testbench puede ser race-free usando correctamente NBAs.
4. El scheduler determina qué valor observa cada proceso.
5. Clocking blocks encapsulan sampling/driving y skew.
6. Son especialmente valiosos en reusable VIP y gate-level.
7. Usarlos mal también puede introducir problemas.
8. Debe existir consistencia entre el evento del clocking block y sus señales sampleadas.

Ésta es una respuesta de nivel senior.

---

# 28. Posición técnica final

Mi posición sería:

### Correctness

```text
Clocking block != requisito
```

Un buen engineer puede escribir un TB determinista sin ellos.

### Architecture

```text
Clocking block = useful abstraction
```

Especialmente en:

```text
reusable agents
VIP
large teams
gate-level
timing-sensitive protocols
```

### Education

```text
scheduler first
clocking block second
```

Hay que entender la race antes de aprender la abstracción que la evita.

### Industry

```text
used, but not universal
```

Hay proyectos grandes que los adoptan como norma y otros que funcionan perfectamente sin ellos.

---

# 29. La frase que mejor resume todo

> **Clocking blocks should encode a timing policy you understand, not replace your understanding of SystemVerilog scheduling.**

---

# 30. Fuentes y links para seguir analizando

## Verification Academy — Dave Rich

### Clocking block usage in UVM — 2014

Dave Rich: si ya se conocen bien los testbenches Verilog, probablemente no sean necesarios.

https://verificationacademy.com/forums/t/clocking-block-usage-in-uvm/29900

---

### What are clocking blocks? — 2022

Dave Rich: son opcionales; pueden ser más útiles con RTL incorrecto o gate-level.

https://verificationacademy.com/forums/t/what-are-clocking-blocks/40479

---

### UVM scheduling and the need for Clocking Blocks — 2022

Probablemente el hilo técnicamente más interesante de toda la discusión.

Analiza:

- NBA;
- old/new value;
- delta cycles;
- gate-level;
- clock delays;
- commercial VIP;
- cuándo se pueden evitar clocking blocks.

https://verificationacademy.com/forums/t/uvm-scheduling-and-the-need-for-clocking-blocks/40325

---

### Use of clocking blocks in different types of testbench — 2024

Dave Rich reafirma que no son estrictamente necesarios y que funcionan como una capa de aislamiento.

https://verificationacademy.com/forums/t/use-of-clocking-blocks-in-different-types-of-testbench/47652

---

## Discusión histórica: clocking blocks como MUST

### Are using SystemVerilog program and clocking blocks poor coding practices? — 2012

Ajeetha Kumari da la postura opuesta: para señales síncronas recomienda usarlos siempre.

https://verificationacademy.com/forums/t/are-using-systemverilog-program-and-clocking-blocks-poor-coding-practices/27840

---

## Paper de Dave Rich / Siemens

### The Missing Link: The Testbench to DUT Connection

Muy recomendable.

Especialmente:

```text
Special design considerations
→ Race conditions and clocking blocks
```

https://static.sw.cdn.siemens.com/siemens-disw-assets/public/78349/en-US/Siemens-SW-The-missing-link-The-testbench-to-DUT-connection-WP-78349-C4.pdf

---

## lowRISC / OpenTitan

### DV Coding Style Guide

Buscar:

```text
Interfaces, Clocking Blocks, Modports
```

El guide dice explícitamente que se usen clocking blocks para samplear y manejar interfaces síncronas del DUT.

https://github.com/lowRISC/style-guides/blob/master/DVCodingStyle.md

---

### OpenTitan Common Interfaces

Ejemplos reales de interfaces utilizadas por el entorno DV.

`clk_if` y `clk_rst_if` incluyen clocking blocks.

https://opentitan.org/book/hw/dv/sv/common_ifs/index.html

---

# 31. Orden recomendado de lectura

Si querés profundizar el tema, sugiero este orden:

1. **Verification Academy — UVM scheduling and the need for Clocking Blocks**  
   El mejor punto de entrada conceptual.

2. **The Missing Link — Dave Rich**  
   Para entender el problema general TB↔DUT.

3. **Verification Academy — What are clocking blocks?**  
   Para ver claramente la postura “optional”.

4. **Verification Academy — 2014 thread**  
   Para ver la frase histórica que probablemente recordabas.

5. **lowRISC DV Coding Style Guide**  
   Para contrastar teoría con política de ingeniería real.

6. **OpenTitan Common Interfaces**  
   Para ver la construcción usada en un entorno grande.

7. **2012 thread con Ajeetha Kumari**  
   Para leer la escuela opuesta y formar criterio propio.

---

# 32. Preguntas para investigar después

Después de leer estas referencias, hay varios temas interesantes para profundizar:

### Scheduler

- ¿Exactamente en qué región se samplea un clocking block?
- ¿Cómo se relaciona `#1step` con la región Preponed?
- ¿Qué diferencia existe entre `input #0` e `input #1step`?
- ¿Qué ocurre con `output #0`?

### UVM

- ¿Cómo debería diseñarse un driver reusable con clocking blocks?
- ¿Driver y monitor deberían compartir el mismo clocking block?
- ¿Conviene usar modports además de clocking blocks?
- ¿Qué hacen los VIPs comerciales?

### Simulación

- ¿Qué soporta Verilator actualmente?
- ¿Hay diferencias de comportamiento entre Questa, VCS, Xcelium y Verilator?
- ¿Qué cambia en gate-level simulation + SDF?

### Arquitectura de TB

- ¿Es mejor exponer señales directamente o encapsularlas en tasks de la interface?
- ¿Cuándo conviene que el UVM driver ni siquiera conozca las señales?
- ¿Clocking block + interface tasks puede convertirse en un BFM más limpio?

---

# 33. Experimento sugerido

La forma definitiva de internalizar este tema sería construir un pequeño laboratorio con cuatro variantes:

```text
A. driver con blocking assignment
B. driver con NBA
C. clocking block input/output #0
D. clocking block con input #1step
```

y observar:

```text
DUT sees
Monitor sees
Waveform
simulation region
cycle N / cycle N+1
```

Ese experimento permite separar visualmente:

```text
race avoidance
sampling semantics
drive semantics
clocking block abstraction
```

y convertir un tema bastante abstracto del scheduler en algo totalmente intuitivo.

---

## Conclusión

Los clocking blocks no son una reliquia ni una obligación religiosa de UVM.

Son una herramienta de SystemVerilog para hacer explícita y reusable la relación temporal entre el TB y el DUT.

Dave Rich demuestra que:

> **podemos prescindir de ellos si entendemos y controlamos correctamente el scheduling.**

OpenTitan demuestra que:

> **un proyecto UVM grande y moderno puede decidir adoptarlos como regla de ingeniería.**

Las dos ideas son compatibles.

La mejor práctica no es simplemente:

```text
USE CLOCKING BLOCKS
```

ni:

```text
DON'T USE CLOCKING BLOCKS
```

sino:

```text
Understand the scheduler.
Define your timing policy.
Choose one consistent abstraction.
```
