`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/05 12:11:22
// Design Name: 
// Module Name: popcount8
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


module popcount8(
    input  logic        en,
    input  logic [7:0]  in,
    output logic [3:0]  cnt
);
    integer i;

    always_comb begin
        if (!en) begin
            cnt = 4'd0;
        end else begin
            cnt = '0;
            for (i=0;i<8;i++) begin
                cnt += in[i];
            end
        end
    end
endmodule

