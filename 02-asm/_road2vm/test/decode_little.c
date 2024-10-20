#include <stdio.h>
#include <stdint.h>

uint32_t decode_little_endian(const char bytes[4]) {
    // 根據 little-endian 方式組合 4 個字節
    uint32_t result = 0;

    result |= (uint32_t)(unsigned char)bytes[0]; // 取第 1 個字節
    result |= (uint32_t)(unsigned char)bytes[1] << 8; // 取第 2 個字節，左移 8 位
    result |= (uint32_t)(unsigned char)bytes[2] << 16; // 取第 3 個字節，左移 16 位
    result |= (uint32_t)(unsigned char)bytes[3] << 24; // 取第 4 個字節，左移 24 位

    return result;
}

int main() {
    // 假設有一個 little-endian 的 char 陣列
    char bytes[4] = {0x78, 0x56, 0x34, 0x12}; // 代表整數 0x12345678

    // 解碼
    uint32_t value = decode_little_endian(bytes);

    // 輸出結果
    printf("Decoded value: 0x%X\n", value); // 應該輸出 0x12345678

    return 0;
}
