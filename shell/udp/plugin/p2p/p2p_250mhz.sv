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
`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
module p2p_250mhz #(
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

  input      [NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tvalid,
  input  [512*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tdata,
  input   [64*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tkeep,
  input      [NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tlast,
  input   [16*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_size,
  input   [16*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_src,
  input   [16*NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tuser_dst,
  output     [NUM_INTF*NUM_QDMA-1:0] s_axis_qdma_h2c_tready,

  output     [NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tvalid,
  output [512*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tdata,
  output  [64*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tkeep,
  output     [NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tlast,
  output  [16*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_size,
  output  [16*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_src,
  output  [16*NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tuser_dst,
  input      [NUM_INTF*NUM_QDMA-1:0] m_axis_qdma_c2h_tready,

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

`ifdef __au55n__
  input                     ref_clk_100mhz,
`elsif __au55c__
  input                     ref_clk_100mhz,
`elsif __au50__
  input                     ref_clk_100mhz,
`elsif __au280__
  input                     ref_clk_100mhz,
`endif
  input                     axis_aclk
);

  wire axil_aresetn;

  // Reset is clocked by the 125MHz AXI-Lite clock
  generic_reset #(
    .NUM_INPUT_CLK  (1),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (mod_rstn),
    .mod_rst_done (mod_rst_done),
    .clk          (axil_aclk),
    .rstn         (axil_aresetn)
  );

  generate if (NUM_QDMA <= 1) begin
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
  end
  endgenerate







  generate for (genvar i = 0; i < NUM_INTF; i++) begin
    wire          [16*3-1:0] axis_adap_tx_250mhz_tuser;
    wire          [16*3-1:0] axis_adap_rx_250mhz_tuser;
    wire          [16*3*NUM_QDMA-1:0] axis_qdma_c2h_tuser;

    assign axis_adap_rx_250mhz_tuser[0+:16]                 = s_axis_adap_rx_250mhz_tuser_size[`getvec(16, i)];
    assign axis_adap_rx_250mhz_tuser[16+:16]                = s_axis_adap_rx_250mhz_tuser_src[`getvec(16, i)];
    assign axis_adap_rx_250mhz_tuser[32+:16]                = s_axis_adap_rx_250mhz_tuser_dst[`getvec(16, i)];

    assign m_axis_adap_tx_250mhz_tuser_size[`getvec(16, i)] = axis_adap_tx_250mhz_tuser[0+:16];
    assign m_axis_adap_tx_250mhz_tuser_src[`getvec(16, i)]  = axis_adap_tx_250mhz_tuser[16+:16];
    assign m_axis_adap_tx_250mhz_tuser_dst[`getvec(16, i)]  = 16'h1 << (6 + i);

    
      wire [47:0] axis_qdma_h2c_tuser;

      assign axis_qdma_h2c_tuser[0+:16]                       = s_axis_qdma_h2c_tuser_size[`getvec(16, i)];
      assign axis_qdma_h2c_tuser[16+:16]                      = s_axis_qdma_h2c_tuser_src[`getvec(16, i)];
      assign axis_qdma_h2c_tuser[32+:16]                      = s_axis_qdma_h2c_tuser_dst[`getvec(16, i)];

      assign m_axis_qdma_c2h_tuser_size[`getvec(16, i)]       = axis_qdma_c2h_tuser[0+:16];
      assign m_axis_qdma_c2h_tuser_src[`getvec(16, i)]        = axis_qdma_c2h_tuser[16+:16];
      assign m_axis_qdma_c2h_tuser_dst[`getvec(16, i)]        = 16'h1 << i;
    if(i == 1)begin
      axi_stream_pipeline tx_ppl_inst (
        .s_axis_tvalid (s_axis_qdma_h2c_tvalid[i]),
        .s_axis_tdata  (s_axis_qdma_h2c_tdata[`getvec(512, i)]),
        .s_axis_tkeep  (s_axis_qdma_h2c_tkeep[`getvec(64, i)]),
        .s_axis_tlast  (s_axis_qdma_h2c_tlast[i]),
        .s_axis_tuser  (axis_qdma_h2c_tuser),
        .s_axis_tready (s_axis_qdma_h2c_tready[i]),

        .m_axis_tvalid (m_axis_adap_tx_250mhz_tvalid[i]),
        .m_axis_tdata  (m_axis_adap_tx_250mhz_tdata[`getvec(512, i)]),
        .m_axis_tkeep  (m_axis_adap_tx_250mhz_tkeep[`getvec(64, i)]),
        .m_axis_tlast  (m_axis_adap_tx_250mhz_tlast[i]),
        .m_axis_tuser  (axis_adap_tx_250mhz_tuser),
        .m_axis_tready (m_axis_adap_tx_250mhz_tready[i]),

        .aclk          (axis_aclk),
        .aresetn       (axil_aresetn)
      );

      axi_stream_pipeline rx_ppl_inst (
        .s_axis_tvalid (s_axis_adap_rx_250mhz_tvalid[i]),
        .s_axis_tdata  (s_axis_adap_rx_250mhz_tdata[`getvec(512, i)]),
        .s_axis_tkeep  (s_axis_adap_rx_250mhz_tkeep[`getvec(64, i)]),
        .s_axis_tlast  (s_axis_adap_rx_250mhz_tlast[i]),
        .s_axis_tuser  (axis_adap_rx_250mhz_tuser),
        .s_axis_tready (s_axis_adap_rx_250mhz_tready[i]),

        .m_axis_tvalid (m_axis_qdma_c2h_tvalid[i]),
        .m_axis_tdata  (m_axis_qdma_c2h_tdata[`getvec(512, i)]),
        .m_axis_tkeep  (m_axis_qdma_c2h_tkeep[`getvec(64, i)]),
        .m_axis_tlast  (m_axis_qdma_c2h_tlast[i]),
        .m_axis_tuser  (axis_qdma_c2h_tuser),
        .m_axis_tready (m_axis_qdma_c2h_tready[i]),

        .aclk          (axis_aclk),
        .aresetn       (axil_aresetn)
      );
    end
    else begin
        wire             adapter_card_tvalid;
        wire [511:0]     adapter_card_tdata;
        wire  [63:0]     adapter_card_tkeep;
        wire             adapter_card_tlast;
        wire  [15:0]     adapter_card_tuser_size;
        wire  [15:0]     adapter_card_tuser_src;
        wire  [15:0]     adapter_card_tuser_dst;
        wire             adapter_card_tready;
        wire  [47:0]     adapter_card_tuser;
        
        
        wire             card_adapter_tvalid;
        wire [511:0]     card_adapter_tdata;
        wire  [63:0]     card_adapter_tkeep;
        wire             card_adapter_tlast;
        wire  [15:0]     card_adapter_tuser_size;
        wire  [15:0]     card_adapter_tuser_src;
        wire  [15:0]     card_adapter_tuser_dst;
        wire             card_adapter_tready;
        wire  [47:0]     card_adapter_tuser;
       
        wire             host_card_tvalid;
        wire [511:0]     host_card_tdata;
        wire  [63:0]     host_card_tkeep;
        wire             host_card_tlast;
        wire  [15:0]     host_card_tuser_size;
        wire  [15:0]     host_card_tuser_src;
        wire  [15:0]     host_card_tuser_dst;
        wire             host_card_tready;
        wire  [47:0]     host_card_tuser;
       
        wire             card_host_tvalid;
        wire [511:0]     card_host_tdata;
        wire  [63:0]     card_host_tkeep;
        wire             card_host_tlast;
        wire  [15:0]     card_host_tuser_size;
        wire  [15:0]     card_host_tuser_src;
        wire  [15:0]     card_host_tuser_dst;
        wire             card_host_tready;
        wire  [47:0]     card_host_tuser;
        
        assign adapter_card_tuser_size = adapter_card_tuser[0+:16];
        assign adapter_card_tuser_src = adapter_card_tuser[16+:16];
        assign adapter_card_tuser_dst = 16'h1 << (6 + i);
        
        assign card_adapter_tuser[0+:16] = card_adapter_tuser_size;
        assign card_adapter_tuser[16+:16] = card_adapter_tuser_src;
        assign card_adapter_tuser[32+:16] = card_adapter_tuser_dst;
        
        assign host_card_tuser_size =  host_card_tuser[0+:16];
        assign host_card_tuser_src =  host_card_tuser[16+:16];
        assign host_card_tuser_dst =  16'h1 << (6 + i);
        
        assign card_host_tuser[0+:16]  = card_host_tuser_size;
        assign card_host_tuser[16+:16] = card_host_tuser_src;
        assign card_host_tuser[32+:16] = card_host_tuser_dst;
        
        axi_stream_pipeline host_process_inst (
        .s_axis_tvalid (s_axis_qdma_h2c_tvalid[i]),
        .s_axis_tdata  (s_axis_qdma_h2c_tdata[`getvec(512, i)]),
        .s_axis_tkeep  (s_axis_qdma_h2c_tkeep[`getvec(64, i)]),
        .s_axis_tlast  (s_axis_qdma_h2c_tlast[i]),
        .s_axis_tuser  (axis_qdma_h2c_tuser),
        .s_axis_tready (s_axis_qdma_h2c_tready[i]),

        .m_axis_tvalid (host_card_tvalid),
        .m_axis_tdata  (host_card_tdata),
        .m_axis_tkeep  (host_card_tkeep),
        .m_axis_tlast  (host_card_tlast),
        .m_axis_tuser  (host_card_tuser),
        .m_axis_tready (host_card_tready),

        .aclk          (axis_aclk),
        .aresetn       (axil_aresetn)
      );
    axi_stream_pipeline process_host_inst (
        .s_axis_tvalid (card_host_tvalid),
        .s_axis_tdata  (card_host_tdata),
        .s_axis_tkeep  (card_host_tkeep),
        .s_axis_tlast  (card_host_tlast),
        .s_axis_tuser  (card_host_tuser),
        .s_axis_tready (card_host_tready),

        .m_axis_tvalid (m_axis_qdma_c2h_tvalid[i]),
        .m_axis_tdata  (m_axis_qdma_c2h_tdata[`getvec(512, i)]),
        .m_axis_tkeep  (m_axis_qdma_c2h_tkeep[`getvec(64, i)]),
        .m_axis_tlast  (m_axis_qdma_c2h_tlast[i]),
        .m_axis_tuser  (axis_qdma_c2h_tuser),
        .m_axis_tready (m_axis_qdma_c2h_tready[i]),

        .aclk          (axis_aclk),
        .aresetn       (axil_aresetn)
      ); 
              // process stack
       process_stack process_stack_inst(
             
             .axis_clk(axis_aclk),                          
             .axis_rstn(axil_aresetn),                         
                                            
             .s_axis_adapter_card_tvalid(adapter_card_tvalid),           
             .s_axis_adapter_card_tdata(adapter_card_tdata),            
             .s_axis_adapter_card_tkeep(adapter_card_tkeep),            
             .s_axis_adapter_card_tlast(adapter_card_tlast),            
             .s_axis_adapter_card_tuser_size(adapter_card_tuser_size),       
             .s_axis_adapter_card_tuser_src(adapter_card_tuser_src),        
             .s_axis_adapter_card_tuser_dst(adapter_card_tuser_dst),        
             .s_axis_adapter_card_tready(adapter_card_tready),           
                                                
             .m_axis_card_adapter_tvalid(card_adapter_tvalid),           
             .m_axis_card_adapter_tdata(card_adapter_tdata),            
             .m_axis_card_adapter_tkeep(card_adapter_tkeep),            
             .m_axis_card_adapter_tlast(card_adapter_tlast),            
             .m_axis_card_adapter_tuser_size(card_adapter_tuser_size),       
             .m_axis_card_adapter_tuser_src(card_adapter_tuser_src),        
             .m_axis_card_adapter_tuser_dst(card_adapter_tuser_dst),        
             .m_axis_card_adapter_tready(card_adapter_tready),           
                                                
             .s_axis_host_card_tvalid(host_card_tvalid),           
             .s_axis_host_card_tdata(host_card_tdata),            
             .s_axis_host_card_tkeep(host_card_tkeep),            
             .s_axis_host_card_tlast(host_card_tlast),            
             .s_axis_host_card_tuser_size(host_card_tuser_size),       
             .s_axis_host_card_tuser_src(host_card_tuser_src),        
             .s_axis_host_card_tuser_dst(host_card_tuser_dst),        
             .s_axis_host_card_tready(host_card_tready),           
                                                
             .m_axis_card_host_tvalid(card_host_tvalid),           
             .m_axis_card_host_tdata(card_host_tdata),            
             .m_axis_card_host_tkeep(card_host_tkeep),            
             .m_axis_card_host_tlast(card_host_tlast),            
             .m_axis_card_host_tuser_size(card_host_tuser_size),       
             .m_axis_card_host_tuser_src(card_host_tuser_src),        
             .m_axis_card_host_tuser_dst(card_host_tuser_dst),        
             .m_axis_card_host_tready(card_host_tready)                 
       ); 
         
     // 
    axi_stream_pipeline adapter_process_inst (
        .s_axis_tvalid (s_axis_adap_rx_250mhz_tvalid[i]),
        .s_axis_tdata  (s_axis_adap_rx_250mhz_tdata[`getvec(512, i)]),
        .s_axis_tkeep  (s_axis_adap_rx_250mhz_tkeep[`getvec(64, i)]),
        .s_axis_tlast  (s_axis_adap_rx_250mhz_tlast[i]),
        .s_axis_tuser  (axis_adap_rx_250mhz_tuser),
        .s_axis_tready (s_axis_adap_rx_250mhz_tready[i]),

        .m_axis_tvalid (adapter_card_tvalid),
        .m_axis_tdata  (adapter_card_tdata),
        .m_axis_tkeep  (adapter_card_tkeep),
        .m_axis_tlast  (adapter_card_tlast),
        .m_axis_tuser  (adapter_card_tuser),
        .m_axis_tready (adapter_card_tready),

        .aclk          (axis_aclk),
        .aresetn       (axil_aresetn)
      ); 
    axi_stream_pipeline process_adapter_inst (
        .s_axis_tvalid (card_adapter_tvalid),
        .s_axis_tdata  (card_adapter_tdata),
        .s_axis_tkeep  (card_adapter_tkeep),
        .s_axis_tlast  (card_adapter_tlast),
        .s_axis_tuser  (card_adapter_tuser),
        .s_axis_tready (card_adapter_tready),

        .m_axis_tvalid (m_axis_adap_tx_250mhz_tvalid[i]),
        .m_axis_tdata  (m_axis_adap_tx_250mhz_tdata[`getvec(512, i)]),
        .m_axis_tkeep  (m_axis_adap_tx_250mhz_tkeep[`getvec(64, i)]),
        .m_axis_tlast  (m_axis_adap_tx_250mhz_tlast[i]),
        .m_axis_tuser  (axis_adap_tx_250mhz_tuser),
        .m_axis_tready (m_axis_adap_tx_250mhz_tready[i]),

        .aclk          (axis_aclk),
        .aresetn       (axil_aresetn)
      );   
    end
  end
  endgenerate

endmodule: p2p_250mhz
