# kleine-riscv on mac

1. 在 mac 底下，make 預設不是 gnu make ，所以要用 brew install make 之後，然後打 gmake (這才是 gnu make)

2. 本專案在 mac 的 make 下會失敗，所以在 mac 要改用 gmake

3. 但即使改用 gmake , 還是會碰到下列錯誤

    (base) cccimac@cccimacdeiMac kleine-riscv % gmake
    gmake[1]: Entering directory '/Users/cccimac/Desktop/ccc/code/kleine-riscv/tests'
    Building build/misc/fibonacci
    error: unable to create target: 'No available targets are compatible with triple "riscv32-unknown-unknown"'
    1 error generated.
    gmake[1]: *** [makefile:36: build/misc/fibonacci] Error 1
    gmake[1]: Leaving directory '/Users/cccimac/Desktop/ccc/code/kleine-riscv/tests'
    gmake: *** [makefile:47: tests/build] Error 2

所以不要在 mac 上跑這個專案，在 linux 上跑就好。
