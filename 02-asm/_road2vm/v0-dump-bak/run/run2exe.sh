riscv64-unknown-elf-gcc -nostdlib -fno-builtin -march=rv32g -mabi=ilp32 addmain.c -o addmain_rv32.o
riscv64-unknown-elf-objdump -d addmain_rv32.o > rv32objdump.txt
gcc elf32dump.c -o elf32dump.o
./elf32dump.o addmain_rv32.o > elf32dump.txt
cat rv32objdump.txt
cat elf32dump.txt