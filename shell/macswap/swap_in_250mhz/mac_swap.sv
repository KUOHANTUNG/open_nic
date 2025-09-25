`timescale 1ns / 1ps
`timescale 1ns / 1ps
`include "open_nic_shell_macros.vh"

module mac_swap #(
  parameter int NUM_QDMA = 1,
  parameter int NUM_INTF = 1
) (
  input        [NUM_INTF*2-1:0] s_axil_awvalid,
  input     [32*NUM_INTF*2-1:0] s_axil_awaddr,
  output       [NUM_INTF*2-1:0] s_axil_awready,
  input        [NUM_INTF*2-1:0] s_axil_wvalid,
  input     [32*NUM_INTF*2-1:0] s_axil_wdata,
  output       [NUM_INTF*2-1:0] s_axil_wready,
  output       [NUM_INTF*2-1:0] s_axil_bvalid,
  output     [2*NUM_INTF*2-1:0] s_axil_bresp,
  input        [NUM_INTF*2-1:0] s_axil_bready,
  input        [NUM_INTF*2-1:0] s_axil_arvalid,
  input     [32*NUM_INTF*2-1:0] s_axil_araddr,
  output       [NUM_INTF*2-1:0] s_axil_arready,
  output       [NUM_INTF*2-1:0] s_axil_rvalid,
  output    [32*NUM_INTF*2-1:0] s_axil_rdata,
  output     [2*NUM_INTF*2-1:0] s_axil_rresp,
  input        [NUM_INTF*2-1:0] s_axil_rready,

  // QDMA H2C (host->card) wide vector: [NUM_QDMA * NUM_INTF] channels
  input      [NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tvalid,
  input  [512*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tdata,
  input   [64*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tkeep,
  input      [NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tlast,
  input   [16*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_size,
  input   [16*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_src,
  input   [16*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_dst,
  output    [NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tready,

  output    [NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tvalid,
  output [512*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tdata,
  output  [64*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tkeep,
  output    [NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tlast,
  output  [16*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_size,
  output  [16*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_src,
  output  [16*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_dst,
  input     [NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tready,

  output     [NUM_INTF-1:0] m_axis_adap_tx_250mhz_tvalid,
  output [512*NUM_INTF-1:0] m_axis_adap_tx_250mhz_tdata,
  output  [64*NUM_INTF-1:0] m_axis_adap_tx_250mhz_tkeep,
  output     [NUM_INTF-1:0] m_axis_adap_tx_250mhz_tlast,
  output  [16*NUM_INTF-1:0] m_axis_adap_tx_250mhz_tuser_size,
  output  [16*NUM_INTF-1:0] m_axis_adap_tx_250mhz_tuser_src,
  output  [16*NUM_INTF-1:0] m_axis_adap_tx_250mhz_tuser_dst,
  input      [NUM_INTF-1:0] m_axis_adap_tx_250mhz_tready,

  input      [NUM_INTF-1:0] s_axis_adap_rx_250mhz_tvalid,
  input  [512*NUM_INTF-1:0] s_axis_adap_rx_250mhz_tdata,
  input   [64*NUM_INTF-1:0] s_axis_adap_rx_250mhz_tkeep,
  input      [NUM_INTF-1:0] s_axis_adap_rx_250mhz_tlast,
  input   [16*NUM_INTF-1:0] s_axis_adap_rx_250mhz_tuser_size,
  input   [16*NUM_INTF-1:0] s_axis_adap_rx_250mhz_tuser_src,
  input   [16*NUM_INTF-1:0] s_axis_adap_rx_250mhz_tuser_dst,
  output     [NUM_INTF-1:0] s_axis_adap_rx_250mhz_tready,

  input                     mod_rstn,
  output                    mod_rst_done,

  input                     axil_aclk,
  input                     axis_aclk
    );

  wire axil_aresetn;

  // Reset is clocked by the AXI-Lite clock
  generic_reset #(
    .NUM_INPUT_CLK  (1),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (mod_rstn),
    .mod_rst_done (mod_rst_done),
    .clk          (axil_aclk),
    .rstn         (axil_aresetn)
  );

  // dummy axi-lite slave kept as-is
  axi_lite_slave #(
    .REG_ADDR_W (12),
    .REG_PREFIX (16'hB000)
  ) reg_inst (
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

    .aclk           (axil_aclk),
    .aresetn        (axil_aresetn)
  );

wire[512*NUM_INTF-1:0] s_data  = s_axis_adap_rx_250mhz_tdata;
assign m_axis_adap_tx_250mhz_tvalid = s_axis_adap_rx_250mhz_tvalid;
assign m_axis_adap_tx_250mhz_tkeep        =   s_axis_adap_rx_250mhz_tkeep       ;     
assign m_axis_adap_tx_250mhz_tlast        =   s_axis_adap_rx_250mhz_tlast       ;     
assign m_axis_adap_tx_250mhz_tuser_size   =   s_axis_adap_rx_250mhz_tuser_size  ;
assign m_axis_adap_tx_250mhz_tuser_src    =   s_axis_adap_rx_250mhz_tuser_src   ; 
assign m_axis_adap_tx_250mhz_tuser_dst    =   s_axis_adap_rx_250mhz_tuser_dst   ; 
assign m_axis_adap_tx_250mhz_tdata = { s_data[511:96], s_data[47:0], s_data[95:48] };
assign s_axis_adap_rx_250mhz_tready = m_axis_adap_tx_250mhz_tready;

wire [512*NUM_INTF*NUM_QDMA-1:0] qdma_data =    s_axis_qdma_h2c_tdata              ;
assign        m_axis_qdma_c2h_tvalid       =    s_axis_qdma_h2c_tvalid             ;
assign        m_axis_qdma_c2h_tkeep        =     s_axis_qdma_h2c_tkeep              ;    
assign        m_axis_qdma_c2h_tlast        =     s_axis_qdma_h2c_tlast              ;    
assign        m_axis_qdma_c2h_tuser_size   =     s_axis_qdma_h2c_tuser_size         ;
assign        m_axis_qdma_c2h_tuser_src    =     s_axis_qdma_h2c_tuser_src          ;
assign        m_axis_qdma_c2h_tuser_dst    =     s_axis_qdma_h2c_tuser_dst          ;
assign        m_axis_qdma_c2h_tdata        =    { qdma_data[511:96], qdma_data[47:0], qdma_data[95:48] };
assign        s_axis_qdma_h2c_tready = m_axis_qdma_c2h_tready;
endmodule : mac_swap


