
#define op(a) \
    asm volatile ( \
        "sll %0, %1, %2\n"   \
        "sll %0, %1, %2\n"   \
        : "=r" (result)      \
        : "r" (a), "i" (2) \
    )

int main() {
    int a = 5;
    int result;

    // 使用內聯 RISC-V 組合語言進行左移操作
    asm volatile (
        "sll %0, %1, %2\n"  // 將 a 左移 2 位
        "sll %0, %1, %2\n"  // 將 a 左移 2 位
        : "=r" (result)     // 輸出操作數
        : "r" (a), "i" (2)  // 輸入操作數，立即數 2
    );
    op(a);
    return 0;
}
