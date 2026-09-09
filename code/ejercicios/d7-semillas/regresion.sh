# Day 7 exercise -- the same sequence, another seed.
#
# run.sh runs this file AFTER compiling, with all of this already in scope:
#
#   run_sim <args>   runs the simulation. SEED=N picks the seed, and prints it.
#                    It leaves that run's coverage in $VLT_OBJ/cov.$VLT_RUN.dat
#   $VLT_OBJ         the build directory
#
# What is asked:
#   1. run the same test with seeds 1, 2, 3, 4 and 5;
#   2. save each one's coverage in $VLT_OBJ/seed.<N>.dat;
#   3. merge the five into $VLT_OBJ/regresion.dat.
#
# The merge command is the same one cov_report uses in common.sh, and it is what
# in Questa would be the ucdb merge:
#
#   verilator_coverage --write <output.dat> <input1.dat> <input2.dat> ...
#
# run.sh takes care of the rest: it reads the five .dat and the merge, and tells
# you whether the regression added coverage or not.

# <<< HERE >>>  the five runs
SEED=1 run_sim +UVM_TESTNAME=regresion_test > /dev/null
cp "$VLT_OBJ/cov.$VLT_RUN.dat" "$VLT_OBJ/seed.1.dat"

# <<< HERE >>>  and the merge into $VLT_OBJ/regresion.dat
