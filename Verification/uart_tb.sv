`timescale 1ns/1ps
`include "TB_pkg.sv"

import tb_pkg::*;

module tb_uart;

    localparam CLK_PERIOD = 20;
    localparam integer DATA_WIDTH = 8;
    parameter int CLK_FREQ = 50000000;
    parameter int BAUD_RATE = 19200;

    logic clk, rst;
    logic rx, tx;
    logic [DATA_WIDTH-1:0] tx_data_in;
    logic [DATA_WIDTH-1:0] rx_data_out;
    logic start, done_tx, tx_active;

    randomData rd;
    cg_uart cov;

    logic [DATA_WIDTH-1:0] test_data;

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data_out(rx_data_out)
    );

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data_in(tx_data_in),
        .tx(tx),
        .tx_active(tx_active),
        .done_tx(done_tx)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;

    assign rx = tx;

    initial begin
        $display("Starting UART Testbench...");
        
        rd = new();
        cov = new(clk, test_data, tx_active);

        $display("Initiating Randomization Class...");
        
        clk = 0;
        rst = 1;
        start = 0;
        tx_data_in = 0;
        test_data = 8'hA5;
        #100;
        rst = 0;

        repeat (255) begin
            test_data = rd.randomc();
            $display("Random value generated: %h", test_data);

            #100;
            $display("Sending data: 0x%0h", test_data);
            tx_data_in = test_data;
            start = 1;
            #CLK_PERIOD;
            start = 0;

            wait (done_tx);
            #CLK_PERIOD;

            #100;
            if (rx_data_out == test_data) begin
                $display("Test Passed: Received data matches transmitted data (0x%0h) \n", rx_data_out);
            end else begin
                $display("Test Failed: Received data (0x%0h) does not match transmitted data (0x%0h) \n", rx_data_out, test_data);
            end

            cov.sample();
        end

        $display("Coverage for random_data bins:");
        $display("Low Values: %0d", cov.random_data.get_coverage());
        $display("Mid Values: %0d", cov.random_data.get_coverage());
        $display("High Values: %0d", cov.random_data.get_coverage());
        $display("Max Values: %0d", cov.random_data.get_coverage());

        $display("Coverage for tx_active bins:");
        $display("Tx Inactive: %0d", cov.tx_active.get_coverage());
        $display("Tx Active: %0d", cov.tx_active.get_coverage());
        $stop;
    end

    initial begin
        $monitor("Time=%.3tms | TX=0x%0h | RX=0x%0h | TX_Active=%b | Done_TX=%b",
                 $realtime / 1e6, tx_data_in, rx_data_out, tx_active, done_tx);
    end

endmodule
