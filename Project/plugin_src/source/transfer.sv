`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/26 22:30:12
// Design Name: 
// Module Name: transfer
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


module transfer#(
  parameter int  MIN_PKT_LEN = 64,
  parameter int  MAX_PKT_LEN = 4096,
  parameter real PKT_CAP     = 1.5
)(
        
    input             clk,
    input             rst_n,
    input             s_axis_tx_tvalid,
    input  [511:0]    s_axis_tx_tdata,
    input   [63:0]    s_axis_tx_tkeep,
    input             s_axis_tx_tlast,
    input             s_axis_tx_tuser_err,
    output            s_axis_tx_tready,
    
    input             s_axis_udp_rx_meta_tvalid,
    input   [175:0]   s_axis_udp_rx_meta_tdata,
    output            s_axis_udp_rx_meta_tready,  
    
    output            m_axis_udp_tx_meta_tvalid,
    output   [175:0]  m_axis_udp_tx_meta_tdata,
    input             m_axis_udp_tx_meta_tready, 
    
    
    output            m_axis_tx_tvalid,
    output [511:0]    m_axis_tx_tdata,
    output  [63:0]    m_axis_tx_tkeep,
    output            m_axis_tx_tlast,
    output  [15:0]    m_axis_tx_tuser_size,
    input             m_axis_tx_tready
    
    );

  wire         drop;
  wire         drop_busy;
  wire         axis_buf_tvalid;
  wire [511:0] axis_buf_tdata;
  wire  [63:0] axis_buf_tkeep;
  wire         axis_buf_tlast;
  wire         axis_buf_tuser_err;
  wire         axis_buf_tready;
  
 
 assign drop = 
(axis_buf_tvalid && ~axis_buf_tready);  
  
  axi_stream_register_slice #(
    .TDATA_W (512),
    .TUSER_W (1),
    .MODE    ("forward")
  ) input_slice_inst (
    .s_axis_tvalid    (s_axis_tx_tvalid),
    .s_axis_tdata     (s_axis_tx_tdata),
    .s_axis_tkeep     (s_axis_tx_tkeep),
    .s_axis_tlast     (s_axis_tx_tlast),
    .s_axis_tid       (0),
    .s_axis_tdest     (0),
    .s_axis_tuser     (s_axis_tx_tuser_err),
    .s_axis_tready    (s_axis_tx_tready),
    
    .m_axis_tvalid    (axis_buf_tvalid),
    .m_axis_tdata     (axis_buf_tdata),
    .m_axis_tkeep     (axis_buf_tkeep),
    .m_axis_tlast     (axis_buf_tlast),
    .m_axis_tid       (),
    .m_axis_tdest     (),
    .m_axis_tuser     (axis_buf_tuser_err),
    .m_axis_tready    (axis_buf_tready),

    .aclk             (clk),
    .aresetn          (rst_n)
  );

  fifo#(
    .DATA_WIDTH(176),
    .FIFO_DEPTH(32)
  )udp_meta_fifo(
     .axis_clk(clk),    
     .axis_rstn(rst_n),   
            
     .s_axis_valid(s_axis_udp_rx_meta_tvalid),
     .s_axis_data(s_axis_udp_rx_meta_tdata), 
     .s_axis_ready(s_axis_udp_rx_meta_tready),
           
     .m_axis_valid(m_axis_udp_tx_meta_tvalid),
     .m_axis_data(m_axis_udp_tx_meta_tdata), 
     .m_axis_ready(m_axis_udp_tx_meta_tready) 
  );
  
  
    
 axi_stream_packet_buffer #(
    .CLOCKING_MODE   ("common_clock"),
    .CDC_SYNC_STAGES (2),
    .TDATA_W         (512),
    .MIN_PKT_LEN     (MIN_PKT_LEN),
    .MAX_PKT_LEN     (MAX_PKT_LEN),
    .PKT_CAP         (PKT_CAP)
  ) pkt_buf_inst (
    .s_axis_tvalid     (axis_buf_tvalid),
    .s_axis_tdata      (axis_buf_tdata),
    .s_axis_tkeep      (axis_buf_tkeep),
    .s_axis_tlast      (axis_buf_tlast),
    .s_axis_tid        (0),
    .s_axis_tdest      (0),
    .s_axis_tuser      (0),
    .s_axis_tready     (axis_buf_tready),

    .drop              (drop),
    .drop_busy         (drop_busy),

    .m_axis_tvalid     (m_axis_tx_tvalid),
    .m_axis_tdata      (m_axis_tx_tdata),
    .m_axis_tkeep      (m_axis_tx_tkeep),
    .m_axis_tlast      (m_axis_tx_tlast),
    .m_axis_tid        (),
    .m_axis_tdest      (),
    .m_axis_tuser      (),
    .m_axis_tuser_size (m_axis_tx_tuser_size),
    .m_axis_tready     (m_axis_tx_tready),

    .s_aclk            (clk),
    .s_aresetn         (rst_n),
    .m_aclk            (clk)
  );
    
    
endmodule
