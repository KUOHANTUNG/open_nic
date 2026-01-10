`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/14 18:13:32
// Design Name: 
// Module Name: core_tb
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


module core_tb;
localparam MIN_PKT_LEN = 64; 
localparam MAX_PKT_LEN = 4096; 
localparam USE_PHYS_FUNC = 1;
localparam NUM_PHYS_FUNC = 1;
localparam NUM_QDMA = 1;
localparam NUM_CMAC_PORT = 1;
localparam CMAC_ID = 0;


logic           axil_awvalid   ;
logic  [31:0]   axil_awaddr    ;
logic           axil_awready   ;
logic           axil_wvalid    ;
logic  [31:0]   axil_wdata     ;
logic           axil_wready    ;
logic           axil_bvalid    ;
logic   [1:0]   axil_bresp     ;
logic           axil_bready    ;
logic           axil_arvalid   ;
logic  [31:0]   axil_araddr    ;
logic           axil_arready   ;
logic           axil_rvalid    ;
logic  [31:0]   axil_rdata     ;
logic   [1:0]   axil_rresp     ;
logic           axil_rready    ;






// 322 MHz  
logic clk_322mhz = 0;
initial begin
    forever #1.5528 clk_322mhz = ~clk_322mhz;
end

// 250 MHz 
logic clk_250mhz = 0;
initial begin
    forever #2.000 clk_250mhz = ~clk_250mhz;
end

// 125 MHz 
logic clk_125mhz = 0;
initial begin
    forever #4.000 clk_125mhz = ~clk_125mhz;
end

logic   rst_n;
//rest
initial begin
    rst_n = 1'b0;
    #100;                  
    rst_n = 1'b1;
end



logic               qdma_h2c_tvalid           ;
logic [511:0]       qdma_h2c_tdata            ;
logic [63:0]        qdma_h2c_tkeep            ;
logic               qdma_h2c_tlast            ;
logic [15:0]        qdma_h2c_tuser_size       ;
logic [15:0]        qdma_h2c_tuser_src        ;
logic [15:0]        qdma_h2c_tuser_dst        ;
logic               qdma_h2c_tready           ;
                                   
logic               qdma_c2h_tvalid           ;
logic [511:0]       qdma_c2h_tdata            ;
logic [63:0]        qdma_c2h_tkeep            ;
logic               qdma_c2h_tlast            ;
logic [15:0]        qdma_c2h_tuser_size       ;
logic [15:0]        qdma_c2h_tuser_src        ;
logic [15:0]        qdma_c2h_tuser_dst        ;
logic               qdma_c2h_tready           ;
                                  
logic               adap_tx_250mhz_tvalid     ;
logic [511:0]       adap_tx_250mhz_tdata      ;
logic [63:0]        adap_tx_250mhz_tkeep      ;
logic               adap_tx_250mhz_tlast      ;
logic [15:0]        adap_tx_250mhz_tuser_size ;
logic [15:0]        adap_tx_250mhz_tuser_src  ;
logic [15:0]        adap_tx_250mhz_tuser_dst  ;
logic               adap_tx_250mhz_tready     ;
                            
logic               adap_rx_250mhz_tvalid     ;
logic [511:0]       adap_rx_250mhz_tdata      ;
logic [63:0]        adap_rx_250mhz_tkeep      ;
logic               adap_rx_250mhz_tlast      ;
logic [15:0]        adap_rx_250mhz_tuser_size ;
logic [15:0]        adap_rx_250mhz_tuser_src  ;
logic [15:0]        adap_rx_250mhz_tuser_dst  ;
logic               adap_rx_250mhz_tready     ;




logic               adap_tx_322mhz_tvalid               ;
logic  [511:0]      adap_tx_322mhz_tdata                ;
logic  [63:0]       adap_tx_322mhz_tkeep                ;
logic               adap_tx_322mhz_tlast                ;
logic               adap_tx_322mhz_tuser_err            ;
logic               adap_tx_322mhz_tready               ;
                                          
logic               adap_rx_322mhz_tvalid               ;
logic   [511:0]     adap_rx_322mhz_tdata                ;
logic   [63:0]      adap_rx_322mhz_tkeep                ;
logic               adap_rx_322mhz_tlast                ;
logic               adap_rx_322mhz_tuser_err            ;
                                          
logic               cmac_tx_tvalid                      ;
logic  [511:0]      cmac_tx_tdata                       ;
logic  [63:0]       cmac_tx_tkeep                       ;
logic               cmac_tx_tlast                       ;
logic               cmac_tx_tuser_err                   ;
logic               cmac_tx_tready                      ;
                                        
logic               cmac_rx_tvalid                      ;
logic   [511:0]     cmac_rx_tdata                       ;
logic   [63:0]      cmac_rx_tkeep                       ;
logic               cmac_rx_tlast                       ;
logic               cmac_rx_tuser_err                   ;



box_250mhz #(
    .MIN_PKT_LEN(MIN_PKT_LEN),   
    .MAX_PKT_LEN(MAX_PKT_LEN),    
    .USE_PHYS_FUNC(USE_PHYS_FUNC),  
    .NUM_PHYS_FUNC(NUM_PHYS_FUNC),  
    .NUM_QDMA(NUM_QDMA),       
    .NUM_CMAC_PORT(NUM_CMAC_PORT) 
)box_250mhz_tb(
    .s_axil_awvalid (axil_awvalid  ), 
    .s_axil_awaddr  (axil_awaddr   ),  
    .s_axil_awready (axil_awready  ), 
    .s_axil_wvalid  (axil_wvalid   ),  
    .s_axil_wdata   (axil_wdata    ),   
    .s_axil_wready  (axil_wready   ),  
    .s_axil_bvalid  (axil_bvalid   ),  
    .s_axil_bresp   (axil_bresp    ),   
    .s_axil_bready  (axil_bready   ),  
    .s_axil_arvalid (axil_arvalid  ), 
    .s_axil_araddr  (axil_araddr   ),  
    .s_axil_arready (axil_arready  ), 
    .s_axil_rvalid  (axil_rvalid   ),  
    .s_axil_rdata   (axil_rdata    ),   
    .s_axil_rresp   (axil_rresp    ),   
    .s_axil_rready  (axil_rready   ), 
    
    .s_axis_qdma_h2c_tvalid             (qdma_h2c_tvalid     ),     
    .s_axis_qdma_h2c_tdata              (qdma_h2c_tdata      ),      
    .s_axis_qdma_h2c_tkeep              (qdma_h2c_tkeep      ),      
    .s_axis_qdma_h2c_tlast              (qdma_h2c_tlast      ),      
    .s_axis_qdma_h2c_tuser_size         (qdma_h2c_tuser_size ), 
    .s_axis_qdma_h2c_tuser_src          (qdma_h2c_tuser_src  ),  
    .s_axis_qdma_h2c_tuser_dst          (qdma_h2c_tuser_dst  ),  
    .s_axis_qdma_h2c_tready             (qdma_h2c_tready     ),     
                               
    .m_axis_qdma_c2h_tvalid             (qdma_c2h_tvalid     ),     
    .m_axis_qdma_c2h_tdata              (qdma_c2h_tdata      ),      
    .m_axis_qdma_c2h_tkeep              (qdma_c2h_tkeep      ),      
    .m_axis_qdma_c2h_tlast              (qdma_c2h_tlast      ),      
    .m_axis_qdma_c2h_tuser_size         (qdma_c2h_tuser_size ), 
    .m_axis_qdma_c2h_tuser_src          (qdma_c2h_tuser_src  ),  
    .m_axis_qdma_c2h_tuser_dst          (qdma_c2h_tuser_dst  ),  
    .m_axis_qdma_c2h_tready             (qdma_c2h_tready     ),     
   
    .m_axis_adap_tx_250mhz_tvalid       (adap_tx_250mhz_tvalid    ),     
    .m_axis_adap_tx_250mhz_tdata        (adap_tx_250mhz_tdata     ),      
    .m_axis_adap_tx_250mhz_tkeep        (adap_tx_250mhz_tkeep     ),      
    .m_axis_adap_tx_250mhz_tlast        (adap_tx_250mhz_tlast     ),      
    .m_axis_adap_tx_250mhz_tuser_size   (adap_tx_250mhz_tuser_size), 
    .m_axis_adap_tx_250mhz_tuser_src    (adap_tx_250mhz_tuser_src ),  
    .m_axis_adap_tx_250mhz_tuser_dst    (adap_tx_250mhz_tuser_dst ),  
    .m_axis_adap_tx_250mhz_tready       (adap_tx_250mhz_tready    ),     
                                     
    .s_axis_adap_rx_250mhz_tvalid       (adap_rx_250mhz_tvalid    ),     
    .s_axis_adap_rx_250mhz_tdata        (adap_rx_250mhz_tdata     ),      
    .s_axis_adap_rx_250mhz_tkeep        (adap_rx_250mhz_tkeep     ),      
    .s_axis_adap_rx_250mhz_tlast        (adap_rx_250mhz_tlast     ),      
    .s_axis_adap_rx_250mhz_tuser_size   (adap_rx_250mhz_tuser_size), 
    .s_axis_adap_rx_250mhz_tuser_src    (adap_rx_250mhz_tuser_src ),  
    .s_axis_adap_rx_250mhz_tuser_dst    (adap_rx_250mhz_tuser_dst ),  
    .s_axis_adap_rx_250mhz_tready       (adap_rx_250mhz_tready    ),       
    
    .mod_rstn                           (rst_n),      
    .mod_rst_done                       (),  
                 
    .box_rstn                           (rst_n),      
    .box_rst_done                       (),  
                  
    .axil_aclk                          (clk_125mhz),     
    
    .axis_aclk                          (clk_250mhz)
);


packet_adapter #(
    .CMAC_ID(CMAC_ID),    
    .MIN_PKT_LEN(MIN_PKT_LEN),
    .MAX_PKT_LEN(MAX_PKT_LEN)
)packet_adapter_tb( 
     .s_axil_awvalid    (axil_awvalid  ),           
     .s_axil_awaddr     (axil_awaddr   ),            
     .s_axil_awready    (axil_awready  ),           
     .s_axil_wvalid     (axil_wvalid   ),            
     .s_axil_wdata      (axil_wdata    ),             
     .s_axil_wready     (axil_wready   ),            
     .s_axil_bvalid     (axil_bvalid   ),            
     .s_axil_bresp      (axil_bresp    ),             
     .s_axil_bready     (axil_bready   ),            
     .s_axil_arvalid    (axil_arvalid  ),           
     .s_axil_araddr     (axil_araddr   ),            
     .s_axil_arready    (axil_arready  ),           
     .s_axil_rvalid     (axil_rvalid   ),            
     .s_axil_rdata      (axil_rdata    ),             
     .s_axil_rresp      (axil_rresp    ),             
     .s_axil_rready     (axil_rready   ),            
                               
     .s_axis_tx_tvalid      (adap_tx_250mhz_tvalid    ),         
     .s_axis_tx_tdata       (adap_tx_250mhz_tdata     ),          
     .s_axis_tx_tkeep       (adap_tx_250mhz_tkeep     ),          
     .s_axis_tx_tlast       (adap_tx_250mhz_tlast     ),          
     .s_axis_tx_tuser_size  (adap_tx_250mhz_tuser_size),     
     .s_axis_tx_tuser_src   (adap_tx_250mhz_tuser_src ),      
     .s_axis_tx_tuser_dst   (adap_tx_250mhz_tuser_dst ),      
     .s_axis_tx_tready      (adap_tx_250mhz_tready    ),         
                               
     .m_axis_tx_tvalid      (adap_tx_322mhz_tvalid    ),         
     .m_axis_tx_tdata       (adap_tx_322mhz_tdata     ),          
     .m_axis_tx_tkeep       (adap_tx_322mhz_tkeep     ),          
     .m_axis_tx_tlast       (adap_tx_322mhz_tlast     ),          
     .m_axis_tx_tuser_err   (adap_tx_322mhz_tuser_err ),      
     .m_axis_tx_tready      (adap_tx_322mhz_tready    ),         
                               
     .s_axis_rx_tvalid      (adap_rx_322mhz_tvalid     ),         
     .s_axis_rx_tdata       (adap_rx_322mhz_tdata      ),          
     .s_axis_rx_tkeep       (adap_rx_322mhz_tkeep      ),          
     .s_axis_rx_tlast       (adap_rx_322mhz_tlast      ),          
     .s_axis_rx_tuser_err   (adap_rx_322mhz_tuser_err  ),      
                               
     .m_axis_rx_tvalid      (adap_rx_250mhz_tvalid    ),         
     .m_axis_rx_tdata       (adap_rx_250mhz_tdata     ),          
     .m_axis_rx_tkeep       (adap_rx_250mhz_tkeep     ),          
     .m_axis_rx_tlast       (adap_rx_250mhz_tlast     ),          
     .m_axis_rx_tuser_size  (adap_rx_250mhz_tuser_size),     
     .m_axis_rx_tuser_src   (adap_rx_250mhz_tuser_src ),      
     .m_axis_rx_tuser_dst   (adap_rx_250mhz_tuser_dst ),      
     .m_axis_rx_tready      (adap_rx_250mhz_tready    ),         
                               
     .mod_rstn(rst_n),                 
     .mod_rst_done(),             
                               
     .axil_aclk(clk_125mhz),                
     .axis_aclk(clk_250mhz),                
     .cmac_clk(clk_322mhz)                 

);


box_322mhz #(
    .MIN_PKT_LEN(MIN_PKT_LEN),  
    .MAX_PKT_LEN(MAX_PKT_LEN),  
    .NUM_CMAC_PORT(NUM_CMAC_PORT)
)box_322mhz_tb(
     .s_axil_awvalid    (axil_awvalid  ),// input                         
     .s_axil_awaddr     (axil_awaddr   ),// input                          
     .s_axil_awready    (axil_awready  ),// output                        
     .s_axil_wvalid     (axil_wvalid   ),// input                          
     .s_axil_wdata      (axil_wdata    ),// input                           
     .s_axil_wready     (axil_wready   ),// output                         
     .s_axil_bvalid     (axil_bvalid   ),// output                         
     .s_axil_bresp      (axil_bresp    ),// output                          
     .s_axil_bready     (axil_bready   ),// input                          
     .s_axil_arvalid    (axil_arvalid  ),// input                         
     .s_axil_araddr     (axil_araddr   ),// input                          
     .s_axil_arready    (axil_arready  ),// output                        
     .s_axil_rvalid     (axil_rvalid   ),// output                         
     .s_axil_rdata      (axil_rdata    ),// output                          
     .s_axil_rresp      (axil_rresp    ),// output                          
     .s_axil_rready     (axil_rready   ),// input                          
                                            
     .s_axis_adap_tx_322mhz_tvalid      (adap_tx_322mhz_tvalid    ),          
     .s_axis_adap_tx_322mhz_tdata       (adap_tx_322mhz_tdata     ),           
     .s_axis_adap_tx_322mhz_tkeep       (adap_tx_322mhz_tkeep     ),           
     .s_axis_adap_tx_322mhz_tlast       (adap_tx_322mhz_tlast     ),           
     .s_axis_adap_tx_322mhz_tuser_err   (adap_tx_322mhz_tuser_err ),       
     .s_axis_adap_tx_322mhz_tready      (adap_tx_322mhz_tready    ),          
                                            
     .m_axis_adap_rx_322mhz_tvalid      (adap_rx_322mhz_tvalid     ),          
     .m_axis_adap_rx_322mhz_tdata       (adap_rx_322mhz_tdata      ),           
     .m_axis_adap_rx_322mhz_tkeep       (adap_rx_322mhz_tkeep      ),           
     .m_axis_adap_rx_322mhz_tlast       (adap_rx_322mhz_tlast      ),           
     .m_axis_adap_rx_322mhz_tuser_err   (adap_rx_322mhz_tuser_err  ),       
                                          
     .m_axis_cmac_tx_tvalid             (cmac_tx_tvalid    ),                 
     .m_axis_cmac_tx_tdata              (cmac_tx_tdata     ),                  
     .m_axis_cmac_tx_tkeep              (cmac_tx_tkeep     ),                  
     .m_axis_cmac_tx_tlast              (cmac_tx_tlast     ),                  
     .m_axis_cmac_tx_tuser_err          (cmac_tx_tuser_err ),              
     .m_axis_cmac_tx_tready             (cmac_tx_tready    ),                 
                                            
     .s_axis_cmac_rx_tvalid             (cmac_rx_tvalid   ),                 
     .s_axis_cmac_rx_tdata              (cmac_rx_tdata    ),                  
     .s_axis_cmac_rx_tkeep              (cmac_rx_tkeep    ),                  
     .s_axis_cmac_rx_tlast              (cmac_rx_tlast    ),                  
     .s_axis_cmac_rx_tuser_err          (cmac_rx_tuser_err),              
    
     .mod_rstn(rst_n),    
     .mod_rst_done(),
     
     .box_rstn(rst_n),    
     .box_rst_done(),
     
     .axil_aclk(clk_125mhz),
     .cmac_clk (clk_322mhz) 
);

assign axil_rready = 1;
assign axil_bready = 1;
//qdma_h2c_tvalid     
//qdma_h2c_tdata      
//qdma_h2c_tkeep      
//qdma_h2c_tlast      
//qdma_h2c_tuser_size 
//qdma_h2c_tuser_src  
//qdma_h2c_tuser_dst  
//qdma_h2c_tready     
    initial begin
        cmac_tx_tready = 1;
        qdma_c2h_tready = 1;
        #1000
        @(posedge clk_250mhz)
            wait(qdma_h2c_tready);
            qdma_h2c_tvalid = 1;
            qdma_h2c_tlast = 1;
            qdma_h2c_tdata = {
                {'0,16'hFFFF},
                64'h0000_FFFF_FFFF_0000,
                64'hFFFF_FFFF_FFFF_FFFF,
                8'h01,
                8'd8,
                16'd10,
                16'h0000,
                16'hFFFF 
            };
            qdma_h2c_tkeep = 64'h0000_0000_03FF_FFFF;
            #6
                qdma_h2c_tvalid = 0;
        #100
        @(posedge clk_250mhz)
        cmac_rx_tvalid = 1;
        cmac_rx_tdata = {
            16'h0000,
            16'h0000,
            16'h0000,
            16'h0000,
            16'h0000,
            16'h0000,
            16'h0000,
            16'h0000,
            16'h0000,
            16'hffff,
            16'h0000,
            16'hffff,
            16'hffff,
            16'hffff,
            16'hffff,
            16'h0008,
            16'h0000,
            16'hffff,
            16'h2008,
            16'h3800,
            16'h8813,
            16'h8913,
            16'h1111,
            16'h1111,
            16'h1211,
            16'h1111,
            16'hd3f1,
            16'h1140,
            16'h0040,
            16'h8904,
            16'h4c00,
            16'h0045,
            16'h0008,
            16'hcdfb,
            16'h9d35,
            16'h0a00,
            16'h6f35,
            16'h0a00,
            16'h4633
        };  
        cmac_rx_tlast = 1;
        cmac_rx_tuser_err = 0;
        cmac_rx_tkeep =  64'hFFFF_FFFF_FFFF_FFFF;
        #6
         cmac_rx_tvalid = 0;
        #550
        cmac_rx_tdata = {
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
                16'h0000,
        
                16'h1111,  // target IP ? 16bit -> 17.17
                16'h1111,  // target IP ? 16bit -> 17.17.17.17
        
                16'h0200,  // opcode = 0x0002 (reply)
        
                16'h0000,
                16'h0000,
        
                16'h1211,  // sender IP ? 16bit -> 17.17
                16'h1111,  // sender IP ? 16bit -> 17.17.17.18
        
                // ===== ??????? sender MAC =====
                16'hfbcd,  // sender MAC = 0a:00:9d:35:cd:fb
                16'h359d,
                16'h000a,
                // ======================================
        
                16'h0200,  // target MAC = 00:00:00:00:00:02 ?????? 0 ???
                16'h0406,  // HLEN=6, PLEN=4
                16'h0008,  // PTYPE=0x0800 (IPv4)
                16'h0100,  // HTYPE=1 (Ethernet)
                16'h0608,  // EtherType=0x0806 (ARP)
        
                16'hfbcd,  // ???? MAC = 0a:00:9d:35:cd:fb
                16'h359d,
                16'h000a,
        
                16'h0200,  // ????? MAC = 00:00:00:00:00:02
                16'h0000,
                16'h0000
            };
        cmac_rx_tvalid = 1;
        cmac_rx_tkeep =  64'hFFFF_FFFF_FFFF_FFFF;
        cmac_rx_tlast = 1;
        $stop;
    end

endmodule
