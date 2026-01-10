`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/07 10:31:05
// Design Name: 
// Module Name: hb_upd_controller
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


module hb_upd_controller(
    input                           s_axis_key_valid,
    input  [80:0]                   s_axis_key_data,
    output                          s_axis_key_ready,
    
    output      reg                 m_axis_udp_req_tvalid,
    output      reg   [143:0]       m_axis_udp_req_tdata,
    input                           m_axis_udp_req_tready,
    
    input                           s_axis_udp_res_tvalid,
    input   [143:0]                 s_axis_udp_res_tdata,
    output                          s_axis_udp_res_tready,
    
    output  reg                     m_axis_free_pointer_valid,
    output  reg [15:0]              m_axis_free_pointer,
    input                           m_axis_free_pointer_ready,
    
    output  reg                     m_axis_key_udp_valid,
    output  reg [63:0]              m_axis_key_udp,
    output  reg                     m_axis_key_udp_result,
    input                           m_axis_key_udp_ready,
    
    input                           clk,
    input                           rst_n
);
    
    assign s_axis_udp_res_tready = m_axis_free_pointer_ready & m_axis_key_udp_ready;
    assign s_axis_key_ready = m_axis_udp_req_tready;
    
    logic   [31:0]  opcode;
    logic   [15:0]  value_addr;
    logic   [63:0]  key;
    
    logic           begin_flag;
    assign  begin_flag = s_axis_key_ready & s_axis_key_valid;
    
    assign          opcode = {31'b0, s_axis_key_data[80]};
    assign          value_addr  =  s_axis_key_data[79:64];
    assign          key         =  s_axis_key_data[63:0];
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            m_axis_udp_req_tvalid <= '0;
            m_axis_udp_req_tdata <= '0;
        end
        else begin
            if(m_axis_udp_req_tvalid & m_axis_udp_req_tready)begin
                m_axis_udp_req_tvalid <= 0;
            end
            if(begin_flag)begin
                m_axis_udp_req_tvalid <= 1'b1;
                m_axis_udp_req_tdata <= {32'b0, value_addr, key, opcode};
            end
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            m_axis_free_pointer_valid <= 0;
            m_axis_free_pointer <= '0;
        end
        else begin
            if(m_axis_free_pointer_valid && m_axis_free_pointer_ready)begin
                m_axis_free_pointer_valid <= 0;
            end
            if(s_axis_udp_res_tvalid && s_axis_udp_res_tready)begin
                if(s_axis_udp_res_tdata[31:0] == 1 && s_axis_udp_res_tdata[119:112] == 1)begin
                    m_axis_free_pointer_valid <= 1;
                    m_axis_free_pointer <= s_axis_udp_res_tdata[111:96];
                end
            end
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            m_axis_key_udp_valid <= '0;
            m_axis_key_udp <= '0;
            m_axis_key_udp_result <= '0;          
        end
        else begin
            if(m_axis_key_udp_valid && m_axis_key_udp_ready)begin
                m_axis_key_udp_valid <= 1'b0;
            end
            if(s_axis_udp_res_tvalid && s_axis_udp_res_tready)begin
                m_axis_key_udp_valid <= 1;
                m_axis_key_udp <= s_axis_udp_res_tdata[95:32];//key
                m_axis_key_udp_result <= s_axis_udp_res_tdata[112];// 1 bit success           
            end
        end  
    end

endmodule
