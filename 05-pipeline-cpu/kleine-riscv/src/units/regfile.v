module regfile (
    input clk, // 時鐘信號

    // from decode (來自解碼階段，讀取端口)
    input [4:0] rs1_address, // 第一個源寄存器的地址
    input [4:0] rs2_address, // 第二個源寄存器的地址
    // to decode (輸出到解碼階段，讀取端口)
    output reg [31:0] rs1_data, // 第一個源寄存器的數據輸出
    output reg [31:0] rs2_data, // 第二個源寄存器的數據輸出

    // from writeback (來自回寫階段，寫入端口)
    input [4:0] rd_address, // 目標寄存器的地址
    input [31:0] rd_data // 要寫入的數據
);

    // 定義一個 32 位元的寄存器陣列，大小為 32
    reg [31:0] registers [0:31];

    // 當讀取端口 rs1_address 的時候，從寄存器中獲取數據
    always @(*) begin
        rs1_data = registers[rs1_address]; // 根據 rs1_address 讀取對應寄存器的數據
    end
    
    // 當讀取端口 rs2_address 的時候，從寄存器中獲取數據
    always @(*) begin
        rs2_data = registers[rs2_address]; // 根據 rs2_address 讀取對應寄存器的數據
    end

    // 當時鐘上升沿時，將 rd_data 寫入到指定的 rd_address 寄存器
    always @(posedge clk) begin
        registers[rd_address] <= rd_data; // 寫入操作，更新指定寄存器的數據
    end

endmodule
