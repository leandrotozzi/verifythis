<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *1 de 7 · La pregunta del día*

**Mil operaciones al azar, el scoreboard no reportó ningún error y el log termina en `PASS`. ¿Qué te falta para decir que el DUT está verificado?**

- [ ] Nada: mil operaciones sin un error es un DUT verificado
- [ ] Correr más semillas hasta que la cobertura de código llegue al 100 %
- [x] Saber qué habría dicho el log con un bug adentro: correrlo con el DUT mutado
- [ ] Reemplazar el scoreboard por assertions, que chequean el protocolo en el flanco exacto y no al final

> **Verlo fallar** — el `PASS` de un scoreboard que nunca vio un error no dice nada: pudo no haber comparado. `VTALU_BUG=1` da vuelta un bit del resultado y el testbench tiene que fallar; `make mutante` lo exige para los tres testbenches de los días 1 y 2.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *2 de 7 · La spec de la ALU*

**Mientras la VTALU está ejecutando una operación, ¿qué tienen que hacer `start` y los operandos?**

- [ ] `start` baja enseguida: es un pulso de arranque, y el DUT ya latcheó todo
- [ ] Da igual: el DUT los registra en el primer flanco
- [ ] Los operandos tienen que cambiar en cada ciclo
- [x] `start` en 1 y los operandos quietos hasta que sube `done`

> **Estables hasta `done`** — es el protocolo del DUT, y es exactamente el motivo por el que existe el BFM: encapsular esa regla en un solo lugar para que ningún test se la olvide. El primer distractor describe un protocolo real —arranque por pulso, operandos latcheados— que este DUT no tiene.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *3 de 7 · Cobertura funcional*

**El test corre 1000 operaciones al azar y la cobertura de *código* da 100 %. ¿Qué te dice eso sobre la verificación?**

- [ ] Que el DUT está verificado y el plan de verificación se puede cerrar
- [ ] Que el testbench no tiene bugs
- [ ] Que faltan pocos escenarios: el 100 % ya recorrió el diseño entero
- [x] Muy poco: mide el RTL que se ejecutó, no la spec

> **Muy poco** — la cobertura de código mide el DUT; la funcional mide la spec. Una feature que el diseñador nunca escribió da 100 % de líneas y 0 % de lo que importa, y el reporte no te lo va a decir.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *4 de 7 · covergroup*

**Declarás un `covergroup`, le hacés `new()`, corrés mil operaciones y el reporte da 0 %. ¿Qué es lo primero que hay que mirar?**

- [x] Que nadie esté llamando a `sample()`
- [ ] Que los bins estén mal definidos y no matcheen ningún valor
- [ ] Que el DUT no esté respondiendo
- [ ] Que falten `ignore_bins`

> **El `sample()`** — el covergroup no se muestrea solo: alguien tiene que llamarlo, en el flanco o cuando llega una transacción. Sin esa llamada el código compila, corre, y el reporte da 0 sin una sola advertencia.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *5 de 7 · Interfaces y BFM*

**¿Qué gana el testbench cuando el protocolo se mueve a un BFM?**

- [x] Deja de hablar en señales y pasa a hablar en operaciones
- [ ] Simula más rápido: una tarea del BFM le cuesta menos al simulador que mover cables
- [ ] Se puede sintetizar el testbench
- [ ] Se ahorra tener que declarar un `clk`

> **Deja de hablar en señales** — el BFM traduce *una operación* a *un handshake de señales*. El tester, el scoreboard y el coverage no vuelven a tocar un cable: es el primer paso hacia UVM.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *6 de 7 · El plan de verificación*

**En el plan de verificación, ¿qué va en la columna *Medida*?**

- [ ] Cuánto tarda el escenario en correr, para poder estimar la regresión
- [ ] El nombre del archivo del testbench que cubre esa fila
- [x] Qué bin se llena cuando el escenario pasa
- [ ] Cuántas veces hay que correr el test para darlo por cubierto

> **Qué bin se llena** — las cinco columnas son *Feature*, *Escenario*, *Estímulo*, *Chequeo* y *Medida*, y ésta es la que más cuesta: obliga a decidir **antes** qué se va a contar. Si queda vacía, nadie se va a enterar de que el escenario nunca pasó — un caso que el random no tocó y que no tiene bin es indistinguible de uno que pasó mil veces.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *7 de 7 · clocking block*

**¿Hacen falta los clocking blocks para escribir un testbench UVM sin races?**

- [ ] Sí: sin clocking block, driver y DUT compiten siempre en el mismo flanco
- [ ] Sí, y además son parte de la librería UVM
- [x] No: alcanza con NBA en el driver y disciplina de scheduler
- [ ] No: los reemplaza el `uvm_driver`, que ya muestrea en la región correcta

> **No hacen falta, y conviene usarlos igual** — son de **SystemVerilog**, no de UVM, y ningún `uvm_driver` muestrea por vos. Lo que evita la race es entender el scheduler: un driver que maneja con `<=` contra un DUT que registra con `<=` ya es determinista. El clocking block no reemplaza ese entendimiento, lo **encapsula** — y ahí es donde paga: agents reutilizables, VIP, gate-level y protocolos con setup/hold en la spec.
