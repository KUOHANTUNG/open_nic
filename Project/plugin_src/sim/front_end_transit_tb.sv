`timescale 1ns / 1ps 
module front_end_transit_tb;

    logic clk;
    logic rst_n;
    logic[511:0]                   s_axis_tdata; 
    logic                          s_axis_tvalid;  
    logic                          s_axis_tlast;  
    logic[63:0]                    s_axis_tkeep;  
    logic                          s_axis_tready;

    logic  [543:0]                 m_value_data;
    logic                          m_value_valid;
    logic                          m_value_ready; 

    logic[15:0]                    s_free_pointer;
    logic                          s_free_pointer_valid;
    logic                          s_free_pointer_ready;

    logic  [87:0]                  m_key_data;
    logic                          m_key_valid;
    logic                          m_key_ready;
   
    


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
       s_axis_tdata = '0;
        s_axis_tvalid = 1'b0;
        s_axis_tlast  = 1'b0;
        s_axis_tkeep = 64'b0;
        m_value_ready <= 1'b1;
        m_key_ready <= 1'b1;
        s_free_pointer <= 16'b0;
        s_free_pointer_valid <= 1'b0;
        #500
        s_axis_tvalid = 1'b1;
        s_axis_tdata = {
                {{80{4'hA}}},
                64'h1200_FFFF_FFFF_0000,
                64'hFFFF_FFFF_FFFF_FFFF,
                8'h01,
                8'd8,
                16'h40,
                16'h0000,
                16'hFFFF 
            };
        s_axis_tlast  = 1'b0;
        s_axis_tkeep = 64'b0;
        #8
        s_axis_tdata = {
               '0,{48{4'hA}}
            };
        s_axis_tlast  = 1'b1;
        s_axis_tkeep = 64'h0000_0000_0000_003F;
        #8
            wait(s_axis_tvalid && s_axis_tready)
                s_axis_tvalid = 0;
        #100    
            $stop;    
    end


front_end_transit 
front_end_transit_tb(
     .clk(clk),                   
     .rst_n(rst_n),                 
     .s_axis_tdata  (s_axis_tdata),          
     .s_axis_tvalid (s_axis_tvalid),         
     .s_axis_tlast  (s_axis_tlast ),          
     .s_axis_tkeep  (s_axis_tkeep ),          
     .s_axis_tready (s_axis_tready),         
                            
     .m_value_data  (m_value_data ),          
     .m_value_valid (m_value_valid),         
     .m_value_ready (m_value_ready),         
                            
     .s_free_pointer        (s_free_pointer),        
     .s_free_pointer_valid  (s_free_pointer_valid),  
     .s_free_pointer_ready  (s_free_pointer_ready),  
                            
     .m_key_data    (m_key_data  ),            
     .m_key_valid   (m_key_valid ),           
     .m_key_ready   (m_key_ready )            
);


endmodule
