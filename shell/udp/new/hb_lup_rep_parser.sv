`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/07 17:00:15
// Design Name: 
// Module Name: hb_lup_rep_parser
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


module hb_lup_rep_parser(
    input               s_axis_lup_rsp_valid,
    input [119:0]       s_axis_lup_rsp_data,
    output              s_axis_lup_rsp_ready,
    
    output reg          m_axis_lup_result_valid,
    output reg [15:0]   m_axis_lup_addr,
    output reg [63:0]   m_axis_lup_key,
    output reg          m_axis_lup_hit,
    input               m_axis_lup_result_ready,
    
    input               clk,
    input               rst_n
    );
    
    assign s_axis_lup_rsp_ready = m_axis_lup_result_ready;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            m_axis_lup_addr <= '0;
            m_axis_lup_key  <= '0;
            m_axis_lup_hit  <= '0;
            m_axis_lup_result_valid <= 0;
        end
        else begin
            if(m_axis_lup_result_valid && m_axis_lup_result_ready)begin
                m_axis_lup_result_valid <= 0;
            end
            if(s_axis_lup_rsp_valid && s_axis_lup_rsp_ready)begin
                m_axis_lup_addr <= s_axis_lup_rsp_data[79:64];
                m_axis_lup_key  <= s_axis_lup_rsp_data[63:0];
                m_axis_lup_hit  <=  s_axis_lup_rsp_data[80];
                m_axis_lup_result_valid <= 1'b1;
            end
        end
    end
endmodule
