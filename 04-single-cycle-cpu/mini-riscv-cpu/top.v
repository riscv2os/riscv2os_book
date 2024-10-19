`include "CPU.v"  // 包含 CPU 模組
`include "SRAM.v" // 包含 SRAM 模組

// 顶层模块
module top(
    input clk,       // 時鐘信號輸入
    input rst       // 重置信號輸入
);

// 定義中間信號的連接
wire        instr_read;       // 指令讀取使能信號
wire [31:0] instr_addr;       // 指令地址
wire [31:0] instr_out;        // 讀取到的指令
wire        data_read;        // 數據讀取使能信號
wire [3:0]  data_write;       // 數據寫入使能信號
wire [31:0] data_addr;        // 數據地址
wire [31:0] data_in;         // 要寫入的數據
wire [31:0] data_out;        // 讀取到的數據

// 初始化設置，生成波形文件
initial
begin
	$dumpfile("tb.vcd"); // 指定波形文件名
	$dumpvars(0, top);   // 記錄當前模組的變量
end

// 實例化 CPU 模組
CPU i_CPU(
    .clk        ( clk              ), // 將時鐘信號傳遞給 CPU
    .rst        ( rst              ), // 將重置信號傳遞給 CPU
    .instr_read ( instr_read       ), // 將指令讀取信號傳遞給 CPU
    .instr_addr ( instr_addr       ), // 將指令地址傳遞給 CPU
    .instr_out  ( instr_out        ), // 將讀取到的指令傳遞給 CPU
    .data_read  ( data_read        ), // 將數據讀取信號傳遞給 CPU
    .data_write ( data_write       ), // 將數據寫入信號傳遞給 CPU
    .data_addr  ( data_addr        ), // 將數據地址傳遞給 CPU
    .data_in    ( data_in          ), // 將要寫入的數據傳遞給 CPU
    .data_out   ( data_out         )  // 將讀取到的數據傳遞給 CPU
);

// 實例化指令記憶體（SRAM）
SRAM i_IM(
    .clk        ( clk              ), // 將時鐘信號傳遞給 SRAM
    .rst        ( rst              ), // 將重置信號傳遞給 SRAM
    .addr       ( instr_addr[15:2] ), // 將指令地址的高位（只取有效位）傳遞給 SRAM
    .read       ( instr_read       ), // 將指令讀取信號傳遞給 SRAM
    .write      ( 4'b0             ), // 此 SRAM 為指令存儲器，不進行寫入，寫入信號為 0
    .DI         ( 32'b0            ), // 不進行寫入時，輸入數據為 0
    .DO         ( instr_out        )  // 將讀取到的指令輸出
);

// 實例化數據記憶體（SRAM）
SRAM i_DM(
    .clk        ( clk              ), // 將時鐘信號傳遞給 SRAM
    .rst        ( rst              ), // 將重置信號傳遞給 SRAM
    .addr       ( data_addr[15:2] ), // 將數據地址的高位（只取有效位）傳遞給 SRAM
    .read       ( data_read       ), // 將數據讀取信號傳遞給 SRAM
    .write      ( data_write      ), // 將數據寫入信號傳遞給 SRAM
    .DI         ( data_in         ), // 將要寫入的數據傳遞給 SRAM
    .DO         ( data_out        )  // 將讀取到的數據輸出
);

endmodule
