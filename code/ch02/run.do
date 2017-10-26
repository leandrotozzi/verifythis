if [file exists "work"] {vdel -all}
# Make the work lib
vlib work

# VHDL Files Compile
vcom -f dut.f

# SystemVerilog TB
vlog tinyalu_tb.sv

# Optimize and the simulate
vopt top -o top_optimized  +acc +cover=sbfec+tinyalu(rtl).
vsim top_optimized -coverage

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all
coverage exclude -src ../tinyalu_dut/single_cycle_add_and_xor.vhd -line 34 -code s
coverage exclude -src ../tinyalu_dut/single_cycle_add_and_xor.vhd -scope /top/DUT/add_and_xor -line 34 -code b
coverage save tinyalu.ucdb
vcover report tinyalu.ucdb 
vcover report tinyalu.ucdb -cvg -details

quit