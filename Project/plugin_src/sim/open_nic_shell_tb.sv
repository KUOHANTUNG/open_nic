`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/14 15:15:07
// Design Name: 
// Module Name: open_nic_shell_tb
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
`define __au45n__
`define simulation
`include "open_nic_shell_macros.vh"
module open_nic_shell_tb;
    
localparam int NUM_CMAC_PORT = 2;   
  localparam int NUM_QDMA      = 1;  

  logic clk, rstn; 

  // ---------------- AXI-Lite sim ----------------
  logic [NUM_QDMA-1:0]     s_axil_sim_awvalid;
  logic [32*NUM_QDMA-1:0]  s_axil_sim_awaddr;
  logic [NUM_QDMA-1:0]     s_axil_sim_awready;
  logic [NUM_QDMA-1:0]     s_axil_sim_wvalid;
  logic [32*NUM_QDMA-1:0]  s_axil_sim_wdata;
  logic [NUM_QDMA-1:0]     s_axil_sim_wready;
  logic [NUM_QDMA-1:0]     s_axil_sim_bvalid;
  logic [2*NUM_QDMA-1:0]   s_axil_sim_bresp;
  logic [NUM_QDMA-1:0]     s_axil_sim_bready;
  logic [NUM_QDMA-1:0]     s_axil_sim_arvalid;
  logic [32*NUM_QDMA-1:0]  s_axil_sim_araddr;
  logic [NUM_QDMA-1:0]     s_axil_sim_arready;
  logic [NUM_QDMA-1:0]     s_axil_sim_rvalid;
  logic [32*NUM_QDMA-1:0]  s_axil_sim_rdata;
  logic [2*NUM_QDMA-1:0]   s_axil_sim_rresp;
  logic [NUM_QDMA-1:0]     s_axil_sim_rready;

  logic [31:0] rdata;

  // ---------------- H2C sim ----------------
  logic      [NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tvalid;
  logic  [512*NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tdata;
  logic   [32*NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tcrc;
  logic      [NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tlast;
  logic   [11*NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tuser_qid;
  logic    [3*NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tuser_port_id;
  logic      [NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tuser_err;
  logic   [32*NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tuser_mdata;
  logic    [6*NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tuser_mty;
  logic      [NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tuser_zero_byte;
  logic      [NUM_QDMA-1:0]   s_axis_qdma_h2c_sim_tready;

  // ---------------- C2H sim ----------------
  logic      [NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_tvalid;
  logic  [512*NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_tdata;
  logic   [32*NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_tcrc;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_tlast;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_ctrl_marker;
  logic    [3*NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_ctrl_port_id;
  logic    [7*NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_ctrl_ecc;
  logic   [16*NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_ctrl_len;
  logic   [11*NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_ctrl_qid;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_ctrl_has_cmpt;
  logic    [6*NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_mty;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_c2h_sim_tready;

  // ---------------- CPL sim ----------------
  logic      [NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_tvalid;
  logic  [512*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_tdata;
  logic    [2*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_size;
  logic   [16*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_dpar;
  logic   [11*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_qid;
  logic    [2*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_cmpt_type;
  logic   [16*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_wait_pld_pkt_id;
  logic    [3*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_port_id;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_marker;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_user_trig;
  logic    [3*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_col_idx;
  logic    [3*NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_err_idx;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_ctrl_no_wrb_marker;
  logic      [NUM_QDMA-1:0]   m_axis_qdma_cpl_sim_tready;

  // ---------------- CMAC TX / RX sim ----------------
  logic      [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_sim_tvalid;
  logic  [512*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_sim_tdata;
  logic   [64*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_sim_tkeep;
  logic      [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_sim_tlast;
  logic      [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_sim_tuser_err;
  logic      [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_sim_tready;

  logic      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_sim_tvalid;
  logic  [512*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_sim_tdata;
  logic   [64*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_sim_tkeep;
  logic      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_sim_tlast;
  logic      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_sim_tuser_err;


  logic [NUM_QDMA-1:0] powerup_rstn;


  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz
  end

  initial begin
    rstn = 0;
    repeat (20) @(posedge clk);
    rstn = 1;
  end

  assign powerup_rstn = {NUM_QDMA{rstn}};
  initial begin
    m_axis_qdma_c2h_sim_tready    = {NUM_QDMA{1'b1}};
    m_axis_qdma_cpl_sim_tready    = {NUM_QDMA{1'b1}};
    m_axis_cmac_tx_sim_tready     = {NUM_CMAC_PORT{1'b1}};

    s_axis_cmac_rx_sim_tvalid     = '0;
    s_axis_cmac_rx_sim_tdata      = '0;
    s_axis_cmac_rx_sim_tkeep      = '0;
    s_axis_cmac_rx_sim_tlast      = '0;
    s_axis_cmac_rx_sim_tuser_err  = '0;
  end



open_nic_shell #(
     .BUILD_TIMESTAMP(32'h01010000),
     .MIN_PKT_LEN(64),    
     .MAX_PKT_LEN(1518),    
     .USE_PHYS_FUNC(1),  
     .NUM_PHYS_FUNC(2),  
     .NUM_QUEUE(512),      
     .NUM_QDMA(1),       
     .NUM_CMAC_PORT(2)
)open_nic_shell_tb(
     // AXI-Lite sim
     .s_axil_sim_awvalid (s_axil_sim_awvalid),
     .s_axil_sim_awaddr  (s_axil_sim_awaddr),
     .s_axil_sim_awready (s_axil_sim_awready),
     .s_axil_sim_wvalid  (s_axil_sim_wvalid),
     .s_axil_sim_wdata   (s_axil_sim_wdata),
     .s_axil_sim_wready  (s_axil_sim_wready),
     .s_axil_sim_bvalid  (s_axil_sim_bvalid),
     .s_axil_sim_bresp   (s_axil_sim_bresp),
     .s_axil_sim_bready  (s_axil_sim_bready),
     .s_axil_sim_arvalid (s_axil_sim_arvalid),
     .s_axil_sim_araddr  (s_axil_sim_araddr),
     .s_axil_sim_arready (s_axil_sim_arready),
     .s_axil_sim_rvalid  (s_axil_sim_rvalid),
     .s_axil_sim_rdata   (s_axil_sim_rdata),
     .s_axil_sim_rresp   (s_axil_sim_rresp),
     .s_axil_sim_rready  (s_axil_sim_rready),

     // H2C sim
     .s_axis_qdma_h2c_sim_tvalid       (s_axis_qdma_h2c_sim_tvalid),
     .s_axis_qdma_h2c_sim_tdata        (s_axis_qdma_h2c_sim_tdata),
     .s_axis_qdma_h2c_sim_tcrc         (s_axis_qdma_h2c_sim_tcrc),
     .s_axis_qdma_h2c_sim_tlast        (s_axis_qdma_h2c_sim_tlast),
     .s_axis_qdma_h2c_sim_tuser_qid    (s_axis_qdma_h2c_sim_tuser_qid),
     .s_axis_qdma_h2c_sim_tuser_port_id(s_axis_qdma_h2c_sim_tuser_port_id),
     .s_axis_qdma_h2c_sim_tuser_err    (s_axis_qdma_h2c_sim_tuser_err),
     .s_axis_qdma_h2c_sim_tuser_mdata  (s_axis_qdma_h2c_sim_tuser_mdata),
     .s_axis_qdma_h2c_sim_tuser_mty    (s_axis_qdma_h2c_sim_tuser_mty),
     .s_axis_qdma_h2c_sim_tuser_zero_byte(s_axis_qdma_h2c_sim_tuser_zero_byte),
     .s_axis_qdma_h2c_sim_tready       (s_axis_qdma_h2c_sim_tready),

     // C2H sim
     .m_axis_qdma_c2h_sim_tvalid       (m_axis_qdma_c2h_sim_tvalid),
     .m_axis_qdma_c2h_sim_tdata        (m_axis_qdma_c2h_sim_tdata),
     .m_axis_qdma_c2h_sim_tcrc         (m_axis_qdma_c2h_sim_tcrc),
     .m_axis_qdma_c2h_sim_tlast        (m_axis_qdma_c2h_sim_tlast),
     .m_axis_qdma_c2h_sim_ctrl_marker  (m_axis_qdma_c2h_sim_ctrl_marker),
     .m_axis_qdma_c2h_sim_ctrl_port_id (m_axis_qdma_c2h_sim_ctrl_port_id),
     .m_axis_qdma_c2h_sim_ctrl_ecc     (m_axis_qdma_c2h_sim_ctrl_ecc),
     .m_axis_qdma_c2h_sim_ctrl_len     (m_axis_qdma_c2h_sim_ctrl_len),
     .m_axis_qdma_c2h_sim_ctrl_qid     (m_axis_qdma_c2h_sim_ctrl_qid),
     .m_axis_qdma_c2h_sim_ctrl_has_cmpt(m_axis_qdma_c2h_sim_ctrl_has_cmpt),
     .m_axis_qdma_c2h_sim_mty          (m_axis_qdma_c2h_sim_mty),
     .m_axis_qdma_c2h_sim_tready       (m_axis_qdma_c2h_sim_tready),

     // CPL sim
     .m_axis_qdma_cpl_sim_tvalid       (m_axis_qdma_cpl_sim_tvalid),
     .m_axis_qdma_cpl_sim_tdata        (m_axis_qdma_cpl_sim_tdata),
     .m_axis_qdma_cpl_sim_size         (m_axis_qdma_cpl_sim_size),
     .m_axis_qdma_cpl_sim_dpar         (m_axis_qdma_cpl_sim_dpar),
     .m_axis_qdma_cpl_sim_ctrl_qid     (m_axis_qdma_cpl_sim_ctrl_qid),
     .m_axis_qdma_cpl_sim_ctrl_cmpt_type (m_axis_qdma_cpl_sim_ctrl_cmpt_type),
     .m_axis_qdma_cpl_sim_ctrl_wait_pld_pkt_id (m_axis_qdma_cpl_sim_ctrl_wait_pld_pkt_id),
     .m_axis_qdma_cpl_sim_ctrl_port_id (m_axis_qdma_cpl_sim_ctrl_port_id),
     .m_axis_qdma_cpl_sim_ctrl_marker  (m_axis_qdma_cpl_sim_ctrl_marker),
     .m_axis_qdma_cpl_sim_ctrl_user_trig (m_axis_qdma_cpl_sim_ctrl_user_trig),
     .m_axis_qdma_cpl_sim_ctrl_col_idx (m_axis_qdma_cpl_sim_ctrl_col_idx),
     .m_axis_qdma_cpl_sim_ctrl_err_idx (m_axis_qdma_cpl_sim_ctrl_err_idx),
     .m_axis_qdma_cpl_sim_ctrl_no_wrb_marker (m_axis_qdma_cpl_sim_ctrl_no_wrb_marker),
     .m_axis_qdma_cpl_sim_tready       (m_axis_qdma_cpl_sim_tready),

     // CMAC TX / RX sim
     .m_axis_cmac_tx_sim_tvalid        (m_axis_cmac_tx_sim_tvalid),
     .m_axis_cmac_tx_sim_tdata         (m_axis_cmac_tx_sim_tdata),
     .m_axis_cmac_tx_sim_tkeep         (m_axis_cmac_tx_sim_tkeep),
     .m_axis_cmac_tx_sim_tlast         (m_axis_cmac_tx_sim_tlast),
     .m_axis_cmac_tx_sim_tuser_err     (m_axis_cmac_tx_sim_tuser_err),
     .m_axis_cmac_tx_sim_tready        (m_axis_cmac_tx_sim_tready),

     .s_axis_cmac_rx_sim_tvalid        (s_axis_cmac_rx_sim_tvalid),
     .s_axis_cmac_rx_sim_tdata         (s_axis_cmac_rx_sim_tdata),
     .s_axis_cmac_rx_sim_tkeep         (s_axis_cmac_rx_sim_tkeep),
     .s_axis_cmac_rx_sim_tlast         (s_axis_cmac_rx_sim_tlast),
     .s_axis_cmac_rx_sim_tuser_err     (s_axis_cmac_rx_sim_tuser_err),

     // powerup rst
     .powerup_rstn                     (powerup_rstn)
);
  task axil_write(input [31:0] addr, input [31:0] data);
    begin
      // ?? & ????
      s_axil_sim_awvalid[0] = 1'b1;
      s_axil_sim_awaddr[31:0] = addr;
      s_axil_sim_wvalid[0] = 1'b1;
      s_axil_sim_wdata[31:0] = data;
      s_axil_sim_bready[0] = 1'b1;

      @(posedge clk);
      while (!s_axil_sim_awready[0] || !s_axil_sim_wready[0]) begin
        @(posedge clk);
      end

      s_axil_sim_awvalid[0] = 1'b0;
      s_axil_sim_wvalid[0]  = 1'b0;

      while (!s_axil_sim_bvalid[0]) begin
        @(posedge clk);
      end

      @(posedge clk);
      s_axil_sim_bready[0] = 1'b0;
    end
  endtask

  task axil_read(input [31:0] addr, output [31:0] data);
    begin
      s_axil_sim_arvalid[0] = 1'b1;
      s_axil_sim_araddr[31:0] = addr;
      s_axil_sim_rready[0] = 1'b1;

      @(posedge clk);
      while (!s_axil_sim_arready[0]) begin
        @(posedge clk);
      end
      s_axil_sim_arvalid[0] = 1'b0;

      while (!s_axil_sim_rvalid[0]) begin
        @(posedge clk);
      end
      data = s_axil_sim_rdata[31:0];

      @(posedge clk);
      s_axil_sim_rready[0] = 1'b0;
    end
  endtask

    initial begin
    // ?? AXI-Lite ??
    s_axil_sim_awvalid = '0;
    s_axil_sim_awaddr  = '0;
    s_axil_sim_wvalid  = '0;
    s_axil_sim_wdata   = '0;
    s_axil_sim_bready  = '0;
    s_axil_sim_arvalid = '0;
    s_axil_sim_araddr  = '0;
    s_axil_sim_rready  = '0;

    wait (rstn);
    #1000
    // === ??? pcimem ???? ===
    // Write to QDMA:
    axil_write(32'h0000_1000, 32'h0000_0001);
    axil_write(32'h0000_2000, 32'h0001_0001);

    // Enable CMAC0:
    axil_write(32'h0000_8014, 32'h0000_0001);
    axil_write(32'h0000_800c, 32'h0000_0001);

    // Enable CMAC1:
    axil_write(32'h0000_C014, 32'h0000_0001);
    axil_write(32'h0000_C00c, 32'h0000_0001);

    // ?? read ????

    axil_read(32'h0000_8014, rdata);
    $display("CMAC0 reg 0x8014 = 0x%08x", rdata);

    repeat (1000) @(posedge clk);
    $finish;
  end



endmodule
