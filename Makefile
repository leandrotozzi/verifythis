# Todo lo que se corre en este repo. Verilator es el unico simulador.
#
#   make doctor     dice si esta maquina puede correr el curso, y que falta
#   make            corre los 38 ejemplos (lento: los de UVM tardan minutos)
#   make u4          corre una unidad entera
#   make u4/tests    corre un ejemplo suelto
#   make rapido     solo los ejemplos sin UVM (segundos): lo que corre el CI
#   make mutante    rompe el DUT a proposito y exige que los ejemplos FALLEN
#   make repros     corre los repros de code/verilator/ (evidencia de docs/verilator.md)
#   make matrix     idem que 'make', y ademas regenera docs/verilator.md
#   make uvm        baja UVM 2020.3.1 a code/.uvm/ (se hace solo si hace falta)
#   make ejercicios corre las SOLUCIONES de code/ejercicios/ (lento: once usan UVM)
#   make regresion  el mismo test con N semillas + merge de cobertura + reporte HTML
#   make figs       regenera las figuras de tendencias (res/trends/*.svg)
#   make machete    res/machete.html -> docs/machete-uvm.pdf (una carilla, A4)
#   make deck       regenera index.html y en/index.html desde slides/
#   make check      lo obligatorio antes de commitear: build --check + overflow
#   make clean      borra los obj_dir de Verilator
#
# Requiere: verilator >= 5.050 (los covergroups entraron ahi) y node.

# Un ejemplo = el directorio de un run*.sh. La lista no esta escrita en ningun
# lado: sale de los propios runners, asi que un ejemplo nuevo entra solo.
RUNNERS  := $(wildcard code/u*/*/run*.sh code/u*/*/*/run*.sh)
UNIDADES := $(notdir $(wildcard code/u[0-9]))
EJEMPLOS := $(patsubst code/%/,%,$(sort $(dir $(RUNNERS))))
# UVM_HOME lo lee tambien common.sh. La imagen de Docker la trae en /opt/uvm y
# la exporta: asi no se rebaja en cada contenedor. Ver docs/docker.md.
UVM_HOME ?= code/.uvm
UVM      := $(UVM_HOME)/src/uvm_pkg.sv

.PHONY: all doctor rapido mutante repros matrix uvm ejercicios regresion figs machete deck check clean $(UNIDADES) $(EJEMPLOS)

all: $(UNIDADES)

# Lo primero que conviene correr en una maquina nueva. No compila nada: mira que
# haya verilator >= 5.050, z3 y ccache, y dice como instalar lo que falte.
doctor:
	@sh tools/doctor.sh

# Sirve tanto la unidad ('make u3') como el ejemplo ('make u3/factory'): el
# filter matchea por prefijo de ruta, y algunos ejemplos tienen varios run*.sh.
$(UNIDADES) $(EJEMPLOS): $(UVM)
	@for r in $(filter code/$@/%,$(RUNNERS)); do \
	  echo "==> $$r"; \
	  ( cd $$(dirname $$r) && bash ./$$(basename $$r) ) || exit 1; \
	done

# Los ejemplos que NO usan UVM: compilan y corren en segundos, contra los
# minutos que tarda cada uno de los de UVM. Es lo que corre el CI en cada push;
# los de UVM van en la corrida nocturna. La lista no esta escrita en ningun
# lado: se deduce de que el run.sh llame a vlt_uvm o no, asi que un ejemplo
# nuevo entra solo. (Ver arriba como se arma la lista de runners.)
rapido:
	@for r in $(RUNNERS); do \
	  grep -q vlt_uvm "$$r" && continue; \
	  echo "==> $$r"; \
	  ( cd $$(dirname $$r) && bash ./$$(basename $$r) >/dev/null ) \
	    && echo "    ok" || { echo "    FALLA"; exit 1; }; \
	done

# El test negativo. Rompe el DUT a proposito --+VTALU_BUG da vuelta el bit 0 de
# 'result'-- y EXIGE que el ejemplo FALLE. Sin esto, "el ejemplo corre" es todo
# lo que sabemos: un scoreboard desconectado, un uvm_error que nadie puede
# disparar y un cov_report vacio pasan igual de verdes.
#
#   make mutante                                  los tres sin UVM: segundos
#   make mutante MUTANTES="u4/tests u7/sequences" los de UVM: minutos
#
# Solo entran ejemplos que instancian el vtalu Y cuyo run.sh aborta con el error
# (los de u8 y u9 ya traen su propia mutacion y chequean el resultado a mano;
# u4/reporting exporta UVM_ERRORS_OK).
MUTANTES ?= u2/convencional u2/interfaces-bfm u3/tb-en-objetos
mutante: $(UVM)
	@for e in $(MUTANTES); do \
	  for r in code/$$e/run*.sh; do \
	    printf '==> %-30s ' "$$r"; \
	    if ( cd $$(dirname $$r) && VTALU_BUG=1 bash ./$$(basename $$r) ) >/dev/null 2>&1; then \
	      echo "NO FALLO — el chequeo de este ejemplo no atrapa el bug"; exit 1; \
	    else echo "ok (fallo, que es lo que tenia que pasar)"; fi; \
	  done; \
	done

# Los cinco repros de code/verilator/ son la evidencia de docs/verilator.md y la
# justificacion de los "ifndef VERILATOR" que hay en dos covergroups del curso.
# Hasta que existio este target no los corria nadie, y se notaba: repro-cg-transition.sv
# no compilaba (una linea de comentario que arrancaba con el nombre de la
# herramienta de cobertura lo hacia abortar con BADVLTPRAGMA, porque Verilator la
# lee como un meta-comentario mal formado) y nadie se habia enterado.
#
# repro-cg-options.sv chequea sus seis numeros solo y termina en $fatal si alguno
# se movio. El ultimo paso es al reves: exige que -DT1 SIGA sin compilar, porque
# el dia que Verilator implemente los bins de transicion hay que sacarles el
# ifndef a los covergroups, y sin esto el curso los iba a seguir escondiendo.
# Segundos.
REPROS := repro-cg-options repro-dist-with repro-solve-before repro-vif-task repro-cg-transition
repros:
	@cd code/verilator && for f in $(REPROS); do \
	  printf '==> %-22s ' "$$f"; mkdir -p obj_dir/$$f; \
	  verilator --binary --timing -j 0 --quiet-build --quiet-stats --coverage-user \
	    -Wno-fatal --top-module top --Mdir obj_dir/$$f -o sim $$f.sv >/dev/null 2>&1 \
	    && ./obj_dir/$$f/sim >/dev/null 2>&1 \
	    && echo ok || { echo FALLA; exit 1; }; \
	done; \
	printf '==> %-22s ' "bins de transicion"; \
	if verilator --lint-only --timing -DT1 repro-cg-transition.sv >/dev/null 2>&1; then \
	  echo "COMPILA: Verilator ya los implementa — saca el ifndef VERILATOR de los covergroups"; \
	  exit 1; \
	else echo "siguen sin implementarse (el ifndef VERILATOR sigue haciendo falta)"; fi

# La matriz corre lo mismo pero tolera fallas y las tabula.
matrix: $(UVM)
	sh tools/verilator-matrix.sh

uvm: $(UVM)
$(UVM):
	sh tools/get-uvm.sh

# Los ejercicios fallan a proposito hasta que el alumno los resuelve, asi que
# 'make' no los corre. Esto corre las soluciones, que es la unica forma de saber
# que las quince siguen siendo resolubles cuando cambia el codigo del curso.
ejercicios: $(UVM)
	@for r in code/ejercicios/*/run.sh; do \
	  printf '==> %-28s ' "$$(dirname $$r)"; \
	  ( cd $$(dirname $$r) && SOLUCION=1 bash ./run.sh >/dev/null 2>&1 ) \
	    && echo ok || { echo FALLA; exit 1; }; \
	done

# Una regresion: el MISMO test, N semillas, y el merge de la cobertura. El
# reporte dice que bins quedaron ABIERTOS, que es la unica pregunta util despues
# de una regresion. Es el ejercicio d6-semillas hecho herramienta.
#
#   make regresion
#   make regresion EJEMPLO=u6/transactions N=20
EJEMPLO ?= u7/sequences
N       ?= 10
regresion: $(UVM)
	sh tools/regresion.sh $(EJEMPLO) $(N)

figs:
	node tools/trends.mjs

# El machete de una carilla. El HTML se abre con doble clic; esto saca el PDF
# que se imprime, y va commiteado. Necesita Chrome, igual que 'npm run pdf'.
machete:
	node tools/machete.mjs

deck:
	npm run build

check:
	npm run check
	npm run overflow
	bash tools/test-run-sim.sh

clean:
	find code -name obj_dir -type d -exec rm -rf {} +
