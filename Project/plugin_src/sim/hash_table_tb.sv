`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/19 22:41:19
// Design Name: 
// Module Name: hash_table_tb
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


module hash_table_tb;

    reg         axis_lup_req_tvalid;
    wire         axis_lup_req_tready;
    reg [95:0]  axis_lup_req_tdata;
    
    reg         axis_udp_req_tvalid;
    wire        axis_udp_req_tready;
    reg [143:0] axis_udp_req_data;
    
    wire        axis_lup_rsp_tvalid;
    reg         axis_lup_rsp_ready;
    wire [119:0]axis_lup_rsp_tdata;
    
    wire        axis_udp_rsp_tvalid;
    reg         axis_udp_rsp_tready;
    wire [151:0]axis_udp_rsp_tdata;
    
    reg         clk;
    reg         rst_n;
    
    //250 Mhz Clock
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;  // 
    end
    //rest
    initial begin
        rst_n = 1'b0;
        #100;                  
        rst_n = 1'b1;
    end
    
    hash_table_ip hash_table_ip_inst(
        // s_axis_lup_req
        .s_axis_lup_req_TVALID(axis_lup_req_tvalid),
        .s_axis_lup_req_TREADY(axis_lup_req_tready),
        .s_axis_lup_req_TDATA(axis_lup_req_tdata),//[95:0]
        //s_axis_upd_req
        .s_axis_upd_req_TVALID(axis_udp_req_tvalid),
        .s_axis_upd_req_TREADY(axis_udp_req_tready),
        .s_axis_upd_req_TDATA(axis_udp_req_data),//[143:0]
        //
        .ap_clk(clk),
        .ap_rst_n(rst_n),
        //m_axis_lup_req
        .m_axis_lup_rsp_TVALID(axis_lup_rsp_tvalid),
        .m_axis_lup_rsp_TREADY(axis_lup_rsp_ready),
        .m_axis_lup_rsp_TDATA(axis_lup_rsp_tdata),//[119:0]
        //m_axis_upd_req
        .m_axis_upd_rsp_TVALID(axis_udp_rsp_tvalid),
        .m_axis_upd_rsp_TREADY(axis_udp_rsp_tready),
        .m_axis_upd_rsp_TDATA(axis_udp_rsp_tdata)//[143:0]
        //
    );


 initial begin
    axis_udp_req_tvalid = 1'b0;
    axis_udp_req_data = 144'b0;
    axis_udp_rsp_tready = 1'b1;
    axis_lup_rsp_ready = 1'b1;
    #100
    wait(axis_udp_req_tready);
        axis_udp_req_tvalid = 1'b1;
        axis_udp_req_data ={32'h0000_0000,16'hFF11,64'hFFFF_FFFF_FFFF_0000, 32'h0000_0000};
    #5
    wait(axis_udp_req_tready && axis_udp_req_tvalid)
        axis_udp_req_tvalid = 1'b0;
    #500
    wait(axis_udp_req_tready)
        axis_udp_req_tvalid = 1'b1;
        axis_udp_req_data = {32'h0000_0000,16'h0000,64'hFFFF_FFFF_FFFF_0000, 32'h1};
   #5
    wait(axis_udp_req_tready && axis_udp_req_tvalid)
        axis_udp_req_tvalid = 1'b0;
    #50
    axis_udp_req_tvalid = 1'b1;
    #1000
    $stop;
 end
endmodule
