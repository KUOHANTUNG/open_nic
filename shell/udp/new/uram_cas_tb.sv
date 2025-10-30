`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/20 15:00:45
// Design Name: 
// Module Name: uram_cas_tb
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


module uram_cas_tb;
    reg  clk;
    wire  [71:0] DOUT_A;
    wire  [71:0] DOUT_B;
    wire         RDACCESS_A;
    wire         RDACCESS_B;
    reg  [22:0] ADDR_A;
    reg  [22:0] ADDR_B;
    reg  [8:0]  BWE_A;
    reg  [8:0]  BWE_B;
    reg  [71:0] DIN_A;
    reg  [71:0] DIN_B;
    reg         RDB_WR_A;
    reg         RDB_WR_B;
    reg         rst;
    reg         EN_A;
    reg         EN_B;
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        rst <= 1;
        #20
        repeat(2) @(posedge clk);
        RDB_WR_A <= 0;
        RDB_WR_B <= 0;
        ADDR_A <= 0;
        ADDR_B <= 0;
        BWE_A <= 0;
        BWE_B <= 0;
        EN_A <= 0;
        EN_B <= 0;
        repeat(2) @(posedge clk);
        rst <= 1;
        @(posedge clk);
        EN_A <= 1;
        ADDR_A <= 23'h00ffff;
        DIN_A <= 72'h121112111211121121;
        BWE_A <= 'b111111111;
        RDB_WR_A <= 1;
        #200
        @(posedge clk);
        RDB_WR_A <= 0;
        ADDR_A <= 23'h00ffff;
        @(posedge clk);
    end

    uram_cas uram_cas_inst (
        .clk(clk),        
        .rst(rst),        
        .DOUT_A(DOUT_A),     
        .DOUT_B(DOUT_B),     
        .RDACCESS_A(RDACCESS_A), 
        .RDACCESS_B(RDACCESS_B), 
        .ADDR_A(ADDR_A),     
        .ADDR_B(ADDR_B),     
        .BWE_A(BWE_A),      
        .BWE_B(BWE_B),      
        .DIN_A(DIN_A),      
        .DIN_B(DIN_B),      
        .RDB_WR_A(RDB_WR_A),   
        .RDB_WR_B(RDB_WR_B),   
        .EN_A(EN_A),       
        .EN_B(EN_B)        
    );

endmodule
