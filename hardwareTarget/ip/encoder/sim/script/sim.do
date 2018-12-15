vlib work
vcom -93 -work work ../../src/encoder_top.vhd
vcom -93 -work work ../src/encoder_tb.vhd
vsim -novopt encoder_tb
do wave.do
run 3 us
