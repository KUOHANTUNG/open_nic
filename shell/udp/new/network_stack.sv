`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 13:55:17
// Design Name: 
// Module Name: network_stack
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


module network_stack(
    input               axis_clk,
    input               axis_rstn,
    
    input               s_axis_rx_tvalid,
    input [511:0]       s_axis_rx_tdata,
    input [63:0]        s_axis_rx_tkeep,
    input               s_axis_rx_tlast,
    output              s_axis_rx_tready,
    
    output              m_axis_tx_tvalid,
    output [511:0]      m_axis_tx_tdata,
    output [63:0]       m_axis_tx_tkeep,
    output              m_axis_tx_tlast,
    input               m_axis_tx_tready,
    
        //meta & data
    output              m_axis_rx_udp_meta_tvalid,
    output   [175:0]    m_axis_rx_udp_meta_tdata,
    input               m_axis_rx_udp_meta_tready,
    
    input               s_axis_tx_udp_meta_tvalid,
    input    [175:0]    s_axis_tx_udp_meta_tdata,
    output              s_axis_tx_udp_meta_tready,
    
    output              m_axis_rx_udp_data_tvalid,
    output   [511:0]    m_axis_rx_udp_data_tdata,
    output   [63:0]     m_axis_rx_udp_data_tkeep,
    output              m_axis_rx_udp_data_tlast,
    input               m_axis_rx_udp_data_tready,
    
    input               s_axis_tx_udp_data_tvalid,
    input   [511:0]     s_axis_tx_udp_data_tdata,
    input   [63:0]      s_axis_tx_udp_data_tkeep,
    input               s_axis_tx_udp_data_tlast,
    output              s_axis_tx_udp_data_tready,
    
    output              regRequestCount_vld,
    output              regReplyCount_vld, 
    output  [15:0]      regRequestCount,   
    output  [15:0]      regReplyCount,      
    
    
//    output  [31:0]       icmp_rx_pkg_counter_sta,
//    output  [31:0]       icmp_tx_pkg_counter_sta,
//    output  [31:0]       udp_rx_pkg_counter_sta,
//    output  [31:0]       udp_tx_pkg_counter_sta,
    
    
    input   [31:0]      myIp,
    input   [47:0]      myMac,
    input   [15:0]      listen_port 
    );
    
    wire                  axis_rx_tvalid ;
    wire    [511:0]       axis_rx_tdata  ;
    wire    [63:0]        axis_rx_tkeep  ;
    wire                  axis_rx_tlast  ;
    wire                  axis_rx_tready ;
//--------------------------------------------------------------------------------------------------    
    // arp wire
    wire                    axis_iph_to_arp_slice_tvalid;
    wire                    axis_iph_to_arp_slice_tready;
    wire    [511:0]         axis_iph_to_arp_slice_tdata;
    wire                    axis_iph_to_arp_slice_tlast;
    wire    [63:0]          axis_iph_to_arp_slice_tkeep; 
    
    // arp server wire
    wire                    axis_arp_slice_to_arp_server_tvalid;
    wire                    axis_arp_slice_to_arp_server_tready;
    wire    [511:0]         axis_arp_slice_to_arp_server_tdata;
    wire                    axis_arp_slice_to_arp_server_tlast;
    wire    [63:0]          axis_arp_slice_to_arp_server_tkeep; 
    
    wire                    axis_arp_server_to_arp_slice_tvalid;
    wire                    axis_arp_server_to_arp_slice_tready;
    wire    [511:0]         axis_arp_server_to_arp_slice_tdata;
    wire                    axis_arp_server_to_arp_slice_tlast;
    wire    [63:0]          axis_arp_server_to_arp_slice_tkeep; 
    
    wire                    axis_arp_slice_to_interconncet_tvalid;
    wire                    axis_arp_slice_to_interconncet_tready;
    wire    [511:0]         axis_arp_slice_to_interconncet_tdata;
    wire                    axis_arp_slice_to_interconncet_tlast;
    wire    [63:0]          axis_arp_slice_to_interconncet_tkeep; 
    
    
    // arp lookup wire
    wire                    axis_arp_lookup_request_tvalid;
    wire                    axis_arp_lookup_request_tready;
    wire    [31:0]          axis_arp_lookup_request_tdata;
    
    wire                    axis_arp_lookup_reply_tvalid;
    wire                    axis_arp_lookup_reply_tready;
    wire    [55:0]          axis_arp_lookup_reply_tdata;
//------------------------------------------------------------------------------------    
    // icmp
    wire                    axis_iph_to_icmp_slice_tvalid;
    wire                    axis_iph_to_icmp_slice_tready;
    wire    [511:0]         axis_iph_to_icmp_slice_tdata;
    wire                    axis_iph_to_icmp_slice_tlast;
    wire    [63:0]          axis_iph_to_icmp_slice_tkeep; 
    
    wire                    axis_icmp_slice_to_icmp_converter_tvalid;
    wire                    axis_icmp_slice_to_icmp_converter_tready;
    wire    [511:0]         axis_icmp_slice_to_icmp_converter_tdata;
    wire                    axis_icmp_slice_to_icmp_converter_tlast;
    wire    [63:0]          axis_icmp_slice_to_icmp_converter_tkeep; 
    
    wire                    axis_icmp_converter_to_icmp_server_tvalid;
    wire                    axis_icmp_converter_to_icmp_server_tready;
    wire    [511:0]         axis_icmp_converter_to_icmp_server_tdata;
    wire                    axis_icmp_converter_to_icmp_server_tlast;
    wire    [63:0]          axis_icmp_converter_to_icmp_server_tkeep; 
    
    wire                    axis_icmp_server_to_icmp_converter_tvalid;
    wire                    axis_icmp_server_to_icmp_converter_tready;
    wire    [511:0]         axis_icmp_server_to_icmp_converter_tdata;
    wire                    axis_icmp_server_to_icmp_converter_tlast;
    wire    [63:0]          axis_icmp_server_to_icmp_converter_tkeep; 
    
    wire                    axis_icmp_converter_to_out_tvalid;
    wire                    axis_icmp_converter_to_out_tready;
    wire    [511:0]         axis_icmp_converter_to_out_tdata;
    wire                    axis_icmp_converter_to_out_tlast;
    wire    [63:0]          axis_icmp_converter_to_out_tkeep; 
//---------------------------------------------------------------------------------
//UDP
    wire                    axis_iph_to_udp_slice_tvalid;
    wire                    axis_iph_to_udp_slice_tready;
    wire    [511:0]         axis_iph_to_udp_slice_tdata;
    wire                    axis_iph_to_udp_slice_tlast;
    wire    [63:0]          axis_iph_to_udp_slice_tkeep; 
    
    wire                    axis_udp_slice_to_udp_stack_tvalid;
    wire                    axis_udp_slice_to_udp_stack_tready;
    wire    [511:0]         axis_udp_slice_to_udp_stack_tdata;
    wire                    axis_udp_slice_to_udp_stack_tlast;
    wire    [63:0]          axis_udp_slice_to_udp_stack_tkeep;
    
    wire                    axis_udp_stack_to_udp_slice_tvalid;
    wire                    axis_udp_stack_to_udp_slice_tready;
    wire    [511:0]         axis_udp_stack_to_udp_slice_tdata;
    wire                    axis_udp_stack_to_udp_slice_tlast;
    wire    [63:0]          axis_udp_stack_to_udp_slice_tkeep;
    
    wire                    axis_udp_slice_to_interconnect_tvalid;
    wire                    axis_udp_slice_to_interconnect_tready;
    wire    [511:0]         axis_udp_slice_to_interconnect_tdata;
    wire                    axis_udp_slice_to_interconnect_tlast;
    wire    [63:0]          axis_udp_slice_to_interconnect_tkeep; 

//---------------------------------------------------------------------------------------------
//mac encode 
    wire                    axis_interconnect_to_mac_slice_tvalid;
    wire                    axis_interconnect_to_mac_slice_tready;
    wire    [511:0]         axis_interconnect_to_mac_slice_tdata;
    wire                    axis_interconnect_to_mac_slice_tlast;
    wire    [63:0]          axis_interconnect_to_mac_slice_tkeep; 
    
    wire                    axis_mac_slice_to_mac_tvalid;
    wire                    axis_mac_slice_to_mac_tready;
    wire    [511:0]         axis_mac_slice_to_mac_tdata;
    wire                    axis_mac_slice_to_mac_tlast;
    wire    [63:0]          axis_mac_slice_to_mac_tkeep; 

    wire                    axis_mac_to_mac_slice_tvalid;
    wire                    axis_mac_to_mac_slice_tready;
    wire    [511:0]         axis_mac_to_mac_slice_tdata;
    wire                    axis_mac_to_mac_slice_tlast;
    wire    [63:0]          axis_mac_to_mac_slice_tkeep; 
   
    wire                    axis_mac_slice_to_interconnect_tvalid;
    wire                    axis_mac_slice_to_interconnect_tready;
    wire    [511:0]         axis_mac_slice_to_interconnect_tdata;
    wire                    axis_mac_slice_to_interconnect_tlast;
    wire    [63:0]          axis_mac_slice_to_interconnect_tkeep; 
//---------------------------------------------------------------------------------------- 
    // fixed subnet mask
    parameter IP_SUBNET_MASK = 32'h00FFFFFF;
    // Default Gateway
    wire [31:0]   ip_subnet_mask;
    wire [31:0]   ip_default_gateway;
    assign ip_subnet_mask = IP_SUBNET_MASK;
    assign ip_default_gateway = {8'h01,myIp[23:0]};
    
    
//    always @(posedge axis_clk)
//    begin
//        if (!axis_rstn) begin
//            ip_subnet_mask <= 32'h00000000;
//            ip_default_gateway <= 32'h00000000;
//        end
//        else begin
//            ip_subnet_mask <= IP_SUBNET_MASK;
//            ip_default_gateway <= {myIp[31:28], 8'h01, myIp[23:0]};
//        end
//    end   
   
   
   
   
//--------------------------------------------------------------------------------   
   axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_1_inst (
      .s_axis_tvalid (s_axis_rx_tvalid),
      .s_axis_tdata  (s_axis_rx_tdata),
      .s_axis_tkeep  (s_axis_rx_tkeep),
      .s_axis_tlast  (s_axis_rx_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (s_axis_rx_tready),

      .m_axis_tvalid (axis_rx_tvalid),
      .m_axis_tdata  (axis_rx_tdata ),
      .m_axis_tkeep  (axis_rx_tkeep ),
      .m_axis_tlast  (axis_rx_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_rx_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_icmp_inst (
      .s_axis_tvalid (axis_iph_to_icmp_slice_tvalid),
      .s_axis_tdata  (axis_iph_to_icmp_slice_tdata),
      .s_axis_tkeep  (axis_iph_to_icmp_slice_tkeep),
      .s_axis_tlast  (axis_iph_to_icmp_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_iph_to_icmp_slice_tready),

      .m_axis_tvalid (axis_icmp_slice_to_icmp_converter_tvalid),
      .m_axis_tdata  (axis_icmp_slice_to_icmp_converter_tdata ),
      .m_axis_tkeep  (axis_icmp_slice_to_icmp_converter_tkeep ),
      .m_axis_tlast  (axis_icmp_slice_to_icmp_converter_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_icmp_slice_to_icmp_converter_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    
    
    
    // ip handler
    ip_handler_ip ip_handler_inst(
        .ap_clk(axis_clk),
        .ap_rst_n(axis_rstn),
        .myIpAddress(myIp),
        
        .s_axis_raw_TVALID(axis_rx_tvalid),
        .s_axis_raw_TREADY(axis_rx_tready),
        .s_axis_raw_TDATA(axis_rx_tdata),
        .s_axis_raw_TKEEP(axis_rx_tkeep),
        .s_axis_raw_TLAST(axis_rx_tlast),
        //arp
        .m_axis_arp_TVALID(axis_iph_to_arp_slice_tvalid),
        .m_axis_arp_TREADY(axis_iph_to_arp_slice_tready),
        .m_axis_arp_TDATA(axis_iph_to_arp_slice_tdata),
        .m_axis_arp_TKEEP(axis_iph_to_arp_slice_tkeep),
        .m_axis_arp_TLAST(axis_iph_to_arp_slice_tlast),
        //ICMP
        .m_axis_icmp_TVALID(axis_iph_to_icmp_slice_tvalid),
        .m_axis_icmp_TREADY(axis_iph_to_icmp_slice_tready),
        .m_axis_icmp_TDATA(axis_iph_to_icmp_slice_tdata),
        .m_axis_icmp_TKEEP(axis_iph_to_icmp_slice_tkeep),
        .m_axis_icmp_TLAST(axis_iph_to_icmp_slice_tlast),
        // TCP
        .m_axis_tcp_TVALID(),
        .m_axis_tcp_TREADY(1'b1),
        .m_axis_tcp_TDATA(),
        .m_axis_tcp_TKEEP(),
        .m_axis_tcp_TLAST(),
        //udp
        .m_axis_udp_TVALID(axis_iph_to_udp_slice_tvalid),
        .m_axis_udp_TREADY(axis_iph_to_udp_slice_tready),
        .m_axis_udp_TDATA(axis_iph_to_udp_slice_tdata),
        .m_axis_udp_TKEEP(axis_iph_to_udp_slice_tkeep),
        .m_axis_udp_TLAST(axis_iph_to_udp_slice_tlast),
        //ipv6udp
        .m_axis_ipv6udp_TVALID(),
        .m_axis_ipv6udp_TREADY(1'b1),
        .m_axis_ipv6udp_TDATA(),
        .m_axis_ipv6udp_TKEEP(),
        .m_axis_ipv6udp_TLAST(),
        //icmpv6
        .m_axis_icmpv6_TVALID(),
        .m_axis_icmpv6_TREADY(1'b1),
        .m_axis_icmpv6_TDATA(),
        .m_axis_icmpv6_TKEEP(),
        .m_axis_icmpv6_TLAST(),
        //ROCE
        .m_axis_roce_TVALID(),
        .m_axis_roce_TREADY(1'b1),
        .m_axis_roce_TDATA(),
        .m_axis_roce_TKEEP(),
        .m_axis_roce_TLAST()
    ); 
    
    
/*--------------------------------------------------------------------------------------------------
ARP server
----------------------------------------------------------------------------------------------------*/       
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_arp_inst (
      .s_axis_tvalid (axis_iph_to_arp_slice_tvalid),
      .s_axis_tdata  (axis_iph_to_arp_slice_tdata),
      .s_axis_tkeep  (axis_iph_to_arp_slice_tkeep),
      .s_axis_tlast  (axis_iph_to_arp_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_iph_to_arp_slice_tready),

      .m_axis_tvalid (axis_arp_slice_to_arp_server_tvalid),
      .m_axis_tdata  (axis_arp_slice_to_arp_server_tdata ),
      .m_axis_tkeep  (axis_arp_slice_to_arp_server_tkeep ),
      .m_axis_tlast  (axis_arp_slice_to_arp_server_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_arp_slice_to_arp_server_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    
   
   // ARP SERVER
    arp_server_subnet_ip arp_server_subnet_inst(
        // axis
        .s_axis_TVALID(axis_arp_slice_to_arp_server_tvalid),
        .s_axis_TREADY(axis_arp_slice_to_arp_server_tready),
        .s_axis_TDATA(axis_arp_slice_to_arp_server_tdata),
        .s_axis_TKEEP(axis_arp_slice_to_arp_server_tkeep),
        .s_axis_TLAST(axis_arp_slice_to_arp_server_tlast),
        
        .m_axis_TVALID(axis_arp_server_to_arp_slice_tvalid),
        .m_axis_TREADY(axis_arp_server_to_arp_slice_tready),
        .m_axis_TDATA (axis_arp_server_to_arp_slice_tdata),
        .m_axis_TKEEP (axis_arp_server_to_arp_slice_tkeep),
        .m_axis_TLAST (axis_arp_server_to_arp_slice_tlast),
        
        // request
        .s_axis_arp_lookup_request_TVALID(axis_arp_lookup_request_tvalid),
        .s_axis_arp_lookup_request_TREADY(axis_arp_lookup_request_tready),
        .s_axis_arp_lookup_request_TDATA (axis_arp_lookup_request_tdata),
        
        .m_axis_arp_lookup_reply_TVALID(axis_arp_lookup_reply_tvalid),
        .m_axis_arp_lookup_reply_TREADY(axis_arp_lookup_reply_tready),
        .m_axis_arp_lookup_reply_TDATA (axis_arp_lookup_reply_tdata),        
        
        //host request
        .s_axis_host_arp_lookup_request_TVALID(1'b0),
        .s_axis_host_arp_lookup_request_TREADY(),
        .s_axis_host_arp_lookup_request_TDATA(32'b0),
                
        .m_axis_host_arp_lookup_reply_TVALID(),
        .m_axis_host_arp_lookup_reply_TREADY(1'b1),
        .m_axis_host_arp_lookup_reply_TDATA(), 
        
        //config
        .ap_clk(axis_clk),
        .ap_rst_n(axis_rstn),
        
        .myMacAddress(myMac),
        .myIpAddress(myIp),
        .regRequestCount_ap_vld(regRequestCount_vld),
        .regReplyCount_ap_vld  (regReplyCount_vld),
        .regRequestCount       (regRequestCount),
        .regReplyCount         (regReplyCount)
    );
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_arp_inst (
      .s_axis_tvalid (axis_arp_server_to_arp_slice_tvalid),
      .s_axis_tdata  (axis_arp_server_to_arp_slice_tdata),
      .s_axis_tkeep  (axis_arp_server_to_arp_slice_tkeep),
      .s_axis_tlast  (axis_arp_server_to_arp_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_arp_server_to_arp_slice_tready),

      .m_axis_tvalid (axis_arp_slice_to_interconncet_tvalid),
      .m_axis_tdata  (axis_arp_slice_to_interconncet_tdata ),
      .m_axis_tkeep  (axis_arp_slice_to_interconncet_tkeep ),
      .m_axis_tlast  (axis_arp_slice_to_interconncet_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_arp_slice_to_interconncet_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );    
    
    
    
/*---------------------------------------------------------------------------------------------------
ICMP
--------------------------------------------------------------------------------------------*/
    // icmp converter 512 to 64
    axis_dwidth_converter_512_64 icmp_in_data_converter (
        .aclk(axis_clk),
        .aresetn(axis_rstn),
        .s_axis_tvalid(axis_icmp_slice_to_icmp_converter_tvalid),
        .s_axis_tready(axis_icmp_slice_to_icmp_converter_tready),
        .s_axis_tdata(axis_icmp_slice_to_icmp_converter_tdata),
        .s_axis_tkeep(axis_icmp_slice_to_icmp_converter_tkeep),
        .s_axis_tlast(axis_icmp_slice_to_icmp_converter_tlast),
        
        .m_axis_tvalid(axis_icmp_converter_to_icmp_server_tvalid),
        .m_axis_tready(axis_icmp_converter_to_icmp_server_tready),
        .m_axis_tdata(axis_icmp_converter_to_icmp_server_tdata),
        .m_axis_tkeep(axis_icmp_converter_to_icmp_server_tkeep),
        .m_axis_tlast(axis_icmp_converter_to_icmp_server_tlast)
    );
    
    icmp_server_ip icmp_server_inst (
        .s_axis_TVALID(axis_icmp_converter_to_icmp_server_tvalid), 
        .s_axis_TREADY(axis_icmp_converter_to_icmp_server_tready), 
        .s_axis_TDATA(axis_icmp_converter_to_icmp_server_tdata),   
        .s_axis_TKEEP(axis_icmp_converter_to_icmp_server_tkeep),   
        .s_axis_TLAST(axis_icmp_converter_to_icmp_server_tlast),   
        .udpIn_TVALID(1'b0),
        .udpIn_TREADY(),           
        .udpIn_TDATA(0),    
        .udpIn_TKEEP(0),    
        .udpIn_TLAST(0),     
        .ttlIn_TVALID(1'b0),
        .ttlIn_TREADY(),           
        .ttlIn_TDATA(0),   
        .ttlIn_TKEEP(0),   
        .ttlIn_TLAST(0),   
        .m_axis_TVALID(axis_icmp_server_to_icmp_converter_tvalid), 
        .m_axis_TREADY(axis_icmp_server_to_icmp_converter_tready), 
        .m_axis_TDATA(axis_icmp_server_to_icmp_converter_tdata),   
        .m_axis_TKEEP(axis_icmp_server_to_icmp_converter_tkeep),   
        .m_axis_TLAST(axis_icmp_server_to_icmp_converter_tlast),   
        .ap_clk(axis_clk),                                  
        .ap_rst_n(axis_rstn)                            
    );    
    
    axis_dwidth_converter_64_512 icmp_out_data_converter (
        .aclk(axis_clk),
        .aresetn(axis_rstn),
        .s_axis_tvalid(axis_icmp_server_to_icmp_converter_tvalid),
        .s_axis_tready(axis_icmp_server_to_icmp_converter_tready),
        .s_axis_tdata(axis_icmp_server_to_icmp_converter_tdata),
        .s_axis_tkeep(axis_icmp_server_to_icmp_converter_tkeep),
        .s_axis_tlast(axis_icmp_server_to_icmp_converter_tlast),
        
        .m_axis_tvalid(axis_icmp_converter_to_out_tvalid),
        .m_axis_tready(axis_icmp_converter_to_out_tready),
        .m_axis_tdata(axis_icmp_converter_to_out_tdata),
        .m_axis_tkeep(axis_icmp_converter_to_out_tkeep),
        .m_axis_tlast(axis_icmp_converter_to_out_tlast)
    );
/*--------------------------------------------------------------------------------------------------------
UDP part
------------------------------------------------------------------------------------*/
   axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_in_inst (
      .s_axis_tvalid (axis_iph_to_udp_slice_tvalid),
      .s_axis_tdata  (axis_iph_to_udp_slice_tdata),
      .s_axis_tkeep  (axis_iph_to_udp_slice_tkeep),
      .s_axis_tlast  (axis_iph_to_udp_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_iph_to_udp_slice_tready),

      .m_axis_tvalid (axis_udp_slice_to_udp_stack_tvalid),
      .m_axis_tdata  (axis_udp_slice_to_udp_stack_tdata ),
      .m_axis_tkeep  (axis_udp_slice_to_udp_stack_tkeep ),
      .m_axis_tlast  (axis_udp_slice_to_udp_stack_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_udp_slice_to_udp_stack_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    
  
    udp_stack udp_stack_inst(
        .axis_clk            (axis_clk)   ,                 
        .axis_rstn           (axis_rstn)  ,                
                                  
        .s_axis_rx_tvalid    (axis_udp_slice_to_udp_stack_tvalid),         
        .s_axis_rx_tdata     (axis_udp_slice_to_udp_stack_tdata),          
        .s_axis_rx_tkeep     (axis_udp_slice_to_udp_stack_tkeep),          
        .s_axis_rx_tlast     (axis_udp_slice_to_udp_stack_tlast),          
        .s_axis_rx_tready    (axis_udp_slice_to_udp_stack_tready),         
                                  
        .m_axis_tx_tvalid(axis_udp_stack_to_udp_slice_tvalid)   ,         
        .m_axis_tx_tdata (axis_udp_stack_to_udp_slice_tdata)   ,          
        .m_axis_tx_tkeep (axis_udp_stack_to_udp_slice_tkeep)   ,          
        .m_axis_tx_tlast (axis_udp_stack_to_udp_slice_tlast)   ,          
        .m_axis_tx_tready(axis_udp_stack_to_udp_slice_tready)   ,         
                                  
        .local_ip_address(myIp),         
        .listen_port(listen_port),              
                                                                
        .m_axis_rx_udp_meta_tvalid(m_axis_rx_udp_meta_tvalid),
        .m_axis_rx_udp_meta_tdata (m_axis_rx_udp_meta_tdata), 
        .m_axis_rx_udp_meta_tready(m_axis_rx_udp_meta_tready),
                                  
        .s_axis_tx_udp_meta_tvalid(s_axis_tx_udp_meta_tvalid),
        .s_axis_tx_udp_meta_tdata (s_axis_tx_udp_meta_tdata), 
        .s_axis_tx_udp_meta_tready(s_axis_tx_udp_meta_tready),
                                  
        .m_axis_rx_udp_data_tvalid(m_axis_rx_udp_data_tvalid),
        .m_axis_rx_udp_data_tdata (m_axis_rx_udp_data_tdata), 
        .m_axis_rx_udp_data_tkeep (m_axis_rx_udp_data_tkeep), 
        .m_axis_rx_udp_data_tlast (m_axis_rx_udp_data_tlast), 
        .m_axis_rx_udp_data_tready(m_axis_rx_udp_data_tready),
                                  
        .s_axis_tx_udp_data_tvalid(s_axis_tx_udp_data_tvalid),
        .s_axis_tx_udp_data_tdata (s_axis_tx_udp_data_tdata), 
        .s_axis_tx_udp_data_tkeep (s_axis_tx_udp_data_tkeep), 
        .s_axis_tx_udp_data_tlast (s_axis_tx_udp_data_tlast), 
        .s_axis_tx_udp_data_tready(s_axis_tx_udp_data_tready) 
    );
    
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_out_inst (
      .s_axis_tvalid (axis_udp_stack_to_udp_slice_tvalid),
      .s_axis_tdata  (axis_udp_stack_to_udp_slice_tdata),
      .s_axis_tkeep  (axis_udp_stack_to_udp_slice_tkeep),
      .s_axis_tlast  (axis_udp_stack_to_udp_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_udp_stack_to_udp_slice_tready),

      .m_axis_tvalid (axis_udp_slice_to_interconnect_tvalid),
      .m_axis_tdata  (axis_udp_slice_to_interconnect_tdata ),
      .m_axis_tkeep  (axis_udp_slice_to_interconnect_tkeep ),
      .m_axis_tlast  (axis_udp_slice_to_interconnect_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_udp_slice_to_interconnect_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    
/*------------------------------------------------------------------------------------------------------  
interconnect 
--------------------------------------------------------------------------*/ 
    axis_interconnect_512_2to1 axis_interconnect_512_2_1_inst(
       .ACLK(axis_clk),                  
       .ARESETN(axis_rstn),          
       .S00_AXIS_ACLK(axis_clk),         
       .S01_AXIS_ACLK(axis_clk),                 
       .S00_AXIS_ARESETN(axis_rstn), 
       .S01_AXIS_ARESETN(axis_rstn), 
       
       .S00_AXIS_TVALID(axis_icmp_converter_to_out_tvalid), 
       .S00_AXIS_TREADY(axis_icmp_converter_to_out_tready), 
       .S00_AXIS_TDATA(axis_icmp_converter_to_out_tdata),   
       .S00_AXIS_TKEEP(axis_icmp_converter_to_out_tkeep),   
       .S00_AXIS_TLAST(axis_icmp_converter_to_out_tlast),
       
       
       .S01_AXIS_TVALID(axis_udp_slice_to_interconnect_tvalid),
       .S01_AXIS_TREADY(axis_udp_slice_to_interconnect_tready),
       .S01_AXIS_TDATA(axis_udp_slice_to_interconnect_tdata),  
       .S01_AXIS_TKEEP(axis_udp_slice_to_interconnect_tkeep),  
       .S01_AXIS_TLAST(axis_udp_slice_to_interconnect_tlast),     
       
       .M00_AXIS_ACLK(axis_clk),    
       .M00_AXIS_ARESETN(axis_rstn),
       .M00_AXIS_TVALID(axis_interconnect_to_mac_slice_tvalid),          
       .M00_AXIS_TREADY(axis_interconnect_to_mac_slice_tready),          
       .M00_AXIS_TDATA(axis_interconnect_to_mac_slice_tdata),           
       .M00_AXIS_TKEEP(axis_interconnect_to_mac_slice_tkeep),           
       .M00_AXIS_TLAST(axis_interconnect_to_mac_slice_tlast),           
       .S00_ARB_REQ_SUPPRESS(1'b0), 
       .S01_ARB_REQ_SUPPRESS(1'b0)
    );
    
/*--------------------------------------------------------------------------------------------

mac ip encode

--------------------------------------------------------------------------------------------*/   
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) map_in_inst (
      .s_axis_tvalid (axis_interconnect_to_mac_slice_tvalid),
      .s_axis_tdata  (axis_interconnect_to_mac_slice_tdata),
      .s_axis_tkeep  (axis_interconnect_to_mac_slice_tkeep),
      .s_axis_tlast  (axis_interconnect_to_mac_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_interconnect_to_mac_slice_tready),

      .m_axis_tvalid (axis_mac_slice_to_mac_tvalid),
      .m_axis_tdata  (axis_mac_slice_to_mac_tdata ),
      .m_axis_tkeep  (axis_mac_slice_to_mac_tkeep ),
      .m_axis_tlast  (axis_mac_slice_to_mac_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_mac_slice_to_mac_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );

    // MAC IP ENCODE
     mac_ip mac_ip_encode_inst(
        .s_axis_ip_TVALID(axis_mac_slice_to_mac_tvalid),
        .s_axis_ip_TREADY(axis_mac_slice_to_mac_tready),
        .s_axis_ip_TDATA(axis_mac_slice_to_mac_tdata),
        .s_axis_ip_TKEEP(axis_mac_slice_to_mac_tkeep),
        .s_axis_ip_TLAST(axis_mac_slice_to_mac_tlast),

        //OUTPUT DATA
        .m_axis_ip_TVALID(axis_mac_to_mac_slice_tvalid),
        .m_axis_ip_TREADY(axis_mac_to_mac_slice_tready),
        .m_axis_ip_TDATA(axis_mac_to_mac_slice_tdata),
        .m_axis_ip_TKEEP(axis_mac_to_mac_slice_tkeep),
        .m_axis_ip_TLAST(axis_mac_to_mac_slice_tlast),
        //LOOKUP  REPLY
        .s_axis_arp_lookup_reply_TVALID(axis_arp_lookup_reply_tvalid),
        .s_axis_arp_lookup_reply_TREADY(axis_arp_lookup_reply_tready),
        .s_axis_arp_lookup_reply_TDATA (axis_arp_lookup_reply_tdata),
        
        //LOOKUP REQUEST
        .m_axis_arp_lookup_request_TVALID(axis_arp_lookup_request_tvalid),
        .m_axis_arp_lookup_request_TREADY(axis_arp_lookup_request_tready),
        .m_axis_arp_lookup_request_TDATA (axis_arp_lookup_request_tdata),

        //CONFIG
        .myMacAddress(myMac),
        .regSubNetMask(ip_subnet_mask),
        .regDefaultGateway(ip_default_gateway),
        .ap_clk(axis_clk),
        .ap_rst_n(axis_rstn)
    );
    
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) map_out_inst (
      .s_axis_tvalid (axis_mac_to_mac_slice_tvalid),
      .s_axis_tdata  (axis_mac_to_mac_slice_tdata),
      .s_axis_tkeep  (axis_mac_to_mac_slice_tkeep),
      .s_axis_tlast  (axis_mac_to_mac_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_mac_to_mac_slice_tready),

      .m_axis_tvalid (axis_mac_slice_to_interconnect_tvalid),
      .m_axis_tdata  (axis_mac_slice_to_interconnect_tdata ),
      .m_axis_tkeep  (axis_mac_slice_to_interconnect_tkeep ),
      .m_axis_tlast  (axis_mac_slice_to_interconnect_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_mac_slice_to_interconnect_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );   
/*-------------------------------------------------------------------------------------------------------
2-1 interconnect
--------------------------------------------------------------------------------------------------------*/    
  axis_interconnect_512_2to1 mac_merger (
    .ACLK(axis_clk), 
    .ARESETN(axis_rstn), 
    .S00_AXIS_ACLK(axis_clk), 
    .S01_AXIS_ACLK(axis_clk), 
    .S00_AXIS_ARESETN(axis_rstn), 
    .S01_AXIS_ARESETN(axis_rstn), 
    
    .S00_AXIS_TVALID(axis_mac_slice_to_interconnect_tvalid),
    .S00_AXIS_TREADY(axis_mac_slice_to_interconnect_tready),
    .S00_AXIS_TDATA(axis_mac_slice_to_interconnect_tdata), 
    .S00_AXIS_TKEEP(axis_mac_slice_to_interconnect_tkeep), 
    .S00_AXIS_TLAST(axis_mac_slice_to_interconnect_tlast), 

    .S01_AXIS_TVALID(axis_arp_slice_to_interconncet_tvalid), 
    .S01_AXIS_TREADY(axis_arp_slice_to_interconncet_tready), 
    .S01_AXIS_TDATA(axis_arp_slice_to_interconncet_tdata), 
    .S01_AXIS_TKEEP(axis_arp_slice_to_interconncet_tkeep), 
    .S01_AXIS_TLAST(axis_arp_slice_to_interconncet_tlast), 


    .M00_AXIS_ACLK(axis_clk),
    .M00_AXIS_ARESETN(axis_rstn), 
    .M00_AXIS_TVALID(m_axis_tx_tvalid), 
    .M00_AXIS_TREADY(m_axis_tx_tready), 
    .M00_AXIS_TDATA(m_axis_tx_tdata),
    .M00_AXIS_TKEEP(m_axis_tx_tkeep),
    .M00_AXIS_TLAST(m_axis_tx_tlast),
    .S00_ARB_REQ_SUPPRESS(1'b0), 
    .S01_ARB_REQ_SUPPRESS(1'b0) 
 ); 
 /*--------------------------------------------------------------------------------
 stats
 ----------------------------------------------------------------------------*/ 
//    reg[31:0] rx_word_counter; 
//    reg[31:0] rx_pkg_counter; 
//    reg[31:0] tx_word_counter; 
//    reg[31:0] tx_pkg_counter; 
    
//    reg[31:0] icmp_rx_pkg_counter;
//    reg[31:0] icmp_tx_pkg_counter;
//    reg[31:0] udp_rx_pkg_counter;
//    reg[31:0] udp_tx_pkg_counter;
    
//    assign icmp_rx_pkg_counter_sta = icmp_rx_pkg_counter;
//    assign icmp_tx_pkg_counter_sta = icmp_tx_pkg_counter;
//    assign udp_rx_pkg_counter_sta =  udp_rx_pkg_counter;
//    assign udp_tx_pkg_counter_sta =  udp_tx_pkg_counter;
//    always@(posedge axis_clk)begin
//        if(!axis_rstn)begin
//            rx_word_counter <= '0;
//            rx_pkg_counter <= '0;
//            tx_word_counter <= '0;
//            tx_pkg_counter <= '0;

//            icmp_rx_pkg_counter <= 0;
//            icmp_tx_pkg_counter <= 0;
//            udp_rx_pkg_counter <= '0;
//            udp_tx_pkg_counter <= '0;
//        end
//        //Icmp
//        if(axis_icmp_converter_to_icmp_server_tvalid && axis_icmp_converter_to_icmp_server_tready)begin
//            if(axis_icmp_converter_to_icmp_server_tlast)begin
//                icmp_rx_pkg_counter <= icmp_rx_pkg_counter+1;
//            end 
//        end
//        if(axis_icmp_server_to_icmp_converter_tvalid && axis_icmp_server_to_icmp_converter_tready)begin
//            if(axis_icmp_server_to_icmp_converter_tlast)begin
//                icmp_tx_pkg_counter <= icmp_tx_pkg_counter + 1; 
//            end
//        end
//        //UDP
//        if(axis_udp_slice_to_udp_stack_tvalid && axis_udp_slice_to_udp_stack_tready)begin
//            if(axis_udp_slice_to_udp_stack_tlast)begin
//                udp_rx_pkg_counter <= udp_rx_pkg_counter + 1;
//            end        
//        end
//        if(axis_udp_stack_to_udp_slice_tvalid && axis_udp_stack_to_udp_slice_tready)begin
//            if(axis_udp_stack_to_udp_slice_tlast)begin
//                udp_tx_pkg_counter <= udp_tx_pkg_counter + 1;
//            end
//        end
//    end
endmodule
