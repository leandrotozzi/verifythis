if [file exists "work"] {vdel -all}
vlib work

vcom -f dut.f

vlog -f tb.f
vopt top -o top_optimized  +acc +cover=sbfec+tinyalu(rtl).

vsim top_optimized -coverage +UVM_TESTNAME=random_test

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all
coverage save random_test.ucdb


vsim top_optimized -coverage +UVM_TESTNAME=add_test

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all
coverage save add_test.ucdb

vcover merge  tinyalu.ucdb random_test.ucdb add_test.ucdb
vcover report tinyalu.ucdb -cvg -details
quit
