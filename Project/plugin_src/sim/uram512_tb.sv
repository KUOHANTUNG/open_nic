`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/15 19:49:44
// Design Name: 
// Module Name: uram512_tb
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


module uram512_tb;

        logic [22:0]  addr_a;    
        logic [22:0]  addr_b;    
                   
        logic [575:0] tx_data_a; 
        logic [575:0] tx_data_b; 
                   
        logic [575:0] rx_data_a; 
        logic [575:0] rx_data_b; 
                  
        logic         clk;       
        logic         rst_n;     
        logic         rdb_wr_a; 
        logic         rdb_wr_b;  
        logic         en_a;      
        logic         en_b;           
    
    uram512 uram512_tb(
         .addr_a(addr_a),     
         .addr_b(addr_b),                 
         .tx_data_a(tx_data_a),  
         .tx_data_b(tx_data_b),           
         .rx_data_a(rx_data_a),  
         .rx_data_b(rx_data_b),            
         .clk(clk),        
         .rst_n(rst_n),      
         .rdb_wr_a(rdb_wr_a),   
         .rdb_wr_b(rdb_wr_b),       
         .en_a(en_a),       
         .en_b(en_b)        
    );
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
        en_a = 1'b1;
        en_b = 1'b1;
        rdb_wr_a = 1'b0;
        rdb_wr_b = 1'b0;
        addr_a = 'b0;
        addr_b = 'b0;
        
        #100
        rdb_wr_a = 1'b1;
        tx_data_a = 575'b1;
        addr_a = 'hA;
        #50
        addr_b = 'hA;
    end

endmodule
