`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/20 20:13:36
// Design Name: 
// Module Name: uram_cas_upgrade
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


module uram_cas_upgrade#(
    parameter cascade_level = 16
)(
    input               clk,
    input               rst_n,
    output wire [71:0]  DOUT_A,
    output wire [71:0]  DOUT_B,
    output wire         RDACCESS_A,
    output wire         RDACCESS_B,
    input [22:0]        ADDR_A,
    input [22:0]        ADDR_B,
    input [8:0]         BWE_A,
    input [8:0]         BWE_B,
    input [71:0]        DIN_A,
    input [71:0]        DIN_B,
    input               RDB_WR_A,
    input               RDB_WR_B,
    input               EN_A,
    input               EN_B
    );

    logic [23 - 1 : 0]     wire_ADDR_A[cascade_level-1:0];
    logic [23 - 1 : 0]     wire_ADDR_B[cascade_level-1:0];
    logic [9 - 1 : 0]      wire_BWE_A[cascade_level-1:0];
    logic [9 - 1 : 0]      wire_BWE_B[cascade_level-1:0];
    logic [72 - 1 : 0]     wire_DIN_A[cascade_level-1:0];
    logic [72 - 1 : 0]     wire_DIN_B[cascade_level-1:0];
    logic [72 - 1 : 0]     wire_DOUT_A[cascade_level-1:0];
    logic [72 - 1 : 0]     wire_DOUT_B[cascade_level-1:0];
    logic [1 - 1 : 0]      wire_EN_A[cascade_level-1:0];
    logic [1 - 1 : 0]      wire_EN_B[cascade_level-1:0];
    logic [1 - 1 : 0]      wire_RDACCESS_A[cascade_level-1:0];
    logic [1 - 1 : 0]      wire_RDACCESS_B[cascade_level-1:0];
    logic [1 - 1 : 0]      wire_RDB_WR_A[cascade_level-1:0];
    logic [1 - 1 : 0]      wire_RDB_WR_B[cascade_level-1:0];
    
    logic [72 - 1 : 0]    DOUT_A_out;
    logic                 RDACCESS_A_out;
    logic [72 - 1 : 0]    DOUT_B_out;    
    logic                 RDACCESS_B_out;
    
    assign  DOUT_A      =     DOUT_A_out;
    assign  RDACCESS_A  = RDACCESS_A_out;
    assign  DOUT_B      =     DOUT_B_out;
    assign  RDACCESS_B  = RDACCESS_B_out;
    
    logic [3:0]            choose_A;
    logic [3:0]            choose_B;
    wire    rst = !rst_n;
   assign   choose_A = ADDR_A[15:12];
   assign   choose_B = ADDR_B[15:12];   
    // A
    always@(posedge clk)begin
        if(!rst_n)begin
            for(int i = 0; i < cascade_level; i++)begin
                wire_ADDR_A[i]=0;     
                wire_BWE_A[i]=0;         
                wire_DIN_A[i]=0;                
                wire_EN_A[i]=0;           
                wire_RDB_WR_A[i]=0;               
            end
        end
        else begin
            case(choose_A) 
                4'b0000  :begin
                    wire_ADDR_A[0] = ADDR_A[11:0];
                  wire_RDB_WR_A[0] = RDB_WR_A;
                     wire_BWE_A[0] = BWE_A;
                     wire_DIN_A[0] = DIN_A;
                      wire_EN_A[0] = EN_A;
                       DOUT_A_out  = wire_DOUT_A[0];
                    RDACCESS_A_out = wire_RDACCESS_A[0];
                  
                end
                4'b0001  :begin
                    wire_ADDR_A[1] = ADDR_A[11:0];      
                  wire_RDB_WR_A[1] = RDB_WR_A;          
                     wire_BWE_A[1] = BWE_A;             
                     wire_DIN_A[1] = DIN_A;             
                      wire_EN_A[1] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[1];    
                    RDACCESS_A_out = wire_RDACCESS_A[1];
                end
                4'b0010  :begin
                    wire_ADDR_A[2] = ADDR_A[11:0];      
                  wire_RDB_WR_A[2] = RDB_WR_A;          
                     wire_BWE_A[2] = BWE_A;             
                     wire_DIN_A[2] = DIN_A;             
                      wire_EN_A[2] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[2];    
                    RDACCESS_A_out = wire_RDACCESS_A[2];
                end
                4'b0011  : begin
                    wire_ADDR_A[3] = ADDR_A[11:0];      
                  wire_RDB_WR_A[3] = RDB_WR_A;          
                     wire_BWE_A[3] = BWE_A;             
                     wire_DIN_A[3] = DIN_A;             
                      wire_EN_A[3] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[3];    
                    RDACCESS_A_out = wire_RDACCESS_A[3];
                end
                4'b0100  :begin
                    wire_ADDR_A[4] = ADDR_A[11:0];      
                  wire_RDB_WR_A[4] = RDB_WR_A;          
                     wire_BWE_A[4] = BWE_A;             
                     wire_DIN_A[4] = DIN_A;             
                      wire_EN_A[4] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[4];    
                    RDACCESS_A_out = wire_RDACCESS_A[4];
                end
                4'b0101  : begin
                    wire_ADDR_A[5] = ADDR_A[11:0];      
                  wire_RDB_WR_A[5] = RDB_WR_A;          
                     wire_BWE_A[5] = BWE_A;             
                     wire_DIN_A[5] = DIN_A;             
                      wire_EN_A[5] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[5];    
                    RDACCESS_A_out = wire_RDACCESS_A[5];
                end
                4'b0110  : begin
                    wire_ADDR_A[6] = ADDR_A[11:0];      
                  wire_RDB_WR_A[6] = RDB_WR_A;          
                     wire_BWE_A[6] = BWE_A;             
                     wire_DIN_A[6] = DIN_A;             
                      wire_EN_A[6] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[6];    
                    RDACCESS_A_out = wire_RDACCESS_A[6];
                end
                4'b0111  : begin
                    wire_ADDR_A[7] = ADDR_A[11:0];      
                  wire_RDB_WR_A[7] = RDB_WR_A;          
                     wire_BWE_A[7] = BWE_A;             
                     wire_DIN_A[7] = DIN_A;             
                      wire_EN_A[7] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[7];    
                    RDACCESS_A_out = wire_RDACCESS_A[7];
                end                                     
                4'b1000  : begin     
                    wire_ADDR_A[8] = ADDR_A[11:0];      
                  wire_RDB_WR_A[8] = RDB_WR_A;          
                     wire_BWE_A[8] = BWE_A;             
                     wire_DIN_A[8] = DIN_A;             
                      wire_EN_A[8] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[8];    
                    RDACCESS_A_out = wire_RDACCESS_A[8];                 
                end                  
                4'b1001  : begin      
                    wire_ADDR_A[9] = ADDR_A[11:0];      
                  wire_RDB_WR_A[9] = RDB_WR_A;          
                     wire_BWE_A[9] = BWE_A;             
                     wire_DIN_A[9] = DIN_A;             
                      wire_EN_A[9] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[9];    
                    RDACCESS_A_out = wire_RDACCESS_A[9];                 
                end  
                4'b1010  : begin    
                    wire_ADDR_A[10] = ADDR_A[11:0];      
                  wire_RDB_WR_A[10] = RDB_WR_A;          
                     wire_BWE_A[10] = BWE_A;             
                     wire_DIN_A[10] = DIN_A;             
                      wire_EN_A[10] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[10];    
                    RDACCESS_A_out = wire_RDACCESS_A[10];                   
                end                 
                4'b1011  : begin    
                    wire_ADDR_A[11] = ADDR_A[11:0];      
                  wire_RDB_WR_A[11] = RDB_WR_A;          
                     wire_BWE_A[11] = BWE_A;             
                     wire_DIN_A[11] = DIN_A;             
                      wire_EN_A[11] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[11];    
                    RDACCESS_A_out = wire_RDACCESS_A[11];                   
                end                 
                4'b1100  : begin    
                    wire_ADDR_A[12] = ADDR_A[11:0];             
                  wire_RDB_WR_A[12] = RDB_WR_A;                     
                     wire_BWE_A[12] = BWE_A;                        
                     wire_DIN_A[12] = DIN_A;                        
                      wire_EN_A[12] = EN_A;                         
                       DOUT_A_out  = wire_DOUT_A[12];                                
                    RDACCESS_A_out = wire_RDACCESS_A[12];                            
                end  
                4'b1101  : begin    
                    wire_ADDR_A[13] = ADDR_A[11:0];      
                  wire_RDB_WR_A[13] = RDB_WR_A;          
                     wire_BWE_A[13] = BWE_A;             
                     wire_DIN_A[13] = DIN_A;             
                      wire_EN_A[13] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[13];    
                    RDACCESS_A_out = wire_RDACCESS_A[13];                      
                end                 
                4'b1110  : begin    
                    wire_ADDR_A[14] = ADDR_A[11:0];      
                  wire_RDB_WR_A[14] = RDB_WR_A;          
                     wire_BWE_A[14] = BWE_A;             
                     wire_DIN_A[14] = DIN_A;             
                      wire_EN_A[14] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[14];    
                    RDACCESS_A_out = wire_RDACCESS_A[14];                                  
                end                 
                4'b1111  : begin   
                    wire_ADDR_A[15] = ADDR_A[11:0];      
                  wire_RDB_WR_A[15] = RDB_WR_A;          
                     wire_BWE_A[15] = BWE_A;             
                     wire_DIN_A[15] = DIN_A;             
                      wire_EN_A[15] = EN_A;              
                       DOUT_A_out  = wire_DOUT_A[15];    
                    RDACCESS_A_out = wire_RDACCESS_A[15];
                    end                                                                            
        endcase
        end
    end
    // B 
    always@(posedge clk)begin
        if(!rst_n)begin
            for(int i = 0; i < cascade_level; i++)begin
                wire_ADDR_B[i]=0;     
                wire_BWE_B[i]=0;         
                wire_DIN_B[i]=0;               
                wire_EN_B[i]=0;           
                wire_RDB_WR_B[i]=0;               
            end
        end
        else begin                                                    
            case(choose_B)                                  
            4'b0000  :begin                                 
                wire_ADDR_B[0] = ADDR_B[11:0];              
              wire_RDB_WR_B[0] = RDB_WR_B;                  
                 wire_BWE_B[0] = BWE_B;                     
                 wire_DIN_B[0] = DIN_B;                     
                  wire_EN_B[0] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[0];            
                RDACCESS_B_out = wire_RDACCESS_B[0];        
                                                            
            end                                             
            4'b0001  :begin                                 
                wire_ADDR_B[1] = ADDR_B[11:0];              
              wire_RDB_WR_B[1] = RDB_WR_B;                  
                 wire_BWE_B[1] = BWE_B;                     
                 wire_DIN_B[1] = DIN_B;                     
                  wire_EN_B[1] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[1];            
                RDACCESS_B_out = wire_RDACCESS_B[1];        
            end                                             
            4'b0010  :begin                                 
                wire_ADDR_B[2] = ADDR_B[11:0];              
              wire_RDB_WR_B[2] = RDB_WR_B;                  
                 wire_BWE_B[2] = BWE_B;                     
                 wire_DIN_B[2] = DIN_B;                     
                  wire_EN_B[2] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[2];            
                RDACCESS_B_out = wire_RDACCESS_B[2];        
            end                                             
            4'b0011  : begin                                
                wire_ADDR_B[3] = ADDR_B[11:0];              
              wire_RDB_WR_B[3] = RDB_WR_B;                  
                 wire_BWE_B[3] = BWE_B;                     
                 wire_DIN_B[3] = DIN_B;                     
                  wire_EN_B[3] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[3];            
                RDACCESS_B_out = wire_RDACCESS_B[3];        
            end                                             
            4'b0100  :begin                                 
                wire_ADDR_B[4] = ADDR_B[11:0];              
              wire_RDB_WR_B[4] = RDB_WR_B;                  
                 wire_BWE_B[4] = BWE_B;                     
                 wire_DIN_B[4] = DIN_B;                     
                  wire_EN_B[4] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[4];            
                RDACCESS_B_out = wire_RDACCESS_B[4];        
            end                                             
            4'b0101  : begin                                
                wire_ADDR_B[5] = ADDR_B[11:0];              
              wire_RDB_WR_B[5] = RDB_WR_B;                  
                 wire_BWE_B[5] = BWE_B;                     
                 wire_DIN_B[5] = DIN_B;                     
                  wire_EN_B[5] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[5];            
                RDACCESS_B_out = wire_RDACCESS_B[5];        
            end                                             
            4'b0110  : begin                                
                wire_ADDR_B[6] = ADDR_B[11:0];              
              wire_RDB_WR_B[6] = RDB_WR_B;                  
                 wire_BWE_B[6] = BWE_B;                     
                 wire_DIN_B[6] = DIN_B;                     
                  wire_EN_B[6] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[6];            
                RDACCESS_B_out = wire_RDACCESS_B[6];        
            end                                             
            4'b0111  : begin                                
                wire_ADDR_B[7] = ADDR_B[11:0];              
              wire_RDB_WR_B[7] = RDB_WR_B;                  
                 wire_BWE_B[7] = BWE_B;                     
                 wire_DIN_B[7] = DIN_B;                     
                  wire_EN_B[7] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[7];            
                RDACCESS_B_out = wire_RDACCESS_B[7];        
            end                                             
            4'b1000  : begin                                
                wire_ADDR_B[8] = ADDR_B[11:0];              
              wire_RDB_WR_B[8] = RDB_WR_B;                  
                 wire_BWE_B[8] = BWE_B;                     
                 wire_DIN_B[8] = DIN_B;                     
                  wire_EN_B[8] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[8];            
                RDACCESS_B_out = wire_RDACCESS_B[8];        
            end                                             
            4'b1001  : begin                                
                wire_ADDR_B[9] = ADDR_B[11:0];              
              wire_RDB_WR_B[9] = RDB_WR_B;                  
                 wire_BWE_B[9] = BWE_B;                     
                 wire_DIN_B[9] = DIN_B;                     
                  wire_EN_B[9] = EN_B;                      
                   DOUT_B_out  = wire_DOUT_B[9];            
                RDACCESS_B_out = wire_RDACCESS_B[9];        
            end                                             
            4'b1010  : begin                                
                wire_ADDR_B[10] = ADDR_B[11:0];             
              wire_RDB_WR_B[10] = RDB_WR_B;                 
                 wire_BWE_B[10] = BWE_B;                    
                 wire_DIN_B[10] = DIN_B;                    
                  wire_EN_B[10] = EN_B;                     
                   DOUT_B_out  = wire_DOUT_B[10];           
                RDACCESS_B_out = wire_RDACCESS_B[10];       
            end                                             
            4'b1011  : begin                                
                wire_ADDR_B[11] = ADDR_B[11:0];             
              wire_RDB_WR_B[11] = RDB_WR_B;                 
                 wire_BWE_B[11] = BWE_B;                    
                 wire_DIN_B[11] = DIN_B;                    
                  wire_EN_B[11] = EN_B;                     
                   DOUT_B_out  = wire_DOUT_B[11];            
                RDACCESS_B_out = wire_RDACCESS_B[11];       
            end                                             
            4'b1100  : begin                                
                wire_ADDR_B[12] = ADDR_B[11:0];             
              wire_RDB_WR_B[12] = RDB_WR_B;                 
                 wire_BWE_B[12] = BWE_B;                    
                 wire_DIN_B[12] = DIN_B;                    
                  wire_EN_B[12] = EN_B;                     
                   DOUT_B_out  = wire_DOUT_B[12];           
                RDACCESS_B_out = wire_RDACCESS_B[12];       
            end                                             
            4'b1101  : begin                                
                wire_ADDR_B[13] = ADDR_B[11:0];             
              wire_RDB_WR_B[13] = RDB_WR_B;                 
                 wire_BWE_B[13] = BWE_B;                    
                 wire_DIN_B[13] = DIN_B;                    
                  wire_EN_B[13] = EN_B;                     
                   DOUT_B_out  = wire_DOUT_B[13];           
                RDACCESS_B_out = wire_RDACCESS_B[13];       
            end                                             
            4'b1110  : begin                                
                wire_ADDR_B[14] = ADDR_B[11:0];             
              wire_RDB_WR_B[14] = RDB_WR_B;                 
                 wire_BWE_B[14] = BWE_B;                    
                 wire_DIN_B[14] = DIN_B;                    
                  wire_EN_B[14] = EN_B;                     
                   DOUT_B_out  = wire_DOUT_B[14];           
                RDACCESS_B_out = wire_RDACCESS_B[14];       
            end                                             
            4'b1111  : begin                                
                wire_ADDR_B[15] = ADDR_B[11:0];             
              wire_RDB_WR_B[15] = RDB_WR_B;                 
                 wire_BWE_B[15] = BWE_B;                    
                 wire_DIN_B[15] = DIN_B;                    
                  wire_EN_B[15] = EN_B;                     
                   DOUT_B_out  = wire_DOUT_B[15];           
                RDACCESS_B_out = wire_RDACCESS_B[15];       
            end                                             
            endcase 
        end                                        
    end                                                    
    
    generate for (genvar i = 0; i < cascade_level; i++) begin
        URAM288_BASE #(
          .AUTO_SLEEP_LATENCY(8),            // Latency requirement to enter sleep mode
          .AVG_CONS_INACTIVE_CYCLES(10),     // Average consecutive inactive cycles when is SLEEP mode for power
                                             // estimation
          .BWE_MODE_A("PARITY_INTERLEAVED"), // Port A Byte write control
          .BWE_MODE_B("PARITY_INTERLEAVED"), // Port B Byte write control
          .EN_AUTO_SLEEP_MODE("FALSE"),      // Enable to automatically enter sleep mode
          .EN_ECC_RD_A("FALSE"),             // Port A ECC encoder
          .EN_ECC_RD_B("FALSE"),             // Port B ECC encoder
          .EN_ECC_WR_A("FALSE"),             // Port A ECC decoder
          .EN_ECC_WR_B("FALSE"),             // Port B ECC decoder
          .IREG_PRE_A("FALSE"),              // Optional Port A input pipeline registers
          .IREG_PRE_B("FALSE"),              // Optional Port B input pipeline registers
          .IS_CLK_INVERTED(1'b0),            // Optional inverter for CLK
          .IS_EN_A_INVERTED(1'b0),           // Optional inverter for Port A enable
          .IS_EN_B_INVERTED(1'b0),           // Optional inverter for Port B enable
          .IS_RDB_WR_A_INVERTED(1'b0),       // Optional inverter for Port A read/write select
          .IS_RDB_WR_B_INVERTED(1'b0),       // Optional inverter for Port B read/write select
          .IS_RST_A_INVERTED(1'b0),          // Optional inverter for Port A reset
          .IS_RST_B_INVERTED(1'b0),          // Optional inverter for Port B reset
          .OREG_A("FALSE"),                  // Optional Port A output pipeline registers
          .OREG_B("FALSE"),                  // Optional Port B output pipeline registers
          .OREG_ECC_A("FALSE"),              // Port A ECC decoder output
          .OREG_ECC_B("FALSE"),              // Port B output ECC decoder
          .RST_MODE_A("SYNC"),               // Port A reset mode
          .RST_MODE_B("SYNC"),               // Port B reset mode
          .USE_EXT_CE_A("FALSE"),            // Enable Port A external CE inputs for output registers
          .USE_EXT_CE_B("FALSE")             // Enable Port B external CE inputs for output registers
       )
       URAM288_BASE_inst (
          .DOUT_A(wire_DOUT_A[i]),                     // 72-bit output: Port A read data output
          .DOUT_B(wire_DOUT_B[i]),                     // 72-bit output: Port B read data output
          .ADDR_A(wire_ADDR_A[i]),                     // 23-bit input: Port A address
          .ADDR_B(wire_ADDR_B[i]),                     // 23-bit input: Port B address
          .BWE_A(wire_BWE_A[i]),                       // 9-bit input: Port A Byte-write enable
          .BWE_B(wire_BWE_B[i]),                       // 9-bit input: Port B Byte-write enable
          .CLK(clk),                           // 1-bit input: Clock source
          .RDACCESS_A(wire_RDACCESS_A[i]),                 // 1-bit output: Port A read status
          .RDACCESS_B(wire_RDACCESS_B[i]),                 // 1-bit output: Port B read status
          .DIN_A(wire_DIN_A[i]),                       // 72-bit input: Port A write data input
          .DIN_B(wire_DIN_B[i]),                       // 72-bit input: Port B write data input
          .EN_A(wire_EN_A[i]),                         // 1-bit input: Port A enable
          .EN_B(wire_EN_B[i]),                         // 1-bit input: Port B enable
          .INJECT_DBITERR_A(1'b0), // 1-bit input: Port A double-bit error injection
          .INJECT_DBITERR_B(1'b0), // 1-bit input: Port B double-bit error injection
          .INJECT_SBITERR_A(1'b0), // 1-bit input: Port A single-bit error injection
          .INJECT_SBITERR_B(1'b0), // 1-bit input: Port B single-bit error injection
          .OREG_CE_A(1'b1),                   // 1-bit input: Port A output register clock enable           
          .OREG_CE_B(1'b1),                   // 1-bit input: Port B output register clock enable           
          .OREG_ECC_CE_A(1'b1),           // 1-bit input: Port A ECC decoder output register clock enable   
          .OREG_ECC_CE_B(1'b1),           // 1-bit input: Port B ECC decoder output register clock enable   
          .RDB_WR_A(wire_RDB_WR_A[i]),                 // 1-bit input: Port A read/write select
          .RDB_WR_B(wire_RDB_WR_B[i]),                 // 1-bit input: Port B read/write select
          .RST_A(rst),                       // 1-bit input: Port A asynchronous or synchronous reset for output
                                                   // registers
          .RST_B(rst),                       // 1-bit input: Port B asynchronous or synchronous reset for output
                                               // registers
          .SLEEP(1'b0)                        // 1-bit input: Dynamic power gating control
       );
    end
    endgenerate

endmodule
