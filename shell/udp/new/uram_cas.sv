`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/20 13:11:11
// Design Name: 
// Module Name: uram_cas
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


module uram_cas#(
    parameter cascade_level = 16,
    parameter addr_mask = 11'h7f0
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
   
    // 7 uram casade to save one row of output of systolic array (226*226*32). 
    // 64 * (2 ^ 12) * 7 - 226 * 226 * 32 >= 0

    logic [23 - 1 : 0]     CAS_ADDR_A[cascade_level:0];
    logic [23 - 1 : 0]     CAS_ADDR_B[cascade_level:0];
    logic [9 - 1 : 0]       CAS_BWE_A[cascade_level:0];
    logic [9 - 1 : 0]       CAS_BWE_B[cascade_level:0];
    logic [1 - 1 : 0]   CAS_DBITERR_A[cascade_level:0];
    logic [1 - 1 : 0]   CAS_DBITERR_B[cascade_level:0];
    logic [72 - 1 : 0]      CAS_DIN_A[cascade_level:0];
    logic [72 - 1 : 0]      CAS_DIN_B[cascade_level:0];
    logic [72 - 1 : 0]     CAS_DOUT_A[cascade_level:0];
    logic [72 - 1 : 0]     CAS_DOUT_B[cascade_level:0];
    logic [1 - 1 : 0]        CAS_EN_A[cascade_level:0];
    logic [1 - 1 : 0]        CAS_EN_B[cascade_level:0];
    logic [1 - 1 : 0]  CAS_RDACCESS_A[cascade_level:0];
    logic [1 - 1 : 0]  CAS_RDACCESS_B[cascade_level:0];
    logic [1 - 1 : 0]    CAS_RDB_WR_A[cascade_level:0];
    logic [1 - 1 : 0]    CAS_RDB_WR_B[cascade_level:0];
    logic [1 - 1 : 0]   CAS_SBITERR_A[cascade_level:0];
    logic [1 - 1 : 0]   CAS_SBITERR_B[cascade_level:0];
    logic [1 - 1 : 0]   CAS_RST      [cascade_level:0];
    assign  CAS_ADDR_A[0] = 0;
    assign  CAS_ADDR_B[0] = 0;
    assign  CAS_BWE_A[0] = 0;
    assign  CAS_BWE_B[0] = 0;
    assign  CAS_DBITERR_A[0] = 0;
    assign  CAS_DBITERR_B[0] = 0;
    assign  CAS_DIN_A[0] = 0;
    assign  CAS_DIN_B[0] = 0;
    assign  CAS_DOUT_A[0] = 0;
    assign  CAS_DOUT_B[0] = 0;
    assign  CAS_EN_A[0] = 0;
    assign  CAS_EN_B[0] = 0;
    assign  CAS_RDACCESS_A[0] = 0;
    assign  CAS_RDACCESS_B[0] = 0;
    assign  CAS_RDB_WR_A[0] = 0;
    assign  CAS_RDB_WR_B[0] = 0;
    assign  CAS_SBITERR_A[0] = 0;
    assign  CAS_SBITERR_B[0] = 0;
   //  assign  CAS_RST[0] = rst;

    /* always_ff @(posedge clk) begin
      CAS_RST[cascade_level:0] <= {CAS_RST[cascade_level - 1:0], rst};
    end */

   generate
      for (genvar i = 0; i < cascade_level + 1; i++) begin
         assign CAS_RST[i] = 0;
      end
   endgenerate

    generate 
    for (genvar i = 0; i < cascade_level; i++) begin : uram_cascade
        if (i == 0) begin
            URAM288 #(
              .AUTO_SLEEP_LATENCY(8),            // Latency requirement to enter sleep mode
              .AVG_CONS_INACTIVE_CYCLES(10),     // Average consecutive inactive cycles when is SLEEP mode for power
                                                 // estimation
              .BWE_MODE_A("PARITY_INDEPENDENT"), // Port A Byte write control
              .BWE_MODE_B("PARITY_INDEPENDENT"), // Port B Byte write control
              .CASCADE_ORDER_A("FIRST"),          // Port A position in cascade chain
              .CASCADE_ORDER_B("FIRST"),          // Port B position in cascade chain
              .EN_AUTO_SLEEP_MODE("FALSE"),      // Enable to automatically enter sleep mode
              .EN_ECC_RD_A("FALSE"),             // Port A ECC encoder
              .EN_ECC_RD_B("FALSE"),             // Port B ECC encoder
              .EN_ECC_WR_A("FALSE"),             // Port A ECC decoder
              .EN_ECC_WR_B("FALSE"),             // Port B ECC decoder
              .IREG_PRE_A("TRUE"),              // Optional Port A input pipeline registers
              .IREG_PRE_B("TRUE"),              // Optional Port B input pipeline registers
              .IS_CLK_INVERTED(1'b0),            // Optional inverter for CLK
              .IS_EN_A_INVERTED(1'b0),           // Optional inverter for Port A enable
              .IS_EN_B_INVERTED(1'b0),           // Optional inverter for Port B enable
              .IS_RDB_WR_A_INVERTED(1'b0),       // Optional inverter for Port A read/write select
              .IS_RDB_WR_B_INVERTED(1'b0),       // Optional inverter for Port B read/write select
              .IS_RST_A_INVERTED(1'b0),          // Optional inverter for Port A reset
              .IS_RST_B_INVERTED(1'b0),          // Optional inverter for Port B reset
              .OREG_A("TRUE"),                  // Optional Port A output pipeline registers
              .OREG_B("TRUE"),                  // Optional Port B output pipeline registers
              .OREG_ECC_A("FALSE"),              // Port A ECC decoder output
              .OREG_ECC_B("FALSE"),              // Port B output ECC decoder
              .REG_CAS_A("FALSE"),               // Optional Port A cascade register
              .REG_CAS_B("FALSE"),               // Optional Port B cascade register
              .RST_MODE_A("SYNC"),               // Port A reset mode
              .RST_MODE_B("SYNC"),               // Port B reset mode
              .SELF_ADDR_A(11'h000),             // Port A self-address value
              .SELF_ADDR_B(11'h000),             // Port B self-address value
              .SELF_MASK_A(addr_mask),             // Port A self-address mask
              .SELF_MASK_B(addr_mask),             // Port B self-address mask
              .USE_EXT_CE_A("FALSE"),            // Enable Port A external CE inputs for output registers
              .USE_EXT_CE_B("FALSE")             // Enable Port B external CE inputs for output registers
           )
           URAM288_inst (
              .CAS_OUT_ADDR_A(CAS_ADDR_A[i + 1]),         // 23-bit output: Port A cascade output address
              .CAS_OUT_ADDR_B(CAS_ADDR_B[i + 1]),         // 23-bit output: Port B cascade output address
              .CAS_OUT_BWE_A(CAS_BWE_A[i + 1]),           // 9-bit output: Port A cascade Byte-write enable output
              .CAS_OUT_BWE_B(CAS_BWE_B[i + 1]),           // 9-bit output: Port B cascade Byte-write enable output
              .CAS_OUT_DBITERR_A(CAS_DBITERR_A[i + 1]),   // 1-bit output: Port A cascade double-bit error flag output
              .CAS_OUT_DBITERR_B(CAS_DBITERR_B[i + 1]),   // 1-bit output: Port B cascade double-bit error flag output
              .CAS_OUT_DIN_A(CAS_DIN_A[i + 1]),           // 72-bit output: Port A cascade output write mode data
              .CAS_OUT_DIN_B(CAS_DIN_B[i + 1]),           // 72-bit output: Port B cascade output write mode data
              .CAS_OUT_DOUT_A(CAS_DOUT_A[i + 1]),         // 72-bit output: Port A cascade output read mode data
              .CAS_OUT_DOUT_B(CAS_DOUT_B[i + 1]),         // 72-bit output: Port B cascade output read mode data
              .CAS_OUT_EN_A(CAS_EN_A[i + 1]),             // 1-bit output: Port A cascade output enable
              .CAS_OUT_EN_B(CAS_EN_B[i + 1]),             // 1-bit output: Port B cascade output enable
              .CAS_OUT_RDACCESS_A(CAS_RDACCESS_A[i + 1]), // 1-bit output: Port A cascade read status output
              .CAS_OUT_RDACCESS_B(CAS_RDACCESS_B[i + 1]), // 1-bit output: Port B cascade read status output
              .CAS_OUT_RDB_WR_A(CAS_RDB_WR_A[i + 1]),     // 1-bit output: Port A cascade read/write select output
              .CAS_OUT_RDB_WR_B(CAS_RDB_WR_B[i + 1]),     // 1-bit output: Port B cascade read/write select output
              .CAS_OUT_SBITERR_A(CAS_SBITERR_A[i + 1]),   // 1-bit output: Port A cascade single-bit error flag output
              .CAS_OUT_SBITERR_B(CAS_SBITERR_B[i + 1]),   // 1-bit output: Port B cascade single-bit error flag output
              .ADDR_A(ADDR_A),                         // 23-bit input: Port A address
              .ADDR_B(ADDR_B),                         // 23-bit input: Port B address
              .BWE_A(BWE_A),                           // 9-bit input: Port A Byte-write enable
              .BWE_B(BWE_B),                           // 9-bit input: Port B Byte-write enable
              .CAS_IN_ADDR_A(CAS_ADDR_A[i]),           // 23-bit input: Port A cascade input address
              .CAS_IN_ADDR_B(CAS_ADDR_B[i]),           // 23-bit input: Port B cascade input address
              .CAS_IN_BWE_A(CAS_BWE_A[i]),             // 9-bit input: Port A cascade Byte-write enable input
              .CAS_IN_BWE_B(CAS_BWE_B[i]),             // 9-bit input: Port B cascade Byte-write enable input
              .CAS_IN_DBITERR_A(CAS_DBITERR_A[i]),     // 1-bit input: Port A cascade double-bit error flag input
              .CAS_IN_DBITERR_B(CAS_DBITERR_B[i]),     // 1-bit input: Port B cascade double-bit error flag input
              .CAS_IN_DIN_A(CAS_DIN_A[i]),             // 72-bit input: Port A cascade input write mode data
              .CAS_IN_DIN_B(CAS_DIN_B[i]),             // 72-bit input: Port B cascade input write mode data
              .CAS_IN_DOUT_A(CAS_DOUT_A[i]),           // 72-bit input: Port A cascade input read mode data
              .CAS_IN_DOUT_B(CAS_DOUT_B[i]),           // 72-bit input: Port B cascade input read mode data
              .CAS_IN_EN_A(CAS_EN_A[i]),               // 1-bit input: Port A cascade enable input
              .CAS_IN_EN_B(CAS_EN_B[i]),               // 1-bit input: Port B cascade enable input
              .CAS_IN_RDACCESS_A(CAS_RDACCESS_A[i]),   // 1-bit input: Port A cascade read status input
              .CAS_IN_RDACCESS_B(CAS_RDACCESS_B[i]),   // 1-bit input: Port B cascade read status input
              .CAS_IN_RDB_WR_A(CAS_RDB_WR_A[i]),       // 1-bit input: Port A cascade read/write select input
              .CAS_IN_RDB_WR_B(CAS_RDB_WR_B[i]),       // 1-bit input: Port B cascade read/write select input
              .CAS_IN_SBITERR_A(CAS_SBITERR_A[i]),     // 1-bit input: Port A cascade single-bit error flag input
              .CAS_IN_SBITERR_B(CAS_SBITERR_B[i]),     // 1-bit input: Port B cascade single-bit error flag input
              .CLK(clk),                               // 1-bit input: Clock source
              .DIN_A(DIN_A),                           // 72-bit input: Port A write data input
              .DIN_B(DIN_B),                           // 72-bit input: Port B write data input
              .EN_A(EN_A),                             // 1-bit input: Port A enable
              .EN_B(EN_B),                             // 1-bit input: Port B enable
              .INJECT_DBITERR_A(1'b0),     // 1-bit input: Port A double-bit error injection
              .INJECT_DBITERR_B(1'b0),     // 1-bit input: Port B double-bit error injection
              .INJECT_SBITERR_A(1'b0),     // 1-bit input: Port A single-bit error injection
              .INJECT_SBITERR_B(1'b0),     // 1-bit input: Port B single-bit error injection
              .OREG_CE_A(1'b1),                   // 1-bit input: Port A output register clock enable
              .OREG_CE_B(1'b1),                   // 1-bit input: Port B output register clock enable
              .OREG_ECC_CE_A(1'b1),           // 1-bit input: Port A ECC decoder output register clock enable
              .OREG_ECC_CE_B(1'b1),           // 1-bit input: Port B ECC decoder output register clock enable
              .RDB_WR_A(RDB_WR_A),                     // 1-bit input: Port A read/write select
              .RDB_WR_B(RDB_WR_B),                     // 1-bit input: Port B read/write select
              .RST_A(CAS_RST[i]),                           // 1-bit input: Port A asynchronous or synchronous reset for
                                                       // output registers
        
              .RST_B(CAS_RST[i]),                           // 1-bit input: Port B asynchronous or synchronous reset for
                                                       // output registers
        
              .SLEEP(1'b0)                            // 1-bit input: Dynamic power gating control
           );
        
        end
        else if (i == cascade_level - 1) begin
            URAM288 #(
              .AUTO_SLEEP_LATENCY(8),            // Latency requirement to enter sleep mode
              .AVG_CONS_INACTIVE_CYCLES(10),     // Average consecutive inactive cycles when is SLEEP mode for power
                                                 // estimation
              .BWE_MODE_A("PARITY_INDEPENDENT"), // Port A Byte write control
              .BWE_MODE_B("PARITY_INDEPENDENT"), // Port B Byte write control
              .CASCADE_ORDER_A("LAST"),          // Port A position in cascade chain
              .CASCADE_ORDER_B("LAST"),          // Port B position in cascade chain
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
              .OREG_A("TRUE"),                  // Optional Port A output pipeline registers
              .OREG_B("TRUE"),                  // Optional Port B output pipeline registers
              .OREG_ECC_A("FALSE"),              // Port A ECC decoder output
              .OREG_ECC_B("FALSE"),              // Port B output ECC decoder
              .REG_CAS_A("TRUE"),               // Optional Port A cascade register
              .REG_CAS_B("TRUE"),               // Optional Port B cascade register
              .RST_MODE_A("SYNC"),               // Port A reset mode
              .RST_MODE_B("SYNC"),               // Port B reset mode
              .SELF_ADDR_A(i),             // Port A self-address value
              .SELF_ADDR_B(i),             // Port B self-address value
              .SELF_MASK_A(addr_mask),             // Port A self-address mask
              .SELF_MASK_B(addr_mask),             // Port B self-address mask
              .USE_EXT_CE_A("FALSE"),            // Enable Port A external CE inputs for output registers
              .USE_EXT_CE_B("FALSE")             // Enable Port B external CE inputs for output registers
           )
           URAM288_inst (
              .CAS_OUT_ADDR_A(CAS_ADDR_A[i + 1]),         // 23-bit output: Port A cascade output address
              .CAS_OUT_ADDR_B(CAS_ADDR_B[i + 1]),         // 23-bit output: Port B cascade output address
              .CAS_OUT_BWE_A(CAS_BWE_A[i + 1]),           // 9-bit output: Port A cascade Byte-write enable output
              .CAS_OUT_BWE_B(CAS_BWE_B[i + 1]),           // 9-bit output: Port B cascade Byte-write enable output
              .CAS_OUT_DBITERR_A(CAS_DBITERR_A[i + 1]),   // 1-bit output: Port A cascade double-bit error flag output
              .CAS_OUT_DBITERR_B(CAS_DBITERR_B[i + 1]),   // 1-bit output: Port B cascade double-bit error flag output
              .CAS_OUT_DIN_A(CAS_DIN_A[i + 1]),           // 72-bit output: Port A cascade output write mode data
              .CAS_OUT_DIN_B(CAS_DIN_B[i + 1]),           // 72-bit output: Port B cascade output write mode data
              .CAS_OUT_DOUT_A(CAS_DOUT_A[i + 1]),         // 72-bit output: Port A cascade output read mode data
              .CAS_OUT_DOUT_B(CAS_DOUT_B[i + 1]),         // 72-bit output: Port B cascade output read mode data
              .CAS_OUT_EN_A(CAS_EN_A[i + 1]),             // 1-bit output: Port A cascade output enable
              .CAS_OUT_EN_B(CAS_EN_B[i + 1]),             // 1-bit output: Port B cascade output enable
              .CAS_OUT_RDACCESS_A(CAS_RDACCESS_A[i + 1]), // 1-bit output: Port A cascade read status output
              .CAS_OUT_RDACCESS_B(CAS_RDACCESS_B[i + 1]), // 1-bit output: Port B cascade read status output
              .CAS_OUT_RDB_WR_A(CAS_RDB_WR_A[i + 1]),     // 1-bit output: Port A cascade read/write select output
              .CAS_OUT_RDB_WR_B(CAS_RDB_WR_B[i + 1]),     // 1-bit output: Port B cascade read/write select output
              .CAS_OUT_SBITERR_A(CAS_SBITERR_A[i + 1]),   // 1-bit output: Port A cascade single-bit error flag output
              .CAS_OUT_SBITERR_B(CAS_SBITERR_B[i + 1]),   // 1-bit output: Port B cascade single-bit error flag output
              .DOUT_A(DOUT_A),                         // 72-bit output: Port A read data output
              .DOUT_B(DOUT_B),                         // 72-bit output: Port B read data output
              .RDACCESS_A(RDACCESS_A),                 // 1-bit output: Port A read status
              .RDACCESS_B(RDACCESS_B),                 // 1-bit output: Port B read status
              .ADDR_A({23{1'b1}}),                         // 23-bit input: Port A address
              .ADDR_B({23{1'b1}}),                         // 23-bit input: Port B address
              .BWE_A({9{1'b1}}),                           // 9-bit input: Port A Byte-write enable
              .BWE_B({9{1'b1}}),                           // 9-bit input: Port B Byte-write enable
              .CAS_IN_ADDR_A(CAS_ADDR_A[i]),           // 23-bit input: Port A cascade input address
              .CAS_IN_ADDR_B(CAS_ADDR_B[i]),           // 23-bit input: Port B cascade input address
              .CAS_IN_BWE_A(CAS_BWE_A[i]),             // 9-bit input: Port A cascade Byte-write enable input
              .CAS_IN_BWE_B(CAS_BWE_B[i]),             // 9-bit input: Port B cascade Byte-write enable input
              .CAS_IN_DBITERR_A(CAS_DBITERR_A[i]),     // 1-bit input: Port A cascade double-bit error flag input
              .CAS_IN_DBITERR_B(CAS_DBITERR_B[i]),     // 1-bit input: Port B cascade double-bit error flag input
              .CAS_IN_DIN_A(CAS_DIN_A[i]),             // 72-bit input: Port A cascade input write mode data
              .CAS_IN_DIN_B(CAS_DIN_B[i]),             // 72-bit input: Port B cascade input write mode data
              .CAS_IN_DOUT_A(CAS_DOUT_A[i]),           // 72-bit input: Port A cascade input read mode data
              .CAS_IN_DOUT_B(CAS_DOUT_B[i]),           // 72-bit input: Port B cascade input read mode data
              .CAS_IN_EN_A(CAS_EN_A[i]),               // 1-bit input: Port A cascade enable input
              .CAS_IN_EN_B(CAS_EN_B[i]),               // 1-bit input: Port B cascade enable input
              .CAS_IN_RDACCESS_A(CAS_RDACCESS_A[i]),   // 1-bit input: Port A cascade read status input
              .CAS_IN_RDACCESS_B(CAS_RDACCESS_B[i]),   // 1-bit input: Port B cascade read status input
              .CAS_IN_RDB_WR_A(CAS_RDB_WR_A[i]),       // 1-bit input: Port A cascade read/write select input
              .CAS_IN_RDB_WR_B(CAS_RDB_WR_B[i]),       // 1-bit input: Port B cascade read/write select input
              .CAS_IN_SBITERR_A(CAS_SBITERR_A[i]),     // 1-bit input: Port A cascade single-bit error flag input
              .CAS_IN_SBITERR_B(CAS_SBITERR_B[i]),     // 1-bit input: Port B cascade single-bit error flag input
              .CLK(clk),                               // 1-bit input: Clock source
              .DIN_A({72{1'b1}}),                           // 72-bit input: Port A write data input
              .DIN_B({72{1'b1}}),                           // 72-bit input: Port B write data input
              .EN_A(1'b1),                             // 1-bit input: Port A enable
              .EN_B(1'b1),                             // 1-bit input: Port B enable
              .INJECT_DBITERR_A(1'b0),     // 1-bit input: Port A double-bit error injection
              .INJECT_DBITERR_B(1'b0),     // 1-bit input: Port B double-bit error injection
              .INJECT_SBITERR_A(1'b0),     // 1-bit input: Port A single-bit error injection
              .INJECT_SBITERR_B(1'b0),     // 1-bit input: Port B single-bit error injection
              .OREG_CE_A(1'b1),                   // 1-bit input: Port A output register clock enable
              .OREG_CE_B(1'b1),                   // 1-bit input: Port B output register clock enable
              .OREG_ECC_CE_A(1'b1),           // 1-bit input: Port A ECC decoder output register clock enable
              .OREG_ECC_CE_B(1'b1),           // 1-bit input: Port B ECC decoder output register clock enable
              .RDB_WR_A(1'b1),                     // 1-bit input: Port A read/write select
              .RDB_WR_B(1'b1),                     // 1-bit input: Port B read/write select
              .RST_A(CAS_RST[i]),                           // 1-bit input: Port A asynchronous or synchronous reset for
                                                       // output registers
        
              .RST_B(CAS_RST[i]),                           // 1-bit input: Port B asynchronous or synchronous reset for
                                                       // output registers
        
              .SLEEP(1'b0)                            // 1-bit input: Dynamic power gating control
           );
        end
        else begin
            URAM288 #(
              .AUTO_SLEEP_LATENCY(8),            // Latency requirement to enter sleep mode
              .AVG_CONS_INACTIVE_CYCLES(10),     // Average consecutive inactive cycles when is SLEEP mode for power
                                                 // estimation
              .BWE_MODE_A("PARITY_INDEPENDENT"), // Port A Byte write control
              .BWE_MODE_B("PARITY_INDEPENDENT"), // Port B Byte write control
              .CASCADE_ORDER_A("MIDDLE"),          // Port A position in cascade chain
              .CASCADE_ORDER_B("MIDDLE"),          // Port B position in cascade chain
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
              .OREG_A("TRUE"),                  // Optional Port A output pipeline registers
              .OREG_B("TRUE"),                  // Optional Port B output pipeline registers
              .OREG_ECC_A("FALSE"),              // Port A ECC decoder output
              .OREG_ECC_B("FALSE"),              // Port B output ECC decoder
              .REG_CAS_A("TRUE"),               // Optional Port A cascade register
              .REG_CAS_B("TRUE"),               // Optional Port B cascade register
              .RST_MODE_A("SYNC"),               // Port A reset mode
              .RST_MODE_B("SYNC"),               // Port B reset mode
              .SELF_ADDR_A(i),             // Port A self-address value
              .SELF_ADDR_B(i),             // Port B self-address value
              .SELF_MASK_A(addr_mask),             // Port A self-address mask
              .SELF_MASK_B(addr_mask),             // Port B self-address mask
              .USE_EXT_CE_A("FALSE"),            // Enable Port A external CE inputs for output registers
              .USE_EXT_CE_B("FALSE")             // Enable Port B external CE inputs for output registers
           )
           URAM288_inst (
              .CAS_OUT_ADDR_A(CAS_ADDR_A[i + 1]),         // 23-bit output: Port A cascade output address
              .CAS_OUT_ADDR_B(CAS_ADDR_B[i + 1]),         // 23-bit output: Port B cascade output address
              .CAS_OUT_BWE_A(CAS_BWE_A[i + 1]),           // 9-bit output: Port A cascade Byte-write enable output
              .CAS_OUT_BWE_B(CAS_BWE_B[i + 1]),           // 9-bit output: Port B cascade Byte-write enable output
              .CAS_OUT_DBITERR_A(CAS_DBITERR_A[i + 1]),   // 1-bit output: Port A cascade double-bit error flag output
              .CAS_OUT_DBITERR_B(CAS_DBITERR_B[i + 1]),   // 1-bit output: Port B cascade double-bit error flag output
              .CAS_OUT_DIN_A(CAS_DIN_A[i + 1]),           // 72-bit output: Port A cascade output write mode data
              .CAS_OUT_DIN_B(CAS_DIN_B[i + 1]),           // 72-bit output: Port B cascade output write mode data
              .CAS_OUT_DOUT_A(CAS_DOUT_A[i + 1]),         // 72-bit output: Port A cascade output read mode data
              .CAS_OUT_DOUT_B(CAS_DOUT_B[i + 1]),         // 72-bit output: Port B cascade output read mode data
              .CAS_OUT_EN_A(CAS_EN_A[i + 1]),             // 1-bit output: Port A cascade output enable
              .CAS_OUT_EN_B(CAS_EN_B[i + 1]),             // 1-bit output: Port B cascade output enable
              .CAS_OUT_RDACCESS_A(CAS_RDACCESS_A[i + 1]), // 1-bit output: Port A cascade read status output
              .CAS_OUT_RDACCESS_B(CAS_RDACCESS_B[i + 1]), // 1-bit output: Port B cascade read status output
              .CAS_OUT_RDB_WR_A(CAS_RDB_WR_A[i + 1]),     // 1-bit output: Port A cascade read/write select output
              .CAS_OUT_RDB_WR_B(CAS_RDB_WR_B[i + 1]),     // 1-bit output: Port B cascade read/write select output
              .CAS_OUT_SBITERR_A(CAS_SBITERR_A[i + 1]),   // 1-bit output: Port A cascade single-bit error flag output
              .CAS_OUT_SBITERR_B(CAS_SBITERR_B[i + 1]),   // 1-bit output: Port B cascade single-bit error flag output
              .ADDR_A({23{1'b1}}),                         // 23-bit input: Port A address
              .ADDR_B({23{1'b1}}),                         // 23-bit input: Port B address
              .BWE_A({9{1'b1}}),                           // 9-bit input: Port A Byte-write enable
              .BWE_B({9{1'b1}}),                           // 9-bit input: Port B Byte-write enable
              .CAS_IN_ADDR_A(CAS_ADDR_A[i]),           // 23-bit input: Port A cascade input address
              .CAS_IN_ADDR_B(CAS_ADDR_B[i]),           // 23-bit input: Port B cascade input address
              .CAS_IN_BWE_A(CAS_BWE_A[i]),             // 9-bit input: Port A cascade Byte-write enable input
              .CAS_IN_BWE_B(CAS_BWE_B[i]),             // 9-bit input: Port B cascade Byte-write enable input
              .CAS_IN_DBITERR_A(CAS_DBITERR_A[i]),     // 1-bit input: Port A cascade double-bit error flag input
              .CAS_IN_DBITERR_B(CAS_DBITERR_B[i]),     // 1-bit input: Port B cascade double-bit error flag input
              .CAS_IN_DIN_A(CAS_DIN_A[i]),             // 72-bit input: Port A cascade input write mode data
              .CAS_IN_DIN_B(CAS_DIN_B[i]),             // 72-bit input: Port B cascade input write mode data
              .CAS_IN_DOUT_A(CAS_DOUT_A[i]),           // 72-bit input: Port A cascade input read mode data
              .CAS_IN_DOUT_B(CAS_DOUT_B[i]),           // 72-bit input: Port B cascade input read mode data
              .CAS_IN_EN_A(CAS_EN_A[i]),               // 1-bit input: Port A cascade enable input
              .CAS_IN_EN_B(CAS_EN_B[i]),               // 1-bit input: Port B cascade enable input
              .CAS_IN_RDACCESS_A(CAS_RDACCESS_A[i]),   // 1-bit input: Port A cascade read status input
              .CAS_IN_RDACCESS_B(CAS_RDACCESS_B[i]),   // 1-bit input: Port B cascade read status input
              .CAS_IN_RDB_WR_A(CAS_RDB_WR_A[i]),       // 1-bit input: Port A cascade read/write select input
              .CAS_IN_RDB_WR_B(CAS_RDB_WR_B[i]),       // 1-bit input: Port B cascade read/write select input
              .CAS_IN_SBITERR_A(CAS_SBITERR_A[i]),     // 1-bit input: Port A cascade single-bit error flag input
              .CAS_IN_SBITERR_B(CAS_SBITERR_B[i]),     // 1-bit input: Port B cascade single-bit error flag input
              .CLK(clk),                               // 1-bit input: Clock source
              .DIN_A({72{1'b1}}),                           // 72-bit input: Port A write data input
              .DIN_B({72{1'b1}}),                           // 72-bit input: Port B write data input
              .EN_A(1'b1),                             // 1-bit input: Port A enable
              .EN_B(1'b1),                             // 1-bit input: Port B enable
              .INJECT_DBITERR_A(1'b0),     // 1-bit input: Port A double-bit error injection
              .INJECT_DBITERR_B(1'b0),     // 1-bit input: Port B double-bit error injection
              .INJECT_SBITERR_A(1'b0),     // 1-bit input: Port A single-bit error injection
              .INJECT_SBITERR_B(1'b0),     // 1-bit input: Port B single-bit error injection
              .OREG_CE_A(1'b1),                   // 1-bit input: Port A output register clock enable
              .OREG_CE_B(1'b1),                   // 1-bit input: Port B output register clock enable
              .OREG_ECC_CE_A(1'b1),           // 1-bit input: Port A ECC decoder output register clock enable
              .OREG_ECC_CE_B(1'b1),           // 1-bit input: Port B ECC decoder output register clock enable
              .RDB_WR_A(1'b1),                     // 1-bit input: Port A read/write select
              .RDB_WR_B(1'b1),                     // 1-bit input: Port B read/write select
              .RST_A(CAS_RST[i]),                           // 1-bit input: Port A asynchronous or synchronous reset for
                                                       // output registers
        
              .RST_B(CAS_RST[i]),                           // 1-bit input: Port B asynchronous or synchronous reset for
                                                       // output registers
        
              .SLEEP(1'b0)                            // 1-bit input: Dynamic power gating control
           );
        end
   end
   endgenerate    
endmodule
