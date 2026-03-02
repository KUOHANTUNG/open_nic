`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/31 23:26:57
// Design Name: 
// Module Name: time_evaluator
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


module time_evaluator(
    input           clk,
    input           rst_n,
    
    input           tx_valid,
    input           tx_ready,
    input [511:0]   tx_data,
    input           tx_last,
    
    input           rx_valid,
    input [511:0]   rx_data,
    input           rx_last,
    
    output reg [63:0]   running_cnt,
    output reg [63:0]   tx_pkts,
    output reg [63:0]   rx_pkts
    );
 /*******rx************/   
    reg rx_in_frame;
    
    wire rx_fire = rx_valid;
    wire rx_sop = rx_fire && !rx_in_frame;
    
    always @(posedge clk)begin
        if(!rst_n)begin
            rx_in_frame <= 0;
        end
        else begin
            if(rx_fire)begin
                if(rx_last) begin
                    rx_in_frame <= 1'b0;
                end
                else begin
                    rx_in_frame <= 1'b1;
                end    
            end
        end
    end
  /*******tx***********/
  reg tx_in_frame; 
  wire tx_fire = tx_valid && tx_ready;
  wire tx_sop  = tx_fire && !tx_in_frame; 
  
  always @(posedge clk) begin
      if (!rst_n) tx_in_frame <= 1'b0;
      else if (tx_fire) begin
        if (tx_last) 
            tx_in_frame <= 1'b0;
        else         
            tx_in_frame <= 1'b1;
      end
    end
 
 /******classifier********/
 function automatic [7:0] get_byte_512(input [511:0] d, input integer idx);
  get_byte_512 = d[8*idx +: 8];  
 endfunction   
 // TX
 wire [511:0] rx_d0 = rx_data;
 wire [15:0]  rx_ethertype = { get_byte_512(rx_d0, 12), get_byte_512(rx_d0, 13) };
 wire [7:0]   rx_ip_proto  =   get_byte_512(rx_d0, 23);
 wire         rx_sop_is_udp = (rx_ethertype == 16'h0800) && (rx_ip_proto == 8'd17);
 //RX
 wire [511:0] tx_d0 = tx_data;
 wire [15:0]  tx_ethertype = { get_byte_512(tx_d0, 12), get_byte_512(tx_d0, 13) };
 wire [7:0]   tx_ip_proto  =   get_byte_512(tx_d0, 23);
 wire         tx_sop_is_udp = (tx_ethertype == 16'h0800) && (tx_ip_proto == 8'd17);
 //flag
 reg rx_is_udp_pkt;
 reg tx_is_udp_pkt;
 
 always @(posedge clk) begin
  if (!rst_n) begin
    rx_is_udp_pkt <= 1'b0;
  end else begin
    if (rx_sop) 
        rx_is_udp_pkt <= rx_sop_is_udp;
    if (rx_fire && rx_last) 
        rx_is_udp_pkt <= 1'b0;
  end
 end
 always @(posedge clk) begin
  if (!rst_n) begin
    tx_is_udp_pkt <= 1'b0;
  end else begin
    if (tx_sop) 
        tx_is_udp_pkt <= tx_sop_is_udp; 
    if (tx_fire && tx_last) 
        tx_is_udp_pkt <= 1'b0;
  end
 end  
 //count
 reg eva_flag;
 always @(posedge clk)begin
    if(!rst_n)begin
        running_cnt <= 64'b0;
        tx_pkts <= 64'b0;
        rx_pkts <= 64'b0;
        eva_flag <= 0;
    end
    else begin
        if (rx_fire && rx_last && rx_is_udp_pkt) begin
          rx_pkts <= rx_pkts + 64'd1;
          eva_flag   <= 1'b1;
        end
        if (tx_fire && tx_last && tx_is_udp_pkt) begin
          if (rx_pkts - 64'd1 == tx_pkts) begin
            eva_flag <= 1'b0;
          end
          tx_pkts <= tx_pkts + 64'd1;
        end
        if(eva_flag == 1'b1)begin
            running_cnt <= running_cnt + 64'b1;
        end
    end
 end
    
endmodule
