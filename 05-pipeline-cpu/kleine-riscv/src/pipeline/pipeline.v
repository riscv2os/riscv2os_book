module pipeline #(
    parameter RESET_VECTOR = 32'h8000_0000 // 定義重置向量的值
) (
    input clk, // 時鐘信號
    input reset, // 重置信號

    // 來自中斷控制器的信號
    input meip, // 中斷信號

    // 從 busio 到 fetch 的數據
    input [31:0] fetch_data, // 從 busio 獲取的指令數據
    // 從 busio 到 memory 的數據
    input [31:0] mem_load_data, // 從 busio 獲取的加載數據
    // 從 busio 到 hazard 的信號
    input fetch_ready, // fetch 階段是否準備好
    input mem_ready, // memory 階段是否準備好

    // 發送到 busio 的 fetch 輸出
    output [31:0] fetch_address, // 從 fetch 模組發送的地址
    // 發送到 busio 的 memory 輸出
    output [31:0] mem_address, // 記憶體地址輸出
    output [31:0] mem_store_data, // 記憶體儲存數據輸出
    output [1:0] mem_size, // 記憶體操作的大小
    output mem_signed, // 是否為有符號數據
    output mem_load, // 加載操作信號
    output mem_store // 儲存操作信號
);

// 實例化 CSR 模組
csr pipeline_csr (
    .clk(clk), // 時鐘信號
    .reset(reset), // 重置信號

    .meip(meip), // 中斷信號

    // 來自 decode 的讀取地址
    .read_address(decode_to_csr_read_address),
    // 發送到 decode 的讀取數據
    .read_data(csr_to_decode_read_data),
    .readable(csr_to_decode_readable), // 是否可讀
    .writeable(csr_to_decode_writable), // 是否可寫

    // 來自 writeback 的寫入信號
    .write_enable(writeback_to_csr_write_enable), // 寫入使能信號
    .write_address(writeback_to_csr_write_address), // 寫入地址
    .write_data(writeback_to_csr_write_data), // 寫入數據
    // 來自 writeback 的信號
    .retired(writeback_to_csr_retired), // 寫回是否已經完成
    .traped(global_traped), // 是否觸發了陷阱
    .mret(global_mret), // 是否進行中斷返回
    .ecp(writeback_to_csr_ecp), // 異常上下文指針
    .trap_cause(writeback_to_csr_trap_cause), // 陷阱原因
    .interupt(writeback_to_csr_interupt), // 中斷信號
    // 發送到 writeback 的信號
    .eip(csr_to_writeback_eip), // 異常處理上下文
    .tip(csr_to_writeback_tip), // 定時器中斷信號
    .sip(csr_to_writeback_sip), // 硬體中斷信號

    // 發送到 fetch 的陷阱向量
    .trap_vector(csr_to_fetch_trap_vector),
    .mret_vector(csr_to_fetch_mret_vector) // 中斷返回向量
);

// 定義 CSR 模組的信號連接
wire [11:0] decode_to_csr_read_address; // 從 decode 模組到 CSR 模組的讀取地址
wire [31:0] csr_to_decode_read_data; // 從 CSR 模組到 decode 模組的讀取數據
wire csr_to_decode_readable; // CSR 模組是否可讀
wire csr_to_decode_writable; // CSR 模組是否可寫

wire writeback_to_csr_write_enable; // 寫回 CSR 模組的使能信號
wire [11:0] writeback_to_csr_write_address; // 寫回 CSR 模組的地址
wire [31:0] writeback_to_csr_write_data; // 寫回 CSR 模組的數據
wire writeback_to_csr_retired; // 寫回 CSR 模組的狀態信號
wire [31:0] writeback_to_csr_ecp; // 寫回 CSR 模組的異常上下文指針
wire [3:0] writeback_to_csr_trap_cause; // 寫回 CSR 模組的陷阱原因
wire writeback_to_csr_interupt; // 寫回 CSR 模組的中斷信號
wire csr_to_writeback_eip; // CSR 模組到寫回的異常處理上下文信號
wire csr_to_writeback_tip; // CSR 模組到寫回的定時器中斷信號
wire csr_to_writeback_sip; // CSR 模組到寫回的硬體中斷信號

wire [31:0] csr_to_fetch_trap_vector; // CSR 模組到 fetch 的陷阱向量
wire [31:0] csr_to_fetch_mret_vector; // CSR 模組到 fetch 的中斷返回向量

// 定義全域信號
wire global_traped; // 全域觸發的陷阱信號
wire global_mret; // 全域中斷返回信號
wire global_wfi; // 全域等待中斷信號

// 實例化寄存器檔模組
regfile pipeline_registers (
    .clk(clk), // 時鐘信號

    // 來自 decode 的讀取端口地址
    .rs1_address(decode_to_regfile_rs1_address), // rs1 寄存器的地址
    .rs2_address(decode_to_regfile_rs2_address), // rs2 寄存器的地址
    // 發送到 decode 的讀取端口數據
    .rs1_data(regfile_to_decode_rs1_data), // rs1 寄存器的數據
    .rs2_data(regfile_to_decode_rs2_data), // rs2 寄存器的數據

    // 來自 writeback 的寫入端口信號
    .rd_address(writeback_to_regfile_rd_address), // 寫回寄存器的地址
    .rd_data(writeback_to_regfile_rd_data) // 寫回寄存器的數據
);

// 定義寄存器檔模組的信號連接
wire [4:0] decode_to_regfile_rs1_address; // 從 decode 模組到寄存器檔的 rs1 地址
wire [4:0] decode_to_regfile_rs2_address; // 從 decode 模組到寄存器檔的 rs2 地址
wire [31:0] regfile_to_decode_rs1_data; // 從寄存器檔到 decode 模組的 rs1 數據
wire [31:0] regfile_to_decode_rs2_data; // 從寄存器檔到 decode 模組的 rs2 數據

wire [4:0] writeback_to_regfile_rd_address; // 寫回寄存器檔的地址
wire [31:0] writeback_to_regfile_rd_data; // 寫回寄存器檔的數據
// 實例化 hazard 模組以檢測和處理流水線中的危險
hazard pipeline_hazard (
    .reset(reset), // 重置信號

    // 來自 decode 階段的信號
    .valid_decode(fetch_to_decode_valid), // decode 階段的有效信號
    .rs1_address_decode(decode_to_regfile_rs1_address), // rs1 地址
    .rs2_address_decode(decode_to_regfile_rs2_address), // rs2 地址
    .uses_rs1(decode_to_hazaed_uses_rs1), // 是否使用 rs1
    .uses_rs2(decode_to_hazaed_uses_rs2), // 是否使用 rs2
    .uses_csr(decode_to_hazaed_uses_csr), // 是否使用 CSR

    // 來自 execute 階段的信號
    .valid_execute(decode_to_execute_valid), // execute 階段的有效信號
    .rd_address_execute(decode_to_execute_rd_address), // 寫回地址
    .csr_write_execute(decode_to_execute_csr_write), // 是否寫入 CSR
        
    // 來自 memory 階段的信號
    .valid_memory(execute_to_memory_valid), // memory 階段的有效信號
    .rd_address_memory(execute_to_memory_rd_address), // 寫回地址
    .csr_write_memory(execute_to_memory_csr_write), // 是否寫入 CSR
    .branch_taken(global_branch_taken), // 分支是否被採取
    .mret_memory(execute_to_memory_mret), // memory 階段的 mret 信號
    .load_store(mem_load || mem_store), // 是否進行加載或儲存操作
    .bypass_memory(memory_to_decode_bypass_address != 0), // 是否有 bypass

    // 來自 writeback 階段的信號
    .valid_writeback(memory_to_writeback_valid), // writeback 階段的有效信號
    .csr_write_writeback(writeback_to_csr_write_enable), // 是否寫入 CSR
    .mret_writeback(global_mret), // writeback 階段的 mret 信號
    .traped(global_traped), // 是否觸發了陷阱
    .wfi(global_wfi), // 是否進入等待中斷狀態

    // 來自 busio 的信號
    .fetch_ready(fetch_ready), // fetch 階段是否準備好
    .mem_ready(mem_ready), // memory 階段是否準備好

    // 發送到 fetch 階段的控制信號
    .stall_fetch(hazard_to_fetch_stall), // fetch 階段的停頓信號
    .invalidate_fetch(hazard_to_fetch_invalidate), // fetch 階段的無效信號

    // 發送到 decode 階段的控制信號
    .stall_decode(hazard_to_decode_stall), // decode 階段的停頓信號
    .invalidate_decode(hazard_to_decode_invalidate), // decode 階段的無效信號

    // 發送到 execute 階段的控制信號
    .stall_execute(hazard_to_execute_stall), // execute 階段的停頓信號
    .invalidate_execute(hazard_to_execute_invalidate), // execute 階段的無效信號

    // 發送到 memory 階段的控制信號
    .stall_memory(hazard_to_memory_stall), // memory 階段的停頓信號
    .invalidate_memory(hazard_to_memory_invalidate) // memory 階段的無效信號
);

// 定義與危險檢測相關的信號
wire decode_to_hazaed_uses_rs1; // decode 階段是否使用 rs1 的信號
wire decode_to_hazaed_uses_rs2; // decode 階段是否使用 rs2 的信號
wire decode_to_hazaed_uses_csr; // decode 階段是否使用 CSR

// 定義來自 hazard 模組的控制信號
wire hazard_to_fetch_stall; // 用於控制 fetch 階段的停頓信號
wire hazard_to_fetch_invalidate; // 用於控制 fetch 階段的無效信號

wire hazard_to_decode_stall; // 用於控制 decode 階段的停頓信號
wire hazard_to_decode_invalidate; // 用於控制 decode 階段的無效信號

wire hazard_to_execute_stall; // 用於控制 execute 階段的停頓信號
wire hazard_to_execute_invalidate; // 用於控制 execute 階段的無效信號

wire hazard_to_memory_stall; // 用於控制 memory 階段的停頓信號
wire hazard_to_memory_invalidate; // 用於控制 memory 階段的無效信號

wire global_branch_taken; // 標記是否發生了全局分支

// 實例化 fetch 模組以獲取指令並進行處理
fetch #(
    .RESET_VECTOR(RESET_VECTOR) // 定義重置向量參數
) pipeline_fetch (
    .clk(clk), // 時鐘信號
    .reset(reset), // 重置信號

    // 從 memory 階段接收的信號
    .branch(global_branch_taken), // 來自 hazard 的全局分支信號
    .branch_vector(memory_to_fetch_branch_address), // 來自 memory 的分支地址

    // 從 writeback 階段接收的信號
    .trap(global_traped), // 是否觸發了全局陷阱
    .mret(global_mret), // 是否執行 mret

    // 從 csr 接收的信號
    .trap_vector(csr_to_fetch_trap_vector), // CSR 定義的陷阱向量
    .mret_vector(csr_to_fetch_mret_vector), // CSR 定義的 mret 向量

    // 從 hazard 模組接收的控制信號
    .stall(hazard_to_fetch_stall), // 控制 fetch 階段的停頓信號
    .invalidate(hazard_to_fetch_invalidate), // 控制 fetch 階段的無效信號
    
    // 從 fetch 模組到 busio 的信號
    .fetch_address(fetch_address), // 用於訪問的地址
    // 從 busio 到 fetch 的信號
    .fetch_data(fetch_data), // 獲取的數據

    // 從 fetch 到 decode 的輸出信號
    .pc_out(fetch_to_decode_pc), // 輸出當前程序計數器的值
    .next_pc_out(fetch_to_decode_next_pc), // 輸出下一個程序計數器的值
    .instruction_out(fetch_to_decode_instruction), // 輸出獲取的指令
    .valid_out(fetch_to_decode_valid) // 表示指令是否有效的信號
);
// 定義從 memory 階段到 fetch 階段的分支地址
wire [31:0] memory_to_fetch_branch_address; // 記錄從 memory 階段回傳的分支地址

// 定義從 fetch 階段到 decode 階段的輸入信號
wire [31:0] fetch_to_decode_pc; // 當前程序計數器的值
wire [31:0] fetch_to_decode_next_pc; // 下一個程序計數器的值
wire [31:0] fetch_to_decode_instruction; // 獲取到的指令
wire fetch_to_decode_valid; // 指令的有效性標誌

// 實例化 decode 模組以解碼指令
decode pipeline_decode (
    .clk(clk), // 時鐘信號

    // 從 fetch 階段接收的信號
    .pc_in(fetch_to_decode_pc), // 當前程序計數器輸入
    .next_pc_in(fetch_to_decode_next_pc), // 下一個程序計數器輸入
    .instruction_in(fetch_to_decode_instruction), // 指令輸入
    .valid_in(fetch_to_decode_valid), // 指令有效性輸入

    // 從 hazard 模組接收的控制信號
    .stall(hazard_to_decode_stall), // 控制 decode 階段的停頓信號
    .invalidate(hazard_to_decode_invalidate), // 控制 decode 階段的無效信號
    
    // 將使用的寄存器地址發送到 hazard 模組
    .uses_rs1(decode_to_hazaed_uses_rs1), // 是否使用 rs1 寄存器
    .uses_rs2(decode_to_hazaed_uses_rs2), // 是否使用 rs2 寄存器
    .uses_csr(decode_to_hazaed_uses_csr), // 是否使用 CSR 寄存器

    // 將 rs1 和 rs2 的地址發送到 regfile 模組
    .rs1_address(decode_to_regfile_rs1_address), // rs1 寄存器的地址
    .rs2_address(decode_to_regfile_rs2_address), // rs2 寄存器的地址
    
    // 從 regfile 模組接收數據
    .rs1_data(regfile_to_decode_rs1_data), // rs1 寄存器的數據
    .rs2_data(regfile_to_decode_rs2_data), // rs2 寄存器的數據
    
    // 將 CSR 的地址發送到 csr 模組
    .csr_address(decode_to_csr_read_address), // CSR 寄存器的地址
    // 從 CSR 模組接收數據
    .csr_data(csr_to_decode_read_data), // CSR 寄存器的數據
    .csr_readable(csr_to_decode_readable), // CSR 是否可讀
    .csr_writeable(csr_to_decode_writable), // CSR 是否可寫

    // 從 memory 階段接收旁路地址和數據
    .bypass_memory_address(memory_to_decode_bypass_address), // 旁路記憶體的地址
    .bypass_memory_data(memory_to_decode_bypass_data), // 旁路記憶體的數據

    // 從 writeback 階段接收旁路地址和數據
    .bypass_writeback_address(writeback_to_regfile_rd_address), // 旁路寫回的地址
    .bypass_writeback_data(writeback_to_regfile_rd_data), // 旁路寫回的數據

    // 將輸出信號發送到 execute 階段
    .pc_out(decode_to_execute_pc), // 將 pc 發送到 execute 階段
    .next_pc_out(decode_to_execute_next_pc), // 將 next pc 發送到 execute 階段
    // 將 rs1 和 rs2 的數據發送到 execute 階段
    .rs1_data_out(decode_to_execute_rs1_data), // rs1 的數據
    .rs2_data_out(decode_to_execute_rs2_data), // rs2 的數據
    .rs1_bypass_out(decode_to_execute_rs1_bypass), // rs1 的旁路信號
    .rs2_bypass_out(decode_to_execute_rs2_bypass), // rs2 的旁路信號
    .rs1_bypassed_out(decode_to_execute_rs1_bypassed), // rs1 是否已被旁路
    .rs2_bypassed_out(decode_to_execute_rs2_bypassed), // rs2 是否已被旁路
    .csr_data_out(decode_to_execute_csr_data), // CSR 數據
    .imm_data_out(decode_to_execute_imm_data), // 立即數數據
    .alu_function_out(decode_to_execute_alu_function), // ALU 功能選擇
    .alu_function_modifier_out(decode_to_execute_alu_function_modifier), // ALU 功能修飾符
    .alu_select_a_out(decode_to_execute_alu_select_a), // ALU A 選擇信號
    .alu_select_b_out(decode_to_execute_alu_select_b), // ALU B 選擇信號
    .cmp_function_out(decode_to_execute_cmp_function), // 比較功能
    .jump_out(decode_to_execute_jump), // 跳轉信號
    .branch_out(decode_to_execute_branch), // 分支信號
    .csr_read_out(decode_to_execute_csr_read), // CSR 讀取信號
    .csr_write_out(decode_to_execute_csr_write), // CSR 寫入信號
    .csr_readable_out(decode_to_execute_csr_readable), // CSR 可讀性信號
    .csr_writeable_out(decode_to_execute_csr_writeable), // CSR 可寫性信號
    // 將控制信號發送到 execute 階段
    .load_out(decode_to_execute_load), // 加載指令信號
    .store_out(decode_to_execute_store), // 儲存指令信號
    .load_store_size_out(decode_to_execute_load_store_size), // 加載/儲存大小
    .load_signed_out(decode_to_execute_load_signed), // 是否加載有符號數據
    .bypass_memory_out(decode_to_execute_bypass_memory), // 記憶體旁路信號
    // 將寫回階段的相關信息發送到 execute 階段
    .write_select_out(decode_to_execute_write_select), // 寫入選擇信號
    .rd_address_out(decode_to_execute_rd_address), // rd 寄存器的地址
    .csr_address_out(decode_to_execute_csr_address), // CSR 寄存器的地址
    .mret_out(decode_to_execute_mret), // mret 信號
    .wfi_out(decode_to_execute_wfi), // wfi 信號
    // 輸出有效性信號和異常信號
    .valid_out(decode_to_execute_valid), // 指令有效性輸出
    .ecause_out(decode_to_execute_ecause), // 異常原因
    .exception_out(decode_to_execute_exception) // 異常信號
);

// 定義從 memory 階段到 decode 階段的旁路地址和數據
wire [4:0] memory_to_decode_bypass_address; // 旁路地址
wire [31:0] memory_to_decode_bypass_data; // 旁路數據

// 定義從 decode 階段到 execute 階段的輸出信號
wire [31:0] decode_to_execute_pc; // 當前程序計數器的值
wire [31:0] decode_to_execute_next_pc; // 下一個程序計數器的值
wire [31:0] decode_to_execute_rs1_data; // rs1 寄存器的數據
wire [31:0] decode_to_execute_rs2_data; // rs2 寄存器的數據
wire [31:0] decode_to_execute_rs1_bypass; // rs1 的旁路數據
wire [31:0] decode_to_execute_rs2_bypass; // rs2 的旁路數據
wire decode_to_execute_rs1_bypassed; // rs1 是否已被旁路
wire decode_to_execute_rs2_bypassed; // rs2 是否已被旁路
wire [31:0] decode_to_execute_csr_data; // CSR 數據
wire [31:0] decode_to_execute_imm_data; // 立即數數據
wire [2:0] decode_to_execute_alu_function; // ALU 功能選擇
wire decode_to_execute_alu_function_modifier; // ALU 功能修飾符
wire [1:0] decode_to_execute_alu_select_a; // ALU A 選擇信號
wire [1:0] decode_to_execute_alu_select_b; // ALU B 選擇信號
wire [2:0] decode_to_execute_cmp_function; // 比較功能
wire decode_to_execute_jump; // 跳轉信號
wire decode_to_execute_branch; // 分支信號
wire decode_to_execute_csr_read; // CSR 讀取信號
wire decode_to_execute_csr_write; // CSR 寫入信號
wire decode_to_execute_csr_readable; // CSR 可讀性信號
wire decode_to_execute_csr_writeable; // CSR 可寫性信號
wire decode_to_execute_load; // 加載指令信號
wire decode_to_execute_store; // 儲存指令信號
wire [1:0] decode_to_execute_load_store_size; // 加載/儲存大小
wire decode_to_execute_load_signed; // 是否加載有符號數據
wire decode_to_execute_bypass_memory; // 記憶體旁路信號
wire [1:0] decode_to_execute_write_select; // 寫入選擇信號
wire [4:0] decode_to_execute_rd_address; // rd 寄存器的地址
wire [11:0] decode_to_execute_csr_address; // CSR 寄存器的地址
wire decode_to_execute_mret; // mret 信號
wire decode_to_execute_wfi; // wfi 信號
wire decode_to_execute_valid; // 指令有效性輸出
wire [3:0] decode_to_execute_ecause; // 異常原因
wire decode_to_execute_exception; // 異常信號

// 實例化 execute 模組以執行 ALU 操作和處理指令
execute pipeline_execute (
    .clk(clk), // 時鐘信號

    // 從 decode 階段接收的信號
    .pc_in(decode_to_execute_pc), // 當前程序計數器輸入
    .next_pc_in(decode_to_execute_next_pc), // 下一個程序計數器輸入
    // 從 decode 階段接收的數據和控制信號 (控制 EX)
    .rs1_data_in(decode_to_execute_rs1_data), // rs1 的數據
    .rs2_data_in(decode_to_execute_rs2_data), // rs2 的數據
    .rs1_bypass_in(decode_to_execute_rs1_bypass), // rs1 的旁路數據
    .rs2_bypass_in(decode_to_execute_rs2_bypass), // rs2 的旁路數據
    .rs1_bypassed_in(decode_to_execute_rs1_bypassed), // rs1 是否已旁路
    .rs2_bypassed_in(decode_to_execute_rs2_bypassed), // rs2 是否已旁路
    .csr_data_in(decode_to_execute_csr_data), // CSR 數據
    .imm_data_in(decode_to_execute_imm_data), // 立即數數據
    .alu_function_in(decode_to_execute_alu_function), // ALU 功能選擇
    .alu_function_modifier_in(decode_to_execute_alu_function_modifier), // ALU 功能修飾符
    .alu_select_a_in(decode_to_execute_alu_select_a), // ALU A 選擇信號
    .alu_select_b_in(decode_to_execute_alu_select_b), // ALU B 選擇信號
    .cmp_function_in(decode_to_execute_cmp_function), // 比較功能
    .jump_in(decode_to_execute_jump), // 跳轉信號
    .branch_in(decode_to_execute_branch), // 分支信號
    .csr_read_in(decode_to_execute_csr_read), // CSR 讀取信號
    .csr_write_in(decode_to_execute_csr_write), // CSR 寫入信號
    .csr_readable_in(decode_to_execute_csr_readable), // CSR 可讀性信號
    .csr_writeable_in(decode_to_execute_csr_writeable), // CSR 可寫性信號
    // 從 decode 階段接收的數據 (控制 MEM)
    .load_in(decode_to_execute_load), // 加載指令信號
    .store_in(decode_to_execute_store), // 儲存指令信號
    .load_store_size_in(decode_to_execute_load_store_size), // 加載/儲存大小
    .load_signed_in(decode_to_execute_load_signed), // 是否加載有符號數據
    .bypass_memory_in(decode_to_execute_bypass_memory), // 記憶體旁路信號
    // 從 decode 階段接收的數據 (控制 WB)
    .write_select_in(decode_to_execute_write_select), // 寫入選擇信號
    .rd_address_in(decode_to_execute_rd_address), // rd 寄存器的地址
    .csr_address_in(decode_to_execute_csr_address), // CSR 寄存器的地址
    .mret_in(decode_to_execute_mret), // mret 信號
    .wfi_in(decode_to_execute_wfi), // wfi 信號
    // 從 decode 階段接收的有效性和異常信號
    .valid_in(decode_to_execute_valid), // 指令有效性輸入
    .ecause_in(decode_to_execute_ecause), // 異常原因
    .exception_in(decode_to_execute_exception), // 異常信號
    
    // 從 hazard 模組接收的控制信號
    .stall(hazard_to_execute_stall), // 控制 execute 階段的停頓信號
    .invalidate(hazard_to_execute_invalidate), // 控制 execute 階段的無效信號

    // 將輸出信號發送到 memory 階段
    .pc_out(execute_to_memory_pc), // 當前程序計數器輸出
    .next_pc_out(execute_to_memory_next_pc), // 下一個程序計數器輸出
    // 將 ALU 的計算結果和控制信號發送到 memory 階段 (控制 MEM)
    .alu_data_out(execute_to_memory_alu_data), // ALU 計算結果
    .alu_addition_out(execute_to_memory_alu_addition), // ALU 加法結果
    .rs2_data_out(execute_to_memory_rs2_data), // rs2 的數據
    .csr_data_out(execute_to_memory_csr_data), // CSR 數據
    .branch_out(execute_to_memory_branch), // 分支信號
    .jump_out(execute_to_memory_jump), // 跳轉信號
    .cmp_output_out(execute_to_memory_cmp_output), // 比較輸出
    .load_out(execute_to_memory_load), // 加載指令信號
    .store_out(execute_to_memory_store), // 儲存指令信號
    .load_store_size_out(execute_to_memory_load_store_size), // 加載/儲存大小
    .load_signed_out(execute_to_memory_load_signed), // 是否加載有符號數據
    .bypass_memory_out(execute_to_memory_bypass_memory), // 記憶體旁路信號
    // 將寫回階段的相關信息發送到 memory 階段 (控制 WB)
    .write_select_out(execute_to_memory_write_select), // 寫入選擇信號
    .rd_address_out(execute_to_memory_rd_address), // rd 寄存器的地址
    .csr_address_out(execute_to_memory_csr_address), // CSR 寄存器的地址
    .csr_write_out(execute_to_memory_csr_write), // CSR 寫入信號
    .mret_out(execute_to_memory_mret), // mret 信號
    .wfi_out(execute_to_memory_wfi), // wfi 信號
    // 將有效性和異常信號發送到 memory 階段
    .valid_out(execute_to_memory_valid), // 指令有效性輸出
    .ecause_out(execute_to_memory_ecause), // 異常原因
    .exception_out(execute_to_memory_exception) // 異常信號
);

// 定義從 execute 階段到 memory 階段的輸出信號
wire [31:0] execute_to_memory_pc; // 當前程序計數器的值
wire [31:0] execute_to_memory_next_pc; // 下一個程序計數器的值
wire [31:0] execute_to_memory_alu_data; // ALU 計算結果
wire [31:0] execute_to_memory_alu_addition; // ALU 加法結果
wire [31:0] execute_to_memory_rs2_data; // rs2 寄存器的數據
wire [31:0] execute_to_memory_csr_data; // CSR 數據
wire execute_to_memory_branch; // 分支信號
wire execute_to_memory_jump; // 跳轉信號
wire execute_to_memory_cmp_output; // 比較輸出
wire execute_to_memory_load; // 加載指令信號
wire execute_to_memory_store; // 儲存指令信號
wire [1:0] execute_to_memory_load_store_size; // 加載/儲存大小
wire execute_to_memory_load_signed; // 是否加載有符號數據
wire execute_to_memory_bypass_memory; // 記憶體旁路信號
wire [1:0] execute_to_memory_write_select; // 寫入選擇信號
wire [4:0] execute_to_memory_rd_address; // rd 寄存器的地址
wire [11:0] execute_to_memory_csr_address; // CSR 寄存器的地址
wire execute_to_memory_csr_write; // CSR 寫入信號
wire execute_to_memory_mret; // mret 信號
wire execute_to_memory_wfi; // wfi 信號
wire execute_to_memory_valid; // 指令有效性輸出
wire [3:0] execute_to_memory_ecause; // 異常原因
wire execute_to_memory_exception; // 異常信號

// 實例化 memory 模組以處理記憶體操作
memory pipeline_memory (
    .clk(clk), // 時鐘信號

    // 從 execute 階段接收的信號
    .pc_in(execute_to_memory_pc), // 當前程序計數器輸入
    .next_pc_in(execute_to_memory_next_pc), // 下一個程序計數器輸入
    // 從 execute 階段接收的數據 (控制 MEM)
    .alu_data_in(execute_to_memory_alu_data), // ALU 計算結果
    .alu_addition_in(execute_to_memory_alu_addition), // ALU 加法結果
    .rs2_data_in(execute_to_memory_rs2_data), // rs2 的數據
    .csr_data_in(execute_to_memory_csr_data), // CSR 數據
    .branch_in(execute_to_memory_branch), // 分支信號
    .jump_in(execute_to_memory_jump), // 跳轉信號
    .cmp_output_in(execute_to_memory_cmp_output), // 比較輸出
    .load_in(execute_to_memory_load), // 加載指令信號
    .store_in(execute_to_memory_store), // 儲存指令信號
    .load_store_size_in(execute_to_memory_load_store_size), // 加載/儲存大小
    .load_signed_in(execute_to_memory_load_signed), // 是否加載有符號數據
    .bypass_memory_in(execute_to_memory_bypass_memory), // 記憶體旁路信號
    // 從 execute 階段接收的數據 (控制 WB)
    .write_select_in(execute_to_memory_write_select), // 寫入選擇信號
    .rd_address_in(execute_to_memory_rd_address), // rd 寄存器的地址
    .csr_address_in(execute_to_memory_csr_address), // CSR 寄存器的地址
    .csr_write_in(execute_to_memory_csr_write), // CSR 寫入信號
    .mret_in(execute_to_memory_mret), // mret 信號
    .wfi_in(execute_to_memory_wfi), // wfi 信號
    // 從 execute 階段接收的有效性和異常信號
    .valid_in(execute_to_memory_valid), // 指令有效性輸入
    .ecause_in(execute_to_memory_ecause), // 異常原因
    .exception_in(execute_to_memory_exception), // 異常信號
    
    // 從 hazard 模組接收的控制信號
    .stall(hazard_to_memory_stall), // 控制 memory 階段的停頓信號
    .invalidate(hazard_to_memory_invalidate), // 控制 memory 階段的無效信號

    // 從 memory 階段到 decode 階段的旁路地址和數據
    .bypass_address(memory_to_decode_bypass_address), // 旁路地址
    .bypass_data(memory_to_decode_bypass_data), // 旁路數據

    // 與記憶體 I/O 相關的信號
    .mem_address(mem_address), // 記憶體地址
    .mem_store_data(mem_store_data), // 儲存數據
    .mem_size(mem_size), // 數據大小
    .mem_signed(mem_signed), // 是否加載有符號數據
    .mem_load(mem_load), // 加載指令信號
    .mem_store(mem_store), // 儲存指令信號
    
    // 從記憶體 I/O 接收的數據
    .mem_load_data(mem_load_data), // 加載數據
    
    // 對 fetch 階段的輸出
    .branch_taken(global_branch_taken), // 分支是否被採用
    .branch_address(memory_to_fetch_branch_address), // 分支地址

    // 對 writeback 階段的輸出
    .pc_out(memory_to_writeback_pc), // 當前程序計數器輸出
    .next_pc_out(memory_to_writeback_next_pc), // 下一個程序計數器輸出
    // 對 writeback 階段的數據 (控制 WB)
    .alu_data_out(memory_to_writeback_alu_data), // ALU 計算結果
    .csr_data_out(memory_to_writeback_csr_data), // CSR 數據
    .load_data_out(memory_to_writeback_load_data), // 加載數據
    .write_select_out(memory_to_writeback_write_select), // 寫入選擇信號
    .rd_address_out(memory_to_writeback_rd_address), // rd 寄存器的地址
    .csr_address_out(memory_to_writeback_csr_address), // CSR 寄存器的地址
    .csr_write_out(memory_to_writeback_csr_write), // CSR 寫入信號
    .mret_out(memory_to_writeback_mret), // mret 信號
    .wfi_out(memory_to_writeback_wfi), // wfi 信號
    // 對 writeback 階段的有效性和異常信號
    .valid_out(memory_to_writeback_valid), // 指令有效性輸出
    .ecause_out(memory_to_writeback_ecause), // 異常原因
    .exception_out(memory_to_writeback_exception) // 異常信號
);
// 定義從 memory 階段到 writeback 階段的輸出信號
wire [31:0] memory_to_writeback_pc; // 當前程序計數器的值
wire [31:0] memory_to_writeback_next_pc; // 下一個程序計數器的值
wire [31:0] memory_to_writeback_alu_data; // ALU 計算結果
wire [31:0] memory_to_writeback_csr_data; // CSR 數據
wire [31:0] memory_to_writeback_load_data; // 加載的數據
wire [1:0] memory_to_writeback_write_select; // 寫入選擇信號
wire [4:0] memory_to_writeback_rd_address; // rd 寄存器的地址
wire [11:0] memory_to_writeback_csr_address; // CSR 寄存器的地址
wire memory_to_writeback_csr_write; // CSR 寫入信號
wire memory_to_writeback_mret; // mret 信號
wire memory_to_writeback_wfi; // wfi 信號
wire memory_to_writeback_valid; // 指令有效性輸出
wire [3:0] memory_to_writeback_ecause; // 異常原因
wire memory_to_writeback_exception; // 異常信號

// 實例化 writeback 模組以處理寫回操作
writeback pipeline_writeback (
    /* .clk(clk), */ // 時鐘信號，這裡註解掉了

    // 從 memory 階段接收的信號
    .pc_in(memory_to_writeback_pc), // 當前程序計數器輸入
    .next_pc_in(memory_to_writeback_next_pc), // 下一個程序計數器輸入
    // 從 memory 階段接收的數據 (控制 WB)
    .alu_data_in(memory_to_writeback_alu_data), // ALU 計算結果
    .csr_data_in(memory_to_writeback_csr_data), // CSR 數據
    .load_data_in(memory_to_writeback_load_data), // 加載數據
    .write_select_in(memory_to_writeback_write_select), // 寫入選擇信號
    .rd_address_in(memory_to_writeback_rd_address), // rd 寄存器的地址
    .csr_address_in(memory_to_writeback_csr_address), // CSR 寄存器的地址
    .csr_write_in(memory_to_writeback_csr_write), // CSR 寫入信號
    .mret_in(memory_to_writeback_mret), // mret 信號
    .wfi_in(memory_to_writeback_wfi), // wfi 信號
    // 從 memory 階段接收的有效性和異常信號
    .valid_in(memory_to_writeback_valid), // 指令有效性輸入
    .ecause_in(memory_to_writeback_ecause), // 異常原因
    .exception_in(memory_to_writeback_exception), // 異常信號

    // 從 csr 模組接收的信號
    .sip(csr_to_writeback_sip), // 監控中斷的狀態信號
    .tip(csr_to_writeback_tip), // 計時器中斷的狀態信號
    .eip(csr_to_writeback_eip), // 外部中斷的狀態信號

    // 對 regfile 的輸出
    .rd_address(writeback_to_regfile_rd_address), // rd 寄存器的地址
    .rd_data(writeback_to_regfile_rd_data), // 寫回的數據

    // 對 csr 的輸出
    .csr_write(writeback_to_csr_write_enable), // CSR 寫入使能信號
    .csr_address(writeback_to_csr_write_address), // CSR 寄存器的地址
    .csr_data(writeback_to_csr_write_data), // 寫回的 CSR 數據

    // 對 fetch、csr 和 hazard 模組的輸出
    .traped(global_traped), // 記錄 trap 信號
    .mret(global_mret), // mret 信號
    // 對 hazard 模組的輸出
    .wfi(global_wfi), // wfi 信號

    // 對 csr 的輸出
    .retired(writeback_to_csr_retired), // 退役指令計數
    .ecp(writeback_to_csr_ecp), // 異常計數
    .ecause(writeback_to_csr_trap_cause), // trap 原因
    .interupt(writeback_to_csr_interupt) // 中斷信號
);

// 結束模組
endmodule
