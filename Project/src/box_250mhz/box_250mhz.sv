// *************************************************************************
//
// Copyright 2020 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// *************************************************************************
`timescale 1ns/1ps
module box_250mhz #(
  parameter int MIN_PKT_LEN   = 64,
  parameter int MAX_PKT_LEN   = 1518,
  parameter int USE_PHYS_FUNC = 1,
  parameter int NUM_PHYS_FUNC = 1,
  parameter int NUM_QDMA      = 1,
  parameter int NUM_CMAC_PORT = 1
) (
  input                          s_axil_awvalid,
  input                   [31:0] s_axil_awaddr,
  output                         s_axil_awready,
  input                          s_axil_wvalid,
  input                   [31:0] s_axil_wdata,
  output                         s_axil_wready,
  output                         s_axil_bvalid,
  output                   [1:0] s_axil_bresp,
  input                          s_axil_bready,
  input                          s_axil_arvalid,
  input                   [31:0] s_axil_araddr,
  output                         s_axil_arready,
  output                         s_axil_rvalid,
  output                  [31:0] s_axil_rdata,
  output                   [1:0] s_axil_rresp,
  input                          s_axil_rready,

  input      [NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tvalid,
  input  [512*NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tdata,
  input   [64*NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tkeep,
  input      [NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tlast,
  input   [16*NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_size,
  input   [16*NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_src,
  input   [16*NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_dst,
  output     [NUM_PHYS_FUNC*NUM_QDMA-1:0] s_axis_qdma_h2c_tready,

  output     [NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tvalid,
  output [512*NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tdata,
  output  [64*NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tkeep,
  output     [NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tlast,
  output  [16*NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_size,
  output  [16*NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_src,
  output  [16*NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_dst,
  input      [NUM_PHYS_FUNC*NUM_QDMA-1:0] m_axis_qdma_c2h_tready,

  output     [NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tlast,
  output  [16*NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tuser_size,
  output  [16*NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tuser_src,
  output  [16*NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tuser_dst,
  input      [NUM_CMAC_PORT-1:0] m_axis_adap_tx_250mhz_tready,

  input      [NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tvalid,
  input  [512*NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tlast,
  input   [16*NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tuser_size,
  input   [16*NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tuser_src,
  input   [16*NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tuser_dst,
  output     [NUM_CMAC_PORT-1:0] s_axis_adap_rx_250mhz_tready,

  input                   [15:0] mod_rstn,
  output                  [15:0] mod_rst_done,

  input                          box_rstn,
  output                         box_rst_done,

  input                          axil_aclk,

`ifdef __au55n__
  input                          ref_clk_100mhz,
`elsif __au55c__
  input                          ref_clk_100mhz,
`elsif __au50__
  input                          ref_clk_100mhz,
`elsif __au280__
  input                          ref_clk_100mhz,
`endif
  input                          axis_aclk
);

  wire internal_box_rstn;

  generic_reset #(
    .NUM_INPUT_CLK  (1),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (box_rstn),
    .mod_rst_done (box_rst_done),
    .clk          (axil_aclk),
    .rstn         (internal_box_rstn)
  );

  `include "box_250mhz_address_map_inst.vh"

  generate if (USE_PHYS_FUNC == 0) begin
    // Terminate H2C and C2H interfaces of the box
    assign s_axis_qdma_h2c_tready     = {NUM_PHYS_FUNC*NUM_QDMA{1'b1}};

    assign m_axis_qdma_c2h_tvalid     = 0;
    assign m_axis_qdma_c2h_tdata      = 0;
    assign m_axis_qdma_c2h_tkeep      = 0;
    assign m_axis_qdma_c2h_tlast      = 0;
    assign m_axis_qdma_c2h_tuser_size = 0;
    assign m_axis_qdma_c2h_tuser_src  = 0;
    assign m_axis_qdma_c2h_tuser_dst  = 0;
  end
  endgenerate

  //`include "user_plugin_250mhz_inst.vh"
mac_swap #(
  .NUM_QDMA    (NUM_QDMA),
  .NUM_INTF    (NUM_PHYS_FUNC)
) mac_swap_inst (
  .s_axil_awvalid                   (axil_p2p_awvalid),
  .s_axil_awaddr                    (axil_p2p_awaddr),
  .s_axil_awready                   (axil_p2p_awready),
  .s_axil_wvalid                    (axil_p2p_wvalid),
  .s_axil_wdata                     (axil_p2p_wdata),
  .s_axil_wready                    (axil_p2p_wready),
  .s_axil_bvalid                    (axil_p2p_bvalid),
  .s_axil_bresp                     (axil_p2p_bresp),
  .s_axil_bready                    (axil_p2p_bready),
  .s_axil_arvalid                   (axil_p2p_arvalid),
  .s_axil_araddr                    (axil_p2p_araddr),
  .s_axil_arready                   (axil_p2p_arready),
  .s_axil_rvalid                    (axil_p2p_rvalid),
  .s_axil_rdata                     (axil_p2p_rdata),
  .s_axil_rresp                     (axil_p2p_rresp),
  .s_axil_rready                    (axil_p2p_rready),

  .s_axis_qdma_h2c_tvalid           (s_axis_qdma_h2c_tvalid),
  .s_axis_qdma_h2c_tdata            (s_axis_qdma_h2c_tdata),
  .s_axis_qdma_h2c_tkeep            (s_axis_qdma_h2c_tkeep),
  .s_axis_qdma_h2c_tlast            (s_axis_qdma_h2c_tlast),
  .s_axis_qdma_h2c_tuser_size       (s_axis_qdma_h2c_tuser_size),
  .s_axis_qdma_h2c_tuser_src        (s_axis_qdma_h2c_tuser_src),
  .s_axis_qdma_h2c_tuser_dst        (s_axis_qdma_h2c_tuser_dst),
  .s_axis_qdma_h2c_tready           (s_axis_qdma_h2c_tready),

  .m_axis_qdma_c2h_tvalid           (m_axis_qdma_c2h_tvalid),
  .m_axis_qdma_c2h_tdata            (m_axis_qdma_c2h_tdata),
  .m_axis_qdma_c2h_tkeep            (m_axis_qdma_c2h_tkeep),
  .m_axis_qdma_c2h_tlast            (m_axis_qdma_c2h_tlast),
  .m_axis_qdma_c2h_tuser_size       (m_axis_qdma_c2h_tuser_size),
  .m_axis_qdma_c2h_tuser_src        (m_axis_qdma_c2h_tuser_src),
  .m_axis_qdma_c2h_tuser_dst        (m_axis_qdma_c2h_tuser_dst),
  .m_axis_qdma_c2h_tready           (m_axis_qdma_c2h_tready),

  .m_axis_adap_tx_250mhz_tvalid     (m_axis_adap_tx_250mhz_tvalid),
  .m_axis_adap_tx_250mhz_tdata      (m_axis_adap_tx_250mhz_tdata),
  .m_axis_adap_tx_250mhz_tkeep      (m_axis_adap_tx_250mhz_tkeep),
  .m_axis_adap_tx_250mhz_tlast      (m_axis_adap_tx_250mhz_tlast),
  .m_axis_adap_tx_250mhz_tuser_size (m_axis_adap_tx_250mhz_tuser_size),
  .m_axis_adap_tx_250mhz_tuser_src  (m_axis_adap_tx_250mhz_tuser_src),
  .m_axis_adap_tx_250mhz_tuser_dst  (m_axis_adap_tx_250mhz_tuser_dst),
  .m_axis_adap_tx_250mhz_tready     (m_axis_adap_tx_250mhz_tready),

  .s_axis_adap_rx_250mhz_tvalid     (s_axis_adap_rx_250mhz_tvalid),
  .s_axis_adap_rx_250mhz_tdata      (s_axis_adap_rx_250mhz_tdata),
  .s_axis_adap_rx_250mhz_tkeep      (s_axis_adap_rx_250mhz_tkeep),
  .s_axis_adap_rx_250mhz_tlast      (s_axis_adap_rx_250mhz_tlast),
  .s_axis_adap_rx_250mhz_tuser_size (s_axis_adap_rx_250mhz_tuser_size),
  .s_axis_adap_rx_250mhz_tuser_src  (s_axis_adap_rx_250mhz_tuser_src),
  .s_axis_adap_rx_250mhz_tuser_dst  (s_axis_adap_rx_250mhz_tuser_dst),
  .s_axis_adap_rx_250mhz_tready     (s_axis_adap_rx_250mhz_tready),

  .mod_rstn                         (mod_rstn[0]),
  .mod_rst_done                     (mod_rst_done[0]),

// For AU55N, AU55C, AU50, and AU280, we generate 100MHz reference clock which is needed when HBM IP is instantiated 
// in user-defined logic.  
// Temperature related outputs can be added to route to CMS

`ifdef __au55n__
  .ref_clk_100mhz                   (ref_clk_100mhz),
`elsif __au55c__
  .ref_clk_100mhz                   (ref_clk_100mhz),
`elsif __au50__
  .ref_clk_100mhz                   (ref_clk_100mhz),
`elsif __au280__
  .ref_clk_100mhz                   (ref_clk_100mhz),    
`endif

  .axil_aclk                        (axil_aclk),
  .axis_aclk                        (axis_aclk)

);


endmodule: box_250mhz
