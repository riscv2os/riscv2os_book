
```
# verilator --cc --exe --build -j 0 -Wall sim_main.cpp our.v
make: Entering directory '/root/kleine-riscv/ccc/_verilator/01-main/obj_dir'
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -Os -c -o sim_main.o ../sim_main.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -c -o verilated.o /usr/share/verilator/include/verilated.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -c -o verilated_threads.o /usr/share/verilator/include/verilated_threads.cpp
/usr/bin/python3 /usr/share/verilator/bin/verilator_includer -DVL_INCLUDE_OPT=include Vour.cpp Vour___024root__DepSet_hf7027e39__0.cpp Vour___024root__DepSet_h637983f1__0.cpp Vour___024root__Slow.cpp Vour___024root__DepSet_h637983f1__0__Slow.cpp Vour__Syms.cpp > Vour__ALL.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable       -c -o Vour__ALL.o Vour__ALL.cpp
echo "" > Vour__ALL.verilator_deplist.tmp
Archive ar -rcs Vour__ALL.a Vour__ALL.o
g++     sim_main.o verilated.o verilated_threads.o Vour__ALL.a    -pthread -lpthread -latomic   -o Vour
rm Vour__ALL.verilator_deplist.tmp
make: Leaving directory '/root/kleine-riscv/ccc/_verilator/01-main/obj_dir'
root@localhost:~/kleine-riscv/ccc/_verilator/01-main# obj_dir/Vour
Hello World
- our.v:5: Verilog $finish
```