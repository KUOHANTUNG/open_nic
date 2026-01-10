`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/20 12:36:17
// Design Name: 
// Module Name: launcher
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


module launcher(
    input             aclk,
    input             reset_n,
    
    input [15:0]      s_axis_alloc_pointer,
	input  	          s_axis_alloc_valid,
	output logic      s_axis_alloc_ready,
	
	input [63:0]      s_axis_key_data,
	input     	      s_axis_key_valid,
	output logic      s_axis_key_ready,
	
    input  [95:0]     s_axis_meta_data,
	input             s_axis_meta_valid,
	output logic      s_axis_meta_ready,
	
	input  [511:0]    s_axis_value_data,
	input             s_axis_value_valid,
	output logic      s_axis_value_ready,
	
	
	output logic [543:0] m_value_data_and_addr,
    output logic         m_value_valid,
    input              m_value_ready, 
    
    output logic [87:0]  m_key_data,
    output logic         m_key_valid,
    input                m_key_ready
    );
    
    
    logic [15:0] alloc_pointer;
    logic [7:0]  opcode;
    logic [15:0] data_length;
    logic [15:0] data_length_byte;
    logic [15:0] value_box_launcher_counter;
    assign opcode = s_axis_meta_data[95:88];
    assign data_length = s_axis_meta_data[79:64];
    localparam [3:0]
        ST_LAUNCH_RECV = 0,
        ST_LAUNCH_LAUNCH_INSERT = 1,
        ST_LAUNCH_LAUNCH_DELETE = 2;
    reg [3:0] launch_state;
    
    
    always@(posedge aclk) begin
        if(!reset_n)begin
            s_axis_alloc_ready <= 1'b1;
            s_axis_key_ready <= 1'b0;
            s_axis_value_ready <= 1'b0;
            m_value_data_and_addr <= 544'b0;
            m_key_data <= 88'b0;
            m_value_valid <= 1'b0;
            m_key_valid <= 1'b0;
            launch_state <= ST_LAUNCH_RECV;
            s_axis_meta_ready <= 1'b0; 
            alloc_pointer <= 16'b0;
            data_length_byte <= 16'b0;
            value_box_launcher_counter <= 16'b0;
        end
        else begin
            if(m_value_valid && m_value_ready) begin
                m_value_valid <= 1'b0;
            end
            if(m_key_ready && m_key_valid)begin
                m_key_valid <= 1'b0;
            end
            case(launch_state)
                ST_LAUNCH_RECV: begin
                    if(s_axis_key_valid && s_axis_meta_valid)begin
                        if(opcode == 8'b1)begin
                            if(s_axis_value_valid && s_axis_alloc_valid && s_axis_alloc_ready )begin
                                s_axis_key_ready <= 1'b1;
                                alloc_pointer <= s_axis_alloc_pointer;
                                s_axis_value_ready <= 1'b1;
                                s_axis_meta_ready <= 1'b1; 
                                data_length_byte <=  data_length;                          
                                launch_state <= ST_LAUNCH_LAUNCH_INSERT;
                                value_box_launcher_counter <=   ( data_length + 16'd63 ) >> 6; 
                                s_axis_alloc_ready <= 1'b0;                           
                            end
                        end
                        else begin
                            s_axis_key_ready <= 1'b1;
                            s_axis_meta_ready <= 1'b1;
                            launch_state <= ST_LAUNCH_LAUNCH_DELETE;
                        end
                    end
                    else begin
                        s_axis_key_ready <= 1'b0;
                        s_axis_value_ready <= 1'b0;
                        s_axis_meta_ready <= 1'b0;
                    end
                end
                ST_LAUNCH_LAUNCH_DELETE: begin
                    m_key_data <= {8'd1, 16'h0000, s_axis_key_data};
                    m_key_valid <= 1'b1;
                    launch_state <= ST_LAUNCH_RECV;
                    s_axis_key_ready <= 1'b0;
                    s_axis_meta_ready <= 1'b0;
                end
                ST_LAUNCH_LAUNCH_INSERT: begin
                    if(value_box_launcher_counter != 0)begin
                        m_value_data_and_addr <= {alloc_pointer,data_length_byte,s_axis_value_data};
                        m_key_data <= {8'b0,alloc_pointer, s_axis_key_data};
                        m_value_valid <= 1'b1;
                        m_key_valid <= 1'b1; 
                        s_axis_meta_ready <= 1'b0; 
                        s_axis_key_ready <= 1'b0;
                        value_box_launcher_counter <= value_box_launcher_counter - 16'b1;
                    end 
                    else begin
                        launch_state <= ST_LAUNCH_RECV;
                        s_axis_value_ready <= 1'b0;
                        s_axis_alloc_ready <= 1'b1;
                    end                                  
                end
                default: begin
                    launch_state <= ST_LAUNCH_RECV;
                end
            endcase
        end
    end
   
    
endmodule
