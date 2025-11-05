`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/04 22:28:47
// Design Name: 
// Module Name: comparer
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
module comparer#(
     parameter cache_depth = 8
)(
    input               axis_clk,
    input               axis_rstn,   
    
    input               cache_key_valid,
    input  [63:0]       cache_key,
    output reg          cache_key_ready,
    
    input               compare_key_valid,
    input  [63:0]       compare_key,
    input               compare_opcode,  // 0: report&delete, 1: delete only
    output reg          compare_key_ready,
   
    output reg          out_key_valid,
    output reg [63:0]   out_key,
    input               out_key_ready,
   
    output reg                          result_valid,
    input                               result_ready,
    output reg [cache_depth-1:0]        result
    );
    
    reg [63:0]  caches[cache_depth - 1:0];
    reg [cache_depth-1:0] caches_state;   
    reg [31:0]  head, tail;
    // compare

    integer i;
    always @(posedge axis_clk) begin
        if (!axis_rstn) begin
            compare_key_ready <= 1'b1;
            result_valid      <= 1'b0;
            result            <= '0;
        end else begin
            if (result_valid && result_ready) begin
                result_valid      <= 1'b0;
                result            <= '0;
                compare_key_ready <= 1'b1;
            end
            if (compare_key_valid && compare_key_ready) begin
                compare_key_ready <= 1'b0;  
                result_valid      <= 1'b1;
                result            <= '0;   
                for (i = 0; i < cache_depth; i = i + 1) begin
                    if (caches_state[i] && caches[i] == compare_key) begin
                        if (!compare_opcode) begin
                            result[i] <= 1'b1;
                        end
                        caches[i]       <= '0;
                        caches_state[i] <= 1'b0;
                    end
                end
            end
        end
    end
    // enqueue

    always @(posedge axis_clk) begin
        if (!axis_rstn) begin
            cache_key_ready <= 1'b1;
            head            <= '0;
            caches_state    <= '0;
            for (i = 0; i < cache_depth; i = i + 1) begin
                caches[i] <= '0;
            end
        end else begin
            if (cache_key_ready && cache_key_valid) begin
                caches[      head & (cache_depth - 1)] <= cache_key;
                caches_state[head & (cache_depth - 1)] <= 1'b1;
                head <= head + 1;              
            end
        end
    end


    // deque

    wire [31:0] head_idx = head & (cache_depth - 1);
    wire [31:0] tail_idx = tail & (cache_depth - 1);

    always @(posedge axis_clk) begin
        if (!axis_rstn) begin
            out_key_valid <= 1'b0;
            out_key       <= '0;
            tail          <= '0;
        end else begin
            if (out_key_valid && out_key_ready) begin
                out_key_valid <= 1'b0;
                tail          <= tail + 1;   
            end
            if (head_idx != tail_idx) begin
                if (!out_key_valid) begin
                    if (caches_state[tail_idx]) begin
                        out_key_valid <= 1'b1;
                        out_key       <= caches[tail_idx];
                    end else begin
                        tail <= tail + 1;
                    end
                end
            end else begin
                out_key_valid <= 1'b0;
            end
        end
    end
endmodule

