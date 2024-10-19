module alu (
    input clk,  // 時鐘信號輸入

    input [31:0] input_a,  // 操作數A輸入
    input [31:0] input_b,  // 操作數B輸入

    input [2:0] function_select,  // 功能選擇（操作類型）
    input function_modifier,      // 功能修飾符（例如加法或減法、邏輯反轉等）

    // 第一個時鐘週期的輸出
    output [31:0] add_result,  // 加法/減法結果
    // 第二個時鐘週期的輸出
    output reg [31:0] result    // ALU 操作結果
);

localparam ALU_ADD_SUB = 3'b000;  // 加法/減法
localparam ALU_SLL     = 3'b001;  // 邏輯左移
localparam ALU_SLT     = 3'b010;  // 有符號比較，小於（SLT）
localparam ALU_SLTU    = 3'b011;  // 無符號比較，小於（SLTU）
localparam ALU_XOR     = 3'b100;  // XOR 邏輯運算
localparam ALU_SRL_SRA = 3'b101;  // 邏輯右移或算術右移
localparam ALU_OR      = 3'b110;  // OR 邏輯運算
localparam ALU_AND_CLR = 3'b111;  // AND 邏輯運算或清除

/* verilator lint_off UNUSED */ // 第 32 位有意忽略，不觸發 linter 警告
// 根據功能修飾符進行有符號算術右移（SRL/SRA）
wire [32:0] tmp_shifted = $signed({function_modifier ? input_a[31] : 1'b0, input_a}) >>> input_b[4:0];
/* verilator lint_on UNUSED */

assign add_result = result_add_sub;  // 將加法或減法結果賦值給 add_result

// 定義各種運算的暫存器
reg [31:0] result_add_sub;  // 加法/減法結果
reg [31:0] result_sll;      // 邏輯左移結果
reg [31:0] result_slt;      // 小於比較結果
reg [31:0] result_xor;      // XOR 結果
reg [31:0] result_srl_sra;  // 右移結果
reg [31:0] result_or;       // OR 結果
reg [31:0] result_and_clr;  // AND 或清除結果

reg [2:0] old_function;  // 保存上一次的操作選擇

// 每當時鐘上升沿觸發時執行
always @(posedge clk) begin
    old_function <= function_select;  // 記錄當前的功能選擇
    result_add_sub <= input_a + (function_modifier ? -input_b : input_b);  // 根據修飾符選擇加法或減法
    result_sll <= input_a << input_b[4:0];  // 邏輯左移，移位量取 B 的低 5 位
    result_slt <= {31'b0, ($signed({function_select[0] ? 1'b0 : input_a[31], input_a}) < 
                          $signed({function_select[0] ? 1'b0 : input_b[31], input_b}))};  // 比較 A 和 B，得出 SLT 或 SLTU 結果
    result_xor <= input_a ^ input_b;  // XOR 運算
    result_srl_sra <= tmp_shifted[31:0];  // 右移結果（算術右移或邏輯右移）
    result_or <= input_a | input_b;   // OR 運算
    result_and_clr <= (function_modifier ? ~input_a : input_a) & input_b;  // AND 或清除（根據修飾符決定是否取反）
end

// 根據上一次選擇的功能，選擇最終的運算結果
always @(*) begin
    case (old_function)
        ALU_ADD_SUB: result = result_add_sub;   // 加法或減法
        ALU_SLL:     result = result_sll;       // 左移
        ALU_SLT,
        ALU_SLTU:    result = result_slt;       // 小於比較（有符號或無符號）
        ALU_XOR:     result = result_xor;       // XOR
        ALU_SRL_SRA: result = result_srl_sra;   // 右移
        ALU_OR:      result = result_or;        // OR
        ALU_AND_CLR: result = result_and_clr;   // AND 或清除
    endcase
end

endmodule
