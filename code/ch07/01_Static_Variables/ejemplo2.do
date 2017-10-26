if [file exists "work"] {vdel -all}
vlib work
vlog ejemplo2.sv -quiet
vsim -c -voptargs="+acc" top -quiet
run -all
quit
