module fetch #(
    parameter RESET_VECTOR = 32'h8000_0000 // 定義重置向量的參數，表示系統重啟時的初始程序計數器值
) (
    input clk, // 時鐘信號
    input reset, // 重置信號

    // from memory (來自記憶體的輸入)
    input branch, // 分支信號
    input [31:0] branch_vector, // 分支向量，分支目標地址
    
    // from writeback (來自回寫階段的輸入)
    input trap, // 陷阱信號
    input mret, // mret 信號，表示返回到前一狀態

    // from csr (來自控制和狀態寄存器的輸入)
    input [31:0] trap_vector, // 陷阱向量，陷阱目標地址
    input [31:0] mret_vector, // mret 向量，返回目標地址

    // from hazard (來自冒險檢測的輸入)
    input stall, // 停頓信號
    input invalidate, // 無效信號
    
    // to busio (輸出到總線 I/O)
    output [31:0] fetch_address, // 獲取的地址
    // from busio (來自總線 I/O的輸入)
    input [31:0] fetch_data, // 獲取的數據

    // to decode (輸出到解碼階段)
    output reg [31:0] pc_out, // 當前程序計數器值
    output reg [31:0] next_pc_out, // 下一個程序計數器值
    output reg [31:0] instruction_out, // 獲取的指令
    output reg valid_out // 指令有效信號
);

// 初始程序計數器設定為重置向量
reg [31:0] pc = RESET_VECTOR;

// 將當前程序計數器值分配給 fetch_address
assign fetch_address = pc;

// 計算下一個程序計數器值
wire [31:0] next_pc = pc + 4;

// 在時鐘上升沿更新程序計數器
always @(posedge clk) begin
    if (reset) begin
        // 如果重置信號為真，將 pc 重置為重置向量
        pc <= RESET_VECTOR;
    end else if (trap) begin
        // 如果發生陷阱，將 pc 設置為陷阱向量
        pc <= trap_vector;
    end else if (mret) begin
        // 如果發生 mret，將 pc 設置為 mret 向量
        pc <= mret_vector;
    end else if (branch) begin
        // 如果發生分支，將 pc 設置為分支向量
        pc <= branch_vector;
    end else begin
        // 如果未發生停頓或無效，更新 pc 為下一個程序計數器值
        pc <= (stall || invalidate) ? pc : next_pc;
    end
end

// 在時鐘上升沿更新輸出信號
always @(posedge clk) begin
    // 根據停頓和無效信號更新有效信號
    valid_out <= (stall ? valid_out : 1) && !invalidate;
    
    if (!stall) begin
        // 如果未發生停頓，更新 pc_out、next_pc_out 和 instruction_out
        pc_out <= pc; // 更新當前 pc
        next_pc_out <= next_pc; // 更新下一個 pc
        instruction_out <= fetch_data; // 更新指令數據
    end
end

endmodule
