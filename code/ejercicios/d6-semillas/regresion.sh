# Ejercicio del dia 6 -- la misma sequence, otra semilla.
#
# Este archivo lo corre run.sh DESPUES de compilar, con todo esto ya en scope:
#
#   run_sim <args>   corre la simulacion. SEED=N elige la semilla, y la imprime.
#                    Deja la cobertura de esa corrida en $VLT_OBJ/cov.$VLT_RUN.dat
#   $VLT_OBJ         el directorio del build
#
# Se pide:
#   1. correr el mismo test con las semillas 1, 2, 3, 4 y 5;
#   2. guardar la cobertura de cada una en $VLT_OBJ/seed.<N>.dat;
#   3. mergear las cinco en $VLT_OBJ/regresion.dat.
#
# El comando del merge es el mismo que usa cov_report en common.sh, y es lo que
# en Questa seria el merge de ucdb:
#
#   verilator_coverage --write <salida.dat> <entrada1.dat> <entrada2.dat> ...
#
# Del resto se encarga run.sh: lee los cinco .dat y el merge, y te dice si la
# regresion sumo cobertura o no.

# <<< ACA >>>  las cinco corridas
SEED=1 run_sim +UVM_TESTNAME=regresion_test > /dev/null
cp "$VLT_OBJ/cov.$VLT_RUN.dat" "$VLT_OBJ/seed.1.dat"

# <<< ACA >>>  y el merge en $VLT_OBJ/regresion.dat
