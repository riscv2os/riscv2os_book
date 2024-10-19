git clone https://github.com/riscv-software-src/riscv-pk.git
cd riscv-pk
mkdir build
cd build
../configure --prefix=$RISCV --host=riscv64-unknown-elf
make
make install
