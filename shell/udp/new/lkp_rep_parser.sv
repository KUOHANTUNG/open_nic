`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/07 23:24:11
// Design Name: 
// Module Name: lkp_rep_parser
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


module lkp_rep_parser(
    input                       clk,
    input                       rst_n,
    
    input                       m_axis_meta_valid,
    input  [63:0]               m_axis_meta_key,
    input                       m_axis_meta_hit,
    output                      m_axis_meta_ready,
    
    input                       m_axis_ram_valid,
    input  [15:0]               m_axis_ram_lenth,  
    input  [511:0]              m_axis_ram_data,
    output                      m_axis_ram_ready,
    
    output reg                  m_axis_tx_tvalid,
    output reg [511:0]          m_axis_tx_tdata,
    output reg [63:0]           m_axis_tx_tkeep,
    output reg                  m_axis_tx_tlast,
    output reg  [15:0]          m_axis_tx_size,
    output reg  [15:0]          m_axis_tx_src,
    output reg  [15:0]          m_axis_tx_dst,
    input                       m_axis_tx_tready
    );

    localparam [3:0]
        ST_IDLE       = 0,
        ST_WAIT_FIRST = 1,
        ST_SEND       = 2;

    localparam [15:0] HEADER_BYTES = 16'd11; // 88bit

    reg [3:0]  state;
    reg [63:0] meta_key_r;

    reg [87:0] packet_buffer;

    reg [15:0] bytes_left;

    function automatic [63:0] gen_keep;
        input [15:0] byte_num;
        integer i;
        begin
            gen_keep = 64'd0;
            for (i = 0; i < 64; i = i + 1)
                gen_keep[i] = (i < byte_num) ? 1'b1 : 1'b0;
        end
    endfunction

    assign m_axis_meta_ready = (state == ST_IDLE) && (!m_axis_tx_tvalid || m_axis_tx_tready);

    assign m_axis_ram_ready  = (state == ST_WAIT_FIRST || state == ST_SEND) &&
                               (!m_axis_tx_tvalid || m_axis_tx_tready);

    always @(posedge clk) begin
        if (!rst_n) begin
            state            <= ST_IDLE;
            m_axis_tx_tvalid <= 1'b0;
            m_axis_tx_tdata  <= '0;
            m_axis_tx_tkeep  <= '0;
            m_axis_tx_tlast  <= 1'b0;
            m_axis_tx_dst   <= '0;
            m_axis_tx_src   <= '0;
            m_axis_tx_size  <= '0;
  
            meta_key_r       <= '0;
            packet_buffer    <= '0;
            bytes_left       <= '0;
        end
        else begin
            if (m_axis_tx_tvalid && m_axis_tx_tready)
                m_axis_tx_tvalid <= 1'b0;

            m_axis_tx_tlast <= 1'b0;

            case (state)
                //--------------------------------------------------
                ST_IDLE: begin
                    if (m_axis_meta_valid && m_axis_meta_ready) begin
                        meta_key_r <= m_axis_meta_key;

                        if (!m_axis_meta_hit) begin
                            m_axis_tx_tvalid <= 1'b1;
                            m_axis_tx_tdata  <= {16'b0, 8'b0, m_axis_meta_key, 424'b0};
                            m_axis_tx_tkeep  <= 64'h0000_0000_0000_07FF; // 11 bytes
                            m_axis_tx_tlast  <= 1'b1;
                            m_axis_tx_dst   <=16'h1 << (6+0);
                            m_axis_tx_src   <= 0;
                            m_axis_tx_size  <=  HEADER_BYTES;                                                 
                        end
                        else begin

                            state <= ST_WAIT_FIRST;
                        end
                    end
                end

                //--------------------------------------------------
                ST_WAIT_FIRST: begin
                    if ((!m_axis_tx_tvalid || m_axis_tx_tready) && m_axis_ram_valid) begin
                        automatic logic [15:0] total_bytes;
                        automatic logic [15:0] bytes_this;

                        total_bytes = HEADER_BYTES + m_axis_ram_lenth;
                        bytes_this  = (total_bytes >= 16'd64) ? 16'd64 : total_bytes;

                        m_axis_tx_tdata  <= { {m_axis_ram_lenth, 8'hFF, meta_key_r},
                                              m_axis_ram_data[511:88] };
                        m_axis_tx_tkeep  <= gen_keep(bytes_this);
                        m_axis_tx_tvalid <= 1'b1;
                        m_axis_tx_dst <=   16'h1 << (6+0);
                        m_axis_tx_src <= 0;
                        m_axis_tx_size <= total_bytes;
                        packet_buffer    <= m_axis_ram_data[87:0];

                        bytes_left       <= total_bytes - bytes_this;

                        if (total_bytes <= 16'd64) begin
                            m_axis_tx_tlast <= 1'b1;
                            state           <= ST_IDLE;
                        end
                        else begin
                            state <= ST_SEND;
                        end
                    end
                end

                //--------------------------------------------------
                ST_SEND: begin
                    if ((!m_axis_tx_tvalid || m_axis_tx_tready) && m_axis_ram_valid) begin
                        automatic logic [15:0] bytes_this;
                        automatic logic [15:0] curr_bytes;

                        curr_bytes = bytes_left;
                        bytes_this = (curr_bytes >= 16'd64) ? 16'd64 : curr_bytes;

                        m_axis_tx_tdata  <= { packet_buffer, m_axis_ram_data[511:88] };
                        m_axis_tx_tkeep  <= gen_keep(bytes_this);
                        m_axis_tx_tvalid <= 1'b1;
                        bytes_left       <= curr_bytes - bytes_this;
                        packet_buffer    <= m_axis_ram_data[87:0];
                        if (curr_bytes <= 16'd64) begin
                            m_axis_tx_tlast <= 1'b1;
                            state           <= ST_IDLE;
                        end
                    end
                end

                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

endmodule