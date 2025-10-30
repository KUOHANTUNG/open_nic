`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/20 10:02:10
// Design Name: 
// Module Name: uram512
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

// A -> peer // B -> host
module uram512(
    
    input [22:0]    addr_a,
    input [22:0]    addr_b,
    
    input [575:0]   tx_data_a,
    input [575:0]   tx_data_b,
    
    output [575:0]   rx_data_a,
    output [575:0]   rx_data_b,
    
    input           clk,
    input           rst_n,
    input           rdb_wr_a,
    input           rdb_wr_b,
    input   [8:0]   bwe_a,
    input   [8:0]   bwe_b,
    input           en_a,
    input           en_b  
    );
    
    generate for (genvar i = 0; i < 8; i++) begin
        uram_para#(
            .cascade_level(16),
            .ROWW(12)
        )uram_para_inst(
            .clk(clk),     
            .rst_n(rst_n),   
            .DOUT_A(rx_data_a[`getvec(72, i)]),  
            .DOUT_B(rx_data_b[`getvec(72, i)]),  
            .ADDR_A(addr_a),  
            .ADDR_B(addr_b),  
            .BWE_A(bwe_a),   
            .BWE_B(bwe_b),   
            .DIN_A(tx_data_a[`getvec(72, i)]),   
            .DIN_B(tx_data_b[`getvec(72, i)]),   
            .RDB_WR_A(rdb_wr_a),
            .RDB_WR_B(rdb_wr_b),
            .EN_A(en_a),    
            .EN_B(en_b)     
        );
    end
    endgenerate
endmodule
