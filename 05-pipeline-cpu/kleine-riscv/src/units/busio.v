module busio (
    /* input clk, */  // 時鐘信號（當前未使用）

    // 外部介面
    output ext_valid,          // 外部記憶體有效信號
    output ext_instruction,    // 外部記憶體指令模式（0: 資料存取, 1: 指令獲取）
    input ext_ready,           // 外部記憶體準備好信號
    output [31:0] ext_address, // 外部記憶體地址
    output [31:0] ext_write_data,  // 外部記憶體寫入數據
    output reg [3:0] ext_write_strobe, // 外部記憶體寫入選擇信號
    input [31:0] ext_read_data, // 外部記憶體讀取數據

    // 內部介面
    input [31:0] fetch_address,  // 指令獲取地址
    output [31:0] fetch_data,    // 指令獲取數據
    output fetch_ready,          // 指令獲取準備好信號

    output reg [31:0] mem_load_data, // 資料讀取結果
    output mem_ready,           // 資料存取準備好信號
    input [31:0] mem_address,   // 資料存取地址
    input [31:0] mem_store_data, // 要寫入的資料
    input [1:0] mem_size,       // 資料大小（0: 1 byte, 1: 2 bytes, 2: 4 bytes）
    input mem_signed,           // 資料是否為有符號
    input mem_load,             // 資料讀取信號
    input mem_store             // 資料寫入信號
);

assign ext_valid = 1;  // 外部記憶體操作始終有效
assign ext_instruction = !(mem_load || mem_store);  // 如果不是資料存取操作，則為指令獲取模式
// 根據當前是資料存取還是指令獲取，選擇適當的地址，並將地址的低兩位強制為 0（對齊地址）
assign ext_address = ((mem_load || mem_store) ? mem_address : fetch_address) & 32'hffff_fffc;
// 根據地址的低兩位，將要寫入的資料對齊到正確的位元組
assign ext_write_data = mem_store_data << (8 * mem_address[1:0]);

// 根據資料大小和地址的低兩位設置寫入選擇信號（write strobe），控制哪些位元組需要寫入
always @(*) begin
    if (!mem_store) begin
        ext_write_strobe = 0;  // 如果不是寫入操作，則不啟用寫入選擇信號
    end else if (mem_size == 0) begin
        ext_write_strobe = (4'b0001 << mem_address[1:0]);  // 1 byte 寫入
    end else if (mem_size == 1) begin
        ext_write_strobe = (4'b0011 << mem_address[1:0]);  // 2 bytes 寫入
    end else if (mem_size == 2) begin
        ext_write_strobe = 4'b1111;  // 4 bytes 寫入
    end else begin
        ext_write_strobe = 0;  // 預設為不啟用
    end
end

// 指令獲取的數據直接從外部讀取的數據獲得
assign fetch_data = ext_read_data;
// 當外部記憶體準備好且當前是指令獲取模式時，指令獲取準備好信號為高
assign fetch_ready = (ext_ready && ext_instruction);

// 當外部記憶體準備好且當前是資料存取模式時，資料存取準備好信號為高
assign mem_ready = (ext_ready && !ext_instruction);

// 讀取資料，根據地址對齊並處理不同大小的資料（1 byte, 2 bytes 或 4 bytes）
wire [31:0] tmp_load_data = (ext_read_data >> (mem_address[1:0] * 8));

// 根據資料大小和是否有符號來處理讀取到的資料
always @(*) begin
    if (mem_size == 0) begin  // 1 byte
        if (mem_signed) begin
            mem_load_data = {{24{tmp_load_data[7]}}, tmp_load_data[7:0]};  // 有符號擴展
        end else begin
            mem_load_data = {24'b0, tmp_load_data[7:0]};  // 無符號擴展
        end
    end else if (mem_size == 1) begin  // 2 bytes
        if (mem_signed) begin
            mem_load_data = {{16{tmp_load_data[15]}}, tmp_load_data[15:0]};  // 有符號擴展
        end else begin
            mem_load_data = {16'b0, tmp_load_data[15:0]};  // 無符號擴展
        end
    end else if (mem_size == 2) begin  // 4 bytes
        mem_load_data = tmp_load_data;  // 直接使用 32 位的資料
    end else begin
        mem_load_data = 0;  // 預設值
    end
end

endmodule
