`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/02 20:46:01
// Design Name: 
// Module Name: request_parser_tb
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
/*
bit 127 :  64   =  meta           (64 bit)   
bit  63 :  56   =  opcode         (8 bit)    
bit  55 :  48   =  keylen_words   (8 bit)    
bit  47 :  32   =  totlen_words   (16 bit)   
bit  31 :  16   =  0              (16 bit)   
bit  15 :   0   =  0xFFFF         (16 bit)   
*/
module request_parser_tb;
    reg                         clk;
    reg                         rst_n;  
    //250 Mhz Clock
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;  // 
    end
    //rest
    initial begin
        rst_n = 1'b0;
        #200;                  
        rst_n = 1'b1;
    end
    reg  [511:0]                 s_axis_tdata ; 
    reg                          s_axis_tvalid ;
    reg                          s_axis_tlast;  
    reg                          s_axis_tkeep ; 
    wire                         s_axis_tready ;
    
    wire [63:0]                  m_key_data;
    wire                         m_key_valid;
    reg                         m_key_ready;
    
    wire [95:0]                  m_meta_data; 
    wire                         m_meta_valid; 
    reg                          m_meta_ready; 
    
    wire [511:0]                m_value_data;
    wire                         m_value_valid;
    wire [15:0]                  m_value_length;
    wire                         m_value_last;
	reg                          m_value_ready;
	
	wire [15:0]                  m_malloc_data;
    wire                         m_malloc_valid;
	reg                          m_malloc_ready;  
  
 initial begin
    m_key_ready     =  1;
    m_meta_ready    =  1;
    m_value_ready   =  1;
    m_malloc_ready  =  1;
    #500
        s_axis_tvalid = 1;
        s_axis_tlast = 1;
        s_axis_tdata = {
            {'0,16'hFFFF},
            64'h0000_FFFF_FFFF_0000,
            64'hFFFF_FFFF_FFFF_FFFF,
            8'h01,
            8'd8,
            16'd72,
            16'h0000,
            16'hFFFF 
        };
    #4
        s_axis_tdata = 512'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
    #8
        if(s_axis_tvalid && s_axis_tready)
            s_axis_tvalid = 0;
     #1000
    $stop;
 end  
  
  
    
    
request_parser request_parser_tb(
    
                        
        .clk            (clk),
        .rst_n          (rst_n),
        
        .s_axis_tdata   (s_axis_tdata), 
        .s_axis_tvalid  (s_axis_tvalid),  
        .s_axis_tlast   (s_axis_tlast),  
        .s_axis_tkeep   (s_axis_tkeep),  
        .s_axis_tready  (s_axis_tready), 
        
        .m_key_data     (m_key_data),
        .m_key_valid    (m_key_valid),
        .m_key_ready    (m_key_ready),
    	
        .m_meta_data    (m_meta_data),
        .m_meta_valid   (m_meta_valid),
        .m_meta_ready   (m_meta_ready),
    
        .m_value_data   (m_value_data  ),
        .m_value_valid  (m_value_valid ),
        .m_value_length (m_value_length),
        .m_value_last   (m_value_last  ),
        .m_value_ready  (m_value_ready ),
    
        .m_malloc_data  (m_malloc_data ),
        .m_malloc_valid (m_malloc_valid),
        .m_malloc_ready (m_malloc_ready)               
);









endmodule
