// 定義 R 型指令對應的 funct3 和 funct7
#include <stdio.h>
#include <stdint.h>

// 函數用來根據給定的 32 位 RISC-V 指令返回其型態
char get_riscv_instr_type(uint32_t instr) {
    // 提取指令的前 7 位作為 opcode
    uint32_t opcode = instr & 0x7F;

    // 根據 opcode 判斷指令型態
    switch (opcode) {
        case 0x33: // R 型指令
            return 'R';
        case 0x13: // I 型指令（例如 addi）
        case 0x03: // I 型指令（例如 lw）
        case 0x67: // I 型指令（例如 jalr）
            return 'I';
        case 0x23: // S 型指令（例如 sw）
            return 'S';
        case 0x63: // B 型指令（例如 beq, bne）
            return 'B';
        case 0x37: // U 型指令（例如 lui）
        case 0x17: // U 型指令（例如 auipc）
            return 'U';
        case 0x6F: // J 型指令（例如 jal）
            return 'J';
        default:
            return '?'; // 無法識別的型態
    }
}

void disassemble_r_type(uint32_t instr, char *asm1) {
    uint32_t rd = (instr >> 7) & 0x1F;   // 目的暫存器
    uint32_t funct3 = (instr >> 12) & 0x7;
    uint32_t rs1 = (instr >> 15) & 0x1F; // 第一個來源暫存器
    uint32_t rs2 = (instr >> 20) & 0x1F; // 第二個來源暫存器
    uint32_t funct7 = (instr >> 25) & 0x7F;

    // 判斷是 add 還是 sub
    const char *instr_name = (funct7 == 0x00) ? R_TYPE_FUNCT7[0] : R_TYPE_FUNCT7[1];

    // 輸出反組譯結果
    sprintf(asm1, "%s x%d, x%d, x%d", instr_name, rd, rs1, rs2);
}

// 反組譯 S 型指令的函數
void disassemble_s_type(uint32_t instr, char *asm1) {
    uint32_t imm11_5 = (instr >> 25) & 0x7F;  // 立即數的高 7 位 (imm[11:5])
    uint32_t imm4_0 = (instr >> 7) & 0x1F;    // 立即數的低 5 位 (imm[4:0])
    uint32_t funct3 = (instr >> 12) & 0x7;    // 功能碼
    uint32_t rs1 = (instr >> 15) & 0x1F;      // 原暫存器1
    uint32_t rs2 = (instr >> 20) & 0x1F;      // 原暫存器2

    // 將立即數的高 7 位和低 5 位合併成完整的 12 位立即數
    int32_t imm = (imm11_5 << 5) | imm4_0;

    // 對立即數進行符號擴展
    imm = sign_extend_12(imm);

    // 根據 funct3 判斷不同的 S 型指令
    switch (funct3) {
        case 0x0: // sb
            sprintf(asm1, "sb x%d, %d(x%d)", rs2, imm, rs1);
            break;
        case 0x1: // sh
            sprintf(asm1, "sh x%d, %d(x%d)", rs2, imm, rs1);
            break;
        case 0x2: // sw
            sprintf(asm1, "sw x%d, %d(x%d)", rs2, imm, rs1);
            break;
        default:
            sprintf(asm1, "Unknown S-Type instruction");
            break;
    }
}

// 反組譯 I 型指令的函數
void disassemble_i_type(uint32_t instr, char *asm1) {
    uint32_t rd = (instr >> 7) & 0x1F;      // 目的暫存器
    uint32_t funct3 = (instr >> 12) & 0x7;  // 功能碼
    uint32_t rs1 = (instr >> 15) & 0x1F;    // 原暫存器1
    int32_t imm = (instr >> 20);            // 立即數，可能需要符號擴展

    // 對 12-bit 的立即數進行符號擴展
    imm = sign_extend_12(imm);

    // 根據 funct3 決定不同的 I 型指令
    switch (funct3) {
        case 0x0: // addi
            sprintf(asm1, "addi x%d, x%d, %d", rd, rs1, imm);
            break;
        case 0x2: // slti
            sprintf(asm1, "slti x%d, x%d, %d", rd, rs1, imm);
            break;
        case 0x3: // sltiu
            sprintf(asm1, "sltiu x%d, x%d, %d", rd, rs1, imm);
            break;
        case 0x4: // xori
            sprintf(asm1, "xori x%d, x%d, %d", rd, rs1, imm);
            break;
        case 0x6: // ori
            sprintf(asm1, "ori x%d, x%d, %d", rd, rs1, imm);
            break;
        case 0x7: // andi
            sprintf(asm1, "andi x%d, x%d, %d", rd, rs1, imm);
            break;
        default:
            sprintf(asm1, "Unknown I-Type instruction");
            break;
    }
}

void disassemble_b_type(uint32_t instr, char *asm1) {
    uint32_t funct3 = (instr >> 12) & 0x7;
    uint32_t rs1 = (instr >> 15) & 0x1F;
    uint32_t rs2 = (instr >> 20) & 0x1F;
    int32_t imm = ((instr >> 31) << 12) | ((instr & 0x7E000000) >> 20) | ((instr & 0x80) << 4) | ((instr >> 7) & 0x1E); // 符號擴展

    if (funct3 == 0x0) {
        sprintf(asm1, "beq x%d, x%d, %d", rs1, rs2, imm);
    } else if (funct3 == 0x1) {
        sprintf(asm1, "bne x%d, x%d, %d", rs1, rs2, imm);
    }
}

// 反組譯 U 型指令的函數
void disassemble_u_type(uint32_t instr, char *asm1) {
    uint32_t rd = (instr >> 7) & 0x1F;        // 目的暫存器
    int32_t imm = instr & 0xFFFFF000;         // 高 20 位立即數
    
    // 提取 opcode 來區分不同的 U 型指令
    uint32_t opcode = instr & 0x7F;

    switch (opcode) {
        case 0x37: // lui 指令
            sprintf(asm1, "lui x%d, 0x%x\n", rd, imm >> 12);
            break;
        case 0x17: // auipc 指令
            sprintf(asm1, "auipc x%d, 0x%x\n", rd, imm >> 12);
            break;
        default:
            sprintf(asm1, "Unknown U-Type instruction\n");
            break;
    }
}

// 反組譯 J 型指令的函數
void disassemble_j_type(uint32_t instr, char *asm1) {
    uint32_t rd = (instr >> 7) & 0x1F;  // 目的暫存器

    // 提取並重組 20-bit 立即數
    int32_t imm = ((instr >> 31) & 0x1) << 19;   // imm[20]
    imm |= ((instr >> 12) & 0xFF) << 12;         // imm[19:12]
    imm |= ((instr >> 20) & 0x1) << 11;          // imm[11]
    imm |= (instr >> 21) & 0x3FF;                // imm[10:1]

    // 對 20-bit 立即數進行符號擴展
    imm = sign_extend_20(imm);

    // 構建 jal 指令
    sprintf(asm1, "jal x%d, %d\n", rd, imm);
}

void disassemble(uint32_t instr, char *asm1) {
    char type = get_riscv_instr_type(instr);
    switch (type) {
        case 'R': disassemble_r_type(instr, asm1); break;
        case 'I': disassemble_i_type(instr, asm1); break;
        case 'S': disassemble_s_type(instr, asm1); break;
        case 'B': disassemble_b_type(instr, asm1); break;
        case 'U': disassemble_u_type(instr, asm1); break;
        case 'J': disassemble_j_type(instr, asm1); break;
        default: sprintf(asm1, "?");
    }
}
