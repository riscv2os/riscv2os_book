// 請包含其他檔案中的 Verilog 檔案，如果你在其他檔案中撰寫模組
module CPU(
    input             clk,            // 時鐘信號
    input             rst,            // 重置信號
    input      [31:0] data_out,      // 來自資料記憶體的輸出數據
    input      [31:0] instr_out,     // 來自指令記憶體的輸出指令
    output reg        instr_read,     // 指令讀取信號
    output reg        data_read,      // 資料讀取信號
    output reg [31:0] instr_addr,     // 指令記憶體地址
    output reg [31:0] data_addr,      // 資料記憶體地址
    output reg [3:0]  data_write,     // 資料寫入信號
    output reg [31:0] data_in         // 要寫入資料記憶體的數據
);
/* 在這裡加入你的設計 */
reg [31:0] register [31:0]; // 32 個 32 位的寄存器陣列
reg [31:0] pc;              // 程式計數器，儲存當前指令的地址
reg [31:0] count;           // 計數器，通常用於計算循環或次數
reg [2:0] state;           // 狀態寄存器，儲存 CPU 當前的狀態
integer i;                 // 整數型變數，用於迴圈或其他計算

// 每當時鐘的上升沿觸發此區塊
always@(posedge clk)
begin
	if(rst) // 如果重置信號為高
	begin
		register[0] = 32'd0; // 將寄存器 0 設為 0，符合 RISC-V 架構的設計
		pc = 32'd0; // 將程式計數器（PC）設為 0，從頭開始執行
		state = 3'd0; // 將狀態設為 0，進入初始狀態
		count = 32'd0; // 將計數器設為 0
	end
	else // 如果沒有重置
	begin
		case(state) // 根據當前狀態執行不同的操作
			3'd0: // 初始狀態
			begin
				register[0] = 0; // 確保寄存器 0 始終為 0
				state <= 3'd1; // 轉換到狀態 1
				instr_addr <= pc; // 將當前 PC 設為指令地址
				instr_read <= 1; // 開啟指令讀取
				data_read <= 0; // 關閉資料讀取
				data_write <= 4'b0000; // 初始化資料寫入信號為 0
				count = count + 1; // 計數器加 1，跟踪執行的指令數
			end
			3'd1: 
			begin
				state <= 3'd2; // 轉換到狀態 2，準備處理讀取的指令
			end
			3'd2: // 處理讀取的指令
			begin	
				case(instr_out[6:0]) // 根據指令的 opcode 判斷指令類型
					7'b0110011: // R-type 指令
					begin
						case({instr_out[31:25], instr_out[14:12]}) // 根據 funct3 和 funct7 判斷具體操作
							10'b0000000000: register[instr_out[11:7]] <= register[instr_out[19:15]] + register[instr_out[24:20]]; // 加法
							10'b0100000000: register[instr_out[11:7]] <= register[instr_out[19:15]] - register[instr_out[24:20]]; // 減法
							10'b0000000001: register[instr_out[11:7]] <= register[instr_out[19:15]] << register[instr_out[24:20]][4:0]; // 左移
							10'b0000000010: register[instr_out[11:7]] <= ($signed(register[instr_out[19:15]]) < $signed(register[instr_out[24:20]])) ? 1 : 0; // 小於比較
							10'b0000000011: register[instr_out[11:7]] <= (register[instr_out[19:15]] < register[instr_out[24:20]]) ? 1 : 0; // 無符號小於比較
							10'b0000000100: register[instr_out[11:7]] <= register[instr_out[19:15]] ^ register[instr_out[24:20]]; // 位元異或
							10'b0000000101: register[instr_out[11:7]] <= register[instr_out[19:15]] >> register[instr_out[24:20]][4:0]; // 右邊邏輯移位
							10'b0100000101: register[instr_out[11:7]] <= $signed(register[instr_out[19:15]]) >> register[instr_out[24:20]][4:0]; // 右邊算術移位
							10'b0000000110: register[instr_out[11:7]] <= register[instr_out[19:15]] | register[instr_out[24:20]]; // 位元或
							10'b0000000111: register[instr_out[11:7]] <= register[instr_out[19:15]] & register[instr_out[24:20]]; // 位元與
							default: ; // 其他情況不處理
						endcase
						state <= 3'd0; // 返回初始狀態
						pc = pc + 32'd4; // PC 加 4，準備讀取下一指令
						instr_read <= 0; // 關閉指令讀取
						data_read <= 0; // 關閉資料讀取
						data_write <= 4'b0000; // 資料寫入信號初始化
					end
					
					7'b0000011: // I-type Load 指令
					begin
						data_addr <= register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:20]}; // 計算資料地址
						state <= 3'd3; // 轉換到狀態 3，準備讀取資料
						instr_addr <= pc; // 設定指令地址
						instr_read <= 1; // 開啟指令讀取
						data_read <= 1; // 開啟資料讀取
						data_write <= 4'b0000; // 初始化資料寫入信號
					end

					7'b0010011: // I-type ALU 指令
					begin
						case(instr_out[14:12]) // 根據 funct3 判斷操作
							3'b000: register[instr_out[11:7]] <= register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:20]}; // 加法
							3'b010: register[instr_out[11:7]] <= ($signed(register[instr_out[19:15]]) < $signed({{20{instr_out[31]}}, instr_out[31:20]})) ? 1 : 0; // 小於比較
							3'b011: register[instr_out[11:7]] <= ($unsigned(register[instr_out[19:15]]) < $unsigned({{20{instr_out[31]}}, instr_out[31:20]})) ? 1 : 0; // 無符號小於比較
							3'b100: register[instr_out[11:7]] <= register[instr_out[19:15]] ^ {{20{instr_out[31]}}, instr_out[31:20]}; // 位元異或
							3'b110: register[instr_out[11:7]] <= register[instr_out[19:15]] | {{20{instr_out[31]}}, instr_out[31:20]}; // 位元或
							3'b111: register[instr_out[11:7]] <= register[instr_out[19:15]] & {{20{instr_out[31]}}, instr_out[31:20]}; // 位元與
							3'b001: register[instr_out[11:7]] <= register[instr_out[19:15]] << instr_out[24:20]; // 左移
							3'b101: // 右移
							begin
								case(instr_out[31:25]) // 根據 funct7 判斷右移方式
									7'b0000000: register[instr_out[11:7]] <= register[instr_out[19:15]] >> instr_out[24:20]; // 邏輯右移
									7'b0100000: register[instr_out[11:7]] <= $signed(register[instr_out[19:15]]) >>> instr_out[24:20]; // 算術右移
									default: ; // 預設情況不處理
								endcase
							end
							default: ; // 預設情況不處理
						endcase
						state <= 3'd0; // 返回初始狀態
						pc = pc + 32'd4; // PC 加 4，準備讀取下一指令
						instr_read <= 0; // 關閉指令讀取
						data_read <= 0; // 關閉資料讀取
						data_write <= 4'b0000; // 初始化資料寫入信號
					end

					7'b1100111: // JALR 指令
					begin
						register[instr_out[11:7]] <= pc + 32'd4; // 將返回地址 (PC + 4) 儲存到指定寄存器
						pc <= {{20{instr_out[31]}}, instr_out[31:20]} + register[instr_out[19:15]]; // 計算新的 PC 值
						state <= 3'd0; // 返回初始狀態
						instr_read <= 0; // 關閉指令讀取
						data_read <= 0; // 關閉資料讀取
						data_write <= 4'b0000; // 初始化資料寫入信號
						//$display("JALR"); // 顯示 JALR 指令的執行（此行為註解，實際運行時可選擇啟用）
					end

					7'b0100011: // S-type Store 指令
					begin
						data_addr = register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:25], instr_out[11:7]}; // 計算資料地址
						state <= 3'd0; // 返回初始狀態
						pc = pc + 32'd4; // 更新 PC 為下一條指令的地址
						instr_read <= 1; // 開啟指令讀取
						data_read <= 0; // 關閉資料讀取
						case(instr_out[14:12]) // 根據 funct3 處理不同的存儲方式
							3'b010: // 存儲字（SW）
							begin
								data_in <= register[instr_out[24:20]]; // 將寄存器的數據放入輸入資料
								data_write <= 4'b1111; // 設置資料寫入信號為全開
							end
							3'b000: // 存儲字節（SB）
							begin
								data_in <= {register[instr_out[24:20]][7:0], register[instr_out[24:20]][7:0], register[instr_out[24:20]][7:0], register[instr_out[24:20]][7:0]}; // 將字節擴展為 4 字節
								case(data_addr[1:0]) // 根據地址確定存儲的字節
									2'b00: data_write <= 4'b0001; // 存儲到最低位
									2'b01: data_write <= 4'b0010; // 存儲到次低位
									2'b10: data_write <= 4'b0100; // 存儲到次高位
									2'b11: data_write <= 4'b1000; // 存儲到最高位
									default: ; // 預設情況不處理
								endcase
							end
							3'b001: // 存儲半字（SH）
							begin
								data_in <= {register[instr_out[24:20]][15:0], register[instr_out[24:20]][15:0]}; // 擴展半字
								case(data_addr[1:0]) // 根據地址確定存儲的半字
									2'b00: data_write <= 4'b0011; // 存儲到最低位和次低位
									2'b10: data_write <= 4'b1100; // 存儲到次高位和最高位
									default: ; // 預設情況不處理
								endcase
							end
							default: ; // 預設情況不處理
						endcase
					end

					7'b1100011: // B-type Branch 指令
					begin
						case(instr_out[14:12]) // 根據 funct3 判斷分支條件
							3'b000: pc = (register[instr_out[19:15]] == register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4; // 相等分支
							3'b001: pc = (register[instr_out[19:15]] != register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4; // 不相等分支
							3'b100: pc = ($signed(register[instr_out[19:15]]) < $signed(register[instr_out[24:20]])) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4; // 小於分支
							3'b101: pc = ($signed(register[instr_out[19:15]]) >= $signed(register[instr_out[24:20]])) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4; // 大於等於分支
							3'b110: pc = (register[instr_out[19:15]] < register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4; // 無符號小於分支
							3'b111: pc = (register[instr_out[19:15]] >= register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4; // 無符號大於等於分支
							default: ; // 預設情況不處理
						endcase
						state <= 3'd0; // 返回初始狀態
						instr_read <= 0; // 關閉指令讀取
						data_read <= 0; // 關閉資料讀取
						data_write <= 4'b0000; // 初始化資料寫入信號
					end
					7'b0010111: // AUIPC 指令
					begin
						register[instr_out[11:7]] <= pc + {instr_out[31:12], 12'd0}; // 將 PC 值加上立即數的高位存入寄存器
						state <= 3'd0; // 返回初始狀態
						pc = pc + 32'd4; // 更新 PC 為下一條指令的地址
						instr_read <= 0; // 關閉指令讀取
						data_read <= 0; // 關閉資料讀取
						data_write <= 4'b0000; // 初始化資料寫入信號
					end
					7'b0110111: // LUI 指令
					begin
						register[instr_out[11:7]] <= {instr_out[31:12], 12'd0}; // 將立即數的高 20 位儲存到指定寄存器，低 12 位填充為零
						state <= 3'd0; // 返回初始狀態
						pc = pc + 32'd4; // 更新 PC 為下一條指令的地址
						instr_read <= 0; // 關閉指令讀取
						data_read <= 0; // 關閉資料讀取
						data_write <= 4'b0000; // 初始化資料寫入信號
					end

					7'b1101111: // JAL 指令
					begin
						register[instr_out[11:7]] <= pc + 32'd4; // 將返回地址 (PC + 4) 儲存到指定寄存器
						pc = pc + {{11{instr_out[31]}}, instr_out[31], instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0}; // 計算跳轉的目標地址
						state <= 3'd0; // 返回初始狀態
						instr_read <= 0; // 關閉指令讀取
						data_read <= 0; // 關閉資料讀取
						data_write <= 4'b0000; // 初始化資料寫入信號
						//$display("JAL"); // 顯示 JAL 指令的執行（此行為註解，實際運行時可選擇啟用）
					end
					default: ; // 其他不匹配的情況不處理
				endcase
			end

			3'd3: // 狀態 3
			begin
				state <= 3'd4; // 轉換到狀態 4
				data_addr <= register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:20]}; // 計算資料地址
				instr_read <= 1; // 開啟指令讀取
				data_read <= 1; // 開啟資料讀取
				data_write <= 4'b0000; // 初始化資料寫入信號
			end

			3'd4: // 狀態 4
			begin
				case(instr_out[14:12]) // 根據 funct3 判斷數據儲存的方式
					3'b010: register[instr_out[11:7]] <= data_out; // 存儲字（LW）
					3'b000: register[instr_out[11:7]] <= {{24{data_out[7]}}, data_out[7:0]}; // 存儲字節（LB），符號擴展
					3'b001: register[instr_out[11:7]] <= {{16{data_out[15]}}, data_out[15:0]}; // 存儲半字（LH），符號擴展
					3'b100: register[instr_out[11:7]] <= {24'd0, data_out[7:0]}; // 存儲字節（LBU），無符號擴展
					3'b101: register[instr_out[11:7]] <= {16'd0, data_out[15:0]}; // 存儲半字（LHU），無符號擴展
					default: ; // 預設情況不處理
				endcase
				state <= 3'd0; // 返回初始狀態
				pc = pc + 32'd4; // 更新 PC 為下一條指令的地址
				instr_read <= 0; // 關閉指令讀取
				data_read <= 0; // 關閉資料讀取
				data_write <= 4'b0000; // 初始化資料寫入信號
			end
		endcase
	end
end

endmodule
