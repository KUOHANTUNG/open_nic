`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/28 23:10:54
// Design Name: 
// Module Name: pick8_indices16
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


module pick8_indices16(
    input  logic [15:0]     m_in,
    output logic [7:0][3:0] idx,
    output logic [3:0]      cnt
);
    logic [15:0] m [0:8];
    integer i;

    function automatic logic [3:0] lsb_index16(input logic [15:0] m);
        int k;
        begin
            lsb_index16 = 4'd0;           
            for (k = 0; k < 16; k++) begin
                if (m[k]) begin
                    lsb_index16 = k[3:0];
                    return lsb_index16;
                end
            end
        end
    endfunction

    always_comb begin
        m[0] = ~m_in;
        cnt  = 4'd0;
        for (i = 0; i < 8; i++) begin
            if (m[i] != 16'b0) begin
                idx[i] = lsb_index16(m[i]);
                m[i+1] = m[i] & (m[i] - 16'b1); 
                cnt    = cnt + 1'b1;
            end else begin
                idx[i] = 4'd0;
                m[i+1] = 16'd0;
            end
        end
    end
endmodule

