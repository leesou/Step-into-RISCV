iverilog -o wave tb/tb_cache.v
vvp -n wave -lxt2
gtkwave wave.vcd