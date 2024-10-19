module decode (
    input clk, // 時鐘信號

    // from fetch (來自取指階段的輸入)
    input [31:0] pc_in, // 當前程序計數器值
    input [31:0] next_pc_in, // 下一個程序計數器值
    input [31:0] instruction_in, // 獲取的指令
    input valid_in, // 指令有效信號

    // from hazard (來自冒險檢測的輸入)
    input stall, // 停頓信號，指示是否需要暫停當前操作
    input invalidate, // 無效信號，指示當前指令是否無效
    // to hazard (輸出到冒險檢測)
    output reg uses_rs1, // 指示是否使用 rs1 寄存器
    output reg uses_rs2, // 指示是否使用 rs2 寄存器
    output reg uses_csr, // 指示是否使用 CSR（控制和狀態寄存器）

    // to regfile (輸出到寄存器檔)
    output [4:0] rs1_address, // rs1 寄存器地址
    output [4:0] rs2_address, // rs2 寄存器地址
    // from regfile (來自寄存器檔的輸入)
    input [31:0] rs1_data, // rs1 寄存器的數據
    input [31:0] rs2_data, // rs2 寄存器的數據
    
    // to csr (輸出到控制和狀態寄存器)
    output [11:0] csr_address, // CSR 地址
    input [31:0] csr_data, // CSR 數據
    // from csr (來自控制和狀態寄存器的輸入)
    input csr_readable, // CSR 可讀信號
    input csr_writeable, // CSR 可寫信號

    // from memory (來自記憶體的輸入)
    input [4:0] bypass_memory_address, // bypass 來自記憶體的地址
    input [31:0] bypass_memory_data, // bypass 來自記憶體的數據

    // from writeback (來自回寫階段的輸入)
    input [4:0] bypass_writeback_address, // bypass 來自回寫的地址
    input [31:0] bypass_writeback_data, // bypass 來自回寫的數據

    // to execute (輸出到執行階段)
    output reg [31:0] pc_out, // 輸出的程序計數器
    output reg [31:0] next_pc_out, // 輸出的下一個程序計數器
    // to execute (控制 EX)
    output reg [31:0] rs1_data_out, // rs1 寄存器的數據輸出
    output reg [31:0] rs2_data_out, // rs2 寄存器的數據輸出
    output reg [31:0] rs1_bypass_out, // rs1 bypass 數據
    output reg [31:0] rs2_bypass_out, // rs2 bypass 數據
    output reg rs1_bypassed_out, // rs1 是否被 bypass
    output reg rs2_bypassed_out, // rs2 是否被 bypass
    output reg [31:0] csr_data_out, // CSR 數據輸出
    output reg [31:0] imm_data_out, // 立即數數據輸出
    output reg [2:0] alu_function_out, // ALU 功能輸出
    output reg alu_function_modifier_out, // ALU 功能修飾符
    output reg [1:0] alu_select_a_out, // ALU A 輸入選擇
    output reg [1:0] alu_select_b_out, // ALU B 輸入選擇
    output reg [2:0] cmp_function_out, // 比較功能輸出
    output reg jump_out, // 跳轉信號
    output reg branch_out, // 分支信號
    output reg csr_read_out, // CSR 讀取信號
    output reg csr_write_out, // CSR 寫入信號
    output reg csr_readable_out, // CSR 可讀信號輸出
    output reg csr_writeable_out, // CSR 可寫信號輸出
    // to execute (控制 MEM)
    output reg load_out, // 加載信號
    output reg store_out, // 存儲信號
    output reg [1:0] load_store_size_out, // 加載/存儲大小
    output reg load_signed_out, // 加載是否有符號
    output reg bypass_memory_out, // bypass 記憶體信號
    // to execute (控制 WB)
    output reg [1:0] write_select_out, // 寫入選擇
    output reg [4:0] rd_address_out, // rd 寄存器地址輸出
    output reg [11:0] csr_address_out, // CSR 地址輸出
    output reg mret_out, // mret 信號輸出
    output reg wfi_out, // 等待中斷信號輸出
    // to execute (輸出到執行階段)
    output reg valid_out, // 有效信號
    output reg [3:0] ecause_out, // 異常原因輸出
    output reg exception_out // 異常信號輸出
);

// 定義 ALU 操作的編碼
localparam ALU_ADD_SUB = 3'b000; // ALU 加法/減法操作
localparam ALU_OR      = 3'b110; // ALU 邏輯或操作
localparam ALU_AND_CLR = 3'b111; // ALU 邏輯與或清除操作

// ALU 輸入選擇信號的編碼
localparam ALU_SEL_REG = 2'b00; // 使用寄存器數據作為 ALU 輸入 A 或 B
localparam ALU_SEL_IMM = 2'b01; // 使用立即數作為 ALU 輸入 B
localparam ALU_SEL_PC  = 2'b10; // 使用程序計數器數據作為 ALU 輸入 A
localparam ALU_SEL_CSR = 2'b11; // 使用 CSR 數據作為 ALU 輸入 A 或 B

// 寫入選擇信號的編碼
localparam WRITE_SEL_ALU     = 2'b00; // ALU 計算結果寫入選擇
localparam WRITE_SEL_CSR     = 2'b01; // CSR 寫入選擇
localparam WRITE_SEL_LOAD    = 2'b10; // 加載指令寫入選擇
localparam WRITE_SEL_NEXT_PC = 2'b11; // 下一個程序計數器寫入選擇

// 指令數據從輸入指令獲取
wire [31:0] instr = instruction_in;

// 從指令中提取 rs1、rs2 和 CSR 地址
assign rs1_address = instr[19:15]; // rs1 地址位於指令的 19-15 位
assign rs2_address = instr[24:20]; // rs2 地址位於指令的 24-20 位
assign csr_address = instr[31:20]; // CSR 地址位於指令的 31-20 位

// 根據指令類型設置使用的寄存器和 CSR 信號
always @(*) begin
    case (instr[6:0]) // 根據指令的操作碼來判斷
        7'b1100111, // JALR
        7'b0000011, // LOAD
        7'b0010011: // OP-IMM
        begin 
            uses_rs1 = valid_in; // 使用 rs1
            uses_rs2 = 0; // 不使用 rs2
            uses_csr = 0; // 不使用 CSR
        end
        7'b1100011, // Branch
        7'b0100011, // STORE
        7'b0110011: // OP
        begin 
            uses_rs1 = valid_in; // 使用 rs1
            uses_rs2 = valid_in; // 使用 rs2
            uses_csr = 0; // 不使用 CSR
        end
        7'b1110011 : begin // SYSTEM
            uses_rs2 = 0; // 不使用 rs2
            case (instr[14:12]) // 根據指令的功能碼進行判斷
                3'b001: begin // CSRRW
                    uses_rs1 = valid_in; // 使用 rs1
                    uses_csr = valid_in && (rd_address != 0); // 使用 CSR，且 rd_address 不能為 0
                end
                3'b010, // CSRRS
                3'b011: // CSRRC
                begin 
                    uses_rs1 = valid_in; // 使用 rs1
                    uses_csr = valid_in; // 使用 CSR
                end
                3'b101: begin // CSRRWI
                    uses_rs1 = 0; // 不使用 rs1
                    uses_csr = valid_in && (rd_address != 0); // 使用 CSR，且 rd_address 不能為 0
                end
                3'b110, // CSRRSI
                3'b111: // CSRRCI
                begin 
                    uses_rs1 = 0; // 不使用 rs1
                    uses_csr = valid_in; // 使用 CSR
                end
                default: begin
                    uses_rs1 = 0; // 不使用 rs1
                    uses_csr = 0; // 不使用 CSR
                end
            endcase
        end
        default : begin
            uses_rs1 = 0; // 不使用 rs1
            uses_rs2 = 0; // 不使用 rs2
            uses_csr = 0; // 不使用 CSR
        end
    endcase
end


// 從指令中提取 rd_address，該地址位於指令的 11-7 位
wire [4:0] rd_address = instr[11:7];

// 定義可能的立即數類型
wire [31:0] u_type_imm_data = {instr[31:12], 12'b0}; // U 型立即數，將指令的高位部分移動到高位，低位填充零
wire [31:0] j_type_imm_data = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J 型立即數，進行符號擴展和重新排列
wire [31:0] i_type_imm_data = {{20{instr[31]}}, instr[31:20]}; // I 型立即數，進行符號擴展
wire [31:0] s_type_imm_data = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S 型立即數，進行符號擴展
wire [31:0] b_type_imm_data = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B 型立即數，進行符號擴展和重新排列
wire [31:0] csr_type_imm_data = {27'b0, rs1_address}; // CSR 型立即數，高位填充零，低位是 rs1_address

// 在時鐘上升沿時執行以下邏輯
always @(posedge clk) begin
    // 計算有效信號，如果發生停頓(stall)則保持原有效性，否則根據輸入的有效信號進行更新
    valid_out <= (stall ? valid_out : valid_in) && !invalidate;
    
    // 如果沒有停頓
    if (!stall) begin
        pc_out <= pc_in; // 將當前程序計數器輸出到 pc_out
        next_pc_out <= next_pc_in; // 將下一個程序計數器輸出到 next_pc_out
        rs1_data_out <= rs1_data; // 將 rs1 數據輸出到 rs1_data_out
        rs2_data_out <= rs2_data; // 將 rs2 數據輸出到 rs2_data_out
        csr_data_out <= csr_data; // 將 CSR 數據輸出到 csr_data_out
        imm_data_out <= 0; // 將立即數輸出設置為 0
        csr_address_out <= csr_address; // 將 CSR 地址輸出到 csr_address_out
        csr_readable_out <= csr_readable; // 將 CSR 可讀性標誌輸出到 csr_readable_out
        csr_writeable_out <= csr_writeable; // 將 CSR 可寫性標誌輸出到 csr_writeable_out
        
        // 設置 ALU 的功能和選擇信號
        alu_function_out <= ALU_OR; // ALU 功能設置為邏輯或操作
        alu_function_modifier_out <= 0; // ALU 功能修飾設置為 0
        alu_select_a_out <= ALU_SEL_IMM; // ALU 輸入 A 選擇立即數
        alu_select_b_out <= ALU_SEL_IMM; // ALU 輸入 B 選擇立即數
        
        // 寫入選擇信號設置
        write_select_out <= WRITE_SEL_ALU; // 設置寫入選擇為 ALU 計算結果
        
        // 控制信號初始化
        jump_out <= 0; // 初始化跳轉信號為 0
        branch_out <= 0; // 初始化分支信號為 0
        load_out <= 0; // 初始化加載信號為 0
        store_out <= 0; // 初始化存儲信號為 0
        rd_address_out <= 0; // 初始化 rd 地址輸出為 0
        bypass_memory_out <= 0; // 初始化繞過記憶體信號為 0
        csr_read_out <= 0; // 初始化 CSR 讀取信號為 0
        csr_write_out <= 0; // 初始化 CSR 寫入信號為 0
        mret_out <= 0; // 初始化 mret 信號為 0
        wfi_out <= 0; // 初始化 WFI 信號為 0
        ecause_out <= 0; // 初始化異常原因輸出為 0
        exception_out <= 0; // 初始化異常信號為 0
        
        // 根據指令的功能碼設置比較功能
        cmp_function_out <= instr[14:12]; // 將功能碼輸出到 cmp_function_out
        load_store_size_out <= instr[13:12]; // 設置加載/存儲大小輸出
        load_signed_out <= !instr[14]; // 設置加載是否為有符號的信號

        // 根據指令的操作碼進行解碼，檢查指令的類型並設置相應的控制信號
        case (instr[6:0])
            7'b0110111 : begin // LUI (Load Upper Immediate)
                imm_data_out <= u_type_imm_data; // 設置立即數輸出
                rd_address_out <= rd_address; // 設置目的寄存器地址
                bypass_memory_out <= 1; // 使能繞過記憶體
            end
            7'b0010111 : begin // AUIPC (Add Upper Immediate to PC)
                alu_function_out <= ALU_ADD_SUB; // 設置 ALU 功能為加法
                alu_select_a_out <= ALU_SEL_PC; // ALU 輸入 A 選擇程序計數器
                imm_data_out <= u_type_imm_data; // 設置立即數輸出
                rd_address_out <= rd_address; // 設置目的寄存器地址
                bypass_memory_out <= 1; // 使能繞過記憶體
            end
            7'b1101111 : begin // JAL (Jump And Link)
                alu_function_out <= ALU_ADD_SUB; // 設置 ALU 功能為加法
                alu_select_a_out <= ALU_SEL_PC; // ALU 輸入 A 選擇程序計數器
                imm_data_out <= j_type_imm_data; // 設置立即數輸出
                write_select_out <= WRITE_SEL_NEXT_PC; // 設置寫入選擇為下一個程序計數器
                branch_out <= 1; // 設置分支信號
                jump_out <= 1; // 設置跳轉信號
                rd_address_out <= rd_address; // 設置目的寄存器地址
            end
            7'b1100111 : begin // JALR (Jump And Link Register)
                alu_function_out <= ALU_ADD_SUB; // 設置 ALU 功能為加法
                alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                imm_data_out <= i_type_imm_data; // 設置立即數輸出
                write_select_out <= WRITE_SEL_NEXT_PC; // 設置寫入選擇為下一個程序計數器
                branch_out <= 1; // 設置分支信號
                jump_out <= 1; // 設置跳轉信號
                rd_address_out <= rd_address; // 設置目的寄存器地址
                // 檢查指令功能碼是否有效
                if (instr[14:12] != 0) begin
                    ecause_out <= 2; // 設置異常原因
                    exception_out <= 1; // 發生異常
                end
            end
            7'b1100011 : begin // Branch (分支指令)
                alu_function_out <= ALU_ADD_SUB; // 設置 ALU 功能為加法
                alu_select_a_out <= ALU_SEL_PC; // ALU 輸入 A 選擇程序計數器
                imm_data_out <= b_type_imm_data; // 設置立即數輸出
                branch_out <= 1; // 設置分支信號
                // 檢查指令功能碼是否有效
                if (instr[14:13] == 2'b01) begin
                    ecause_out <= 2; // 設置異常原因
                    exception_out <= 1; // 發生異常
                end
            end
            7'b0000011 : begin // LOAD (加載指令)
                alu_function_out <= ALU_ADD_SUB; // 設置 ALU 功能為加法
                alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                imm_data_out <= i_type_imm_data; // 設置立即數輸出
                write_select_out <= WRITE_SEL_LOAD; // 設置寫入選擇為加載
                load_out <= 1; // 設置加載信號
                rd_address_out <= rd_address; // 設置目的寄存器地址
                // 檢查加載操作是否有效
                if (instr[13:12] == 2'b11 || (instr[14] && instr[13:12] == 2'b10)) begin
                    ecause_out <= 2; // 設置異常原因
                    exception_out <= 1; // 發生異常
                end
            end
            7'b0100011 : begin // STORE (存儲指令)
                alu_function_out <= ALU_ADD_SUB; // 設置 ALU 功能為加法
                alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                imm_data_out <= s_type_imm_data; // 設置立即數輸出
                store_out <= 1; // 設置存儲信號
                // 檢查存儲操作是否有效
                if (instr[13:12] == 2'b11 || instr[14]) begin
                    ecause_out <= 2; // 設置異常原因
                    exception_out <= 1; // 發生異常
                end
            end
            7'b0010011 : begin // OP-IMM (立即數運算指令)
                alu_function_out <= instr[14:12]; // 設置 ALU 功能為指令功能碼
                alu_function_modifier_out <= (instr[14:12] == 3'b101 && instr[30]); // 設置功能修飾
                alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                imm_data_out <= i_type_imm_data; // 設置立即數輸出
                write_select_out <= WRITE_SEL_ALU; // 設置寫入選擇為 ALU 計算結果
                rd_address_out <= rd_address; // 設置目的寄存器地址
                bypass_memory_out <= 1; // 使能繞過記憶體
                // 檢查立即數運算指令的有效性
                if (
                    (instr[14:12] == 3'b001 && instr[31:25] != 0) || // SLLI
                    (instr[14:12] == 3'b101 && (instr[31] != 0 || instr[29:25] != 0)) // SRLI/SRAI
                ) begin
                    ecause_out <= 2; // 設置異常原因
                    exception_out <= 1; // 發生異常
                end
            end
            7'b0110011 : begin // OP (運算指令)
                alu_function_out <= instr[14:12]; // 設置 ALU 功能為指令功能碼
                alu_function_modifier_out <= instr[30]; // 設置功能修飾
                alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                alu_select_b_out <= ALU_SEL_REG; // ALU 輸入 B 選擇寄存器
                write_select_out <= WRITE_SEL_ALU; // 設置寫入選擇為 ALU 計算結果
                rd_address_out <= rd_address; // 設置目的寄存器地址
                bypass_memory_out <= 1; // 使能繞過記憶體
                // 檢查運算指令的有效性
                if (instr[31:25] != 0 && (instr[31:25] != 7'b0100000 || (instr[14:12] != 0 && instr[14:12] != 3'b101))) begin
                    ecause_out <= 2; // 設置異常原因
                    exception_out <= 1; // 發生異常
                end
            end
            7'b0001111 : begin // FENCE / FENCE.I (屏障指令)
                // 檢查功能碼是否有效
                if (instr[14:13] != 0) begin
                    ecause_out <= 2; // 設置異常原因
                    exception_out <= 1; // 發生異常
                end
            end
            7'b1110011 : begin // SYSTEM (系統指令)
                case (instr[14:12])
                    3'b000: begin // PRIV (特權指令)
                        case (instr[24:20])
                            5'b00000: begin // ECALL (系統呼叫)
                                ecause_out <= 11; // 設置異常原因為 ECALL
                                exception_out <= 1; // 發生異常
                                // 檢查指令是否有效
                                if (instr[31:25] != 0 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                    ecause_out <= 2; // 設置異常原因
                                end
                            end
                            5'b00001: begin // EBREAK (斷點)
                                ecause_out <= 3; // 設置異常原因為 EBREAK
                                exception_out <= 1; // 發生異常
                                // 檢查指令是否有效
                                if (instr[31:25] != 0 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                    ecause_out <= 2; // 設置異常原因
                                end
                            end
                            5'b00010: begin // MRET (返回到特權模式)
                                mret_out <= 1; // 設置 MRET 信號
                                // 檢查指令是否有效
                                if (instr[31:25] != 7'b0011000 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                    ecause_out <= 2; // 設置異常原因
                                    exception_out <= 1; // 發生異常
                                end
                            end
                            5'b00101: begin // WFI (等待中斷)
                                wfi_out <= 1; // 設置 WFI 信號
                                // 檢查指令是否有效
                                if (instr[31:25] != 7'b0001000 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                    ecause_out <= 2; // 設置異常原因
                                    exception_out <= 1; // 發生異常
                                end
                            end
                            default: begin // 其他特權指令
                                ecause_out <= 2; // 設置異常原因
                                exception_out <= 1; // 發生異常
                            end
                        endcase
                    end
                    3'b001: begin // CSRRW (寄存器寫入 CSR)
                        rd_address_out <= rd_address; // 設置目的寄存器地址
                        bypass_memory_out <= 1; // 使能繞過記憶體
                        alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                        csr_read_out <= (rd_address != 0); // 檢查 CSR 讀取
                        csr_write_out <= 1; // 使能 CSR 寫入
                        write_select_out <= WRITE_SEL_CSR; // 設置寫入選擇為 CSR
                    end
                    3'b010: begin // CSRRS (寄存器讀取 CSR)
                        rd_address_out <= rd_address; // 設置目的寄存器地址
                        bypass_memory_out <= 1; // 使能繞過記憶體
                        alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                        alu_select_b_out <= ALU_SEL_CSR; // ALU 輸入 B 選擇 CSR
                        csr_read_out <= 1; // 使能 CSR 讀取
                        csr_write_out <= (rs1_address != 0); // 檢查 CSR 寫入
                        write_select_out <= WRITE_SEL_CSR; // 設置寫入選擇為 CSR
                    end
                    3'b011: begin // CSRRC (寄存器清除 CSR)
                        rd_address_out <= rd_address; // 設置目的寄存器地址
                        bypass_memory_out <= 1; // 使能繞過記憶體
                        alu_function_out <= ALU_AND_CLR; // 設置 ALU 功能為 AND 清除
                        alu_function_modifier_out <= 1; // 設置功能修飾
                        alu_select_a_out <= ALU_SEL_REG; // ALU 輸入 A 選擇寄存器
                        alu_select_b_out <= ALU_SEL_CSR; // ALU 輸入 B 選擇 CSR
                        csr_read_out <= 1; // 使能 CSR 讀取
                        csr_write_out <= (rs1_address != 0); // 檢查 CSR 寫入
                        write_select_out <= WRITE_SEL_CSR; // 設置寫入選擇為 CSR
                    end
                    3'b101: begin // CSRRWI (立即數寫入 CSR)
                        rd_address_out <= rd_address; // 設置目的寄存器地址
                        bypass_memory_out <= 1; // 使能繞過記憶體
                        imm_data_out <= csr_type_imm_data; // 設置立即數為 CSR 立即數
                        csr_read_out <= (rd_address != 0); // 檢查 CSR 讀取
                        csr_write_out <= 1; // 使能 CSR 寫入
                        write_select_out <= WRITE_SEL_CSR; // 設置寫入選擇為 CSR
                    end
                    3'b110: begin // CSRRSI (立即數讀取 CSR)
                        rd_address_out <= rd_address; // 設置目的寄存器地址
                        bypass_memory_out <= 1; // 使能繞過記憶體
                        alu_select_b_out <= ALU_SEL_CSR; // ALU 輸入 B 選擇 CSR
                        imm_data_out <= csr_type_imm_data; // 設置立即數為 CSR 立即數
                        csr_read_out <= 1; // 使能 CSR 讀取
                        csr_write_out <= (rs1_address != 0); // 檢查 CSR 寫入
                        write_select_out <= WRITE_SEL_CSR; // 設置寫入選擇為 CSR
                    end
                    3'b111: begin // CSRRCI (立即數清除 CSR)
                        rd_address_out <= rd_address; // 設置目的寄存器地址
                        bypass_memory_out <= 1; // 使能繞過記憶體
                        alu_function_out <= ALU_AND_CLR; // 設置 ALU 功能為 AND 清除
                        alu_function_modifier_out <= 1; // 設置功能修飾
                        alu_select_b_out <= ALU_SEL_CSR; // ALU 輸入 B 選擇 CSR
                        imm_data_out <= csr_type_imm_data; // 設置立即數為 CSR 立即數
                        csr_read_out <= 1; // 使能 CSR 讀取
                        csr_write_out <= (rs1_address != 0); // 檢查 CSR 寫入
                        write_select_out <= WRITE_SEL_CSR; // 設置寫入選擇為 CSR
                    end
                    default: begin
                        ecause_out <= 2; // 設置異常原因為未定義操作碼
                        exception_out <= 1; // 標記發生異常
                    end
                endcase
            end
            default: begin
                ecause_out <= 2; // 設置異常原因為未定義操作碼
                exception_out <= 1; // 標記發生異常
            end
        endcase

        // 根據 rs1_address 設置寄存器 rs1 的繞過信號
        case (rs1_address)
            0: begin // 當 rs1_address 為 0 時
                rs1_bypassed_out <= 1; // 標記 rs1 被繞過
                rs1_bypass_out <= 0; // 由於為 0，繞過數據為 0
            end
            bypass_memory_address: begin // 當 rs1_address 等於繞過記憶體地址時
                rs1_bypassed_out <= 1; // 標記 rs1 被繞過
                rs1_bypass_out <= bypass_memory_data; // 繞過數據來自記憶體
            end
            bypass_writeback_address: begin // 當 rs1_address 等於寫回地址時
                rs1_bypassed_out <= 1; // 標記 rs1 被繞過
                rs1_bypass_out <= bypass_writeback_data; // 繞過數據來自寫回
            end
            default: begin // 當 rs1_address 不是以上情況時
                rs1_bypassed_out <= 0; // 標記 rs1 未被繞過
                rs1_bypass_out <= 0; // 繞過數據為 0
            end
        endcase 

        // 根據 rs2_address 設置寄存器 rs2 的繞過信號
        case (rs2_address)
            0: begin // 當 rs2_address 為 0 時
                rs2_bypassed_out <= 1; // 標記 rs2 被繞過
                rs2_bypass_out <= 0; // 由於為 0，繞過數據為 0
            end
            bypass_memory_address: begin // 當 rs2_address 等於繞過記憶體地址時
                rs2_bypassed_out <= 1; // 標記 rs2 被繞過
                rs2_bypass_out <= bypass_memory_data; // 繞過數據來自記憶體
            end
            bypass_writeback_address: begin // 當 rs2_address 等於寫回地址時
                rs2_bypassed_out <= 1; // 標記 rs2 被繞過
                rs2_bypass_out <= bypass_writeback_data; // 繞過數據來自寫回
            end
            default: begin // 當 rs2_address 不是以上情況時
                rs2_bypassed_out <= 0; // 標記 rs2 未被繞過
                rs2_bypass_out <= 0; // 繞過數據為 0
            end
        endcase 
    end
end

endmodule
