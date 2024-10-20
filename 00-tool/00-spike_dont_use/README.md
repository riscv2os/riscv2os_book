

要編譯執行一個 hello.c 之前，必須先安裝下列工具

1. spike
2. riscv-pk
3. riscv-gnu-toolchain

有夠麻煩吧！

而且不能直接用 apt install, 而是要用 git clone 下這些專案後，重新用 make build

其中 riscv-gnu-toolchain 就佔了 6GB ...
