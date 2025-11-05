`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/05 09:59:55
// Design Name: 
// Module Name: front_end_transit
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


module front_end_transit#(
    parameter FIFO_WIDTH = 8,
    parameter cache_depth = 8
)(
    input                         clk,
    input                         rst_n,
    
    input                         s_key_valid,
    input[63:0]                   s_key,
    output                        s_key_ready,
    
    input[511:0]                  s_value_data,       
    input                         s_value_valid,         
    input[15:0]                   s_value_length,        
    input                         s_value_last,          
    output reg                    s_value_ready,
    input[15:0]                   s_malloc_data,
    input                         s_malloc_valid,
    output reg                    s_malloc_ready,
    
    output reg                    m_compare_key_valid,
    output reg [63:0]             m_compare_key,
    output reg                    m_compare_opcode,
    input                         m_compare_key_ready,
    
    input                         s_compare_result_valid,
    input   [cache_depth-1:0]     s_compare_result,
    output reg                    s_compare_result_ready,
        
    output                        m_axis_ram_adapter_tvalid,
    output [511:0]                m_axis_ram_adapter_tdata,
    output [63:0]                 m_axis_ram_adapter_tkeep,
    output                        m_axis_ram_adapter_tlast,
    output [15:0]                 m_axis_ram_adapter_tuser_size,
    output [15:0]                 m_axis_ram_adapter_tuser_src,
    output [15:0]                 m_axis_ram_adapter_tuser_dst,
    input                         m_axis_ram_adapter_tready,
    
    output                        m_axis_ram_host_tvalid,
    output [511:0]                m_axis_ram_host_tdata,
    output [63:0]                 m_axis_ram_host_tkeep,
    output                        m_axis_ram_host_tlast,
    output [15:0]                 m_axis_ram_host_tuser_size,
    output [15:0]                 m_axis_ram_host_tuser_src,
    output [15:0]                 m_axis_ram_host_tuser_dst,
    input                         m_axis_ram_host_tready,
    
    input  [95:0]                 s_meta_data,
	input                         s_meta_valid,
	output   reg                     s_meta_ready,
	
	input  [15:0]                 s_alloc_data,
	input                         s_alloc_valid,
	output                        s_alloc_ready
    );
    wire free_ready, alloc_ready;
    logic [15:0] alloc_request;
    logic       alloc_valid;
    assign    s_alloc_ready = alloc_ready;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            s_meta_ready<=1;
        end
        else begin
            if(s_meta_valid && s_meta_ready)begin
                s_meta_ready<=0;
                //insert
                if(s_meta_data[95:88] == 1)begin
                    if(alloc_valid && alloc_ready)begin
                        alloc_valid <= 1'b0;
                    end
                    if(s_alloc_ready && s_alloc_valid)begin
                        alloc_request <= s_alloc_data;
                        alloc_valid <= 1'b1;
                    end
                end
                else begin
                    
                end
            end
        end
    end
    allocator#(
    .cache_depth(16),  
    .MEMORY_WIDTH(512),
    .CLASS_COUNT(4),   
    .BLOCKSIZE(64) //B    
    )allocator_inst(
     .clk           (clk),     
     .rst_n         (rst_n),   
              
     .req_valid     (),
     .req_data      (),
     .req_ready     (),
              
     .alloc_pointer (alloc_request),
     .alloc_valid   (alloc_valid),
     .alloc_ready   (alloc_ready),
              
     .free_pointer  (),
     .free_valid    (), 
     .free_ready    (free_ready)     
    );

 
    
    
    
    
    
    
endmodule
