`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/17 00:13:53
// Design Name: 
// Module Name: box_322_register
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


module box_322_register(
     // AXI-Lite slave
  input                 s_axil_awvalid,
  input  [31:0]         s_axil_awaddr,
  output                s_axil_awready,
  input                 s_axil_wvalid,
  input  [31:0]         s_axil_wdata,
  output                s_axil_wready,
  output                s_axil_bvalid,
  output  [1:0]         s_axil_bresp,
  input                 s_axil_bready,
  input                 s_axil_arvalid,
  input  [31:0]         s_axil_araddr,
  output                s_axil_arready,
  output                s_axil_rvalid,
  output [31:0]         s_axil_rdata,
  output  [1:0]         s_axil_rresp,
  input                 s_axil_rready,
      
  output   [31:0]       myIp,
  output   [47:0]       myMac,
  output   [15:0]       listen_port,
    
  input                 regRequestCount_vld,
  input                 regReplyCount_vld,
  input     [15:0]      regRequestCount,
  input     [15:0]      regReplyCount, 
    
//  input    [31:0]       icmp_rx_pkg_counter_sta,
//  input    [31:0]       icmp_tx_pkg_counter_sta,
//  input    [31:0]       udp_rx_pkg_counter_sta,
//  input    [31:0]       udp_tx_pkg_counter_sta,  
    
    
  input                 axil_aclk,
  input                 axil_aresetn
    );

  localparam C_ADDR_W = 12;
  // Address map
  localparam LOCAL_IP_W_0          = 12'h000;
  localparam LOCAL_IP_R_0          = 12'h004;
  localparam LOCAL_MAC_UPPER_W_0   = 12'h008; 
  localparam LOCAL_MAC_LOWER_W_0   = 12'h00C; 
  localparam LOCAL_MAC_UPPER_R_0   = 12'h010;
  localparam LOCAL_MAC_LOWER_R_0   = 12'h014;
  localparam LISTEN_PORT_W         = 12'h018;
  localparam LISTEN_PORT_R         = 12'h01C;
  localparam ARP_REQUEST_VAL_0     = 12'h020;
  localparam ARP_REPLY_VAL_0       = 12'h024;
  localparam ARP_REQUEST_CNT_0     = 12'h028;
  localparam ARP_REPLY_CNT_0       = 12'h02C; 
  localparam ICMP_RX_PKG           = 12'h030; 
  localparam ICMP_TX_PKG           = 12'h034;
  localparam UDP_RX_PKG            = 12'h038;
  localparam UDP_TX_PKG            = 12'h03C;
  
  wire                reg_en;
  wire                reg_we;
  wire [C_ADDR_W-1:0] reg_addr;
  wire         [31:0] reg_din;
  reg          [31:0] reg_dout;
  
  
  reg   [31:0]  reg_local_ip;
  reg   [47:0]  reg_local_mac;
  reg   [15:0]  reg_listen_port;
  
  assign myIp = reg_local_ip;
  assign myMac  = reg_local_mac;
  assign listen_port = reg_listen_port;
  axi_lite_register #(
    .CLOCKING_MODE ("common_clock"),
    .ADDR_W        (C_ADDR_W),
    .DATA_W        (32)
  ) axil_reg_inst (
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awaddr  (s_axil_awaddr),
    .s_axil_awready (s_axil_awready),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wready  (s_axil_wready),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bready  (s_axil_bready),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_araddr  (s_axil_araddr),
    .s_axil_arready (s_axil_arready),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),
    .s_axil_rready  (s_axil_rready),

    .reg_en         (reg_en),
    .reg_we         (reg_we),
    .reg_addr       (reg_addr),
    .reg_din        (reg_din),
    .reg_dout       (reg_dout),

    .axil_aclk      (axil_aclk),
    .axil_aresetn   (axil_aresetn),
    .reg_clk        (axil_aclk),
    .reg_rstn       (axil_aresetn)
  );

  // write register
  always @(posedge axil_aclk) begin
    if (~axil_aresetn) begin
      reg_local_ip          <= 32'h0000_0000;
      reg_local_mac         <= 48'h0000_0000_0000;
      reg_listen_port       <= 16'h0000;
    end else if (reg_en && reg_we) begin
      case (reg_addr)
        LOCAL_IP_W_0:   reg_local_ip          <= reg_din;          
        LOCAL_MAC_LOWER_W_0: reg_local_mac[47:16]   <= reg_din;
        LOCAL_MAC_UPPER_W_0: reg_local_mac[15:0]    <= reg_din[15:0]; // mask
        LISTEN_PORT_W: reg_listen_port <=  reg_din[15:0];
        default: ;
      endcase
    end
  end

  // read register
  always @(posedge axil_aclk) begin
    if (~axil_aresetn) begin
      reg_dout <= 32'h0;
    end else if (reg_en && ~reg_we) begin
      case (reg_addr)
        LOCAL_IP_R_0:        reg_dout <= reg_local_ip[31:0];
        LOCAL_MAC_LOWER_R_0: reg_dout <= reg_local_mac[47:16];
        LOCAL_MAC_UPPER_R_0: reg_dout <= reg_local_mac[15:0];
        LISTEN_PORT_R:       reg_dout <= reg_listen_port;
        ARP_REQUEST_VAL_0:   reg_dout <= {31'd0, regRequestCount_vld};
        ARP_REPLY_VAL_0:     reg_dout <= {31'd0, regReplyCount_vld};
        ARP_REQUEST_CNT_0:   reg_dout <= {16'd0, regRequestCount[15:0]};
        ARP_REPLY_CNT_0:     reg_dout <= {16'd0, regReplyCount[15:0]};
//        ICMP_RX_PKG:         reg_dout <=  icmp_rx_pkg_counter_sta;
//        ICMP_TX_PKG:         reg_dout <=  icmp_tx_pkg_counter_sta;
//        UDP_RX_PKG :         reg_dout <=  udp_rx_pkg_counter_sta;
//        UDP_TX_PKG :         reg_dout <=  udp_tx_pkg_counter_sta;
        default:           reg_dout <= 32'hDEAD_BEEF;
      endcase
    end
  end
       
endmodule
