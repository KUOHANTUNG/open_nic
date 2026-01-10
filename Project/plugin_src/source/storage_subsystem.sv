`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/11/07 17:11:14
// Design Name:
// Module Name: storage_subsystem
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

module storage_subsystem(
    input               s_axis_lup_rsp_valid,
    input  [119:0]      s_axis_lup_rsp_data,
    output              s_axis_lup_rsp_ready, 

    input               s_axis_value_valid,
    input  [543:0]      s_axis_value_data,
    output              s_axis_value_ready,

    output logic        m_axis_meta_valid,
    output logic [63:0] m_axis_meta_key,
    output logic        m_axis_meta_hit,
    input               m_axis_meta_ready,

    output              m_axis_ram_valid,
    output [527:0]      m_axis_ram_data_and_length,
    input               m_axis_ram_ready,

    input               clk,
    input               rst_n
);
    
    logic           lup_addr_valid;
    logic  [15:0]   lup_addr_data ;
    logic           lup_addr_ready;

    
    // -----------------------------
    // Lookup response parser
    // -----------------------------
    hb_lup_rep_parser hb_lup_rep_parser_inst (
        .s_axis_lup_rsp_valid    (s_axis_lup_rsp_valid),
        .s_axis_lup_rsp_data     (s_axis_lup_rsp_data),
        .s_axis_lup_rsp_ready    (s_axis_lup_rsp_ready),

        .m_axis_lup_result_valid (m_axis_meta_valid),
        .m_axis_lup_key          (m_axis_meta_key),
        .m_axis_lup_hit          (m_axis_meta_hit),
        .m_axis_lup_result_ready (m_axis_meta_ready),
        
        .m_axis_lup_addr_valid(lup_addr_valid),
        .m_axis_lup_addr_data (lup_addr_data), 
        .m_axis_lup_addr_ready(lup_addr_ready),
        
        
        .clk                     (clk),
        .rst_n                    (rst_n)
    );

    // -----------------------------
    // RAM instance
    // -----------------------------
    bram_storage bram_storage_inst (
        .clk                (clk),
        .rst_n              (rst_n),

        // A port (read)
        .s_axis_rx_valid_a  (lup_addr_valid),
        .s_axis_addr_a      (lup_addr_data),
        .s_axis_rx_ready_a  (lup_addr_ready),

        .s_axis_tx_valid_a  (m_axis_ram_valid),
        .s_axis_tx_data_a   (m_axis_ram_data_and_length),
        .s_axis_tx_ready_a  (m_axis_ram_ready),

        // B port (write)
        .s_axis_rx_valid_b  (s_axis_value_valid),
        .s_axis_rx_data_b   (s_axis_value_data),//address & length + data
        .s_axis_rx_ready_b  (s_axis_value_ready)
    );

endmodule