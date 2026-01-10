`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/30 10:47:58
// Design Name: 
// Module Name: allocator_tb
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


module allocator_tb;
    reg                         clk;
    reg                         rst_n;    
  
    reg                         req_valid;
    reg         [15:0]          req_data;
    wire                        req_ready;
    
    wire        [15:0]          alloc_pointer;
    wire 	                    alloc_valid;
	reg  	                    alloc_ready;
	
    reg         [15:0]          free_pointer;
	reg  	                    free_valid;
	wire 		                free_ready;
    
    
    
    
    
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
        #500
        if(req_ready)begin
            req_valid = 1'b1;
            req_data = 16'h40;
            alloc_ready = 1'b1;
        end
//        #100
//        if(free_ready)begin
//            free_pointer = 1;
//            free_valid = 1;
//        end
//        #4
//        if(!free_ready & free_valid)
//            free_valid = 0;
//        #4 
//        if(req_ready)begin
//            req_valid = 1'b1;
//            req_data = 16'h40;
//            alloc_ready = 1'b1;
//        end   
        #10000
        $stop;
    end

alloc#(
    .cache_depth(16),  
    .MEMORY_WIDTH(512),
    .CLASS_COUNT(4),   
    .BLOCKSIZE(64) //B    
)allocator_tb(
     .clk           (clk),     
     .rst_n         (rst_n),   
              
     .req_valid     (req_valid),
     .req_data      (req_data),
     .req_ready     (req_ready),
              
     .alloc_pointer (alloc_pointer),
     .alloc_valid   (alloc_valid),
     .alloc_ready   (alloc_ready),
              
     .free_pointer  (free_pointer),
     .free_valid    (free_valid), 
     .free_ready    (free_ready)     
);
endmodule
