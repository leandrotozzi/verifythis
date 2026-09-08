# Todo lo que se corre en este repo. Verilator es el unico simulador.
#
#   make doctor     dice si esta maquina puede correr el curso, y que falta
#   make            corre los 38 ejemplos (lento: los de UVM tardan minutos)
#   make u4          corre una unidad entera
#   make u4/tests    corre un ejemplo suelto
#   make rapido     solo los ejemplos sin UVM (segundos): lo que corre el CI
#   make matrix     idem que 'make', y ademas regenera docs/verilator.md
#   make uvm        baja UVM 2020.3.1 a code/.uvm/ (se hace solo si hace falta)
#   make ejercicios corre las SOLUCIONES de code/ejercicios/ (lento: nueve usan UVM)
#   make regresion  el mismo test con N semillas + merge de cobertura + reporte HTML
#   make figs       regenera las figuras de tendencias (res/trends/*.svg)
#   make machete    res/machete.html -> docs/machete-uvm.pdf (una carilla, A4)
#   make deck       regenera index.html desde slides/
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

.PHONY: all doctor rapido matrix uvm ejercicios regresion figs machete deck check clean $(UNIDADES) $(EJEMPLOS)

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
