section .data
filename: .asciz "input.txt"
yes_msg: .ascii "Yes\n"
no_msg: .ascii "No\n"

.section .bss
char_l: .byte 0
char_r: .byte 0

.section .text
.globl _start

_start:
    li a7, 56       #56 syscall for openat
    li a0, -100      #-100 is look in current directory
    la a1, filename  #load memory location
    li a2, 0        #open in read only mode
    li a3, 0        #