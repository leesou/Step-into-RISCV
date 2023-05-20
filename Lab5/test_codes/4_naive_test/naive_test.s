lw x10, 36(x0) # miss, load to set1's way0, read 2nd word
lw x11, 44(x0) # hit set1's way0, read 4th word
add x12, x10, x11
sw x12, 40(x0) # hit set1's way0, read 3rd word
sw x12, 304(x0) # miss, load to set1's way1, write to 5th word
lw x13, 304(x0) # hit set1's way1, read 5th word
sw x13, 308(x0) # hit set1's way1, write to 6th word
sw x10, 568(x0) # miss, load to set1's way2, write to 7th word
lw x14, 828(x0) # miss, load to set1's way3, read 8th word
# access way 2->3->1->0
lw x15, 544(x0) # access set1's way2's 1st word
lw x16, 800(x0) # access set1's way3's 1st word
lw x17, 288(x0) # access set1's way1's 1st word
sw x14, 32(x0) # hit, write to set1's way0's 1st word
# flush cache's all lines
lw x0, 1060(x0) # FIFO: replace way0. LRU: replace way2, tag: 100
lw x0, 1316(x0) # FIFO: replace way1, LRU: replace way3, tag: 101
lw x0, 1572(x0) # FIFO: replace way2, LRU: replace way1, tag: 110
lw x0, 1828(x0) # FIFO: replace way3, LRU: replace way0, tag: 111


