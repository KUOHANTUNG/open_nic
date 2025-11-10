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


module front_end_transit(
    input                           clk,
    input                           rst_n,
    input [511:0]                   s_axis_tdata, 
    input                           s_axis_tvalid,  
    input                           s_axis_tlast,  
    input [63:0]                    s_axis_tkeep,  
    output                          s_axis_tready,
    
    output reg [543:0]              m_value_data,
    output reg                      m_value_valid,
    input                           m_value_ready, 
    
    input [15:0]                    s_free_pointer,
    input                           s_free_pointer_valid,
    output                          s_free_pointer_ready,
    
    output reg [80:0]               m_key_data,
    output reg                      m_key_valid,
    input                           m_key_ready
);

    logic [3:0] insert_wait_counter;

    logic        alloc_ready;
    logic [15:0] alloc_pointer;
    logic [15:0] alloc_pointer_buffer;
    logic        alloc_valid;
    
    wire            parser_to_allocator_valid;
    wire    [15:0]  parser_to_allocator_data;
    wire            parser_to_allocator_ready;
    
    logic [95:0]    meta_data;
    logic           meta_valid;
    logic           meta_ready;
    
    logic [63:0]    key_data;
    logic           key_valid;
    logic           key_valid_buffer;
    logic           key_ready;
    
    logic [511:0]   value_data;
    logic           value_valid; 
    logic [15:0]    value_length;
    logic [15:0]    value_box_number;//one box = 512 bits
    logic [15:0]    value_box_number_launcher;
    logic [15:0]    value_len_byte;
    logic           value_last;  
    logic           value_ready;      
    
    logic [511:0]   fifo_value_out_data;
    logic           fifo_value_valid;
    logic           fifo_value_ready;
    
    logic [15:0]    free_pointer;
    logic           free_pointer_valid;
    logic           free_pointer_ready;
    
    logic           launch_on;
    
    
    localparam [3:0]	
        ST_IDLE   = 0,
        ST_INSERT_BEGIN  = 1;
    reg [3:0] state; 
    
    localparam [3:0]
        ST_LAUNCH_IDLE = 0,
        ST_LAUNCH_BEGIN = 1;
    reg [3:0] launch_state;
    
    
    // ================= FIFO for value =================
    fifo #(
        .DATA_WIDTH(512),
        .FIFO_DEPTH(4)  
    ) fifo_value (
        .axis_clk     (clk),     
        .axis_rstn    (rst_n),                       
        .s_axis_valid (value_valid), 
        .s_axis_data  (value_data),  
        .s_axis_ready (value_ready),       
        .m_axis_valid (fifo_value_valid), 
        .m_axis_data  (fifo_value_out_data),  
        .m_axis_ready (fifo_value_ready)    
    );
    
    fifo #(
        .DATA_WIDTH(16),
        .FIFO_DEPTH(4)  
    ) fifo_pointer (
        .axis_clk     (clk),     
        .axis_rstn    (rst_n),                       
        .s_axis_valid (s_free_pointer_valid), 
        .s_axis_data  (s_free_pointer),  
        .s_axis_ready (s_free_pointer_ready),                      
        .m_axis_valid (free_pointer_valid), 
        .m_axis_data  (free_pointer),  
        .m_axis_ready (free_pointer_ready)    
    );
    
    assign key_ready = m_key_ready;
    assign meta_ready = 1'b1;
    always @(posedge clk) begin
        if(!rst_n)begin
             insert_wait_counter <= '0;
             m_value_valid     <= 1'b0;
             m_value_data      <= '0;
             fifo_value_ready  <= 1'b0;
             m_key_valid       <= 1'b0;
             m_key_data        <= '0;
             state <= ST_IDLE;
             launch_on <= 0;
             key_valid_buffer <= '0;
             value_box_number <= '0;
             insert_wait_counter <= '0;
             alloc_pointer_buffer <= '0;
             launch_state <= ST_LAUNCH_IDLE;
             value_box_number_launcher <= '0;
             value_len_byte <= '0;
        end
        else begin
            if(m_key_valid && m_key_ready)begin
                m_key_valid <= '0;
            end
            if(m_value_valid && m_value_ready)begin
                m_value_valid <= '0;
            end
            //launcher
            case(launch_state)
               ST_LAUNCH_IDLE: begin
                    if(launch_on)begin
                        launch_state <= ST_LAUNCH_BEGIN;
                        launch_on       <= 0;
                    end
               end
               ST_LAUNCH_BEGIN: begin
                if(value_box_number_launcher - 1 > 0)begin
                    value_box_number_launcher <= value_box_number_launcher - 1;
                    m_value_valid     <= fifo_value_valid;
                    m_value_data      <= {alloc_pointer_buffer,16'b0,fifo_value_out_data};
                    fifo_value_ready  <= m_value_ready;
                end
                else begin
                    launch_state <= ST_LAUNCH_IDLE;
                    fifo_value_ready <= 0;
                end
               end
            endcase
            //
            case (state)
                ST_IDLE: begin
                    if (meta_valid && meta_ready) begin
                        if (meta_data[95:88] == 8'd1) begin
                            state <= ST_INSERT_BEGIN;
                            value_box_number <= ( meta_data[79:64] + 6'd63 ) >> 6;
                            key_valid_buffer <= key_valid;
                            insert_wait_counter <= insert_wait_counter + 1;
                            alloc_ready <= m_value_ready && m_key_ready;
                            value_len_byte    <=  meta_data[79:64];  
                        end
                        else begin
                            m_value_valid   <= '0;
                            alloc_ready     <= 0;
                            m_key_valid       <= key_valid;
                            m_key_data        <= {1'b1, 16'h0000, key_data};
                            fifo_value_ready  <= 1'b0;
                        end
                    end
                end
                ST_INSERT_BEGIN:begin
                    if(insert_wait_counter == 2)begin
                        insert_wait_counter <= '0;
                        m_value_valid     <= fifo_value_valid && alloc_valid;
                        m_value_data      <= {alloc_pointer,value_len_byte, fifo_value_out_data};
                        alloc_pointer_buffer <= alloc_pointer;
                        fifo_value_ready  <= m_value_ready;
                        m_key_valid       <= alloc_valid && key_valid_buffer;
                        m_key_data        <= {1'b0, alloc_pointer, key_data};
                        alloc_ready       <= '0;  
                        value_box_number_launcher <= value_box_number;        
                        state <= ST_IDLE;
                    end
                    else begin
                        if(insert_wait_counter == 1)begin
                            launch_on       <= 1;
                            if(value_box_number - 1 > 0)begin
                                fifo_value_ready <= m_value_ready;
                            end
                        end
                        insert_wait_counter <= insert_wait_counter + 1;
                    end
                end
            endcase
        end
    end

    
    
    
    request_parser #(
        .DATA_WIDTH (512),
        .META_WIDTH (96)
    ) request_parser_inst (
        .clk            (clk),
        .rst_n          (rst_n),

        .s_axis_tdata   (s_axis_tdata), 
        .s_axis_tvalid  (s_axis_tvalid),  
        .s_axis_tlast   (s_axis_tlast),  
        .s_axis_tkeep   (s_axis_tkeep),  
        .s_axis_tready  (s_axis_tready), 

        .m_key_data     (key_data),
        .m_key_valid    (key_valid),
        .m_key_ready    (key_ready),

        .m_meta_data    (meta_data),
        .m_meta_valid   (meta_valid),
        .m_meta_ready   (meta_ready),

        .m_value_data   (value_data),
        .m_value_valid  (value_valid),
        .m_value_length (value_length),
        .m_value_last   (value_last),
        .m_value_ready  (value_ready),

        .m_malloc_data  (parser_to_allocator_data),
        .m_malloc_valid (parser_to_allocator_valid),
        .m_malloc_ready (parser_to_allocator_ready)
    );
    
    allocator #(
        .cache_depth (16),  
        .MEMORY_WIDTH(512),
        .CLASS_COUNT (4),   
        .BLOCKSIZE   (64)   //B    
    ) allocator_inst (
        .clk           (clk),     
        .rst_n         (rst_n),   
                
        .req_valid     (parser_to_allocator_valid),
        .req_data      (parser_to_allocator_data),
        .req_ready     (parser_to_allocator_ready),
                
        .alloc_pointer (alloc_pointer),  
        .alloc_valid   (alloc_valid),
        .alloc_ready   (alloc_ready),
                
        .free_pointer  (free_pointer),
        .free_valid    (free_pointer_valid), 
        .free_ready    (free_pointer_ready)     
    );
endmodule

