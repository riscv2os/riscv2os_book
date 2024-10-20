## 安裝 Spike

```
$ git clone https://github.com/riscv-software-src/riscv-isa-sim.git
$ cd riscv-isa-sim
$ apt-get install device-tree-compiler libboost-regex-dev libboost-system-dev
$ mkdir build
$ cd build
$ ../configure --prefix=$RISCV
$ make
$ [sudo] make install
```
