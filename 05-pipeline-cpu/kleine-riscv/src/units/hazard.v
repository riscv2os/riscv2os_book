module hazard (
    input reset, // 重置信號

    // from decode (來自解碼階段)
    input valid_decode, // 解碼是否有效
    input [4:0] rs1_address_decode, // 第一個源寄存器地址
    input [4:0] rs2_address_decode, // 第二個源寄存器地址
    input uses_rs1, // 是否使用 rs1
    input uses_rs2, // 是否使用 rs2
    input uses_csr, // 是否使用 CSR（控制和狀態寄存器）

    // from execute (來自執行階段)
    input valid_execute, // 執行是否有效
    input [4:0] rd_address_execute, // 寫入的目的寄存器地址
    input csr_write_execute, // 是否寫入 CSR

    // from memory (來自記憶體階段)
    input valid_memory, // 記憶體操作是否有效
    input [4:0] rd_address_memory, // 寫入的目的寄存器地址
    input csr_write_memory, // 是否寫入 CSR
    input branch_taken, // 是否執行分支
    input mret_memory, // 記憶體階段是否執行 mret
    input load_store, // 是否為載入/存儲操作
    input bypass_memory, // 是否進行旁路操作

    // from writeback (來自回寫階段)
    input valid_writeback, // 回寫操作是否有效
    input csr_write_writeback, // 是否寫入 CSR
    input mret_writeback, // 回寫階段是否執行 mret
    input wfi, // 是否執行 wfi（等待中斷）
    input traped, // 是否發生陷阱

    // from busio (來自總線IO)
    input fetch_ready, // 是否準備好取指
    input mem_ready, // 記憶體是否準備好

    // to fetch (輸出到取指階段)
    output stall_fetch, // 取指階段是否停頓
    output invalidate_fetch, // 取指階段是否失效

    // to decode (輸出到解碼階段)
    output stall_decode, // 解碼階段是否停頓
    output invalidate_decode, // 解碼階段是否失效

    // to execute (輸出到執行階段)
    output stall_execute, // 執行階段是否停頓
    output invalidate_execute, // 執行階段是否失效

    // to memory (輸出到記憶體階段)
    output stall_memory, // 記憶體階段是否停頓
    output invalidate_memory // 記憶體階段是否失效
);

// 計算取指階段的停頓信號
assign stall_fetch = stall_decode || data_hazard; // 若解碼階段停頓或存在資料冒險則取指階段也停頓

// 解碼階段停頓信號，這裡直接來自執行階段的停頓信號
assign stall_decode = stall_execute;

// 執行階段的停頓信號
assign stall_execute = stall_memory // 若記憶體階段停頓
    || (!mem_ready && load_store) // 若記憶體未準備好且為載入/存儲操作
    || (valid_memory && mret_memory); // 若記憶體階段有效且執行 mret

assign stall_memory = wfi; // 若執行 wfi，則記憶體階段停頓

// 定義陷阱失效信號
wire trap_invalidate = mret_writeback || traped; // 若回寫階段執行 mret 或發生陷阱則失效

// 定義分支失效信號
wire branch_invalidate = branch_taken || trap_invalidate; // 若發生分支或陷阱則失效

// 計算資料冒險
wire data_hazard = valid_decode && ( // 若解碼有效
    (valid_execute && rd_address_execute != 0 && ( // 若執行有效且目標寄存器不為 0
        uses_rs1 && rs1_address_decode == rd_address_execute // 使用 rs1 且地址匹配
        || uses_rs2 && rs2_address_decode == rd_address_execute // 使用 rs2 且地址匹配
    ))
    || (valid_memory && rd_address_memory != 0 && !bypass_memory && ( // 若記憶體有效且目標寄存器不為 0 且不進行旁路
        uses_rs1 && rs1_address_decode == rd_address_memory // 使用 rs1 且地址匹配
        || uses_rs2 && rs2_address_decode == rd_address_memory // 使用 rs2 且地址匹配
    ))
    || uses_csr && ( // 若使用 CSR
        csr_write_execute && valid_execute // 若執行有效且寫入 CSR
        || csr_write_memory && valid_memory // 若記憶體有效且寫入 CSR
        || csr_write_writeback && valid_writeback // 若回寫有效且寫入 CSR
    )
);

// 計算取指失效信號
assign invalidate_fetch = reset || branch_invalidate || (!fetch_ready && !data_hazard); // 若重置、發生分支或取指未準備好且存在資料冒險則失效

// 計算解碼失效信號
assign invalidate_decode = reset || branch_invalidate || data_hazard; // 若重置、發生分支或資料冒險則失效

// 計算執行失效信號
assign invalidate_execute = reset || branch_invalidate; // 若重置或發生分支則失效

// 計算記憶體失效信號
assign invalidate_memory = reset || trap_invalidate || (!mem_ready && load_store); // 若重置、發生陷阱或記憶體未準備好且為載入/存儲操作則失效

endmodule
