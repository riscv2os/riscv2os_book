#define PUTS(s) \
    asm volatile ( \
        "la a7, %1\n" \
        "ecall\n" \
        : "=r" (s)      \
        : "r" (s) \
    )

int main() {
    char *msg = "hello";
    PUTS(msg);
}
