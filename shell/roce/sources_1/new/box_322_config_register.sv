`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/05 14:24:21
// Design Name: 
// Module Name: box_322_config_register
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

module box_322_config_register(
  // AXI-Lite slave
  input         s_axil_awvalid,
  input  [31:0] s_axil_awaddr,
  output        s_axil_awready,
  input         s_axil_wvalid,
  input  [31:0] s_axil_wdata,
  output        s_axil_wready,
  output        s_axil_bvalid,
  output  [1:0] s_axil_bresp,
  input         s_axil_bready,
  input         s_axil_arvalid,
  input  [31:0] s_axil_araddr,
  output        s_axil_arready,
  output        s_axil_rvalid,
  output [31:0] s_axil_rdata,
  output  [1:0] s_axil_rresp,
  input         s_axil_rready,
    
    
  output [31:0] local_addr,
  output [47:0] local_mac,
    
    
  input          regRequestCount_vld,
  input          regReplyCount_vld,
  input [15:0]   regRequestCount,
  input [15:0]   regReplyCount,  
    
    
  input         axil_aclk,
  input         axil_aresetn
);

  localparam C_ADDR_W = 12;

  // Address map
  localparam LOCAL_IP_W          = 12'h000;
  localparam LOCAL_IP_R          = 12'h004;
  localparam LOCAL_MAC_LOWER_W   = 12'h008; // MAC[31:0]
  localparam LOCAL_MAC_UPPER_W   = 12'h00C; // MAC[47:32] -> [15:0]
  localparam LOCAL_MAC_LOWER_R   = 12'h010;
  localparam LOCAL_MAC_UPPER_R   = 12'h014;
  localparam ARP_REQUEST_VAL     = 12'h018;
  localparam ARP_REPLY_VAL       = 12'h01C;
  localparam ARP_REQUEST_CNT     = 12'h020;
  localparam ARP_REPLY_CNT       = 12'h024;   
  wire                reg_en;
  wire                reg_we;
  wire [C_ADDR_W-1:0] reg_addr;
  wire         [31:0] reg_din;
  reg          [31:0] reg_dout;
  
  reg [31:0] reg_rx_cnt;
  reg [31:0] reg_tx_cnt;
  
  reg [31:0] reg_local_ip;
  reg [31:0] reg_local_mac_lower;
  reg [31:0] reg_local_mac_upper; // only use [15:0]

  assign local_addr = reg_local_ip;
  assign local_mac  = {reg_local_mac_lower, reg_local_mac_upper[15:0]};

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
      reg_local_ip        <= 32'h0000_0000;
      reg_local_mac_lower <= 32'h0000_0000;
      reg_local_mac_upper <= 32'h0000_0000; 
    end else if (reg_en && reg_we) begin
      case (reg_addr)
        LOCAL_IP_W:        reg_local_ip        <= reg_din;
        LOCAL_MAC_LOWER_W: reg_local_mac_lower <= reg_din;
        LOCAL_MAC_UPPER_W: reg_local_mac_upper <= {16'h0000, reg_din[15:0]}; // mask
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
        LOCAL_IP_R:        reg_dout <= reg_local_ip;
        LOCAL_MAC_LOWER_R: reg_dout <= reg_local_mac_lower;
        LOCAL_MAC_UPPER_R: reg_dout <= reg_local_mac_upper;
        ARP_REQUEST_VAL:   reg_dout <= {31'd0, regRequestCount_vld};
        ARP_REPLY_VAL:     reg_dout <= {31'd0, regReplyCount_vld};
        ARP_REQUEST_CNT:   reg_dout <= {16'd0, regRequestCount};
        ARP_REPLY_CNT:     reg_dout <= {16'd0, regReplyCount};
        default:           reg_dout <= 32'hDEAD_BEEF;
      endcase
    end
  end
  

endmodule
