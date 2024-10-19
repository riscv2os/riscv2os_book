// Please DO NOT modify this file !!!

module SRAM(
    clk,                         // 時鐘信號
    rst,                         // 重置信號
    addr,                        // 存取地址
    read,                        // 讀取使能信號
    write,                       // 寫入使能信號
    DI,                          // 輸入資料
    DO                           // 輸出資料
);

// 設定參數
parameter BYTES_SIZE     = 8;                // 每個字節的大小
parameter BYTES_CNT      = 4;                // 字節數量
parameter WORD_SIZE      = BYTES_SIZE * BYTES_CNT; // 每個字的大小（32位元）
parameter WORD_ADDR_BITS = 14;               // 字的地址位元數
parameter WORD_CNT       = 1 << WORD_ADDR_BITS; // 總字數量 (2^14)

input                       clk;               // 時鐘輸入
input                       rst;               // 重置輸入
input  [WORD_ADDR_BITS-1:0] addr;              // 地址輸入
input                       read;              // 讀取信號輸入
input  [3:0]                write;             // 寫入信號輸入（4位元）
input  [     WORD_SIZE-1:0] DI;               // 輸入資料
output reg [     WORD_SIZE-1:0] DO;           // 輸出資料

// 定義四個字節的記憶體，分別對應到 32 位元中的每個字節
reg [BYTES_SIZE-1:0] Memory_byte3 [0:WORD_CNT-1]; // 第 3 個字節
reg [BYTES_SIZE-1:0] Memory_byte2 [0:WORD_CNT-1]; // 第 2 個字節
reg [BYTES_SIZE-1:0] Memory_byte1 [0:WORD_CNT-1]; // 第 1 個字節
reg [BYTES_SIZE-1:0] Memory_byte0 [0:WORD_CNT-1]; // 第 0 個字節

// 將四個字節的資料合併為一個 32 位元的輸出
wire [     WORD_SIZE-1:0] tmp_DO; // 暫存的輸出資料
assign tmp_DO = {  Memory_byte3[addr], // 合併四個字節
                   Memory_byte2[addr],
                   Memory_byte1[addr],
                   Memory_byte0[addr] };

// 讀取操作的邏輯
always @(posedge clk) begin
    DO <= (read) ? tmp_DO : 32'bz; // 如果讀取使能，則輸出資料，否則高阻態
	//$display("%d %d %d", read, tmp_DO, addr); // 顯示當前讀取狀態（此行為註解，實際運行時可選擇啟用）
end

// 寫入操作的邏輯
always @(posedge clk) begin
    if (write[3])                   // 如果寫入信號第 3 位有效
        Memory_byte3[addr] <= DI[31:24]; // 寫入高字節
    if (write[2])                   // 如果寫入信號第 2 位有效
        Memory_byte2[addr] <= DI[23:16]; // 寫入次高字節
    if(write[1])                    // 如果寫入信號第 1 位有效
        Memory_byte1[addr] <= DI[15: 8]; // 寫入次低字節
    if(write[0])                    // 如果寫入信號第 0 位有效
        Memory_byte0[addr] <= DI[ 7: 0]; // 寫入低字節
	//if(write[3] || write[2] || write[1] || write[0]) // 如果任何寫入信號有效
		//$display("!!!!!%h %d", {DI[31:24], DI[23:16], DI[15:8], DI[7:0]}, addr); // 顯示寫入資料（此行為註解，實際運行時可選擇啟用）
end

endmodule
