module core #(
    parameter RESET_VECTOR = 32'h8000_0000 // 設定重置向量的參數，默認為 0x8000_0000
) (
    input clk,       // 時鐘信號輸入
    input reset,     // 重置信號輸入

    input meip,      // 機器外部中斷請求信號輸入

    // 記憶體介面
    output ext_valid,        // 外部記憶體有效信號輸出
    output ext_instruction,  // 外部記憶體指令信號輸出
    input ext_ready,         // 外部記憶體準備好信號輸入
    output [31:0] ext_address,        // 外部記憶體地址輸出
    output [31:0] ext_write_data,     // 外部記憶體寫數據輸出
    output [3:0] ext_write_strobe,    // 外部記憶體寫入選擇信號輸出
    input [31:0] ext_read_data        // 外部記憶體讀取數據輸入
);

pipeline #(
    .RESET_VECTOR(RESET_VECTOR)  // 傳入重置向量參數
) core_pipeline (
    .clk(clk),       // 時鐘信號連接到流水線模組
    .reset(reset),   // 重置信號連接到流水線模組

    .meip(meip),     // 外部中斷請求信號連接到流水線模組

    .fetch_data(fetch_data),     // 從指令記憶體獲取的數據
    .mem_load_data(mem_load_data), // 從資料記憶體讀取的數據
    .fetch_ready(fetch_ready),   // 指令獲取是否準備好
    .mem_ready(mem_ready),       // 資料存取是否準備好

    .fetch_address(fetch_address), // 指令獲取的地址
    .mem_address(mem_address),     // 資料存取的地址
    .mem_store_data(mem_store_data), // 存取的資料
    .mem_size(mem_size),         // 資料大小
    .mem_signed(mem_signed),     // 資料是否為有符號
    .mem_load(mem_load),         // 資料讀取信號
    .mem_store(mem_store)        // 資料寫入信號
);

wire [31:0] fetch_data;        // 定義從指令記憶體獲取的數據的連接線
wire [31:0] fetch_address;     // 定義指令獲取的地址的連接線
wire fetch_ready;              // 定義指令獲取準備好信號的連接線

wire [31:0] mem_load_data;     // 定義從資料記憶體讀取的數據的連接線
wire [31:0] mem_address;       // 定義資料存取的地址的連接線
wire [31:0] mem_store_data;    // 定義要存取的資料的連接線
wire [1:0] mem_size;           // 定義資料大小的連接線
wire mem_signed;               // 定義資料是否有符號的連接線
wire mem_load;                 // 定義資料讀取信號的連接線
wire mem_store;                // 定義資料寫入信號的連接線
wire mem_ready;                // 定義資料存取準備好信號的連接線

busio core_busio (
    /* .clk(clk), */  // 時鐘信號目前未連接

    .ext_valid(ext_valid),      // 外部記憶體有效信號
    .ext_instruction(ext_instruction), // 外部記憶體指令信號
    .ext_ready(ext_ready),      // 外部記憶體準備好信號
    .ext_address(ext_address),  // 外部記憶體地址
    .ext_write_data(ext_write_data), // 外部記憶體寫入數據
    .ext_write_strobe(ext_write_strobe), // 外部記憶體寫入選擇信號
    .ext_read_data(ext_read_data),  // 外部記憶體讀取數據

    .fetch_address(fetch_address), // 指令獲取地址
    .fetch_data(fetch_data),       // 指令獲取數據
    .fetch_ready(fetch_ready),     // 指令獲取準備好信號

    .mem_load_data(mem_load_data), // 資料讀取數據
    .mem_ready(mem_ready),         // 資料存取準備好信號
    .mem_address(mem_address),     // 資料存取地址
    .mem_store_data(mem_store_data), // 資料寫入數據
    .mem_size(mem_size),           // 資料大小
    .mem_signed(mem_signed),       // 資料是否有符號
    .mem_load(mem_load),           // 資料讀取信號
    .mem_store(mem_store)          // 資料寫入信號
);

endmodule
