lw x10, 0(x0) # 000000000000 00000 010 01010 0000011
addi x12, x10, 1919 # 011101111111 01010 000 01100 0010011
sw x12, 20(x0) # 0000000 01100 00000 010 10100 0100011
addi x13, x10, 4095 # 111111111111 01010 000 01101 0010011
sw x13, 24(x0) # 0000000 01101 00000 010 11000 0100011

slli x14, x10, 15 # 0000000 01111 01010 001 01110 0010011
sw x14, 28(x0) # 0000000 01110 00000 010 11100 0100011
srli x15, x14, 16 # 0000000 10000 01110 101 01111 0010011
sw x15, 32(x0) # 0000001 01111 00000 010 00000 0100011
srai x16, x14, 8 # 0100000 01000 01110 101 10000 0010011
sw x16, 36(x0) # 00000001 10000 00000 010 00100 0100011

slti x17, x10, 4095 # 111111111111 01010 010 10001 0010011
sw x17, 40(x0) # 0000001 10001 00000 010 01000 0100011
sltiu x18, x10, 4095 # 111111111111 01010 011 10010 0010011
sw x18, 44(x0) # 0000001 10010 00000 010 01100 0100011

xori x19, x10, 2048 # 100000000000 01010 100 10011 0010011
sw x19, 48(x0) # 0000001 10011 00000 010 10000 0100011
ori x20, x10, 2133 # 100001010101 01010 110 10100 0010011
sw x20, 52(x0) # 0000001 10100 00000 010 10100 0100011
andi x21, x10, 1445 # 010110100101 01010 111 10101 0010011
sw x21, 56(x0) # 0000001 10101 00000 010 11000 0100011