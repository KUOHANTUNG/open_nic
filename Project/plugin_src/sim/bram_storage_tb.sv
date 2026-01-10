`timescale 1ns / 1ps 



module bram_storage_tb;


    logic                   clk;
    logic                   rst_n;

    // Port A INPUT (cmd/data share)
    logic                   s_axis_rx_valid_a;
    logic                   s_axis_rx_ready_a;

    // Port A OUTPUT (read data out)
    logic                   s_axis_tx_valid_a;
    logic  [527:0]          s_axis_tx_data_a;
    logic                   s_axis_tx_ready_a;

    // Port A cmd
    logic  [15:0]           s_axis_addr_a;

    // Port B INPUT (cmd/data share)
    logic                   s_axis_rx_valid_b;
    logic  [543:0]          s_axis_rx_data_b; //address & length + data
    logic                   s_axis_rx_ready_b;

    // Port B cmd
    logic  [15:0]           s_axis_addr_b;

   
    //250 Mhz Clock
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;  // 
    end
    //rest
    initial begin
        rst_n = 1'b0;
        #200;                  
        rst_n = 1'b1;
    end
   
    initial begin
        s_axis_rx_valid_b = 1'b0;
        s_axis_tx_ready_a = 1'b1;
        #500
        s_axis_rx_valid_b = 1'b1;
        s_axis_rx_data_b = {16'h0001,16'h64, {128{4'hA}}};
        #4
        s_axis_rx_valid_b = 1'b0;
        #50
        s_axis_rx_valid_a = 1'b1;
        s_axis_addr_a = 16'h0001;
        #4
        s_axis_rx_valid_a = 1'b0;    
    end

bram_storage
bram_storage_tb(
        .clk                (clk),
        .rst_n              (rst_n),

        // A port (read)
        .s_axis_rx_valid_a  (s_axis_rx_valid_a),
        .s_axis_rx_data_a   (s_axis_rx_data_a ),
        .s_axis_rx_ready_a  (s_axis_rx_ready_a),

        .s_axis_tx_valid_a  (s_axis_tx_valid_a),
        .s_axis_tx_data_a   (s_axis_tx_data_a ),
        .s_axis_tx_ready_a  (s_axis_tx_ready_a),
        .s_axis_addr_a      (s_axis_addr_a    ),
        // B port (write)
        .s_axis_rx_valid_b  (s_axis_rx_valid_b),
        .s_axis_rx_data_b   (s_axis_rx_data_b ),//address & length + data
        .s_axis_rx_ready_b  (s_axis_rx_ready_b),

        .s_axis_tx_valid_b  (s_axis_tx_valid_b),
        .s_axis_tx_data_b   (s_axis_tx_data_b ),
        .s_axis_tx_ready_b  (1'b1)
); 
endmodule
