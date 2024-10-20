#include <stdio.h>

int main() {
    // 定義一個 16 進位整數（0x12345678）
    unsigned int x = 0x12345678;

    // 建立一個字元指標，指向這個整數的位址
    unsigned char *c = (unsigned char*) &x;

    // 判斷第一個位址儲存的值是 0x12 (big-endian) 還是 0x78 (little-endian)
    if (*c == 0x78) {
        printf("This system is Little-endian.\n");
    } else if (*c == 0x12) {
        printf("This system is Big-endian.\n");
    } else {
        printf("Unknown endianness.\n");
    }

    return 0;
}
