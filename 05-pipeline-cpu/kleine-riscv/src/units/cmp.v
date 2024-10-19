module cmp (
    input clk,  // 時鐘信號

    input [31:0] input_a,  // 比較的第一個輸入值
    input [31:0] input_b,  // 比較的第二個輸入值

    input [2:0] function_select,  // 功能選擇信號，用來選擇比較類型

    output result  // 比較結果輸出
);

reg quasi_result;  // 暫存的比較結果
reg negate;  // 是否取反

// 擷取功能選擇信號的位元，判斷是否為無符號比較
wire usign = function_select[1];
// 擷取功能選擇信號的位元，判斷是小於比較還是等於比較
wire less = function_select[2];

// 判斷兩個輸入是否相等
wire is_equal = (input_a == input_b);
// 判斷 input_a 是否小於 input_b，根據是否為無符號比較來決定使用無符號或有符號的比較
wire is_less = ($signed({usign ? 1'b0 : input_a[31], input_a}) < $signed({usign ? 1'b0 : input_b[31], input_b}));

// 每個時鐘周期，更新比較結果和是否取反的標誌
always @(posedge clk) begin
    negate <= function_select[0];  // 取反標誌由 function_select[0] 控制
    quasi_result <= less ? is_less : is_equal;  // 根據功能選擇，決定是進行小於比較還是等於比較
end

// 根據取反標誌，決定最終輸出的比較結果
assign result = negate ? !quasi_result : quasi_result;

endmodule
