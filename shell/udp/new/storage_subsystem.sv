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
    output [15:0]       m_axis_ram_lenth,
    output [511:0]      m_axis_ram_data,
    input               m_axis_ram_ready,

    input               clk,
    input               rst_n
);

    logic        lup_out_valid;
    logic        lup_out_ready;
    logic [15:0] read_addr;
    logic [63:0] lup_key;
    logic        lup_hit;

    assign m_axis_meta_valid = lup_out_valid;
    assign m_axis_meta_key   = lup_key;
    assign m_axis_meta_hit   = lup_hit;

    logic           ram_porta_rx_valid;
    logic           ram_porta_rx_ready;
    logic [543:0]   ram_porta_data_in;
    logic           ram_porta_read;

    assign ram_porta_read     = 1'b0;
    assign ram_porta_data_in  = '0;
    assign ram_porta_rx_valid = lup_out_valid;
    assign lup_out_ready = m_axis_meta_ready && ram_porta_rx_ready;

    logic        ram_portb_data_out_valid;
    logic [543:0] ram_portb_data_out;
    logic        ram_portb_data_out_ready;
    logic        ram_portb_write;

    assign ram_portb_write          = 1'b1;  
    assign ram_portb_data_out_ready = 1'b1;   
    hb_lup_rep_parser hb_lup_rep_parser_inst (
        .s_axis_lup_rsp_valid    (s_axis_lup_rsp_valid),
        .s_axis_lup_rsp_data     (s_axis_lup_rsp_data),
        .s_axis_lup_rsp_ready    (s_axis_lup_rsp_ready),
        
        .m_axis_lup_result_valid (lup_out_valid),
        .m_axis_lup_addr         (read_addr),
        .m_axis_lup_key          (lup_key),
        .m_axis_lup_hit          (lup_hit),
        .m_axis_lup_result_ready (lup_out_ready),
        
        .clk                     (clk),
        .rst_n                   (rst_n)
    );
    ram ram_inst (
        .clk                (clk),
        .rst_n              (rst_n),
        // A port (read)
        .s_axis_rx_valid_a  (ram_porta_rx_valid),
        .s_axis_rx_data_a   (ram_porta_data_in),
        .s_axis_rx_ready_a  (ram_porta_rx_ready),

        .s_axis_tx_valid_a  (m_axis_ram_valid),
        .s_axis_tx_data_a   ({m_axis_ram_lenth, m_axis_ram_data}),
        .s_axis_tx_ready_a  (m_axis_ram_ready),
        .s_axis_addr_a      (read_addr),
        .read_or_write_a    (ram_porta_read),    // 0: read, 1: write  

        // B port (write)
        .s_axis_rx_valid_b  (s_axis_value_valid),
        .s_axis_rx_data_b   (s_axis_value_data[527:0]),
        .s_axis_rx_ready_b  (s_axis_value_ready),

        .s_axis_tx_valid_b  (ram_portb_data_out_valid),
        .s_axis_tx_data_b   (ram_portb_data_out),
        .s_axis_tx_ready_b  (ram_portb_data_out_ready),
        .s_axis_addr_b      (s_axis_value_data[543:528]), // 16 bit addr
        .read_or_write_b    (ram_portb_write)    // 0: read, 1: write  
    );

endmodule

