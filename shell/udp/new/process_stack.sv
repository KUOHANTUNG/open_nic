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
    
    input               s_axis_host_rx_tvalid,
    input [511:0]       s_axis_host_rx_tdata,
    input [63:0]        s_axis_host_rx_tkeep,
    input               s_axis_host_rx_tlast,
    output              s_axis_host_rx_tready,
                              
    output              m_axis_host_tx_tvalid,
    output [511:0]      m_axis_host_tx_tdata,
    output [63:0]       m_axis_host_tx_tkeep,
    output              m_axis_host_tx_tlast,
    input               m_axis_host_tx_tready,
    
    input               s_axis_card_rx_tvalid,
    input [511:0]       s_axis_card_rx_tdata,
    input [63:0]        s_axis_card_rx_tkeep,
    input               s_axis_card_rx_tlast,
    output              s_axis_card_rx_tready,
                               
    output              m_axis_card_tx_tvalid,
    output [511:0]      m_axis_card_tx_tdata,
    output [63:0]       m_axis_card_tx_tkeep,
    output              m_axis_card_tx_tlast,
    input               m_axis_card_tx_tready
    );
    
    // CARD PARSER -> CAHCE
    //KEY
    logic         card_parser_to_cache_valid;
    logic[63:0]   card_parser_to_cache_key;
    logic         card_parser_to_cache_ready;
    request_parser #(
        .DATA_WIDTH(512),
        .META_WIDTH(96)
   )request_parser_card(
        .clk(axis_clk),                   
        .rst_n(axis_rstn),                                    
        .s_axis_tdata(s_axis_card_rx_tdata),          
        .s_axis_tvalid(s_axis_card_rx_tvalid),         
        .s_axis_tlast(s_axis_card_rx_tlast),                 
        .s_axis_tkeep(s_axis_card_rx_tkeep),             
        .s_axis_tready(s_axis_card_rx_tready),            
                         
        .m_key_data(card_parser_to_cache_key),            
        .m_key_valid(card_parser_to_cache_valid),              
        .m_key_ready(card_parser_to_cache_ready),              
                          
        .m_meta_data(),           
        .m_meta_valid(),          
        .m_meta_ready(1'b1),          
                          
        .m_value_data(),       
        .m_value_valid(),         
        .m_value_length(),        
        .m_value_last(),          
        .m_value_ready(1'b1),         
                          
        .m_malloc_data(),         
        .m_malloc_valid(),        
        .m_malloc_ready(1'b1)      
   ) ;     
   hash_table_ip  hash_table_ip_inst(
            // s_axis_lup_req
        .s_axis_lup_req_TVALID(card_parser_to_cache_valid),
        .s_axis_lup_req_TREADY(card_parser_to_cache_ready),
        .s_axis_lup_req_TDATA({32'h0,card_parser_to_cache_key}),//[95:0]
        //s_axis_upd_req
        .s_axis_upd_req_TVALID(),
        .s_axis_upd_req_TREADY(),
        .s_axis_upd_req_TDATA(),//[143:0]
        //
        .ap_clk(clk),
        .ap_rst_n(rst_n),
        //m_axis_lup_req
        .m_axis_lup_rsp_TVALID(),
        .m_axis_lup_rsp_TREADY(),
        .m_axis_lup_rsp_TDATA(),//[119:0]
        //m_axis_upd_req
        .m_axis_upd_rsp_TVALID(),
        .m_axis_upd_rsp_TREADY(),
        .m_axis_upd_rsp_TDATA()//[143:0]
        //
   );
    
    
   request_parser #(
    .DATA_WIDTH(512),
    .META_WIDTH(96)
   )request_parser_host(
        .clk(axis_clk),                   
        .rst_n(axis_rstn),                 
                          
        .s_axis_tdata(s_axis_host_rx_tdata),          
        .s_axis_tvalid(s_axis_host_rx_tvalid),         
        .s_axis_tlast(s_axis_host_rx_tlast),                 
        .s_axis_tkeep(s_axis_host_rx_tkeep),             
        .s_axis_tready(s_axis_host_rx_tready),            
                          
        .m_key_data(),            
        .m_key_valid(),              
        .m_key_ready(),              
                          
        .m_meta_data(),           
        .m_meta_valid(),          
        .m_meta_ready(1'b1),          
                          
        .m_value_data(),       
        .m_value_valid(),         
        .m_value_length(),        
        .m_value_last(),          
        .m_value_ready(),         
                          
        .m_malloc_data(),         
        .m_malloc_valid(),        
        .m_malloc_ready()      
   ) ;
   


    // CARD cache control
    
    
    
    
    
    
    
    
    
endmodule
