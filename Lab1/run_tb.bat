iverilog -o wave tb/tb_alu.v
vvp -n wave -lxt2
gtkwave wave.vcd