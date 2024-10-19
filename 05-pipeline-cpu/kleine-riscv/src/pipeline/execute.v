module execute (
    input clk, // 時鐘信號

    // 來自 decode 模組的輸入
    input [31:0] pc_in, // 當前指令的程式計數器
    input [31:0] next_pc_in, // 下一個指令的程式計數器
    // 來自 decode 的資料
    input [31:0] rs1_data_in, // rs1 的數據
    input [31:0] rs2_data_in, // rs2 的數據
    input [31:0] rs1_bypass_in, // rs1 繞過的數據
    input [31:0] rs2_bypass_in, // rs2 繞過的數據
    input rs1_bypassed_in, // rs1 是否被繞過的標誌
    input rs2_bypassed_in, // rs2 是否被繞過的標誌
    input [31:0] csr_data_in, // 控制和狀態寄存器的數據
    input [31:0] imm_data_in, // 立即數
    input [2:0] alu_function_in, // ALU 功能選擇
    input alu_function_modifier_in, // ALU 功能修飾符
    input [1:0] alu_select_a_in, // ALU A 輸入選擇
    input [1:0] alu_select_b_in, // ALU B 輸入選擇
    input [2:0] cmp_function_in, // 比較功能選擇
    input jump_in, // 跳轉信號
    input branch_in, // 分支信號
    input csr_read_in, // CSR 讀取信號
    input csr_write_in, // CSR 寫入信號
    input csr_readable_in, // CSR 可讀取標誌
    input csr_writeable_in, // CSR 可寫入標誌
    // 來自 decode 的存儲控制信號
    input load_in, // 加載信號
    input store_in, // 儲存信號
    input [1:0] load_store_size_in, // 加載/儲存大小
    input load_signed_in, // 是否為有符號加載
    input bypass_memory_in, // 繞過記憶體信號
    // 來自 decode 的寫回控制信號
    input [1:0] write_select_in, // 寫回選擇
    input [4:0] rd_address_in, // 寫回的寄存器地址
    input [11:0] csr_address_in, // CSR 地址
    input mret_in, // 中斷返回信號
    input wfi_in, // 等待中斷信號
    // 來自 decode 的有效性信號
    input valid_in, // 輸入有效信號
    input [3:0] ecause_in, // 異常原因
    input exception_in, // 異常信號
    
    // 來自 hazard 控制的信號
    input stall, // 停頓信號
    input invalidate, // 使無效信號

    // 發送到記憶體的輸出
    output reg [31:0] pc_out, // 輸出程式計數器
    output reg [31:0] next_pc_out, // 輸出下一個程式計數器
    // 發送到記憶體的控制信號
    output [31:0] alu_data_out, // ALU 輸出數據
    output [31:0] alu_addition_out, // ALU 加法結果
    output reg [31:0] rs2_data_out, // 輸出 rs2 數據
    output reg [31:0] csr_data_out, // 輸出 CSR 數據
    output reg branch_out, // 分支輸出
    output reg jump_out, // 跳轉輸出
    output cmp_output_out, // 比較結果輸出
    output reg load_out, // 加載輸出
    output reg store_out, // 儲存輸出
    output reg [1:0] load_store_size_out, // 加載/儲存大小輸出
    output reg load_signed_out, // 有符號加載輸出
    output reg bypass_memory_out, // 繞過記憶體輸出
    // 發送到記憶體的控制信號
    output reg [1:0] write_select_out, // 寫回選擇輸出
    output reg [4:0] rd_address_out, // 寫回寄存器地址輸出
    output reg [11:0] csr_address_out, // CSR 地址輸出
    output reg csr_write_out, // CSR 寫入輸出
    output reg mret_out, // 中斷返回輸出
    output reg wfi_out, // 等待中斷輸出
    // 發送到記憶體的有效信號
    output reg valid_out, // 輸出有效信號
    output reg [3:0] ecause_out, // 輸出異常原因
    output reg exception_out // 輸出異常信號
);

// ALU 輸入選擇的本地參數
localparam ALU_SEL_REG = 2'b00; // 選擇寄存器作為 ALU 的輸入 A
localparam ALU_SEL_IMM = 2'b01; // 選擇立即數作為 ALU 的輸入 A
localparam ALU_SEL_PC  = 2'b10; // 選擇程式計數器作為 ALU 的輸入 A
localparam ALU_SEL_CSR = 2'b11; // 選擇 CSR 作為 ALU 的輸入 A

// 根據 rs1_bypassed_in 判斷使用哪個 rs1 數據
wire [31:0] acctual_rs1 = rs1_bypassed_in ? rs1_bypass_in : rs1_data_in;
// 根據 rs2_bypassed_in 判斷使用哪個 rs2 數據
wire [31:0] acctual_rs2 = rs2_bypassed_in ? rs2_bypass_in : rs2_data_in;

// 實例化比較器模組
cmp ex_cmp (
    .clk(clk), // 時鐘信號
    .input_a(acctual_rs1), // 輸入 A
    .input_b(acctual_rs2), // 輸入 B
    .function_select(cmp_function_in), // 比較功能選擇
    .result(cmp_output_out) // 比較結果輸出
);

// ALU 輸入寄存器
reg [31:0] alu_input_a;
reg [31:0] alu_input_b;

// 根據選擇信號設置 ALU 輸入 A 和 B
always @(*) begin
    case (alu_select_a_in)
        ALU_SEL_REG : alu_input_a = acctual_rs1; // 使用 rs1 數據
        ALU_SEL_IMM : alu_input_a = imm_data_in; // 使用立即數
        ALU_SEL_PC  : alu_input_a = pc_in; // 使用程式計數器
        ALU_SEL_CSR : alu_input_a = csr_data_in; // 使用 CSR 數據
    endcase
    case (alu_select_b_in)
        ALU_SEL_REG : alu_input_b = acctual_rs2; // 使用 rs2 數據
        ALU_SEL_IMM : alu_input_b = imm_data_in; // 使用立即數
        ALU_SEL_PC  : alu_input_b = pc_in; // 使用程式計數器
        ALU_SEL_CSR : alu_input_b = csr_data_in; // 使用 CSR 數據
    endcase
end

// 實例化 ALU 模組
alu ex_alu (
    .clk(clk), // 時鐘信號
    .input_a(alu_input_a), // ALU 輸入 A
    .input_b(alu_input_b), // ALU 輸入 B
    .function_select(alu_function_in), // ALU 功能選擇
    .function_modifier(alu_function_modifier_in), // ALU 功能修飾符
    .add_result(alu_addition_out), // ALU 加法結果
    .result(alu_data_out) // ALU 最終結果
);

// 檢查 CSR 讀取和寫入的有效性
wire csr_exception = ((csr_read_in && !csr_readable_in) || (csr_write_in && !csr_writeable_in));

// 在時鐘上升沿更新輸出
always @(posedge clk) begin
    // 根據 stall 和 invalidate 來更新 valid_out
    valid_out <= (stall ? valid_out : valid_in) && !invalidate;
    if (!stall) begin // 當不在 stall 狀態時
        pc_out <= pc_in; // 更新程式計數器
        next_pc_out <= next_pc_in; // 更新下一個程式計數器
        rs2_data_out <= acctual_rs2; // 更新 rs2 數據
        csr_data_out <= csr_data_in; // 更新 CSR 數據
        branch_out <= branch_in; // 更新分支信號
        jump_out <= jump_in; // 更新跳轉信號
        load_out <= load_in; // 更新加載信號
        store_out <= store_in; // 更新儲存信號
        load_store_size_out <= load_store_size_in; // 更新加載/儲存大小
        load_signed_out <= load_signed_in; // 更新有符號加載信號
        write_select_out <= write_select_in; // 更新寫回選擇
        rd_address_out <= rd_address_in; // 更新寫回寄存器地址
        bypass_memory_out <= bypass_memory_in; // 更新繞過記憶體信號
        csr_address_out <= csr_address_in; // 更新 CSR 地址
        csr_write_out <= csr_write_in; // 更新 CSR 寫入信號
        mret_out <= mret_in; // 更新中斷返回信號
        wfi_out <= wfi_in; // 更新等待中斷信號
        // 處理異常情況
        if (!exception_in && csr_exception) begin
            ecause_out <= 2; // 設置異常原因
            exception_out <= 1; // 標記發生異常
        end else begin
            ecause_out <= ecause_in; // 更新異常原因
            exception_out <= exception_in; // 更新異常信號
        end
    end
end

endmodule
