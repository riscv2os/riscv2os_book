`timescale 1ns / 1ps // 定義時間單位和時間精度

module and_gate (
    input wire a,
    input wire b,
    output wire y
);
    assign y = a & b; // AND operation
endmodule
