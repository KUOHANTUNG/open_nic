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
module p2p_322mhz #(
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

  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tvalid,
  input  [512*NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tlast,
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tuser_err,
  output     [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tready,

  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tlast,
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tuser_err,

  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tlast,
  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tuser_err,
  input      [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tready,

  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tvalid,
  input  [512*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tlast,
  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tuser_err,

  input                          mod_rstn,
  output                         mod_rst_done,

  input                          axil_aclk,
  input      [NUM_CMAC_PORT-1:0] cmac_clk
);

  wire                         axil_aresetn;
  wire     [NUM_CMAC_PORT-1:0] cmac_rstn;

  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tuser_err;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tuser_err;

//------------------------------------------------------------------------------
  wire    [31:0]          myIp;                 
  wire    [47:0]          myMac;                
  wire    [15:0]          listen_port;         
                                      
  wire                    RequestCount_vld;  
  wire                    ReplyCount_vld;    
  wire    [15:0]          RequestCount;      
  wire    [15:0]          ReplyCount;  
  
//  wire        [31:0]                icmp_rx_pkg_counter_sta;
//  wire        [31:0]                icmp_tx_pkg_counter_sta;
//  wire        [31:0]                udp_rx_pkg_counter_sta;
//  wire        [31:0]                udp_tx_pkg_counter_sta;      

//  wire                              axis_rx_322mhz_stack_to_adapter_tvalid;
//  wire      [511:0]                 axis_rx_322mhz_stack_to_adapter_tdata;
//  wire      [63:0]                  axis_rx_322mhz_stack_to_adapter_tkeep;
//  wire                              axis_rx_322mhz_stack_to_adapter_tlast;
//  wire                              axis_rx_322mhz_stack_to_adapter_tready;

//  wire                              axis_tx_adapter_to_322mhz_stack_tvalid;
//  wire      [511:0]                 axis_tx_adapter_to_322mhz_stack_tdata;
//  wire      [63:0]                  axis_tx_adapter_to_322mhz_stack_tkeep;
//  wire                              axis_tx_adapter_to_322mhz_stack_tlast; 
//  wire                              axis_tx_adapter_to_322mhz_stack_tready;  


//---------------------------------------------------------------------------------
  generic_reset #(
    .NUM_INPUT_CLK  (1 + NUM_CMAC_PORT),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (mod_rstn),
    .mod_rst_done (mod_rst_done),
    .clk          ({cmac_clk, axil_aclk}),
    .rstn         ({cmac_rstn, axil_aresetn})
  );

  box_322_register box_322_register_inst(
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
                                   
         .myIp(myIp),                 
         .myMac(myMac),                
         .listen_port(listen_port),          
              
//        .icmp_rx_pkg_counter_sta(icmp_rx_pkg_counter_sta),
//        .icmp_tx_pkg_counter_sta(icmp_tx_pkg_counter_sta),
//        .udp_rx_pkg_counter_sta(udp_rx_pkg_counter_sta), 
//        .udp_tx_pkg_counter_sta(udp_tx_pkg_counter_sta),        
              
                               
         .regRequestCount_vld(RequestCount_vld),  
         .regReplyCount_vld(ReplyCount_vld),    
         .regRequestCount(RequestCount),      
         .regReplyCount(ReplyCount),        
                               
         .axil_aclk(axil_aclk),            
         .axil_aresetn(axil_aresetn)              
  );

  generate for (genvar i = 1; i < NUM_CMAC_PORT; i++) begin
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_0_inst (
      .s_axis_tvalid (s_axis_adap_tx_322mhz_tvalid[i]),
      .s_axis_tdata  (s_axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (s_axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (s_axis_adap_tx_322mhz_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (s_axis_adap_tx_322mhz_tuser_err[i]),
      .s_axis_tready (s_axis_adap_tx_322mhz_tready[i]),

      .m_axis_tvalid (axis_adap_tx_322mhz_tvalid[i]),
      .m_axis_tdata  (axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (axis_adap_tx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_tx_322mhz_tuser_err[i]),
      .m_axis_tready (axis_adap_tx_322mhz_tready[i]),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_1_inst (
      .s_axis_tvalid (axis_adap_tx_322mhz_tvalid[i]),
      .s_axis_tdata  (axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (axis_adap_tx_322mhz_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (axis_adap_tx_322mhz_tuser_err[i]),
      .s_axis_tready (axis_adap_tx_322mhz_tready[i]),

      .m_axis_tvalid (m_axis_cmac_tx_tvalid[i]),
      .m_axis_tdata  (m_axis_cmac_tx_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (m_axis_cmac_tx_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (m_axis_cmac_tx_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (m_axis_cmac_tx_tuser_err[i]),
      .m_axis_tready (m_axis_cmac_tx_tready[i]),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_0_inst (
      .s_axis_tvalid (s_axis_cmac_rx_tvalid[i]),
      .s_axis_tdata  (s_axis_cmac_rx_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (s_axis_cmac_rx_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (s_axis_cmac_rx_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (s_axis_cmac_rx_tuser_err[i]),
      .s_axis_tready (),

      .m_axis_tvalid (axis_adap_rx_322mhz_tvalid[i]),
      .m_axis_tdata  (axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (axis_adap_rx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_rx_322mhz_tuser_err[i]),
      .m_axis_tready (1'b1),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_1_inst (
      .s_axis_tvalid (axis_adap_rx_322mhz_tvalid[i]),
      .s_axis_tdata  (axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (axis_adap_rx_322mhz_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (axis_adap_rx_322mhz_tuser_err[i]),
      .s_axis_tready (),

      .m_axis_tvalid (m_axis_adap_rx_322mhz_tvalid[i]),
      .m_axis_tdata  (m_axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (m_axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (m_axis_adap_rx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (m_axis_adap_rx_322mhz_tuser_err[i]),
      .m_axis_tready (1'b1),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );
  end
  endgenerate
/*---------------------------------------------------------------------------------*/
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_1_inst (
      .s_axis_tvalid (axis_adap_tx_322mhz_tvalid[0]),
      .s_axis_tdata  (axis_adap_tx_322mhz_tdata[`getvec(512, 0)]),
      .s_axis_tkeep  (axis_adap_tx_322mhz_tkeep[`getvec(64, 0)]),
      .s_axis_tlast  (axis_adap_tx_322mhz_tlast[0]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_adap_tx_322mhz_tready[0]),

      .m_axis_tvalid (m_axis_cmac_tx_tvalid[0]),
      .m_axis_tdata  (m_axis_cmac_tx_tdata[`getvec(512, 0)]),
      .m_axis_tkeep  (m_axis_cmac_tx_tkeep[`getvec(64, 0)]),
      .m_axis_tlast  (m_axis_cmac_tx_tlast[0]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (m_axis_cmac_tx_tuser_err[0]),
      .m_axis_tready (m_axis_cmac_tx_tready[0]),

      .aclk          (cmac_clk[0]),
      .aresetn       (cmac_rstn[0])
    );
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_0_inst (
      .s_axis_tvalid (s_axis_cmac_rx_tvalid[0]),
      .s_axis_tdata  (s_axis_cmac_rx_tdata[`getvec(512, 0)]),
      .s_axis_tkeep  (s_axis_cmac_rx_tkeep[`getvec(64, 0)]),
      .s_axis_tlast  (s_axis_cmac_rx_tlast[0]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (s_axis_cmac_rx_tuser_err[0]),
      .s_axis_tready (),

      .m_axis_tvalid (axis_adap_rx_322mhz_tvalid[0]),
      .m_axis_tdata  (axis_adap_rx_322mhz_tdata[`getvec(512, 0)]),
      .m_axis_tkeep  (axis_adap_rx_322mhz_tkeep[`getvec(64, 0)]),
      .m_axis_tlast  (axis_adap_rx_322mhz_tlast[0]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_rx_322mhz_tuser_err[0]),
      .m_axis_tready (1'b1),

      .aclk          (cmac_clk[0]),
      .aresetn       (cmac_rstn[0])
    );
    
/*----------------------------------------------------------------------------------------------------------------
temporary loopback test 

----------------------------------------------------------------------------------------------------------------*/
    wire             axis_loopback_udp_meta_tvalid  ;
    wire  [175:0]    axis_loopback_udp_meta_tdata   ; 
    wire             axis_loopback_udp_meta_tready  ;
                                        
    wire             axis_loopback_udp_data_tvalid   ;
    wire  [511:0]    axis_loopback_udp_data_tdata    ;
    wire  [63:0]     axis_loopback_udp_data_tkeep    ;
    wire             axis_loopback_udp_data_tlast    ;
    wire             axis_loopback_udp_data_tready   ;
    
    wire                              axis_tx_stack_to_padding_tvalid;
    wire      [511:0]                 axis_tx_stack_to_padding_tdata;
    wire      [63:0]                  axis_tx_stack_to_padding_tkeep;
    wire                              axis_tx_stack_to_padding_tlast; 
    wire                              axis_tx_stack_to_padding_tready;
    
    wire                              axis_tx_padding_to_slice_tvalid;
    wire      [511:0]                 axis_tx_padding_to_slice_tdata;
    wire      [63:0]                  axis_tx_padding_to_slice_tkeep;
    wire                              axis_tx_padding_to_slice_tlast; 
    wire                              axis_tx_padding_to_slice_tready;
    

    
    
    
    
    
     
                                  
//---------------------------------------------------------------------------------------------------------------    
    
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_padding_slice_0_inst (
      .s_axis_tvalid (axis_tx_padding_to_slice_tvalid),
      .s_axis_tdata  (axis_tx_padding_to_slice_tdata),
      .s_axis_tkeep  (axis_tx_padding_to_slice_tkeep),
      .s_axis_tlast  (axis_tx_padding_to_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_tx_padding_to_slice_tready),

      .m_axis_tvalid (axis_adap_tx_322mhz_tvalid[0]),
      .m_axis_tdata  (axis_adap_tx_322mhz_tdata[`getvec(512, 0)]),
      .m_axis_tkeep  (axis_adap_tx_322mhz_tkeep[`getvec(64, 0)]),
      .m_axis_tlast  (axis_adap_tx_322mhz_tlast[0]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_tx_322mhz_tuser_err[0]),
      .m_axis_tready (axis_adap_tx_322mhz_tready[0]),

      .aclk          (cmac_clk[0]),
      .aresetn       (cmac_rstn[0])
    );
    
    
    ethernet_frame_padding_512_ip ethernet_frame_padding_512_ip_inst(

        .s_axis_TVALID(axis_tx_stack_to_padding_tvalid),
        .s_axis_TREADY(axis_tx_stack_to_padding_tready),
        .s_axis_TDATA (axis_tx_stack_to_padding_tdata),
        .s_axis_TLAST (axis_tx_stack_to_padding_tlast),
        .s_axis_TKEEP (axis_tx_stack_to_padding_tkeep),
        
        .m_axis_TVALID(axis_tx_padding_to_slice_tvalid),
        .m_axis_TREADY(axis_tx_padding_to_slice_tready),
        .m_axis_TDATA(axis_tx_padding_to_slice_tdata),
        .m_axis_TLAST(axis_tx_padding_to_slice_tlast),
        .m_axis_TKEEP(axis_tx_padding_to_slice_tkeep),

        .ap_clk(cmac_clk[0]),
        .ap_rst_n(cmac_rstn[0])
    );
    
    network_stack network_stack_inst(
        .axis_clk(cmac_clk[0]),                 
        .axis_rstn(cmac_rstn[0]),                
                                 
        .s_axis_rx_tvalid(axis_adap_rx_322mhz_tvalid[0]),         
        .s_axis_rx_tdata(axis_adap_rx_322mhz_tdata[`getvec(512, 0)]),          
        .s_axis_rx_tkeep(axis_adap_rx_322mhz_tkeep[`getvec(64, 0)]),          
        .s_axis_rx_tlast(axis_adap_rx_322mhz_tlast[0]),          
        .s_axis_rx_tready(),         
                                
        .m_axis_tx_tvalid(axis_tx_stack_to_padding_tvalid),         
        .m_axis_tx_tdata (axis_tx_stack_to_padding_tdata),          
        .m_axis_tx_tkeep (axis_tx_stack_to_padding_tkeep),          
        .m_axis_tx_tlast (axis_tx_stack_to_padding_tlast),          
        .m_axis_tx_tready(axis_tx_stack_to_padding_tready),         
                              
        .m_axis_rx_udp_meta_tvalid(axis_loopback_udp_meta_tvalid),
        .m_axis_rx_udp_meta_tdata(axis_loopback_udp_meta_tdata), 
        .m_axis_rx_udp_meta_tready(axis_loopback_udp_meta_tready),
                                 
        .s_axis_tx_udp_meta_tvalid(axis_loopback_udp_meta_tvalid),
        .s_axis_tx_udp_meta_tdata({axis_loopback_udp_meta_tdata[175:128],axis_loopback_udp_meta_tdata[31:0],96'b0}), 
        .s_axis_tx_udp_meta_tready(axis_loopback_udp_meta_tready),
                                
        .m_axis_rx_udp_data_tvalid(axis_loopback_udp_data_tvalid),
        .m_axis_rx_udp_data_tdata (axis_loopback_udp_data_tdata), 
        .m_axis_rx_udp_data_tkeep (axis_loopback_udp_data_tkeep), 
        .m_axis_rx_udp_data_tlast (axis_loopback_udp_data_tlast), 
        .m_axis_rx_udp_data_tready(axis_loopback_udp_data_tready),
                                
        .s_axis_tx_udp_data_tvalid(axis_loopback_udp_data_tvalid),
        .s_axis_tx_udp_data_tdata (axis_loopback_udp_data_tdata), 
        .s_axis_tx_udp_data_tkeep (axis_loopback_udp_data_tkeep), 
        .s_axis_tx_udp_data_tlast (axis_loopback_udp_data_tlast), 
        .s_axis_tx_udp_data_tready(axis_loopback_udp_data_tready),
                                 
        .regRequestCount_vld(RequestCount_vld),      
        .regReplyCount_vld(ReplyCount_vld),        
        .regRequestCount(RequestCount),          
        .regReplyCount(ReplyCount),            
                
//        .icmp_rx_pkg_counter_sta(icmp_rx_pkg_counter_sta),
//        .icmp_tx_pkg_counter_sta(icmp_tx_pkg_counter_sta),
//        .udp_rx_pkg_counter_sta(udp_rx_pkg_counter_sta), 
//        .udp_tx_pkg_counter_sta(udp_tx_pkg_counter_sta),        
                                  
        .myIp(myIp),                     
        .myMac(myMac),                    
        .listen_port(listen_port)               
    );
    
//    axi_stream_register_slice #(
//      .TDATA_W (512),
//      .TUSER_W (1),
//      .MODE    ("full")
//    ) tx_slice_0_inst (
//      .s_axis_tvalid (s_axis_adap_tx_322mhz_tvalid[0]),
//      .s_axis_tdata  (s_axis_adap_tx_322mhz_tdata[`getvec(512, 0)]),
//      .s_axis_tkeep  (s_axis_adap_tx_322mhz_tkeep[`getvec(64, 0)]),
//      .s_axis_tlast  (s_axis_adap_tx_322mhz_tlast[0]),
//      .s_axis_tid    (0),
//      .s_axis_tdest  (0),
//      .s_axis_tuser  (s_axis_adap_tx_322mhz_tuser_err[0]),
//      .s_axis_tready (s_axis_adap_tx_322mhz_tready[0]),

//      .m_axis_tvalid (axis_tx_adapter_to_322mhz_stack_tvalid),
//      .m_axis_tdata  (axis_tx_adapter_to_322mhz_stack_tdata),
//      .m_axis_tkeep  (axis_tx_adapter_to_322mhz_stack_tkeep),
//      .m_axis_tlast  (axis_tx_adapter_to_322mhz_stack_tlast),
//      .m_axis_tid    (),
//      .m_axis_tdest  (),
//      .m_axis_tuser  (),
//      .m_axis_tready (axis_tx_adapter_to_322mhz_stack_tready),

//      .aclk          (cmac_clk[0]),
//      .aresetn       (cmac_rstn[0])
//    );
    
    
//    axi_stream_register_slice #(
//      .TDATA_W (512),
//      .TUSER_W (1),
//      .MODE    ("full")
//    ) rx_slice_1_inst (
//      .s_axis_tvalid (axis_rx_322mhz_stack_to_adapter_tvalid),
//      .s_axis_tdata  (axis_rx_322mhz_stack_to_adapter_tdata),
//      .s_axis_tkeep  (axis_rx_322mhz_stack_to_adapter_tkeep),
//      .s_axis_tlast  (axis_rx_322mhz_stack_to_adapter_tlast),
//      .s_axis_tid    (0),
//      .s_axis_tdest  (0),
//      .s_axis_tuser  (0),
//      .s_axis_tready (axis_rx_322mhz_stack_to_adapter_tready),

//      .m_axis_tvalid (m_axis_adap_rx_322mhz_tvalid[0]),
//      .m_axis_tdata  (m_axis_adap_rx_322mhz_tdata[`getvec(512, 0)]),
//      .m_axis_tkeep  (m_axis_adap_rx_322mhz_tkeep[`getvec(64, 0)]),
//      .m_axis_tlast  (m_axis_adap_rx_322mhz_tlast[0]),
//      .m_axis_tid    (),
//      .m_axis_tdest  (),
//      .m_axis_tuser  (m_axis_adap_rx_322mhz_tuser_err[0]),
//      .m_axis_tready (1'b1),

//      .aclk          (cmac_clk[0]),
//      .aresetn       (cmac_rstn[0])
//    );    
    
    
     
/*------------------------------------------------------------------------------------*/    
    
    
    
endmodule: p2p_322mhz
