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
        input              axis_clk,
        input              axis_rstn,
    
        input              s_axis_adapter_card_tvalid,
        input  [511:0]     s_axis_adapter_card_tdata,
        input   [63:0]     s_axis_adapter_card_tkeep,
        input              s_axis_adapter_card_tlast,
        input   [15:0]     s_axis_adapter_card_tuser_size,
        input   [15:0]     s_axis_adapter_card_tuser_src,
        input   [15:0]     s_axis_adapter_card_tuser_dst,
        output             s_axis_adapter_card_tready,
        
        output             m_axis_card_adapter_tvalid,
        output [511:0]     m_axis_card_adapter_tdata,
        output  [63:0]     m_axis_card_adapter_tkeep,
        output             m_axis_card_adapter_tlast,
        output  [15:0]     m_axis_card_adapter_tuser_size,
        output  [15:0]     m_axis_card_adapter_tuser_src,
        output  [15:0]     m_axis_card_adapter_tuser_dst,
        input              m_axis_card_adapter_tready,
        
        input              s_axis_host_card_tvalid,
        input  [511:0]     s_axis_host_card_tdata,
        input   [63:0]     s_axis_host_card_tkeep,
        input              s_axis_host_card_tlast,
        input   [15:0]     s_axis_host_card_tuser_size,
        input   [15:0]     s_axis_host_card_tuser_src,
        input   [15:0]     s_axis_host_card_tuser_dst,
        output             s_axis_host_card_tready,
        
        output             m_axis_card_host_tvalid,
        output [511:0]     m_axis_card_host_tdata,
        output  [63:0]     m_axis_card_host_tkeep,
        output             m_axis_card_host_tlast,
        output  [15:0]     m_axis_card_host_tuser_size,
        output  [15:0]     m_axis_card_host_tuser_src,
        output  [15:0]     m_axis_card_host_tuser_dst,
        input              m_axis_card_host_tready
        
    );
    
    logic           peer_request_key_valid;
    logic [63:0]    peer_request_key_data;
    logic           peer_request_key_ready;  
    
    logic           peer_request_lup_rep_valid;
    logic [119:0]   peer_request_lup_rep_data;
    logic           peer_request_lup_rep_ready;
    
    logic           meta_valid;     
    logic[63:0]     meta_key;       
    logic           meta_hit;       
    logic           meta_ready;    
    
    logic           ram_valid;      
    logic [15:0]    ram_lenth;      
    logic [511:0]   ram_data;       
    logic           ram_ready; 
    
    logic[15:0]    free_pointer;
    logic          free_pointer_valid;
    logic          free_pointer_ready;
    
    logic  [80:0]  host_store_key_data;
    logic          host_store_key_valid;
    logic          host_store_key_ready;

    logic  [543:0] host_store_value_data;
    logic          host_store_value_valid;
    logic          host_store_value_ready;


    logic          key_udp_valid;
    logic   [63:0] key_udp;
    logic          key_udp_result;
    logic          key_udp_ready;
    
         
    transmission_subsystem transmission_subsystem_inst(
     .clk(axis_clk),
     .rst_n(axis_rstn),
     
     .s_axis_peer_card_valid(s_axis_adapter_card_tvalid),
     .s_axis_peer_card_data(s_axis_adapter_card_tdata),
     .s_axis_peer_card_keep(s_axis_adapter_card_tkeep),
     .s_axis_peer_card_last(s_axis_adapter_card_tlast),
     .s_axis_peer_card_ready(s_axis_adapter_card_tready),
     
     .m_axis_card_peer_valid(m_axis_card_adapter_tvalid),
     .m_axis_card_peer_data(m_axis_card_adapter_tdata),
     .m_axis_card_peer_keep(m_axis_card_adapter_tkeep),
     .m_axis_card_peer_last(m_axis_card_adapter_tlast),
     .m_axis_card_peer_src(m_axis_card_adapter_tuser_src),  
     .m_axis_card_peer_size(m_axis_card_adapter_tuser_size), 
     .m_axis_card_peer_dst(m_axis_card_adapter_tuser_dst),  
     .m_axis_card_peer_ready(m_axis_card_adapter_tready),
     
     .s_axis_host_card_valid(s_axis_host_card_tvalid),
     .s_axis_host_card_data(s_axis_host_card_tdata),
     .s_axis_host_card_keep(s_axis_host_card_tkeep),
     .s_axis_host_card_last(s_axis_host_card_tlast),
     .s_axis_host_card_ready(s_axis_host_card_tready),
     
     .m_axis_card_host_valid(m_axis_card_host_tvalid),  
     .m_axis_card_host_data(m_axis_card_host_tdata),   
     .m_axis_card_host_keep(m_axis_card_host_tkeep),   
     .m_axis_card_host_src(m_axis_card_host_tuser_src),    
     .m_axis_card_host_size(m_axis_card_host_tuser_size),   
     .m_axis_card_host_dst(m_axis_card_host_tuser_dst),    
     .m_axis_card_host_last(m_axis_card_host_tlast),   
     .m_axis_card_host_ready(m_axis_card_host_tready),  
     
     .m_axis_peer_request_key_valid(peer_request_key_valid),
     .m_axis_peer_request_key_data(peer_request_key_data),
     .m_axis_peer_request_key_ready(peer_request_key_ready),   
      
     .s_axis_meta_valid(meta_valid),     
     .s_axis_meta_key(meta_key),       
     .s_axis_meta_hit(meta_hit),       
     .s_axis_meta_ready(meta_ready),     
     
     .s_axis_ram_valid(ram_valid),      
     .s_axis_ram_lenth(ram_lenth),      
     .s_axis_ram_data(ram_data),       
     .s_axis_ram_ready(ram_ready),   
          
     .s_free_pointer(free_pointer),
     .s_free_pointer_valid(free_pointer_valid),
     .s_free_pointer_ready(free_pointer_ready),  
     
     .m_host_store_key_data(host_store_key_data),
     .m_host_store_key_valid(host_store_key_valid),
     .m_host_store_key_ready(host_store_key_ready), 
     
     .m_host_store_value_data(host_store_value_data),
     .m_host_store_value_valid(host_store_value_valid),
     .m_host_store_value_ready(host_store_value_ready),
     
     .s_axis_key_udp_valid(key_udp_valid),
     .s_axis_key_udp(key_udp),
     .s_axis_key_udp_result(key_udp_result),
     .s_axis_key_udp_ready(key_udp_ready)
    
    );
    hashtable_subsystem hashtable_subsystem_inst(
      .clk(axis_clk),                                  
      .rst_n(axis_rstn),                                
                                            
      .s_axis_peer_request_key_valid(peer_request_key_valid),        
      .s_axis_peer_request_key_data(peer_request_key_data),         
      .s_axis_peer_request_key_ready(peer_request_key_ready),        
                                            
      .m_axis_peer_request_lup_rep_valid(peer_request_lup_rep_valid),    
      .m_axis_peer_request_lup_rep_data(peer_request_lup_rep_data),     
      .m_axis_peer_request_lup_rep_ready(peer_request_lup_rep_ready),    
                                            
      .m_free_pointer_data(free_pointer),                  
      .m_free_pointer_valid(free_pointer_valid),                 
      .m_free_pointer_ready(free_pointer_ready),                 
                                            
      .s_host_store_key_data(host_store_key_data),                
      .s_host_store_key_valid(host_store_key_valid),               
      .s_host_store_key_ready(host_store_key_ready),               
                                            
      .m_axis_key_udp_valid(key_udp_valid),                 
      .m_axis_key_udp(key_udp),                       
      .m_axis_key_udp_result(key_udp_result),                
      .m_axis_key_udp_ready(key_udp_ready)                  
    );
    
    storage_subsystem storage_subsystem_inst(
         .s_axis_lup_rsp_valid(peer_request_lup_rep_valid),       
         .s_axis_lup_rsp_data(peer_request_lup_rep_data),        
         .s_axis_lup_rsp_ready(peer_request_lup_rep_ready),       
                                     
         .s_axis_value_valid(host_store_value_valid),         
         .s_axis_value_data(host_store_value_data),          
         .s_axis_value_ready(host_store_value_ready),         
                                     
         .m_axis_meta_valid(meta_valid),          
         .m_axis_meta_key(meta_key),            
         .m_axis_meta_hit(meta_hit),            
         .m_axis_meta_ready(meta_ready),          
                                     
         .m_axis_ram_valid(ram_valid),           
         .m_axis_ram_lenth(ram_lenth),           
         .m_axis_ram_data(ram_data),            
         .m_axis_ram_ready(ram_ready),           
                                     
         .clk(axis_clk),                        
         .rst_n(axis_rstn)                       
    );
    
    
endmodule
