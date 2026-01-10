`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/04 10:02:26
// Design Name: 
// Module Name: ram_testbench
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


module ram_testbench;
reg     clk;
    reg     rst_n;
    // Port A INPUT
    reg                 s_axis_rx_valid_a;
    reg  [511:0]        s_axis_rx_data_a;
    wire                s_axis_rx_ready_a;

    // Port A OUTPUT
    wire                s_axis_tx_valid_a;
    wire [511:0]        s_axis_tx_data_a;
    reg                 s_axis_tx_ready_a;
    reg  [15:0]         s_axis_addr_a;
    reg                 read_or_write_a;   // 0: read, 1: write

    // Port B INPUT
    reg                 s_axis_rx_valid_b;
    reg  [511:0]        s_axis_rx_data_b;
    wire                s_axis_rx_ready_b;

    // Port B OUTPUT
    wire                s_axis_tx_valid_b;
    wire [511:0]        s_axis_tx_data_b;
    reg                 s_axis_tx_ready_b;
    reg  [15:0]         s_axis_addr_b;
    reg                 read_or_write_b;    // 0: read, 1: write

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end
    initial begin
        rst_n = 1'b0;
        #200;                  
        rst_n = 1'b1;
    end
    
    initial begin
        #800
                    @(posedge clk)begin
                s_axis_rx_valid_b = 1;
                s_axis_rx_data_b = {512{1'b1}};
                s_axis_addr_b = 16'h0000;
                read_or_write_b = 1;
                end
//            for(int i = 0; i < 4; i ++)begin
//            @(posedge clk)begin
//                s_axis_rx_valid_b = 1;
//                s_axis_rx_data_b = {512{1'b1}};
//                s_axis_addr_b = 16'hC000;
//                read_or_write_b = 1;
//                end
//                @(posedge clk)begin
//                s_axis_rx_valid_b = 1;
//                s_axis_rx_data_b = {'0,{32{1'b1}}};
//                s_axis_addr_b = 16'hC000;
//                read_or_write_b = 1;            
//                end
//            end
            @(posedge clk)begin
            read_or_write_b = 0;
            s_axis_rx_valid_b = 0;
            end
            #500
            wait(s_axis_rx_ready_a);
                s_axis_tx_ready_a = 1;
                s_axis_rx_valid_a = 1;
                s_axis_addr_a = 16'h0000;
                read_or_write_a = 0;
    end
    
    
// A read B wirte
ram ram_tbt(
    .clk(clk),                                   
    .rst_n(rst_n),                                   
                                           
    .s_axis_rx_valid_a(s_axis_rx_valid_a),                       
    .s_axis_rx_data_a(s_axis_rx_data_a),                        
    .s_axis_rx_ready_a(s_axis_rx_ready_a),                       
                                            
    .s_axis_tx_valid_a(s_axis_tx_valid_a),                       
    .s_axis_tx_data_a(s_axis_tx_data_a),                        
    .s_axis_tx_ready_a(s_axis_tx_ready_a),                       
    .s_axis_addr_a(s_axis_addr_a),                           
    .read_or_write_a(read_or_write_a),   // 0: read, 1: write  
                                           
    .s_axis_rx_valid_b(s_axis_rx_valid_b),                       
    .s_axis_rx_data_b(s_axis_rx_data_b),                        
    .s_axis_rx_ready_b(s_axis_rx_ready_b),                       
                                            
    .s_axis_tx_valid_b(s_axis_tx_valid_b),                       
    .s_axis_tx_data_b(s_axis_tx_data_b),                        
    .s_axis_tx_ready_b(s_axis_tx_ready_b),                       
    .s_axis_addr_b(s_axis_addr_b),                           
    .read_or_write_b(read_or_write_b)    // 0: read, 1: write  
);


endmodule
