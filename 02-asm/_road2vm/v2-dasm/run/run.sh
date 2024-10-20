set -x
riscv64-unknown-elf-gcc -march=rv32g -mabi=ilp32 -c add.c -o add_rv32.o
riscv64-unknown-elf-objdump -d add_rv32.o # > rv32objdump.txt
gcc ../elf32dump.c -o ../elf32dump.o
../elf32dump.o add_rv32.o # > elf32dump.txt
# cat rv32objdump.txt
# cat elf32dump.txt