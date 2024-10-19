
```
root@localhost:~/kleine-riscv/ccc/_verilator/A1-chatgptEx# ./run.sh
make: Entering directory '/root/kleine-riscv/ccc/_verilator/A1-chatgptEx/obj_dir'
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable     -DVL_TIME_CONTEXT   -fcoroutines -c -o verilated.o /usr/share/verilator/include/verilated.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable     -DVL_TIME_CONTEXT   -fcoroutines -c -o verilated_timing.o /usr/share/verilator/include/verilated_timing.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable     -DVL_TIME_CONTEXT   -fcoroutines -c -o verilated_threads.o /usr/share/verilator/include/verilated_threads.cpp
/usr/bin/python3 /usr/share/verilator/bin/verilator_includer -DVL_INCLUDE_OPT=include Vtestbench.cpp Vtestbench___024root__DepSet_hfc24d085__0.cpp Vtestbench___024root__DepSet_hed41eec4__0.cpp Vtestbench__main.cpp Vtestbench___024root__Slow.cpp Vtestbench___024root__DepSet_hfc24d085__0__Slow.cpp Vtestbench___024root__DepSet_hed41eec4__0__Slow.cpp Vtestbench___024unit__Slow.cpp Vtestbench___024unit__DepSet_hf87c9ffd__0__Slow.cpp Vtestbench__Syms.cpp > Vtestbench__ALL.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable     -DVL_TIME_CONTEXT   -fcoroutines -c -o Vtestbench__ALL.o Vtestbench__ALL.cpp
echo "" > Vtestbench__ALL.verilator_deplist.tmp
Archive ar -rcs Vtestbench__ALL.a Vtestbench__ALL.o
g++     verilated.o verilated_timing.o verilated_threads.o Vtestbench__ALL.a    -pthread -lpthread -latomic   -o Vtestbench
rm Vtestbench__ALL.verilator_deplist.tmp
make: Leaving directory '/root/kleine-riscv/ccc/_verilator/A1-chatgptEx/obj_dir'
Time: 0 | a: 0, b: 0, y: 0
Time: 10000 | a: 0, b: 1, y: 0
Time: 10000 | a: 0, b: 1, y: 0
Time: 20000 | a: 1, b: 0, y: 0
Time: 20000 | a: 1, b: 0, y: 0
Time: 30000 | a: 1, b: 1, y: 1
Time: 30000 | a: 1, b: 1, y: 1
- testbench.v:24: Verilog $finish
Time: 40000 | a: 1, b: 1, y: 1
Time: 40000 | a: 1, b: 1, y: 1
```