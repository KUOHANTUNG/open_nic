`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/20 22:02:57
// Design Name: 
// Module Name: uram_para
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uram_para#(
    parameter int cascade_level = 16,
    parameter int ROWW = 12
)(
    input               clk,
    input               rst_n,
    output logic [71:0] DOUT_A,
    output logic [71:0] DOUT_B,
    input  logic [22:0] ADDR_A,
    input  logic [22:0] ADDR_B,
    input  logic [8:0]  BWE_A,
    input  logic [8:0]  BWE_B,
    input  logic [71:0] DIN_A,
    input  logic [71:0] DIN_B,
    input  logic        RDB_WR_A,
    input  logic        RDB_WR_B,
    input  logic        EN_A,
    input  logic        EN_B
);

   localparam int BANKS = cascade_level;
    localparam int SELW  = (BANKS<=1) ? 1 : $clog2(BANKS);



 
    wire [SELW-1:0] selA = ADDR_A[ROWW+SELW-1 : ROWW];
    wire [SELW-1:0] selB = ADDR_B[ROWW+SELW-1 : ROWW];


    wire rst = ~rst_n;


    logic [22:0] wire_ADDR_A [BANKS-1:0];
    logic [22:0] wire_ADDR_B [BANKS-1:0];
    logic [8:0]  wire_BWE_A  [BANKS-1:0];
    logic [8:0]  wire_BWE_B  [BANKS-1:0];
    logic [71:0] wire_DIN_A  [BANKS-1:0];
    logic [71:0] wire_DIN_B  [BANKS-1:0];
    logic [71:0] wire_DOUT_A [BANKS-1:0];
    logic [71:0] wire_DOUT_B [BANKS-1:0];
    logic        wire_EN_A   [BANKS-1:0];
    logic        wire_EN_B   [BANKS-1:0];
    logic        wire_RDACCESS_A [BANKS-1:0];
    logic        wire_RDACCESS_B [BANKS-1:0];
    logic        wire_RDB_WR_A   [BANKS-1:0];
    logic        wire_RDB_WR_B   [BANKS-1:0];


    always_comb begin
 
        for (int i = 0; i < BANKS; i++) begin
            wire_ADDR_A[i]   = '0;
            wire_BWE_A[i]    = '0;
            wire_DIN_A[i]    = '0;
            wire_EN_A[i]     = 1'b0;
            wire_RDB_WR_A[i] = 1'b0; 
        end

        if (selA < BANKS) begin
            wire_ADDR_A[selA]   = { {(23-ROWW){1'b0}}, ADDR_A[ROWW-1:0] }; 
            wire_BWE_A[selA]    = BWE_A;
            wire_DIN_A[selA]    = DIN_A;
            wire_EN_A[selA]     = EN_A;
            wire_RDB_WR_A[selA] = RDB_WR_A;
        end
    end


    always_comb begin
        for (int i = 0; i < BANKS; i++) begin
            wire_ADDR_B[i]   = '0;
            wire_BWE_B[i]    = '0;
            wire_DIN_B[i]    = '0;
            wire_EN_B[i]     = 1'b0;
            wire_RDB_WR_B[i] = 1'b0;
        end
        if (selB < BANKS) begin
            wire_ADDR_B[selB]   = { {(23-ROWW){1'b0}}, ADDR_B[ROWW-1:0] };
            wire_BWE_B[selB]    = BWE_B;
            wire_DIN_B[selB]    = DIN_B;
            wire_EN_B[selB]     = EN_B;
            wire_RDB_WR_B[selB] = RDB_WR_B;
        end
    end


    assign DOUT_A     = (selA < BANKS) ? wire_DOUT_A[selA]     : '0;
    assign DOUT_B     = (selB < BANKS) ? wire_DOUT_B[selB]     : '0;


    generate
        for (genvar i = 0; i < BANKS; i++) begin : G_URAM
            URAM288_BASE #(
                .AUTO_SLEEP_LATENCY(8),
                .AVG_CONS_INACTIVE_CYCLES(10),
                .BWE_MODE_A("PARITY_INTERLEAVED"),
                .BWE_MODE_B("PARITY_INTERLEAVED"),
                .EN_AUTO_SLEEP_MODE("FALSE"),
                .EN_ECC_RD_A("FALSE"),
                .EN_ECC_RD_B("FALSE"),
                .EN_ECC_WR_A("FALSE"),
                .EN_ECC_WR_B("FALSE"),
                .IREG_PRE_A("FALSE"),
                .IREG_PRE_B("FALSE"),
                .IS_CLK_INVERTED(1'b0),
                .IS_EN_A_INVERTED(1'b0),
                .IS_EN_B_INVERTED(1'b0),
                .IS_RDB_WR_A_INVERTED(1'b0),
                .IS_RDB_WR_B_INVERTED(1'b0),
                .IS_RST_A_INVERTED(1'b0),
                .IS_RST_B_INVERTED(1'b0),
                .OREG_A("FALSE"),
                .OREG_B("FALSE"),
                .OREG_ECC_A("FALSE"),
                .OREG_ECC_B("FALSE"),
                .RST_MODE_A("SYNC"),
                .RST_MODE_B("SYNC"),
                .USE_EXT_CE_A("FALSE"),
                .USE_EXT_CE_B("FALSE")
            ) URAM288_BASE_inst (
                .CLK(clk),
                .RST_A(rst),
                .RST_B(rst),
                .ADDR_A(wire_ADDR_A[i]),
                .ADDR_B(wire_ADDR_B[i]),
                .BWE_A (wire_BWE_A[i]),
                .BWE_B (wire_BWE_B[i]),
                .DIN_A (wire_DIN_A[i]),
                .DIN_B (wire_DIN_B[i]),
                .EN_A  (wire_EN_A[i]),
                .EN_B  (wire_EN_B[i]),
                .RDB_WR_A(wire_RDB_WR_A[i]),
                .RDB_WR_B(wire_RDB_WR_B[i]),
                .DOUT_A(wire_DOUT_A[i]),
                .DOUT_B(wire_DOUT_B[i]),
                .INJECT_DBITERR_A(1'b0),
                .INJECT_DBITERR_B(1'b0),
                .INJECT_SBITERR_A(1'b0),
                .INJECT_SBITERR_B(1'b0),
                .OREG_CE_A(1'b1),
                .OREG_CE_B(1'b1),
                .OREG_ECC_CE_A(1'b1),
                .OREG_ECC_CE_B(1'b1),
                .SLEEP(1'b0)
            );
        end
    endgenerate
endmodule
