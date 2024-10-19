`timescale 1ns/10ps // 定義時間單位和精度
`define CYCLE 10.0 // 定義時鐘周期為 10.0 ns
`define MAX 100000 // 定義最大循環數
// 定義一個宏，用於讀取數據記憶體中的一個字（由四個字節組成）
`define mem_word(addr) \
  {TOP.i_DM.Memory_byte3[addr], \
   TOP.i_DM.Memory_byte2[addr], \
   TOP.i_DM.Memory_byte1[addr], \
   TOP.i_DM.Memory_byte0[addr]}
// 定義一個宏，用於讀取寄存器文件中的一個字
`define reg_word(addr) TOP.i_CPU.i_RF.Reg_Data[addr]
// 定義模擬結束的標誌和結束代碼
`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1
`define TEST_START 'h2000 // 定義測試開始的地址

module top_tb; // 測試基準模組

// 定義內部信號
reg        clk; // 時鐘信號
reg        rst; // 重置信號
reg [31:0] GOLDEN [0:65535]; // 定義一個數組，用來存儲金標準數據
integer gf, // 金標準文件句柄
        i, // 循環索引
        num, // 金標準數據的計數
        err, // 錯誤計數
        tmp; // 暫存變數

// 時鐘信號生成
always #(`CYCLE/2) clk = ~clk;

// 實例化頂層模組
top TOP(
  .clk(clk), // 將時鐘信號連接到頂層模組
  .rst(rst)  // 將重置信號連接到頂層模組
);

// 初始化區域
initial begin
    clk = 0; rst = 1; // 初始化時鐘為 0，重置為高
    #(`CYCLE) rst = 0; // 在一個時鐘周期後釋放重置信號
    // 從 HEX 文件中加載指令和數據到 SRAM
    $readmemh("./main0.hex", TOP.i_IM.Memory_byte0);
    $readmemh("./main0.hex", TOP.i_DM.Memory_byte0); 
    $readmemh("./main1.hex", TOP.i_IM.Memory_byte1);
    $readmemh("./main1.hex", TOP.i_DM.Memory_byte1); 
    $readmemh("./main2.hex", TOP.i_IM.Memory_byte2);
    $readmemh("./main2.hex", TOP.i_DM.Memory_byte2); 
    $readmemh("./main3.hex", TOP.i_IM.Memory_byte3);
    $readmemh("./main3.hex", TOP.i_DM.Memory_byte3); 

    // 讀取金標準數據文件
    num = 0; // 初始化數據計數
    gf = $fopen("./golden.hex", "r"); // 打開金標準文件
    while (!$feof(gf)) // 當未到達文件結尾
    begin
      tmp = $fscanf(gf, "%h\n", GOLDEN[num]); // 讀取十六進制數據
      num = num + 1; // 更新數據計數
    end
    $fclose(gf); // 關閉文件
  
    err = 0; // 初始化錯誤計數
    repeat(`MAX) @(negedge clk) // 在時鐘的下降沿重複進行測試
        if (`mem_word(`SIM_END) === `SIM_END_CODE) begin // 檢查是否達到模擬結束標誌
            $display("\nDone\n"); // 輸出結束信息
            for (i = 0; i < num; i = i + 1) begin // 遍歷金標準數據
                if (`mem_word(`TEST_START + i) !== GOLDEN[i]) begin // 檢查數據是否與金標準匹配
                    $display("DM[%4d] = %h, expect = %h", i+`TEST_START, `mem_word(`TEST_START + i), GOLDEN[i]); // 輸出不匹配的數據
                    err = err + 1; // 更新錯誤計數
                end
                else begin
                    $display("DM[%4d] = %h, pass", i+`TEST_START, `mem_word(`TEST_START + i)); // 輸出通過信息
                end
            end
            result(err); // 調用結果輸出任務
            $finish; // 結束模擬
        end

    @(negedge clk) // 在時鐘的下降沿
    for (i = 0; i < num; i = i + 1) begin // 檢查數據是否與金標準匹配
        if (`mem_word(`TEST_START+i) !== GOLDEN[i]) begin
            $display("DM[%4d] = %h, expect = %h", `TEST_START+i, `mem_word(`TEST_START + i), GOLDEN[i]); // 輸出不匹配的數據
            err = err + 1; // 更新錯誤計數
        end
        else begin
            $display("DM[%4d] = %h, pass", `TEST_START+i, `mem_word(`TEST_START + i)); // 輸出通過信息
        end
    end
    $display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `mem_word(`SIM_END), `SIM_END_CODE); // 輸出模擬結束的結果
    result(err); // 調用結果輸出任務
    $finish; // 結束模擬
end

`ifdef SYN
initial $sdf_annotate("top_syn.sdf", TOP); // 如果在合成模式下，添加 SDF 文件的註釋
`endif

initial
begin
  `ifdef FSDB
  $fsdbDumpfile("top.fsdb"); // 如果在 FSDB 模式下，設置 FSDB 波形文件
  $fsdbDumpvars(0, TOP); // 記錄變量
  `elsif FSDB_ALL
  $fsdbDumpfile("top.fsdb"); // 設置 FSDB 波形文件
  $fsdbDumpvars("+struct", "+mda", TOP); // 記錄變量，包括結構和 MDA
  `endif
end

// 輸出結果的任務
task result;
    input integer err; // 輸入錯誤數
    begin
        if (err === 0) begin // 如果錯誤數為 0
            $display("\n");
            $display("\n");
            $display("        ****************************               ");
            $display("        **                        **       |\__||  ");
            $display("        **  Congratulations !!    **      / O.O  | ");
            $display("        **                        **    /_____   | ");
            $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
            $display("        **                        **  |^ ^ ^ ^ |w| ");
            $display("        ****************************   \\m___m__|_|");
            $display("\n");
        end
        else begin // 如果有錯誤
            $display("\n");
            $display("\n");
            $display("        ****************************               ");
            $display("        **                        **       |\__||  ");
            $display("        **  OOPS!!                **      / X,X  | ");
            $display("        **                        **    /_____   | ");
            $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
            $display("        **                        **  |^ ^ ^ ^ |w| ");
            $display("        ****************************   \\m___m__|_|");
            $display("         Totally has %d errors                     ", err); // 輸出總錯誤數
            $display("\n");
        end
    end
endtask

endmodule // 測試基準模組結束
