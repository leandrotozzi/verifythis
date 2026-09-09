# Shared Verilator flags. Each example has its own run.sh; this exists only so
# the UVM invocation is not repeated eleven times.
#
# LANGUAGE POLICY (phase 9.2). Comments in code/ are in ENGLISH: they document
# how the code works, they are what the {{code:}} blocks show on the slides, and
# they have to read the same in the Spanish and the English course. What stays
# in the course language is the text ADDRESSED TO THE STUDENT: the strings this
# script prints at runtime (below), the TODO(exercise <dir>) markers in
# code/ejercicios, and the messages its correctors print. That text is course
# material, not code documentation, and phase 12.2 translates it together with
# the slides.
#
#   . "$(dirname "${BASH_SOURCE[0]}")/../verilator/common.sh"
#   vlt     top -f sv.f      # build the example (top = top-level module)
#   run_sim                  # run whatever the previous vlt built
#
# Functions:
#   vlt      <top> <args>    build an example without UVM
#   vlt_uvm  <top> <args>    same, with UVM 2020.3.1 linked in
#   run_sim  <args>          run the binary from the last vlt/vlt_uvm; the output
#                            also lands in $VLT_LOG
#
# Environment variables:
#   VTALU_BUG=1              passes +VTALU_BUG, which flips bit 0 of the DUT's
#                            result. It is the NEGATIVE test: the example has to
#                            FAIL. 'make mutante' runs it and demands the
#                            failure. Examples that do not instantiate the vtalu
#                            ignore the plusarg.
#   SEED=N                   random seed: passes +verilator+seed+N. Without
#                            SEED, Verilator uses its own, which is fixed too
#                            (that is why the numbers in the course do not move).
#                            run_sim prints which one it used. See
#                            code/ejercicios and the "otra semilla, y de nuevo"
#                            slide in the Transactions section.
#   OBJCACHE=ccache          set automatically if ccache is installed
#   cov_report               prints the coverage of the last run_sim
#   expect_output <pattern> <args>
#                            runs and requires that text in the output. For the
#                            examples that end in $fatal on purpose.
#   expect_in_log <n> <pattern>
#                            demands that the LAST run_sim printed that text n
#                            times. For the examples that demonstrate instead of
#                            verifying: what they teach is what they print.
#   intocables               checks the ./intocables.sha of an exercise: the
#                            files the statement says NOT to touch.
VLT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UVM_HOME=${UVM_HOME:-$VLT_DIR/../.uvm}

# ccache in front of g++. Verilator uses it ONLY if OBJCACHE is defined.
# What it saves and what it does not, measured on u4/tests on a 12-core laptop:
#
#   make u4/tests the first time ................... 92 s
#   make u4/tests with obj_dir deleted ............. 15 s   (40/40 hits)
#   make u4/env with the u4/tests cache warm ....... 91 s   ( 9/40 hits)
#
# In other words: it helps when rebuilding THE SAME THING -- the section you
# already ran, the exercise where you touched one file, last night's CI run --
# and not the section next door, because Verilator renames the symbols by design
# and the C++ it generates for UVM does not end up being the same file.
# If ccache is not installed nothing happens: it builds as always.
command -v ccache >/dev/null 2>&1 && export OBJCACHE=${OBJCACHE:-ccache}

# -j 0 = all cores. UVM builds take several minutes.
#
# VLT_BUILD_JOBS lowers ONLY the C++ compilation, not the verilate step nor the
# number of files the output is split into (that is --output-groups, already
# fixed by the -j 0 above). Verilator groups the ~2300 .cpp files UVM generates
# into one bucket per core, and each bucket is a g++ of nearly a gigabyte:
# twelve at once OOM-kill a 4 GB VM. Empty = all cores, as always.
# The Docker image uses it; see docs/docker.md.
# VLT_TRACE=1 adds the waveform dump for GTKWave. Two things go together and
# both are needed: --trace asks Verilator for dump support, and +define+VLT_TRACE
# turns on the top's $dumpfile/$dumpvars -- which would not compile without
# --trace. Only code/u2/convencional and the d1b exercise carry that block; they
# are where reading waveforms is taught.
#
#   cd code/u2/convencional && VLT_TRACE=1 bash run.sh && gtkwave vtalu.vcd
VLT_FLAGS="--binary --timing -j 0 --quiet-build --quiet-stats${VLT_BUILD_JOBS:+ --build-jobs $VLT_BUILD_JOBS}${VLT_TRACE:+ --trace +define+VLT_TRACE}"

# One obj_dir per top: u3/clases builds three tops in the same directory.
_vlt_setup() {
  VLT_TOP=$1; VLT_OBJ=obj_dir/$VLT_TOP; VLT_RUN=0
  mkdir -p "$VLT_OBJ"; rm -f "$VLT_OBJ"/cov.*.dat
}

vlt() {
  _vlt_setup "$1"; shift
  verilator $VLT_FLAGS --top-module "$VLT_TOP" --Mdir "$VLT_OBJ" -o sim "$@"
}

vlt_uvm() {
  _vlt_setup "$1"; shift
  if [ ! -f "$UVM_HOME/src/uvm_pkg.sv" ]; then
    echo "UVM is missing in $UVM_HOME — run: sh tools/get-uvm.sh" >&2
    return 1
  fi
  # --vpi: UVM reads the command line with vpi_get_vlog_info().
  # WIDTHTRUNC/UNSIGNED come from the UVM macros expanded INSIDE the course's
  # own files, so the library waiver is not enough: they have to be silenced by
  # name. Everything else stays fatal.
  #
  # The UVM library's own warnings no longer need silencing by hand: Verilator
  # 5.052 ships verilated_std_waiver.vlt and applies it on its own
  # (--no-std-waiver disables it). This used to pass a hand-written uvm.vlt,
  # which was deleted.
  verilator $VLT_FLAGS --vpi --top-module "$VLT_TOP" --Mdir "$VLT_OBJ" -o sim \
    -Wno-WIDTHTRUNC -Wno-UNSIGNED \
    -CFLAGS "-I$VLT_DIR -I$UVM_HOME/src/dpi" \
    +incdir+"$UVM_HOME/src" "$UVM_HOME/src/uvm_pkg.sv" "$VLT_DIR/uvm_dpi.cc" \
    "$@"
}

# One coverage .dat per run, numbered, inside obj_dir. If the build has no
# --coverage-user nothing is written and the plusarg does no harm.
#
# +UVM_NO_RELNOTES: UVM 2020 prints 15 lines of release notes on every run. It
# is noise that has nothing to do with the example. Examples without UVM ignore
# the plusarg.
#
# UVM does not exit with a non-zero code when it reports a uvm_error: a
# scoreboard counting a thousand mismatches would still end up as "PASS". So on
# top of the exit code, the Report Summary is read. Examples without UVM do not
# print it and are unaffected. u4/reporting breaks the scoreboard on purpose: it
# exports UVM_ERRORS_OK=1 before running.
# The run also lands in $VLT_LOG, which the exercises grep to grade themselves
# without running the simulation again.
run_sim() {
  VLT_RUN=$((VLT_RUN + 1))
  VLT_LOG=$VLT_OBJ/run.$VLT_RUN.log
  echo "    seed: ${SEED:-the Verilator default, which is fixed too}"
  "./$VLT_OBJ/sim" +UVM_NO_RELNOTES ${SEED:++verilator+seed+$SEED} \
    ${VTALU_BUG:++VTALU_BUG} \
    +verilator+coverage+file+"$VLT_OBJ/cov.$VLT_RUN.dat" "$@" 2>&1 | tee "$VLT_LOG"
  local rc=${PIPESTATUS[0]}
  [ "$rc" -eq 0 ] || return "$rc"
  [ -n "${UVM_ERRORS_OK:-}" ] || uvm_summary_ok "$VLT_LOG"
}

# The summary lines look like "UVM_ERROR :    0"; individual error lines carry
# "@" or the file name in the second field, so the ":" tells them apart.
uvm_summary_ok() {
  awk '$1 ~ /^UVM_(ERROR|FATAL)$/ && $2 == ":" && $3 + 0 > 0 {
         print "FAIL: the Report Summary counts " $3 " " $1 > "/dev/stderr"; bad = 1 }
       END { exit bad + 0 }' "$1"
}

# The files an exercise says NOT to touch, plus the ones its grading leans on.
# Four exercises put their whole point inside one of them, and until now the ban
# lived only in the README while the corrector read only the log: in d3,
# replacing random_tester::type_id::create with mult_tester::... inside env.svh
# passes in green without a single set_type_override, which IS the exercise.
#
# The list and its hashes live in intocables.sha, next to the run.sh. To
# regenerate it after changing one of those files on purpose:
#
#   cd code/ejercicios/d3 && sha256 chequeo.svh env.svh vtalu_pkg.sv tb.f dut.f > intocables.sha
#
# It runs BEFORE compiling: there is no point in waiting two minutes for UVM to
# say that the file you were not supposed to touch is the one that moved. And
# `make ejercicios` runs the eighteen solutions, so a hash that goes stale
# because the course code changed shows up on the next run and not months later.
#
# shasum comes with perl and is the one macOS has; sha256sum comes with
# coreutils and is the one Debian has. The two write and read the same format.
sha256() {
  if command -v shasum > /dev/null 2>&1; then shasum -a 256 "$@"; else sha256sum "$@"; fi
}

intocables() {
  [ -f intocables.sha ] || return 0
  local movidas
  # "FAILED" and "FAILED open or read": a deleted file counts as touched.
  movidas=$(sha256 -c intocables.sha 2>/dev/null | sed -n 's/: FAILED.*$//p')
  [ -n "$movidas" ] || return 0
  {
    echo "not yet: the exercise is doing this WITHOUT touching these files, and they moved:"
    echo "$movidas" | sed 's/^/    /'
    echo "  Put them back --git checkout -- <file>-- and the point of the exercise comes back"
    echo "  with them. If you changed them on purpose, regenerate intocables.sha."
  } >&2
  return 1
}

# Demands that the last run_sim printed something exactly N times. The examples
# that DEMONSTRATE instead of verifying -- the ones without a scoreboard -- have
# no other way of failing: what they teach IS what they print, and without this a
# Verilator that stopped dispatching a virtual method would leave the example
# green with the lesson upside down. N and not "at least one" because the count
# is usually the lesson: the fernet served twice, once through its own handle and
# once through the base one.
#
#   expect_in_log 2 'Fernet: 70/30'
expect_in_log() {
  local got
  got=$(grep -cF "$2" "$VLT_LOG" || true)
  [ "$got" -eq "$1" ] && return 0
  echo "EXPECTED \"$2\" $1 time(s) in the output, found $got" >&2
  return 1
}

# Functional coverage (covergroups). Ask for --coverage-user when building: that
# leaves out line/toggle/branch, which are not the topic. Verilator 5.052
# measures value bins and implicit crosses; it ignores transition bins and
# crosses with binsof/intersect (COVERIGN). See repro-cg-transition.sv.
#
# Examples that run more than one test (random_test and add_test) add one run
# each: they have to be MERGED, like the ucdb merge in Questa. Without that the
# last test overwrites the previous one and the number that comes out is
# add_test's alone.
cov_report() {
  local dats
  dats=$(ls "$VLT_OBJ"/cov.*.dat 2>/dev/null)
  [ -n "$dats" ] || { echo "no coverage was generated in $VLT_OBJ" >&2; return 1; }
  verilator_coverage --write "$VLT_OBJ/coverage.dat" $dats > /dev/null
  verilator_coverage "$VLT_OBJ/coverage.dat" | tee "$VLT_OBJ/cov.report"
  # A covergroup that measures 0 % is not "low coverage": it is a covergroup
  # NOBODY SAMPLED -- the analysis port left unplugged, the write() that never
  # gets called, the sample() dropped out of the loop. It prints as a tidy
  # report, the run ends in 0 UVM_ERROR, and the example passes without having
  # measured a thing. The number itself is not asserted --it moves with the
  # seed-- but zero is not a number, it is a symptom.
  if grep -q '^  covergroup *: *0\.0%' "$VLT_OBJ/cov.report"; then
    echo "FAIL: the covergroup measured 0 % — nobody sampled it" >&2
    return 1
  fi
}

expect_output() {
  local pattern=$1; shift
  local out
  out=$("./$VLT_OBJ/sim" "$@" 2>&1) || true; echo "$out"
  case "$out" in
    *"$pattern"*) ;;
    *) echo "EXPECTED in the output: $pattern" >&2; return 1 ;;
  esac
}
