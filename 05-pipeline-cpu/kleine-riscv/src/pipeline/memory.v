module memory (
    input clk, // 時鐘信號
    // 來自 execute 模組的輸入
    input [31:0] pc_in, // 當前指令的程式計數器
    input [31:0] next_pc_in, // 下一個指令的程式計數器
    // 來自 execute 的資料
    input [31:0] alu_data_in, // ALU 輸出數據
    input [31:0] alu_addition_in, // ALU 的加法結果
    input [31:0] rs2_data_in, // rs2 的數據
    input [31:0] csr_data_in, // CSR 數據
    input branch_in, // 分支信號
    input jump_in, // 跳轉信號
    input cmp_output_in, // 比較結果輸入
    input load_in, // 加載信號
    input store_in, // 儲存信號
    input [1:0] load_store_size_in, // 加載/儲存大小
    input load_signed_in, // 是否為有符號加載
    input bypass_memory_in, // 繞過記憶體信號
    // 來自 execute 的寫回控制信號
    input [1:0] write_select_in, // 寫回選擇
    input [4:0] rd_address_in, // 寫回的寄存器地址
    input [11:0] csr_address_in, // CSR 地址
    input csr_write_in, // CSR 寫入信號
    input mret_in, // 中斷返回信號
    input wfi_in, // 等待中斷信號
    // 來自 execute 的有效性信號
    input valid_in, // 輸入有效信號
    input [3:0] ecause_in, // 異常原因
    input exception_in, // 異常信號
    
    // 來自 hazard 控制的信號
    input stall, // 停頓信號
    input invalidate, // 使無效信號

    // 發送到 decode
    output [4:0] bypass_address, // 繞過地址輸出
    output [31:0] bypass_data, // 繞過數據輸出

    // 發送到 busio
    output [31:0] mem_address, // 記憶體地址輸出
    output [31:0] mem_store_data, // 儲存數據輸出
    output [1:0] mem_size, // 記憶體大小輸出
    output mem_signed, // 是否為有符號輸出
    output mem_load, // 加載信號輸出
    output mem_store, // 儲存信號輸出
    
    // 從 busio 接收的數據
    input [31:0] mem_load_data, // 加載數據輸入
    
    // 發送到 fetch
    output branch_taken, // 分支是否被採納輸出
    output [31:0] branch_address, // 分支地址輸出

    // 發送到 writeback
    output reg [31:0] pc_out, // 輸出程式計數器
    output reg [31:0] next_pc_out, // 輸出下一個程式計數器
    // 發送到 writeback 的控制信號
    output reg [31:0] alu_data_out, // ALU 數據輸出
    output reg [31:0] csr_data_out, // CSR 數據輸出
    output reg [31:0] load_data_out, // 載入數據輸出
    output reg [1:0] write_select_out, // 寫回選擇輸出
    output reg [4:0] rd_address_out, // 寫回寄存器地址輸出
    output reg [11:0] csr_address_out, // CSR 地址輸出
    output reg csr_write_out, // CSR 寫入輸出
    output reg mret_out, // 中斷返回輸出
    output reg wfi_out, // 等待中斷輸出
    // 發送到 writeback 的有效信號
    output reg valid_out, // 輸出有效信號
    output reg [3:0] ecause_out, // 輸出異常原因
    output reg exception_out // 輸出異常信號
);

// 判斷是否可執行的信號
wire to_execute = !exception_in && valid_in;

// 設定繞過地址和數據
assign bypass_address = (valid_in && bypass_memory_in) ? rd_address_in : 5'h0; // 繞過地址的選擇
assign bypass_data = write_select_in[0] ? csr_data_in : alu_data_in; // 繞過數據的選擇

// 判斷有效的分支地址
wire valid_branch_address = (alu_addition_in[1:0] == 0);
reg valid_mem_address; // 內部標誌，判斷記憶體地址是否有效

// 根據加載/儲存大小判斷記憶體地址的有效性
always @(*) begin
    case (load_store_size_in)
        2'b00: valid_mem_address = 1; // 32-bit 存取有效
        2'b01: valid_mem_address = (alu_addition_in[0] == 0); // 16-bit 存取有效性
        2'b10: valid_mem_address = (alu_addition_in[1:0] == 0); // 8-bit 存取有效性
        2'b11: valid_mem_address = 0; // 不有效
    endcase
end

// 判斷是否應該進行分支
wire should_branch = branch_in && (jump_in || cmp_output_in); // 根據分支和比較結果判斷
assign branch_taken = valid_in && valid_branch_address && should_branch; // 判斷分支是否被採納
assign branch_address = alu_addition_in; // 設置分支地址

// 記憶體操作信號的設置
assign mem_load = to_execute && valid_mem_address && load_in; // 加載信號
assign mem_store = to_execute && valid_mem_address && store_in; // 儲存信號
assign mem_size = load_store_size_in; // 記憶體大小
assign mem_signed = load_signed_in; // 是否為有符號
assign mem_address = alu_addition_in; // 記憶體地址
assign mem_store_data = rs2_data_in; // 儲存的數據

// 在時鐘上升沿更新輸出
always @(posedge clk) begin
    // 根據 stall 和 invalidate 更新有效信號
    valid_out <= (stall ? valid_out : valid_in) && !invalidate;
    if (!stall) begin // 當不在 stall 狀態時
        pc_out <= pc_in; // 更新程式計數器
        next_pc_out <= next_pc_in; // 更新下一個程式計數器
        alu_data_out <= alu_data_in; // 更新 ALU 數據
        csr_data_out <= csr_data_in; // 更新 CSR 數據
        load_data_out <= mem_load_data; // 更新載入數據
        write_select_out <= write_select_in; // 更新寫回選擇
        rd_address_out <= rd_address_in; // 更新寫回寄存器地址
        csr_address_out <= csr_address_in; // 更新 CSR 地址
        csr_write_out <= csr_write_in; // 更新 CSR 寫入信號
        mret_out <= mret_in; // 更新中斷返回信號
        wfi_out <= wfi_in; // 更新等待中斷信號
        // 處理異常情況
        if (!exception_in && should_branch && !valid_branch_address) begin
            ecause_out <= 0; // 設置異常原因
            exception_out <= 1; // 標記發生異常
        end else if (!exception_in && (load_in || store_in) && !valid_mem_address) begin
            ecause_out <= load_in ? 4'h4 : 4'h6; // 根據操作設置異常原因
            exception_out <= 1; // 標記發生異常
        end else begin
            ecause_out <= ecause_in; // 更新異常原因
            exception_out <= exception_in; // 更新異常信號
        end
    end
end

endmodule
