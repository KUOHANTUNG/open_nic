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
    input               rst,
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
    
     generate for (genvar i = 1; i < cascade_level; i++) begin
     
     
     
     
     
     
     
     
     
     end
    
endmodule
