`timescale 1ns / 1ps

module testbench;
    reg a;            // 測試信號 a
    reg b;            // 測試信號 b
    wire y;          // 輸出信號 y

    // 實例化 AND gate
    and_gate uut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        // 模擬不同的輸入情況
        $monitor("Time: %0t | a: %b, b: %b, y: %b", $time, a, b, y);
        
        a = 0; b = 0; #10; // 輸入 0 和 0
        a = 0; b = 1; #10; // 輸入 0 和 1
        a = 1; b = 0; #10; // 輸入 1 和 0
        a = 1; b = 1; #10; // 輸入 1 和 1
        
        $finish; // 結束模擬
    end
endmodule
