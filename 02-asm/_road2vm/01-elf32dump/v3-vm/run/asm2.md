

```
root@localhost:~/riscv2os_book/02-asm/_road2vm/01-elf32dump/v3-vm/run# riscv64-unknown-elf-gcc -march=rv32g -mabi=ilp32 -c -S asm2.c -o asm2.s
root@localhost:~/riscv2os_book/02-asm/_road2vm/01-elf32dump/v3-vm/run# cat asm2.s
        .file   "asm2.c"
        .option nopic
        .attribute arch, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0"
        .attribute unaligned_access, 0
        .attribute stack_align, 16
        .text
        .section        .rodata
        .align  2
.LC0:
        .string "hello"
        .text
        .align  2
        .globl  main
        .type   main, @function
main:
        addi    sp,sp,-32
        sw      s0,28(sp)
        addi    s0,sp,32
        lui     a5,%hi(.LC0)
        addi    a5,a5,%lo(.LC0)
        sw      a5,-20(s0)
        lw      a5,-20(s0)
 #APP
# 11 "asm2.c" 1
        la a7, a5
ecall

# 0 "" 2
 #NO_APP
        sw      a5,-20(s0)
        li      a5,0
        mv      a0,a5
        lw      s0,28(sp)
        addi    sp,sp,32
        jr      ra
        .size   main, .-main
        .ident  "GCC: (13.2.0-11ubuntu1+12) 13.2.0"
```