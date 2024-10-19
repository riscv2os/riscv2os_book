# single-cycle-riscv-cpu

## Introduction
`single-cycle-riscv-cpu` is based on the assignment of Computer Organization HW3 of [CAID Lab (Computer Architecture & IC Design Lab)](http://caid.csie.ncku.edu.tw/index.php?e=home.courses&lang=en#tab-0) in [NCKU](https://web.ncku.edu.tw/index.php?Lang=en). This is a simple single cycle cpu supporting RV32I ISA, in verilog.

### Instruction
**R-type:** `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRI`, `SRA`, `OR`, `AND`  
**I-type:** `LW`, `LB`, `LH`, `LBU`, `LHU`, `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`, `JALR`  
**S-type:** `SW`, `SB`, `SH`  
**B-type:** `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`  
**U-type:** `AUIPC`, `LUI`  
**J-type:** `JAL`  

### Register File
| Register | ABI Name |
| -------- | -------- |
| x0       | zero     |
| x1       | ra       |
| x2       | sp       |
| x3       | gp       |
| x4       | tp       |
| x5       | t0       |
| x6-x7    | t1-t2    |
| x8       | s0/fp    |
| x9       | s1       |
| x10-x11  | a0-a1    |
| x12-x17  | a2-a7    |
| x18-x27  | s2-s11   |
| x28-x31  | t3-t6    |

## Prerequisites
**Install:**
* [iverilog](http://iverilog.icarus.com)
* [gcc-riscv64-unknown-elf](https://github.com/riscv/riscv-gcc)
* [gtkwave](http://gtkwave.sourceforge.net/)

```
$ sudo apt install gcc-riscv64-unknown-elf iverilog gtkwave
```

## Build and Verify
Generate hex file from riscv asembly code:
```
$ make
riscv64-unknown-elf-gcc -c -march=rv32i -mabi=ilp32 setup.S
riscv64-unknown-elf-gcc -c -march=rv32i -mabi=ilp32 main.S
riscv64-unknown-elf-gcc setup.o main.o -static -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -Tlink.ld -lgcc -o main
riscv64-unknown-elf-objdump -xsd main > main.log
riscv64-unknown-elf-objcopy -O verilog main -i 4 -b 0 main0.hex
riscv64-unknown-elf-objcopy -O verilog main -i 4 -b 1 main1.hex
riscv64-unknown-elf-objcopy -O verilog main -i 4 -b 2 main2.hex
riscv64-unknown-elf-objcopy -O verilog main -i 4 -b 3 main3.hex
```
Compile using iverilog:
```
$ make iverilog 
iverilog -o tb.vvp top.v top_tb.v
```
Use vvp as the simulation run-time engine, and dump the `vcd` (tb.vcd) file:
```
$ make vvp
vvp tb.vvp
VCD info: dumpfile tb.vcd opened for output.

Done

DM[8192] = fffffff0, pass
DM[8193] = fffffff8, pass
DM[8194] = 00000008, pass
DM[8195] = 00000001, pass
DM[8196] = 00000001, pass
DM[8197] = 78787878, pass
DM[8198] = 000091a2, pass
DM[8199] = 00000003, pass
DM[8200] = fefcfefd, pass
DM[8201] = 10305070, pass
DM[8202] = cccccccc, pass
DM[8203] = ffffffcc, pass
DM[8204] = ffffcccc, pass
DM[8205] = 000000cc, pass
DM[8206] = 0000cccc, pass
DM[8207] = 00000d9d, pass
DM[8208] = 00000004, pass
DM[8209] = 00000003, pass
DM[8210] = 000001a6, pass
DM[8211] = 00000ec6, pass
DM[8212] = 2468b7a8, pass
DM[8213] = 5dbf9f00, pass
DM[8214] = 00012b38, pass
DM[8215] = fa2817b7, pass
DM[8216] = ff000000, pass
DM[8217] = 12345678, pass
DM[8218] = 0000f000, pass
DM[8219] = 00000f00, pass
DM[8220] = 000000f0, pass
DM[8221] = 0000000f, pass
DM[8222] = 56780000, pass
DM[8223] = 78000000, pass
DM[8224] = 00005678, pass
DM[8225] = 00000078, pass
DM[8226] = 12345678, pass
DM[8227] = ce780000, pass
DM[8228] = fffff000, pass
DM[8229] = fffff000, pass
DM[8230] = fffff000, pass
DM[8231] = fffff000, pass
DM[8232] = fffff000, pass
DM[8233] = fffff000, pass
DM[8234] = 1357a064, pass
DM[8235] = 13578000, pass
DM[8236] = fffff004, pass




        ****************************               
        **                        **       |__||  
        **  Congratulations !!    **      / O.O  | 
        **                        **    /_____   | 
        **  Simulation PASS!!     **   /^ ^ ^ \  |
        **                        **  |^ ^ ^ ^ |w| 
        ****************************   \m___m__|_|
        
```

## Verify wave using GTKWave
```
$ gtkwave tb.vcd
```
