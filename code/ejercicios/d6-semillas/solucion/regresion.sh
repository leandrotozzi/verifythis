# Solucion del ejercicio del dia 6 -- la misma sequence, otra semilla.
#
# Cinco corridas del MISMO test, y un merge. Eso es una regresion: no cinco
# tests distintos, el mismo test cinco veces con otra semilla.
for s in 1 2 3 4 5; do
  SEED=$s run_sim +UVM_TESTNAME=regresion_test > /dev/null
  cp "$VLT_OBJ/cov.$VLT_RUN.dat" "$VLT_OBJ/seed.$s.dat"
done

# El merge acumula: un bin que llena cualquiera de las cinco queda llenado. Es
# lo mismo que hace cov_report cuando un ejemplo corre mas de un test.
verilator_coverage --write "$VLT_OBJ/regresion.dat" "$VLT_OBJ"/seed.*.dat > /dev/null
