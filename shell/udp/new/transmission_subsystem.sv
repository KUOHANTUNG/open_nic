`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/08 18:36:53
// Design Name: 
// Module Name: transmission_subsystem
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


module transmission_subsystem(
    
    input               clk,
    input               rst_n,
    // PPER TO CARD
    input               s_axis_peer_card_valid,
    input [511:0]       s_axis_peer_card_data,
    input [63:0]        s_axis_peer_card_keep,
    input               s_axis_peer_card_last,
    output              s_axis_peer_card_ready,
    
    // CARD TO PEER
    output              m_axis_card_peer_valid,
    output [511:0]      m_axis_card_peer_data,
    output [63:0]       m_axis_card_peer_keep,
    output [15:0]       m_axis_card_peer_src,
    output [15:0]       m_axis_card_peer_size,
    output [15:0]       m_axis_card_peer_dst,
    output              m_axis_card_peer_last,
    input               m_axis_card_peer_ready,
    
    //HOST TO CARD
    input               s_axis_host_card_valid,
    input [511:0]       s_axis_host_card_data,
    input [63:0]        s_axis_host_card_keep,
    input               s_axis_host_card_last,
    output              s_axis_host_card_ready,
    
    //CARD TO HOST
    output              m_axis_card_host_valid,
    output [511:0]      m_axis_card_host_data,
    output [63:0]       m_axis_card_host_keep,
    output [15:0]       m_axis_card_host_src,
    output [15:0]       m_axis_card_host_size,
    output [15:0]       m_axis_card_host_dst,
    output              m_axis_card_host_last,
    input               m_axis_card_host_ready,
    
    // ouput to hash table subsystem
    output              m_axis_peer_request_key_valid,
    output [63:0]       m_axis_peer_request_key_data,
    input               m_axis_peer_request_key_ready,
    
    // input from storage subsystem
    input                s_axis_meta_valid,     
    input [63:0]         s_axis_meta_key,       
    input                s_axis_meta_hit,       
    output               s_axis_meta_ready,     
                         
    input                s_axis_ram_valid,      
    input  [15:0]        s_axis_ram_lenth,      
    input  [511:0]       s_axis_ram_data,       
    output               s_axis_ram_ready,     
    
    // free request from hb subsystem
    
    input [15:0]        s_free_pointer,
    input               s_free_pointer_valid,
    output              s_free_pointer_ready,
    
    output  [80:0]      m_host_store_key_data,
    output              m_host_store_key_valid,
    input               m_host_store_key_ready,
    
    output  [543:0]     m_host_store_value_data,
    output              m_host_store_value_valid,
    input               m_host_store_value_ready,
    
    // update feedback for hb system
    input               s_axis_key_udp_valid,
    input    [63:0]     s_axis_key_udp,
    input               s_axis_key_udp_result,
    output              s_axis_key_udp_ready

    );
    
    logic               peer_request_key_valid;
    logic [63:0]        peer_request_key_data;
    logic               peer_request_key_ready;
    
    logic [80:0]        store_key_data;
    logic               store_key_valid;
    logic               store_key_ready;

    logic [543:0]       store_value_data;
    logic               store_value_valid;
    logic               store_value_ready; 
    
    
    request_parser #(
        .DATA_WIDTH(512),
        .META_WIDTH(96)
    )request_parser_peer(
        .clk(clk),                   
        .rst_n(rst_n),                                    
        .s_axis_tdata(s_axis_peer_card_data),          
        .s_axis_tvalid(s_axis_peer_card_valid),         
        .s_axis_tlast(s_axis_peer_card_last),                 
        .s_axis_tkeep(s_axis_peer_card_keep),             
        .s_axis_tready(s_axis_peer_card_ready),            
                         
        .m_key_data(peer_request_key_data),            
        .m_key_valid(peer_request_key_valid),              
        .m_key_ready(peer_request_key_ready),              
                          
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
    
    fifo #(
        .DATA_WIDTH(64),
        .FIFO_DEPTH(8)  
    ) fifo_peer_request (
        .axis_clk     (clk),     
        .axis_rstn    (rst_n),                       
        .s_axis_valid (peer_request_key_valid), 
        .s_axis_data  (peer_request_key_data),  
        .s_axis_ready (peer_request_key_ready),       
        .m_axis_valid (m_axis_peer_request_key_valid), 
        .m_axis_data  (m_axis_peer_request_key_data),  
        .m_axis_ready (m_axis_peer_request_key_ready)    
    );
    
    
    lkp_rep_parser lkp_rep_parser_inst(
                 .clk(clk),                   
                 .rst_n(rst_n),                 
                                        
                 .s_axis_meta_valid(s_axis_meta_valid),     
                 .s_axis_meta_key(s_axis_meta_key),       
                 .s_axis_meta_hit(s_axis_meta_hit),       
                 .s_axis_meta_ready(s_axis_meta_ready),     
                                        
                 .s_axis_ram_valid(s_axis_ram_valid),      
                 .s_axis_ram_lenth(s_axis_ram_lenth),      
                 .s_axis_ram_data(s_axis_ram_data),       
                 .s_axis_ram_ready(s_axis_ram_ready),      
                                        
                 .m_axis_tx_tvalid(m_axis_card_peer_valid),      
                 .m_axis_tx_tdata(m_axis_card_peer_data),       
                 .m_axis_tx_tkeep(m_axis_card_peer_keep),       
                 .m_axis_tx_tlast(m_axis_card_peer_last), 
                 .m_axis_tx_size(m_axis_card_peer_size),
                 .m_axis_tx_src(m_axis_card_peer_src), 
                 .m_axis_tx_dst(m_axis_card_peer_dst),       
                 .m_axis_tx_tready(m_axis_card_peer_ready) 
                          
    );
    
    host_ack_parser host_ack_parser_inst(
                .s_axis_key_udp_valid(s_axis_key_udp_valid),     
                .s_axis_key_udp(s_axis_key_udp),           
                .s_axis_key_udp_result(s_axis_key_udp_result),    
                .s_axis_key_udp_ready(s_axis_key_udp_ready),     
                                          
                .m_axis_ack_valid(m_axis_card_host_valid),         
                .m_axis_ack_ready(m_axis_card_host_ready),         
                .m_axis_ack_data(m_axis_card_host_data),  
                .m_axis_ack_size(m_axis_card_host_size),
                .m_axis_ack_src(m_axis_card_host_src), 
                .m_axis_ack_dst(m_axis_card_host_dst),                       
                .m_axis_ack_last(m_axis_card_host_last),          
                .m_axis_ack_keep(m_axis_card_host_keep),          
                                          
                .clk(clk),                      
                .rst_n(rst_n)                       
    );
    
    front_end_transit front_end_transit_inst(
            .clk(clk),                    
            .rst_n(rst_n),                  
            .s_axis_tdata(s_axis_host_card_data),           
            .s_axis_tvalid(s_axis_host_card_valid),          
            .s_axis_tlast(s_axis_host_card_last),           
            .s_axis_tkeep(s_axis_host_card_keep),           
            .s_axis_tready(s_axis_host_card_ready),          
                                    
            .m_value_data(store_value_data),           
            .m_value_valid(store_value_valid),          
            .m_value_ready(store_value_ready),          
                                    
            .s_free_pointer(s_free_pointer),         
            .s_free_pointer_valid(s_free_pointer_valid),   
            .s_free_pointer_ready(s_free_pointer_ready),   
                                    
            .m_key_data(store_key_data),             
            .m_key_valid(store_key_valid),            
            .m_key_ready(store_key_ready)             
    
    );
    
    fifo #(
        .DATA_WIDTH(544),
        .FIFO_DEPTH(8)  
    ) fifo_store_value (
        .axis_clk     (clk),     
        .axis_rstn    (rst_n),                       
        .s_axis_valid (store_value_valid), 
        .s_axis_data  (store_value_data),  
        .s_axis_ready (store_value_ready),       
        .m_axis_valid (m_host_store_value_valid), 
        .m_axis_data  (m_host_store_value_data),  
        .m_axis_ready (m_host_store_value_ready)    
    );
    
    fifo #(
        .DATA_WIDTH(81),
        .FIFO_DEPTH(8)  
    ) fifo_store_key (
        .axis_clk     (clk),     
        .axis_rstn    (rst_n),                       
        .s_axis_valid (store_key_valid), 
        .s_axis_data  (store_key_data),  
        .s_axis_ready (store_key_ready),       
        .m_axis_valid (m_host_store_key_valid), 
        .m_axis_data  (m_host_store_key_data),  
        .m_axis_ready (m_host_store_key_ready)    
    );
    
endmodule
