`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/01 17:31:31
// Design Name: 
// Module Name: request_parser
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

/*
bit 127 :  64   =  meta           (64 bit)   
bit  63 :  56   =  opcode         (8 bit)    
bit  55 :  48   =  keylen_words   (8 bit)    
bit  47 :  32   =  totlen_words   (16 bit)   
bit  31 :  16   =  0              (16 bit)   
bit  15 :   0   =  0xFFFF         (16 bit)   
*/
module request_parser#(
    parameter DATA_WIDTH = 512,
    parameter META_WIDTH = 96
)(
    input                           clk,
    input                           rst_n,
    
    input [DATA_WIDTH-1:0]          s_axis_tdata, 
    input                           s_axis_tvalid,  
	input 		                    s_axis_tlast,  
	input [DATA_WIDTH/8-1:0]        s_axis_tkeep,  
	output                          s_axis_tready, 
	
    output reg [63:0]               m_key_data,
	output reg     	                m_key_valid,
	input                           m_key_ready,
	
	output reg [META_WIDTH-1:0]     m_meta_data,
	output reg                      m_meta_valid,
	input                           m_meta_ready,

    output reg [DATA_WIDTH-1:0]     m_value_data,
	output reg                      m_value_valid,
	output reg [15:0]               m_value_length,
	output reg                      m_value_last,
	input                           m_value_ready,

	output reg [15:0]               m_malloc_data,
	output reg                      m_malloc_valid,
    input  wire                     m_malloc_ready    
    );
    
    localparam [2:0]
	   ST_IDLE         = 0,
	   ST_DATA_FETCH   = 1,
	   ST_DROP         = 2,
	   ST_VALUE        = 3;
    reg [2:0] state;
    
    localparam [9:0]
        HEAD_LENTH = 128,
        KEY_LENTH = 64;
            
        
reg [7:0] opcode;
reg [7:0] keylen;
reg [15:0] vallen;
reg [63:0] net_meta;

reg [319:0]    value_data_buf;
reg            value_last_buf;

reg inready;
wire outready;

reg force_throw;
reg[31:0] throw_length_left;
wire readyfornew;
assign readyfornew = m_meta_ready & m_key_ready & m_value_ready & m_malloc_ready;
assign outready = m_meta_ready & m_key_ready & m_value_ready;
assign s_axis_tready = (state!=ST_IDLE) ? ((inready & outready) | force_throw): 0;
always@(posedge clk)begin
    if(!rst_n)begin
        m_meta_valid <= 0;
		m_malloc_valid <= 0;
		m_key_valid <= 0;
		m_value_valid <= 0;
		m_value_last <= 0; 
		state <= ST_IDLE;
		inready <= 0;
        force_throw <= 0;
        throw_length_left <= 0;
        opcode <= 0; keylen <= 0; vallen <= 0; net_meta <= 0;
        value_data_buf <= 0; value_last_buf <= 0;
        m_value_data <= 0; m_key_data <= 0; m_meta_data <= 0;
    end
    else begin
        if(m_meta_valid == 1 && m_meta_ready == 1)begin
            m_meta_valid <= 0;
        end
        
        if(m_malloc_valid == 1 && m_malloc_ready == 1)begin
            m_malloc_valid <= 0;
        end
        
        if(m_key_valid == 1 && m_key_ready == 1)begin
            m_key_valid <= 0;
        end
        if (m_value_valid==1 && m_value_ready==1) begin
			m_value_valid <= 0;
			m_value_last <= 0;
		end
    end
    case (state)
        ST_IDLE: begin
            if(s_axis_tvalid == 1 && readyfornew == 1 )begin
               opcode <= s_axis_tdata[63:64-8];
               keylen <= s_axis_tdata[64-8-1:64-16];
               net_meta <= s_axis_tdata[127:64];
               vallen <= s_axis_tdata[32+15:32]-s_axis_tdata[64-8-1:64-16];
               inready <= 1;
               state <= ST_DATA_FETCH;
               value_last_buf <= '0;
            end
            else if (s_axis_tvalid==1)begin
                force_throw <= 1;
                throw_length_left <= s_axis_tdata[32+15:32];
                state <= ST_DROP;	
            end     
        end
        ST_DATA_FETCH: begin
           if (s_axis_tvalid==1 && s_axis_tready==1)  begin
                //meta
               m_meta_data <= {opcode,keylen,vallen,net_meta};
               m_meta_valid <= 1;
               m_malloc_data <= vallen;
               m_malloc_valid <= (opcode==8'h01) ? 1 : 0;
               // KEY
               m_key_valid <= 1;
               m_key_data <= s_axis_tdata[HEAD_LENTH+KEY_LENTH-1:HEAD_LENTH];
               //VALUE
               if(opcode==8'h01)begin
                   m_value_length <= vallen*8;
                   if(vallen*8 >320)begin 
                        state <= ST_VALUE; 
                        value_data_buf <= s_axis_tdata[DATA_WIDTH-1:HEAD_LENTH+KEY_LENTH];
                   end
                   else begin
                        m_value_valid <= 1;              
                        m_value_last <= 1;
                        state <= ST_IDLE;
                        m_value_data <= {{HEAD_LENTH+KEY_LENTH{1'b0}},s_axis_tdata[DATA_WIDTH-1:HEAD_LENTH+KEY_LENTH]};
                   end
                end else begin
                    m_value_length <= '0;
                    state <= ST_IDLE;             
                end
           end 
        end
        ST_VALUE: begin
            m_value_valid <= 1'b0;
            m_value_last  <= 1'b0;     
            if (s_axis_tvalid && s_axis_tready) begin
                m_value_valid <= 1'b1;
                if (value_last_buf) begin
                    m_value_data   <= {'0, value_data_buf};
                    m_value_last   <= 1'b1;
                    state          <= ST_IDLE;
                    inready        <= 1'b0;
                    value_last_buf <= 1'b0;   
                end
                else begin
                    m_value_data   <= {s_axis_tdata[HEAD_LENTH+KEY_LENTH-1:0], value_data_buf};
                    value_data_buf <=  s_axis_tdata[DATA_WIDTH-1:HEAD_LENTH+KEY_LENTH];
                    if (s_axis_tlast && (s_axis_tkeep > 64'hFF_FFFF)) begin
                        value_last_buf <= 1'b1;
                    end
                    else if (s_axis_tlast && (s_axis_tkeep < 64'hFF_FFFF)) begin
                        m_value_last <= 1'b1;
                        state        <= ST_IDLE;
                        inready      <= 1'b0;
                    end
                end
            end
        end
        ST_DROP: begin
                if (s_axis_tvalid==1 && s_axis_tready==1) begin
					throw_length_left <= throw_length_left-1;					
				end
                if (s_axis_tvalid==1 && s_axis_tready==1 && throw_length_left==0)  begin
					state <= ST_IDLE;
					inready <= 0;
					force_throw <= 0;
				end
        end
    endcase

end
    
    
    
endmodule
