
```
root@localhost:~/riscv2os_book/02-asm/_vm/rv32dump/01# ./run2exe.sh
/usr/lib/gcc/riscv64-unknown-elf/13.2.0/../../../riscv64-unknown-elf/bin/ld: warning: cannot find entry symbol _start; defaulting to 00010074

addmain_rv32.o:     file format elf32-littleriscv


Disassembly of section .text:

00010074 <add>:
   10074:       fe010113                addi    sp,sp,-32
   10078:       00812e23                sw      s0,28(sp)
   1007c:       02010413                addi    s0,sp,32
   10080:       fea42623                sw      a0,-20(s0)
   10084:       feb42423                sw      a1,-24(s0)
   10088:       fec42703                lw      a4,-20(s0)
   1008c:       fe842783                lw      a5,-24(s0)
   10090:       00f707b3                add     a5,a4,a5
   10094:       00078513                mv      a0,a5
   10098:       01c12403                lw      s0,28(sp)
   1009c:       02010113                addi    sp,sp,32
   100a0:       00008067                ret

000100a4 <main>:
   100a4:       ff010113                addi    sp,sp,-16
   100a8:       00112623                sw      ra,12(sp)
   100ac:       00812423                sw      s0,8(sp)
   100b0:       01010413                addi    s0,sp,16
   100b4:       00500593                li      a1,5
   100b8:       00300513                li      a0,3
   100bc:       fb9ff0ef                jal     10074 <add>
   100c0:       00000793                li      a5,0
   100c4:       00078513                mv      a0,a5
   100c8:       00c12083                lw      ra,12(sp)
   100cc:       00812403                lw      s0,8(sp)
   100d0:       01010113                addi    sp,sp,16
   100d4:       00008067                ret
ELF 類型: 2
機器類型: 243
進入點位址: 0x10074
段表偏移量: 812
程式表偏移量: 52
段名稱:                      段位址: 0x       0 段大小:        0
段名稱:                .text 段位址: 0x   10074 段大小:      100
=====> 程式段 ....
.text 段的前幾個字節:
13 01 01 fe 23 2e 81 00 13 04 01 02 23 26 a4 fe 
23 24 b4 fe 03 27 c4 fe 83 27 84 fe b3 07 f7 00 
13 85 07 00 03 24 c1 01 13 01 01 02 67 80 00 00 
13 01 01 ff 23 26 11 00 23 24 81 00 13 04 01 01 
93 05 50 00 13 05 30 00 ef f0 9f fb 93 07 00 00 
13 85 07 00 83 20 c1 00 03 24 81 00 13 01 01 01 
67 80 00 00 
段名稱:             .comment 段位址: 0x       0 段大小:       34
段名稱:    .riscv.attributes 段位址: 0x       0 段大小:       78
段名稱:              .symtab 段位址: 0x       0 段大小:      256
段名稱:              .strtab 段位址: 0x       0 段大小:      166
段名稱:            .shstrtab 段位址: 0x       0 段大小:       60
```