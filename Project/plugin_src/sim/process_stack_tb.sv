`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/12 11:53:47
// Design Name: 
// Module Name: process_stack_tb
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


module process_stack_tb;
    logic                         clk;
    logic                         rst_n; 
        

    logic             adapter_card_tvalid       ;
    logic [511:0]     adapter_card_tdata        ;
    logic  [63:0]     adapter_card_tkeep        ;
    logic             adapter_card_tlast        ;
    logic  [15:0]     adapter_card_tuser_size   ;
    logic  [15:0]     adapter_card_tuser_src    ;
    logic  [15:0]     adapter_card_tuser_dst    ;
    logic             adapter_card_tready       ;
   
    logic             card_adapter_tvalid       ;
    logic [511:0]     card_adapter_tdata        ;
    logic  [63:0]     card_adapter_tkeep        ;
    logic             card_adapter_tlast        ;
    logic  [15:0]     card_adapter_tuser_size   ;
    logic  [15:0]     card_adapter_tuser_src    ;
    logic  [15:0]     card_adapter_tuser_dst    ;
    logic             card_adapter_tready       ; 
   
    logic             host_card_tvalid          ;
    logic [511:0]     host_card_tdata           ;
    logic  [63:0]     host_card_tkeep           ;
    logic             host_card_tlast           ;
    logic  [15:0]     host_card_tuser_size      ;
    logic  [15:0]     host_card_tuser_src       ;
    logic  [15:0]     host_card_tuser_dst       ;
    logic             host_card_tready          ;
   
    logic             card_host_tvalid          ;
    logic [511:0]     card_host_tdata           ;
    logic  [63:0]     card_host_tkeep           ;
    logic             card_host_tlast           ;
    logic  [15:0]     card_host_tuser_size      ;
    logic  [15:0]     card_host_tuser_src       ;
    logic  [15:0]     card_host_tuser_dst       ;
    logic             card_host_tready          ;
    
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
        
            card_adapter_tready     =   1'b1;
            card_host_tready        =   1'b1;
            
            host_card_tvalid        = '0;
            host_card_tdata         = '0;
            host_card_tkeep         = '0;
            host_card_tlast         = '0;
            host_card_tuser_size    = '0;
            host_card_tuser_src     = '0;
            host_card_tuser_dst     = '0;
            
            adapter_card_tvalid     = '0;
            adapter_card_tdata      = '0;
            adapter_card_tkeep      = '0;
            adapter_card_tlast      = '0;
            adapter_card_tuser_size = '0;
            adapter_card_tuser_src  = '0;
            adapter_card_tuser_dst  = '0;                                    
        #400
            @(posedge clk)
            host_card_tvalid = 1;
            host_card_tlast = 1 ;
            host_card_tdata = {
                {'0,16'hFFFF},
                64'h0000_FFFF_FFFF_0000,
                64'hFFFF_FFFF_FFFF_FFFF,
                8'h01,
                8'd8,
                16'h0A,
                16'h0000,
                16'hFFFF 
            };
            host_card_tkeep = 64'h0000_0000_0003_FFFF;
            #8
            wait(host_card_tvalid && host_card_tready)
                host_card_tvalid = 0;
            $stop;
        #100            
            @(posedge clk)
            host_card_tvalid = 1;
            host_card_tlast = 1 ;
            host_card_tdata = {
                {'0,16'hAAAA},
                64'hAAAA_FFFF_FFFF_0000,
                64'hFFFF_FFFF_FFFF_FFFF,
                8'h00,
                8'd8,
                16'h0B,
                16'h0000,
                16'hFFFF 
            };
            host_card_tkeep = 64'h0000_0000_0003_FFFF;
            #8
            wait(host_card_tvalid && host_card_tready)
                host_card_tvalid = 0;
        #500
            @(posedge clk)
            adapter_card_tvalid = 1'b1;
            adapter_card_tlast = 1'b1;
            adapter_card_tkeep = 64'hFFFF_FFFF_FFFF_FFFF;
            adapter_card_tdata ={
                64'h0000_FFFF_FFFF_0000,
                64'hFFFF_FFFF_FFFF_FFFF,
                8'h00,
                8'd8,
                16'd112,
                16'h0000,
                16'hFFFF 
            };
            adapter_card_tkeep = 64'h0000_0000_0000_FFFF;
        #100
            @(posedge clk)
            adapter_card_tvalid = 1'b1;
            adapter_card_tlast = 1'b1;
            adapter_card_tkeep = 64'hFFFF_FFFF_FFFF_FFFF;
            adapter_card_tdata ={
                64'hAAAA_FFFF_FFFF_0000,
                64'hFFFF_FFFF_FFFF_FFFF,
                8'h00,
                8'd8,
                16'd112,
                16'h0000,
                16'hFFFF 
            };
            adapter_card_tkeep = 64'h0000_0000_0000_FFFF;
            $stop;
              #1000
              $stop;
    end
    
    
    
    
    process_stack process_stack_tb(
          .axis_clk(clk),                         
          .axis_rstn(rst_n),                        
                                            
          .s_axis_adapter_card_tvalid       (adapter_card_tvalid    ),       
          .s_axis_adapter_card_tdata        (adapter_card_tdata     ),        
          .s_axis_adapter_card_tkeep        (adapter_card_tkeep     ),        
          .s_axis_adapter_card_tlast        (adapter_card_tlast     ),        
          .s_axis_adapter_card_tuser_size   (adapter_card_tuser_size),   
          .s_axis_adapter_card_tuser_src    (adapter_card_tuser_src ),    
          .s_axis_adapter_card_tuser_dst    (adapter_card_tuser_dst ),    
          .s_axis_adapter_card_tready       (adapter_card_tready    ),       
                                            
          .m_axis_card_adapter_tvalid       (card_adapter_tvalid     ),       
          .m_axis_card_adapter_tdata        (card_adapter_tdata      ),        
          .m_axis_card_adapter_tkeep        (card_adapter_tkeep      ),        
          .m_axis_card_adapter_tlast        (card_adapter_tlast      ),        
          .m_axis_card_adapter_tuser_size   (card_adapter_tuser_size ),   
          .m_axis_card_adapter_tuser_src    (card_adapter_tuser_src  ),    
          .m_axis_card_adapter_tuser_dst    (card_adapter_tuser_dst  ),    
          .m_axis_card_adapter_tready       (card_adapter_tready     ),       
                                            
          .s_axis_host_card_tvalid          ( host_card_tvalid     ),          
          .s_axis_host_card_tdata           ( host_card_tdata      ),           
          .s_axis_host_card_tkeep           ( host_card_tkeep      ),           
          .s_axis_host_card_tlast           ( host_card_tlast      ),           
          .s_axis_host_card_tuser_size      ( host_card_tuser_size ),      
          .s_axis_host_card_tuser_src       ( host_card_tuser_src  ),       
          .s_axis_host_card_tuser_dst       ( host_card_tuser_dst  ),       
          .s_axis_host_card_tready          ( host_card_tready     ),          
                                            
          .m_axis_card_host_tvalid          (card_host_tvalid     ),          
          .m_axis_card_host_tdata           (card_host_tdata      ),           
          .m_axis_card_host_tkeep           (card_host_tkeep      ),           
          .m_axis_card_host_tlast           (card_host_tlast      ),           
          .m_axis_card_host_tuser_size      (card_host_tuser_size ),      
          .m_axis_card_host_tuser_src       (card_host_tuser_src  ),       
          .m_axis_card_host_tuser_dst       (card_host_tuser_dst  ),       
          .m_axis_card_host_tready          (card_host_tready     )           
    );


endmodule
