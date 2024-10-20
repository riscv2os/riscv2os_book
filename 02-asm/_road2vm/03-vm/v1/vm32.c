#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// 定義 RV32I 的寄存器數量與記憶體大小
#define NUM_REGS 32
#define MEM_SIZE 4096

// 寄存器
int32_t regs[NUM_REGS];

// 記憶體
uint8_t memory[MEM_SIZE];

// 提取操作碼的宏
#define OPCODE(instr) (instr & 0x7F)

// RV32I 的操作碼
#define OP_IMM  0x13
#define OP      0x33
#define LOAD    0x03
#define STORE   0x23
#define BRANCH  0x63
#define LUI     0x37
#define AUIPC   0x17
#define JAL     0x6F
#define JALR    0x67

// 指令解碼
void execute_instruction(uint32_t instruction) {
    uint32_t opcode = OPCODE(instruction);
    uint32_t rd, rs1, rs2, funct3, funct7;
    int32_t imm;

    switch(opcode) {
        case OP_IMM: // I 型指令
            rd = (instruction >> 7) & 0x1F;
            funct3 = (instruction >> 12) & 0x07;
            rs1 = (instruction >> 15) & 0x1F;
            imm = (int32_t)(instruction & 0xFFF00000) >> 20;
            switch (funct3) {
                case 0x0: // ADDI
                    regs[rd] = regs[rs1] + imm;
                    break;
                // 其他 I 型指令的處理...
            }
            break;

        case OP: // R 型指令
            rd = (instruction >> 7) & 0x1F;
            funct3 = (instruction >> 12) & 0x07;
            rs1 = (instruction >> 15) & 0x1F;
            rs2 = (instruction >> 20) & 0x1F;
            funct7 = (instruction >> 25) & 0x7F;
            switch (funct3) {
                case 0x0: // ADD or SUB
                    if (funct7 == 0x00) {
                        regs[rd] = regs[rs1] + regs[rs2]; // ADD
                    } else if (funct7 == 0x20) {
                        regs[rd] = regs[rs1] - regs[rs2]; // SUB
                    }
                    break;
                // 其他 R 型指令的處理...
            }
            break;

        // 其他指令格式的解碼與執行...

        default:
            printf("Unknown instruction: 0x%x\n", instruction);
            break;
    }
}

// 簡單的載入記憶體的函式
uint32_t load_memory(uint32_t address) {
    if (address >= MEM_SIZE - 4) {
        printf("Memory access error at 0x%x\n", address);
        exit(1);
    }
    return *(uint32_t*)(memory + address);
}

// 測試用例
void run_vm() {
    // 簡單的測試指令 ADDI x1, x0, 10 (增加立即數)
    uint32_t test_instr = 0x00A00093; // ADDI x1, x0, 10
    execute_instruction(test_instr);
    printf("x1 = %d\n", regs[1]); // 應該輸出 10
}

int main() {
    // 初始化記憶體與寄存器
    for (int i = 0; i < NUM_REGS; i++) regs[i] = 0;

    run_vm();
    return 0;
}
