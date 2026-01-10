`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/08 20:21:01
// Design Name: 
// Module Name: hashtable_subsystem
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
module hashtable_subsystem(
    
    input           clk,
    input           rst_n,
    
    input           s_axis_peer_request_key_valid,
    input [63:0]    s_axis_peer_request_key_data,
    output          s_axis_peer_request_key_ready,
    
    output          m_axis_peer_request_lup_rep_valid,
    output [119:0]  m_axis_peer_request_lup_rep_data,
    input           m_axis_peer_request_lup_rep_ready,
    
    output [15:0]   m_free_pointer_data,
    output          m_free_pointer_valid,
    input           m_free_pointer_ready,
    
    input  [80:0]   s_host_store_key_data,
    input           s_host_store_key_valid,    
    output          s_host_store_key_ready,
    
    output          m_axis_key_udp_valid,
    output [63:0]   m_axis_key_udp,
    output          m_axis_key_udp_result,
    input           m_axis_key_udp_ready
    );
    
    logic                udp_req_tvalid;
    logic  [143:0]       udp_req_tdata;
    logic                udp_req_tready;
   
    logic                udp_res_tvalid;
    logic  [143:0]       udp_res_tdata;
    logic                udp_res_tready;             
    
    logic                lup_res_valid;
    logic  [119:0]       lup_res_data;
    logic                lup_res_ready;
    
    hash_table_ip  hash_table_ip_inst(
        // s_axis_lup_req
        .s_axis_lup_req_TVALID(s_axis_peer_request_key_valid),
        .s_axis_lup_req_TREADY(s_axis_peer_request_key_ready),
        .s_axis_lup_req_TDATA({32'h0,s_axis_peer_request_key_data}),//[95:0]
        //s_axis_upd_req
        .s_axis_upd_req_TVALID(udp_req_tvalid),
        .s_axis_upd_req_TREADY(udp_req_tready),
        .s_axis_upd_req_TDATA(udp_req_tdata),//[143:0]
        //
        .ap_clk(clk),
        .ap_rst_n(rst_n),
        //m_axis_lup_req
        .m_axis_lup_rsp_TVALID(lup_res_valid),
        .m_axis_lup_rsp_TREADY(lup_res_ready),
        .m_axis_lup_rsp_TDATA(lup_res_data),//[119:0]
        //m_axis_upd_req
        .m_axis_upd_rsp_TVALID(udp_res_tvalid),
        .m_axis_upd_rsp_TREADY(udp_res_tready),
        .m_axis_upd_rsp_TDATA(udp_res_tdata)//[143:0]
        //
   );
    
    hb_upd_controller hb_upd_controller_inst(
        .s_axis_key_valid(s_host_store_key_valid),             
        .s_axis_key_data(s_host_store_key_data),              
        .s_axis_key_ready(s_host_store_key_ready),             
                                      
        .m_axis_udp_req_tvalid(udp_req_tvalid),        
        .m_axis_udp_req_tdata(udp_req_tdata),         
        .m_axis_udp_req_tready(udp_req_tready),        
                                      
        .s_axis_udp_res_tvalid(udp_res_tvalid),        
        .s_axis_udp_res_tdata(udp_res_tdata),         
        .s_axis_udp_res_tready(udp_res_tready),        
                                      
        .m_axis_free_pointer_valid(m_free_pointer_valid),    
        .m_axis_free_pointer(m_free_pointer_data),          
        .m_axis_free_pointer_ready(m_free_pointer_ready),    
                                      
        .m_axis_key_udp_valid(m_axis_key_udp_valid),         
        .m_axis_key_udp(m_axis_key_udp),               
        .m_axis_key_udp_result(m_axis_key_udp_result),        
        .m_axis_key_udp_ready(m_axis_key_udp_ready),         
                                      
        .clk(clk),                          
        .rst_n(rst_n)                         
    );
    fifo #(
        .DATA_WIDTH(120),
        .FIFO_DEPTH(8)  
    ) fifo_lup_rsp (
        .axis_clk     (clk),     
        .axis_rstn    (rst_n),                       
        .s_axis_valid (lup_res_valid), 
        .s_axis_data  (lup_res_data),  
        .s_axis_ready (lup_res_ready),       
        .m_axis_valid (m_axis_peer_request_lup_rep_valid), 
        .m_axis_data  (m_axis_peer_request_lup_rep_data),  
        .m_axis_ready (m_axis_peer_request_lup_rep_ready)    
    );
     
endmodule
