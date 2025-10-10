`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/08 09:59:37
// Design Name: 
// Module Name: roce_stack
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


module roce_stack(
    input           axis_clk,
    input           axis_rstn,
    
    input           axis_rx_tvalid,
    input [511:0]   axis_rx_tdata,
    input [63:0]    axis_rx_tkeep,
    input           axis_rx_tlast,
    output           axis_rx_tready,
    
    output           axis_tx_tvalid,
    output [511:0]   axis_tx_tdata,
    output [63:0]    axis_tx_tkeep,
    output           axis_tx_tlast,
    input            axis_tx_tready,
    
    input [31:0]    myIp,
    input [47:0]    myMac,
    
    output          regRequestCount_vld,
    output          regReplyCount_vld,
    output [15:0]   regRequestCount,
    output [15:0]   regReplyCount
    );
    // fixed subnet mask
    localparam SubNetMask = 32'd0_255_255_255;
    // Default Gateway
    wire                    default_gateway;
    assign  default_gateway = {8'b1, SubNetMask&myIp};
    // arp wire
    wire                    axis_arp_rx_tvalid;
    wire                    axis_arp_rx_tready;
    wire    [511:0]         axis_arp_rx_tdata;
    wire                    axis_arp_rx_tlast;
    wire    [63:0]          axis_arp_rx_tkeep;
    wire    [63:0]          axis_arp_rx_tstrb;
    // icmp wire
    wire                    axis_icmp_rx_tvalid;
    wire                    axis_icmp_rx_tready;
    wire    [511:0]         axis_icmp_rx_tdata;
    wire                    axis_icmp_rx_tlast;
    wire    [63:0]          axis_icmp_rx_tkeep;
    wire    [63:0]          axis_icmp_rx_tstrb;
    
    wire                    axis_icmp_tx_tvalid;
    wire                    axis_icmp_tx_tready;
    wire    [511:0]         axis_icmp_tx_tdata;
    wire                    axis_icmp_tx_tlast;
    wire    [63:0]          axis_icmp_tx_tkeep;
    wire    [63:0]          axis_icmp_tx_tstrb;
    // roce wire
    wire                    axis_roce_rx_tvalid;
    wire                    axis_roce_rx_tready;
    wire    [511:0]         axis_roce_rx_tdata;
    wire                    axis_roce_rx_tlast;
    wire    [63:0]          axis_roce_rx_tkeep;
    
    // mac encode wire
    wire                    axis_encode_tvalid;
    wire                    axis_encode_tready;
    wire    [511:0]         axis_encode_tdata;
    wire                    axis_encode_tlast;
    wire    [63:0]          axis_encode_tkeep;
    wire    [63:0]          axis_encode_tstrb;
    // arp server wire
    wire                    axis_arp_server_tvalid;
    wire                    axis_arp_server_tready;
    wire    [511:0]         axis_arp_server_tdata;
    wire                    axis_arp_server_tlast;
    wire    [63:0]          axis_arp_server_tkeep;
    wire    [63:0]          axis_arp_server_tstrb;
    
    // PADDING WIRE
    wire                    axis_padding_tvalid;
    wire                    axis_padding_tready;
    wire    [511:0]         axis_padding_tdata;
    wire                    axis_padding_tlast;
    wire    [63:0]          axis_padding_tkeep;
    wire    [63:0]          axis_padding_tstrb;    
 
    // ARP REQUEST WIRE
    wire                    axis_arp_request_tvalid;
    wire                    axis_arp_request_tready;
    wire    [31:0]          axis_arp_request_tdata;
    
    wire                    axis_arp_reply_tvalid;
    wire                    axis_arp_reply_tready;
    wire    [55:0]          axis_arp_reply_tdata;
    
    ip_handler_0 ip_handler_inst(
        .ap_clk(axis_clk),
        .ap_rst_n(axis_rstn),
        .myIpAddress(myIp),
        
        .s_axis_raw_TVALID(axis_rx_tvalid),
        .s_axis_raw_TREADY(axis_rx_tready),
        .s_axis_raw_TDATA(axis_rx_tdata),
        .s_axis_raw_TKEEP(axis_rx_tkeep),
        .s_axis_raw_TSTRB(),
        .s_axis_raw_TLAST(axis_rx_tlast),
        //arp
        .m_axis_arp_TVALID(axis_arp_rx_tvalid),
        .m_axis_arp_TREADY(axis_arp_rx_tready),
        .m_axis_arp_TDATA(axis_arp_rx_tdata),
        .m_axis_arp_TKEEP(axis_arp_rx_tkeep),
        .m_axis_arp_TSTRB(axis_arp_rx_tstrb),
        .m_axis_arp_TLAST(axis_arp_rx_tlast),
        //ICMP
        .m_axis_icmp_TVALID(axis_icmp_rx_tvalid),
        .m_axis_icmp_TREADY(axis_icmp_rx_tready),
        .m_axis_icmp_TDATA(axis_icmp_rx_tdata),
        .m_axis_icmp_TKEEP(axis_icmp_rx_tkeep),
        .m_axis_icmp_TSTRB(axis_icmp_rx_tstrb),
        .m_axis_icmp_TLAST(axis_icmp_rx_tlast),
        // TCP
        .m_axis_tcp_TVALID(),
        .m_axis_tcp_TREADY(1'b1),
        .m_axis_tcp_TDATA(),
        .m_axis_tcp_TKEEP(),
        .m_axis_tcp_TSTRB(),
        .m_axis_tcp_TLAST(),
        //udp
        .m_axis_udp_TVALID(),
        .m_axis_udp_TREADY(1'b1),
        .m_axis_udp_TDATA(),
        .m_axis_udp_TKEEP(),
        .m_axis_udp_TSTRB(),
        .m_axis_udp_TLAST(),
        //ipv6udp
        .m_axis_ipv6udp_TVALID(),
        .m_axis_ipv6udp_TREADY(1'b1),
        .m_axis_ipv6udp_TDATA(),
        .m_axis_ipv6udp_TKEEP(),
        .m_axis_ipv6udp_TSTRB(),
        .m_axis_ipv6udp_TLAST(),
        //icmpv6
        .m_axis_icmpv6_TVALID(),
        .m_axis_icmpv6_TREADY(1'b1),
        .m_axis_icmpv6_TDATA(),
        .m_axis_icmpv6_TKEEP(),
        .m_axis_icmpv6_TSTRB(),
        .m_axis_icmpv6_TLAST(),
        //ROCE
        .m_axis_roce_TVALID(axis_roce_rx_tvalid),
        .m_axis_roce_TREADY(1'b1),
        .m_axis_roce_TDATA(axis_roce_rx_tdata),
        .m_axis_roce_TKEEP(axis_roce_rx_tkeep),
        .m_axis_roce_TSTRB(),
        .m_axis_roce_TLAST(axis_roce_rx_tlast)
    );

    arp_server_subnet_0 arp_server_subnet_inst(
        // axis
        .s_axis_TVALID(axis_arp_rx_tvalid),
        .s_axis_TREADY(axis_arp_rx_tready),
        .s_axis_TDATA(axis_arp_rx_tdata),
        .s_axis_TKEEP(axis_arp_rx_tkeep),
        .s_axis_TSTRB(axis_arp_rx_tstrb),
        .s_axis_TLAST(axis_arp_rx_tlast),
        
        .m_axis_TVALID(axis_arp_server_tvalid),
        .m_axis_TREADY(axis_arp_server_tready),
        .m_axis_TDATA(axis_arp_server_tdata),
        .m_axis_TKEEP(axis_arp_server_tkeep),
        .m_axis_TSTRB(axis_arp_server_tstrb),
        .m_axis_TLAST(axis_arp_server_tlast),
        
        // request
        .s_axis_arp_lookup_request_TVALID(axis_arp_request_tvalid),
        .s_axis_arp_lookup_request_TREADY(axis_arp_request_tready),
        .s_axis_arp_lookup_request_TDATA(axis_arp_request_tdata),
        
        .m_axis_arp_lookup_reply_TVALID(axis_arp_reply_tvalid),
        .m_axis_arp_lookup_reply_TREADY(axis_arp_reply_tready),
        .m_axis_arp_lookup_reply_TDATA(axis_arp_reply_tdata),        
        
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
        .regReplyCount_ap_vld(regReplyCount_vld),
        .regRequestCount(regRequestCount),
        .regReplyCount(regReplyCount)
    );
    // outpadding
   ethernet_frame_padding_512_0   ethernet_frame_padding_512_inst(
        .s_axis_TVALID(axis_arp_server_tvalid),
        .s_axis_TREADY(axis_arp_server_tready),
        .s_axis_TDATA(axis_arp_server_tdata),
        .s_axis_TLAST(axis_arp_server_tlast),
        .s_axis_TKEEP(axis_arp_server_tkeep),
        .s_axis_TSTRB(axis_arp_server_tstrb),
        
        .m_axis_TVALID(axis_padding_tvalid),
        .m_axis_TREADY(axis_padding_tready),
        .m_axis_TDATA(axis_padding_tdata),
        .m_axis_TLAST(axis_padding_tlast),
        .m_axis_TKEEP(axis_padding_tkeep),
        .m_axis_TSTRB(axis_padding_tstrb),
        
        .ap_clk(axis_clk),
        .ap_rst_n(axis_rstn)
   );
    // icmp part
    icmp_server_0 icmp_server_inst(
        .ap_rst_n(axis_rstn),
        .ap_clk(axis_clk),
        
        .s_axis_TVALID(axis_icmp_rx_tvalid),
        .s_axis_TREADY(axis_icmp_rx_tready),
        .s_axis_TDATA(axis_icmp_rx_tdata),
        .s_axis_TKEEP(axis_icmp_rx_tkeep),
        .s_axis_TSTRB(axis_icmp_rx_tstrb),
        .s_axis_TLAST(axis_icmp_rx_tlast),
        // UDPLN
        .udpln_TVALID(),
        .udpln_TREADY(),
        .udpln_TDATA(),
        .udpln_TKEEP(),
        .udpln_TSTRB(),
        .udpln_TLAST(),
        //TTLLN
        .ttlln_TVALID(),
        .ttlln_TREADY(),
        .ttlln_TDATA(),
        .ttlln_TKEEP(),
        .ttlln_TSTRB(),
        .ttlln_TLAST(),
        //OUTPUT
        .m_axis_TVALID(axis_icmp_tx_tvalid),
        .m_axis_TREADY(axis_icmp_tx_tready),
        .m_axis_TDATA(axis_icmp_tx_tdata),
        .m_axis_TKEEP(axis_icmp_tx_tkeep),
        .m_axis_TSTRB(axis_icmp_tx_tstrb),
        .m_axis_TLAST(axis_icmp_tx_tlast)
    );
    
    // mac encode
    mac_ip_encode_0 mac_ip_encode_inst(
        .s_axis_ip_TVALID(axis_icmp_tx_tvalid),
        .s_axis_ip_TREADY(axis_icmp_tx_tready),
        .s_axis_ip_TDATA(axis_icmp_tx_tdata),
        .s_axis_ip_TKEEP(axis_icmp_tx_tkeep),
        .s_axis_ip_TSTRB(axis_icmp_tx_tstrb),
        .s_axis_ip_TLAST(axis_icmp_tx_tlast),

        //OUTPUT DATA
        .m_axis_ip_TVALID(axis_encode_tvalid),
        .m_axis_ip_TREADY(axis_encode_tready),
        .m_axis_ip_TDATA(axis_encode_tdata),
        .m_axis_ip_TKEEP(axis_encode_tkeep),
        .m_axis_ip_TSTRB(axis_encode_tstrb),
        .m_axis_ip_TLAST(axis_encode_tlast),
        //LOOKUP  REPLY
        .s_axis_arp_lookup_reply_TVALID(axis_arp_reply_tvalid),
        .s_axis_arp_lookup_reply_TREADY(axis_arp_reply_tready),
        .s_axis_arp_lookup_reply_TDATA(axis_arp_reply_tdata),
        
        //LOOKUP REQUEST
        .m_axis_arp_lookup_request_TVALID(axis_arp_request_tvalid),
        .m_axis_arp_lookup_request_TREADY(axis_arp_request_tready),
        .m_axis_arp_lookup_request_TDATA(axis_arp_request_tdata),

        //CONFIG
        .myMacAddress(myMac),
        .regSubNetMask(SubNetMask),
        .regDefaultGateway(default_gateway),
        .ap_clk(axis_clk),
        .ap_rst_n(axis_rstn)
    );
       
    // 2 to 1 -> arp & ip
    axis_interconnect_0 axis_interconnect_inst(
        //S00_AXIS -> arp
        .S00_AXIS_TDATA(axis_padding_tdata),
        .S00_AXIS_TKEEP(axis_padding_tkeep),
        .S00_AXIS_TLAST(axis_padding_tlast),
        .S00_AXIS_TREADY(axis_padding_tready), 
        .S00_AXIS_TVALID(axis_padding_tvalid),
        //S01_AXIS -> ip
        .S01_AXIS_TDATA(axis_encode_tdata),
        .S01_AXIS_TKEEP(axis_encode_tkeep),
        .S01_AXIS_TLAST(axis_encode_tlast),
        .S01_AXIS_TREADY(axis_encode_tready), 
        .S01_AXIS_TVALID(axis_encode_tvalid),
        //M00_AXIS
        .M00_AXIS_TDATA(axis_tx_tdata),
        .M00_AXIS_TKEEP(axis_tx_tkeep),
        .M00_AXIS_TLAST(axis_tx_tlast),
        .M00_AXIS_TREADY(axis_tx_tready), 
        .M00_AXIS_TVALID(axis_tx_tvalid),        
        //CONFIG
        .ACLK(axis_clk),
        .ARESTN(axis_rstn),
        .S00_AXIS_ACLK(axis_clk),
        .S01_AXIS_ACLK(axis_clk),
        .S00_AXIS_ARESETN(axis_rstn),
        .S01_AXIS_ARESETN(axis_rstn),
        .M00_AXIS_ACLK(axis_clk),
        .M00_AXIS_ARESTN(axis_rstn),
        .S00_ARB_REQ_SUPPRESS(1'b0),
        .S01_ARB_REQ_SUPPRESS(1'b0)
    );
  
endmodule
