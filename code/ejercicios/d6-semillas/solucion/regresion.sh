# Solution to the day 6 exercise -- the same sequence, another seed.
#
# Five runs of the SAME test, and a merge. That is a regression: not five
# different tests, the same test five times with another seed.
for s in 1 2 3 4 5; do
  SEED=$s run_sim +UVM_TESTNAME=regresion_test > /dev/null
  cp "$VLT_OBJ/cov.$VLT_RUN.dat" "$VLT_OBJ/seed.$s.dat"
done

# The merge accumulates: a bin filled by any of the five stays filled. It is
# the same thing cov_report does when an example runs more than one test.
verilator_coverage --write "$VLT_OBJ/regresion.dat" "$VLT_OBJ"/seed.*.dat > /dev/null
