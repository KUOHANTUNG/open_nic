`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/05 16:45:15
// Design Name: 
// Module Name: fifo
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


module fifo #(
    parameter DATA_WIDTH = 64,
    parameter FIFO_DEPTH = 8
) (
    input                       axis_clk,
    input                       axis_rstn,

    input                       s_axis_valid,
    input  [DATA_WIDTH-1:0]     s_axis_data,
    output                      s_axis_ready,

    output                      m_axis_valid,
    output [DATA_WIDTH-1:0]     m_axis_data,
    input                       m_axis_ready
);
    localparam ADDR_W = $clog2(FIFO_DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
    reg [ADDR_W:0]       wr_ptr;  
    reg [ADDR_W:0]       rd_ptr;

    wire [ADDR_W-1:0] wr_idx = wr_ptr[ADDR_W-1:0];
    wire [ADDR_W-1:0] rd_idx = rd_ptr[ADDR_W-1:0];

    wire empty = (wr_ptr == rd_ptr);
    wire full  = (wr_ptr[ADDR_W]     != rd_ptr[ADDR_W]) &&
                 (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]);

    assign s_axis_ready = !full;
    assign m_axis_valid = !empty;
    assign m_axis_data  = mem[rd_idx];

    always_ff @(posedge axis_clk or negedge axis_rstn) begin
        if (!axis_rstn) begin
            wr_ptr <= '0;
        end else begin
            if (s_axis_valid && s_axis_ready) begin
                mem[wr_idx] <= s_axis_data;
                wr_ptr      <= wr_ptr + 1'b1;
            end
        end
    end

    always_ff @(posedge axis_clk or negedge axis_rstn) begin
        if (!axis_rstn) begin
            rd_ptr <= '0;
        end else begin
            if (m_axis_valid && m_axis_ready) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end
endmodule

