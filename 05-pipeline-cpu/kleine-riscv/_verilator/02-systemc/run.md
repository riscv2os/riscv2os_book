
```
root@localhost:~/kleine-riscv/ccc/_verilator/02-systemc# chmod +x build.sh
root@localhost:~/kleine-riscv/ccc/_verilator/02-systemc# ./build.sh
%Warning-EOFNEWLINE: our.v:5:10: Missing newline at end of file (POSIX 3.206).
                               : ... Suggest add newline.
    5 | endmodule
      |          ^
                     ... For warning description see https://verilator.org/warn/EOFNEWLINE?v=5.020
                     ... Use "/* verilator lint_off EOFNEWLINE */" and lint_on around source to disable this message.
%Error: Exiting due to 1 warning(s)
make: Entering directory '/root/kleine-riscv/ccc/_verilator/02-systemc/obj_dir'
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=1 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable         -Os -c -o sc_main.o ../sc_main.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=1 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable         -c -o verilated.o /usr/share/verilator/include/verilated.cpp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=1 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable         -c -o verilated_threads.o /usr/share/verilator/include/verilated_threads.cpp
/usr/bin/python3 /usr/share/verilator/bin/verilator_includer -DVL_INCLUDE_OPT=include Vour.cpp Vour___024root__DepSet_hf7027e39__0.cpp Vour___024root__DepSet_h637983f1__0.cpp Vour___024root__Slow.cpp Vour___024root__DepSet_hf7027e39__0__Slow.cpp Vour___024root__DepSet_h637983f1__0__Slow.cpp Vour__Syms.cpp > Vour__ALL.cpp
echo "" > Vour__ALL.verilator_deplist.tmp
g++ -Os  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=1 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-overloaded-virtual -Wno-shadow -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable         -c -o Vour__ALL.o Vour__ALL.cpp
Archive ar -rcs Vour__ALL.a Vour__ALL.o
g++       sc_main.o verilated.o verilated_threads.o Vour__ALL.a    -pthread -lpthread -latomic  -lsystemc -o Vour
rm Vour__ALL.verilator_deplist.tmp
make: Leaving directory '/root/kleine-riscv/ccc/_verilator/02-systemc/obj_dir'
root@localhost:~/kleine-riscv/ccc/_verilator/02-systemc# obj_dir/Vour

        SystemC 2.3.4-Accellera --- Apr 22 2024 14:54:19
        Copyright (c) 1996-2022 by all Contributors,
        ALL RIGHTS RESERVED
Hello World
- our.v:4: Verilog $finish
```

