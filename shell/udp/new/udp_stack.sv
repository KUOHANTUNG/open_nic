`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 16:01:41
// Design Name: 
// Module Name: udp_stack
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


module udp_stack(
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
    
    input   [31:0]      local_ip_address,
    input   [15:0]      listen_port,
    
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
    output              s_axis_tx_udp_data_tready
    );
    wire                  axis_rx_tvalid ;
    wire    [511:0]       axis_rx_tdata  ;
    wire    [63:0]        axis_rx_tkeep  ;
    wire                  axis_rx_tlast  ;
    wire                  axis_rx_tready ;
    
    wire                  axis_tx_tvalid ;
    wire    [511:0]       axis_tx_tdata  ;
    wire    [63:0]        axis_tx_tkeep  ;
    wire                  axis_tx_tlast  ;
    wire                  axis_tx_tready ;    
    
    wire                  axis_ip_to_udp_slice_tvalid ;
    wire    [511:0]       axis_ip_to_udp_slice_tdata  ;
    wire    [63:0]        axis_ip_to_udp_slice_tkeep  ;
    wire                  axis_ip_to_udp_slice_tlast  ;
    wire                  axis_ip_to_udp_slice_tready ;
    
    wire                  axis_ip_to_udp_slice_meta_tvalid;
    wire                  axis_ip_to_udp_slice_meta_tready;
    wire    [47:0]        axis_ip_to_udp_slice_meta_tdata;
    
    wire                  axis_udp_slice_meta_to_udp_meta_tvalid;
    wire                  axis_udp_slice_meta_to_udp_meta_tready;
    wire    [47:0]        axis_udp_slice_meta_to_udp_meta_tdata;
    
    wire                  axis_udp_slice_to_udp_data_tvalid ;
    wire    [511:0]       axis_udp_slice_to_udp_data_tdata  ;
    wire    [63:0]        axis_udp_slice_to_udp_data_tkeep  ;
    wire                  axis_udp_slice_to_udp_data_tlast  ;
    wire                  axis_udp_slice_to_udp_data_tready ;

    wire                  axis_udp_meta_to_udp_slice_meta_tvalid;
    wire                  axis_udp_meta_to_udp_slice_meta_tready;
    wire    [47:0]        axis_udp_meta_to_udp_slice_meta_tdata;    
    
    wire                  axis_udp_slice_out_meta_to_udp_meta_tvalid;
    wire                  axis_udp_slice_out_meta_to_udp_meta_tready;
    wire    [47:0]        axis_udp_slice_out_meta_to_udp_meta_tdata ;
    
    wire                  axis_udp_data_to_udp_slice_tvalid ;
    wire    [511:0]       axis_udp_data_to_udp_slice_tdata  ;
    wire    [63:0]        axis_udp_data_to_udp_slice_tkeep  ;
    wire                  axis_udp_data_to_udp_slice_tlast  ;
    wire                  axis_udp_data_to_udp_slice_tready ;
    
    wire                  axis_udp_slice_out_to_udp_data_tvalid ;
    wire    [511:0]       axis_udp_slice_out_to_udp_data_tdata  ;
    wire    [63:0]        axis_udp_slice_out_to_udp_data_tkeep  ;
    wire                  axis_udp_slice_out_to_udp_data_tlast  ;
    wire                  axis_udp_slice_out_to_udp_data_tready ;
    
    
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
    ) rx_slice_udp_in_inst (
      .s_axis_tvalid (axis_ip_to_udp_slice_tvalid),
      .s_axis_tdata  (axis_ip_to_udp_slice_tdata),
      .s_axis_tkeep  (axis_ip_to_udp_slice_tkeep),
      .s_axis_tlast  (axis_ip_to_udp_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_ip_to_udp_slice_tready),

      .m_axis_tvalid (axis_udp_slice_to_udp_data_tvalid),
      .m_axis_tdata  (axis_udp_slice_to_udp_data_tdata ),
      .m_axis_tkeep  (axis_udp_slice_to_udp_data_tkeep ),
      .m_axis_tlast  (axis_udp_slice_to_udp_data_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_udp_slice_to_udp_data_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    axi_stream_register_slice #(
      .TDATA_W (48),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_meta_in_inst (
      .s_axis_tvalid (axis_ip_to_udp_slice_meta_tvalid),
      .s_axis_tdata  (axis_ip_to_udp_slice_meta_tdata),
      .s_axis_tkeep  (6'b111111),
      .s_axis_tlast  (1'b1),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_ip_to_udp_slice_meta_tready),

      .m_axis_tvalid (axis_udp_slice_meta_to_udp_meta_tvalid),
      .m_axis_tdata  (axis_udp_slice_meta_to_udp_meta_tdata ),
      .m_axis_tkeep  (),
      .m_axis_tlast  (),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_udp_slice_meta_to_udp_meta_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    
    //IPv4
     ipv4_ip ipv4_inst (
       .local_ipv4_address(local_ip_address),
       .protocol(8'h11), //UDP_PROTOCOL
       //RX
       .s_axis_rx_data_TVALID(axis_rx_tvalid),
       .s_axis_rx_data_TREADY(axis_rx_tready),
       .s_axis_rx_data_TDATA(axis_rx_tdata),
       .s_axis_rx_data_TKEEP(axis_rx_tkeep),
       .s_axis_rx_data_TLAST(axis_rx_tlast),
       
       .m_axis_rx_meta_TVALID(axis_ip_to_udp_slice_meta_tvalid),
       .m_axis_rx_meta_TREADY(axis_ip_to_udp_slice_meta_tready),
       .m_axis_rx_meta_TDATA (axis_ip_to_udp_slice_meta_tdata),
       
       .m_axis_rx_data_TVALID(axis_ip_to_udp_slice_tvalid),
       .m_axis_rx_data_TREADY(axis_ip_to_udp_slice_tready ),
       .m_axis_rx_data_TDATA (axis_ip_to_udp_slice_tdata ),
       .m_axis_rx_data_TKEEP (axis_ip_to_udp_slice_tkeep ),
       .m_axis_rx_data_TLAST (axis_ip_to_udp_slice_tlast),
       //TX
       .s_axis_tx_meta_TVALID(axis_udp_slice_out_meta_to_udp_meta_tvalid),
       .s_axis_tx_meta_TREADY(axis_udp_slice_out_meta_to_udp_meta_tready),
       .s_axis_tx_meta_TDATA (axis_udp_slice_out_meta_to_udp_meta_tdata),
       
       .s_axis_tx_data_TVALID(axis_udp_slice_out_to_udp_data_tvalid),
       .s_axis_tx_data_TREADY(axis_udp_slice_out_to_udp_data_tready),
       .s_axis_tx_data_TDATA(axis_udp_slice_out_to_udp_data_tdata),
       .s_axis_tx_data_TKEEP(axis_udp_slice_out_to_udp_data_tkeep),
       .s_axis_tx_data_TLAST(axis_udp_slice_out_to_udp_data_tlast),
       
       .m_axis_tx_data_TVALID(axis_tx_tvalid),
       .m_axis_tx_data_TREADY(axis_tx_tready),
       .m_axis_tx_data_TDATA(axis_tx_tdata),
       .m_axis_tx_data_TKEEP(axis_tx_tkeep),
       .m_axis_tx_data_TLAST(axis_tx_tlast),
     
       .ap_clk(axis_clk),
       .ap_rst_n(axis_rstn)
     );
    
     //UDP
      udp_ip udp_inst (
       .reg_listen_port(listen_port),
       .reg_ip_address({local_ip_address,local_ip_address,local_ip_address,local_ip_address}),
       //RX
       .s_axis_rx_meta_TVALID(axis_udp_slice_meta_to_udp_meta_tvalid),
       .s_axis_rx_meta_TREADY(axis_udp_slice_meta_to_udp_meta_tready),
       .s_axis_rx_meta_TDATA(axis_udp_slice_meta_to_udp_meta_tdata),
       
       .s_axis_rx_data_TVALID(axis_udp_slice_to_udp_data_tvalid),
       .s_axis_rx_data_TREADY(axis_udp_slice_to_udp_data_tready),
       .s_axis_rx_data_TDATA(axis_udp_slice_to_udp_data_tdata),
       .s_axis_rx_data_TKEEP(axis_udp_slice_to_udp_data_tkeep),
       .s_axis_rx_data_TLAST(axis_udp_slice_to_udp_data_tlast),
       
       .m_axis_rx_meta_TVALID(m_axis_rx_udp_meta_tvalid),
       .m_axis_rx_meta_TREADY(m_axis_rx_udp_meta_tready),
       .m_axis_rx_meta_TDATA (m_axis_rx_udp_meta_tdata),
       
       .m_axis_rx_data_TVALID(m_axis_rx_udp_data_tvalid),
       .m_axis_rx_data_TREADY(m_axis_rx_udp_data_tready),
       .m_axis_rx_data_TDATA (m_axis_rx_udp_data_tdata),
       .m_axis_rx_data_TKEEP (m_axis_rx_udp_data_tkeep),
       .m_axis_rx_data_TLAST (m_axis_rx_udp_data_tlast),
       //TX
       .s_axis_tx_meta_TVALID(s_axis_tx_udp_meta_tvalid),
       .s_axis_tx_meta_TREADY(s_axis_tx_udp_meta_tready),
       .s_axis_tx_meta_TDATA (s_axis_tx_udp_meta_tdata),
       
       .s_axis_tx_data_TVALID(s_axis_tx_udp_data_tvalid),
       .s_axis_tx_data_TREADY(s_axis_tx_udp_data_tready ),
       .s_axis_tx_data_TDATA (s_axis_tx_udp_data_tdata ),
       .s_axis_tx_data_TKEEP (s_axis_tx_udp_data_tkeep ),
       .s_axis_tx_data_TLAST (s_axis_tx_udp_data_tlast ),
       
       .m_axis_tx_meta_TVALID(axis_udp_meta_to_udp_slice_meta_tvalid),
       .m_axis_tx_meta_TREADY(axis_udp_meta_to_udp_slice_meta_tready),
       .m_axis_tx_meta_TDATA(axis_udp_meta_to_udp_slice_meta_tdata),
       
       .m_axis_tx_data_TVALID(axis_udp_data_to_udp_slice_tvalid),
       .m_axis_tx_data_TREADY(axis_udp_data_to_udp_slice_tready ),
       .m_axis_tx_data_TDATA (axis_udp_data_to_udp_slice_tdata ),
       .m_axis_tx_data_TKEEP (axis_udp_data_to_udp_slice_tkeep ),
       .m_axis_tx_data_TLAST (axis_udp_data_to_udp_slice_tlast),
     
       .ap_clk(axis_clk),
       .ap_rst_n(axis_rstn)
     );
    // output slice
     axi_stream_register_slice #(
      .TDATA_W (48),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_meta_out_inst (
      .s_axis_tvalid (axis_udp_meta_to_udp_slice_meta_tvalid),
      .s_axis_tdata  (axis_udp_meta_to_udp_slice_meta_tdata),
      .s_axis_tkeep  (6'b111111),
      .s_axis_tlast  (1'b1),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_udp_meta_to_udp_slice_meta_tready),

      .m_axis_tvalid (axis_udp_slice_out_meta_to_udp_meta_tvalid),
      .m_axis_tdata  (axis_udp_slice_out_meta_to_udp_meta_tdata ),
      .m_axis_tkeep  (),
      .m_axis_tlast  (),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_udp_slice_out_meta_to_udp_meta_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );   
    
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_udp_out_inst (
      .s_axis_tvalid (axis_udp_data_to_udp_slice_tvalid),
      .s_axis_tdata  (axis_udp_data_to_udp_slice_tdata),
      .s_axis_tkeep  (axis_udp_data_to_udp_slice_tkeep),
      .s_axis_tlast  (axis_udp_data_to_udp_slice_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_udp_data_to_udp_slice_tready),

      .m_axis_tvalid (axis_udp_slice_out_to_udp_data_tvalid),
      .m_axis_tdata  (axis_udp_slice_out_to_udp_data_tdata ),
      .m_axis_tkeep  (axis_udp_slice_out_to_udp_data_tkeep ),
      .m_axis_tlast  (axis_udp_slice_out_to_udp_data_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (axis_udp_slice_out_to_udp_data_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_2_inst (
      .s_axis_tvalid (axis_tx_tvalid),
      .s_axis_tdata  (axis_tx_tdata),
      .s_axis_tkeep  (axis_tx_tkeep),
      .s_axis_tlast  (axis_tx_tlast),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (0),
      .s_axis_tready (axis_tx_tready),

      .m_axis_tvalid (m_axis_tx_tvalid),
      .m_axis_tdata  (m_axis_tx_tdata ),
      .m_axis_tkeep  (m_axis_tx_tkeep ),
      .m_axis_tlast  (m_axis_tx_tlast ),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (),
      .m_axis_tready (m_axis_tx_tready),

      .aclk          (axis_clk),
      .aresetn       (axis_rstn)
    );
    

endmodule
