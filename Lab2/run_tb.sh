iverilog -o wave tb/tb_if_id.v
vvp -n wave -lxt2
gtkwave wave.vcd