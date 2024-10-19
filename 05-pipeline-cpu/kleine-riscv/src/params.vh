// 這些是 ALU 操作值，亦用於指令集架構 (ISA)
localparam ALU_ADD_SUB = 3'b000; // ALU 加法/減法操作
localparam ALU_SLL     = 3'b001; // ALU 左邊邏輯移位 (Shift Left Logical)
localparam ALU_SLT     = 3'b010; // ALU 小於比較 (Set Less Than)
localparam ALU_SLTU    = 3'b011; // ALU 無符號小於比較 (Set Less Than Unsigned)
localparam ALU_XOR     = 3'b100; // ALU 异或操作 (XOR)
localparam ALU_SRL_SRA = 3'b101; // ALU 右邊邏輯/算術移位 (Shift Right Logical / Arithmetic)
localparam ALU_OR      = 3'b110; // ALU 或操作 (OR)
localparam ALU_AND_CLR = 3'b111; // ALU 與操作/清除操作 (AND/Clear)

// ALU 操作數的選擇信號
localparam ALU_SEL_REG = 2'b00; // 從寄存器選擇 ALU 操作數
localparam ALU_SEL_IMM = 2'b01; // 從立即數選擇 ALU 操作數
localparam ALU_SEL_PC  = 2'b10; // 從程序計數器 (PC) 選擇 ALU 操作數
localparam ALU_SEL_CSR = 2'b11; // 從 CSR (控制和狀態寄存器) 選擇 ALU 操作數

// 比較操作的選擇值
localparam CMP_EQ  = 3'b000; // 比較是否相等 (Equal)
localparam CMP_NE  = 3'b001; // 比較是否不相等 (Not Equal)
localparam CMP_LT  = 3'b110; // 比較是否小於 (Less Than)
localparam CMP_GE  = 3'b111; // 比較是否大於或等於 (Greater Than or Equal)
localparam CMP_LTU = 3'b100; // 無符號小於比較 (Less Than Unsigned)
localparam CMP_GEU = 3'b101; // 無符號大於或等於比較 (Greater Than or Equal Unsigned)

// 寫入選擇的參數
localparam WRITE_SEL_ALU     = 2'b00; // ALU 的寫入選擇
localparam WRITE_SEL_CSR     = 2'b01; // CSR 的寫入選擇
localparam WRITE_SEL_LOAD    = 2'b10; // 加載數據的寫入選擇
localparam WRITE_SEL_NEXT_PC = 2'b11; // 下一個程序計數器的寫入選擇

