`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/29 23:33:00
// Design Name: 
// Module Name: box_250_registers
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


module box_250_registers(
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
      
  input     [63:0]      regExeCount,
  input     [31:0]      rx_pkt,
  input     [31:0]      tx_pkt,   
       
  input                 axil_aclk,
  input                 axil_aresetn
    );

  localparam C_ADDR_W = 12;
  // Address map
  localparam RUNNING_LOW           = 12'h000; 
  localparam RUNNING_HIG           = 12'h004;
  localparam RX_PKT                = 12'h008;
  localparam TX_PKT                = 12'h00C;  
  wire                reg_en;
  wire                reg_we;
  wire [C_ADDR_W-1:0] reg_addr;
  wire         [31:0] reg_din;
  reg          [31:0] reg_dout;
  
  
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


  // read register
  always @(posedge axil_aclk) begin
    if (~axil_aresetn) begin
      reg_dout <= 32'h0;
    end else if (reg_en && ~reg_we) begin
      case (reg_addr)
        RUNNING_LOW:         reg_dout <= regExeCount[31:0];
        RUNNING_HIG:         reg_dout <= regExeCount[63:32];
        RX_PKT:              reg_dout <= rx_pkt;
        TX_PKT:              reg_dout <= tx_pkt;
        default:           reg_dout <= 32'hDEAD_BEEF;
      endcase
    end
  end
       
endmodule
