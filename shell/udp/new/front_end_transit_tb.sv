`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/06 14:30:57
// Design Name: 
// Module Name: front_end_transit_tb
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

module front_end_transit_tb;
    reg  [511:0]                 s_axis_tdata ; 
    reg                          s_axis_tvalid ;
    reg                          s_axis_tlast;  
    reg  [63:0]                         s_axis_tkeep ; 
    wire                         s_axis_tready ;
    reg                         clk;
    reg                         rst_n; 
    
    logic [543:0]               m_value_data;
    logic                       m_value_valid;
    logic                       m_value_ready;
    
    logic [80:0]               m_key_data;
    logic                       m_key_ready;
    logic                       m_key_valid;
    
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
    initial begin
            m_key_ready = 1;
            m_value_ready = 1;
        #300
            m_key_ready = 1;
            m_value_ready = 1;
        #400
            @(posedge clk)
            s_axis_tvalid = 1;
            s_axis_tlast = 0;
            s_axis_tdata = {
                {'0,16'hFFFF},
                64'h0000_FFFF_FFFF_0000,
                64'hFFFF_FFFF_FFFF_FFFF,
                8'h01,
                8'd8,
                16'd112,
                16'h0000,
                16'hFFFF 
            };
            #8
            @(posedge clk)
            s_axis_tdata = {
                {512{1'b1}}
            };
            s_axis_tlast = 1;
            s_axis_tkeep = 64'hFFFF_FFFF_FFFF_FFFF;
            #8
            wait(s_axis_tvalid && s_axis_tready)
                s_axis_tvalid = 0;
              #1000
              $stop;
    end
    
    
    front_end_transit front_end_transit_tb(
                 .clk(clk),                   
                 .rst_n(rst_n),                 
                 .s_axis_tdata(s_axis_tdata),          
                 .s_axis_tvalid(s_axis_tvalid),         
                 .s_axis_tlast(s_axis_tlast),          
                 .s_axis_tkeep(s_axis_tkeep),          
                 .s_axis_tready(s_axis_tready),                                                
                 .m_value_data(m_value_data),          
                 .m_value_valid(m_value_valid),         
                 .m_value_ready(m_value_ready),                                                
                 .s_free_pointer(),        
                 .s_free_pointer_valid(),  
                 .s_free_pointer_ready(),                                        
                 .m_key_data(m_key_data),            
                 .m_key_valid(m_key_valid),           
                 .m_key_ready(m_key_ready)                          
    );          
                
endmodule       
                
