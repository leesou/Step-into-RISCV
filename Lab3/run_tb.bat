iverilog -o wave tb/tb_single_cycle.v
vvp -n wave -lxt2
gtkwave wave.vcd