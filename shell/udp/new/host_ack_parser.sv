`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/08 17:34:32
// Design Name: 
// Module Name: host_ack_parser
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


module host_ack_parser(
    
    input                               s_axis_key_udp_valid,
    input    [63:0]                     s_axis_key_udp,
    input                               s_axis_key_udp_result,
    output                              s_axis_key_udp_ready,
    
    output   reg                        m_axis_ack_valid,
    input                               m_axis_ack_ready,
    output  reg[511:0]                  m_axis_ack_data,
    output  reg                         m_axis_ack_last,
    output  reg [63:0]                  m_axis_ack_keep,
    output reg  [15:0]                  m_axis_ack_size,
    output reg  [15:0]                  m_axis_ack_src,
    output reg  [15:0]                  m_axis_ack_dst,
    
    input                               clk,
    input                               rst_n                        
    );
    
    
    assign s_axis_key_udp_ready = m_axis_ack_ready;
    always@(posedge clk)begin
        if(!rst_n)begin
            m_axis_ack_valid <= 0;
            m_axis_ack_data <= '0;
            m_axis_ack_last <= '0;
            m_axis_ack_keep <= '0;
            m_axis_ack_size <= '0;
            m_axis_ack_dst  <= '0;
            m_axis_ack_src  <= '0;
        end
        else begin
            if(m_axis_ack_valid && m_axis_ack_ready)begin
               m_axis_ack_valid <= 0;             
            end
            if( s_axis_key_udp_ready && s_axis_key_udp_valid)begin
                m_axis_ack_valid <= 1'b1;
                m_axis_ack_last <= 1'b1;
                m_axis_ack_keep <= 64'h0000_0000_0000_01FF;
                m_axis_ack_size <= 16'd9;
                m_axis_ack_dst <= 16'd0;
                m_axis_ack_src <= 16'h1 << (0 + 6);
                if(s_axis_key_udp_result)begin
                    m_axis_ack_data <= {8'hFF, s_axis_key_udp};
                end 
                else begin
                    m_axis_ack_data <= {8'h00, s_axis_key_udp};
                end
            end
        end 
    end
    
endmodule
