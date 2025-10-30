`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/19 21:20:55
// Design Name: 
// Module Name: process_stack
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


module process_stack(
    input               axis_clk,
    input               axis_rstn,
    
    input               s_axis_rx_tvalid,
    input [511:0]       s_axis_rx_tdata,
    input [63:0]        s_axis_rx_tkeep,
    input               s_axis_rx_tlast,
    output              s_axis_rx_tready,
    
    output              m_axis_tx_tvalid,
    output [511:0]      m_axis_tx_tdata,
    output [63:0]       m_axis_tx_tkeep,
    output              m_axis_tx_tlast,
    input               m_axis_tx_tready
    );
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
