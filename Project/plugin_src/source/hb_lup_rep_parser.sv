module hb_lup_rep_parser(
    input               s_axis_lup_rsp_valid,
    input  [119:0]      s_axis_lup_rsp_data,
    output              s_axis_lup_rsp_ready,

    output reg          m_axis_lup_result_valid,
    output reg [63:0]   m_axis_lup_key,
    output reg          m_axis_lup_hit,
    input               m_axis_lup_result_ready,

    output reg          m_axis_lup_addr_valid,
    output reg [15:0]   m_axis_lup_addr_data,
    input               m_axis_lup_addr_ready,

    input               clk,
    input               rst_n
);

    wire result_can_accept = (~m_axis_lup_result_valid) || m_axis_lup_result_ready;
    wire addr_can_accept   = (~m_axis_lup_addr_valid)   || m_axis_lup_addr_ready;

    assign s_axis_lup_rsp_ready = result_can_accept && addr_can_accept;

    always @(posedge clk) begin
        if (!rst_n) begin
            m_axis_lup_addr_data     <= 16'b0;
            m_axis_lup_addr_valid    <= 1'b0;
            m_axis_lup_key           <= 64'b0;
            m_axis_lup_hit           <= 1'b0;
            m_axis_lup_result_valid  <= 1'b0;
        end else begin
            if (m_axis_lup_result_valid && m_axis_lup_result_ready)
                m_axis_lup_result_valid <= 1'b0;

            if (m_axis_lup_addr_valid && m_axis_lup_addr_ready)
                m_axis_lup_addr_valid <= 1'b0;

            if (s_axis_lup_rsp_valid && s_axis_lup_rsp_ready) begin
                m_axis_lup_addr_data    <= s_axis_lup_rsp_data[79:64];
                m_axis_lup_addr_valid   <= 1'b1;

                m_axis_lup_key          <= s_axis_lup_rsp_data[63:0];
                m_axis_lup_hit          <= s_axis_lup_rsp_data[80];
                m_axis_lup_result_valid <= 1'b1;
            end
        end
    end
endmodule
