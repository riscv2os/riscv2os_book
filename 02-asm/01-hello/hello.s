.section .data
hello: .asciz "Hello, RISC-V!"

.section .text
.globl _start
_start:
    li a7, 4         # syscall for write
    li a0, 1         # file descriptor 1 (stdout)
    la a1, hello     # address of the string
    li a2, 14        # length of the string
    ecall            # make the syscall

    li a7, 10        # syscall for exit
    ecall            # make the syscall
