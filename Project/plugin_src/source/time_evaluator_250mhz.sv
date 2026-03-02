`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/22 22:26:58
// Design Name: 
// Module Name: time_evaluator_250mhz
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


module time_evaluator_250mhz(
    input                   clk,
    input                   rst_n,
    
    input                   s_axis_host_input_valid,
    input   [511:0]         s_axis_host_input_data, 
    input                   s_axis_host_input_ready,
    
    input                   m_axis_host_output_valid,
    input                   m_axis_host_output_ready,
    
    output  reg [31:0]      rx_pkt,
    output  reg [31:0]      tx_pkt,
    output  reg [63:0]      running_cnt 
    );
    
    //Rx handshake
    wire rx_handshake = s_axis_host_input_valid && s_axis_host_input_ready;
    
    //Tx handshake
    wire tx_handshake   = m_axis_host_output_valid && m_axis_host_output_ready;
    
    //match head segments
    wire tx_match = (m_axis_host_ouput_data[31:16] == 16'h0000) &&
                    (m_axis_host_ouput_data[15:0]  == 16'hFFFF);
                    
    wire tx_cnt_begin = tx_handshake && tx_match;
    
    reg [63:0] pending_cnt;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            rx_pkt      <= 32'd0;
            tx_pkt      <= 32'd0;
            running_cnt <= 64'd0;
            pending_cnt <= 64'd0;
        end
        else begin
            if(rx_handshake)begin
               rx_pkt <= rx_pkt + 32'd1; 
            end
            if(tx_cnt_begin)begin
                tx_pkt <= tx_pkt + 32'd1;
            end
            case ({rx_handshake, tx_cnt_begin})
                2'b10: pending_cnt <= pending_cnt + 64'd1;
                2'b01: pending_cnt <= (pending_cnt != 64'd0) ? (pending_cnt - 64'd1) : 64'd0; 
                default: pending_cnt <= pending_cnt; 
            endcase
            
            begin : RUNNING_ACC
                reg [63:0] next_pending;
                next_pending = pending_cnt;
                case ({rx_handshake, tx_cnt_begin})
                    2'b10: next_pending = pending_cnt + 64'd1;
                    2'b01: next_pending = (pending_cnt != 64'd0) ? (pending_cnt - 64'd1) : 64'd0;
                    default: next_pending = pending_cnt;
                endcase

                if (next_pending != 64'd0)
                    running_cnt <= running_cnt + 64'd1; 
            end
        end
    end
    
    
    
    
    
    
    
    
    
    
endmodule
