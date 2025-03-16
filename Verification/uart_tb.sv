`timescale 1ns/1ns
`include "TB_pkg.sv"

import tb_pkg::*;

module tb_uart;

    parameter integer DATA_WIDTH = 8;
    parameter int TX_CLK_FREQ = 50000000;
    parameter int RX_CLK_FREQ = 25000000;
    parameter int BAUD_RATE = 19200;
    parameter int TX_CLK_PERIOD = 20;
    parameter int RX_CLK_PERIOD = 40;

    logic tx_clk, rx_clk, tx, rx, rst;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [DATA_WIDTH-1:0] rx_data;
    logic start, done_tx;

    logic [DATA_WIDTH-1:0] random_data;

    covergroup cg_uart;
        coverpoint random_data;
    endgroup

    randomData #(.DATA_WIDTH(DATA_WIDTH)) rd;
    cg_uart cg;

    uart_tx #(
        .CLK_FREQ(TX_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH)
    ) transmitter (
        .clk(tx_clk),
        .rst(rst),
        .start(start),
        .tx_data(tx_data),
        .tx(tx),
        .done_tx(done_tx)
    );

    uart_rx #(
        .CLK_FREQ(RX_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH)
    ) receiver (
        .clk(rx_clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data)
    );

    always #(TX_CLK_PERIOD / 2) tx_clk = ~tx_clk;
    always #(RX_CLK_PERIOD / 2) rx_clk = ~rx_clk;

    assign rx = tx;

    initial begin
        $display("Starting UART Testbench...");
        
        rd = new();
        cg = new();
        
        tx_clk = 0;
        rx_clk = 0;
        rst = 1;
        start = 0;
        tx_data = 0;
        random_data = 8'h00;
        #100;
        rst = 0;

        repeat (20) begin
            random_data = rd.randomc();
            
            $display("Random value generated: %h", random_data);

            #100;
            $display("Sending data: 0x%h", random_data);
            tx_data = random_data;
            start = 1;
            #TX_CLK_PERIOD;
            start = 0;

            wait (done_tx);
            #TX_CLK_PERIOD;

            #100;
            if (rx_data == random_data) begin
                $display("Test Passed: Received data matches transmitted data (0x%h) \n", rx_data);
            end else begin
                $display("Test Failed: Received data (0x%h) does not match transmitted data (0x%h) \n", rx_data, random_data);
            end

            cg.sample();
        end

        $display("Total functional Coverage for random_data: %0.2f%%", cg.get_coverage());

        $stop;
    end

    initial begin
        $monitor("Time=%.3tms | TX=0x%h | RX=0x%h | Done_TX=%b", $realtime / 1e6, tx_data, rx_data, done_tx);
    end

endmodule
