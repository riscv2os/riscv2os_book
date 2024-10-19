module writeback (
    /* input clk, */ // 時鐘信號（被註解掉）

    // 從 memory 階段接收的信號
    input [31:0] pc_in, // 當前程序計數器的值
    input [31:0] next_pc_in, // 下一個程序計數器的值

    // 從 memory 階段接收的數據 (控制 WB)
    input [31:0] alu_data_in, // ALU 計算結果
    input [31:0] csr_data_in, // CSR 數據
    input [31:0] load_data_in, // 加載的數據
    input [1:0] write_select_in, // 寫入選擇信號，決定寫入的數據來源
    input [4:0] rd_address_in, // rd 寄存器的地址
    input [11:0] csr_address_in, // CSR 寄存器的地址
    input csr_write_in, // CSR 寫入使能信號
    input mret_in, // mret 信號
    input wfi_in, // wfi 信號

    // 從 memory 階段接收的有效性和異常信號
    input valid_in, // 指令有效性輸入
    input [3:0] ecause_in, // 異常原因
    input exception_in, // 異常信號

    // 從 csr 模組接收的信號
    input sip, // 監控中斷的狀態信號
    input tip, // 計時器中斷的狀態信號
    input eip, // 外部中斷的狀態信號

    // 對 regfile 的輸出
    output [4:0] rd_address, // rd 寄存器的地址
    output reg [31:0] rd_data, // 寫回的數據

    // 對 csr 的輸出
    output csr_write, // CSR 寫入使能信號
    output [11:0] csr_address, // CSR 寄存器的地址
    output [31:0] csr_data, // 寫回的 CSR 數據

    // 對 fetch、csr 和 hazard 模組的輸出
    output traped, // trap 信號
    output mret, // mret 信號

    // 對 hazard 模組的輸出
    output wfi, // wfi 信號

    // 對 csr 的輸出
    output retired, // 退役指令計數
    output [31:0] ecp, // 異常計數
    output reg [3:0] ecause, // 異常原因
    output reg interupt // 中斷信號
);

localparam WRITE_SEL_ALU     = 2'b00; // ALU 寫入選擇
localparam WRITE_SEL_CSR     = 2'b01; // CSR 寫入選擇
localparam WRITE_SEL_LOAD    = 2'b10; // 加載數據寫入選擇
localparam WRITE_SEL_NEXT_PC = 2'b11; // 下一程序計數器寫入選擇

// 異常信號的生成，根據 valid_in 和 exception_in 的值
wire exception = exception_in && valid_in;

// 判斷是否需要觸發 trap
assign traped = (sip || tip || eip || exception);

// 根據 wfi_in 決定 ecp 的值
assign ecp = wfi_in ? next_pc_in : pc_in;
// wfi 信號的生成
assign wfi = valid_in && wfi_in;

// 計算是否已經退役
assign retired = valid_in && !traped && !wfi;

// 計算 mret 的有效性
assign mret = valid_in && mret_in;

// 根據中斷類型設定異常原因和中斷信號
always @(*) begin
    if (eip) begin
        ecause = 11; // 外部中斷的異常原因
        interupt = 1; // 設置中斷信號
    end else if (tip) begin
        ecause = 7; // 計時器中斷的異常原因
        interupt = 1; // 設置中斷信號
    end else if (sip) begin
        ecause = 3; // 監控中斷的異常原因
        interupt = 1; // 設置中斷信號
    end else if (exception_in) begin
        ecause = ecause_in; // 使用傳入的異常原因
        interupt = 0; // 不設置中斷信號
    end else begin
        ecause = 0; // 默認異常原因
        interupt = 0; // 默認不設置中斷信號
    end
end

// 根據 valid_in 和 traped 的狀態決定 rd_address 的值
assign rd_address = (!valid_in || traped) ? 5'h0 : rd_address_in;

// 根據寫入選擇決定 rd_data 的值
always @(*) begin
    case (write_select_in)
        WRITE_SEL_ALU: rd_data = alu_data_in; // ALU 數據寫回
        WRITE_SEL_CSR: rd_data = csr_data_in; // CSR 數據寫回
        WRITE_SEL_LOAD: rd_data = load_data_in; // 加載數據寫回
        WRITE_SEL_NEXT_PC: rd_data = next_pc_in; // 下一程序計數器寫回
    endcase
end

// CSR 寫入使能信號的生成
assign csr_write = valid_in && !traped && csr_write_in;
// CSR 寄存器地址的輸出
assign csr_address = csr_address_in;
// CSR 數據的輸出
assign csr_data = alu_data_in; // 這裡使用 ALU 數據作為 CSR 數據

endmodule
