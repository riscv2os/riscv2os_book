set -x
riscv64-unknown-elf-gcc -march=rv32g -mabi=ilp32 -c add.c -o add_rv32.o
riscv64-unknown-elf-objdump -d add_rv32.o
gcc ../rvm32elf.c -o ../rvm32elf.o
../rvm32elf.o add_rv32.o