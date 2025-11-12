`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/03 22:27:05
// Design Name: 
// Module Name: ram
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


`timescale 1ns / 1ps

/*
class0 (64B): base_addr 0x0000 - 0x3FFF   -> 1 beat
class1 (128B): base_addr 0x4000 - 0x7FFF  -> 2 beats
class2 (256B): base_addr 0x8000 - 0xBFFF  -> 4 beats
class3 (512B): base_addr 0xC000 - 0xFFFF  -> 8 beats
*/

module ram(
    input                   clk,
    input                   rst_n,

    // Port A INPUT
    input                   s_axis_rx_valid_a,
    input  [527:0]          s_axis_rx_data_a,
    output reg              s_axis_rx_ready_a,

    // Port A OUTPUT
    output reg              s_axis_tx_valid_a,
    output reg [527:0]      s_axis_tx_data_a,
    input                   s_axis_tx_ready_a,
    input  [15:0]           s_axis_addr_a,
    input                   read_or_write_a,   // 0: read, 1: write

    // Port B INPUT
    input                   s_axis_rx_valid_b,
    input  [527:0]          s_axis_rx_data_b,
    output reg              s_axis_rx_ready_b,

    // Port B OUTPUT
    output reg              s_axis_tx_valid_b,
    output reg [527:0]      s_axis_tx_data_b,
    input                   s_axis_tx_ready_b,
    input  [15:0]           s_axis_addr_b,
    input                   read_or_write_b    // 0: read, 1: write
);

    //========================================
    // uram512 INTERFACE
    //========================================

    reg  [15:0]   addr_a;
    reg  [15:0]   addr_b;

    reg  [575:0]  wr_data_a;    
    reg  [575:0]  wr_data_b;
    wire [575:0]  rd_data_a;    
    wire [575:0]  rd_data_b;

    reg           rdb_wr_a;     
    reg           rdb_wr_b;
    reg   [8:0]   bwe_a;        
    reg   [8:0]   bwe_b;
    reg           en_a;
    reg           en_b;

    localparam integer URAM_RD_LAT = 0;    

    uram512 uram512_inst (
        .addr_a   (addr_a),
        .addr_b   (addr_b),
        .tx_data_a(wr_data_a),
        .tx_data_b(wr_data_b),
        .rx_data_a(rd_data_a),
        .rx_data_b(rd_data_b),
        .clk      (clk),
        .rst_n    (rst_n),
        .rdb_wr_a (rdb_wr_a),
        .rdb_wr_b (rdb_wr_b),
        .bwe_a    (bwe_a),
        .bwe_b    (bwe_b),
        .en_a     (en_a),
        .en_b     (en_b)
    );

    function [3:0] class_to_beats;
        input [1:0] cls;
        begin
            class_to_beats = 4'd1 << cls; // 0?1, 1?2, 2?4, 3?8
        end
    endfunction


    localparam [1:0]
        ST_A_IDLE   = 2'd0,
        ST_A_READ   = 2'd1,   
        ST_A_W_DATA = 2'd2;  

    reg [1:0] state_a;

    reg [1:0] in_class_a;       
    reg [3:0] beats_total_a;    
    reg [3:0] beats_issued_a;   
    reg [3:0] beats_sent_a;    
    reg [15:0] base_addr_a;


    reg issue_read_a;
    reg [URAM_RD_LAT:0] rd_valid_pipe_a;

    localparam [1:0]
        ST_B_IDLE   = 2'd0,
        ST_B_READ   = 2'd1,
        ST_B_W_DATA = 2'd2;

    reg [1:0] state_b;

    reg [1:0] in_class_b;
    reg [3:0] beats_total_b;
    reg [3:0] beats_issued_b;
    reg [3:0] beats_sent_b;
    reg [15:0] base_addr_b;

    reg issue_read_b;
    reg [URAM_RD_LAT:0] rd_valid_pipe_b;

    //========================================
    // Port A
    //========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_a            <= 16'd0;
            wr_data_a         <= {576{1'b0}};
            rdb_wr_a          <= 1'b0;
            bwe_a             <= 9'd0;
            en_a              <= 1'b0;

            s_axis_rx_ready_a <= 1'b1;
            s_axis_tx_valid_a <= 1'b0;
            s_axis_tx_data_a  <= 528'd0;

            state_a           <= ST_A_IDLE;
            in_class_a        <= 2'd0;
            beats_total_a     <= 4'd0;
            beats_issued_a    <= 4'd0;
            beats_sent_a      <= 4'd0;
            base_addr_a       <= 16'd0;

            issue_read_a      <= 1'b0;
            rd_valid_pipe_a   <= { (URAM_RD_LAT+1){1'b0} };

        end else begin
            en_a      <= 1'b0;
            rdb_wr_a  <= 1'b0;
            bwe_a     <= 9'h1FF;

            issue_read_a <= 1'b0;
            rd_valid_pipe_a <= {issue_read_a };       
            if (s_axis_tx_valid_a && s_axis_tx_ready_a)
                s_axis_tx_valid_a <= 1'b0;

            case (state_a)
                ST_A_IDLE: begin
                    s_axis_rx_ready_a <= 1'b1;
                    beats_issued_a    <= 4'd0;
                    beats_sent_a      <= 4'd0;
                    if (s_axis_rx_valid_a && s_axis_rx_ready_a) begin
                        base_addr_a   <= s_axis_addr_a;
                        in_class_a    <= s_axis_addr_a[15:14];
                        beats_total_a <= class_to_beats(s_axis_addr_a[15:14]);
                        if (!read_or_write_a) begin                          
                            s_axis_rx_ready_a <= 1'b0;                       
                            addr_a        <= s_axis_addr_a;
                            en_a          <= 1'b1;
                            rdb_wr_a      <= 1'b0;
                            issue_read_a  <= 1'b1;      
                            beats_issued_a<= 4'd1;
                            rd_valid_pipe_a <= { (URAM_RD_LAT+1){1'b0} }; 
                            state_a       <= ST_A_READ;
                        end else begin                         
                            s_axis_rx_ready_a <= 1'b1;
                            en_a      <= 1'b1;
                            rdb_wr_a  <= 1'b1;
                            addr_a    <= s_axis_addr_a;
                            wr_data_a <= {48'd0, s_axis_rx_data_a};
                            if (class_to_beats(s_axis_addr_a[15:14]) == 4'd1) begin
                                state_a <= ST_A_IDLE;
                            end else begin
                                beats_issued_a <= 4'd0;  
                                beats_sent_a   <= 4'd0;
                                state_a        <= ST_A_W_DATA;
                            end
                        end
                    end
                end
                ST_A_READ: begin
                    s_axis_rx_ready_a <= 1'b0;            
                    if (beats_issued_a < beats_total_a) begin
                        addr_a        <= base_addr_a + beats_issued_a;
                        en_a          <= 1'b1;
                        rdb_wr_a      <= 1'b0;
                        issue_read_a  <= 1'b1;
                        beats_issued_a<= beats_issued_a + 1'b1;
                    end                 
                    if (rd_valid_pipe_a[URAM_RD_LAT]) begin                       
                        s_axis_tx_data_a  <= rd_data_a[527:0];
                        s_axis_tx_valid_a <= 1'b1;
                        beats_sent_a      <= beats_sent_a + 1'b1;                     
                        if (beats_sent_a + 1 == beats_total_a) begin
                            s_axis_rx_ready_a <= 1'b1;
                            state_a           <= ST_A_IDLE;
                        end
                    end
                end
                ST_A_W_DATA: begin
                    s_axis_rx_ready_a <= 1'b1;

                    if (s_axis_rx_valid_a && s_axis_rx_ready_a) begin
                        en_a      <= 1'b1;
                        rdb_wr_a  <= 1'b1;
                        addr_a    <= base_addr_a + beats_issued_a;
                        wr_data_a <= {48'd0, s_axis_rx_data_a};

                        if (beats_issued_a + 1 < beats_total_a) begin
                            beats_issued_a <= beats_issued_a + 1'b1;
                        end else begin
                            state_a <= ST_A_IDLE;
                        end
                    end
                end

                default: state_a <= ST_A_IDLE;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_b            <= 16'd0;
            wr_data_b         <= {576{1'b0}};
            rdb_wr_b          <= 1'b0;
            bwe_b             <= 9'd0;
            en_b              <= 1'b0;

            s_axis_rx_ready_b <= 1'b1;
            s_axis_tx_valid_b <= 1'b0;
            s_axis_tx_data_b  <= 528'd0;

            state_b           <= ST_B_IDLE;
            in_class_b        <= 2'd0;
            beats_total_b     <= 4'd0;
            beats_issued_b    <= 4'd0;
            beats_sent_b      <= 4'd0;
            base_addr_b       <= 16'd0;

            issue_read_b      <= 1'b0;
            rd_valid_pipe_b   <= { (URAM_RD_LAT+1){1'b0} };

        end else begin
            en_b      <= 1'b0;
            rdb_wr_b  <= 1'b0;
            bwe_b     <= 9'h1FF;

            issue_read_b <= 1'b0;
            rd_valid_pipe_b <= {issue_read_b };

            if (s_axis_tx_valid_b && s_axis_tx_ready_b)
                s_axis_tx_valid_b <= 1'b0;

            case (state_b)
                ST_B_IDLE: begin
                    s_axis_rx_ready_b <= 1'b1;
                    beats_issued_b    <= 4'd0;
                    beats_sent_b      <= 4'd0;

                    if (s_axis_rx_valid_b && s_axis_rx_ready_b) begin
                        base_addr_b   <= s_axis_addr_b;
                        in_class_b    <= s_axis_addr_b[15:14];
                        beats_total_b <= class_to_beats(s_axis_addr_b[15:14]);

                        if (!read_or_write_b) begin
                            // READ
                            s_axis_rx_ready_b <= 1'b0;

                            addr_b        <= s_axis_addr_b;
                            en_b          <= 1'b1;
                            rdb_wr_b      <= 1'b0;
                            issue_read_b  <= 1'b1;
                            beats_issued_b<= 4'd1;

                            rd_valid_pipe_b <= { (URAM_RD_LAT+1){1'b0} };
                            state_b       <= ST_B_READ;

                        end else begin
                            // WRITE
                            s_axis_rx_ready_b <= 1'b1;

                            en_b      <= 1'b1;
                            rdb_wr_b  <= 1'b1;
                            addr_b    <= s_axis_addr_b;
                            wr_data_b <= {48'd0, s_axis_rx_data_b};

                            if (class_to_beats(s_axis_addr_b[15:14]) == 4'd1) begin
                                state_b <= ST_B_IDLE;
                            end else begin
                                beats_issued_b <= 4'd1;
                                beats_sent_b   <= 4'd0;
                                state_b        <= ST_B_W_DATA;
                            end
                        end
                    end
                end

                ST_B_READ: begin
                    s_axis_rx_ready_b <= 1'b0;

                    if (beats_issued_b < beats_total_b) begin
                        addr_b        <= base_addr_b + beats_issued_b;
                        en_b          <= 1'b1;
                        rdb_wr_b      <= 1'b0;
                        issue_read_b  <= 1'b1;
                        beats_issued_b<= beats_issued_b + 1'b1;
                    end

                    if (rd_valid_pipe_b[URAM_RD_LAT]) begin
                        s_axis_tx_data_b  <= rd_data_b[527:0];
                        s_axis_tx_valid_b <= 1'b1;
                        beats_sent_b      <= beats_sent_b + 1'b1;

                        if (beats_sent_b + 1 == beats_total_b) begin
                            s_axis_rx_ready_b <= 1'b1;
                            state_b           <= ST_B_IDLE;
                        end
                    end
                end

                ST_B_W_DATA: begin
                    s_axis_rx_ready_b <= 1'b1;
                    if (s_axis_rx_valid_b && s_axis_rx_ready_b) begin
                        en_b      <= 1'b1;
                        rdb_wr_b  <= 1'b1;
                        addr_b    <= base_addr_b + beats_issued_b;
                        wr_data_b <= {48'd0, s_axis_rx_data_b};
                        if (beats_issued_b+1  < beats_total_b) begin
                            beats_issued_b <= beats_issued_b + 1'b1;
                        end else begin
                            state_b <= ST_B_IDLE;
                        end
                    end
                end

                default: state_b <= ST_B_IDLE;
            endcase
        end
    end

endmodule

