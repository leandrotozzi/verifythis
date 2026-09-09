<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *1 de 6 · Tendencias*

**Según el estudio de Wilson 2024, ¿en qué se le va la mayor parte del tiempo a un verificador?**

- [ ] En escribir el testbench
- [x] En debug
- [ ] En correr regresiones
- [ ] En escribir la especificación

> **En debug** — el 47 % del tiempo del verificador se va ahí. Por eso el curso le dedica una sección entera al reporting: un scoreboard que sólo dice "falló" te deja justo en ese 47 %.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *2 de 6 · La spec de la ALU*

**Mientras la VTALU está ejecutando una operación, ¿qué tienen que hacer `start` y los operandos?**

- [ ] `start` baja enseguida; los operandos pueden cambiar
- [ ] Da igual: el DUT los registra en el primer flanco
- [ ] Los operandos tienen que cambiar en cada ciclo
- [x] `start` se mantiene en 1 y los operandos estables hasta que sube `done`

> **Estables hasta `done`** — es el protocolo del DUT, y es exactamente el motivo por el que existe el BFM: encapsular esa regla en un solo lugar para que ningún test se la olvide.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *3 de 6 · Cobertura funcional*

**El test corre 1000 operaciones al azar y la cobertura de *código* da 100 %. ¿Qué te dice eso sobre la verificación?**

- [ ] Que el DUT está verificado
- [x] Muy poco: dice qué RTL se **ejecutó**, no qué escenarios de la **spec** pasaron
- [ ] Que el testbench no tiene bugs
- [ ] Que ya se puede cerrar el plan de verificación

> **Muy poco** — la cobertura de código mide el DUT; la funcional mide la spec. Una feature que el diseñador nunca escribió da 100 % de líneas y 0 % de lo que importa, y el reporte no te lo va a decir.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *4 de 6 · covergroup*

**Declarás un `covergroup`, le hacés `new()`, corrés mil operaciones y el reporte da 0 %. ¿Qué es lo primero que hay que mirar?**

- [ ] Que los bins estén mal definidos
- [x] Que nadie esté llamando a `sample()`
- [ ] Que el DUT no esté respondiendo
- [ ] Que falten `ignore_bins`

> **El `sample()`** — el covergroup no se muestrea solo: alguien tiene que llamarlo, en el flanco o cuando llega una transacción. Sin esa llamada el código compila, corre, y el reporte da 0 sin una sola advertencia.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *5 de 6 · Interfaces y BFM*

**¿Qué gana el testbench cuando el protocolo se mueve a un BFM?**

- [x] El resto del TB deja de hablar en señales y pasa a hablar en operaciones
- [ ] Simula más rápido
- [ ] Se puede sintetizar el testbench
- [ ] Se ahorra tener que declarar un `clk`

> **Deja de hablar en señales** — el BFM traduce *una operación* a *un handshake de señales*. El tester, el scoreboard y el coverage no vuelven a tocar un cable: es el primer paso hacia UVM.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 1

#### *6 de 6 · clocking block*

**¿Hacen falta los clocking blocks para escribir un testbench UVM sin races?**

- [ ] Sí: sin clocking block, driver y DUT compiten siempre en el mismo flanco
- [ ] Sí, y además son parte de la librería UVM
- [x] No: con NBA en el driver y disciplina de scheduler alcanza — son una abstracción opcional, útil sobre todo en agents reutilizables
- [ ] No, y por eso no conviene usarlos nunca

> **No hacen falta, y conviene usarlos igual** — son de **SystemVerilog**, no de UVM. Lo que evita la race es entender el scheduler: un driver que maneja con `<=` contra un DUT que registra con `<=` ya es determinista. El clocking block no reemplaza ese entendimiento, lo **encapsula** — y ahí es donde paga: agents reutilizables, VIP, gate-level y protocolos con setup/hold en la spec.
