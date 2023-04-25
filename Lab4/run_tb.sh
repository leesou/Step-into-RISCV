iverilog -o wave tb/tb_pipeline.v
vvp -n wave -lxt2
gtkwave wave.vcd