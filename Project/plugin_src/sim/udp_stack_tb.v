`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 20:24:31
// Design Name: 
// Module Name: udp_stack_tb
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


module udp_stack_tb;

    reg clk;
    reg rest_n;
    
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;  // 
    end
    //rest
    initial begin
        rest_n = 1'b0;
        #100;                  
        rest_n = 1'b1;
    end
    
    reg              rx_tvalid;
    reg [511:0]      rx_tdata;
    reg [63:0]       rx_tkeep;
    reg              rx_tlast;
    wire             rx_tready;
    
    wire             tx_tvalid;
    wire [511:0]     tx_tdata;
    wire [63:0]      tx_tkeep;
    wire             tx_tlast;
    reg              tx_tready;
    
    reg [31:0]       myIP;
    reg [47:0]       myMac;
    reg [15:0]       listen_port;
    
    wire            m_axis_rx_udp_meta_tvalid;
    wire   [175:0]  m_axis_rx_udp_meta_tdata;
    wire            m_axis_rx_udp_meta_tready;
    
    reg             s_axis_tx_udp_meta_tvalid;
    reg    [175:0]  s_axis_tx_udp_meta_tdata;
    wire            s_axis_tx_udp_meta_tready;
    
//    wire            m_axis_rx_udp_data_tvalid;
//    wire   [511:0]  m_axis_rx_udp_data_tdata;
//    wire   [63:0]   m_axis_rx_udp_data_tkeep;
//    wire            m_axis_rx_udp_data_tlast;
//    reg             m_axis_rx_udp_data_tready;
    wire            m_axis_rx_udp_data_tvalid;
    wire   [511:0]  m_axis_rx_udp_data_tdata;
    wire   [63:0]   m_axis_rx_udp_data_tkeep;
    wire            m_axis_rx_udp_data_tlast;
    wire            m_axis_rx_udp_data_tready;
    
    reg             s_axis_tx_udp_data_tvalid;
    reg   [511:0]   s_axis_tx_udp_data_tdata;
    reg   [63:0]    s_axis_tx_udp_data_tkeep;
    reg             s_axis_tx_udp_data_tlast;
    wire            s_axis_tx_udp_data_tready;

    udp_stack udp_stack_tb(
        .axis_clk(clk),                  
        .axis_rstn(rest_n),                 
                                   
        .s_axis_rx_tvalid (rx_tvalid),          
        .s_axis_rx_tdata  (rx_tdata),           
        .s_axis_rx_tkeep  (rx_tkeep),           
        .s_axis_rx_tlast  (rx_tlast),           
        .s_axis_rx_tready( rx_tready),          
                                   
        .m_axis_tx_tvalid(tx_tvalid),          
        .m_axis_tx_tdata(tx_tdata),           
        .m_axis_tx_tkeep(tx_tkeep),           
        .m_axis_tx_tlast(tx_tlast),           
        .m_axis_tx_tready(tx_tready),          
                                   
        .local_ip_address(myIP),          
        .listen_port(listen_port),               
                                                     
        .m_axis_rx_udp_meta_tvalid(m_axis_rx_udp_meta_tvalid), 
        .m_axis_rx_udp_meta_tdata (m_axis_rx_udp_meta_tdata),  
        .m_axis_rx_udp_meta_tready(m_axis_rx_udp_meta_tready), 
                                   
        .s_axis_tx_udp_meta_tvalid(s_axis_tx_udp_meta_tvalid), 
        .s_axis_tx_udp_meta_tdata (s_axis_tx_udp_meta_tdata),  
        .s_axis_tx_udp_meta_tready(s_axis_tx_udp_meta_tready), 
                                   
        .m_axis_rx_udp_data_tvalid(m_axis_rx_udp_data_tvalid), 
        .m_axis_rx_udp_data_tdata (m_axis_rx_udp_data_tdata),  
        .m_axis_rx_udp_data_tkeep (m_axis_rx_udp_data_tkeep),  
        .m_axis_rx_udp_data_tlast (m_axis_rx_udp_data_tlast),  
        .m_axis_rx_udp_data_tready(m_axis_rx_udp_data_tready), 
                                   
        .s_axis_tx_udp_data_tvalid(s_axis_tx_udp_data_tvalid), 
        .s_axis_tx_udp_data_tdata (s_axis_tx_udp_data_tdata),  
        .s_axis_tx_udp_data_tkeep (s_axis_tx_udp_data_tkeep),  
        .s_axis_tx_udp_data_tlast (s_axis_tx_udp_data_tlast),  
        .s_axis_tx_udp_data_tready(s_axis_tx_udp_data_tready)     
    );
//    network_stack network_stack_tb(
//         .axis_clk(clk),                  
//         .axis_rstn(rest_n),                 
                                    
//         .s_axis_rx_tvalid(rx_tvalid),          
//         .s_axis_rx_tdata (rx_tdata),           
//         .s_axis_rx_tkeep (rx_tkeep),           
//         .s_axis_rx_tlast (rx_tlast),           
//         .s_axis_rx_tready(rx_tready),          
                                    
//         .m_axis_tx_tvalid(tx_tvalid),          
//         .m_axis_tx_tdata (tx_tdata),           
//         .m_axis_tx_tkeep (tx_tkeep),           
//         .m_axis_tx_tlast (tx_tlast),           
//         .m_axis_tx_tready(tx_tready),          
                                    
                                    
//         .m_axis_rx_udp_meta_tvalid(m_axis_rx_udp_meta_tvalid), 
//         .m_axis_rx_udp_meta_tdata(m_axis_rx_udp_meta_tdata),  
//         .m_axis_rx_udp_meta_tready(m_axis_rx_udp_meta_tready), 
                                    
//         .s_axis_tx_udp_meta_tvalid(m_axis_rx_udp_meta_tvalid), 
//         .s_axis_tx_udp_meta_tdata({m_axis_rx_udp_meta_tdata[175:128],m_axis_rx_udp_meta_tdata[31:0],96'b0}),  
//         .s_axis_tx_udp_meta_tready(m_axis_rx_udp_meta_tready), 
                                    
//         .m_axis_rx_udp_data_tvalid(m_axis_rx_udp_data_tvalid), 
//         .m_axis_rx_udp_data_tdata(m_axis_rx_udp_data_tdata),  
//         .m_axis_rx_udp_data_tkeep(m_axis_rx_udp_data_tkeep),  
//         .m_axis_rx_udp_data_tlast(m_axis_rx_udp_data_tlast),  
//         .m_axis_rx_udp_data_tready(m_axis_rx_udp_data_tready), 
                                    
//         .s_axis_tx_udp_data_tvalid(m_axis_rx_udp_data_tvalid), 
//         .s_axis_tx_udp_data_tdata(m_axis_rx_udp_data_tdata),  
//         .s_axis_tx_udp_data_tkeep(m_axis_rx_udp_data_tkeep),  
//         .s_axis_tx_udp_data_tlast(m_axis_rx_udp_data_tlast),  
//         .s_axis_tx_udp_data_tready(m_axis_rx_udp_data_tready), 
                           
//         .myIp(myIP),                      
//         .myMac(myMac),                     
//         .listen_port(listen_port)                
    
    
//    );
//    initial begin
//        rx_tvalid = 1'b0;
//        rx_tkeep  = 64'h0;
//        rx_tlast = 1'b0;
//        #100
//        myIP = 32'h11_11_11_11;
//        myMac = 48'h02_00_00_00_00_00;
//        listen_port = 16'h13_88;
////        #100
////            rx_tvalid = 1'b1;
////            rx_tlast = 1'b1;
////            tx_tready = 1'b1;
////            rx_tkeep  = 64'h0000_03FF_FFFF_FFFF;
////            //rx_tkeep = 64'h0000_0000_7FFF_FFFF;
////            rx_tdata = {
////            32'h1111, 32'h11110000,
////            32'h00000000, 32'h12111111, 
////            32'hC9E73C35, 32'h0A000100, 
////            32'h04060008, 32'h01000608, 
////            32'hC9E73C35, 32'h0A00FFFF, 
////            32'hFFFFFFFF};
////        #100
////            tx_tready = 1'b0;
////            rx_tvalid = 1'b0;
//        #201
//            rx_tvalid = 1'b1;
//            rx_tlast = 1'b1;
//            tx_tready = 1'b1;
//            rx_tkeep  = 64'h001F_FFFF_FFFF_FFFF;
//            //rx_tkeep = 64'h0000_0000_7FFF_FFFF;
//            rx_tdata = {
//            32'h0A,
//            32'h30313B5D, 32'h0B008813,
//            32'hA00F1111, 32'h11111211, 
//            32'h1111C94D, 32'h11400040, 
//            32'hC0A81F00, 32'h00450008, 
//            32'hD1194635, 32'h0A00000A, 
//            32'h7688BF35};
//        #1000
//        $stop;
//    end
endmodule
