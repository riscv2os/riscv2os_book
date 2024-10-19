# kleine-riscv on linux

## build & run

必須在 linux 底下，先安裝 lld libelf-dev g++ clang verilator

然後就能 make

```
root@localhost:~# git clone git@github.com:riscv2os/kleine-riscv.git
Cloning into 'kleine-riscv'...
remote: Enumerating objects: 760, done.
remote: Counting objects: 100% (10/10), done.
remote: Compressing objects: 100% (10/10), done.
remote: Total 760 (delta 0), reused 0 (delta 0), pack-reused 750 (from 1)
Receiving objects: 100% (760/760), 156.33 KiB | 508.00 KiB/s, done.
Resolving deltas: 100% (390/390), done.
root@localhost:~# cd kleine-riscv/
root@localhost:~/kleine-riscv# make
make[1]: Entering directory '/root/kleine-riscv/tests'
Building build/rv32ui/addi
Building build/rv32ui/lhu
Building build/rv32ui/jal
Building build/rv32ui/sll
Building build/rv32ui/sltu
Building build/rv32ui/lw
Building build/rv32ui/bgeu
Building build/rv32ui/lbu
Building build/rv32ui/auipc
Building build/rv32ui/simple
Building build/rv32ui/bne
Building build/rv32ui/srai
Building build/rv32ui/xor
Building build/rv32ui/blt
Building build/rv32ui/fence_i
Building build/rv32ui/sw
Building build/rv32ui/slt
Building build/rv32ui/bge
Building build/rv32ui/sltiu
Building build/rv32ui/slti
Building build/rv32ui/lb
Building build/rv32ui/sb
Building build/rv32ui/lh
Building build/rv32ui/beq
Building build/rv32ui/or
Building build/rv32ui/add
Building build/rv32ui/sh
Building build/rv32ui/andi
Building build/rv32ui/jalr
Building build/rv32ui/ori
Building build/rv32ui/srl
Building build/rv32ui/slli
Building build/rv32ui/srli
Building build/rv32ui/sra
Building build/rv32ui/bltu
Building build/rv32ui/lui
Building build/rv32ui/sub
Building build/rv32ui/xori
Building build/rv32ui/and
Building build/misc/fastfib
Building build/misc/ackermann
Building build/misc/alarm
Building build/misc/partitions
Building build/misc/sha256
Building build/misc/fibonacci
Building build/misc/factorial
Building build/misc/primes
Building build/rv32mi/csr
Building build/rv32mi/scall
Building build/rv32mi/ma_addr
Building build/rv32mi/mcsr
Building build/rv32mi/ma_fetch
Building build/rv32mi/shamt
Building build/rv32mi/illegal
Building build/rv32mi/sbreak
Building build/rv32mi/mtimecmp
make[1]: Leaving directory '/root/kleine-riscv/tests'
Building build/Vcore
make[1]: Entering directory '/root/kleine-riscv/build'
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -Os -c -o core.o ../sim/core.cpp
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -Os -c -o memory.o ../sim/memory.cpp
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -Os -c -o simulator.o ../sim/simulator.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -c -o verilated.o /usr/share/verilator/include/verilated.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -c -o verilated_threads.o /usr/share/verilator/include/verilated_threads.cpp
/usr/bin/python3 /usr/share/verilator/bin/verilator_includer -DVL_INCLUDE_OPT=include Vcore.cpp Vcore___024root__DepSet_h0a3cae5e__0.cpp Vcore___024root__DepSet_h134b5715__0.cpp Vcore__ConstPool_0.cpp Vcore___024root__Slow.cpp Vcore___024root__DepSet_h0a3cae5e__0__Slow.cpp Vcore___024root__DepSet_h134b5715__0__Slow.cpp Vcore__Syms.cpp > Vcore__ALL.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -c -o Vcore__ALL.o Vcore__ALL.cpp
echo "" > Vcore__ALL.verilator_deplist.tmp
Archive ar -rcs Vcore__ALL.a Vcore__ALL.o
g++     core.o memory.o simulator.o verilated.o verilated_threads.o Vcore__ALL.a   -lelf  -pthread -lpthread -latomic   -o Vcore
rm Vcore__ALL.verilator_deplist.tmp
make[1]: Leaving directory '/root/kleine-riscv/build'
Running test addi
Running test lhu
Running test jal
Running test sll
Running test sltu
Running test lw
Running test bgeu
Running test lbu
Running test auipc
Running test simple
Running test bne
Running test srai
Running test xor
Running test blt
Running test fence_i
Running test sw
Running test slt
Running test bge
Running test sltiu
Running test slti
Running test lb
Running test sb
Running test lh
Running test beq
Running test or
Running test add
Running test sh
Running test andi
Running test jalr
Running test ori
Running test srl
Running test slli
Running test srli
Running test sra
Running test bltu
Running test lui
Running test sub
Running test xori
Running test and
Running test fastfib
Running test ackermann
Running test alarm
Running test partitions
Running test sha256
Running test fibonacci
Running test factorial
Running test primes
Running test csr
Running test scall
Running test ma_addr
Running test mcsr
Running test ma_fetch
Running test shamt
Running test illegal
Running test sbreak
Running test mtimecmp
```
