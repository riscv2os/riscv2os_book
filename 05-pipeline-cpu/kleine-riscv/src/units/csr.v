module csr (
    input clk,       // 時鐘信號
    input reset,     // 重置信號

    // 來自中斷控制器
    input meip,      // 機模式外部中斷請求 (Machine External Interrupt Pending)

    // 來自指令解碼 (讀取端口)
    input [11:0] read_address,   // CSR 讀取位址
    // 回傳給指令解碼 (讀取端口)
    output reg [31:0] read_data,  // CSR 讀取數據
    output reg readable,          // 是否可讀
    output reg writeable,         // 是否可寫

    // 來自回寫階段 (寫入端口)
    input write_enable,           // CSR 寫入使能信號
    input [11:0] write_address,   // CSR 寫入位址
    input [31:0] write_data,      // CSR 寫入數據
    
    // 來自回寫階段的其他信號
    input retired,        // 指令執行完成信號
    input traped,         // 中斷或異常發生信號
    input mret,           // mret 指令信號 (返回機模式)
    input [31:0] ecp,     // 異常程序計數器
    input [3:0] trap_cause, // 異常或中斷原因
    input interupt,       // 是否發生中斷

    // 給回寫階段
    output eip,           // 機模式外部中斷指示
    output tip,           // 機模式定時中斷指示
    output sip,           // 機模式軟體中斷指示

    // 給取指階段
    output [31:0] trap_vector,  // 異常向量地址
    output [31:0] mret_vector   // mret 指令返回地址
);

// 64位元週期計數器
reg [63:0] cycle = 0;
// 64位元已執行指令計數
reg [63:0] instret = 0;

// 中斷與狀態寄存器
reg pie = 0;  // 機模式先前中斷使能標誌
reg ie = 0;   // 機模式中斷使能標誌
reg meie;     // 外部中斷使能標誌
reg msie;     // 軟體中斷使能標誌
reg msip;     // 軟體中斷等待標誌
reg mtie;     // 定時中斷使能標誌
reg mtip;     // 定時中斷等待標誌
reg [31:0] mtvec;    // 異常處理向量地址寄存器
reg [31:0] mscratch; // 暫存寄存器
reg [31:0] mecp;     // 機模式異常程序計數器
reg [3:0] mcause = 0;  // 異常或中斷原因
reg minterupt = 0;     // 中斷標誌

// 自定義的 CSR 寄存器
reg [63:0] mtimecmp;  // 定時比較器

// 生成中斷指示信號
assign eip = ie && meie && meip;   // 外部中斷指示
assign tip = ie && mtie && mtip;   // 定時中斷指示
assign sip = ie && msie && msip;   // 軟體中斷指示

// 異常向量地址和 mret 返回地址
assign trap_vector = mtvec;       // 異常向量地址 (mtvec)
assign mret_vector = mecp;        // mret 返回地址 (mepc)

always @(*) begin
    casez (read_address) // 根據讀取地址選擇對應的 CSR
        12'hc00, 12'hc01: begin // cycle, time
            read_data = cycle[31:0]; // 讀取 cycle 的低32位
            readable = 1; // 設定可讀標記
            writeable = 0; // 設定不可寫標記
        end
        12'hc02: begin // instret
            read_data = instret[31:0]; // 讀取 instret 的低32位
            readable = 1; 
            writeable = 0; 
        end
        12'hc80, 12'hc81: begin // cycleh, timeh
            read_data = cycle[63:32]; // 讀取 cycle 的高32位
            readable = 1; 
            writeable = 0; 
        end
        12'hc82: begin // instreth
            read_data = instret[63:32]; // 讀取 instret 的高32位
            readable = 1; 
            writeable = 0; 
        end
        12'hc03, 12'hc04, 12'hc05, 12'hc06, 12'hc07, 12'hc08, 12'hc09, 
        12'hc0a, 12'hc0b, 12'hc0c, 12'hc0d, 12'hc0e, 12'hc0f, 12'hc1?,
        12'hc83, 12'hc84, 12'hc85, 12'hc86, 12'hc87, 12'hc88, 
        12'hc89, 12'hc8a, 12'hc8b, 12'hc8c, 12'hc8d, 12'hc8e, 
        12'hc8f: begin // hpmcounterX, hpmcounterXh
            read_data = 0; // 這些 CSR 返回 0
            readable = 1; // 設定可讀標記
            writeable = 0; // 設定不可寫標記
        end
        12'hf11, 12'hf12, 12'hf13, 12'hf14: begin // mvendorid, marchid, mimpid, mhartid
            read_data = 0; // 這些 CSR 返回 0
            readable = 1; 
            writeable = 0; 
        end
        12'h300: begin // mstatus
            // mstatus 的位元設置，包含多個標誌位
            read_data = {1'b0, 8'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
                          2'b0, 2'b0, 2'b0, 2'b0, 1'b0, pie, 1'b0, 
                          1'b0, 1'b0, ie, 1'b0, 1'b0, 1'b0}; // 設定 mstatus 的各個位元
            readable = 1; // 可讀
            writeable = 1; // 可寫
        end
        12'h301: begin // misa
            // MISA 的位元設置，表示支持的特性
            read_data = {2'b1, 4'b0, 26'b00000000000000000100000000}; // 設定 MISA 的位元
            readable = 1; 
            writeable = 1; 
        end
        12'h344: begin // mip
            // 中斷請求的位元設置
            read_data = {20'b0, meip, 1'b0, 1'b0, 1'b0, mtip, 1'b0, 
                          1'b0, 1'b0, msip, 1'b0, 1'b0, 1'b0}; // 返回中斷請求狀態
            readable = 1; 
            writeable = 1; 
        end
        12'h304: begin // mie
            // 中斷使能的位元設置
            read_data = {20'b0, meie, 1'b0, 1'b0, 1'b0, mtie, 1'b0, 
                          1'b0, 1'b0, msie, 1'b0, 1'b0, 1'b0}; // 返回中斷使能設置
            readable = 1; 
            writeable = 1; 
        end
        12'h305: begin // mtvec
            read_data = {mtvec[31:2], 2'b00}; // 返回 mtvec，低兩位設為 0
            readable = 1; 
            writeable = 1; 
        end
        12'h340: begin // mscratch
            read_data = mscratch; // 返回 mscratch 的內容
            readable = 1; 
            writeable = 1; 
        end
        12'h341: begin // mepc
            read_data = mecp; // 返回 mepc 的內容
            readable = 1; 
            writeable = 1; 
        end
        12'h342: begin // mcause
            read_data = {minterupt, 27'b0, mcause}; // 返回中斷原因及標誌
            readable = 1; 
            writeable = 1; 
        end
        12'h343: begin // mtval
            read_data = 0; // mtval 返回 0
            readable = 1; 
            writeable = 1; 
        end
        12'hb00, 12'hb01: begin // mcycle, mtime
            read_data = cycle[31:0]; // 讀取 mcycle 或 mtime 的低32位
            readable = 1; 
            writeable = 1; 
        end
        12'hb02: begin // minstret
            read_data = instret[31:0]; // 讀取 minstret 的低32位
            readable = 1; 
            writeable = 1; 
        end
        12'hb80, 12'hb81: begin // mcycleh, mtimeh
            read_data = cycle[63:32]; // 讀取 mcycle 或 mtime 的高32位
            readable = 1; 
            writeable = 1; 
        end
        12'hb82: begin // minstreth
            read_data = instret[63:32]; // 讀取 minstret 的高32位
            readable = 1; 
            writeable = 1; 
        end
        12'hb03, 12'hb04, 12'hb05, 12'hb06, 12'hb07, 12'hb08, 
        12'hb09, 12'hb0a, 12'hb0b, 12'hb0c, 12'hb0d, 12'hb0e, 
        12'hb0f, 12'hb1?, 12'hb83, 12'hb84, 12'hb85, 12'hb86, 
        12'hb87, 12'hb88, 12'hb89, 12'hb8a, 12'hb8b, 12'hb8c, 
        12'hb8d, 12'hb8e, 12'hb8f, 12'hb9?: begin // mhpmcounterX, mhpmcounterXh
            read_data = 0; // 這些 CSR 返回 0
            readable = 1; 
            writeable = 1; 
        end
        12'h32?, 12'h33?: begin // mhpmeventX
            read_data = 0; // 這些 CSR 返回 0
            readable = 1; 
            writeable = 1; 
        end
        // Custom CSRs
        12'hbc0: begin // mtimecmp - 此 CSR 不依據 RISC-V 規範進行內存映射
            read_data = mtimecmp[31:0]; // 返回 mtimecmp 的低32位
            readable = 1; 
            writeable = 1; 
        end
        12'hbc1: begin // mtimecmph
            read_data = mtimecmp[63:32]; // 返回 mtimecmp 的高32位
            readable = 1; 
            writeable = 1; 
        end
        default: begin
            read_data = 0; // 默認返回 0
            readable = 0; // 設定不可讀標記
            writeable = 0; // 設定不可寫標記
        end
    endcase
end
always @(posedge clk) begin // 當時鐘上升沿觸發時執行
    if (traped) begin // 如果發生陷阱
        pie <= ie; // 將中斷使能狀態保存到 pie
        ie <= 0; // 禁用中斷
        mecp <= ecp; // 保存當前程序計數器的值
        minterupt <= interupt; // 保存中斷狀態
        mcause <= trap_cause; // 保存陷阱原因
    end else if (mret) begin // 如果發生返回指令（mret）
        ie <= pie; // 恢復中斷使能狀態
        pie <= 1; // 設置 pie 為 1，允許中斷
    end
    
    cycle <= cycle + 1; // 更新 cycle 計數器
    
    if (retired) begin // 如果指令執行完畢
        instret <= instret + 1; // 更新已執行指令計數器
    end
    
    if (write_enable) begin // 如果有寫入操作
        casez (write_address) // 根據寫入地址進行不同的處理
            12'h300: begin // mstatus
                ie <= write_data[3]; // 更新中斷使能狀態
                pie <= write_data[7]; // 更新先前中斷使能狀態
            end
            12'h344: begin // mip
                msip <= write_data[3]; // 更新 msip 狀態
            end
            12'h304: begin // mie
                msie <= write_data[3]; // 更新 msie 狀態
                mtie <= write_data[7]; // 更新 mtie 狀態
                meie <= write_data[11]; // 更新 meie 狀態
            end
            12'h305: begin // mtvec
                mtvec <= {write_data[31:2], 2'b00}; // 更新 mtvec，低兩位設為 0
            end
            12'h340: begin // mscratch
                mscratch <= write_data; // 更新 mscratch 的值
            end
            12'h341: begin // mepc
                mecp <= write_data; // 更新 mepc 的值
            end
            12'h342: begin // mcause
                minterupt <= write_data[31]; // 更新中斷狀態
                mcause <= write_data[3:0]; // 更新中斷原因
            end
            12'hb00, 12'hb01: begin // mcycle, mtime
                cycle[31:0] <= write_data; // 更新 cycle 或 mtime 的低32位
            end
            12'hb02: begin // minstret
                instret[31:0] <= write_data; // 更新 minstret 的低32位
            end
            12'hb80, 12'hb81: begin // mcycleh, mtimeh
                cycle[63:32] <= write_data; // 更新 cycle 或 mtime 的高32位
            end
            12'hb82: begin // minstreth
                instret[63:32] <= write_data; // 更新 minstret 的高32位
            end
            // Custom CSRs
            12'hbc0: begin // mtimecmp - 此 CSR 不依據 RISC-V 規範進行內存映射
                mtimecmp[31:0] <= write_data; // 更新 mtimecmp 的低32位
            end
            12'hbc1: begin // mtimecmph
                mtimecmp[63:32] <= write_data; // 更新 mtimecmp 的高32位
            end
            default: begin
                // 對於未定義的地址不執行任何操作
            end
        endcase
    end
    
    if (reset) begin // 如果重置信號有效
        ie <= 0; // 重置中斷使能狀態
        pie <= 0; // 重置先前中斷使能狀態
        mcause <= 0; // 重置中斷原因
        minterupt <= 0; // 重置中斷狀態
        cycle <= 0; // 重置 cycle 計數器
        instret <= 0; // 重置已執行指令計數器
    end
    
    mtip <= cycle >= mtimecmp; // 設置中斷請求標記，如果 cycle 超過 mtimecmp
end

endmodule
